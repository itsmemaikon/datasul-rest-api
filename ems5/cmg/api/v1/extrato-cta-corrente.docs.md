# API Extrato de Conta Corrente

![Módulo](https://img.shields.io/badge/m%C3%B3dulo-EMS5%2FCMG-blue)
![Status](https://img.shields.io/badge/status-Est%C3%A1vel-brightgreen)
![Versão](https://img.shields.io/badge/vers%C3%A3o-v1-lightgrey)

## 📋 Descrição

A API **Extrato de Conta Corrente** disponibiliza serviços para consulta e manutenção de extratos bancários e de suas linhas de movimento, além da conferência (conciliação de saldos) no módulo **EMS5/CMG** do TOTVS Datasul.

Por meio desta API é possível:

- Consultar extratos de conta corrente cadastrados.
- Consultar um extrato específico, incluindo suas linhas de movimento (`movimentos`).
- Incluir um novo extrato.
- Alterar dados de um extrato existente.
- Excluir um extrato.
- Incluir uma linha de movimento em um extrato.
- Alterar uma linha de movimento existente.
- Excluir uma linha de movimento.
- Consultar a conferência (conciliação) de saldo de um extrato.

---

## ℹ️ Informações gerais

| Item | Valor |
|---|---|
| Módulo Datasul | EMS5/CMG |
| Camada | EMS5 |
| Versão da API | v1 |
| Autor / Mantenedor | Maikon Lopes |
| Arquivo endpoint | `api/v1/extrato-cta-corrente.p` |
| Arquivo handler | `extrato-cta-corrente.p` |

---

## 🌐 Endpoint base

```text
{{BASE_URL}}cmg/v1/extrato-cta-corrente
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
| `GET` | `/extrato-cta-corrente` | Consulta extratos (lista paginada) |
| `GET` | `/extrato-cta-corrente/{id}` | Consulta um extrato específico, com suas linhas de movimento |
| `POST` | `/extrato-cta-corrente` | Inclui um novo extrato |
| `PUT` | `/extrato-cta-corrente/{id}` | Atualiza um extrato existente |
| `DELETE` | `/extrato-cta-corrente/{id}` | Exclui um extrato |
| `POST` | `/extrato-cta-corrente/{id}/linhas` | Inclui uma linha de movimento no extrato |
| `PUT` | `/extrato-cta-corrente/{id}/linhas/{idLinha}` | Atualiza uma linha de movimento |
| `DELETE` | `/extrato-cta-corrente/{id}/linhas/{idLinha}` | Exclui uma linha de movimento |
| `GET` | `/extrato-cta-corrente/{id}/conferencia` | Consulta a conferência de saldo do extrato |

> ⚠️ Diferente da API `cta-emitente`, as operações de exclusão desta API retornam **HTTP 200** com uma mensagem de confirmação no corpo, e não HTTP 204. Veja a seção [Observações](#-observações).

---

# Endpoints

## GET `/extrato-cta-corrente`

### Consulta extratos

Retorna uma lista paginada de extratos de conta corrente cadastrados.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| page | query | Integer | Não | Página atual da consulta |
| pageSize | query | Integer | Não | Quantidade de registros por página |
| contaCorrente | query | String | Não | Código da conta corrente |
| extrato | query | Integer | Não | Número do extrato de conta corrente |
| dataInicial | query | Date | Não | Filtra extratos com data inicial a partir deste valor |
| dataFinal | query | Date | Não | Filtra extratos com data final até este valor |
| search / quickSearch | query | String | Não | Pesquisa textual |

### Exemplo de requisição

```http
GET {{BASE_URL}}cmg/v1/extrato-cta-corrente?page=1&pageSize=20&contaCorrente=00000004006
```

### Resposta

**HTTP 200**

```json
{
    "total": 1,
    "hasNext": false,
    "items": [
        {
            "contaCorrente": "00000004006",
            "extratoCtaCorrente": 1042,
            "referenciaExtrato": "Extrato Julho/2026",
            "dataInicial": "2026-07-01",
            "dataFinal": "2026-07-31",
            "dataGeracaoMovto": "2026-07-01",
            "saldoInicial": 15230.45,
            "saldoFinal": 18940.12,
            "dataAlteracao": "2026-07-09",
            "horaAlteracao": "14:32:10",
            "usuarioAlteracao": "mlopes",
            "id": 20481093
        }
    ]
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 400 | - | Parâmetro de filtro inválido |

---

## GET `/extrato-cta-corrente/{id}`

### Consulta extrato por identificador

Retorna os dados de um extrato específico **com as linhas de movimento aninhadas** no campo `movimentos`.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno (RECID) do extrato |

### Exemplo de requisição

```http
GET {{BASE_URL}}cmg/v1/extrato-cta-corrente/20481093
```

### Resposta

**HTTP 200**

```json
{
    "contaCorrente": "00000004006",
    "extratoCtaCorrente": 1042,
    "referenciaExtrato": "Extrato Julho/2026",
    "dataInicial": "2026-07-01",
    "dataFinal": "2026-07-31",
    "dataGeracaoMovto": "2026-07-01",
    "saldoInicial": 15230.45,
    "saldoFinal": 18940.12,
    "dataAlteracao": "2026-07-09",
    "horaAlteracao": "14:32:10",
    "usuarioAlteracao": "mlopes",
    "id": 20481093,
    "movimentos": [
        {
            "contaCorrente": "00000004006",
            "extratoCtaCorrente": 1042,
            "sequencia": 1,
            "doctoBanco": "000123",
            "tipoLancamento": "DOC",
            "dataMovto": "2026-07-05",
            "historicoMovto": "TED recebida - Cliente XPTO",
            "fluxoMovto": "C",
            "ligacaoConciliacao": "",
            "situacaConciliacao": "P",
            "conciliacao": false,
            "vlMovto": 4200.00,
            "vlPendenteConciliacao": 4200.00,
            "id": 87421
        }
    ]
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Extrato não encontrado para o identificador informado |

---

## POST `/extrato-cta-corrente`

### Inclui um extrato

Cria um novo extrato de conta corrente.

### Corpo da requisição

```json
{
    "contaCorrente": "00000004006",
    "referenciaExtrato": "Extrato Julho/2026",
    "dataInicial": "2026-07-01",
    "dataFinal": "2026-07-31",
    "saldoInicial": 15230.45,
    "saldoFinal": 18940.12
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| contaCorrente | String | Sim | Código da conta corrente |
| referenciaExtrato | String | Não | Descrição/referência do extrato |
| dataInicial | Date | Sim | Data inicial do período do extrato |
| dataFinal | Date | Sim | Data final do período do extrato |
| saldoInicial | Decimal | Sim | Saldo inicial informado no extrato |
| saldoFinal | Decimal | Sim | Saldo final informado no extrato |

### Exemplo de requisição

```http
POST {{BASE_URL}}cmg/v1/extrato-cta-corrente
```

### Resposta

**HTTP 201**

```json
{
    "contaCorrente": "00000004006",
    "extratoCtaCorrente": 1042,
    "referenciaExtrato": "Extrato Julho/2026",
    "dataInicial": "2026-07-01",
    "dataFinal": "2026-07-31",
    "dataGeracaoMovto": "2026-07-01",
    "saldoInicial": 15230.45,
    "saldoFinal": 18940.12,
    "dataAlteracao": "2026-07-09",
    "horaAlteracao": "14:32:10",
    "usuarioAlteracao": "mlopes",
    "id": 20481093
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 400 | - | Campos obrigatórios ausentes/inválidos, ou conta corrente inexistente |

---

## PUT `/extrato-cta-corrente/{id}`

### Atualiza um extrato

Atualiza os dados de um extrato existente. A resposta retorna o extrato atualizado com as linhas de movimento aninhadas em `movimentos`, assim como o `GET /{id}`.

> ⚠️ O campo `contaCorrente` não é alterável por este endpoint — apenas os demais campos abaixo.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno (RECID) do extrato |

### Corpo da requisição

```json
{
    "referenciaExtrato": "Extrato Julho/2026 - Revisado",
    "dataInicial": "2026-07-01",
    "dataFinal": "2026-07-31",
    "saldoInicial": 15230.45,
    "saldoFinal": 19010.00
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| referenciaExtrato | String | Não | Descrição/referência do extrato |
| dataInicial | Date | Não | Data inicial do período do extrato |
| dataFinal | Date | Não | Data final do período do extrato |
| saldoInicial | Decimal | Não | Saldo inicial informado no extrato |
| saldoFinal | Decimal | Não | Saldo final informado no extrato |

### Exemplo de requisição

```http
PUT {{BASE_URL}}cmg/v1/extrato-cta-corrente/20481093
```

### Resposta

**HTTP 200**

```json
{
    "contaCorrente": "00000004006",
    "extratoCtaCorrente": 1042,
    "referenciaExtrato": "Extrato Julho/2026 - Revisado",
    "dataInicial": "2026-07-01",
    "dataFinal": "2026-07-31",
    "dataGeracaoMovto": "2026-07-01",
    "saldoInicial": 15230.45,
    "saldoFinal": 19010.00,
    "dataAlteracao": "2026-07-10",
    "horaAlteracao": "09:15:44",
    "usuarioAlteracao": "mlopes",
    "id": 20481093,
    "movimentos": []
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Extrato não encontrado para o identificador informado |

---

## DELETE `/extrato-cta-corrente/{id}`

### Exclui um extrato

Remove um extrato de conta corrente existente.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno (RECID) do extrato |

### Exemplo de requisição

```http
DELETE {{BASE_URL}}cmg/v1/extrato-cta-corrente/20481093
```

### Resposta

**HTTP 200**

```json
{
    "code": 1,
    "message": "Registro excluído com sucesso",
    "type": "information"
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Extrato não encontrado para o identificador informado |

---

## POST `/extrato-cta-corrente/{id}/linhas`

### Inclui uma linha de movimento

Adiciona uma nova linha de movimento a um extrato existente. A sequência da linha (`sequencia`) e o vínculo com a conta corrente/extrato são atribuídos automaticamente pela API — não é necessário (nem possível) informá-los no corpo da requisição.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno (RECID) do extrato |

### Corpo da requisição

```json
{
    "doctoBanco": "000123",
    "tipoLancamento": "DOC",
    "dataMovto": "2026-07-05",
    "historicoMovto": "TED recebida - Cliente XPTO",
    "fluxoMovto": "C",
    "vlMovto": 4200.00
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| doctoBanco | String | Sim | Número do documento bancário do movimento |
| tipoLancamento | String | Sim | Código do tipo de lançamento do extrato |
| dataMovto | Date | Sim | Data do movimento |
| historicoMovto | String | Não | Histórico/descrição do movimento |
| fluxoMovto | String | Sim | Indicador de fluxo (`C` crédito / `D` débito) |
| vlMovto | Decimal | Sim | Valor do movimento |

> Os campos `contaCorrente`, `extratoCtaCorrente`, `sequencia` e `id` são ignorados se enviados no corpo — são sempre derivados do extrato informado em `{id}` e da sequência automática.

### Exemplo de requisição

```http
POST {{BASE_URL}}cmg/v1/extrato-cta-corrente/20481093/linhas
```

### Resposta

**HTTP 201**

```json
{
    "contaCorrente": "00000004006",
    "extratoCtaCorrente": 1042,
    "sequencia": 1,
    "doctoBanco": "000123",
    "tipoLancamento": "DOC",
    "dataMovto": "2026-07-05",
    "historicoMovto": "TED recebida - Cliente XPTO",
    "fluxoMovto": "C",
    "ligacaoConciliacao": "",
    "situacaConciliacao": "P",
    "conciliacao": false,
    "vlMovto": 4200.00,
    "vlPendenteConciliacao": 4200.00,
    "id": 87421
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 400 | - | Campos obrigatórios ausentes/inválidos |
| 404 | 2 | Extrato não encontrado para o identificador informado |

---

## PUT `/extrato-cta-corrente/{id}/linhas/{idLinha}`

### Atualiza uma linha de movimento

Atualiza os dados de uma linha de movimento existente.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno (RECID) do extrato |
| idLinha | path | Integer | Sim | Identificador interno (RECID) da linha de movimento |

### Corpo da requisição

```json
{
    "doctoBanco": "000123",
    "tipoLancamento": "DOC",
    "fluxoMovto": "C",
    "vlMovto": 4350.00,
    "historicoMovto": "TED recebida - Cliente XPTO (valor corrigido)"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| doctoBanco | String | Não | Número do documento bancário do movimento |
| tipoLancamento | String | Não | Código do tipo de lançamento do extrato |
| fluxoMovto | String | Não | Indicador de fluxo (`C` crédito / `D` débito) |
| vlMovto | Decimal | Não | Valor do movimento |
| historicoMovto | String | Não | Histórico/descrição do movimento |

> Diferente do `POST` de criação, este endpoint **não** permite alterar `dataMovto` — apenas os campos acima.

### Exemplo de requisição

```http
PUT {{BASE_URL}}cmg/v1/extrato-cta-corrente/20481093/linhas/87421
```

### Resposta

**HTTP 200**

```json
{
    "contaCorrente": "00000004006",
    "extratoCtaCorrente": 1042,
    "sequencia": 1,
    "doctoBanco": "000123",
    "tipoLancamento": "DOC",
    "dataMovto": "2026-07-05",
    "historicoMovto": "TED recebida - Cliente XPTO (valor corrigido)",
    "fluxoMovto": "C",
    "ligacaoConciliacao": "",
    "situacaConciliacao": "P",
    "conciliacao": false,
    "vlMovto": 4350.00,
    "vlPendenteConciliacao": 4350.00,
    "id": 87421
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Extrato ou linha de movimento não encontrados para os identificadores informados |

---

## DELETE `/extrato-cta-corrente/{id}/linhas/{idLinha}`

### Exclui uma linha de movimento

Remove uma linha de movimento existente de um extrato.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno (RECID) do extrato |
| idLinha | path | Integer | Sim | Identificador interno (RECID) da linha de movimento |

### Exemplo de requisição

```http
DELETE {{BASE_URL}}cmg/v1/extrato-cta-corrente/20481093/linhas/87421
```

### Resposta

**HTTP 200**

```json
{
    "code": 1,
    "message": "Registro excluído com sucesso",
    "type": "information"
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Extrato ou linha de movimento não encontrados para os identificadores informados |

---

## GET `/extrato-cta-corrente/{id}/conferencia`

### Consulta a conferência do extrato

Retorna a conferência (conciliação) de saldo de um extrato, comparando os valores cadastrados com os valores apurados/informados.

### Parâmetros

| Parâmetro | Local | Tipo | Obrigatório | Descrição |
|---|---|---|---|---|
| id | path | Integer | Sim | Identificador interno (RECID) do extrato |

### Exemplo de requisição

```http
GET {{BASE_URL}}cmg/v1/extrato-cta-corrente/20481093/conferencia
```

### Resposta

**HTTP 200**

```json
{
    "contaCorrente": "00000004006",
    "extratoCtaCorrente": 1042,
    "dataInicial": "2026-07-01",
    "dataFinal": "2026-07-31",
    "saldoInicial": 15230.45,
    "saldoFinal": 18940.12,
    "dataInicialInformado": "2026-07-01",
    "dataFinalInformado": "2026-07-31",
    "saldoFinalInformado": 18940.12,
    "dataInicialAprovado": true,
    "dataFinalAprovado": true,
    "saldoAprovado": true
}
```

### Possíveis erros

| HTTP Status | ErrorNumber | Situação |
|---|---|---|
| 404 | 2 | Extrato não encontrado para o identificador informado |

---

# 📦 Modelo de Dados

## Extrato

| Campo | Tipo | Descrição |
|---|---|---|
| id | Integer | Identificador interno (RECID) do registro |
| contaCorrente | String | Código da conta corrente |
| extratoCtaCorrente | Integer | Número do extrato de conta corrente |
| referenciaExtrato | String | Descrição/referência do extrato |
| dataInicial | Date | Data inicial do período do extrato |
| dataFinal | Date | Data final do período do extrato |
| dataGeracaoMovto | Date | Data de geração do movimento |
| saldoInicial | Decimal | Saldo inicial informado no extrato |
| saldoFinal | Decimal | Saldo final informado no extrato |
| dataAlteracao | Date | Data da última alteração |
| horaAlteracao | String | Hora da última alteração |
| usuarioAlteracao | String | Usuário responsável pela última alteração |
| movimentos | Array\<Movimento\> | Linhas de movimento do extrato (presente apenas em `GET /{id}` e `PUT /{id}`) |

## Movimento (linha de extrato)

| Campo | Tipo | Descrição |
|---|---|---|
| id | Integer | Identificador interno (RECID) da linha |
| contaCorrente | String | Código da conta corrente (herdado do extrato) |
| extratoCtaCorrente | Integer | Número do extrato (herdado do extrato) |
| sequencia | Integer | Sequência da linha dentro do extrato (gerada automaticamente) |
| doctoBanco | String | Número do documento bancário do movimento |
| tipoLancamento | String | Código do tipo de lançamento do extrato |
| dataMovto | Date | Data do movimento |
| historicoMovto | String | Histórico/descrição do movimento |
| fluxoMovto | String | Indicador de fluxo (`C` crédito / `D` débito) |
| ligacaoConciliacao | String | Chave de ligação usada na conciliação bancária |
| situacaConciliacao | String | Situação da conciliação da linha |
| conciliacao | Boolean | Indica se a linha está conciliada |
| vlMovto | Decimal | Valor do movimento |
| vlPendenteConciliacao | Decimal | Valor ainda pendente de conciliação |

## Conferência

| Campo | Tipo | Descrição |
|---|---|---|
| contaCorrente | String | Código da conta corrente |
| extratoCtaCorrente | Integer | Número do extrato |
| dataInicial | Date | Data inicial cadastrada no extrato |
| dataFinal | Date | Data final cadastrada no extrato |
| saldoInicial | Decimal | Saldo inicial cadastrado no extrato |
| saldoFinal | Decimal | Saldo final cadastrado no extrato |
| dataInicialInformado | Date | Data inicial apurada/informada para conferência |
| dataFinalInformado | Date | Data final apurada/informada para conferência |
| saldoFinalInformado | Decimal | Saldo final apurado/informado para conferência |
| dataInicialAprovado | Boolean | Indica se a data inicial confere |
| dataFinalAprovado | Boolean | Indica se a data final confere |
| saldoAprovado | Boolean | Indica se o saldo final confere |

---

# ⚠️ Envelope de erro padrão

```json
{
    "rowErrors": [
        {
            "errorNumber": 2,
            "errorType": "EMS",
            "errorSubType": "ERROR",
            "errorDescription": "Não encontrado(a) extrato de conta corrente para chave informada.",
            "errorHelp": "Não foi encontrada ocorrência para extrato de conta corrente com a chave informada."
        }
    ]
}
```

# ⚠️ Códigos de Retorno

| Código HTTP | Descrição |
|---|---|
| 200 | Operação realizada com sucesso (inclusive exclusões, nesta API) |
| 201 | Registro criado com sucesso |
| 400 | Requisição inválida |
| 404 | Registro não encontrado |
| 500 | Erro interno do servidor |

---

# 📌 Observações

- Todos os endpoints utilizam autenticação Basic Auth.
- Os campos apresentados representam o contrato JSON exposto pela API.
- **Exclusões retornam HTTP 200** (não 204) com um corpo de confirmação (`code`, `message`, `type`). Este comportamento é específico desta API e diverge do padrão adotado em `cta-emitente`; ao consumir esta API, não trate a ausência de HTTP 204 como erro.
- Todos os erros de negócio mapeados nesta API usam `errorNumber = 2` ("registro não encontrado"). Não há, no momento, um código específico para conflito (ex.: linha duplicada).
- O campo `sequencia` das linhas de movimento é sempre atribuído automaticamente pela API (última sequência do extrato + 1) e não pode ser definido pelo cliente.
- O identificador `id` corresponde ao RECID interno do registro no Datasul e não deve ser tratado como chave de negócio estável entre ambientes.

---

# 🕓 Changelog

| Data | Versão | Descrição |
|---|---|---|
| 2026-07-10 | v1 | Criação da documentação da API (anteriormente inexistente), seguindo `docs/PADRAO-DOCUMENTACAO.md`. |
