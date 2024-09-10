# Importação do módulo Active Directory
Import-Module ActiveDirectory

# Caminho do arquivo CSV
$csvPath = "C:\Script\usuarios.csv"

# Verificar se o arquivo CSV existe
if (-not (Test-Path $csvPath)) {
    Write-Host "Arquivo CSV não encontrado: $csvPath" -ForegroundColor Red
    exit
}

Write-Host "Iniciando importação de usuários a partir de $csvPath..." -ForegroundColor Yellow

# Variáveis para resumo
$usuariosCriados = 0
$usuariosPulados = 0
$usuariosErros = 0

# Função para criação de usuários no AD
function Criar-UsuarioAD {
    param (
        [string]$NomeCompleto,
        [string]$SamAccountName,
        [string]$Email,
        [string]$Telefone,
        [string]$Departamento,
        [string]$Senha
    )

    try {
        # Ajuste aqui o nome do domínio de acordo com o seu ambiente
        $dominio = "SeuDominio.local"  # ←←← ATUALIZE AQUI SEU DOMÍNIO

        # Definir a OU com base no departamento
        $ouPath = "OU=$Departamento,OU=Departamentos,DC=SeuDominio,DC=local"  # ←←← ATUALIZE AQUI O DOMÍNIO

        Write-Host "Verificando a existência da OU: $ouPath..." -ForegroundColor Yellow

        # Verificar se a OU existe
        $ouExistente = Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$ouPath'" -ErrorAction SilentlyContinue

        if (-not $ouExistente) {
            Write-Host "A OU do Departamento $Departamento não foi encontrada." -ForegroundColor Red
            $script:usuariosErros++
            return
        }

        # Verificar se o usuário já existe
        $usuarioExistente = Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction SilentlyContinue

        if ($usuarioExistente) {
            Write-Host "Usuário $SamAccountName já existe. Pulando criação..." -ForegroundColor Yellow
            $script:usuariosPulados++
        } else {
            # Separação do nome e sobrenome aprimorada
            $nomeArray = $NomeCompleto.Split(' ')
            $givenName = $nomeArray[0]
            $surname = if ($nomeArray.Count -gt 1) { $nomeArray[1..($nomeArray.Length)] -join ' ' } else { $givenName }

            # Criar o novo usuário dentro da OU do Departamento
            Write-Host "Criando usuário $NomeCompleto ($SamAccountName) na OU $ouPath..." -ForegroundColor Yellow

            New-ADUser -Name $NomeCompleto `
                -SamAccountName $SamAccountName `
                -UserPrincipalName "$SamAccountName@$dominio" `
                -EmailAddress $Email `
                -GivenName $givenName `
                -Surname $surname `
                -DisplayName $NomeCompleto `
                -Path $ouPath `
                -OfficePhone $Telefone `
                -Department $Departamento `
                -AccountPassword (ConvertTo-SecureString $Senha -AsPlainText -Force) `
                -Enabled $true `
                -ChangePasswordAtLogon $true

            Write-Host "Usuário $NomeCompleto ($SamAccountName) criado com sucesso na OU $Departamento!" -ForegroundColor Green
            $script:usuariosCriados++
        }

    } catch {
        Write-Host "Erro ao criar o usuário ${NomeCompleto}: $_" -ForegroundColor Red
        $script:usuariosErros++
    }
}

# Importar usuários a partir do CSV e criar no AD
try {
    $usuarios = Import-Csv -Path $csvPath

    if ($usuarios.Count -eq 0) {
        Write-Host "Nenhum usuário encontrado no arquivo CSV." -ForegroundColor Red
        exit
    }

    foreach ($usuario in $usuarios) {
        Criar-UsuarioAD `
            -NomeCompleto $usuario.NomeCompleto `
            -SamAccountName $usuario.SamAccountName `
            -Email $usuario.Email `
            -Telefone $usuario.Telefone `
            -Departamento $usuario.Departamento `
            -Senha $usuario.Senha
    }

    # Exibir resumo
    Write-Host "`nResumo:" -ForegroundColor Cyan
    Write-Host "Usuários criados: $usuariosCriados" -ForegroundColor Green
    Write-Host "Usuários pulados (já existentes): $usuariosPulados" -ForegroundColor Yellow
    Write-Host "Erros encontrados: $usuariosErros" -ForegroundColor Red

} catch {
    Write-Host "Erro ao importar o CSV: $_" -ForegroundColor Red
}
