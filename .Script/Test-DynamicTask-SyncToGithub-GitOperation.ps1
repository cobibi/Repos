param($GithubPAT,$GithubUserEmail,$GithubUserName,$GithubRepoName,$AzureUserEmail,$AzureUserName)


# set environment variables
if(-not $env:GithubPAT)
{
	Write-Error "You must set the PAT environment variable";
    exit 1;
}
if(-not $env:GithubUserEmail)
{
	Write-Error "You must set the GithubUserEmail environment variable";
    exit 1;
}
if(-not $env:GithubUserName)
{
	Write-Error "You must set the GithubUserName environment variable";
    exit 1;
}
if(-not $env:GithubRepoName)
{
	Write-Error "You must set the GithubRepoName environment variable";
    exit 1;
}
$GithubPAT = $env:GithubPAT;
$GithubUserEmail =$env:GithubUserEmail;
$GithubUserName =$env:GithubUserName;
$GithubRepoName = $env:GithubRepoName;
$AzureUserEmail = $env:AzureUserEmail;
$AzureUserName = $env:AzureUserName;
Write-Host "GithubPAT number is " $GithubPAT;
Write-Host "GithubUserEmail is " $GithubUserEmail;
Write-Host "GithubUserName is " $GithubUserName;
Write-Host "GithubRepoName is " $GithubRepoName;
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
	Get-ChildItem -Path $destinationPath -Recurse|Where {$_.FullName -notlike $projGitInfoLocation}|Where {$_.name -notlike 'azure-pipelines.yml'}|Where {$_.name -notlike 'Test-DynamicTask-SyncToGithub-GitOperation.ps1'}|Remove-Item -force -Recurse

    #Create Directory tree
	Write-Host "Create new directory in" $destinationPath;
	FindChild $sourcePath $sourcePath $destinationPath;

    #generate new item
	Write-Host "Generate Files to "$destinationPath "exclude .git folder";	
	$sourceprojGitInfoLocation = $sourcePath+"\.git";
	$sourceprojScriptInfoLocation = $sourcePath+".Script";
	Get-ChildItem -Path  $sourcePath -Recurse|Where {$_.FullName -notlike $sourceprojGitInfoLocation}|where {$_.Attributes -notmatch 'Directory'}|Foreach-Object{
	  if($_.FullName.endswith("azure-pipelines.yml") ){}
	  elseif($_.FullName.contains($sourceprojScriptInfoLocation)){}
	  else{
	    $source=$_.FullName;
	    $destination=$_.FullName.Replace($sourcePath,$destinationPath);
	    Write-Host "Copy" $source "to" $destination;
	    Copy-Item $source -Destination $destination -Recurse
	  }
	}
	Write-Host "Copy items complete";

	git add .
	
	Write-Host "Git status after modification";
	git status

	Write-Host "Commit to local Repo";
	git commit -m "Sync From Azure Repo"

	Write-Host "Push to remote Repo using https";
	Write-Host "Set remote Repo";
    git remote set-url --push origin $RepoPushUrl

	Write-Host "Origin after";
	git remote show origin

	Write-Host "Push to remote Repo";
    git push -u origin master

    cd ..

}


#Push to Github Repo
$CloneRepo="https://${GithubUserName}:${GithubPAT}@github.com/MicrosoftDocs/${GithubRepoName}.git"
$GithubRepoPushUrl="https://${GithubUserName}:${GithubPAT}@github.com/MicrosoftDocs/${GithubRepoName}.git";
PushtoRemote $CloneRepo $GithubRepoPushUrl $GithubRepoName $GithubUserEmail $GithubUserName;

