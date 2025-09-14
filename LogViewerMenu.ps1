Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Lista de scripts de visualização
$scripts = @(
    @{ Name = "AgentExecutor"; File = "AgentExecutorLogViewer.ps1" },
    @{ Name = "AppActionProcessor"; File = "AppActionProcessorLogViewer.ps1" },
    @{ Name = "AppWorkload"; File = "AppWorkloadLogViewer.ps1" },
    @{ Name = "ClientCertCheck"; File = "ClientCertCheckLogViewer.ps1" },
    @{ Name = "ClientHealth"; File = "ClientHealthLogViewer.ps1" },
    @{ Name = "DeviceHealthMonitoring"; File = "DeviceHealthMonitoringLogViewer.ps1" },
    @{ Name = "HealthScripts"; File = "HealthScriptsLogViewer.ps1" },
    @{ Name = "IntuneManagementExtension"; File = "IntuneManagementExtensionLogViewer.ps1" },
    @{ Name = "Sensor"; File = "SensorLogViewer.ps1" },
    @{ Name = "Win32AppInventory"; File = "Win32AppInventoryLogViewer.ps1" }
)

# Caminho base dos scripts
$scriptBase = Split-Path -Parent $MyInvocation.MyCommand.Path

# Criar o formulário do menu
$form = New-Object System.Windows.Forms.Form
$form.Text = "Intune Log Viewer Menu"
$form.Size = New-Object System.Drawing.Size(400, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::Gray
$form.ForeColor = [System.Drawing.Color]::Black
$form.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Selecione o log para visualizar:"
$lblTitle.Size = New-Object System.Drawing.Size(380, 40)
$lblTitle.Location = New-Object System.Drawing.Point(10, 20)
$lblTitle.BackColor = [System.Drawing.Color]::Gray
$lblTitle.ForeColor = [System.Drawing.Color]::Black
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblTitle)

# Adicionar botões dinamicamente
$y = 80
foreach ($script in $scripts) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $script.Name
    $btn.Size = New-Object System.Drawing.Size(360, 40)
    $btn.Location = New-Object System.Drawing.Point(20, $y)
    $btn.BackColor = [System.Drawing.Color]::Gray
    $btn.ForeColor = [System.Drawing.Color]::Black
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $btn.Add_Click({
        $scriptPath = Join-Path $scriptBase $script.File
        if (Test-Path $scriptPath) {
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
        } else {
            [System.Windows.Forms.MessageBox]::Show("Script não encontrado: $($script.File)", "Erro", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $form.Controls.Add($btn)
    $y += 50
}
# ...existing code...
