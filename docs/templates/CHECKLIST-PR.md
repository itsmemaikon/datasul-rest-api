# ✅ Checklist de Documentação — Pull Request

Copie esta lista para a descrição do seu PR e marque cada item antes de solicitar revisão. Veja o padrão completo em [`docs/PADRAO-DOCUMENTACAO.md`](../PADRAO-DOCUMENTACAO.md).

## Arquivos

- [ ] `api/v1/nome-api.docs.md` criado/atualizado a partir do [template](./nome-api.docs.md).
- [ ] `api/v1/nome-api.openapi.yaml` criado/atualizado a partir do [template](./nome-api.openapi.yaml).
- [ ] `api/v1/nome-api.postman.json` criado/atualizado, com exemplo de resposta real salvo em cada request.
- [ ] Nomes de arquivo em kebab-case e iguais ao nome do recurso na URL.

## Conteúdo

- [ ] Todos os endpoints implementados no `.p` (verifique cada `ut-api-action.i`) estão descritos no `.docs.md` e no `.openapi.yaml`.
- [ ] Tabela de parâmetros completa (path + query) para cada endpoint.
- [ ] Exemplo de corpo de requisição para todo `POST`/`PUT`.
- [ ] Exemplo de resposta de sucesso para todo endpoint.
- [ ] Seção "Possíveis erros" preenchida, incluindo `ErrorNumber`s específicos de negócio (além dos genéricos 400/404/409).
- [ ] Modelo de dados (tabela de campos) reflete o `SERIALIZE-NAME` do `.i`, não o nome de campo Progress.
- [ ] Envelope de erro padrão presente (copiado do template, sem necessidade de reescrever).
- [ ] Changelog com a entrada desta alteração.
- [ ] Exemplos usam dados fictícios plausíveis — nenhum dado real de cliente/empresa.

## Consistência

- [ ] `.docs.md` e `.openapi.yaml` descrevem os mesmos endpoints, com os mesmos nomes de campo.
- [ ] `BASE_URL`, `USERNAME` e `PASSWORD` usados como variáveis (nunca valores fixos).
