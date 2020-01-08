$folder ='C:\v-haiy\Agents\vsts-agent-win-x64-2.160.1\_work\1\SupportContent-Public-RP\Exchange\ExchangeHybrid\accessing-email-data' 
$filename=Join-Path $folder 'internaltest.md'
$fullcontent = Get-Content $filename  -Raw

        $tags = select-string -InputObject  $fullcontent  -Pattern   '---\r?\n?' -AllMatches
        if($tags.Matches.Count -gt 1)
        {
            
            $isinteralsyntax = select-string -InputObject  $fullcontent  -Pattern   'mmc.confidentiality\s*:\s*internal' -AllMatches
            if($isinteralsyntax.Matches.Count  -gt 0){
                $internalIndex = $isinteralsyntax.Matches[0].Index
                $begintagIndex = $tags.Matches[0].Index
                $endtagIndex =$tags.Matches[1].Index
                if($internalIndex -gt $begintagIndex -and $internalIndex -lt $endtagIndex){
                    Write-Host internal
                }
            }
        }


        $filename =Join-Path $folder "PublicDocwithInternalSections.md"
        $fullcontent = Get-Content $filename  -Raw

$beginTag = ":::mmc.confidentiality:internal";
$endTag = ":::";

$isinternal=$false
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
                $isinternal=$true
                break
            }
        } 
    }else {
        break
    }
}


$isinternal
$fullcontent