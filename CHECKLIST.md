# ✅ Checklist de Implementação - Stripe Integration

Use esta lista para garantir que tudo está configurado corretamente.

## 📋 Pré-Deploy

- [ ] Firebase CLI instalado (`firebase --version`)
- [ ] Logado no Firebase (`firebase login`)
- [ ] Projeto correto selecionado (`firebase use padariapro-d0759`)
- [ ] Node.js e npm instalados (`node --version`, `npm --version`)

## 🔧 Configuração Inicial

- [ ] Dependências instaladas (`cd functions && npm install`)
- [ ] Arquivo `firebase.json` presente na raiz
- [ ] Arquivo `firestore.rules` presente na raiz
- [ ] Arquivo `firestore.indexes.json` presente na raiz
- [ ] Pasta `functions/` com `index.js` e `package.json`

## 🔐 Variáveis de Ambiente

- [ ] Chave secreta Stripe configurada:
  ```bash
  firebase functions:config:set stripe.secret_key="sk_test_..."
  ```
- [ ] Configuração verificada:
  ```bash
  firebase functions:config:get
  ```

## ☁️ Deploy

- [ ] Functions deployadas:
  ```bash
  firebase deploy --only functions
  ```
- [ ] URL da função anotada (aparece após deploy):
  ```
  https://us-central1-padariapro-d0759.cloudfunctions.net/stripeWebhook
  ```
- [ ] Firestore rules deployadas:
  ```bash
  firebase deploy --only firestore:rules
  ```
- [ ] Firestore indexes deployados:
  ```bash
  firebase deploy --only firestore:indexes
  ```

## 💳 Configuração Stripe

- [ ] Login no Dashboard Stripe: https://dashboard.stripe.com/test/webhooks
- [ ] Webhook criado com URL da Cloud Function
- [ ] Evento `checkout.session.completed` adicionado
- [ ] Eventos opcionais adicionados:
  - [ ] `customer.subscription.created`
  - [ ] `customer.subscription.updated`
  - [ ] `customer.subscription.deleted`
- [ ] Webhook ativo (status: "Enabled")
- [ ] Webhook secret copiado (opcional, para produção)

## 🔗 Payment Link Stripe

- [ ] Payment Link criado: https://buy.stripe.com/test_00w3cvfVgbJB8hjcOqdnW01
- [ ] URL de sucesso configurada: `https://padariapro.netlify.app/?success=true`
- [ ] URL de cancelamento configurada: `https://padariapro.netlify.app/`
- [ ] Preço configurado: R$ 9,99 (ou valor desejado)

## 🌐 Frontend (já implementado)

- [ ] Função `openStripeCheckout()` corrigida (client_reference_id sem UID fixo)
- [ ] Função `checkStripeReturn()` implementada
- [ ] Função `startProVerification()` implementada
- [ ] Listener do Firestore configurado
- [ ] Código duplicado removido
- [ ] Deploy no Netlify atualizado (push para GitHub)

## 🧪 Teste End-to-End

### Preparação
- [ ] Logs da Cloud Function abertos:
  ```bash
  firebase functions:log --only stripeWebhook --tail
  ```
- [ ] Console do navegador aberto (F12)

### Execução
1. - [ ] Acesse https://padariapro.netlify.app/
2. - [ ] Faça login com usuário de teste
3. - [ ] Verifique no console: "✅ User autenticado: [UID]"
4. - [ ] Clique em "Assinar PRO"
5. - [ ] Verifique redirecionamento para Stripe
6. - [ ] Verifique URL contém `client_reference_id=[UID]`
7. - [ ] Use cartão de teste: `4242 4242 4242 4242`
8. - [ ] Data: qualquer data futura
9. - [ ] CVV: qualquer 3 dígitos
10. - [ ] Complete o pagamento
11. - [ ] Aguarde redirecionamento automático
12. - [ ] Verifique URL contém `?success=true`
13. - [ ] Verifique console: "🔄 Iniciando verificação de PRO"
14. - [ ] Aguarde mensagem: "🎉 Bem-vindo ao PRO!"
15. - [ ] Verifique que recursos PRO estão desbloqueados

### Verificação Backend
- [ ] Logs da Cloud Function mostram:
  - [ ] "📥 Webhook recebido: checkout.session.completed"
  - [ ] "✅ Checkout completado"
  - [ ] "✅ Usuário [UID] atualizado para PRO com sucesso"
- [ ] Stripe Dashboard mostra:
  - [ ] Webhook disparado com status 200 OK
  - [ ] Pagamento marcado como "Succeeded"
- [ ] Firestore Database mostra:
  - [ ] Documento `users/[UID]` existe
  - [ ] Campo `plan: "pro"`
  - [ ] Campo `upgradedAt` com timestamp

## 🔒 Segurança

- [ ] Regras do Firestore impedem alteração manual do campo `plan`
- [ ] Teste: tentar alterar `plan` manualmente pelo console → deve ser bloqueado
- [ ] Chaves secretas não estão no código-fonte
- [ ] Arquivo `.env` não está commitado no Git
- [ ] `.gitignore` configurado na pasta `functions/`

## 📊 Monitoramento Pós-Deploy

- [ ] Webhooks na Stripe estão sendo entregues (status 200)
- [ ] Nenhum erro 500 nos logs da Cloud Function
- [ ] Usuários conseguem fazer upgrade sem problemas
- [ ] Plano é persistido corretamente no Firestore

## 🚀 Produção (quando estiver pronto)

- [ ] Criar novo Payment Link de produção na Stripe
- [ ] Substituir chave `sk_test_` por `sk_live_` nas configurações
- [ ] Configurar webhook secret para validação:
  ```bash
  firebase functions:config:set stripe.webhook_secret="whsec_..."
  ```
- [ ] Atualizar URL do Payment Link no código (se necessário)
- [ ] Testar fluxo completo em produção com cartão real
- [ ] Monitorar logs nas primeiras transações

## 📝 Documentação

- [ ] README atualizado com informações do projeto
- [ ] QUICKSTART.md explicando setup rápido
- [ ] STRIPE_SETUP.md com setup detalhado
- [ ] FLOW_DIAGRAM.md com diagrama do fluxo
- [ ] COMMANDS.md com comandos úteis
- [ ] CHECKLIST.md (este arquivo) para referência

## 🎯 Critérios de Sucesso

✅ Usuário consegue:
- Fazer login no app
- Clicar em "Assinar PRO"
- Ser redirecionado para Stripe
- Pagar com cartão de teste
- Retornar ao app automaticamente
- Ver mensagem de sucesso
- Ter plano atualizado para PRO
- Acessar recursos PRO sem limites

✅ Backend:
- Webhook recebe eventos da Stripe
- Cloud Function processa sem erros
- Firestore é atualizado corretamente
- Logs mostram todas as etapas

✅ Segurança:
- Regras do Firestore protegem dados
- Chaves não expostas no código
- Validação de webhook ativa (produção)

---

## 🎉 Parabéns!

Se você marcou todos os itens acima, sua integração Stripe está completa e funcionando! 🚀

Próximos passos opcionais:
- [ ] Implementar portal de gerenciamento de assinatura
- [ ] Adicionar analytics de conversão
- [ ] Implementar emails de confirmação
- [ ] Criar planos adicionais (Business, Enterprise, etc.)
