# ✅ Correção dos Botões de Assinatura - PadariaPro

## 🎯 Problema Resolvido

Os botões **"Portal de Assinatura"** e **"Cancelar Assinatura"** estavam causando erro interno. Todas as correções foram implementadas!

## 📝 O Que Foi Corrigido

### 1. **Cloud Functions** (`functions/index.js`)
- ✅ Melhorado `createPortalLink` com:
  - Tratamento robusto de erros
  - CORS configurado corretamente para Netlify
  - Validação adequada de autenticação
  - Logs detalhados para debugging
  
- ✅ Criado `cancelSubscription` (nova função):
  - Permite cancelar assinatura diretamente do app
  - Marca assinatura para cancelamento no fim do período
  - Atualiza Firestore automaticamente

### 2. **Frontend** (`index.html`)
- ✅ Função `manageSubscription` melhorada:
  - Logs detalhados em cada etapa
  - Timeout de 30 segundos
  - Mensagens de erro mais claras
  - Validação de resposta robusta

- ✅ Função `cancelSubscription` atualizada:
  - Opção de cancelar diretamente ou via portal Stripe
  - Nova função `confirmCancelSubscription` implementada
  - Feedback visual durante o processo

### 3. **Documentação**
- ✅ `INSTRUCOES_DEPLOY_CORRECAO.md` - Guia completo passo a passo
- ✅ `deploy-functions.ps1` - Script automatizado para deploy (Windows)

## 🚀 Como Aplicar a Correção

### Opção 1: Script Automatizado (Recomendado para Windows)

```powershell
# Execute o script na raiz do projeto
.\deploy-functions.ps1
```

O script vai:
1. Verificar se Firebase CLI está instalado
2. Criar arquivo `.env` se não existir
3. Instalar dependências
4. Configurar variáveis de ambiente (opcional)
5. Fazer deploy das Cloud Functions

### Opção 2: Manual

```bash
# 1. Criar arquivo .env em functions/
cd functions
# Crie o arquivo .env com sua chave da Stripe

# 2. Instalar dependências
npm install

# 3. Configurar variáveis no Firebase
firebase functions:config:set stripe.secret_key="SUA_CHAVE_AQUI"

# 4. Deploy
cd ..
firebase deploy --only functions
```

## 📋 Checklist Pós-Deploy

Após fazer o deploy, você DEVE configurar:

### ✅ 1. Billing Portal na Stripe
1. Acesse: https://dashboard.stripe.com/settings/billing/portal
2. Clique em **"Activate test link"**
3. Ative as opções:
   - Cancelar assinatura
   - Atualizar forma de pagamento
   - Ver faturas

### ✅ 2. Webhook na Stripe
1. Acesse: https://dashboard.stripe.com/webhooks
2. Adicione endpoint:
   ```
   https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook
   ```
3. Selecione eventos:
   - `checkout.session.completed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
4. Copie o **Signing secret** (whsec_...)
5. Configure no Firebase:
   ```bash
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   firebase deploy --only functions
   ```

## 🧪 Testando

### Teste 1: Portal de Assinatura
1. Faça login no app
2. Vá em **Perfil** 
3. Clique em **"Portal de Assinatura"**
4. Abra o Console (F12) e observe os logs:
   ```
   🔄 Iniciando manageSubscription...
   ✅ Usuário autenticado: [uid]
   ✅ Cliente Stripe encontrado: [customerId]
   ✅ Token obtido
   🔄 Chamando Cloud Function createPortalLink...
   ✅ Resposta recebida, status: 200
   📦 Resultado: {url: "...", success: true}
   ✅ Redirecionando para: [stripe portal url]
   ```
5. Você deve ser redirecionado para o Stripe Billing Portal

### Teste 2: Cancelar Assinatura
1. Faça login no app
2. Vá em **Perfil**
3. Clique em **"Cancelar Assinatura"**
4. Escolha uma opção:
   - **"Abrir Portal Stripe"**: Redireciona para portal (mesmo que Teste 1)
   - **"Cancelar Agora"**: Cancela diretamente via API
5. Observe os logs no Console
6. Você deve ver mensagem de sucesso

## 🐛 Se Ainda Houver Erro

### 1. Verifique Logs do Console (F12)
Procure por:
- ❌ Erros em vermelho
- Status code da requisição (deve ser 200)
- Mensagens de erro específicas

### 2. Verifique Logs do Firebase
```bash
firebase functions:log
```

### 3. Verifique se Functions Foram Deployadas
```bash
firebase functions:list
```

Você deve ver:
- `createPortalLink`
- `cancelSubscription`
- `stripeWebhook`

### 4. Teste Functions Localmente (Opcional)
```bash
firebase emulators:start --only functions
```

## 📊 Alterações nos Arquivos

| Arquivo | Status | Descrição |
|---------|--------|-----------|
| `functions/index.js` | ✏️ Modificado | Melhorias em `createPortalLink` e nova função `cancelSubscription` |
| `index.html` | ✏️ Modificado | Melhorias em `manageSubscription` e `cancelSubscription` |
| `INSTRUCOES_DEPLOY_CORRECAO.md` | ➕ Novo | Guia completo de correção e deploy |
| `deploy-functions.ps1` | ➕ Novo | Script automatizado para Windows |
| `CORRECAO_ASSINATURAS_README.md` | ➕ Novo | Este arquivo (resumo) |

## 🌐 Sobre Domínio Personalizado

### Você NÃO precisa comprar um novo domínio!

Seu site já funciona no Netlify. Um domínio personalizado é **opcional** e só muda a URL de:
- `https://padariapro.netlify.app` → `https://seudominio.com`

### Se Quiser Domínio Personalizado:

#### Via Netlify (Mais Fácil)
1. Compre domínio na GoDaddy
2. No Netlify: **Domain Settings** → **Add custom domain**
3. Configure DNS conforme instruções do Netlify
4. Certificado SSL é automático

#### Via Firebase Hosting
1. Compre domínio na GoDaddy
2. No Firebase Console: **Hosting** → **Add custom domain**
3. Configure DNS na GoDaddy
4. Faça deploy: `firebase deploy --only hosting`

## ⚠️ Importante

### Chaves da Stripe
- **Teste**: Use `sk_test_...` (atual)
- **Produção**: Substitua por `sk_live_...` quando for ao vivo

### Segurança
- ❌ NUNCA commit o arquivo `.env` no GitHub
- ✅ Ele já está no `.gitignore`

### Custo Firebase
- Functions gratuitas até 2 milhões de invocações/mês
- Monitore no console: https://console.firebase.google.com

## 📞 Suporte

Se após seguir todos os passos o erro persistir:

1. Verifique cada item do checklist acima
2. Compartilhe os logs do console (F12)
3. Compartilhe os logs do Firebase: `firebase functions:log`
4. Confirme que o Billing Portal está ativo na Stripe

---

## 🎉 Tudo Pronto!

Após fazer o deploy e configurar o Billing Portal + Webhook, seus botões devem funcionar perfeitamente!

**Tempo estimado**: 15-30 minutos para deploy completo

**Próximo commit**: 
```bash
git add .
git commit -m "fix: corrigir botões de portal e cancelar assinatura"
git push origin main
```

O Netlify fará deploy automático do frontend atualizado!
