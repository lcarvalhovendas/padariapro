# 🔧 Configuração da Integração Stripe + Firebase

Este guia explica como configurar o fluxo de pagamento Stripe com atualização automática no Firebase para o PadariaPro.

## 📋 Pré-requisitos

- Conta Stripe (modo teste ou produção)
- Firebase CLI instalado (`npm install -g firebase-tools`)
- Projeto Firebase configurado (já existe: padariapro-d0759)

## 🚀 Passo a Passo

### 1️⃣ Instalar Dependências da Cloud Function

```bash
cd functions
npm install
```

### 2️⃣ Fazer Login no Firebase

```bash
firebase login
```

### 3️⃣ Configurar Chave Secreta da Stripe

Configure a chave secreta da Stripe como variável de ambiente:

```bash
firebase functions:config:set stripe.secret_key="sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru"
```

**⚠️ IMPORTANTE:** Quando for para produção, substitua pela chave real (começando com `sk_live_`)

### 4️⃣ Deploy da Cloud Function

```bash
firebase deploy --only functions
```

Após o deploy, você receberá a URL da função, algo como:
```
https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook
```

### 5️⃣ Configurar Webhook na Stripe

1. Acesse o [Dashboard da Stripe](https://dashboard.stripe.com/test/webhooks)
2. Clique em **"Add endpoint"**
3. Configure:
   - **Endpoint URL**: `https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook`
   - **Description**: `PadariaPro - Upgrade para PRO`
   - **Events to send**: Selecione os seguintes eventos:
     - ✅ `checkout.session.completed`
     - ✅ `customer.subscription.created`
     - ✅ `customer.subscription.updated`
     - ✅ `customer.subscription.deleted`
4. Clique em **"Add endpoint"**

### 6️⃣ (Opcional) Configurar Webhook Secret para Produção

Para maior segurança em produção, configure o webhook secret:

1. No Dashboard da Stripe, copie o **Signing secret** do webhook criado (começa com `whsec_`)
2. Configure no Firebase:

```bash
firebase functions:config:set stripe.webhook_secret="whsec_XXXXXXXXXXXXXXX"
```

3. Faça deploy novamente:

```bash
firebase deploy --only functions
```

### 7️⃣ Configurar URL de Retorno no Payment Link

Seu Payment Link da Stripe deve estar configurado com:
- **URL de Sucesso**: `https://padariapro.netlify.app/?success=true`
- **URL de Cancelamento**: `https://padariapro.netlify.app/`

## 🔄 Fluxo Completo

1. **Usuário clica em "Assinar PRO"** → Redireciona para Stripe com `client_reference_id={UID}`
2. **Usuário paga na Stripe** → Stripe processa o pagamento
3. **Stripe envia webhook** → Cloud Function recebe evento `checkout.session.completed`
4. **Cloud Function atualiza Firestore** → Define `plan: "pro"` no documento `users/{UID}`
5. **Usuário retorna ao site** → URL contém `?success=true`
6. **App detecta retorno** → Inicia verificação do Firestore
7. **Firestore notifica mudança** → Listener em tempo real detecta `plan: "pro"`
8. **App atualiza estado** → Usuário agora tem acesso PRO

## 🧪 Testar Localmente

Para testar a Cloud Function localmente:

```bash
cd functions
npm install
firebase emulators:start --only functions
```

A função estará disponível em `http://localhost:5001/padariapro-d0759/us-central1/stripeWebhook`

## 📝 Variáveis de Ambiente

Atualmente configuradas via `firebase functions:config`:

- `stripe.secret_key` - Chave secreta da Stripe
- `stripe.webhook_secret` - (Opcional) Secret do webhook para validação

Para visualizar as configurações atuais:

```bash
firebase functions:config:get
```

## 🔐 Segurança

### Regras do Firestore

As regras em `firestore.rules` impedem que usuários alterem diretamente o campo `plan`:

```javascript
allow update: if request.auth != null 
              && request.auth.uid == userId
              && (!request.resource.data.diff(resource.data).affectedKeys()
                  .hasAny(['plan', 'stripeCustomerId', 'subscriptionStatus']));
```

Apenas a Cloud Function (com privilégios admin) pode atualizar esses campos.

## 🐛 Troubleshooting

### Problema: Pagamento não atualiza o plano

1. **Verifique os logs da Cloud Function:**
   ```bash
   firebase functions:log
   ```

2. **Verifique o console do navegador** - Deve mostrar:
   - ✅ User autenticado com UID
   - 🔗 URL do checkout com client_reference_id correto
   - 🔄 Iniciando verificação após retorno
   - ✅ Plano PRO ativado

3. **Verifique no Dashboard da Stripe:**
   - Acesse "Webhooks" → Veja se o webhook foi disparado
   - Verifique a resposta (deve ser 200 OK)

4. **Verifique no Firestore:**
   - Console Firebase → Firestore Database
   - Coleção `users` → Documento com o UID do usuário
   - Campo `plan` deve estar como `"pro"`

### Problema: Webhook retorna erro 500

- A chave secreta pode estar incorreta
- Verifique os logs: `firebase functions:log`

### Problema: client_reference_id não está sendo enviado

- Verifique se o usuário está autenticado antes de clicar em "Assinar PRO"
- Abra o console e veja se aparece o log com o UID

## 📊 Monitoramento

### Logs da Cloud Function

```bash
firebase functions:log --only stripeWebhook
```

### Eventos na Stripe

Dashboard → Developers → Webhooks → [Seu webhook] → Events

## 🎯 Próximos Passos (Opcional)

1. **Portal de gerenciamento de assinatura** - Já implementado na função `createPortalLink`
2. **Upgrade para assinatura recorrente** - A função já suporta eventos de subscription
3. **Notificações por email** - Integrar SendGrid ou similar
4. **Analytics** - Rastrear conversões de FREE → PRO

## 💡 Notas Importantes

- Em **modo teste**, use cartões de teste da Stripe:
  - `4242 4242 4242 4242` (sucesso)
  - Qualquer data futura, qualquer CVV
- Em **produção**, substitua todas as chaves `test_` por `live_`
- O Payment Link atual é: `https://buy.stripe.com/test_00w3cvfVgbJB8hjcOqdnW01`

## 🆘 Suporte

Se encontrar problemas:
1. Verifique os logs do Firebase
2. Verifique o console do navegador
3. Verifique os eventos no Dashboard da Stripe
4. Confirme que o webhook está ativo e respondendo 200
