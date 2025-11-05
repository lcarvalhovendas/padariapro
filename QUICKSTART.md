# ⚡ Quick Start - Stripe Integration

Guia rápido para ativar os pagamentos Stripe no PadariaPro.

## 🎯 Comandos Rápidos

### 1. Instalar Firebase CLI (se ainda não tem)
```bash
npm install -g firebase-tools
```

### 2. Login no Firebase
```bash
firebase login
```

### 3. Instalar dependências e fazer deploy
```bash
cd functions
npm install
cd ..
firebase deploy --only functions,firestore
```

### 4. Configurar chave da Stripe
```bash
firebase functions:config:set stripe.secret_key="sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru"
firebase deploy --only functions
```

### 5. Configurar Webhook na Stripe

1. Acesse: https://dashboard.stripe.com/test/webhooks
2. Clique em **"Add endpoint"**
3. Cole a URL: `https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook`
4. Adicione o evento: `checkout.session.completed`
5. Salve

## ✅ Pronto!

Agora teste:
1. Faça login no app: https://padariapro.netlify.app/
2. Clique em "Assinar PRO"
3. Use o cartão de teste: `4242 4242 4242 4242`
4. Após o pagamento, você será redirecionado e o plano será atualizado automaticamente

## 📄 Documentação Completa

- **Setup detalhado**: [STRIPE_SETUP.md](./STRIPE_SETUP.md)
- **Troubleshooting**: Consulte a seção no STRIPE_SETUP.md

## 🔍 Verificar se está funcionando

### Logs da Cloud Function
```bash
firebase functions:log --only stripeWebhook
```

### Console do navegador
Após clicar em "Assinar PRO", você deve ver:
- ✅ User autenticado: [UID]
- 🔗 Redirecionando para: https://buy.stripe.com/test_...
- (Após pagamento) 🔄 Iniciando verificação de PRO
- ✅ PLANO PRO ATIVADO!

## ⚠️ Problemas Comuns

### Plano não atualiza após pagamento
1. Verifique se o webhook está configurado corretamente
2. Veja os logs: `firebase functions:log`
3. Confirme que o evento `checkout.session.completed` está selecionado

### Erro 500 no webhook
- Verifique se a chave secreta da Stripe está correta
- Execute: `firebase functions:config:get` para ver as configurações

### UID não está sendo enviado
- Certifique-se de estar logado antes de clicar em "Assinar PRO"
- Verifique no console: deve aparecer "User autenticado"

## 🎉 Sucesso!

Se tudo funcionou, você verá:
- Mensagem "🎉 Bem-vindo ao PRO!" no app
- Campo `plan: "pro"` no Firestore (users → seu UID)
- Recursos PRO desbloqueados (sem limites de receitas, ingredientes, etc.)

---

**Precisando de ajuda?** Consulte [STRIPE_SETUP.md](./STRIPE_SETUP.md) para detalhes completos.
