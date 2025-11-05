# 🛠️ Comandos Úteis - PadariaPro

## 🚀 Deploy

### Deploy completo
```bash
firebase deploy
```

### Deploy apenas Functions
```bash
firebase deploy --only functions
```

### Deploy apenas Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy apenas Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

## 🔐 Configuração

### Ver todas as configurações
```bash
firebase functions:config:get
```

### Configurar chave Stripe (teste)
```bash
firebase functions:config:set stripe.secret_key="sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru"
```

### Configurar chave Stripe (produção)
```bash
firebase functions:config:set stripe.secret_key="sk_live_XXXXXXXXXXXXXXX"
```

### Configurar webhook secret (opcional)
```bash
firebase functions:config:set stripe.webhook_secret="whsec_XXXXXXXXXXXXXXX"
```

### Remover uma configuração
```bash
firebase functions:config:unset stripe.webhook_secret
```

## 📊 Monitoramento

### Ver logs em tempo real
```bash
firebase functions:log --tail
```

### Ver logs apenas do webhook
```bash
firebase functions:log --only stripeWebhook --tail
```

### Ver logs das últimas 2 horas
```bash
firebase functions:log --since 2h
```

### Ver logs com filtro
```bash
firebase functions:log | grep "PRO ATIVADO"
```

## 🧪 Testes Locais

### Iniciar emuladores
```bash
firebase emulators:start
```

### Iniciar apenas Functions emulator
```bash
firebase emulators:start --only functions
```

### Testar função localmente
```bash
# A função estará em:
# http://localhost:5001/padariapro-d0759/us-central1/stripeWebhook
```

## 🗄️ Firestore

### Abrir console do Firestore
```bash
firebase firestore:indexes
```

### Backup do Firestore
```bash
# Via console web:
# https://console.firebase.google.com/project/padariapro-d0759/firestore
```

## 🔄 Git & Deploy

### Commit e push para GitHub
```bash
git add .
git commit -m "Integração Stripe concluída"
git push origin main
```

### Deploy automático Netlify
O Netlify fará deploy automático após push para GitHub.
Apenas o frontend (HTML) será atualizado.

### Deploy manual das Functions
```bash
firebase deploy --only functions
```

## 🛡️ Segurança

### Verificar regras do Firestore
```bash
firebase firestore:rules:list
```

### Testar regras localmente
```bash
firebase emulators:start --only firestore
# Acesse: http://localhost:4000/firestore
```

## 📦 Dependências

### Instalar dependências (Functions)
```bash
cd functions
npm install
cd ..
```

### Atualizar dependências
```bash
cd functions
npm update
cd ..
```

### Verificar vulnerabilidades
```bash
cd functions
npm audit
npm audit fix
cd ..
```

## 🔍 Debug

### Verificar se Firebase está inicializado
```bash
firebase projects:list
```

### Verificar projeto atual
```bash
firebase use
```

### Trocar de projeto
```bash
firebase use padariapro-d0759
```

### Ver informações do projeto
```bash
firebase apps:list
```

## 🌐 URLs Importantes

### Frontend (Netlify)
```
https://padariapro.netlify.app/
```

### Cloud Function (Webhook)
```
https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook
```

### Firebase Console
```
https://console.firebase.google.com/project/padariapro-d0759
```

### Stripe Dashboard (Teste)
```
https://dashboard.stripe.com/test/webhooks
```

### Stripe Dashboard (Produção)
```
https://dashboard.stripe.com/webhooks
```

## 🎯 Fluxo de Deploy Completo

```bash
# 1. Instalar dependências
cd functions && npm install && cd ..

# 2. Configurar Stripe
firebase functions:config:set stripe.secret_key="sk_test_..."

# 3. Deploy de tudo
firebase deploy

# 4. Verificar logs
firebase functions:log --tail

# 5. Testar pagamento
# Acesse o app e teste
```

## 🆘 Troubleshooting

### Erro: "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

### Erro: "Not logged in"
```bash
firebase login
```

### Erro: "Permission denied"
```bash
firebase login --reauth
```

### Erro: "Function not found"
```bash
firebase deploy --only functions --force
```

### Limpar cache e reinstalar
```bash
cd functions
rm -rf node_modules package-lock.json
npm install
cd ..
firebase deploy --only functions
```

## 📝 Logs Úteis

### Buscar por UID específico
```bash
firebase functions:log | grep "abc123xyz"
```

### Buscar erros
```bash
firebase functions:log | grep "Error"
```

### Buscar upgrades bem-sucedidos
```bash
firebase functions:log | grep "PRO ATIVADO"
```

## 🔄 Rollback

### Ver versões anteriores
```bash
firebase functions:list
```

### Rollback para versão anterior (não recomendado)
- Melhor: fazer novo deploy com código corrigido
```

## 💡 Dicas

- Use `--only` para deploy mais rápido de componentes específicos
- Sempre teste localmente com emulators antes de fazer deploy
- Mantenha logs abertos durante testes: `--tail`
- Use filtros nos logs para encontrar informações específicas
- Faça backup do Firestore antes de grandes mudanças
