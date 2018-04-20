$moduleBase = Get-Module dbatools | exp ModuleBase
. "$($moduleBase)\internal\functions\Write-Message.ps1"
. "$($moduleBase)\internal\functions\Stop-Function.ps1"
. "$($moduleBase)\internal\functions\Test-FunctionInterrupt.ps1"
. "$($moduleBase)\internal\functions\Test-DbaDeprecation.ps1"
. "$($moduleBase)\internal\functions\Get-DbaRunspace.ps1"
. "$($moduleBase)\internal\functions\Write-HostColor.ps1"
$EnableException = $false

function Prompt
{
    try
    {
        $history = Get-History -ErrorAction Ignore
        if ($history)
        {
            Write-Host "[" -NoNewline
            if (([System.Management.Automation.PSTypeName]'Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty').Type)
            {
                Write-Host ([Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime)) -ForegroundColor Gray -NoNewline
            }
            else
            {
                Write-Host ($history[-1].EndExecutionTime - $history[-1].StartExecutionTime) -ForegroundColor Gray -NoNewline
            }
            Write-Host "]" -NoNewline
        }
    }
    catch { }
    Write-Host "I $([char]9829) dbatools:" -NoNewline
    "> "
}