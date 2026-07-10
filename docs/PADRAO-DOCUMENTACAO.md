# 📖 Padrão de Documentação de APIs

Este documento define o **padrão oficial** de documentação para todas as APIs REST deste repositório. Ele existe para que qualquer pessoa — hoje ou daqui a dois anos — consiga entender, testar e consumir uma API sem precisar ler o código Progress (`.p`/`.i`).

Todo novo endpoint **deve** seguir este padrão. Endpoints já existentes devem ser migrados para ele conforme forem alterados.

---

## 1. Visão geral: quais arquivos toda API precisa ter

| Arquivo | Obrigatório | Descrição |
|---|:---:|---|
| `api/v1/nome-api.p` | ✅ | Endpoint REST (camada HTTP). |
| `nome-api.p` | ✅ | API Handler (regra de negócio), na raiz do módulo. |
| `nome-api.i` | ✅ | Temp-tables e ProDataSets compartilhados. |
| `api/v1/nome-api.docs.md` | ✅ | Documentação funcional da API (este padrão). |
| `api/v1/nome-api.openapi.yaml` | ✅ | Especificação OpenAPI 3.0. |
| `api/v1/nome-api.postman.json` | ⚠️ Recomendado | Collection do Postman para testes manuais. |

> ⚠️ **Nomenclatura**: o sufixo correto do arquivo de documentação é **`.docs.md`**, não `.md`. Isso evita ambiguidade com outros arquivos Markdown do repositório (README, CONTRIBUTING etc.) e é o padrão já em uso na API `cta-emitente`.

Todos os nomes de arquivo usam **kebab-case** e devem ser idênticos ao nome do recurso exposto na URL (ex.: recurso `cta-emitente` → arquivos `cta-emitente.*`).

---

## 2. Estrutura obrigatória do arquivo `.docs.md`

Use o template pronto em [`docs/templates/nome-api.docs.md`](./templates/nome-api.docs.md) como ponto de partida. Ele contém todas as seções abaixo, com marcações `{{ASSIM}}` indicando o que deve ser substituído.

1. **Título e badges** — nome da API, módulo Datasul, status (Estável / Beta / Deprecated), versão.
2. **Descrição** — o que a API faz e quais operações de negócio ela cobre (bullets).
3. **Informações gerais** — módulo (ex. `EMS2/CDP`), camada (`EMS2` ou `EMS5`), versão da API (`v1`), autor/mantenedor.
4. **Endpoint base** — a URL base, sempre usando a variável `{{BASE_URL}}`.
5. **Autenticação** — método de autenticação (hoje: Basic Auth) e variáveis do Postman (`{{USERNAME}}` / `{{PASSWORD}}`).
6. **Sumário de endpoints** — tabela rápida com método, path e resumo de todos os endpoints, com link para a seção detalhada.
7. **Endpoints (detalhado)** — uma seção por endpoint, seguindo a subestrutura da seção 3 deste documento.
8. **Modelo de dados** — tabela de campos de cada recurso/objeto retornado pela API.
9. **Envelope de erro padrão** — como os erros são retornados (ver seção 4 deste documento).
10. **Códigos de retorno** — tabela de status HTTP usados pela API.
11. **Observações** — regras de negócio relevantes, limitações conhecidas, dependências de cadastro/parametrização no Datasul.
12. **Changelog** — histórico de alterações relevantes da API (data, versão, descrição).

### 2.1 Subestrutura de cada endpoint (seção 7)

Cada endpoint documentado deve conter, nesta ordem:

```markdown
## MÉTODO `/caminho/{parametro}`

### Nome curto do endpoint

Descrição de uma ou duas frases sobre o que o endpoint faz.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|

### Corpo da requisição   (apenas em POST/PUT)

json de exemplo + tabela de campos aceitos

### Exemplo de requisição

http/bash de exemplo, sempre com {{BASE_URL}}

### Resposta

**HTTP 200/201/204** + json de exemplo

### Possíveis erros

Lista dos erros específicos deste endpoint (com HTTP status e ErrorNumber, quando aplicável)
```

- **Parâmetros de path e query ficam na mesma tabela**, diferenciados pela coluna "Local" (`path` ou `query`).
- Todo exemplo de JSON deve ser **realista** (valores plausíveis, não `"string"` ou `"foo"`), preferencialmente baseado em um teste real (com dados fictícios).
- Toda operação de escrita (POST/PUT/DELETE) deve documentar o que acontece quando o registro **não existe** ou já existe (conflito).

---

## 3. Estrutura obrigatória do arquivo `.openapi.yaml`

- OpenAPI **3.0.3**.
- `servers` sempre com `{{BASE_URL}}`.
- `security: basicAuth` a nível global (a menos que o endpoint use outro método).
- Um `tag` por recurso/API.
- Todo `path` deve ter `summary`, `description`, `parameters` tipados (com `example`), `requestBody` (quando aplicável) e `responses` cobrindo no mínimo os códigos de sucesso e `400`/`404`/`500`.
- `components/schemas` deve refletir fielmente os campos do `SERIALIZE-NAME` definidos no `.i` (não o nome de campo Progress, e sim o nome JSON exposto).
- Separe schemas de **entrada** (`...Create`, `...Update`) dos de **saída** (schema base), assim como feito em `cta-emitente.openapi.yaml`.
- Use o template [`docs/templates/nome-api.openapi.yaml`](./templates/nome-api.openapi.yaml) como esqueleto.

---

## 4. Convenções gerais (válidas para todas as APIs do repositório)

Estas convenções vêm da infraestrutura comum (`utp/ut-api*.i`, `JsonAPIResponse`, `RowErrors`) e devem ser **descritas, não redefinidas**, em cada `.docs.md` — copie a seção "Envelope de erro padrão" do template e ajuste apenas exemplos.

### 4.1 Envelope de listagem (paginação)

```json
{
    "total": 2,
    "hasNext": true,
    "items": [ { ... } ]
}
```

| Query param | Tipo | Descrição |
|---|---|---|
| `page` | Integer | Página atual (padrão: 1) |
| `pageSize` | Integer | Registros por página |
| `search` ou `quickSearch` | String | Pesquisa textual livre |

### 4.2 Envelope de erro

Erros de negócio (validação, não encontrado, conflito) são retornados via `RowErrors`, mapeado para o JSON de resposta assim:

```json
{
    "rowErrors": [
        {
            "errorNumber": 2,
            "errorType": "EMS",
            "errorSubType": "ERROR",
            "errorDescription": "Não encontrado(a) registro para chave informada.",
            "errorHelp": "Não foi encontrada ocorrência para o registro com a chave informada."
        }
    ]
}
```

Mapeamento padrão de `ErrorNumber` → HTTP status (usado pelos handlers deste repositório):

| ErrorNumber | HTTP Status | Significado |
|---|---|---|
| `1` | 409 | Registro já existente / conflito |
| `2` | 404 | Registro não encontrado |
| outro / genérico | 400 | Requisição ou dados inválidos |

> Cada API pode ter `ErrorNumber`s de negócio adicionais — quando existirem, devem ser listados na tabela "Possíveis erros" do endpoint correspondente.

### 4.3 Datas e tipos

- Datas trafegam no formato `AAAA-MM-DD` (ISO 8601).
- Valores monetários/decimais são números JSON (`decimal`), não string.
- Campos booleanos Progress (`logical`) são serializados como `true`/`false`.

### 4.4 Autenticação

Todas as APIs deste repositório usam **HTTP Basic Auth**. Documentar sempre com as variáveis de ambiente do Postman: `{{USERNAME}}` e `{{PASSWORD}}`.

---

## 5. Checklist antes de abrir o Pull Request

Use também o checklist completo em [`docs/templates/CHECKLIST-PR.md`](./templates/CHECKLIST-PR.md). Resumo:

- [ ] `nome-api.docs.md` criado/atualizado seguindo este padrão.
- [ ] `nome-api.openapi.yaml` criado/atualizado e validado (sem erros de sintaxe YAML).
- [ ] `nome-api.postman.json` criado/atualizado, com exemplos de resposta reais salvos.
- [ ] Todos os endpoints do `.p` estão documentados (compare os `ut-api-action.i` do endpoint com as seções do `.docs.md`).
- [ ] Erros de negócio específicos da API estão listados.
- [ ] Exemplos usam dados fictícios plausíveis, sem informação real de cliente/empresa.

---

## 6. Migração de documentação existente

APIs documentadas antes deste padrão (ex.: versões antigas de `cta-emitente`) devem ser atualizadas na próxima alteração relevante que receberem, adicionando pelo menos as seções que faltarem (Autenticação, Envelope de erro padrão, Sumário de endpoints, Changelog).
