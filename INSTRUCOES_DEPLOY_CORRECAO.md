# 🔧 Instruções para Corrigir e Deploy das Cloud Functions

## ✅ Problemas Corrigidos

1. **Cloud Function `createPortalLink`**: Melhorado com tratamento de erros robusto e CORS correto
2. **Nova Cloud Function `cancelSubscription`**: Criada para permitir cancelamento direto
3. **Frontend**: Atualizado com melhor tratamento de erros, logs detalhados e timeout

## 📋 Passo a Passo para Deploy

### 1️⃣ Criar arquivo .env nas Functions

No diretório `functions/`, crie um arquivo `.env` (que será ignorado pelo git):

```bash
cd functions
```

Crie o arquivo `.env` com o seguinte conteúdo:

```env
# Chave secreta da Stripe
STRIPE_SECRET_KEY=sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru

# Webhook secret (obtenha no painel da Stripe após configurar o webhook)
# STRIPE_WEBHOOK_SECRET=whsec_...
```

**⚠️ IMPORTANTE**: Se você já tem uma conta Stripe em produção, substitua a `STRIPE_SECRET_KEY` pela sua chave real (`sk_live_...`).

### 2️⃣ Instalar Dependências

```bash
cd functions
npm install
```

### 3️⃣ Configurar Variáveis de Ambiente no Firebase

As variáveis de ambiente precisam ser configuradas no Firebase Functions:

```bash
# Configure a chave da Stripe
firebase functions:config:set stripe.secret_key="sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru"

# (Opcional) Configure o webhook secret depois de criar o webhook na Stripe
# firebase functions:config:set stripe.webhook_secret="whsec_..."
```

### 4️⃣ Configurar Billing Portal na Stripe

1. Acesse o [Dashboard da Stripe](https://dashboard.stripe.com)
2. Vá em **Settings** → **Billing** → **Customer Portal**
3. Clique em **Activate test link** (ou **Activate link** em produção)
4. Configure as opções:
   - ✅ Permitir cancelamento de assinatura
   - ✅ Permitir atualização de informações de pagamento
   - ✅ Permitir visualização de faturas

### 5️⃣ Deploy das Cloud Functions

```bash
# Deploy apenas as functions
firebase deploy --only functions

# Ou deploy completo (functions + hosting)
firebase deploy
```

### 6️⃣ Verificar URLs das Functions

Após o deploy, você verá as URLs das functions no console. Elas devem ser:

```
✔  functions[createPortalLink(us-central1)]: https://us-central1-padariapro-d0759.cloudfunctions.net/createPortalLink
✔  functions[cancelSubscription(us-central1)]: https://us-central1-padariapro-d0759.cloudfunctions.net/cancelSubscription
✔  functions[stripeWebhook(us-central1)]: https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook
```

### 7️⃣ Configurar Webhook na Stripe

1. Acesse [Dashboard da Stripe](https://dashboard.stripe.com)
2. Vá em **Developers** → **Webhooks**
3. Clique em **Add endpoint**
4. URL do endpoint: `https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook`
5. Selecione os eventos:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
6. Copie o **Signing secret** (começa com `whsec_...`)
7. Configure no Firebase:
   ```bash
   firebase functions:config:set stripe.webhook_secret="whsec_SEU_SECRET_AQUI"
   ```
8. Faça deploy novamente:
   ```bash
   firebase deploy --only functions
   ```

### 8️⃣ Atualizar URL do Site no Frontend (se necessário)

Se você mudou o domínio ou URL do Netlify, atualize as URLs permitidas nas Cloud Functions.

No arquivo `functions/index.js`, linhas 125-129 e 221-225, adicione seu domínio:

```javascript
const allowedOrigins = [
    'https://padariapro.netlify.app',
    'https://SEU-NOVO-DOMINIO.com',  // Adicione aqui
    'http://localhost:5000',
    'http://localhost:8080',
    'http://127.0.0.1:5000'
];
```

### 9️⃣ Deploy do Frontend no Netlify

O Netlify já deve fazer deploy automático via GitHub. Se precisar fazer manualmente:

```bash
# Commit e push para GitHub
git add .
git commit -m "Fix: Correção botões de assinatura e portal"
git push origin main
```

O Netlify detectará automaticamente e fará o deploy.

## 🧪 Testando as Correções

### Teste do Portal de Assinatura

1. Faça login no app
2. Vá em **Perfil**
3. Se tiver assinatura PRO, clique em **Portal de Assinatura**
4. Verifique o console do navegador (F12) para logs detalhados
5. Você deve ser redirecionado para o Stripe Billing Portal

### Teste do Cancelamento

1. Faça login no app
2. Vá em **Perfil**
3. Se tiver assinatura PRO, clique em **Cancelar Assinatura**
4. Escolha **Cancelar Agora** ou **Abrir Portal Stripe**
5. Verifique o console do navegador para logs
6. A assinatura deve ser marcada para cancelamento

## 🐛 Debugging

### Se o erro persistir, verifique:

1. **Console do Navegador** (F12):
   - Procure por erros de CORS
   - Verifique se os logs `🔄`, `✅` e `❌` aparecem
   - Anote o status code da requisição

2. **Logs do Firebase**:
   ```bash
   firebase functions:log
   ```

3. **Verificar se as functions foram deployadas**:
   ```bash
   firebase functions:list
   ```

4. **Testar as functions diretamente**:
   ```bash
   # Teste local
   firebase emulators:start --only functions
   ```

5. **Verificar IAM Permissions no Firebase**:
   - Vá no [Console do Firebase](https://console.firebase.google.com)
   - Selecione seu projeto
   - Vá em **Functions**
   - Clique em cada função
   - Verifique se a permissão está configurada corretamente

### Configurar Permissões Públicas (se necessário)

Se as functions não estiverem acessíveis publicamente:

```bash
# Para cada função, execute:
gcloud functions add-iam-policy-binding createPortalLink \
  --member="allUsers" \
  --role="roles/cloudfunctions.invoker" \
  --region="us-central1"

gcloud functions add-iam-policy-binding cancelSubscription \
  --member="allUsers" \
  --role="roles/cloudfunctions.invoker" \
  --region="us-central1"

gcloud functions add-iam-policy-binding stripeWebhook \
  --member="allUsers" \
  --role="roles/cloudfunctions.invoker" \
  --region="us-central1"
```

## 📱 Domínio Personalizado (GoDaddy)

Se você quiser usar um domínio personalizado da GoDaddy:

### Opção 1: Netlify com Domínio Personalizado

1. Compre o domínio na GoDaddy
2. No Netlify, vá em **Domain Settings**
3. Clique em **Add custom domain**
4. Digite seu domínio (ex: `padariapro.com`)
5. Configure os DNS na GoDaddy:
   - Tipo: `A`
   - Nome: `@`
   - Valor: IP do Netlify (fornecido no painel)
   - Tipo: `CNAME`
   - Nome: `www`
   - Valor: `SEU-SITE.netlify.app`

### Opção 2: Firebase Hosting com Domínio Personalizado

1. No Firebase Console, vá em **Hosting**
2. Clique em **Add custom domain**
3. Siga as instruções para configurar DNS na GoDaddy
4. Deploy usando: `firebase deploy --only hosting`

## ✅ Checklist Final

- [ ] Arquivo `.env` criado em `functions/`
- [ ] Variáveis de ambiente configuradas no Firebase
- [ ] Billing Portal ativado na Stripe
- [ ] Cloud Functions deployadas
- [ ] Webhook configurado na Stripe
- [ ] Frontend deployado no Netlify
- [ ] Testado Portal de Assinatura
- [ ] Testado Cancelamento de Assinatura
- [ ] Logs no console estão limpos

## 🆘 Suporte

Se o erro persistir após seguir todos os passos:

1. Compartilhe os logs do console do navegador (F12 → Console)
2. Compartilhe os logs do Firebase: `firebase functions:log`
3. Verifique o status code do erro HTTP
4. Confirme que você seguiu todos os passos acima

## 📝 Notas Adicionais

- **Ambiente de Teste**: As chaves `sk_test_` são para testes. Use `sk_live_` em produção.
- **Segurança**: Nunca commit o arquivo `.env` no GitHub.
- **Custo**: Firebase Functions têm um limite gratuito generoso. Monitore no console.
- **Domínio**: Não é necessário comprar um novo domínio se o Netlify já funciona.

---

## 🎉 Pronto!

Após seguir estes passos, os botões de **Portal de Assinatura** e **Cancelar Assinatura** devem funcionar perfeitamente!
