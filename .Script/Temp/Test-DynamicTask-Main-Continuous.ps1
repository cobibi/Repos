#Run the script code
Function RunDynamicPSTasks($ScriptFolder)
{
         
        $ExcutePSFile = "Test-DynamicTask-2-ContentParsing";
        . ((Split-Path $script:MyInvocation.InvocationName) + $ScriptFolder + $ExcutePSFile);
	
}