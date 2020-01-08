#Run the script code
Function RunDynamicPSTasks($ScriptFolder)
{
	#Tasks - Generate the Wiki Templates - Should be Triggered every time when changes under folder \.psscriptsonline\CWQL
		#Task: Generate Dynamic Pages  - Project Level
         
        $ExcutePSFile = "Test-DynamicTask-2-ContentParsing";
        . ((Split-Path $script:MyInvocation.InvocationName) + $ScriptFolder + $ExcutePSFile);
	
}