// Código temporário para adicionar controle de estoque na página de perfil
// Este código será integrado diretamente no index.html

// Adicionar ao final da função profile(), logo após o código do mixer:

// Adicionar card de controle de estoque (PRO only)
if(isPro){
  const useStockControl=App.state.settings?.useStockControl??false;
  const actionsCard=document.querySelector('.card:has(>b)');
  if(actionsCard && actionsCard.textContent.includes('Ações')){
    const stockCard=document.createElement('div');
    stockCard.className='card';
    stockCard.innerHTML=`<b>📦 Controle de Estoque ${!isPro?'<span class="chip">💎 PRO</span>':''}</b>
      <div class='grid'>
        <label class='row' style='gap:8px;justify-content:flex-start;'>
          <input type='checkbox' id='use_stock_control' ${useStockControl?'checked':''} onchange='Views.profile_toggle_stock_control()'/>
          <span>Ativar controle de estoque</span>
        </label>
        <span class='hint'>Quando ativado, o sistema validará se há estoque suficiente antes de calcular preços. Você poderá gerenciar o estoque de cada ingrediente.</span>
      </div>`;
    actionsCard.before(stockCard);
  }
}
