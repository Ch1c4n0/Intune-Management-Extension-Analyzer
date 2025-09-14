# Intune Management Extension Analyzer

Tool to view and analyze Intune Management Extension logs.

## Log Scripts

- **AgentExecutor.log**: Records agent task execution.
- **AppActionProcessor.log**: Monitors managed app actions.
- **AppWorkload.log**: Details distributed app workloads.
- **ClientCertCheck.log**: Checks client certificates for authentication.
- **ClientHealth.log**: Assesses Intune client health.
- **DeviceHealthMonitoring.log**: Monitors managed device health.
- **HealthScripts.log**: Records health script executions.
- **IntuneManagementExtension.log**: Main log for Intune Management Extension.
- **Sensor.log**: Collects device sensor data.
- **Win32AppInventory.log**: Inventories installed Win32 apps.

## IntuneManagementExtensionAnalyzer.ps1

This script creates a PowerShell GUI to view all logs above. Allows filtering by text and date, updating view, and switching between logs easily. Uses Windows Forms for a friendly and fast data display.

### Features
- Log selection in the interface
- Text and date filter
- Dynamic update
- Detailed view of each log entry

    <img width="888" height="629" alt="image" src="https://github.com/user-attachments/assets/5363d378-25dc-4845-82ea-0d6d5444471c" />

## Installation and Usage

You can install UnifiedLogViewer directly from PowerShell Gallery:

```
Install-Module -Name UnifiedLogViewer
```
After installing, run:

```
Get-IntuneLogs
```

Or run directly from the internet (no install):

```
IEX (Invoke-WebRequest 'https://raw.githubusercontent.com/Ch1c4n0/Intune-Management-Extension-Analyzer/refs/heads/main/UnifiedLogViewer.ps1' -UseBasicParsing)
```
---

# Intune Management Extension Analyzer

Ferramenta para visualizar e analisar os logs do Intune Management Extension.

## Scripts de Log

- **AgentExecutor.log**: Registra a execução de tarefas do agente do Intune.
- **AppActionProcessor.log**: Monitora ações de aplicativos gerenciados pelo Intune.
- **AppWorkload.log**: Detalha cargas de trabalho de aplicativos distribuídos.
- **ClientCertCheck.log**: Verifica certificados do cliente para autenticação.
- **ClientHealth.log**: Avalia a saúde do cliente Intune.
- **DeviceHealthMonitoring.log**: Monitora a integridade dos dispositivos gerenciados.
- **HealthScripts.log**: Registra execuções de scripts de saúde.
- **IntuneManagementExtension.log**: Log principal da extensão de gerenciamento do Intune.
- **Sensor.log**: Coleta dados de sensores do dispositivo.
- **Win32AppInventory.log**: Inventaria aplicativos Win32 instalados.

## IntuneManagementExtensionAnalyzer.ps1

Este script cria uma interface gráfica em PowerShell para visualizar todos os logs acima. Permite filtrar por texto e data, atualizar visualização e alternar entre logs facilmente. Utiliza Windows Forms para exibição amigável e rápida dos dados.

### Funcionalidades
- Seleção de log na interface
- Filtro por texto e data
- Atualização dinâmica
- Visualização detalhada de cada entrada de log

  <img width="888" height="629" alt="image" src="https://github.com/user-attachments/assets/5363d378-25dc-4845-82ea-0d6d5444471c" />

## Instalação e Execução

Você pode instalar o UnifiedLogViewer diretamente do PowerShell Gallery:

```
Install-Module -Name UnifiedLogViewer
```
Após instalar, execute:

```
Get-IntuneLogs
```

Ou executar diretamente pela internet (sem instalar):

```
IEX (Invoke-WebRequest 'https://raw.githubusercontent.com/Ch1c4n0/Intune-Management-Extension-Analyzer/refs/heads/main/UnifiedLogViewer.ps1' -UseBasicParsing)
```



