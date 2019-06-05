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
What are Workflows? 

Workflows use a 'powershell-like-syntax', but are not PowerShell. The purpose of workflows is orchestration.  
-Workflows are ideal for: 
    Run running code, hours or days.
    Unattended execution
    parallel execution
    can be stopped and restarted as well as continue through reboots and crashes

Workflow cons: 
    workflows are complex
    a pain to write

    
    
Now lets get onto some examples..... 


#>


#region Workflows_01

# Here is a typical 'hello world' example

Workflow Hello
{
    'Norcal PowerShell!'
}

Hello

# Lets get some more info about 'Hello'

Get-Command Hello

# Notice the CommandType. Now lets try a typically available command in powershell within the workflow

Workflow Hello2
{
    Write-Host 'Hello2!'
}

Hello2


# Notice how the error mentions workflow activities and what commands are available.

# Lets try a none interactive session command

Workflow Hello2
{
    $Word = 'Hello2!'
    return $Word
}

Hello2







#endregion


#region Workflows_02

# Lets look at what workflows are good at

Workflow Invoke-ParallelForEach
{
    foreach -parallel ($i in 1..10)
    {
        InlineScript
        {
            "foo: $using:i"

        }
        $count = Get-Process -Name PowerShell* | Measure-Object | Select-Object -ExpandProperty Count 
        "Number of PowerShell processes = $count"
    }


}
$StartCount = Get-Process -Name PowerShell* | Measure-Object | Select-Object -ExpandProperty Count 
"Number of starting PowerShell processes = $StartCount"

Invoke-ParallelForEach


#endregion

#region Workflows_03-parallel

Workflow p1
{
    foreach($i in 1..4)
    {
        $i
    }
    foreach($j in 4..1)
    {
        $j
    }
}

p1

Function f1
{
    foreach ($i in 1..4)
    {
        $i
    }
    foreach ($j in 4..1)
    {
        $j
    }

}
f1


Workflow p2
{
    Parallel 
    {
        foreach($i in 1..4)
        {
            $i
        }
        foreach($j in 4..1)
        {
            $j
        }
    }
}

p2

Measure-Command {p1} | Select-Object Milliseconds
Measure-Command {p2} | Select-Object Milliseconds

#endregion

#region Workflows_04-sequence

Workflow ps1
{
    Parallel
    {
        foreach($i in 1..4)
        {
            $i
        }
        sequence
        {
            foreach ($k in 65..68)
            {
                [char][byte]$k
            }

            foreach ($k in 87..90)
            {
                [char][byte]$k
            }

        }
        foreach ($j in 4..1)
        {
            $j
        }

    }
}

ps1

#endregion


#endregion



#region MoreInfo
# For more info about workflows try looking at the output from calling get-command with the target being a workflow then piping into format-list *

Get-Command Hello | FL *

#endregion 