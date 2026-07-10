# API Conta Corrente do Emitente

## 📋 Descrição

A API **Conta Corrente do Emitente** disponibiliza serviços para consulta e manutenção das contas correntes vinculadas aos emitentes do módulo **EMS2/CDP** do TOTVS Datasul.

Por meio desta API é possível:

- Consultar contas correntes cadastradas.
- Consultar uma conta corrente específica.
- Incluir nova conta corrente.
- Alterar dados de uma conta corrente específica.
- Excluir uma conta corrente específica.

---

## 🌐 Endpoint Base

```text
{{BASE_URL}}cdp/v1/cta-emitente
```

---

# Endpoints

## GET `/cta-emitente`

### Consulta contas correntes

Retorna uma lista paginada de contas correntes cadastradas.

Permite utilização de filtros para restringir os resultados.

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| page | Integer | Não | Página atual da consulta |
| pageSize | Integer | Não | Quantidade de registros por página |
| emitente | Integer | Não | Código do emitente |
| banco | Integer | Não | Código do banco |
| agencia | String | Não | Código da agência |
| contaCorrente | String | Não | Número da conta corrente |
| preferencial | Boolean | Não | Retorna somente contas preferenciais |
| search | String | Não | Pesquisa textual |

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

---

## GET `/cta-emitente/{id}`

### Consulta conta corrente por identificador

Retorna uma conta corrente através do identificador interno.

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | Integer | Sim | Identificador interno da conta corrente |

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

---

## POST `/cta-emitente`

### Inclui uma conta corrente

Cria uma nova conta corrente vinculada a um emitente.

### Exemplo de requisição

```http
POST {{BASE_URL}}cdp/v1/cta-emitente
```

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

---

## PUT `/cta-emitente/{id}`

### Atualiza uma conta corrente

Atualiza os dados de uma conta corrente existente.

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | Integer | Sim | Identificador interno da conta corrente |

### Exemplo de requisição

```http
PUT {{BASE_URL}}cdp/v1/cta-emitente/9785625
```

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

---

## DELETE `/cta-emitente/{id}`

### Exclui uma conta corrente

Remove uma conta corrente existente.

### Parâmetros

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| id | Integer | Sim | Identificador interno da conta corrente |

### Exemplo de requisição

```http
DELETE {{BASE_URL}}cdp/v1/cta-emitente/9785474
```

### Resposta

**HTTP 204**

Registro excluído com sucesso.

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