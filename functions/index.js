const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({ origin: true });
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY || 'sk_test_51SONg9I9XxzZxv0BVdAvdTU3kvIA7h136RqkusFwqAiWPUiHggyFcwTFkrB1IQ6xZ5ZT5A3GG36M0mc2yKxmgtoo00rWDpSeru');

// IMPORTANTE: Configure esta variável de ambiente (Environment Variable)
// com o segredo do webhook que você pegou no painel Stripe (whsec_...)
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

admin.initializeApp();
const db = admin.firestore();

/**
 * Webhook da Stripe para processar eventos de pagamento.
 * * Configuração:
 * 1. Definimos `options.rawBody` para garantir que o corpo bruto 
 * da requisição esteja disponível para a verificação de assinatura.
 * 2. Em produção (Cloud Functions), a função deve ser publicamente invocável 
 * (Permissão 'allUsers' com o papel 'Cloud Functions Invoker').
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
    // Apenas aceita POST
    if (req.method !== 'POST') {
        return res.status(405).send('Method Not Allowed');
    }

    const sig = req.headers['stripe-signature'];
    let event;

    // --- 1. VERIFICAÇÃO DE ASSINATURA (CRÍTICO PARA SEGURANÇA) ---
    // A Stripe precisa do corpo bruto (`req.rawBody`) para verificar a assinatura.
    try {
        if (!webhookSecret) {
            // Em ambiente de desenvolvimento ou se o segredo não estiver configurado
            console.warn('⚠️ STRIPE_WEBHOOK_SECRET não configurado. Pulando validação de assinatura.');
            event = JSON.parse(req.rawBody.toString('utf8')); // Tentativa de parse manual
        } else {
            // Verifica se o evento é legítimo (segurança)
            event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
        }
    } catch (err) {
        console.error(`❌ Erro na validação da assinatura: ${err.message}`);
        // Retorna 400 Bad Request se a assinatura falhar
        return res.status(400).send(`Webhook Error: ${err.message}`);
    }

    console.log(`📥 Webhook recebido: ${event.type}`);

    // --- 2. PROCESSAMENTO DO EVENTO ---
    const eventData = event.data.object;

    if (event.type === 'checkout.session.completed') {
        const session = eventData;
        const uid = session.client_reference_id;

        if (!uid) {
            console.error('❌ client_reference_id (UID) não encontrado na session.');
            return res.status(400).send('Missing client_reference_id');
        }

        if (session.payment_status === 'paid') {
            try {
                await db.collection('users').doc(uid).set({
                    plan: 'pro',
                    stripeCustomerId: session.customer,
                    stripeSessionId: session.id,
                    upgradedAt: admin.firestore.FieldValue.serverTimestamp(),
                    subscriptionStatus: 'active'
                }, { merge: true });

                console.log(`✅ Usuário ${uid} atualizado para PRO com sucesso`);
            } catch (error) {
                console.error('❌ Erro ao atualizar Firestore:', error);
                return res.status(500).send('Error updating database');
            }
        } else {
            console.warn('⚠️ Pagamento não confirmado:', session.payment_status);
        }
    } 
    // --- Lógica para customer.subscription.created/updated/deleted... ---
    else if (event.type.startsWith('customer.subscription.')) {
        // Você já tinha essa lógica, mas ela usa `stripeCustomerId`
        const subscription = eventData;
        const customerId = subscription.customer;

        try {
            const usersSnapshot = await db.collection('users')
                .where('stripeCustomerId', '==', customerId)
                .limit(1)
                .get();

            if (!usersSnapshot.empty) {
                const userDoc = usersSnapshot.docs[0];
                const newPlan = subscription.status === 'active' ? 'pro' : 'free';
                
                await userDoc.ref.update({
                    subscriptionStatus: subscription.status,
                    subscriptionId: subscription.id,
                    plan: newPlan,
                    lastUpdated: admin.firestore.FieldValue.serverTimestamp()
                });
                
                console.log(`✅ Assinatura atualizada para usuário ${userDoc.id}. Plano: ${newPlan}`);
            }
        } catch (error) {
            console.error('❌ Erro ao processar assinatura:', error);
        }
    }
    // Para outros eventos
    else {
        console.log(`ℹ️ Evento não tratado: ${event.type}`);
    }


    // 3. Retorna 200 para a Stripe avisando que o evento foi recebido
    res.status(200).json({ received: true });
});

/**
 * Função auxiliar para criar portal de gerenciamento de assinatura
 * Versão onRequest com CORS manual (mais compatível)
 */
exports.createPortalLink = functions.https.onRequest(async (req, res) => {
    // CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.set('Access-Control-Max-Age', '3600');

    // Handle preflight
    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }

    // Só aceita POST
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
        // Pega o token de autenticação
        const authHeader = req.headers.authorization;
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({ error: 'Não autenticado' });
        }

        const idToken = authHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        const uid = decodedToken.uid;

        console.log('📋 Portal solicitado para UID:', uid);

        const userDoc = await db.collection('users').doc(uid).get();
        const userData = userDoc.data();

        if (!userData || !userData.stripeCustomerId) {
            console.error('❌ Cliente Stripe não encontrado para UID:', uid);
            return res.status(404).json({ error: 'Cliente Stripe não encontrado' });
        }

        console.log('✅ Criando portal para customer:', userData.stripeCustomerId);

        const returnUrl = req.body.returnUrl || 'https://padariapro.netlify.app/';
        const session = await stripe.billingPortal.sessions.create({
            customer: userData.stripeCustomerId,
            return_url: returnUrl,
        });

        console.log('✅ Portal URL criada:', session.url);
        return res.status(200).json({ url: session.url });
    } catch (error) {
        console.error('❌ Erro ao criar portal link:', error);
        return res.status(500).json({ error: error.message });
    }
});
