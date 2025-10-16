# ==============================================
# Remover certificado MS-Organization-Access (Pessoal)
# Local real: Cert:\CurrentUser\My
# ==============================================

$log = "C:\Windows\Temp\remover-cert-msorg.log"

function Write-Log {
    param([string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host "[$timestamp] $Message"
    Add-Content -Path $log -Value "[$timestamp] $Message"
}

Write-Log "---- Iniciando monitor de certificados MS-Organization-Access ----"

# Caminho corrigido para o store "Pessoal"
$certPath = "Cert:\CurrentUser\My"
$knownThumbprints = @{}

# Inicializa lista de certificados existentes
try {
    Get-ChildItem $certPath -ErrorAction Stop | ForEach-Object { $knownThumbprints[$_.Thumbprint] = $true }
    Write-Log "Monitorando $certPath (pressione CTRL+C para parar)"
} catch {
    Write-Log "Erro ao acessar $certPath : $_"
}

# --- Remoção inicial de certificados já existentes ---
try {
    # Busca pelo EMISSOR OU Subject (GUID)
    $existing = Get-ChildItem $certPath -ErrorAction Stop | Where-Object { 
        $_.Issuer -like "*MS-Organization-Access*" -or 
        $_.Subject -match "^[A-F0-9-]{36}$" 
    }
    
    foreach ($cert in $existing) {
        try {
            Write-Log "Removendo certificado existente: $($cert.Subject)"
            Remove-Item -Path "$certPath\$($cert.Thumbprint)" -Force
            Write-Log "Certificado removido com sucesso (inicial)."
        } catch {
            Write-Log "Erro ao remover certificado existente: $_"
        }
    }
} catch {
    Write-Log "Erro ao buscar certificados existentes: $_"
}

# --- Loop de monitoramento contínuo ---
while ($true) {
    try {
        $certs = Get-ChildItem $certPath -ErrorAction Stop

        foreach ($cert in $certs) {
            if (-not $knownThumbprints.ContainsKey($cert.Thumbprint)) {
                Write-Log "Novo certificado detectado: $($cert.Subject)"

                # Busca pelo EMISSOR OU Subject (GUID)
                if ($cert.Issuer -like "*MS-Organization-Access*" -or $cert.Subject -match "^[A-F0-9-]{36}$") {
                    try {
                        Remove-Item -Path "$certPath\$($cert.Thumbprint)" -Force
                        Write-Log "Certificado removido com sucesso!"
                    } catch {
                        Write-Log "Erro ao remover certificado: $_"
                    }
                }
                else {
                    Write-Log "Ignorado (não é MS-Organization-Access): $($cert.Subject)"
                }
            }
        }

        # Atualiza lista de certificados conhecidos
        $knownThumbprints.Clear()
        $certs | ForEach-Object { $knownThumbprints[$_.Thumbprint] = $true }
    }
    catch {
        Write-Log "Erro geral: $_"
    }

    Start-Sleep -Seconds 5
}