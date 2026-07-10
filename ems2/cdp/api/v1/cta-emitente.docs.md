# API Conta Corrente do Emitente

![Módulo](https://img.shields.io/badge/m%C3%B3dulo-EMS2%2FCDP-blue)
![Status](https://img.shields.io/badge/status-Est%C3%A1vel-brightgreen)
![Versão](https://img.shields.io/badge/vers%C3%A3o-v1-lightgrey)

## 📋 Descrição

A API **Conta Corrente do Emitente** disponibiliza serviços para consulta e manutenção das contas correntes vinculadas aos emitentes do módulo **EMS2/CDP** do TOTVS Datasul.

Por meio desta API é possível:

- Consultar contas correntes cadastradas.
- Consultar uma conta corrente específica.
- Incluir nova conta corrente.
- Alterar dados de uma conta corrente específica.
- Excluir uma conta corrente específica.

---

## ℹ️ Informações gerais

| Item | Valor |
|---|---|
| Módulo Datasul | EMS2/CDP |
| Camada | EMS2 |
| Versão da API | v1 |
| Arquivo endpoint | `api/v1/cta-emitente.p` |
| Arquivo handler | `cta-emitente.p` |

---

## 🌐 Endpoint base

```text
{{BASE_URL}}cdp/v1/cta-emitente
```

---

## 🔐 Autenticação

Esta API utiliza **HTTP Basic Auth**.

| Variável Postman | Descrição |
|---|---|
| `{{USERNAME}}` | Usuário Datasul |
| `{{PASSWORD}}` | Senha do usuário |

---

## 📑 Sumário de endpoints

| Método | Caminho | Descrição |
|---|---|---|
| `GET` | `/cta-emitente` | Consulta contas correntes (lista paginada) |
| `GET` | `/cta-emitente/{id}` | Consulta conta corrente por identificador |
| `POST` | `/cta-emitente` | Inclui uma conta corrente |
| `PUT` | `/cta-emitente/{id}` | Atualiza uma conta corrente |
| `DELETE` | `/cta-emitente/{id}` | Exclui uma conta corrente |

---

# Endpoints

## GET `/cta-emitente`

### Consulta contas correntes

Retorna uma lista paginada de contas correntes cadastradas.

Permite utilização de filtros para restringir os resultados.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| page | query | Integer | Não | Página atual da consulta |
| pageSize | query | Integer | Não | Quantidade de registros por página |
| emitente | query | Integer | Não | Código do emitente |
| banco | query | Integer | Não | Código do banco |
| agencia | query | String | Não | Código da agência |
| contaCorrente | query | String | Não | Número da conta corrente |
| preferencial | query | Boolean | Não | Retorna somente contas preferenciais |
| search | query | String | Não | Pesquisa textual |

### Exemplo de requisição

```http
GET {{BASE_URL}}cdp/v1/cta-emitente?page=1&pageSize=20&emitente=2
```

### Resposta

**HTTP 200**

```json
{
    "total": 2,
    "hasNext": true,
    "items": [
        {
            "emitente": 2,
            "contaCorrente": "00000004006",
            "banco": 237,
            "preferencial": true,
            "id": 9785625,
            "agencia": "0033987",
            "descricao": ""
        }
    ]
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 400 | - | Parâmetro de filtro inválido |

---

## GET `/cta-emitente/{id}`

### Consulta conta corrente por identificador

Retorna uma conta corrente através do identificador interno.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno da conta corrente |

### Exemplo de requisição

```http
GET {{BASE_URL}}cdp/v1/cta-emitente/9785625
```

### Resposta

**HTTP 200**

```json
{
    "emitente": 2,
    "contaCorrente": "00000004006",
    "banco": 237,
    "preferencial": true,
    "id": 9785625,
    "agencia": "0033987",
    "descricao": ""
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Conta corrente não encontrada para o identificador informado |

---

## POST `/cta-emitente`

### Inclui uma conta corrente

Cria uma nova conta corrente vinculada a um emitente.

### Corpo da requisição

```json
{
    "emitente": 2769,
    "contaCorrente": "13002158",
    "banco": 1,
    "preferencial": true,
    "agencia": "1595",
    "descricao": "TESTE API"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| emitente | Integer | Sim | Código do emitente |
| contaCorrente | String | Sim | Número da conta corrente |
| banco | Integer | Sim | Código do banco |
| agencia | String | Não | Código da agência bancária |
| preferencial | Boolean | Não | Indica se a conta é preferencial |
| descricao | String | Não | Descrição da conta |

### Exemplo de requisição

```http
POST {{BASE_URL}}cdp/v1/cta-emitente
```

### Resposta

**HTTP 201**

```json
{
    "emitente": 2769,
    "contaCorrente": "13002158",
    "banco": 1,
    "preferencial": true,
    "agencia": "1595",
    "descricao": "TESTE API"
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 400 | - | Campos obrigatórios ausentes/inválidos (ex.: emitente inexistente) |
| 409 | 1 | Já existe conta corrente cadastrada para a chave informada |

---

## PUT `/cta-emitente/{id}`

### Atualiza uma conta corrente

Atualiza os dados de uma conta corrente existente.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno da conta corrente |

### Corpo da requisição

```json
{
    "contaCorrente": "64634",
    "banco": 1,
    "preferencial": true,
    "agencia": "4081",
    "descricao": "TESTE API"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| contaCorrente | String | Não | Número da conta corrente |
| banco | Integer | Não | Código do banco |
| agencia | String | Não | Código da agência bancária |
| preferencial | Boolean | Não | Indica se a conta é preferencial |
| descricao | String | Não | Descrição da conta |

### Exemplo de requisição

```http
PUT {{BASE_URL}}cdp/v1/cta-emitente/9785625
```

### Resposta

**HTTP 200**

```json
{
    "contaCorrente": "64634",
    "banco": 1,
    "preferencial": true,
    "agencia": "4081",
    "descricao": "TESTE API"
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Conta corrente não encontrada para o identificador informado |

---

## DELETE `/cta-emitente/{id}`

### Exclui uma conta corrente

Remove uma conta corrente existente.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno da conta corrente |

### Exemplo de requisição

```http
DELETE {{BASE_URL}}cdp/v1/cta-emitente/9785474
```

### Resposta

**HTTP 204**

Registro excluído com sucesso.

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Conta corrente não encontrada para o identificador informado |

---

# 📦 Modelo de Dados

## Conta Corrente

| Campo | Tipo | Descrição |
|---|---|---|
| id | Integer | Identificador interno do registro |
| emitente | Integer | Código do emitente |
| banco | Integer | Código do banco |
| agencia | String | Código da agência bancária |
| contaCorrente | String | Número da conta corrente |
| preferencial | Boolean | Indica se a conta é preferencial |
| descricao | String | Descrição da conta |

---

# ⚠️ Envelope de erro padrão

```json
{
    "rowErrors": [
        {
            "errorNumber": 2,
            "errorType": "EMS",
            "errorSubType": "ERROR",
            "errorDescription": "Não encontrado(a) conta corrente de emitente para chave informada.",
            "errorHelp": "Não foi encontrada ocorrência para conta corrente de emitente com a chave informada."
        }
    ]
}
```

# ⚠️ Códigos de Retorno

| Código HTTP | Descrição |
|---|---|
| 200 | Operação realizada com sucesso |
| 201 | Registro criado com sucesso |
| 204 | Registro removido com sucesso |
| 400 | Requisição inválida |
| 404 | Registro não encontrado |
| 409 | Registro já existente |
| 500 | Erro interno do servidor |

---

# 📌 Observações

- Todos os endpoints utilizam autenticação Basic Auth.
- Os campos apresentados representam o contrato JSON exposto pela API.
- A implementação segue os padrões REST disponibilizados pelo TOTVS Datasul.
- O identificador `id` corresponde ao RECID interno do registro no Datasul e não deve ser tratado como chave de negócio estável entre ambientes.

---

# 🕓 Changelog

| Data | Versão | Descrição |
|---|---|---|
| 2026-07-10 | v1 | Documentação reestruturada conforme padrão do repositório (`docs/PADRAO-DOCUMENTACAO.md`). |
