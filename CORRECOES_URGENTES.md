# ⚡ CORREÇÕES URGENTES - Guia Rápido
## 3 Passos Críticos Antes de Lançar

**Tempo Total:** ~1h  
**Dificuldade:** Fácil

---

## 🔴 1. FIRESTORE RULES (5 minutos)

### Passo a Passo:
1. Acesse: https://console.firebase.google.com/
2. Selecione projeto **padariapro-d0759**
3. Menu lateral: **Firestore Database**
4. Clique na aba **Regras**
5. **DELETE tudo** e cole isso:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários só podem ler/escrever seus próprios dados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bloquear todo o resto
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

6. Clique em **Publicar**
7. ✅ PRONTO!

---

## 🔴 2. STRIPE WEBHOOK (30 minutos)

### Parte A: Criar Cloud Function

1. **Instalar Firebase CLI** (se não tiver):
```bash
npm install -g firebase-tools
firebase login
```

2. **Inicializar Functions:**
```bash
cd "c:\Users\Luan\Desktop\Projetos IA\Perplexity\PadariaPro"
firebase init functions
# Escolha: JavaScript
# Escolha: Yes (ESLint)
```

3. **Criar arquivo `functions/index.js`:**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  // Verificar se é POST
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  try {
    const event = req.body;

    console.log('📩 Webhook recebido:', event.type);

    // Quando checkout é completado
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const userId = session.client_reference_id;

      console.log('💰 Pagamento confirmado para:', userId);

      // Atualizar usuário para PRO
      await admin.firestore().collection('users').doc(userId).update({
        plan: 'pro',
        stripeCustomerId: session.customer,
        subscriptionId: session.subscription,
        upgradedAt: admin.firestore.FieldValue.serverTimestamp()
      });

      console.log('✅ Usuário atualizado para PRO:', userId);
    }

    // Quando assinatura é cancelada
    if (event.type === 'customer.subscription.deleted') {
      const subscription = event.data.object;
      const customerId = subscription.customer;

      // Buscar usuário pelo customerId
      const snapshot = await admin.firestore()
        .collection('users')
        .where('stripeCustomerId', '==', customerId)
        .limit(1)
        .get();

      if (!snapshot.empty) {
        const userId = snapshot.docs[0].id;
        await admin.firestore().collection('users').doc(userId).update({
          plan: 'free',
          canceledAt: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log('❌ Usuário voltou para FREE:', userId);
      }
    }

    res.json({ received: true });
  } catch (error) {
    console.error('❌ Erro no webhook:', error);
    res.status(500).send('Internal Error');
  }
});
```

4. **Deploy:**
```bash
firebase deploy --only functions
```

5. **Copiar URL da função:**
```
https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook
```

### Parte B: Configurar no Stripe

1. Acesse: https://dashboard.stripe.com/
2. **Developers** → **Webhooks**
3. Clique **+ Add endpoint**
4. Cole a URL: `https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook`
5. Selecione eventos:
   - ✅ `checkout.session.completed`
   - ✅ `customer.subscription.deleted`
6. Clique **Add endpoint**
7. ✅ PRONTO!

### Parte C: Testar

1. Stripe Dashboard → **Webhooks** → **Send test webhook**
2. Escolha evento: `checkout.session.completed`
3. Adicione no JSON:
```json
{
  "client_reference_id": "SEU_FIREBASE_UID_DE_TESTE"
}
```
4. Enviar
5. Verificar logs: `firebase functions:log`

---

## 🔴 3. LINK STRIPE PRODUÇÃO (2 minutos)

### Passo a Passo:

1. **Stripe Dashboard:**
   - Products → Create product
   - Nome: "PadariaPro - Plano PRO"
   - Preço: R$ 29,90/mês (ou o que quiser)
   - Recurring: Monthly

2. **Criar Payment Link:**
   - Payment links → New
   - Selecione o produto PRO
   - **IMPORTANTE:** Em "Collect customer information" marque "Email"
   - Copie o link gerado

3. **Atualizar código:**

Abra `index.html` e procure linha 373:

**ANTES:**
```javascript
const stripeUrl = `https://buy.stripe.com/test_00w3cvfVgbJB8hjcOqdnW01?client_reference_id=${user.uid}`;
```

**DEPOIS:**
```javascript
const stripeUrl = `https://buy.stripe.com/SEU_LINK_AQUI?client_reference_id=${user.uid}`;
```

4. ✅ PRONTO!

---

## ✅ CHECKLIST FINAL

Antes de lançar, teste:

### Teste 1: Criar Conta
- [ ] Criar conta com email real
- [ ] Login funciona
- [ ] Dados aparecem no Firebase

### Teste 2: Usar FREE
- [ ] Criar ingrediente
- [ ] Criar receita
- [ ] Calcular preço
- [ ] Limites FREE funcionam (3 receitas, etc)

### Teste 3: Upgrade PRO
- [ ] Clicar "Fazer Upgrade"
- [ ] Redireciona para Stripe
- [ ] Pagar com cartão de teste: `4242 4242 4242 4242`
- [ ] Voltar ao app
- [ ] **VERIFICAR:** Plano mudou para PRO? ✅
- [ ] Testar funcionalidades PRO (estoque, equipamentos)

### Teste 4: Webhook Funcionando
- [ ] Stripe Dashboard → Webhooks
- [ ] Ver eventos recebidos (200 OK)
- [ ] Firestore mostra `plan: 'pro'`

---

## 🚨 CARTÕES DE TESTE STRIPE

Use esses para testar:

| Cartão | Resultado |
|--------|-----------|
| `4242 4242 4242 4242` | ✅ Sucesso |
| `4000 0000 0000 0002` | ❌ Recusado |
| `4000 0000 0000 3220` | ⚠️ Requer 3D Secure |

**Data:** Qualquer data futura  
**CVV:** Qualquer 3 dígitos  
**CEP:** Qualquer

---

## 🎯 PRONTO PARA LANÇAR?

**SIM, se:**
- ✅ Firestore Rules aplicadas
- ✅ Webhook criado e testando 200 OK
- ✅ Link Stripe de produção
- ✅ Fluxo completo testado 3x

**NÃO, se:**
- ❌ Webhook retorna erro
- ❌ Plano não muda após pagamento
- ❌ Link ainda é de teste

---

## 💰 CUSTOS

**Firebase:**
- Free tier: 50k reads/day, 20k writes/day
- Suficiente para ~500 usuários ativos
- **Custo:** $0/mês

**Stripe:**
- 2.9% + R$0,39 por transação
- Assinatura R$29,90 = Você recebe R$28,60
- **Custo:** $0 (só paga quando vende)

**Netlify:**
- Free tier: 100 GB bandwidth
- **Custo:** $0/mês

**TOTAL:** R$0 até começar a vender! 🎉

---

## 📞 AJUDA RÁPIDA

**Erro comum 1:** "Firebase rules deny"
- Solução: Verificar se regras foram publicadas

**Erro comum 2:** "Webhook 500 error"
- Solução: Ver logs com `firebase functions:log`

**Erro comum 3:** "Plano não muda"
- Solução: Verificar se `client_reference_id` está correto

---

## 🚀 PRÓXIMO PASSO

**Depois de corrigir as 3 críticas:**

1. Deploy final: `git push` (Netlify atualiza automático)
2. Testar em modo incógnito
3. **LANÇAR!** 🎉
4. Monitorar: Firebase Console + Stripe Dashboard
5. Coletar feedback
6. Iterar v1.1 com melhorias

**Boa sorte! 🍀**
