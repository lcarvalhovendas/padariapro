# Script PowerShell para Deploy das Cloud Functions
# PadariaPro - Correção dos Botões de Assinatura

Write-Host "🚀 Deploy das Cloud Functions - PadariaPro" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Verifica se o Firebase CLI está instalado
Write-Host "📋 Verificando Firebase CLI..." -ForegroundColor Yellow
$firebaseVersion = firebase --version 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Firebase CLI não encontrado!" -ForegroundColor Red
    Write-Host "Instale com: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Firebase CLI instalado: $firebaseVersion" -ForegroundColor Green
Write-Host ""

# Verifica se está no diretório correto
if (-not (Test-Path "functions/index.js")) {
    Write-Host "❌ Erro: Execute este script na raiz do projeto!" -ForegroundColor Red
    exit 1
}

# Verifica se está logado no Firebase
Write-Host "🔐 Verificando autenticação Firebase..." -ForegroundColor Yellow
$firebaseProjects = firebase projects:list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Não autenticado no Firebase!" -ForegroundColor Red
    Write-Host "Executando firebase login..." -ForegroundColor Yellow
    firebase login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Falha no login!" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✅ Autenticado no Firebase" -ForegroundColor Green
Write-Host ""

# Verifica se o arquivo .env existe
Write-Host "📄 Verificando arquivo .env..." -ForegroundColor Yellow
if (-not (Test-Path "functions/.env")) {
    Write-Host "⚠️  Arquivo .env não encontrado!" -ForegroundColor Yellow
    Write-Host "Criando arquivo .env..." -ForegroundColor Yellow
    
    $envContent = @"
# Configuração da Stripe
# IMPORTANTE: Substitua pela sua chave secreta real em produção

# Chave secreta da Stripe (obrigatório)
# Teste: sk_test_...
# Produção: sk_live_...
STRIPE_SECRET_KEY=sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru

# Webhook secret para validação (opcional, recomendado para produção)
# Obtenha no Dashboard da Stripe após criar o webhook
# STRIPE_WEBHOOK_SECRET=whsec_...
"@
    
    Set-Content -Path "functions/.env" -Value $envContent -Encoding UTF8
    Write-Host "✅ Arquivo .env criado!" -ForegroundColor Green
    Write-Host "⚠️  IMPORTANTE: Edite functions/.env e adicione suas chaves reais!" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host "✅ Arquivo .env encontrado" -ForegroundColor Green
    Write-Host ""
}

# Instala dependências
Write-Host "📦 Instalando dependências..." -ForegroundColor Yellow
Set-Location functions
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao instalar dependências!" -ForegroundColor Red
    Set-Location ..
    exit 1
}
Set-Location ..
Write-Host "✅ Dependências instaladas" -ForegroundColor Green
Write-Host ""

# Pergunta se deseja configurar as variáveis de ambiente
Write-Host "🔧 Configuração de Variáveis de Ambiente" -ForegroundColor Cyan
Write-Host "As variáveis de ambiente precisam ser configuradas no Firebase Functions." -ForegroundColor White
Write-Host ""
$configEnv = Read-Host "Deseja configurar as variáveis agora? (s/n)"

if ($configEnv -eq "s" -or $configEnv -eq "S") {
    Write-Host ""
    Write-Host "Digite sua chave secreta da Stripe:" -ForegroundColor Yellow
    Write-Host "(Deixe em branco para usar a chave de teste padrão)" -ForegroundColor Gray
    $stripeKey = Read-Host "STRIPE_SECRET_KEY"
    
    if ([string]::IsNullOrWhiteSpace($stripeKey)) {
        $stripeKey = "sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru"
    }
    
    Write-Host "Configurando variável STRIPE_SECRET_KEY..." -ForegroundColor Yellow
    firebase functions:config:set stripe.secret_key="$stripeKey"
    
    Write-Host ""
    Write-Host "Digite o webhook secret da Stripe (opcional):" -ForegroundColor Yellow
    Write-Host "(Deixe em branco para pular)" -ForegroundColor Gray
    $webhookSecret = Read-Host "STRIPE_WEBHOOK_SECRET"
    
    if (-not [string]::IsNullOrWhiteSpace($webhookSecret)) {
        Write-Host "Configurando variável STRIPE_WEBHOOK_SECRET..." -ForegroundColor Yellow
        firebase functions:config:set stripe.webhook_secret="$webhookSecret"
    }
    
    Write-Host "✅ Variáveis configuradas" -ForegroundColor Green
    Write-Host ""
}

# Deploy das functions
Write-Host "🚀 Iniciando deploy das Cloud Functions..." -ForegroundColor Cyan
Write-Host "Isto pode levar alguns minutos..." -ForegroundColor Gray
Write-Host ""

firebase deploy --only functions

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "🎉 Deploy concluído com sucesso!" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Próximos Passos:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Configure o Billing Portal na Stripe:" -ForegroundColor White
    Write-Host "   https://dashboard.stripe.com/settings/billing/portal" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Configure o Webhook na Stripe:" -ForegroundColor White
    Write-Host "   - URL: https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook" -ForegroundColor Gray
    Write-Host "   - Eventos: checkout.session.completed, customer.subscription.*" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Teste os botões no app:" -ForegroundColor White
    Write-Host "   - Portal de Assinatura" -ForegroundColor Gray
    Write-Host "   - Cancelar Assinatura" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📖 Veja INSTRUCOES_DEPLOY_CORRECAO.md para mais detalhes" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Host ""
    Write-Host "❌ Erro no deploy!" -ForegroundColor Red
    Write-Host "Verifique os logs acima para mais informações." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📖 Consulte INSTRUCOES_DEPLOY_CORRECAO.md para ajuda" -ForegroundColor Yellow
    exit 1
}
