<!--
  TEMPLATE de documentação de API — copie este arquivo para
  <módulo>/<pacote>/api/v1/nome-da-api.docs.md e substitua os
  trechos entre {{ }}.

  Consulte docs/PADRAO-DOCUMENTACAO.md para as regras completas.
-->

# API {{Nome Funcional da API}}

![Módulo](https://img.shields.io/badge/m%C3%B3dulo-{{EMS2%2FCDP}}-blue)
![Status](https://img.shields.io/badge/status-{{Est%C3%A1vel}}-brightgreen)
![Versão](https://img.shields.io/badge/vers%C3%A3o-v1-lightgrey)

## 📋 Descrição

A API **{{Nome Funcional da API}}** disponibiliza serviços para {{descrever objetivo em uma frase}}, no módulo **{{EMS2/CDP}}** do TOTVS Datasul.

Por meio desta API é possível:

- {{Consultar ...}}
- {{Incluir ...}}
- {{Alterar ...}}
- {{Excluir ...}}

---

## ℹ️ Informações gerais

| Item | Valor |
|---|---|
| Módulo Datasul | {{EMS2/CDP}} |
| Camada | {{EMS2 / EMS5}} |
| Versão da API | v1 |
| Autor / Mantenedor | {{Nome}} |
| Arquivo endpoint | `api/v1/{{nome-api}}.p` |
| Arquivo handler | `{{nome-api}}.p` |

---

## 🌐 Endpoint base

```text
{{BASE_URL}}{{pacote}}/v1/{{nome-api}}
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
| `GET` | `/{{nome-api}}` | {{Consulta lista paginada}} |
| `GET` | `/{{nome-api}}/{id}` | {{Consulta por identificador}} |
| `POST` | `/{{nome-api}}` | {{Cria um novo registro}} |
| `PUT` | `/{{nome-api}}/{id}` | {{Atualiza um registro existente}} |
| `DELETE` | `/{{nome-api}}/{id}` | {{Remove um registro}} |

---

# Endpoints

## GET `/{{nome-api}}`

### {{Consulta lista}}

{{Descrição de uma ou duas frases.}}

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| page | query | Integer | Não | Página atual da consulta |
| pageSize | query | Integer | Não | Quantidade de registros por página |
| search | query | String | Não | Pesquisa textual |

### Exemplo de requisição

```http
GET {{BASE_URL}}{{pacote}}/v1/{{nome-api}}?page=1&pageSize=20
```

### Resposta

**HTTP 200**

```json
{
    "total": 0,
    "hasNext": false,
    "items": []
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 400 | - | Parâmetro de filtro inválido |

---

## GET `/{{nome-api}}/{id}`

### {{Consulta por identificador}}

{{Descrição.}}

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno do registro |

### Exemplo de requisição

```http
GET {{BASE_URL}}{{pacote}}/v1/{{nome-api}}/123456
```

### Resposta

**HTTP 200**

```json
{}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Registro não encontrado |

---

## POST `/{{nome-api}}`

### {{Inclui um registro}}

{{Descrição.}}

### Corpo da requisição

```json
{}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|

### Exemplo de requisição

```http
POST {{BASE_URL}}{{pacote}}/v1/{{nome-api}}
```

### Resposta

**HTTP 201**

```json
{}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 400 | - | Dados obrigatórios ausentes/inválidos |
| 409 | 1 | Registro já existente |

---

## PUT `/{{nome-api}}/{id}`

### {{Atualiza um registro}}

{{Descrição.}}

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno do registro |

### Corpo da requisição

```json
{}
```

### Exemplo de requisição

```http
PUT {{BASE_URL}}{{pacote}}/v1/{{nome-api}}/123456
```

### Resposta

**HTTP 200**

```json
{}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Registro não encontrado |

---

## DELETE `/{{nome-api}}/{id}`

### {{Exclui um registro}}

{{Descrição.}}

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno do registro |

### Exemplo de requisição

```http
DELETE {{BASE_URL}}{{pacote}}/v1/{{nome-api}}/123456
```

### Resposta

**HTTP 204**

Registro excluído com sucesso.

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Registro não encontrado |

---

# 📦 Modelo de Dados

## {{Nome do Recurso}}

| Campo | Tipo | Descrição |
|---|---|---|
| id | Integer | Identificador interno do registro |

---

# ⚠️ Envelope de erro padrão

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
- {{Regras de negócio ou dependências de parametrização relevantes.}}

---

# 🕓 Changelog

| Data | Versão | Descrição |
|---|---|---|
| {{AAAA-MM-DD}} | v1 | Criação da API. |
