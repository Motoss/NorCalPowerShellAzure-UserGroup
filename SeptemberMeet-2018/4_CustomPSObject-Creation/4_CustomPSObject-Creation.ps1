#region Script Context/Intro  
<#
    Custom PSObject Creation. PS Objects are great for binging data and behaviors to objects. 

    To get an idea of what MemberTypes you can use pipe any item to Get-Member. When creating or modifying
    PS Objects you can define synthetic members and associate data with them. In this example we are going to 
    focus on the membertype 'NoteProperty', but there are other membertypes that you can work with.  

#>
#endregion


#region Basic - Discovery

#Here is how you can do a basic discovery on custom PS Objects. Take note of the MemberTypes and their correlating definitions. 
Get-ChildItem | Get-Member

#endregion

#region Basic - Example

#For this example lets work on creating a simple script to discover folder ACL information.

#First lets create and define our custom PSObject.
$FileInfoOBJ = New-Object PSObject

#Lets check out our object that we just created
$FileInfoOBJ 

#As we can see the above variable call doesn't display anything because it is empty. Now lets pipe it to get-member and check out the results
$FileInfoOBJ | Get-Member

#We can see that this doesn't return much other than the 'structure' of a PSCustomObject and some default Methods. 

#Now that we have created our custom PSObject lets move onto defining additional properties to extend the use. 
$FileInfoOBJ | Add-Member NoteProperty FullName ""
$FileInfoOBJ | Add-Member NoteProperty FileSystemRights ""
$FileInfoOBJ | Add-Member NoteProperty AccessControlType  ""
$FileInfoOBJ | Add-Member NoteProperty IdentityReference  ""
$FileInfoOBJ | Add-Member NoteProperty IsInherited  ""
$FileInfoOBJ | Add-Member NoteProperty InheritanceFlags ""
$FileInfoOBJ | Add-Member NoteProperty PropagationFlags ""

#Now lets check the variable and pipe it to get member
$FileInfoOBJ

#Ok so the variable call returns some structure, but no real data. (That would be different if we assigned data upon creation of the other member properties in the PSObject.


$FileInfoOBJ | Get-Member
#Now we can see the new 'NoteProperties' returned and their definitions. 


#Ok, time to start putting this Custom PS Object to work

    $ScanTarget = Read-Host "Please enter Scanning target. Ex: C:\  "
    $OutputLocation = Read-Host "Please enter desired folder for Report to be saved. Ex: C:  "
    $DirectoryListingFULL = Dir -Path $ScanTarget -Recurse -Force -Attributes Directory -ErrorAction SilentlyContinue
    $d = Get-Date
    $date = "$($d.Month)-$($d.Day)-$($d.Year)"
        Foreach ($item in $DirectoryListingFULL)
        {
            
            
            $DataACLInventory = Get-Acl -Path $item.FullName


            $FileInfoOBJ.FullName = $item.FullName


            Foreach ($detail in $DataACLInventory.Access) 
            {
                
                $FileInfoOBJ.FileSystemRights = $detail.FileSystemRights
                $FileInfoOBJ.AccessControlType = $detail.AccessControlType
                $FileInfoOBJ.IdentityReference = $detail.IdentityReference
                $FileInfoOBJ.IsInherited = $detail.IsInherited
                $FileInfoOBJ.InheritanceFlags = $detail.InheritanceFlags
                $FileInfoOBJ.PropagationFlags = $detail.PropagationFlags

                $FileInfoOBJ | Export-Csv "$($OutputLocation)\DirectoryACL-Report-$($date).csv" -Append

            }
            

        }
#Lets take a look at the results:

$ExcelFilePath = "$($OutputLocation)\DirectoryACL-Report-$($date).csv"
$objExcel = New-Object -ComObject Excel.Application
$objExcel.Visible = $true
$OpenExcelFile = $objExcel.Workbooks.Open($ExcelFilePath)



#As you can see using a custom PSObject allows us to easily create custom reports or objects to assign data to. In this case though the data assigning was pretty straight forward
#But the beatuy of custom psobjects are that they easily enable more complex assignments. 

#endregion

#region Intermediate - Example 


#region Intermediate context
    <#
        Lets take a more typical administrative task and apply what we have learned thus far about custom psobjects to make it easier. 

        Task: New Active Directory user account creation. 

        Challenage: Use a custom PS Object to assist in the automation of creating an AD account with minimal manual input.

    #>

#endregion


    #Lets define our custom PS Object
    $UserAccount = New-Object PSObject
    $UserAccount | Add-Member NoteProperty FirstName ""
    $UserAccount | Add-Member NoteProperty LastName ""
    $UserAccount | Add-Member NoteProperty DisplayName ""
    $UserAccount | Add-Member NoteProperty EmailAddress ""
    $UserAccount | Add-Member NoteProperty UserPrincipalName ""
    $UserAccount | Add-Member NoteProperty Title ""
    $UserAccount | Add-Member NoteProperty Department ""
    $UserAccount | Add-Member NoteProperty Location ""
    $UserAccount | Add-Member NoteProperty Country ""
    $UserAccount | Add-Member NoteProperty Company ""
    $UserAccount | Add-Member NoteProperty UserName ""
    $UserAccount | Add-Member NoteProperty Password ""


    $FileLocation = 'C:\Users\Tom\Dropbox\Sookasa\Hyper-Systems\Pwsh & Azure User Grp\CustomPSObject_Creation\NewUserData-ExampleInput.csv'
    $datasheet = Import-Csv -Path $FileLocation
    
    Foreach($item in $datasheet)
    {

        $UserAccount.FirstName = $item.FirstName
        $UserAccount.LastName = $item.LastName 
        $UserAccount.DisplayName = "$($UserAccount.FirstName) $($UserAccount.LastName)"
        $UserAccount.Title = $item.Title
        $UserAccount.Company = $item.Company
        $UserAccount.EmailAddress = "$($UserAccount.FirstName.Substring(0,1))$($UserAccount.LastName)@HyperSystemsTech.com"
        $UserAccount.UserPrincipalName = "$($UserAccount.FirstName.Substring(0,1))$($UserAccount.LastName)@HyperSystemsTech.com"
        $UserAccount.Country = $item.Country
        $UserAccount.Location = $item.Location
        $UserAccount.Department = $item.Department

        $PasswordBase = "P@sswordB@se-" 
        $PasswordEnd = "$($UserAccount.FirstName.Substring(0,1))$($UserAccount.LastName.Substring(0,1))-$($Year)"
        $UserAccount.Password = "$($PasswordBase)$($PasswordEnd.ToUpper())" 
        $secure = ConvertTo-SecureString -AsPlainText "$($UserAccount.Password)" -Force
            
        $Num = $UserAccount.LastName.Length

           

        If($Num -lt 20)
        {
            $UserAccount.UserName = "$($UserAccount.FirstName.Substring(0,1))$($UserAccount.LastName.Substring(0,$Num))"
            
        } 

        If($Num -gt 20)
        {
                
            $UserAccount.UserName = "$($UserAccount.FirstName.Substring(0,1))$($UserAccount.LastName.Substring(0,19))"
            
        } 
        
        #Now lets pull in a trick we covered earlier to make this cleaner and easier to pass the needed variables
        $NewUserSplat = @{

            Name = "$($UserAccount.DisplayName)";
            SamAccountName = "$($UserAccount.UserName)";
            AccountPassword = $secure;
            Company = "$($UserAccount.Company)";
            Country = "$($UserAccount.Country)";
            Description = "$($UserAccount.Title)";
            Title = "$($UserAccount.Title)";
            Department = "$($UserAccount.Department)";
            GivenName = "$($UserAccount.FirstName)";
            SurName = "$($UserAccount.LastName)";
            UserPrincipalName = "$($UserAccount.UserPrincipalName)";
            EmailAddress = "$($UserAccount.EmailAddress)";
            Office = "$($UserAccount.Location)";
            DisplayName = "$($UserAccount.DisplayName)";
        
            Enabled = $true;
            Credential = $cred;
        
    
        }       
           
        #This command is for illustractive purposes and not intended to be used in this demo as I'm not connected with an AD Domain. 
        New-ADUser @NewUserSplat


        #Now lets see what we have been able to do with our custom PS object. 
        $UserAccount

    }

#endregion