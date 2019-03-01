##################################################################################

<# 
    Code Created for: 
            Northern California PowerShell and Azure User Group
            Site: NorCalPowerShellAzure.org (Coming Soon)
            MeetupGrp: https://www.meetup.com/NorCal-PowerShell-Azure-User-Group/
    
  Script Updated on: 2/27/2019                                                 
      Created By: Thomas Peffers | Contact: Tom@HyperSystemsTech.com           
#>

##################################################################################



#region How to find Azure Modules

#Old modules: AzureRM.*
#Note Find-Module command requires powershell version 5.1

Find-Module AzureRM* | Where-Object { $_.Author -like "Microsoft Corp*"}


#Or

Find-Module AzureRM



#What about the new modules? 

Find-Module az | Where-Object { $_.Author -like "Microsoft Corp*"} | FL



#How to install? 

Find-Module AzureRM | Install-module -WhatIf

Find-Module az | Where-Object { $_.Author -like "Microsoft Corp*"} | Install-Module -WhatIf

#endregion



#region Connecting into Azure

#Interactive Sign in
Connect-AzureRmAccount


#Sign in with Creds
$creds = Get-Credential 
Connect-AzureRmAccount -Credential $creds


#What if your using Azure Gov or in a different county? 
Connect-AzureRmAccount -Environment AzureChinaCloud

#What if you have multiple subscriptions?

$Sub = Get-AzureRmSubscription | Out-GridView -Title "Select a Subscription" -PassThru 
Select-AzureRmSubscription -Subscription $Sub

#endregion

#region Finding Stuff

Get-AzureRmResourceGroup


#endregion


#region Lets Create a VM!
$ResourceGroupLocation = 'WestUS2'
$ResourceGroupName = 'NorCalPwshAz-rg'
$TemplateFile = 'C:\Users\Tom\Documents\GitHub\NorCalPowerShellAzure-UserGroup\FebruaryMeet-2019\DemoJsonDeployment\azuredeploy.json'


#region runDeployment
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force

if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                                                                  -TemplateFile $TemplateFile `
                                                                                  -TemplateParameterObject $ParameterHashTable)
    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else {
    New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                       -ResourceGroupName $ResourceGroupName `
                                       -TemplateFile $TemplateFile `
                                       -Verbose `
                                       -ErrorVariable ErrorMessages
    if ($ErrorMessages) {
        Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    }
}
#endregion

#endregion




#Done!

#region Lets Create a VM!
$Location = 'WestUS2'

Get-AzureRmVMImagePublisher -Location $Location 

Get-AzureRmVMImagePublisher -Location $Location | Select-Object PublisherName | Where-Object {$_.PublisherName -like 'Microsoft*'}

$publisher = 'MicrosoftWindowsServer'

Get-AzureRmVMImageOffer -Location $Location -PublisherName $publisher

$offer = 'WindowsServer'

Get-AzureRmVMImageSku -Location $Location -PublisherName $publisher -Offer $offer

$sku = '2019-Datacenter'

Get-AzureRmVMImage -Location $Location -PublisherName $publisher -Offer $offer -Skus $sku

Get-AzureRmVMSize -Location $Location 

$vmSize = 'Standard_DS2_v2'



$resourceGroup = 'NorCalPwshAzureGroup-Rg'
$storageAccount = 'norcalpwshaz916'
New-AzureRmResourceGroup -Name $resourceGroup -Location $Location -Verbose -WhatIf


Get-command -Module AzureRM Test-*

#endregion
