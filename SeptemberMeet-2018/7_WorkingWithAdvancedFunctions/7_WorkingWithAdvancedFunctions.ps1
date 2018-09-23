#region Basic Function (Parameter and cmdlet binding) example

#region Script Context
    <#
        The purpose of this script is to demonstrate how to create a basic function and add on parameters and vmdlet binding. 


    #>

#endregion

#Here is a basic function declaration 
Function Run-BasicFunction
{

    Write-Host "Hello World"

}

Run-BasicFunction

#Notice that no parameters are allowed nor are other basic universal parameters like -verbose or debuging assistance this is 
# because to gain access to these you need to declare cmdlet binding. 

Function Run-BasicFunction2
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$true)]
        [string] $Message
    
    )

    Write-Host $Message

}

Run-BasicFunction2 -Message "Hello World Through this function!"

#In the Run-BasicFunction2 you will notice that we now have access to other universal parameters in addition to now being able to 
#Declaire if a parameter is mandatory, default parameter options/data, and via the cmdletbinding we can use the various optional properties to
#further tweak our custom Function. 



#Lets see how to delare a default value if none is defined. 

Function Run-BasicFunction3
{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=$false)]
        [string] $Message = "Hello World Through this function as a Default param!"
    
    )

    Write-Host $Message

}

Run-BasicFunction3

#Now lets try passing it something directly to see what happens. 

Run-BasicFunction3 -Message "Muahahaha, default override!"



#endregion


#region Intermedate Funtions

start notepad

Function Run-IntFunction1
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        [Parameter(Position=0,Mandatory=$false)]
        $TargetApp = 'NotePad'
    
    )

    Get-Process | Where-Object {$_.Name -match $TargetApp} | Stop-Process

}

Run-IntFunction1 

#Ok we can see that the above function will just close notepad without asking for confirmation. 

#Now lets see if what happens if we use the parameter -whatif

start notepad

Run-IntFunction1 -WhatIf

#As you can see if properly processes -whatif and the application is still up. Now lets see what happens if we use -confirm

Run-IntFunction1 -Confirm:$true

#It prompts for confirmation just as expected and only terminates the application 'notepad' if we hit yes or yes to all.


#There are more CmdletBinding properties that can be used/declared, but for the sake of keeping this topic from becoming a deep dive into 
#Advanced funtions I have only included the example above, however, for those curious I have included a list of the other properties below. 
<#
    Other properties available within 'CdmletBinding':
        -ConfirmImpact
        -DefaultParameterSetName
        -HelpURI
        -SupportPaging
        -PositionalBinding
#>
#endregion