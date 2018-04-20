$content = @'
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

Import-Module dbatools
. "þinsertinternalþ"
'@

$pathInternal = Resolve-Path .\importinternals.ps1
$content = $content -replace "þinsertinternalþ",$pathInternal
Set-Content -Path $profile -Value $content -Encoding UTF8
$cred = (Get-Credential foo)