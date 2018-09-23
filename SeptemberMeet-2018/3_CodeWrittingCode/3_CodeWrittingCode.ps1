#region Basic CodeWrittingCode example

#region Script Context
    <#
        The purpose of this script is to demonstrate how to use 'here-string' literals to help generate code
        for something that doesn't use or interface easily/directly with powershell. 

        What follows in this example is how I used a 'here-string' literal nested in a loop to 
        generate foritnet firewall commands to assist in 'white listing' o365 IPs for various services. 
        Additionally I have used this same type of method to generate much more complex code for programming 
        network infrastructure.


    #>

#endregion


#Show this region and explain variables
#region LoadVariables

#Base directory for working with script input resources and script output location
$FileBaseLoc = 'C:\Users\Tom\Dropbox\Sookasa\Hyper-Systems\Pwsh & Azure User Grp\CodeWrittingCode'

#Arbitrary variable that is not essential to the script overall. Mostly here to show how variables can be added/used to generate desired results. 
$RuleBaseGrp = '7'

#Arbitrary variable that is not essential to the script overall. Mostly here to show how variables can be added/used to generate desired results. 
$x=1

#Used to pull in file containing the loop centric data. In this context this data reflects the IPs to whitelist for Microsoft Office 365 services on the firewall.
$list = Get-Content "$FileBaseLoc\ExchangeOnline 7.txt"

#endregion


#region DemoCleanup

$CleanupTest = Test-Path "$($FileBaseLoc)\output\$($RuleNameBase).txt"

If($CleanupTest -eq $true)
{
    Remove-Item "$($FileBaseLoc)\output\$($RuleNameBase).txt" -Force
}

#endregion


#Show contents of file
start notepad -ArgumentList "$FileBaseLoc\ExchangeOnline 7.txt"

#region Do Work (Run foreach loop)
Foreach($line in $list)
{

    
    $RuleNameBase = "o365 Exchange Online"
    $CurrentRuleName = $RuleNameBase + "$($RuleBaseGrp)-$($x)"

    $Template = @"
edit "$($CurrentRuleName)"
set associated-interface "port2" 
set subnet $($line)
next

"@

$X++

$Template | Out-File "$($FileBaseLoc)\output\$($RuleNameBase).txt" -Append
}

#endregion

#Display results
start notepad -ArgumentList "$($FileBaseLoc)\output\$($RuleNameBase).txt"



#endregion




#region More Advanced Example of Code Writting Code



#region LoadVariables
$FileBaseLoc = 'C:\Users\Tom\Dropbox\Sookasa\Hyper-Systems\Pwsh & Azure User Grp\CodeWrittingCode\Advanced'

$OutPutTemplate = Get-Content "$($FileBaseLoc)\Brocade ICX 7xxx - Tom - AE1.txt"
$DataSet = Import-Csv "$($FileBaseLoc)\Dataset-AE1.csv"

#endregion

#Show contents of input files:

#Show Template Contents
start notepad -ArgumentList "$FileBaseLoc\Brocade ICX 7xxx - Tom - AE1.txt"


#Show DataSet
#region ComObject Calling to allow excel to open file
$ExcelFilePath = "$($FileBaseLoc)\Dataset-AE1.csv"

$objExcel = New-Object -ComObject Excel.Application
$objExcel.Visible = $true

#endregion
$OpenExcelFile = $objExcel.Workbooks.Open($ExcelFilePath)


#region GenerateCode with Pwsh

Foreach ($PSObj in $DataSet) 
{

   


    $FullName = "$($PSObj.RootSiteName)-$($PSObj.Location)"

   
    $OUTPUT = $OutPutTemplate | ForEach-Object { 
        $_ -replace "<v>" , "$($PSObj.v)" `
                 -replace "<w>" , "$($PSObj.w)" `
                 -replace "<x>" , "$($PSObj.x)" `
                 -replace "<y>", "$($PSObj.y)" `
                 -replace "<z>", "$($PSObj.z)" `
                 -replace "<RootSiteName>", "$($PSObj.RootSiteName)" `
                 -replace "<location>", "$($PSObj.location)" `
                 -replace "<NumInStack>", "$($PSObj.NumInStack)" `
                 -replace "<StackSecondary>", "$($PSObj.StackSecondary)" `
                 -replace "<DefaultUserVlan>", "$($PSObj.DefaultUserVlan)"
     } 

    $OUTPUT | Out-File -FilePath "$($FileBaseLoc)\Output\$($FullName).txt" -Force
  

}

#endregion


#Display results
start explorer "$FileBaseLoc\output"

#endregion