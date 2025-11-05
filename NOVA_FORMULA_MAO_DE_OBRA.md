# ✅ NOVA FÓRMULA DE MÃO DE OBRA (v1.3)

**Data:** 02/11/2025  
**Mudança:** Cálculo mais realista baseado em tempo real de trabalho

---

## ❌ **FÓRMULA ANTIGA (v1.2):**

```javascript
labor = hourlyRate × baseTimePerUnit × totalUnits
      = R$25/h × 0.08h/un × 2 un
      = R$4,00
Mínimo: R$5,00
```

**Problema:**
- Calculava **por unidade** (5 min × 2 massas = 10 min)
- Assumia trabalho individual para cada massa
- **Irreal:** Você faz 2 massas juntas em ~8 min, não 10!

---

## ✅ **FÓRMULA NOVA (v1.3):**

```javascript
// 1. Calcular tempo ativo de preparação (30% do tempo total)
prepTimeMin = max(5, (bakeMin + mixMin) × 0.3)

// 2. Converter para horas
batchTimeHours = prepTimeMin / 60

// 3. Calcular custo
labor = hourlyRate × batchTimeHours

// 4. Ajustar por volume
if (unidades > 10 e <= 30)  labor × 1.1  (+10%)
if (unidades > 30 e <= 50)  labor × 1.2  (+20%)
if (unidades > 50)          labor × 1.3  (+30%)

// 5. Aplicar limites
labor = max(R$2, min(R$60, labor))
```

---

## 📊 **EXEMPLO: 2 Massas de Pizza**

**Dados da receita:**
- Tempo forno: 40 min
- Tempo batedeira: 15 min
- Total produção: 55 min
- Rende: 2 unidades

**Cálculo:**
```
1. Tempo ativo:
   prepTimeMin = max(5, 55 × 0.3)
   prepTimeMin = max(5, 16.5)
   prepTimeMin = 16.5 minutos

2. Horas:
   batchTimeHours = 16.5 / 60
   batchTimeHours = 0.275 horas

3. Custo base:
   labor = 25 × 0.275
   labor = R$6,88

4. Ajuste volume (2 unidades < 10):
   labor = R$6,88 (sem ajuste)

5. Limites (R$2 a R$60):
   labor = R$6,88 ✅
```

**Resultado:** **R$6,88** (não R$5,00)

---

## 🔍 **POR QUE 30% DO TEMPO TOTAL?**

**Tempo total de produção:**
- Forno: 40 min
- Batedeira: 15 min
- **Total:** 55 min

**Desses 55 minutos, você trabalha ativamente:**
- Pesar ingredientes: 3 min
- Misturar: 5 min (batedeira faz sozinha depois)
- Moldar massas: 5 min
- Colocar no forno: 2 min
- Tirar do forno: 1 min
- **Total ativo:** ~16 min

**16 min / 55 min = 29% ≈ 30%** ✅

O resto do tempo (forno assando, massa crescendo) você faz outras coisas!

---

## 📊 **COMPARAÇÃO: Antes vs Depois**

| Receita | Unidades | V1.2 (ANTIGA) | V1.3 (NOVA) | Diferença |
|---------|----------|---------------|-------------|-----------|
| **2 Massas Pizza** | 2 | R$5,00 | R$6,88 | +38% |
| **10 Pães** | 10 | R$20,00 | R$10,31 | -48% 🎉 |
| **50 Bolos** | 50 | R$60,00 (max) | R$25,74 | -57% 🎉 |
| **100 Biscoitos** | 100 | R$60,00 (max) | R$33,48 | -44% 🎉 |

**Vantagens:**
- ✅ Lotes pequenos: +R$1-2 (mais realista)
- ✅ Lotes grandes: -50% (economia de escala correta!)
- ✅ Baseado em tempo REAL de trabalho

---

## 🎯 **ECONOMIA DE ESCALA AJUSTADA**

### **Antiga (ERRADA):**
```
10-20 unidades:  -0%
20-50 unidades:  -15%
50+ unidades:    -30%
```
**Problema:** Desconto por volume, mas já estava baixo demais!

### **Nova (CORRETA):**
```
1-10 unidades:   +0%  (normal)
10-30 unidades:  +10% (mais trabalho)
30-50 unidades:  +20% (muito trabalho)
50+ unidades:    +30% (industrial)
```
**Por quê?** Lotes grandes exigem mais atenção, coordenação, embalagem!

---

## 📝 **COMO AJUSTAR (PRO):**

**Se a mão de obra ainda não está ideal:**

1. **Valor/hora muito alto?**
   - Vá em **Perfil** → **Mão de Obra**
   - Reduza de R$25/h para R$15-20/h

2. **Tempo de receita errado?**
   - Edite a receita
   - Ajuste tempo de forno/batedeira
   - Exemplo: 40 min forno → 30 min

3. **Override manual (PRO):**
   - Na calculadora, clique "Ver detalhamento"
   - Campo "Ajustar Mão de Obra"
   - Digite valor desejado (ex: R$3,00)

---

## 🔧 **VALORES PADRÃO ATUALIZADOS:**

| Parâmetro | Antigo | Novo |
|-----------|--------|------|
| **Mínimo** | R$5,00 | R$2,00 |
| **Máximo** | R$60,00 | R$60,00 |
| **Valor/hora** | R$25,00 | R$25,00 |
| **Base tempo/un** | 0.08h (~5min) | *Removido* |
| **% Tempo ativo** | N/A | 30% |

---

## 📊 **TESTE AGORA:**

### **Sua Receita (2 Massas):**

**Se cadastrou:**
- Tempo forno: 40 min
- Tempo batedeira: 15 min

**Resultado:**
```
prepTime = (40 + 15) × 0.3 = 16.5 min
labor = (16.5/60) × 25 = R$6,88
```

**Se NÃO cadastrou tempo:**
```
prepTime = 5 min (mínimo)
labor = (5/60) × 25 = R$2,08
Mínimo R$2,00
```

---

## 💡 **DICA PRO:**

**Para massas de pizza rápidas:**

1. Cadastre tempo REAL:
   - Forno: 20-30 min (massa fina)
   - Batedeira: 10 min (misturar)
   - Total: 30-40 min

2. Resultado:
   ```
   prepTime = 35 × 0.3 = 10.5 min
   labor = (10.5/60) × 25 = R$4,38
   ```
   **Muito mais realista!** ✅

---

## 🎯 **RESUMO:**

**ANTES (v1.2):**
- ❌ R$5,00 fixo para lotes pequenos
- ❌ Baseado em "tempo por unidade" irreal
- ❌ Economia de escala invertida

**AGORA (v1.3):**
- ✅ R$2-8 para lotes pequenos (realista!)
- ✅ Baseado em tempo REAL da receita
- ✅ Mais caro em lotes grandes (correto!)

**Sua receita:** R$6,88 (se cadastrou tempos)  
**Competitivo:** R$4-8 é normal para artesanal!

---

**Atualizado em:** 02/11/2025  
**Versão:** 1.3 - Cálculo Realista
