#region Working with Json Object type

#region Script Context
    <#
        The purpose of this script is for showing what working with Json object types in powershell looks like.
    #>

#endregion

$TomACLJson = Get-Acl C:\users\Tom | ConvertTo-Json 


$TomACLJson | Out-File C:\Users\Tom\Desktop\TOmTest.json

#Notice once converted there is no easy way to parse/pull info out of the json object format. Lets try reversing the json object to extract data

$Reverse_TomACLJSON = $TomACLJson | ConvertFrom-Json

$Reverse_TomACLJSON.Access
<#
    Volia, we can pull info and work with object data / various propeties again. So where does this come in handy? Well storing data as json
    can make the data easier to read with human eyes and can be used by other applications/systems. Also since it is so easy to convert back and forth
    there isn't a reason to avoid storing data as json if you prefer its format. Where JSON conversion comes into play is when working with Rest API calls.
#>

#RestAPI call example

$Url = "https://raw.githubusercontent.com/Motoss/NorCalPowerShellAzure-UserGroup/master/SeptemberMeet-2018/6_WorkingWithJsonDataTypes/JSONExampleData"
$Result = Invoke-WebRequest -Uri $Url

$Conversion = $Result | ConvertFrom-Json

#endregion