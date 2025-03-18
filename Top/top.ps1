# Funcao para limpar a tela inicialmente
function Limpar-Tela {
    Clear-Host
    Write-Host "=== Monitoramento de Sistema (Pressione Ctrl+C para sair) ===" -ForegroundColor Green
    Write-Host "Data/Hora: $(Get-Date)" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------"
}

# Funcao para exibir o uso geral da CPU e memória
function Exibir-UsoSistema {
    # Uso da CPU
    $cpu = Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    Set-CursorPos 5 0
    Write-Host "Uso da CPU: $($cpu)%               " -NoNewline

    # Uso da Memória RAM
    $memoria = Get-WmiObject Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory
    $totalRAM = [math]::Round($memoria.TotalVisibleMemorySize / 1MB, 2)
    $livreRAM = [math]::Round($memoria.FreePhysicalMemory / 1MB, 2)
    $usadaRAM = $totalRAM - $livreRAM
    Set-CursorPos 6 0
    Write-Host "Memoria Total: ${totalRAM} GB      " -NoNewline
    Set-CursorPos 7 0
    Write-Host "Memoria Livre: ${livreRAM} GB      " -NoNewline
    Set-CursorPos 8 0
    Write-Host "Memoria Usada: ${usadaRAM} GB      " -NoNewline
    Set-CursorPos 9 0
    Write-Host "-------------------------------------------------------------" -NoNewline
}

# Funcao para exibir os processos mais ativos
function Exibir-ProcessosAtivos {
    # Obtém os 10 processos mais ativos
    $processos = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

    # Define a posicao inicial dos processos
    $linhaInicial = 11

    # Limpa a área de processos antes de atualizar
    for ($i = 0; $i -lt 10; $i++) {
        Set-CursorPos ($linhaInicial + $i) 0
        Write-Host "                                             " -NoNewline
    }

    # Exibe os processos
    $linha = $linhaInicial
    foreach ($proc in $processos) {
        Set-CursorPos $linha 0
        Write-Host "$($proc.Id)".PadRight(6) -NoNewline
        Write-Host "$($proc.ProcessName)".PadRight(20) -NoNewline
        Write-Host "$($proc.CPU)".PadRight(10) -NoNewline
        Write-Host "$([math]::Round($proc.WorkingSet / 1MB, 2)) MB" -NoNewline
        $linha++
    }
}

# Funcao para definir a posicao do cursor
function Set-CursorPos {
    param (
        [int]$linha,
        [int]$coluna
    )
    [Console]::SetCursorPosition($coluna, $linha)
}

# Loop principal: Atualiza as informações periodicamente
try {
    Limpar-Tela
    while ($true) {
        Exibir-UsoSistema
        Exibir-ProcessosAtivos

        # Aguarda alguns segundos antes de atualizar novamente
        Start-Sleep -Seconds 1
    }
} catch {
    # Captura interrupcao (Ctrl+C) para sair do loop
    Write-Host "`nMonitoramento encerrado." -ForegroundColor Red
}