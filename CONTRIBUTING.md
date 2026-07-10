# 🤝 Contribuindo

Obrigado pelo interesse em contribuir com o **Datasul REST API**.

Este projeto tem como objetivo criar uma biblioteca colaborativa de APIs REST para o ERP **TOTVS Datasul**, compartilhando implementações, documentações e boas práticas utilizando **Progress OpenEdge ABL**.

---

# 📌 Antes de contribuir

Antes de enviar uma contribuição, verifique se:

- A alteração está alinhada com o objetivo do projeto.
- Não existem implementações semelhantes já disponíveis.
- A documentação da alteração está atualizada.
- Os exemplos foram testados em um ambiente Datasul.

---

# 🚀 Adicionando uma nova API

Ao adicionar uma nova API ao repositório, mantenha a estrutura padrão utilizada pelo projeto.

Cada endpoint deve possuir os seguintes arquivos:

```text
api/v1/

nome-api.p
nome-api.docs.md
nome-api.openapi.yaml
nome-api.postman.json
```

Exemplo:
```text
ems2/
└── cdp/
    ├── api/
    │   └── v1/
    │       ├── cta-emitente.p
    │       ├── cta-emitente.docs.md
    │       ├── cta-emitente.openapi.yaml
    │       └── cta-emitente.postman.json
    │
    ├── cta-emitente.p
    └── cta-emitente.i
```

## Código-fonte

A implementação deve seguir a arquitetura padrão do Datasul:

```text
Endpoint REST
      |
      v
API Handler
      |
      v
Banco de Dados
```

Responsabilidades:

| Arquivo | Responsabilidade |
|---------|------------------|
| `api/v1/*.p` | Tratamento da requisição HTTP, entrada e saída JSON. |
| `*.p` | Regras de negócio da API. |
| `*.i` | Definição das estruturas compartilhadas, como Temp-Tables e ProDataSets. |

---

# 📖 Documentação

Toda nova API deve seguir o **padrão oficial de documentação** definido em [`docs/PADRAO-DOCUMENTACAO.md`](./docs/PADRAO-DOCUMENTACAO.md). Não crie a documentação do zero: parta dos templates em [`docs/templates`](./docs/templates).

O arquivo `nome-api.docs.md` deve permanecer junto ao endpoint, em `api/v1/`, e conter no mínimo:

- Descrição da API e informações gerais (módulo, versão, autor).
- Endpoint base e autenticação.
- Sumário de todos os endpoints disponíveis.
- Para cada endpoint: método HTTP, parâmetros (path/query), corpo da requisição (quando aplicável), exemplo de requisição, exemplo de resposta e possíveis erros.
- Modelo de dados (tabela de campos do contrato JSON).
- Envelope de erro padrão e tabela de códigos de retorno.
- Changelog.

Antes de abrir o Pull Request, preencha o [checklist de documentação](./docs/templates/CHECKLIST-PR.md).

---

# 📑 OpenAPI

Toda nova API deve ser acompanhada de sua especificação OpenAPI, seguindo o esqueleto em [`docs/templates/nome-api.openapi.yaml`](./docs/templates/nome-api.openapi.yaml).

O arquivo deve permanecer junto ao endpoint:

```text
api/v1/nome-api.openapi.yaml
```

---

# 📬 Postman

Quando aplicável, deve ser adicionada uma collection do Postman contendo exemplos de utilização da API.

O arquivo deve permanecer junto ao endpoint:

```text
api/v1/nome-api.postman.json
```

---

# 🔀 Pull Requests

Ao criar um Pull Request:

- Utilize uma descrição clara sobre a alteração realizada.
- Informe quais APIs ou módulos foram afetados.
- Inclua evidências de testes realizados.
- Atualize a documentação quando necessário.

---

# 🐛 Reportando problemas

Ao encontrar um problema, abra uma Issue contendo:

- Descrição do problema.
- API ou módulo afetado.
- Versão do Datasul utilizada.
- Passos para reproduzir.
- Resultado esperado.
- Resultado obtido.

---

# 📋 Padrões de código

Ao contribuir:

- Preserve a estrutura utilizada pelo Datasul.
- Evite alterações que quebrem compatibilidade com APIs existentes.
- Utilize nomes claros para variáveis, parâmetros e arquivos.
- Mantenha comentários somente quando agregarem contexto relevante.

---

# Licença

Ao contribuir com este projeto, você concorda que sua contribuição será disponibilizada sob a licença definida no arquivo `LICENSE`.