#region Basic Invoke-Command example

#region Script Context
    <#
        The purpose of this script is to demonstrate how to use Invoke-Command to issue commands to 
        a remote target or targets without having to first create a remote connection.


    #>

#endregion


#region LoadVariables
$Target = "10.69.69.45"
$TargetAdminCreds = Get-Credential administrator

$Targets = "10.69.69.45", "10.69.69.15"


#endregion


#Lets issue a simple command to our remote target to discover various services running on the target
$SimpleICMResults = Invoke-Command -ComputerName $Target -Credential $TargetAdminCreds -ScriptBlock { Get-Service }

#Now lets see the results:
$SimpleICMResults


#Lets see if Invoke-command can handle variables and such in the requests
Invoke-Command -ComputerName $Target -Credential $TargetAdminCreds -ScriptBlock { $SimpleICMResults_InternalVar = Get-Service }


#Now Lets check the results
$SimpleICMResults_InternalVar

#Ouch, well what happened there? Why didn't that work? Lets try that again with a slight change:
Invoke-Command -ComputerName $Target -Credential $TargetAdminCreds -ScriptBlock { $SimpleICMResults_InternalVar = Get-Service; $SimpleICMResults_InternalVar }

#This is because the script block thats executed on the target is executed in the context of the VM. So any variable stays in the context of the target in which it is executed. 

#Is the context persistent? Lets see by calling the variable in the scripblock context on the same remote machine and see if we get the variable results. 
Invoke-Command -ComputerName $Target -Credential $TargetAdminCreds -ScriptBlock { $SimpleICMResults_InternalVar }


#Shoot, no dice. So what does this tell us? Well this tells us that each command or block of commands we issue to the remote machine is like opening a new powershell window/instance. No carry over or persistance.


#Can we target more than one computer at a time? If so what do the results look like? Lets try it out!
Invoke-Command -ComputerName $Targets -Credential $TargetAdminCreds -ScriptBlock { $SimpleICMResults_InternalVar = Get-Service; $SimpleICMResults_InternalVar }

#Yep, it works! This is awesome because you can issue commands to multiple machines without having to create a PS Session for each one and bounce between them.


#endregion

#region Intermediate Invoke-Command Example
#What if you want to write more complex scripts and pass varibles through to execute and want it to look clean?

#Intermediate Example 1
$ScriptBlock =
{

   $ServiceName = "WSearch"
   
   Get-Service -Name $ServiceName

}

 
Invoke-Command -ComputerName $Target -Credential $TargetAdminCreds -ScriptBlock $ScriptBlock
#The above method works fine since we are defining the variables within the script block.



#Lets try an example that passes a variable into the script block from outside. 

$External_ServiceName = "WSearch"

$ScriptBlock =
{

   
   
   Get-Service -Name $External_ServiceName

}

 
Invoke-Command -ComputerName $Target -Credential $TargetAdminCreds -ScriptBlock $ScriptBlock -ArgumentList $External_ServiceName

#As you can see since this returned a whole list of services the variable 'External_ServiceName' wasn't passed through to the script block and thus
#the command was ran without the desired filter applied. Now lets see how to properly pass an external variable into a script block using the 'argument list' property. 

#Intermediate Example 2
$External_ServiceName = "WSearch"

$ScriptBlock =
{
    #Args[0] stands for the first argument passed to 'argumentlist'. This language tells us that AugumentList treats objects passed into it as an array. 
    $Arg_In_ScriptBlock_ServiceName = $args[0] 
  
    Get-Service -Name $Arg_In_ScriptBlock_ServiceName

}

Invoke-Command -ComputerName $Target -Credential $TargetAdminCreds -ScriptBlock $ScriptBlock -ArgumentList $External_ServiceName
 


#Here's where it can get fun when we apply this method to multiple targets

#Intermediate Example 3
$External_ServiceName = "WSearch"

$ScriptBlock =
{
    
    $Arg_In_ScriptBlock_ServiceName = $args[0] 
  
    Get-Service -Name $Arg_In_ScriptBlock_ServiceName

}

Invoke-Command -ComputerName $Targets -Credential $TargetAdminCreds -ScriptBlock $ScriptBlock -ArgumentList $External_ServiceName


#Why not toss in some splatting!?!
$External_ServiceName = "WSearch"

$ScriptBlock =
{
    
    $Arg_In_ScriptBlock_ServiceName = $args[0] 
  
    Get-Service -Name $Arg_In_ScriptBlock_ServiceName

}

$ICMSplat = @{
    ComputerName = $Targets;
    Credential = $TargetAdminCreds;
    ScriptBlock = $ScriptBlock;
    ArgumentList = $External_ServiceName;
}
Invoke-Command @ICMSplat


#endregion