# 🔄 Fluxo de Pagamento - Diagrama

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FLUXO COMPLETO                               │
└─────────────────────────────────────────────────────────────────────┘

1️⃣ USUÁRIO NO APP
   ↓
   • Usuário autenticado (Firebase Auth)
   • Clica em "Assinar PRO" (R$ 9,99/mês)
   ↓

2️⃣ REDIRECIONAMENTO STRIPE
   ↓
   • openStripeCheckout() é chamada
   • Envia client_reference_id={UID do Firebase}
   • Redireciona para: buy.stripe.com/test_...?client_reference_id=abc123
   ↓

3️⃣ PAGAMENTO NA STRIPE
   ↓
   • Usuário preenche dados do cartão
   • Stripe processa pagamento
   • Status: paid ✅
   ↓

4️⃣ WEBHOOK DISPARADO
   ↓
   • Stripe → POST https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook
   • Evento: checkout.session.completed
   • Dados: { client_reference_id: "abc123", payment_status: "paid", ... }
   ↓

5️⃣ CLOUD FUNCTION PROCESSA
   ↓
   • Extrai UID do client_reference_id
   • Atualiza Firestore: users/abc123 → { plan: "pro", ... }
   • Retorna 200 OK para Stripe
   ↓

6️⃣ USUÁRIO RETORNA AO APP
   ↓
   • Stripe redireciona para: padariapro.netlify.app/?success=true
   • checkStripeReturn() detecta parâmetro success=true
   • startProVerification() é chamada
   ↓

7️⃣ VERIFICAÇÃO EM TEMPO REAL
   ↓
   • Firestore Listener detecta mudança em users/abc123
   • Campo plan mudou de "free" → "pro"
   • App atualiza estado local: App.state.user.plan = "pro"
   ↓

8️⃣ CONFIRMAÇÃO
   ↓
   • Toast: "🎉 Bem-vindo ao PRO!"
   • Redireciona para dashboard
   • Recursos PRO desbloqueados ✅

┌─────────────────────────────────────────────────────────────────────┐
│                      ARQUITETURA TÉCNICA                             │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│              │         │              │         │              │
│   Frontend   │ ──────▶ │    Stripe    │ ──────▶ │  Cloud       │
│  (Netlify)   │         │   Checkout   │         │  Function    │
│              │         │              │         │              │
└──────┬───────┘         └──────────────┘         └──────┬───────┘
       │                                                  │
       │                                                  │
       │         ┌──────────────────────────────┐        │
       │         │                              │        │
       └────────▶│         Firestore            │◀───────┘
                 │    (users collection)        │
                 │  { uid: { plan: "pro" } }    │
                 │                              │
                 └──────────────────────────────┘
                              ▲
                              │ Listener em tempo real
                              │
                        ┌─────┴────┐
                        │ Frontend │
                        │  detecta │
                        │  mudança │
                        └──────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                    COMPONENTES PRINCIPAIS                            │
└─────────────────────────────────────────────────────────────────────┘

📄 index.html
   • openStripeCheckout() - Redireciona para Stripe com UID
   • checkStripeReturn() - Detecta retorno após pagamento
   • startProVerification() - Inicia verificação no Firestore

☁️ functions/index.js
   • stripeWebhook() - Processa webhook da Stripe
   • Atualiza Firestore quando payment_status === 'paid'

🔥 Firestore
   • Coleção: users
   • Documento: {uid}
   • Campos: plan, stripeCustomerId, upgradedAt

🔒 firestore.rules
   • Impede que usuário altere campo 'plan' diretamente
   • Apenas Cloud Function (admin) pode atualizar

┌─────────────────────────────────────────────────────────────────────┐
│                         SEGURANÇA                                    │
└─────────────────────────────────────────────────────────────────────┘

✅ client_reference_id validado no webhook
✅ Firestore Rules impedem alteração manual do plano
✅ Webhook signature pode ser verificado (opcional)
✅ Chaves secretas armazenadas em variáveis de ambiente
✅ HTTPS em todas as comunicações

┌─────────────────────────────────────────────────────────────────────┐
│                    MONITORAMENTO                                     │
└─────────────────────────────────────────────────────────────────────┘

📊 Firebase Console
   • Functions → Logs
   • Firestore → Database

💳 Stripe Dashboard
   • Webhooks → Events
   • Payments → Transactions

🖥️ Browser Console
   • Logs detalhados de cada etapa
   • Verificação em tempo real
```

## 🎯 Pontos Críticos

### 1. client_reference_id
**ANTES (❌):** `client_reference_id=Mrt0PRmyiVaO9pKj6CydRivIny93${uid}`
**DEPOIS (✅):** `client_reference_id=${uid}`

### 2. Webhook URL
Deve apontar para: `https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook`

### 3. Eventos do Webhook
Mínimo necessário:
- `checkout.session.completed`

Recomendado (para assinaturas):
- `customer.subscription.created`
- `customer.subscription.updated`
- `customer.subscription.deleted`

### 4. Sincronização Bidirecional
- Webhook → Firestore (servidor para banco)
- Firestore → Frontend (banco para cliente via listener)

## 🔧 Teste Manual do Fluxo

```bash
# 1. Ver logs em tempo real
firebase functions:log --only stripeWebhook --tail

# 2. Em outra janela, fazer um pagamento de teste
# 3. Observar logs mostrando:
#    - Webhook recebido
#    - UID extraído
#    - Firestore atualizado
#    - Resposta 200 enviada
```
