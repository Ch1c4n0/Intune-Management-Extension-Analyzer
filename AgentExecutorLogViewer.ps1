Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Caminho do arquivo de log
$logPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\AgentExecutor.log"

# Função para extrair dados de cada linha do log, incluindo o texto entre <![LOG[ ... ]LOG]!>
function Get-LogLineParsed {
    param([string]$line)
    $regex = '<time="([^\"]+)" date="([^\"]+)" component="([^\"]+)" context="([^\"]*)" type="([^\"]+)" thread="([^\"]+)" file="([^\"]*)">'
    $logMatch = [regex]::Match($line, $regex)
    $logText = $null
    $textRegex = '<!\[LOG\[(.*?)\]LOG\]!>'
    $textMatch = [regex]::Match($line, $textRegex)
    if ($textMatch.Success) {
        $logText = $textMatch.Groups[1].Value
    }
    if ($logMatch.Success) {
        return [PSCustomObject]@{
            LogText   = $logText
            Time      = $logMatch.Groups[1].Value
            Date      = $logMatch.Groups[2].Value
            Component = $logMatch.Groups[3].Value
            Context   = $logMatch.Groups[4].Value
            Type      = $logMatch.Groups[5].Value
            Thread    = $logMatch.Groups[6].Value
            File      = $logMatch.Groups[7].Value
        }
    } elseif ($logText) {
        return [PSCustomObject]@{
            LogText   = $logText
            Time      = "-"
            Date      = "-"
            Component = "-"
            Context   = "-"
            Type      = "-"
            Thread    = "-"
            File      = "-"
        }
    } else {
        return $null
    }
}

function Get-LogData {
    $data = @()
    if (Test-Path $logPath) {
        $lines = Get-Content $logPath
        foreach ($line in $lines) {
            $entry = Get-LogLineParsed $line
            if ($entry) { $data += $entry }
        }
        if ($data.Count -eq 0) {
            return [PSCustomObject]@{ Time = "-"; Date = "-"; Component = "Nenhum dado encontrado"; Context = "-"; Type = "-"; Thread = "-"; File = "-" }
        }
    } else {
        return [PSCustomObject]@{ Time = "-"; Date = "-"; Component = "Arquivo não encontrado"; Context = "-"; Type = "-"; Thread = "-"; File = "-" }
    }
    return $data
}
# ...existing code...
