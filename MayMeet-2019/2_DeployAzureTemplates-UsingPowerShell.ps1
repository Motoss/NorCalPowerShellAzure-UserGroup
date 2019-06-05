##################################################################################

<# 
    Code Created for: 
            Northern California PowerShell and Azure User Group
            Site: NorCalPowerShellAzure.org (Coming Soon)
            MeetupGrp: https://www.meetup.com/NorCal-PowerShell-Azure-User-Group/
    
  Script Updated on: 5/18/2019                                                 
      Created By: Thomas Peffers | Contact: Tom@HyperSystemsTech.com           
#>

##################################################################################


#region WorkFlows_01

<#
Why use PowerShell to deploy Azure templates you ask? The answer is, for fun! No but really there can be some great benefits as it allows the template to be the 'truth'
while PowerShell can be the changing input. 
    
    
Now lets get onto some examples..... 


#>



#region LoginSub
Add-AzureRmAccount

#Select subscription for the deployment
Write-Host "Select the desired subscription for the deployment" -ForegroundColor Yellow
$Sub = (Get-AzureRmSubscription | Out-GridView -Title "Please select your desired subscription" -PassThru )

Select-AzureRmSubscription -SubscriptionId $Sub.SubscriptionId
Write-Host "Subscription selected..." -ForegroundColor Yellow
#endregion

#region PowerShell-Template-Injection_01

# Here is a basic networking template example

$scriptfolder = "C:\Users\Tom\Pwsh & Azure User Grp\May-2019"
$TemplateFile = $scriptfolder + "\2_DeployAzureTemplates-UsingPowerShell.json"
$TestPath = Test-Path -Path $scriptfolder

#region RunRG
If($TestPath -eq $True)
{

    $ResourceGroupName = "2_DeployAzureTemplates-PWSH-rg"
    $ResourceGroupLocation = "WESTUS2"

        $ParameterHashTable = [ordered]@{ 

                                 "MainVNet_Name" = "prod-vnet"; #Main vNet Name. 
                                 "MainVNetPrefix" = "10.1.0.0/21"; #Main vNet Prefix in Cidr notation. 

                                 "MainVNetSubnet1Name" = "subnet-web"; #This is the name of your web tier subnet
                                 "MainVNetSubnet1Prefix" = "10.1.1.0/24"; #This is the CIDR prefix for your web tier subnet

                                 "MainVNetSubnet2Name" = "subnet-apps"; #This is the name of your apps subnet
                                 "MainVNetSubnet2Prefix" = "10.1.2.0/24"; #This is the CIDR prefix for your apps subnet

                                 "MainVNetSubnet3Name" = "subnet-data"; #This is the name of your data tier subnet
                                 "MainVNetSubnet3Prefix" = "10.1.3.0/24"; #This is the CIDR prefix for your data tier subnet

                                 "MainVNetSubnet4Name" = "subnet-ad"; #This is the name of your AD subnet
                                 "MainVNetSubnet4Prefix" = "10.1.4.0/27"; #This is the CIDR prefix for your AD subnet

                                 "MainVNetSubnet5Name" = "subnet-mgmt"; #This is the name of your management subnet
                                 "MainVNetSubnet5Prefix" = "10.1.4.32/27"; #This is the CIDR prefix for your management subnet

                                 "MainVNetSubnet6Prefix" = "10.1.0.0/27"; #This is the CIDR prefix for your gateway subnet 



        }




#region deploymentScript

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
                                           -TemplateParameterObject $ParameterHashTable `
                                           -Force -Verbose `
                                           -ErrorVariable ErrorMessages
        if ($ErrorMessages) {
            Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
        }
    }


}
Else
{
    Write-Host "Script & CSV not in expected location ($($scriptfolder)...). Extract files to this directory and run the script again." -ForegroundColor Red -ErrorAction SilentlyContinue
    Read-Host -Prompt "Press Enter to Exit"
}


Read-Host -Prompt "Press Enter to Exit"

#endregion

#endregion





#endregion


#region Workflows_02

# Now lets look at combining workflows and azure powershell template deployments

$Path = '.\AzureRMProfile.json'
Save-AzureRmContext -Path $Path -Force


$ResourceGroupName = "2-1_WorkflowDeploy_1-0-rg"
$ResourceGroupLoc = "WESTUS2"

Workflow AzureDeployTemplate_01
{
    
    param(
    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupName,
 
    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupLoc,

    [Parameter(Mandatory=$true)]
    [psobject] $ParameterHashTable,

    [Parameter(Mandatory=$true)]
    [String] $TemplateFile,

    [Parameter(Mandatory=$true)]
    [psobject] $AzureRMContext
     
    )

    $Profile = Import-AzureRmContext -Path $AzureRMContext

    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLoc -Verbose -Force

    
        New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                           -ResourceGroupName $ResourceGroupName `
                                           -TemplateFile $TemplateFile `
                                           -TemplateParameterObject $ParameterHashTable `
                                           -Force -Verbose `
                                           -ErrorVariable ErrorMessages
    

}

# Note, using splatting works here because we are not inside a powershell workflow. Splatting does not work inside a powershell workflow.

$Workflow01Params = @{
    ResourceGroupName = $ResourceGroupName;
    ResourceGroupLoc = $ResourceGroupLoc;
    ParameterHashTable = $ParameterHashTable;
    TemplateFile = $TemplateFile;
    AzureRMContext = $Path;
}


AzureDeployTemplate_01 @Workflow01Params

#endregion

#region Workflows_03-parallel




Workflow Invoke-AzureDeployParallel-01
{
    
        #region params
        $ResourceGroupName = "Workflow-deploy-rg"
        $ResourceGroupLoc = "WESTUS2"
        $ParameterHashTable1 = [ordered]@{ 

                                 "MainVNet_Name" = "prod-vnet1"; #Main vNet Name. 
                                 "MainVNetPrefix" = "10.1.0.0/21"; #Main vNet Prefix in Cidr notation. 

                                 "MainVNetSubnet1Name" = "subnet-web"; #This is the name of your web tier subnet
                                 "MainVNetSubnet1Prefix" = "10.1.1.0/24"; #This is the CIDR prefix for your web tier subnet

                                 "MainVNetSubnet2Name" = "subnet-apps"; #This is the name of your apps subnet
                                 "MainVNetSubnet2Prefix" = "10.1.2.0/24"; #This is the CIDR prefix for your apps subnet

                                 "MainVNetSubnet3Name" = "subnet-data"; #This is the name of your data tier subnet
                                 "MainVNetSubnet3Prefix" = "10.1.3.0/24"; #This is the CIDR prefix for your data tier subnet

                                 "MainVNetSubnet4Name" = "subnet-ad"; #This is the name of your AD subnet
                                 "MainVNetSubnet4Prefix" = "10.1.4.0/27"; #This is the CIDR prefix for your AD subnet

                                 "MainVNetSubnet5Name" = "subnet-mgmt"; #This is the name of your management subnet
                                 "MainVNetSubnet5Prefix" = "10.1.4.32/27"; #This is the CIDR prefix for your management subnet

                                 "MainVNetSubnet6Prefix" = "10.1.0.0/27"; #This is the CIDR prefix for your gateway subnet 



        }
        $ParameterHashTable2 = [ordered]@{ 

                                 "MainVNet_Name" = "prod-vnet2"; #Main vNet Name. 
                                 "MainVNetPrefix" = "10.1.0.0/21"; #Main vNet Prefix in Cidr notation. 

                                 "MainVNetSubnet1Name" = "subnet-web"; #This is the name of your web tier subnet
                                 "MainVNetSubnet1Prefix" = "10.1.1.0/24"; #This is the CIDR prefix for your web tier subnet

                                 "MainVNetSubnet2Name" = "subnet-apps"; #This is the name of your apps subnet
                                 "MainVNetSubnet2Prefix" = "10.1.2.0/24"; #This is the CIDR prefix for your apps subnet

                                 "MainVNetSubnet3Name" = "subnet-data"; #This is the name of your data tier subnet
                                 "MainVNetSubnet3Prefix" = "10.1.3.0/24"; #This is the CIDR prefix for your data tier subnet

                                 "MainVNetSubnet4Name" = "subnet-ad"; #This is the name of your AD subnet
                                 "MainVNetSubnet4Prefix" = "10.1.4.0/27"; #This is the CIDR prefix for your AD subnet

                                 "MainVNetSubnet5Name" = "subnet-mgmt"; #This is the name of your management subnet
                                 "MainVNetSubnet5Prefix" = "10.1.4.32/27"; #This is the CIDR prefix for your management subnet

                                 "MainVNetSubnet6Prefix" = "10.1.0.0/27"; #This is the CIDR prefix for your gateway subnet 



        }
        $Path = 'C:\users\tom\AzureRMProfile.json'
        $scriptfolder = "C:\Users\Tom\Pwsh & Azure User Grp\May-2019"
        $TemplateFile = $scriptfolder + "\2_DeployAzureTemplates-UsingPowerShell.json"

    #endregion

    
    #region workflow1
    Workflow AzureDeployTemplate_01
    {
    
        param(
        [Parameter(Mandatory=$true)]
        [String] $ResourceGroupName,
 
        [Parameter(Mandatory=$true)]
        [String] $ResourceGroupLoc,

        [Parameter(Mandatory=$true)]
        [psobject] $ParameterHashTable,

        [Parameter(Mandatory=$true)]
        [String] $TemplateFile,

        [Parameter(Mandatory=$true)]
        [psobject] $AzureRMContext
     
        )

        $Profile = Import-AzureRmContext -Path $AzureRMContext

        New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLoc -Verbose -Force

    
            New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                               -ResourceGroupName $ResourceGroupName `
                                               -TemplateFile $TemplateFile `
                                               -TemplateParameterObject $ParameterHashTable `
                                               -Force -Verbose `
                                               -ErrorVariable ErrorMessages
    

    }

    #endregion


    #region workflow2
    Workflow AzureDeployTemplate_02
    {
    
    param(
    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupName,
 
    [Parameter(Mandatory=$true)]
    [String] $ResourceGroupLoc,

    [Parameter(Mandatory=$true)]
    [psobject] $ParameterHashTable,

    [Parameter(Mandatory=$true)]
    [String] $TemplateFile,

    [Parameter(Mandatory=$true)]
    [psobject] $AzureRMContext
     
    )

    $Profile = Import-AzureRmContext -Path $AzureRMContext

    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLoc -Verbose -Force

    
        New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                           -ResourceGroupName $ResourceGroupName `
                                           -TemplateFile $TemplateFile `
                                           -TemplateParameterObject $ParameterHashTable `
                                           -Force -Verbose `
                                           -ErrorVariable ErrorMessages
    

    }
    #endregion



    
    
    Parallel 
    {
        AzureDeployTemplate_01 -ResourceGroupName $ResourceGroupName -ResourceGroupLoc $ResourceGroupLoc -ParameterHashTable $ParameterHashTable1 -TemplateFile $TemplateFile -AzureRMContext $Path
        AzureDeployTemplate_02 -ResourceGroupName "$($ResourceGroupName)-2" -ResourceGroupLoc $ResourceGroupLoc -ParameterHashTable $ParameterHashTable2 -TemplateFile $TemplateFile -AzureRMContext $Path

    }
}

Invoke-AzureDeployParallel-01
#endregion
