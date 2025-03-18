O arquivo top.ps1 tenta ser similar ao comando top do Bash

### **Estrutura Geral do Script**

O script está organizado em funções modulares, cada uma com uma responsabilidade específica. Ele usa manipulação de cursor (`[Console]::SetCursorPosition`) para atualizar partes específicas da tela dinamicamente.

---

### **1. Função `Limpar-Tela`**

```powershell
function Limpar-Tela {
    Clear-Host
    Write-Host "=== Monitoramento de Sistema (Pressione Ctrl+C para sair) ===" -ForegroundColor Green
    Write-Host "Data/Hora: $(Get-Date)" -ForegroundColor Cyan
    Write-Host "-------------------------------------------------------------"
}
```

#### **Explicação**
- **`Clear-Host`**: Limpa a tela para garantir que não haja resíduos de texto antigo.
- **Cabeçalho Fixo**:
  - Escreve um cabeçalho fixo na tela com informações gerais sobre o monitoramento.
  - O cabeçalho inclui:
    - Título do monitoramento (`Monitoramento de Sistema`).
    - Data e hora atuais (`$(Get-Date)`).
    - Linha divisória (`-------------------------------------------------------------`).

Este cabeçalho será exibido apenas uma vez no início do script e permanecerá fixo durante a execução.

---

### **2. Função `Exibir-UsoSistema`**

```powershell
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
    Write-Host "Memória Total: ${totalRAM} GB      " -NoNewline
    Set-CursorPos 7 0
    Write-Host "Memória Livre: ${livreRAM} GB      " -NoNewline
    Set-CursorPos 8 0
    Write-Host "Memória Usada: ${usadaRAM} GB      " -NoNewline
    Set-CursorPos 9 0
    Write-Host "-------------------------------------------------------------" -NoNewline
}
```

#### **Explicação**
- **Uso da CPU**:
  - `Get-WmiObject Win32_Processor`: Obtém informações sobre os processadores.
  - `Measure-Object -Property LoadPercentage -Average`: Calcula a média do uso da CPU em porcentagem.
  - `$cpu`: Armazena o valor médio do uso da CPU.
  - `Set-CursorPos 5 0`: Define o cursor na linha 5, coluna 0.
  - `Write-Host "Uso da CPU: $($cpu)%"`: Escreve o uso da CPU na tela.
  - `-NoNewline`: Impede que o cursor avance para a próxima linha.

- **Uso da Memória RAM**:
  - `Get-WmiObject Win32_OperatingSystem`: Obtém informações sobre a memória total e livre.
  - `[math]::Round(...)`: Converte os valores de bytes para gigabytes (GB) e arredonda para duas casas decimais.
  - `Set-CursorPos`: Define o cursor nas linhas 6, 7 e 8 para escrever as informações de memória total, livre e usada.
  - `Write-Host`: Atualiza as linhas correspondentes na tela.

- **Linha Divisória**:
  - `Set-CursorPos 9 0`: Define o cursor na linha 9, coluna 0.
  - `Write-Host "-------------------------------------------------------------"`: Adiciona uma linha divisória para separar as seções.

---

### **3. Função `Exibir-ProcessosAtivos`**

```powershell
function Exibir-ProcessosAtivos {
    # Obtém os 10 processos mais ativos
    $processos = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10

    # Define a posição inicial dos processos
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
```

#### **Explicação**
- **Obtém os Processos**:
  - `Get-Process`: Lista todos os processos em execução.
  - `Sort-Object CPU -Descending`: Ordena os processos pelo uso da CPU em ordem decrescente.
  - `Select-Object -First 10`: Seleciona os 10 processos mais ativos.

- **Limpa a Área de Processos**:
  - `$linhaInicial = 11`: Define a linha inicial para exibir os processos.
  - `for ($i = 0; $i -lt 10; $i++)`: Loop para limpar as 10 linhas reservadas para os processos.
  - `Set-CursorPos ($linhaInicial + $i) 0`: Posiciona o cursor na linha correspondente.
  - `Write-Host " "`: Substitui o conteúdo antigo com espaços em branco para limpar a linha.

- **Exibe os Processos**:
  - `$linha = $linhaInicial`: Inicializa a variável de linha.
  - `foreach ($proc in $processos)`: Itera sobre os 10 processos mais ativos.
  - `Set-CursorPos $linha 0`: Posiciona o cursor na linha correta.
  - `Write-Host`: Exibe as informações de cada processo (ID, Nome, CPU e Memória).
    - `.PadRight(x)`: Garante que cada coluna tenha um tamanho fixo para alinhar os dados.
    - `-NoNewline`: Impede que o cursor avance para a próxima linha.

---

### **4. Função `Set-CursorPos`**

```powershell
function Set-CursorPos {
    param (
        [int]$linha,
        [int]$coluna
    )
    [Console]::SetCursorPosition($coluna, $linha)
}
```

#### **Explicação**
- **Parâmetros**:
  - `$linha`: Número da linha onde o cursor deve ser posicionado.
  - `$coluna`: Número da coluna onde o cursor deve ser posicionado.

- **Funcionalidade**:
  - `[Console]::SetCursorPosition($coluna, $linha)`: Altera a posição do cursor no console.
  - Isso permite que atualizemos partes específicas da tela sem reescrever todo o conteúdo.

---

### **5. Loop Principal**

```powershell
try {
    Limpar-Tela
    while ($true) {
        Exibir-UsoSistema
        Exibir-ProcessosAtivos

        # Aguarda alguns segundos antes de atualizar novamente
        Start-Sleep -Seconds 1
    }
} catch {
    # Captura interrupção (Ctrl+C) para sair do loop
    Write-Host "`nMonitoramento encerrado." -ForegroundColor Red
}
```

#### **Explicação**
- **`Limpar-Tela`**: Exibe o cabeçalho inicial uma única vez.
- **Loop Infinito**:
  - `while ($true)`: Mantém o script em execução continuamente.
  - `Exibir-UsoSistema`: Atualiza as informações de uso da CPU e memória.
  - `Exibir-ProcessosAtivos`: Atualiza a lista dos 10 processos mais ativos.
  - `Start-Sleep -Seconds 1`: Pausa o loop por 1 segundo antes de atualizar novamente.
- **Tratamento de Interrupção**:
  - `try/catch`: Captura a interrupção (`Ctrl+C`) para permitir que o usuário encerre o script de forma segura.
  - `Write-Host`: Exibe uma mensagem de despedida quando o script é interrompido.

---

### **Resumo do Funcionamento**

1. **Inicialização**:
   - O script começa limpando a tela e exibindo um cabeçalho fixo.

2. **Atualização Contínua**:
   - As informações de uso da CPU e memória são atualizadas dinamicamente na tela.
   - A lista dos 10 processos mais ativos é atualizada periodicamente.

3. **Manipulação de Cursor**:
   - O script usa `[Console]::SetCursorPosition` para atualizar apenas as partes relevantes da tela, evitando flickering ou redimensionamento desnecessário.

4. **Interrupção Segura**:
   - O script pode ser interrompido a qualquer momento pressionando `Ctrl+C`.

---