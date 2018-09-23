##################################################################################

<# 
    Code Created for: 
            Northern California PowerShell and Azure User Group
            Site: NorCalPowerShellAzure.org (Coming Soon)
            MeetupGrp: https://www.meetup.com/NorCal-PowerShell-Azure-User-Group/
    
  Script Updated on: 9/23/2018                                                 
      Created By: Thomas Peffers | Contact: Tom@HyperSystemsTech.com           
#>

##################################################################################


#region Splatting_01

<#
What is splatting? 

Splatting is short hand for 'variable splatting', which is in short a method of passing argument variables to commands. 

Thats cool, but why use it and what are the benefits? 

Splatting allows for a more compact way of passing arguments to commands. You can use splatting to assign almost all arguments and their associated 'data'/ 'variables' as a
single variable that you can then pass to your designed command.

-Benefits: 
    By using splatting you can make your code much cleaner, clearer, and easier to troubleshoot. 
    
    
Now lets get onto some examples..... 


#>


#region Splatting_01-Example1

# Here is the base command that we are going to use to build our example off of

Get-ChildItem 

# This shows us what properties we can call / use for this command

Get-ChildItem | Get-Member

# Here is an example command
Get-ChildItem -Path C:\users\tom\Desktop -Filter "*.jpg" -Force -Recurse -Verbose 


# Here is a representation of the above command using variable splatting

$Splat = @{
    Path = "C:\users\tom\Desktop";
    Filter = "*.jpg";
    Force = $true;
    Recurse = $true;
    Verbose = $true;
}

Get-ChildItem @Splat

# As you can see this can greatly reduce the size/length of arguments and their variables that you pass/ use in your scripts. 
# All variables are clearly outlined and then called using 1 clean 'variable'





#endregion



#endregion