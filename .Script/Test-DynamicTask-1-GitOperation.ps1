param($PAT,$SyncToOrganizationName,$SyncToProjectName,$SyncToReposName,$AzureUserEmail,$AzureUserName,$ExcutePSFile)

if(-not $ExcutePSFile)
{
	Write-Error "You must set the ExcutePSFile environment variable - For example, DynamicTask-Main-Daily.ps1";
    exit 1;
}

# set environment variables
if(-not $env:PAT)
{
	Write-Error "You must set the PAT environment variable";
    exit 1;
}
if(-not $env:SyncToOrganizationName)
{
	Write-Error "You must set the SyncToOrganizationName environment variable - For example, Supportability";
    exit 1;
}
if(-not $env:SyncToProjectName)
{
	Write-Error "You must set the SyncToProjectName environment variable - For example, Azure";
    exit 1;
}
if(-not $env:SyncToReposName)
{
	Write-Error "You must set the SyncToReposName environment variable - For example, WikiContent";
    exit 1;
}

$PAT = $env:PAT;
$OrganizationName = $env:SyncToOrganizationName;
$ProjectName = $env:SyncToProjectName;
$ReposName = $env:SyncToReposName;
$AzureUserEmail = $env:AzureUserEmail;
$AzureUserName = $env:AzureUserName;
Write-Host "pat number is " $PAT;
Write-Host "env pat number is " $env:PAT;
Write-Host "OrganizationName is " $OrganizationName;
Write-Host "ProjectName is " $ProjectName;
Write-Host "AzureUserEmail is " $AzureUserEmail;
Write-Host "AzureUserName is " $AzureUserName;

git config --global user.email $AzureUserEmail
git config --global user.name $AzureUserName
$ScriptFolder =".Script\";
$CurrentProjContentLocation=Get-location;
Write-Host "Current Project Content Location" $CurrentProjContentLocation;

Function FindChild($parentFolderPath,$sourcePath,$destinationPath){

  $newPath=$parentFolderPath.Replace($sourcePath,$destinationPath)

  Write-Host "ObjectPath:" $newPath;
  if(Test-Path -Path $newPath){
	Write-Host $newPath "exist";
  }else{
    Write-Host $newPath "not exist";
    New-Item -ItemType "directory" -path $newPath
  }

  $chlidItemsList=Get-childitem $parentFolderPath |where {$_.Attributes -match 'Directory'}
  if($chlidItemsList.Count -eq 0){}
  else{
    $chlidItemsList|Foreach-object{
	  if($_.FullName.contains("\.git")){}
	  else{
	    $newparentFolderPath=$parentFolderPath+"\"+$_.name;
	    FindChild  $newparentFolderPath $sourcePath $destinationPath;
	  }
	}
  }
}

Function PushtoRemote($CloneRepo,$RepoPushUrl,$RepoName,$UserEmail,$UserName)
{
    $MixProjLocation = Get-Location;
    Write-Host "Current Location is:" $MixProjLocation;
    #$sshItemLocation = $MixProjLocation.ToString() + "\.test\.ssh\*";

	#get back to parent folder of current project
	cd ..

	#clone destination project
    $GithubTempRepo=$RepoName;
    Write-Host "Remote Repo operations start:";
    Write-Host "Clone Remote Repo to local ..\"$RepoName;
    git clone $CloneRepo $RepoName 

	#enter destination project and initialize user account
	cd $RepoName 
    Write-Host "Config account info UserEmail:"$UserEmail "UserName:"$UserName;
	git config --global user.email $UserEmail
    git config --global user.name $UserName

	#prepare for sorce and destination patch
	$updateFolder="\";
	$sourcePath=$CurrentProjContentLocation.ToString()+$updateFolder;
	$currentPath=Get-location;
	$destinationPath=$currentPath.ToString()+$updateFolder;
	Write-Host "sourcePath" $sourcePath;
	Write-Host "destinationPath" $destinationPath;

	#Remove items
	Write-Host "Remove all the item except .git.Script folder in destinationPath before update";
	$projGitInfoLocation = $destinationPath+"\.git";
	$projScriptInfoLocation = $destinationPath+"\azure-pipelines.yml";
	Get-ChildItem -Path $destinationPath -Recurse|Where {$_.FullName -notlike $projGitInfoLocation}|Where {$_.name -notlike 'azure-pipelines.yml'}|Remove-Item -force -Recurse

	#Create Directory tree
	Write-Host "Create new directory in" $destinationPath;
	FindChild $sourcePath $sourcePath $destinationPath;

	#Coly files
	Write-Host "Copy Files from" $sourcePath "to" $destinationPath "exclude .git folder";	
	$sourceprojGitInfoLocation = $sourcePath+"\.git";
	$sourceprojScriptInfoLocation = $sourcePath+"\.Script";
	Get-ChildItem -Path  $sourcePath -Recurse|Where {$_.FullName -notlike $sourceprojGitInfoLocation}|where {$_.Attributes -notmatch 'Directory'}|Foreach-Object{
	  if($_.FullName.endswith("azure-pipelines.yml") ){}
	  else{
	    $source=$_.FullName;
	    $destination=$_.FullName.Replace($sourcePath,$destinationPath);
	    Write-Host "Copy" $source "to" $destination;
	    Copy-Item $source -Destination $destination -Recurse
	  }
	}
	Write-Host "Copy items complete";

	$ItemListofDocFolder = Get-ChildItem -Path $destinationPath -Force;
	Write-Host "Items in" $ItemListofDocFolder;
	ForEach($Item in $ItemListofVssAdministratorssh){
	   Write-Host $Item.FullName;
	   git add $Item.name
	}

	git add .
	
	Write-Host "Git status after modification";
	git status

	Write-Host "Commit to local Repo";
	git commit -m "test 1204-1"

	Write-Host "Push to remote Repo using https";

	Write-Host "Set remote Repo";
    git remote set-url --push origin $RepoPushUrl

	Write-Host "Origin after";
	git remote show origin

	Write-Host "Push to remote Repo";
    git push -u origin master

    cd ..

}


#Run the script tasks
. ((Split-Path $MyInvocation.InvocationName) + $ScriptFolder + $ExcutePSFile);
RunDynamicPSTasks $ScriptFolder;

#Push to Azure Public Repo
$CloneRepo="https://${OrganizationName}:${PAT}@dev.azure.com/${OrganizationName}/${ProjectName}/_git/${ReposName}";
$AzureRepoPushUrl="https://${OrganizationName}:${PAT}@dev.azure.com/${OrganizationName}/${ProjectName}/_git/${ReposName}";
PushtoRemote $CloneRepo $AzureRepoPushUrl $ReposName $AzureUserEmail $AzureUserName;


