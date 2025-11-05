# ✅ QUANTIDADE DE EMBALAGEM POR RECEITA

**Data:** 02/11/2025  
**Mudança:** Campo para definir QUANTAS embalagens a receita usa

---

## ❌ **PROBLEMA ANTERIOR:**

```javascript
// Sistema assumia: 1 embalagem por unidade produzida
Receita: 2 massas de pizza
Embalagem cadastrada: Caixa R$100 / 50 un = R$2,00/caixa

Cálculo ERRADO:
2 massas × R$2,00 = R$4,00 ❌

// Problema: As 2 massas vão na MESMA caixa!
```

---

## ✅ **SOLUÇÃO:**

Agora você define **QUANTAS embalagens** usa naquela receita:

```javascript
Receita: 2 massas de pizza
Embalagem: Caixa R$100 / 50 un = R$2,00/caixa
Qtd de Embalagem: 1 caixa ← NOVO CAMPO!

Cálculo CORRETO:
1 caixa × R$2,00 = R$2,00 ✅
```

---

## 📋 **COMO USAR:**

### **1. Ao Criar/Editar Receita:**

```
Nome: Pizza Família
Rendimento: 2 unidades

Embalagem: Caixa 35cm
Qtd de Embalagem: 1    ← NOVO CAMPO!
```

**Interpretação:**  
"Esta receita rende 2 pizzas e usa 1 caixa"

---

### **2. Exemplos Práticos:**

#### **Exemplo 1: 2 Massas em 1 Caixa**
```
Receita: 2 massas
Embalagem: Caixa R$2,00
Qtd: 1
─────────────
Custo: 1 × R$2,00 = R$2,00 ✅
```

#### **Exemplo 2: 10 Pães em 2 Sacos**
```
Receita: 10 pães
Embalagem: Saco R$0,30
Qtd: 2 (5 pães por saco)
─────────────
Custo: 2 × R$0,30 = R$0,60 ✅
```

#### **Exemplo 3: 50 Biscoitos em 1 Pote**
```
Receita: 50 biscoitos
Embalagem: Pote R$3,00
Qtd: 1
─────────────
Custo: 1 × R$3,00 = R$3,00 ✅
```

#### **Exemplo 4: 100 Bolos Individuais**
```
Receita: 100 bolos
Embalagem: Caixinha R$0,50
Qtd: 100 (1 por bolo)
─────────────
Custo: 100 × R$0,50 = R$50,00 ✅
```

---

## 🔄 **COMO FUNCIONA COM MULTIPLICADOR:**

Se você usa o multiplicador na calculadora:

```
Receita: 2 massas
Qtd Embalagem: 1
Multiplicador: 3x (fazer 6 massas)

Cálculo:
1 embalagem × 3 lotes = 3 embalagens
3 × R$2,00 = R$6,00 ✅
```

**Lógica:**
```javascript
packageQtyUsed = (r.packageQty || 1) × multiplicador
```

---

## 📊 **COMPARAÇÃO: Antes vs Depois**

### **Sua Receita (2 Massas):**

| Item | ANTES | DEPOIS | Economia |
|------|-------|--------|----------|
| Embalagem | R$4,00 | R$2,00 | -50% ✅ |
| Total | R$16,50 | R$14,50 | R$2,00 |
| Por massa | R$8,25 | R$7,25 | R$1,00 |

**Agora competitivo!** 🎉

---

## 🎯 **RECEITAS JÁ EXISTENTES:**

**Receitas antigas (sem packageQty):**
```javascript
// Sistema assume: 1 embalagem
packageQty = 1 (padrão)
```

**Você precisa:**
1. Editar cada receita
2. Definir quantidade correta
3. Salvar

**Dica:** Comece pelas receitas mais usadas!

---

## 💡 **DICAS PRO:**

### **Dica 1: Embalagens Reutilizáveis**
```
Receita: Bolo em forma
Embalagem: Não
Qtd: 0

Custo embalagem: R$0,00 ✅
```

### **Dica 2: Embalagem + Tampa**
```
Cadastre 2 embalagens:
- Caixa: R$2,00
- Tampa: R$0,50

Na receita:
Embalagem: Caixa
Qtd: 1
+ Tampa (usar custo fixo: R$0,50)
```

### **Dica 3: Atacado (muitas unidades)**
```
Receita: 100 pães
Embalagem: Caixa grande R$5,00
Qtd: 2 (50 pães por caixa)

Custo: 2 × R$5,00 = R$10,00
Por pão: R$10,00 / 100 = R$0,10 ✅
```

---

## 🔧 **VALORES PADRÃO:**

| Campo | Valor Padrão | Mínimo |
|-------|--------------|--------|
| **Qtd de Embalagem** | 1 | 0 |

**Se deixar vazio:** Assume 1 embalagem

---

## 📝 **FÓRMULA COMPLETA:**

```javascript
// 1. Embalagem cadastrada
Caixa: R$100 para 50 unidades
Preço/unidade: R$100 / 50 = R$2,00

// 2. Receita
Rende: 2 massas
Usa: 1 caixa (packageQty)
Multiplicador: 1x

// 3. Cálculo
packageQtyUsed = 1 × 1 = 1 caixa
Custo = 1 × R$2,00 = R$2,00

// 4. Com multiplicador (ex: 5x)
packageQtyUsed = 1 × 5 = 5 caixas
Custo = 5 × R$2,00 = R$10,00
(para 10 massas total)
```

---

## ✅ **EXEMPLO COMPLETO: SUAS 2 MASSAS**

### **Cadastros:**
```
Embalagem: Caixa 35cm
Preço: R$100
Quantidade: 50 unidades
───────────────────────
Por caixa: R$2,00
```

### **Receita:**
```
Nome: Pizza Família
Rendimento: 2 massas
Embalagem: Caixa 35cm
Qtd Embalagem: 1      ← AJUSTE AQUI!

Ingredientes:
- 300g farinha: R$1,50
- 15g açúcar: R$0,08
- 5g sal: R$0,03
- 5g fermento: R$1,00
```

### **Calculadora:**
```
Ingredientes:  R$2,61
Embalagem:     R$2,00  ← CORRIGIDO!
Energia:       R$1,01
Mão de Obra:   R$3,00  ← AJUSTADO!
──────────────────────
Subtotal:      R$8,62

Margem 30%:    + R$3,69
──────────────────────
TOTAL:         R$12,31 (2 massas)
Por massa:     R$6,16  ✅
```

**Competitivo com artesanais!** 🎉

---

## 🎯 **RESUMO:**

✅ **Campo "Qtd de Embalagem" adicionado**  
✅ **Sistema usa quantidade REAL da receita**  
✅ **Não assume mais 1 embalagem por unidade**  
✅ **Funciona com multiplicador**  
✅ **Receitas antigas assumem 1 (padrão)**

**Edite suas receitas e ajuste as quantidades!**

---

**Implementado em:** 02/11/2025  
**Versão:** 1.3
