
. "$PSScriptRoot\Common.ps1"

$CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
$CWDir = Split-Path -Parent $CurrentyDir;

#init param in local
#$env:WikiName="AzureLinuxNinjas";
#$env:GeneralPages= "GeneralPages,SharedPages";

Write-Host Start DynamicTask-2_1-GeneratePages
Function Main {
    if (IsNull($env:WikiName)) {
        
        Write-Error 'Please config the WikiName in .yml files'
        return;
        #Create index for teamList projects (Not using)
        $TeamListFile = $CWDir + "\.psscriptsonline\.configurations\TeamList.txt";

        $content = Get-Content $TeamListFile
        foreach ($line in $content) {
	        $ProjectDir = $CWDir + "\" + $line;
	        GenerateTags($ProjectDir)；    
        }
    } else {
        $ProjectDir = $CWDir + "\" + $env:WikiName;
        GenerateTags($ProjectDir)；  
    }
} 

function GeneralFolderIndexPages($ProjectDir)
{
    
	 Get-ChildItem $ProjectDir -recurse | Where-Object { $_.Attributes -eq "Directory"} | 
		ForEach-Object -Process{
			if ($_.Name.StartsWith(".") -or $_.Name -eq "Tags" -or $_.Name -eq "Welcome" ){return;}
			$directory=$_.Name;
			Get-ChildItem $_.Parent.FullName | 
				ForEach-Object -Process{
					if($_.Name -eq  $directory+".md"){
						Remove-Item -Path $_.FullName -Recurse -Force  #delete md
					}
				}
		}

  Get-ChildItem $ProjectDir -recurse | Where-Object { $_.Attributes -eq "Directory"} | 
    ForEach-Object -Process{
         if ($_.Name.StartsWith(".") -or $_.Name -eq "Tags" -or $_.Name -eq "Welcome" ){return;}
         #if ($_.Name -ne "1.0.170928.3"){ return;}
         "..."+$_.Name;
         $fileName=$_.Parent.FullName+"\"+ $_.Name+".md";
         $fileContent="";
        Get-ChildItem $_.FullName | 
        ForEach-Object -Process{
            if ($_.Name.Length -lt '1') {return;}
            $_.FullName
            if($_.Attributes -eq "Directory"){
                return;
                $directory="(" + $_.Directory.Name+"/"+$_.Name+")";
            } else {
                if ($_.FullName.Contains("\.")){ return;}
                $directory="(" + $_.Directory.Name+"/"+$_.Name+")";
            }
            $name= $_.Name;
            if ($name.EndsWith(".md")) {$name=$name.Replace(".md","") }
            $directory=$directory.Replace("\","/").Replace("%5","%255")
            if (!$directory.EndsWith(".md)")){$directory=$directory.Substring(0,$directory.Length-1)+".md)";}
            $name = RenamePageName($name);
            $fileContent+=AddNewLine(" - ["+ $name +"]"+$directory)
        }
        
        $fileContent|Out-File $fileName;
        
    }
}

function GenerateTags($ProjectDir){
    Write-Host 'Project:' $ProjectDir
    
    $GeneralPages= $env:GeneralPages.split(",");  #$env:GeneralPages: 'GeneralPages,SharedPages'
       
    foreach ($GeneralPage in $GeneralPages){
        if ($GeneralPage.Trim() -eq "") {continue;}
        $path= $ProjectDir+"/"+$GeneralPage+"/";
        If(-not(test-path $path)){ continue;}
        $file = ls $path;
        if ($file.Length -eq "0"){ continue; }
        GeneralFolderIndexPages($path);
    }
}

$ProjectDir='';
Main;
Write-Host "---------------------------Compete-----------------------";



