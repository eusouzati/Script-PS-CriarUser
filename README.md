# Script de Criação de Usuários no Active Directory

## Descrição
Este script em PowerShell foi desenvolvido para importar usuários de um arquivo CSV e criar contas no Active Directory (AD), verificando a existência do usuário e atribuindo as contas às Unidades Organizacionais (OU) corretas.

## Pré-requisitos
- Permissões para criar usuários no Active Directory.
- Módulo do PowerShell `ActiveDirectory` instalado.
- Arquivo CSV contendo os dados dos usuários.

## Como utilizar o script
1. Certifique-se de que o módulo `ActiveDirectory` está instalado. Caso não esteja, você pode instalá-lo executando:
    ```powershell
    Install-WindowsFeature -Name "RSAT-AD-PowerShell"
    ```
2. Edite o caminho do arquivo CSV no script:
    ```powershell
    $csvPath = "C:\Script\usuarios.csv"
    ```
3. Atualize o domínio no script conforme necessário:
    ```powershell
    $dominio = "SeuDominio.local"
    ```
4. Edite o caminho da OU, se necessário:
    ```powershell
    $ouPath = "OU=$Departamento,OU=Departamentos,DC=SeuDominio,DC=local"
    ```
5. Execute o script no PowerShell com permissões de administrador.

## Formato do arquivo CSV
O arquivo CSV deve conter as seguintes colunas, todas obrigatórias:
```csv
NomeCompleto,SamAccountName,Email,Telefone,Departamento,Senha

NomeCompleto,SamAccountName,Email,Telefone,Departamento,Senha
João Silva,jsilva,joao.silva@seudominio.com,123456789,TI,P@ssword123
Maria Oliveira,moliveira,maria.oliveira@seudominio.com,987654321,Financeiro,SecurePass456

Iniciando importação de usuários a partir de C:\Script\usuarios.csv...
Verificando a existência da OU: OU=TI,OU=Departamentos,DC=SeuDominio,DC=local...
Criando usuário João Silva (jsilva) na OU OU=TI...
Usuário João Silva (jsilva) criado com sucesso na OU TI!
Usuário Maria Oliveira (moliveira) já existe. Pulando criação...

Resumo:
Usuários criados: 1
Usuários pulados (já existentes): 1
Erros encontrados: 0

