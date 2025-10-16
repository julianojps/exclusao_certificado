# Monitoramento e Remoção de Certificado MS-Organization-Access

Este repositório contém um script PowerShell e arquivos Batch de suporte para monitorar e remover automaticamente certificados emitidos por `MS-Organization-Access` em uma máquina Windows.

## 🎯 Propósito

O certificado `MS-Organization-Access` é criado pelo Windows para facilitar o Single Sign-On (SSO) com o Azure Active Directory (agora Microsoft Entra ID). No entanto, ele pode persistir após a remoção de contas, expirar ou causar erros de autenticação contínuos.

Este script tem como objetivo:
* **Identificar** continuamente o certificado.
* **Remover** o certificado assim que ele é detectado, garantindo a limpeza e prevenindo erros.
* **Executar** automaticamente com privilégios elevados.

O script foi projetado para remover certificados que correspondem ao emissor **`*MS-Organization-Access*`**.

## ⚙️ Arquivos do Repositório

| Arquivo | Descrição |
| :--- | :--- |
| `remover-cert-msorg.ps1` | O script principal em PowerShell que contém a lógica de busca, remoção e log. |
| `iniciar-monitor-msorg.bat` | Arquivo Batch usado pelo Agendador de Tarefas para iniciar o script PowerShell minimizado e com o diretório correto. |
| `monitor-ms-org-cert.bat` | Versão em loop do Batch para execução manual (inicia o script a cada 10 segundos e fica ativo na janela de console). |

## 🛠️ Configuração Inicial

### 1. Política de Execução do PowerShell

Para permitir que o Windows execute scripts locais do PowerShell, você precisa definir a política de execução como `Bypass` ou `RemoteSigned`.

Abra o PowerShell como **Administrador** e execute:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

