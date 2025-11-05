# Script de Deploy para PadariaPro
# PowerShell Script

Write-Host "🚀 Iniciando deploy do PadariaPro..." -ForegroundColor Cyan

# 1. Instalar dependências
Write-Host "`n📦 Instalando dependências da Cloud Function..." -ForegroundColor Yellow
Set-Location functions
npm install
Set-Location ..

# 2. Deploy das Functions
Write-Host "`n☁️ Fazendo deploy das Cloud Functions..." -ForegroundColor Yellow
firebase deploy --only functions

# 3. Deploy do Firestore Rules
Write-Host "`n🔒 Fazendo deploy das regras do Firestore..." -ForegroundColor Yellow
firebase deploy --only firestore:rules

# 4. Deploy dos índices do Firestore
Write-Host "`n📊 Fazendo deploy dos índices do Firestore..." -ForegroundColor Yellow
firebase deploy --only firestore:indexes

Write-Host "`n✅ Deploy concluído!" -ForegroundColor Green
Write-Host "`nPróximos passos:" -ForegroundColor Cyan
Write-Host "1. Configure o webhook na Stripe com a URL exibida acima"
Write-Host "2. Adicione os eventos: checkout.session.completed, customer.subscription.*"
Write-Host "3. Teste o fluxo de pagamento"
Write-Host "`nDocumentação completa: STRIPE_SETUP.md" -ForegroundColor Yellow
