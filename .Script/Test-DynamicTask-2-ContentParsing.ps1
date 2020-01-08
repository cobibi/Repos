$CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CWDir=Split-Path -Parent (Split-Path -Parent $CurrentyDir)

Write-Host "ProjectDir"： $CWDir;
Write-Host "ObjectDir"： $CurrentyDir;
$DocFolder = "\";

Function Main() {
    $splitDir=$CWDir+$DocFolder;
	Write-Host "splitDir"： $splitDir;
    SplitContent($splitDir);
}



#Exclude inner content
Function SplitContent($SplitDir){

     #$fileList = Get-ChildItem -Path $SplitDir -Filter *.md;
	 $fileListAll = Get-ChildItem -Path $SplitDir . -recurse;
	 
	 #Parsing files	 
	 foreach ($file in $fileListAll) {
	    Write-Host "File Name: " $file.FullName ;
	    if($file.Attributes -match 'Directory'){
		  Write-Host "This is a Directory" $file.FullName ",will continue";
		  Continue;
		}

		#1 checking
		#1.1 checking keyword
		if($file.FullName.toLower().contains("assets-internal")){
		  Write-Host "Find keyword asset-internal in filepath" $file.FullName;
		if(Test-Path $file.FullName){
		  Remove-Item $file.FullName
		}	 
		  Write-Host "This is an internal file, will skip and checking for next one." $file.FullName;
		  continue;
		}
		#1.2 checking md file
		if($file.FullName.endswith(".md")){
		  Write-Host "This is a md file." $file.FullName;
		}else{
		  Write-Host "This is not a md file, will skip and checking for next one." $file.FullName;
		  continue;
		}

		#2 parsing Tags
		Write-Host "Start Parsing ...";	 
		Write-Host "Part II Tags:";
		$isInternal=$false;

		$fullcontent = Get-Content $file.FullName  -Raw

        $tags = select-string -InputObject  $fullcontent  -Pattern   '---\r?\n?' -AllMatches
        if($tags.Matches.Count -gt 1)
        {
            
            $isinteralsyntax = select-string -InputObject  $fullcontent  -Pattern   'mmc.confidentiality\s*:\s*internal' -AllMatches
            if($isinteralsyntax.Matches.Count  -gt 0){
                $internalIndex = $isinteralsyntax.Matches[0].Index
                $begintagIndex = $tags.Matches[0].Index
                $endtagIndex =$tags.Matches[1].Index
                if($internalIndex -gt $begintagIndex -and $internalIndex -lt $endtagIndex){
					if(Test-Path $file.FullName){
						Remove-Item $file.FullName
					}
					Write-Host "["$file.FullName"] is an internal artical, will not be push to public.";	
					continue
                }
            }
        }		

		Write-Host "Part II Complete:";	


		#3 parsing content
	    #3.1 preparing
		Write-Host "Part III Content:";	

		while($true){
			$beginTags = select-string -InputObject  $fullcontent  -Pattern   ':::\s*mmc.confidentiality\s*:\s*internal\s*(\r|\n)' 
			$endTags = select-string -InputObject  $fullcontent  -Pattern   '(\r|\n)\s*:::\s*(\r|\n|^)' -AllMatches
			
			if($beginTags.Matches.Success -gt 0 -and $endTags.Matches.Count -gt 0){
			$beginIndex = $beginTags.Matches.Index
				for ($j=0; $j -lt $endTags.Matches.Count; $j++) {
					if( $endTags.Matches[$j].Index -gt $beginIndex)
					{
						$endIndex =$endTags.Matches[$j].Index
						$endLength=$endTags.Matches[$j].Length
						$fullcontent = $fullcontent.Substring(0,$beginIndex) +$fullcontent.Substring($endIndex+$endLength,$fullcontent.Length-$endIndex-$endLength)
						$isInternal=$true
						break
					}
				} 
			}else {
				break
			}
		}

		if($isInternal)
		{
				Write-Host "Set new content";
				Set-Content -Path $file.FullName -Value $fullcontent;
		}			
		Write-Host "Part III Complete:";	
	 }
	
}



Main;
Write-Host "--------------------------- Content Parsing Compete ---------------------------";

 

 