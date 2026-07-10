# 🚀 Datasul REST API

Repositório colaborativo com APIs REST desenvolvidas para o **ERP TOTVS Datasul**, contendo implementações em **Progress OpenEdge ABL**, documentação técnica, especificações OpenAPI e coleções do Postman.

O projeto tem como objetivo servir tanto como uma **biblioteca de APIs reutilizáveis** quanto como um **material de referência** para desenvolvedores que desejam implementar ou aprender a desenvolver APIs REST seguindo a arquitetura utilizada pelo Datasul.

> **⚠️ Aviso**
>
> Este projeto é independente e não possui qualquer vínculo oficial com a TOTVS.

---

# 🎯 Objetivos

- 📚 Disponibilizar uma biblioteca de APIs REST que possam ser reutilizadas e adaptadas em projetos Datasul.
- 💻 Centralizar exemplos de implementação utilizando Progress OpenEdge ABL.
- 🏗️ Compartilhar boas práticas para o desenvolvimento de APIs REST no Datasul.
- 📖 Disponibilizar documentação técnica dos endpoints.
- 📑 Fornecer especificações OpenAPI.
- 📬 Disponibilizar coleções do Postman para facilitar testes e integrações.
- 🤝 Servir como material de referência para desenvolvedores da comunidade Datasul.

> 💡 Todas as APIs deste repositório seguem a estrutura de desenvolvimento utilizada pelo ERP TOTVS Datasul, facilitando sua reutilização, adaptação e implantação em novos projetos.

---

# 📂 Estrutura do repositório

Cada API segue a mesma organização utilizada pelo Datasul.

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

## 📄 Organização dos arquivos

| Arquivo | Descrição |
|---------|-----------|
| `api/v1/*.p` | Endpoint REST responsável pelo recebimento da requisição HTTP, serialização/desserialização do JSON e retorno da resposta. |
| `*.p` | API Handler contendo a lógica de negócio da API. |
| `*.i` | Definição das Temp-Tables e ProDataSets compartilhados entre o endpoint REST e o handler. |
| `api/v1/*.docs.md` | Documentação funcional da API. |
| `api/v1/*.openapi.yaml` | Especificação OpenAPI. |
| `api/v1/*.postman.json` | Collection do Postman. |

---

# 📚 Documentação

Todas as APIs deste repositório seguem um **padrão único de documentação**, descrito em [`docs/PADRAO-DOCUMENTACAO.md`](./docs/PADRAO-DOCUMENTACAO.md). Esse documento define quais arquivos toda API precisa ter, a estrutura obrigatória de cada um e as convenções gerais (paginação, autenticação, envelope de erro).

Para criar a documentação de uma nova API, parta dos templates prontos em [`docs/templates`](./docs/templates):

- [`nome-api.docs.md`](./docs/templates/nome-api.docs.md) — documentação funcional.
- [`nome-api.openapi.yaml`](./docs/templates/nome-api.openapi.yaml) — especificação OpenAPI.
- [`CHECKLIST-PR.md`](./docs/templates/CHECKLIST-PR.md) — checklist a preencher no Pull Request.

Cada endpoint possui sua própria documentação (`*.docs.md`) ao lado do respectivo endpoint REST, em `api/v1/`.

## 🔌 APIs disponíveis

| API | Módulo | Documentação |
|---|---|---|
| Conta Corrente do Emitente | EMS2/CDP | [`cta-emitente.docs.md`](./ems2/cdp/api/v1/cta-emitente.docs.md) |
| Extrato de Conta Corrente | EMS5/CMG | [`extrato-cta-corrente.docs.md`](./ems5/cmg/api/v1/extrato-cta-corrente.docs.md) |

---

# 🤝 Contribuindo

Contribuições são bem-vindas.

Antes de abrir uma *Issue* ou *Pull Request*, leia o arquivo `CONTRIBUTING.md`.

---

# 📄 Licença

Este projeto é distribuído sob a licença **MIT**.