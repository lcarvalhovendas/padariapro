# Script para adicionar seção de equipamentos personalizados no Perfil
$content = Get-Content 'index.html' -Raw -Encoding UTF8

# Localiza e substitui a parte específica
$old = "<div class='card'><b>Ações</b><div class='grid cols-2'><button class='btn secondary' onclick='Views.profile_export()'>Exportar Dados</button><button class='btn secondary' onclick='Views.profile_backup()'>Backup Completo</button></div></div></div>"

$new = @"
<div class='card' id='custom_eq_section' style='display:none;'><div class='row' style='justify-content:space-between'><b>⚙️ Equipamentos Personalizados</b><button class='btn secondary' onclick='Views.custom_equipment_form()'>+ Adicionar</button></div><div id='custom_eq_list'></div><span class='hint'>Adicione equipamentos extras (ex: 2° forno, masseira) que serão incluídos no cálculo quando usados.</span></div><div class='card'><b>Ações</b><div class='grid cols-2'><button class='btn secondary' onclick='Views.profile_export()'>Exportar Dados</button><button class='btn secondary' onclick='Views.profile_backup()'>Backup Completo</button></div></div></div>
"@

if ($content -match [regex]::Escape($old)) {
    $content = $content.Replace($old, $new)
    Set-Content 'index.html' $content -NoNewline -Encoding UTF8
    Write-Host "✓ Seção de equipamentos personalizados adicionada!" -ForegroundColor Green
} else {
    Write-Host "✗ Padrão não encontrado. Verifique o arquivo." -ForegroundColor Red
}
