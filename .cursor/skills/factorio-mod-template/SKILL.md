---
name: factorio-mod-template
description: >-
  Orienta o onboarding de um mod criado a partir do mod-template do Factorio:
  estrutura dos arquivos, obtenção e cadastro da chave de API do portal, e
  preparação de uma publicação. Use quando o usuário clonar ou renomear este
  template, perguntar da estrutura do mod, da chave do portal, ou pedir para
  publicar ou preparar uma versão antes da publicação.
---

# Mod template

O mod de exemplo imprime uma mensagem quando o jogador entra na partida. O restante do repositório é a base de teste, empacotamento e envio ao portal.

## Estrutura do mod

| Arquivo | Função |
|---|---|
| `info.json` | Nome interno, versão, título, autor, `factorio_version` e descrição. Obrigatório. |
| `control.lua` | Script de runtime. No template, imprime `mod-template.hello` em `on_player_joined_game`. |
| `data.lua` | Protótipos, via `data:extend`. Vazio até haver protótipos. |
| `changelog.txt` | Histórico exibido no navegador de mods. A versão do topo é a mais nova e tem de ser a mesma de `info.json`. |
| `locale/<idioma>/*.cfg` | Traduções. A pasta do idioma é o código (`en`). |
| `thumbnail.png` | Imagem 144×144 do navegador de mods e do portal. |
| `.modfiles` | Globs, a partir da raiz, dos arquivos que entram no zip. `#` comenta a linha. Padrão sem match falha o empacotamento. |
| `tests/` | Testes unitários fora do jogo. `bash .github/scripts/run-tests.sh` (Lua 5.4). |
| `.github/workflows/test.yml` | Roda os testes em pull request e em push fora da `main`. |
| `.github/workflows/publish.yml` | Na `main`, roda os testes e depois publica. |
| `.github/scripts/` | Leitura do `info.json`, zip, upload e execução dos testes. |

O jogo também carrega, se existirem, `settings.lua`, `settings-updates.lua`, `settings-final-fixes.lua`, `data-updates.lua` e `data-final-fixes.lua`. Ao criar um desses, inclua o nome em `.modfiles`. Qualquer outro `.lua` só entra em execução se um desses arquivos der `require` nele.

Ao renomear o mod, troque o nome interno em `info.json`, no arquivo e na seção de `locale/`, e na chave usada em `control.lua`. A pasta dentro de `mods/` deve ser o nome interno, ou `nome_versão`.

`changelog.txt` começa com uma linha de exatamente 99 traços. Cada versão tem `Version: ` e, opcionalmente, `Date: `. A categoria começa com dois espaços e termina com dois-pontos. Cada item começa com quatro espaços, um hífen e um espaço. Sem tabulação e sem espaço no fim da linha. Categorias reconhecidas pelo jogo: Major Features, Features, Minor Features, Graphics, Sounds, Optimizations, Balancing, Combat Balancing, Circuit Network, Changes, Bugfixes, Modding, Scripting, Gui, Control, Translation, Debug, Ease of use, Info, Locale, Compatibility.

## Chave de API do portal de mods do Factorio

### Obtenção da chave

1. Abra <https://factorio.com/profile> com a conta que publica o mod.
2. Crie uma chave em **API Keys**.
3. Não use o token antigo exibido no perfil. A publicação usa só a API key.

### Cadastro da chave no Github

1. No repositório do mod: **Settings → Secrets and variables → Actions**.
2. Crie um secret de repositório.
3. O nome é exatamente `FACTORIO_API_KEY`.
4. O valor é a chave. Ela não entra no git.

O workflow de publicação lê esse secret e o envia em `Authorization: Bearer` para `https://mods.factorio.com/api/v2/mods/releases/init_upload`.

## Publicação do mod

Caso o usuário solicite publicação ou mesmo uma preparação antes da publicação, executar os passos abaixo. Não commitar, não dar stage e não publicar antes do fim deste fluxo.

### 1. Árvore limpa

Primeiramente, o usuário deve commitar e/ou descartar todas as alterações. Continuar somente quando não houver alterações (nem mesmo em staging).

Conferir com `git status --porcelain`. Qualquer saída, inclusive arquivo novo ou linha em stage, encerra o fluxo. Dizer o que ainda está pendente e parar. Não descartar, não guardar em stash e não commitar no lugar do usuário.

### 2. O que mudou desde a última versão do portal

Confrontar tudo que mudou desde a última versão publicada no portal de mods.

- Ler `name` e `version` em `info.json`.
- Consultar `https://mods.factorio.com/api/mods/<name>`.
- Se o mod existir, a versão publicada é a maior `releases[].version`, sem depender da ordem do array. Achar o commit em que `info.json` passou a ter essa versão e comparar desse commit até `HEAD`.
- Se o portal responder que o mod não existe, não há versão publicada. Comparar a partir do primeiro commit.

### 3. Alterar os arquivos da release

Com o resultado, alterar os arquivos pertinentes (ex.: info.json, changelog etc), mas não colocar em stage e nem commitar, apenas alterar.

- Se o diff não tiver mudança que o jogador perceba, não alterar versão nem changelog. Dizer que não há release nova e parar.
- Se houver, subir `info.json` `version`: patch para correção, minor para funcionalidade, major para mudança incompatível.
- Inserir essa versão no topo de `changelog.txt`, com a data de hoje no formato `DD. MM. YYYY` e só as categorias que couberem nas mudanças.
- Ajustar locale, descrição ou thumbnail quando o diff exigir.
- Não executar `git add` nem `git commit`.

### 4. Mensagem e confirmação

No fim, mostrar uma mensagem de commit com o novo número de versão e o que foi feito. Orientar o usuário que ele pode seguir por conta própria, porém perguntar se ele quer que o agente termine o serviço, bastando responder "sim".

A mensagem fica neste formato:

```
Release <versão>: <o que mudou para o jogador>.

<por que essa versão existe>
```

Terminar o serviço, somente depois de uma resposta "sim", é: colocar em stage os arquivos alterados nesta preparação, commitar com essa mensagem e fazer push da `main`. Esse push dispara o workflow de publicação. Qualquer outra resposta não commita e não faz push.
