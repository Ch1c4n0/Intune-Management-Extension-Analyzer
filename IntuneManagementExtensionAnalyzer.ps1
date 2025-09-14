Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Lista de scripts e arquivos de log
$logConfigs = @(
    @{ Name = "AgentExecutor"; File = "AgentExecutor.log" },
    @{ Name = "AppActionProcessor"; File = "AppActionProcessor.log" },
    @{ Name = "AppWorkload"; File = "AppWorkload.log" },
    @{ Name = "ClientCertCheck"; File = "ClientCertCheck.log" },
    @{ Name = "ClientHealth"; File = "ClientHealth.log" },
    @{ Name = "DeviceHealthMonitoring"; File = "DeviceHealthMonitoring.log" },
    @{ Name = "HealthScripts"; File = "HealthScripts.log" },
    @{ Name = "IntuneManagementExtension"; File = "IntuneManagementExtension.log" },
    @{ Name = "Sensor"; File = "Sensor.log" },
    @{ Name = "Win32AppInventory"; File = "Win32AppInventory.log" }
)

$logFolder = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"

# Função para extrair dados do log
function Get-LogLineParsed {
    param([string]$line)
    $regex = '<time="([^"]+)" date="([^"]+)" component="([^"]+)" context="([^"]*)" type="([^"]+)" thread="([^"]+)" file="([^"]*)">'
    $logMatch = [regex]::Match($line, $regex)
    $logText = $null
    $textRegex = '<!\[LOG\[(.*?)\]LOG\]!>'
    $textMatch = [regex]::Match($line, $textRegex, [System.Text.RegularExpressions.RegexOptions]::Singleline)
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
    param([string]$logPath)
    $data = @()
    if (Test-Path $logPath) {
        $fileText = Get-Content $logPath -Raw
        $pattern = '(<!\[LOG\[.*?\]LOG\]!><time="[^"]+" date="[^"]+" component="[^"]+" context="[^"]*" type="[^"]+" thread="[^"]+" file="[^"]*">)'
        $logMatches = [regex]::Matches($fileText, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        foreach ($match in $logMatches) {
            $entry = Get-LogLineParsed $match.Value
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

# Função para filtrar e formatar os dados
function Get-LogText {
    param([array]$data, [string]$logFilter, [string]$dateFilter)
    if ($data -is [System.Collections.IEnumerable]) {
        $filtered = $data | Where-Object {
            ($logFilter -eq "" -or $_.LogText -like "*${logFilter}*") -and
            ($dateFilter -eq "" -or $_.Date -like "*${dateFilter}*")
        }
        return ($filtered | ForEach-Object {
            $logText = $_.LogText -replace "`r`n", [Environment]::NewLine
            "LOG:" + [Environment]::NewLine + $logText + [Environment]::NewLine +
            "Time: $($_.Time)" + [Environment]::NewLine +
            "Date: $($_.Date)" + [Environment]::NewLine +
            "Component: $($_.Component)" + [Environment]::NewLine +
            "Context: $($_.Context)" + [Environment]::NewLine +
            "Type: $($_.Type)" + [Environment]::NewLine +
            "Thread: $($_.Thread)" + [Environment]::NewLine +
            "File: $($_.File)" + [Environment]::NewLine +
            "---------------------------"
        }) -join [Environment]::NewLine
    } else {
        return "Nenhum dado encontrado ou erro ao ler o arquivo."
    }
}

# Criar o formulário principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "Intune Log Viewer - Marcelo dos Santos Goncalves - MVP Security"
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::Gray
$form.ForeColor = [System.Drawing.Color]::Black
$form.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)

# Painel para menu
$panelMenu = New-Object System.Windows.Forms.Panel
$panelMenu.Size = $form.ClientSize
$panelMenu.BackColor = [System.Drawing.Color]::Gray
$panelMenu.Dock = 'Fill'

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Intune Management Extension Analyzer"
$lblTitle.Size = New-Object System.Drawing.Size(880, 40)
$lblTitle.Location = New-Object System.Drawing.Point((($form.ClientSize.Width - 880) / 2), 20)
$lblTitle.BackColor = [System.Drawing.Color]::Gray
$lblTitle.ForeColor = [System.Drawing.Color]::Black
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$panelMenu.Controls.Add($lblTitle)


# Adicionar botões dinamicamente na parte superior, logo abaixo do título
$menuButtons = @()
$y = $lblTitle.Location.Y + $lblTitle.Size.Height + 10  # 10px abaixo do título
foreach ($log in $logConfigs) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $log.Name
    $btn.Size = New-Object System.Drawing.Size(860, 40)
    $btn.Location = New-Object System.Drawing.Point(20, $y)
    $btn.BackColor = [System.Drawing.Color]::Gray
    $btn.ForeColor = [System.Drawing.Color]::Black
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $panelMenu.Controls.Add($btn)
    $menuButtons += $btn
    $logName = $log.Name
    $logFile = $log.File
    $btn.Add_Click([ScriptBlock]::Create("ShowLogViewer '$logName' '$logFile'"))
    $y += 50
}

$form.Controls.Add($panelMenu)

# Painel para visualização do log
$panelLog = New-Object System.Windows.Forms.Panel
$panelLog.Size = $form.ClientSize
$panelLog.BackColor = [System.Drawing.Color]::Gray
$panelLog.Dock = 'Fill'
$panelLog.Visible = $false

$lblLogTitle = New-Object System.Windows.Forms.Label
$lblLogTitle.Size = New-Object System.Drawing.Size(880, 40)
$lblLogTitle.Location = New-Object System.Drawing.Point(10, 10)
$lblLogTitle.BackColor = [System.Drawing.Color]::Gray
$lblLogTitle.ForeColor = [System.Drawing.Color]::Black
$lblLogTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($lblLogTitle)


# Adicionar controles na parte superior do painel de log
$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text = "Update"
$btnRefresh.Size = New-Object System.Drawing.Size(100,30)
$btnRefresh.Location = New-Object System.Drawing.Point(10,60)
$btnRefresh.BackColor = [System.Drawing.Color]::Gray
$btnRefresh.ForeColor = [System.Drawing.Color]::Black
$btnRefresh.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($btnRefresh)

$btnBack = New-Object System.Windows.Forms.Button
$btnBack.Text = "Back"
$btnBack.Size = New-Object System.Drawing.Size(100,30)
$btnBack.Location = New-Object System.Drawing.Point(120,60)
$btnBack.BackColor = [System.Drawing.Color]::Gray
$btnBack.ForeColor = [System.Drawing.Color]::Black
$btnBack.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($btnBack)

$lblLogFilter = New-Object System.Windows.Forms.Label
$lblLogFilter.Text = "Search:"
$lblLogFilter.Location = New-Object System.Drawing.Point(230,65)
$lblLogFilter.Size = New-Object System.Drawing.Size(70,20)
$lblLogFilter.BackColor = [System.Drawing.Color]::Gray
$lblLogFilter.ForeColor = [System.Drawing.Color]::Black
$lblLogFilter.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($lblLogFilter)

$txtLogFilter = New-Object System.Windows.Forms.TextBox
$txtLogFilter.Location = New-Object System.Drawing.Point(300,60)
$txtLogFilter.Size = New-Object System.Drawing.Size(200,30)
$txtLogFilter.BackColor = [System.Drawing.Color]::Gray
$txtLogFilter.ForeColor = [System.Drawing.Color]::Black
$txtLogFilter.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($txtLogFilter)

# Adicionar placeholder ao campo Search
$txtLogFilter.Text = "Digite o termo de busca..."
$txtLogFilter.ForeColor = [System.Drawing.Color]::DarkGray
$txtLogFilter.Add_Enter({
    if ($txtLogFilter.Text -eq "Digite o termo de busca...") {
        $txtLogFilter.Text = ""
        $txtLogFilter.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtLogFilter.Add_Leave({
    if ($txtLogFilter.Text -eq "") {
        $txtLogFilter.Text = "Digite o termo de busca..."
        $txtLogFilter.ForeColor = [System.Drawing.Color]::DarkGray
    }
})

$lblDateFilter = New-Object System.Windows.Forms.Label
$lblDateFilter.Text = "Date:"
$lblDateFilter.Location = New-Object System.Drawing.Point(510,65)
$lblDateFilter.Size = New-Object System.Drawing.Size(70,20)
$lblDateFilter.BackColor = [System.Drawing.Color]::Gray
$lblDateFilter.ForeColor = [System.Drawing.Color]::Black
$lblDateFilter.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($lblDateFilter)

$txtDateFilter = New-Object System.Windows.Forms.TextBox
$txtDateFilter.Location = New-Object System.Drawing.Point(580,60)
$txtDateFilter.Size = New-Object System.Drawing.Size(120,30)
$txtDateFilter.BackColor = [System.Drawing.Color]::Gray
$txtDateFilter.ForeColor = [System.Drawing.Color]::Black
$txtDateFilter.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($txtDateFilter)

# Adicionar placeholder ao campo Date
$txtDateFilter.Text = "Digite a data..."
$txtDateFilter.ForeColor = [System.Drawing.Color]::DarkGray
$txtDateFilter.Add_Enter({
    if ($txtDateFilter.Text -eq "Digite a data...") {
        $txtDateFilter.Text = ""
        $txtDateFilter.ForeColor = [System.Drawing.Color]::Black
    }
})
$txtDateFilter.Add_Leave({
    if ($txtDateFilter.Text -eq "") {
        $txtDateFilter.Text = "Digite a data..."
        $txtDateFilter.ForeColor = [System.Drawing.Color]::DarkGray
    }
})

# Caixa de texto do log agora fica abaixo dos controles
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ScrollBars = 'Vertical'
$txtLog.Size = New-Object System.Drawing.Size(880,480)
$txtLog.Location = New-Object System.Drawing.Point(10,100)
$txtLog.ReadOnly = $true
$txtLog.BackColor = [System.Drawing.Color]::Gray
$txtLog.ForeColor = [System.Drawing.Color]::Black
$txtLog.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$panelLog.Controls.Add($txtLog)

$form.Controls.Add($panelLog)

# Função para mostrar visualizador de log
function ShowLogViewer {
    param($logName, $logFile)
    $panelMenu.Visible = $false
    $panelLog.Visible = $true
    $lblLogTitle.Text = "Log: $logName"
    $logPath = Join-Path $logFolder $logFile
    $global:currentLogPath = $logPath
    UpdateLogView
}

# Função para atualizar visualização
function UpdateLogView {
    $searchText = $txtLogFilter.Text
    if ($searchText -eq "Digite o termo de busca...") { $searchText = "" }
    $dateText = $txtDateFilter.Text
    if ($dateText -eq "Digite a data...") { $dateText = "" }
    $data = Get-LogData $global:currentLogPath
    $txtLog.Text = Get-LogText $data $searchText $dateText
}

$btnRefresh.Add_Click({ UpdateLogView })
$btnBack.Add_Click({
    $panelLog.Visible = $false
    $panelMenu.Visible = $true
})
$txtLogFilter.Add_TextChanged({ UpdateLogView })
$txtDateFilter.Add_TextChanged({ UpdateLogView })

# Layout responsivo
$form.Add_Resize({
    $panelMenu.Size = $form.ClientSize
    $panelLog.Size = $form.ClientSize
    $txtLog.Width = $form.ClientSize.Width - 20
    $txtLog.Height = $form.ClientSize.Height - 120
    $btnRefresh.Location = New-Object System.Drawing.Point(10, $form.ClientSize.Height - 50)
    $btnBack.Location = New-Object System.Drawing.Point(120, $form.ClientSize.Height - 50)
    $lblLogFilter.Location = New-Object System.Drawing.Point(230, $form.ClientSize.Height - 45)
    $txtLogFilter.Location = New-Object System.Drawing.Point(300, $form.ClientSize.Height - 50)
    $lblDateFilter.Location = New-Object System.Drawing.Point(510, $form.ClientSize.Height - 45)
    $txtDateFilter.Location = New-Object System.Drawing.Point(580, $form.ClientSize.Height - 50)
    # Responsividade dos botões do menu em coluna
    $y = 80
    foreach ($btn in $menuButtons) {
        $btn.Size = New-Object System.Drawing.Size($form.ClientSize.Width - 40, 40)
        $btn.Location = New-Object System.Drawing.Point(20, $y)
        $y += 50
    }
})

[void]$form.ShowDialog()
