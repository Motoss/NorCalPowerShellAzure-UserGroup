#region Basics on getting info on Errors in PowerShell

#region Script Context
    <#
        The purpose of this script is a basic intro to error handling in powershell. 

        PowerShell by default is a nonterminating error language while most others are terminating. Ex: .Net C# etc..

        What does this mean? 
            Well in short, it means that when an error occurs the system will continue processing/running and just pass the error to 
            the error stream log. 

        If errors are nonterminating and are streamed into a log. Then how do I get more detailed info on the error? 
            Good question, PowerShell stores the errors as rich objects that contain a wealth of information. 
            To truely answer the question we need to jump into some examples. 
    #>

#endregion

#First lets clear the error log
$Error.Clear()

#Now lets create an error and pull the error log to display the results.

Get-ChildItem -Path C:\PathDoesNotExist

#The Error log is literally just $Error. 
$Error

#Ok, that gave us some basic info, but can we get more from it? Lets do some discovery...

$Error | Get-Member

#Ok so we see some Methods and Properties. Lets see what one of them is. 

$Error.InvocationInfo
#So that gave us a bit more info, but nothing we didn't already know. 
$Error | Get-Member

$Error.CategoryInfo
#Nice! So this one helps us classify the issue. 

$Error | Get-Member

$Error.FullyQualifiedErrorID
$Error.ScriptStackTrace #Nice! A trace of the issue. This could be super helpful!
$Error.TargetObject #Meh, on the scale of info in this context, but in a more complex script this could be useful.
$Error.ErrorDetails #Bummer Nothing here.

#Lets see if there is anything that is hidden from us
$Error | Get-Member -Force    

#Using -Force when calling properties or get-member allows you to pull up 'hidden' items. Lets see if any of them help. 
$Error.psobject #Nice this gave us some additional info plus a summary. 




#What happens when we have multiple errors in the error stream, how do we sort/deal with that? 
$Error.Clear()

$x=1
While($x -lt 10)
{
    Get-ChildItem -Path "C:\PathDoesNotExist$($x)" 

    $x++
}

   
$Error 
#Ok so that returns a bunch of errors, but how do we sort through that.

$Error.Count
#Ah, ok so it holds a count of the errors in what appears to be an array. Lets try using array munipulation to pull more data


$Error[0]
<#
    Notice we had a count of 9 errors earlier. This is do to the while loop above. Before the loop we clear the error variable 
    so we know it is all from that loop. In the error it states 'C:\PathDoesNotExist9' does not exist, which is interesting since
    that would have been the last error, yet the array sees it as the first. This because it is an 'Error Stream' meaning all errors
    are pulled into this variable and bump the previous errors down in the line as the most recent error takes first place. Lets try
    calling the last error to further show this behavior. 

#>

$Error[8]

#Yep, confirmed this is the first error that occured. So why does this matter? Well it's important to note if you are working through
#the error stream to troubleshoot an issue. If you aren't aware of this you could be looking at the error info for something completely different.


#So lets see if the properties and info we had access to earlier are still available...
$Error[0] | Get-Member 

#Yep! So each error is logged in this stream with a rich object based information to help with troubleshooting. 


<#
    Next Step tips: 
        1) Explore the properties on your errors as some really great info can be nested within properties. 
        2) Look into Breakpoints and error handling within scripts to catch errors and to step through them.
        3) If you are having a tough time with an error in a script and breakpoints, error handling, or if your error stream is 
           getting flooded with errors; try using the .Clear() method on the error stream to do some house cleaning on it to further isolate the 
           error info you are looking for.




    Anyways that is thats it on working with errors for now, Best of luck troubleshooting! 
#>



#endregion

