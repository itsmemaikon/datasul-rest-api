/*------------------------------------------------------------------------
    File        : extrato-cta-corrente.p
    Purpose     : API REST de leitura de extratos de conta corrente

    Syntax      : GET extrato-cta-corrente
                  GET extrato-cta-corrente/{id}
                  POST extrato-cta-corrente + payload
                  PUT extrato-cta-corrente/{id} + payload
                  DELETE extrato-cta-corrente/{id}
                  POST extrato-cta-corrente/{id}/linhas + payload                  
                  POST extrato-cta-corrente/{id}/linhas/{idLinha} + payload
                  DELETE extrato-cta-corrente/{id}/linhas/{idLinha}
                  GET extrato-cta-corrente/{id}/conferencia
                  
    Description : API REST de leitura de extratos de conta corrente

    Author(s)   : Maikon Lopes
    Created     : Mon Apr 20 09:00:00 BRT 2026
    Notes       :
  ----------------------------------------------------------------------*/
BLOCK-LEVEL ON ERROR UNDO, THROW.
/* ***************************  Definitions  ************************** */
{utp/ut-api.i}
{utp/ut-api-utils.i}
{fwk/utils/fndApiServices.i}

{include/i-prgvrs.i programs 2.00.00.001} /*** "010001" ***/

{utp/ut-api-action.i pi-conferencia-extrato GET /~*/conferencia/ }
{utp/ut-api-action.i pi-excluir-lin-extrato DELETE /~*/linhas/~* }
{utp/ut-api-action.i pi-alterar-lin-extrato PUT /~*/linhas/~* }
{utp/ut-api-action.i pi-criar-lin-extrato POST /~*/linhas/~* }
{utp/ut-api-action.i pi-excluir-extrato DELETE /~*/ }
{utp/ut-api-action.i pi-alterar-extrato PUT /~*/ }
{utp/ut-api-action.i pi-criar-extrato POST /~* }
{utp/ut-api-action.i pi-listar-extratos GET / }
{utp/ut-api-action.i pi-consultar-extrato GET /~* }

{utp/ut-api-notfound.i}

/** Definicao de temp-tables usadas no programa **/
{cmg/extrato-cta-corrente.i}
    
/** Definicao de datasets usados no programa **/       
DEFINE DATASET ds-extrato SERIALIZE-NAME "extrato" FOR tt-api-extrato, tt-api-lin-extrato 
    DATA-RELATION ds-extrato FOR tt-api-extrato, tt-api-lin-extrato
       RELATION-FIELDS(tt-api-extrato.num_extrat_cta_corren, tt-api-lin-extrato.num_extrat_cta_corren) NESTED.        
   
/** Variaveis **/
DEFINE NEW GLOBAL SHARED VARIABLE c-seg-usuario AS CHARACTER FORMAT "x(12)" NO-UNDO. 
DEFINE VARIABLE oJsonObject                     AS JsonObject           NO-UNDO.
DEFINE VARIABLE aJsonArray                      AS JsonArray            NO-UNDO.
DEFINE VARIABLE iCount                          AS INTEGER              NO-UNDO.    
DEFINE VARIABLE lHasNext                        AS LOGICAL              NO-UNDO.                   
DEFINE VARIABLE c-id                            AS CHARACTER            NO-UNDO.
DEFINE VARIABLE c-id-lin                        AS CHARACTER            NO-UNDO.
DEFINE VARIABLE h-api-handler                   AS HANDLE               NO-UNDO.
DEFINE VARIABLE h-dbo-extrat_cta_corren         AS HANDLE               NO-UNDO.

/* **********************  Internal Procedures  *********************** */
PROCEDURE pi-listar-extratos:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite retornar uma listagem de extratos de conta
          corrente e acordo com os filtros informados na requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### LISTAGEM EXTRATOS CTA CORRENTE - INICIO ####").

    DEFINE INPUT  PARAMETER oJsonInput      AS JsonObject       NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput     AS JsonObject       NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 1).
        RUN pi-listar-extratos  IN h-api-handler(INPUT-OUTPUT TABLE tt-param,
                                                 OUTPUT TABLE tt-api-extrato,
                                                 OUTPUT TABLE RowErrors
                                                 ).
    END.    
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:    
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.  
        
        RUN pi-json-saida(1, OUTPUT oJsonOutput).
    
        MESSAGE("#### LISTAGEM EXTRATOS CTA CORRENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.     
END PROCEDURE.

PROCEDURE pi-consultar-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite consultar os dados um extrato de conta corrente 
          especifico, de acordo com o recid informado na requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### CONSULTA DE EXTRATO CTA CORRENTE - INICIO ####").

    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 2).
        RUN pi-consultar-extrato  IN h-api-handler(c-id,
                                                   OUTPUT TABLE tt-api-extrato,
                                                   OUTPUT TABLE tt-api-lin-extrato,                                                   
                                                   OUTPUT TABLE RowErrors
                                                   ).                                                                                                     
    END.    
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:  
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(2, OUTPUT oJsonOutput).
        
        MESSAGE("#### CONSULTA DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.        
    END FINALLY.   
END PROCEDURE.

PROCEDURE pi-criar-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite adicionar um novo extrato de conta corrente, 
          de acordo com os dados informados no corpo da requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### CRIACAO DE EXTRATO CTA CORRENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 3).
        RUN pi-criar-extrato  IN h-api-handler(INPUT TABLE tt-extrat_cta_corren,
                                               OUTPUT TABLE tt-api-extrato,                                                   
                                               OUTPUT TABLE RowErrors
                                                 ).
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.    
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(3, OUTPUT oJsonOutput).
        
        MESSAGE("#### CRIACAO DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.

PROCEDURE pi-alterar-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite alterar uma extrato existente, de acordo com o 
          rowid do extrato e os dados informados no corpo da requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### ALTERACAO DE EXTRATO CTA CORRENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 4).
        RUN pi-alterar-extrato  IN h-api-handler(c-id,
                                                 INPUT TABLE tt-extrat_cta_corren,
                                                 OUTPUT TABLE tt-api-extrato,                                                   
                                                 OUTPUT TABLE RowErrors
                                                 ).
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.    
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(4, OUTPUT oJsonOutput).
        
        MESSAGE("#### ALTERACAO DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.


PROCEDURE pi-excluir-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite excluir uma linha de um extrato de conta
          corrente existente, de acordo com id do extrato e linha informados.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### EXCLUSAO DE EXTRATO CTA CORRENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 5).
        RUN pi-excluir-extrato  IN h-api-handler(c-id,
                                                 OUTPUT TABLE RowErrors
                                                 ).
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.    
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(5, OUTPUT oJsonOutput).
        
        MESSAGE("#### EXCLUSAO DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.

PROCEDURE pi-criar-lin-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite adicionar uma nova linha a um extrato de conta
          corrente existente, de acordo com id do extrato e os dados informados 
          no corpo da requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### CRIACAO DE LINHA DE EXTRATO CTA CORRENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 6).
        RUN pi-criar-lin-extrato  IN h-api-handler(c-id,
                                                   INPUT-OUTPUT TABLE tt-api-lin-extrato,
                                                   OUTPUT TABLE RowErrors
                                                   ).
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.    
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(6, OUTPUT oJsonOutput).
        
        MESSAGE("#### CRIACAO DE LINHA DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.

PROCEDURE pi-alterar-lin-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite alterar uma linha de um extrato existente, 
          de acordo com o id do extrato, o id da linha do extrato e os dados 
          informados no corpo da requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### ALTERACAO DE LINHA DE EXTRATO CTA CORRENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 7).
        RUN pi-alterar-lin-extrato  IN h-api-handler(c-id,
                                                     c-id-lin,
                                                     INPUT TABLE tt-lin_extrat_cta_corren,
                                                     OUTPUT TABLE tt-api-lin-extrato,                                                   
                                                     OUTPUT TABLE RowErrors
                                                     ).
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.    
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(7, OUTPUT oJsonOutput).
        
        MESSAGE("#### ALTERACAO DE LINHA DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.

PROCEDURE pi-excluir-lin-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite excluir uma linha de um extrato de conta
          corrente existente, de acordo com id do extrato e linha informados.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### EXCLUSAO DE LINHA DE EXTRATO CTA CORRENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 8).
        RUN pi-excluir-lin-extrato  IN h-api-handler(c-id,
                                                     c-id-lin,
                                                     OUTPUT TABLE RowErrors
                                                     ).
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.    
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(8, OUTPUT oJsonOutput).
        
        MESSAGE("#### EXCLUSAO DE LINHA DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.

PROCEDURE pi-conferencia-extrato:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite realizar a conferencia dos valores de um extrato 
           de conta corrente 
          especifico, de acordo com o recid informado na requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### CONFERENCIA DE EXTRATO CTA CORRENTE - INICIO ####").

    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 9).
        RUN pi-conferencia-extrato  IN h-api-handler(c-id,
                                                     OUTPUT TABLE tt-api-conferencia,
                                                     OUTPUT TABLE RowErrors
                                                   ).                                                                                                     
    END.    
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:  
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-api-handler) THEN
            DELETE OBJECT h-api-handler.      
    
        RUN pi-json-saida(9, OUTPUT oJsonOutput).
        
        MESSAGE("#### CONFERENCIA DE EXTRATO CTA CORRENTE - FIM ####").
        RETURN 'OK'.        
    END FINALLY.   
END PROCEDURE.


PROCEDURE pi-json-entrada:
/*------------------------------------------------------------------------------
 Purpose: Realiza o parse e tratamento do json de entrada enviado na informado 
          no corpo da requisicao.
 Notes:
------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER oJsonInput          AS JsonObject           NO-UNDO.
    DEFINE INPUT  PARAMETER ip-tipo             AS INTEGER              NO-UNDO.

    /** Variaveis com informacos presentes no parametro de INPUT da requisicao **/
    DEFINE VARIABLE oRequestParser              AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE oHeaders                    AS JsonObject           NO-UNDO.
    DEFINE VARIABLE oBody                       AS JsonObject           NO-UNDO.
    DEFINE VARIABLE aPathParams                 AS JsonArray            NO-UNDO.
    DEFINE VARIABLE oQueryParams                AS JsonObject           NO-UNDO.
                                                                        
    DEFINE VARIABLE iStartRow                   AS INTEGER              NO-UNDO.
    DEFINE VARIABLE iPageSize                   AS INTEGER              NO-UNDO.
    DEFINE VARIABLE cFields                     AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE cExpandables                AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE lcPayload                   AS LONGCHAR             NO-UNDO.  
           
    IF ip-tipo = 1 THEN
        /** Coleta os dados da requisicao efetuada com paginacao **/
        RUN parseInputParameters(INPUT oJsonInput, OUTPUT oHeaders, OUTPUT aPathParams, OUTPUT oQueryParams, OUTPUT iStartRow, OUTPUT iPageSize, OUTPUT cFields, OUTPUT cExpandables, OUTPUT lcPayload).    
    ELSE DO:        
        /** Coleta os dados da requisicao efetuada **/
        oRequestParser  = NEW JsonAPIRequestParser(oJsonInput).
        oHeaders        = oRequestParser:getHeaders().    
        oBody           = oRequestParser:getPayload().
        oQueryParams    = oRequestParser:getQueryParams().
        aPathParams     = oRequestParser:getPathParams().
        lcPayload       = oRequestParser:getPayloadLongChar(). 
    END.
    
    /** Instancia os handles que serao usados no programa **/
    IF NOT VALID-HANDLE(h-api-handler) THEN
        RUN cmg/extrato-cta-corrente.p PERSISTENT SET h-api-handler.      

    IF ip-tipo = 1 THEN DO:                
        CREATE tt-param.    
        /** Passando os parametros passados via Query Params para a temp-table tt-param **/     
        IF oQueryParams:Has("contaCorrente") THEN
            ASSIGN tt-param.cod_cta_corren      = oQueryParams:GetJsonArray("contaCorrente"):GetCharacter(1).
                   
        IF oQueryParams:Has("extrato") THEN
            ASSIGN tt-param.num_extrat_cta_corren = INT(oQueryParams:GetJsonArray("extrato"):GetCharacter(1)).
                                                
        IF oQueryParams:Has("dataInicial") THEN
            ASSIGN tt-param.dat_extrat_cta_corren_inic = oQueryParams:GetJsonArray("dataInicial"):GetDate(1).
            
        IF oQueryParams:Has("dataFinal") THEN
            ASSIGN tt-param.dat_extrat_cta_corren_final = oQueryParams:GetJsonArray("dataFinal"):GetDate(1).
            
        /** Filtrar registros pelo campo de search **/
        IF oQueryParams:Has("search") THEN        
            ASSIGN tt-param.buscar-texto = oQueryParams:GetJsonArray("search"):GetCharacter(1).        
        IF oQueryParams:Has("quickSearch") THEN        
            ASSIGN tt-param.buscar-texto = oQueryParams:GetJsonArray("quickSearch"):GetCharacter(1).
            
        /** Obtendo a paginacao e o indice primeiro registro atual selecionado **/        
        ASSIGN tt-param.registro-atual = iStartRow
               tt-param.qtd-paginas    = iPageSize.                                   
    END.               
        
    IF ip-tipo = 2 
    OR ip-tipo = 4 
    OR ip-tipo = 5
    OR ip-tipo = 6
    OR ip-tipo = 7
    OR ip-tipo = 8
    OR ip-tipo = 9
    THEN DO:    
        // Obtem o ID
        c-id = oRequestParser:getPathParams():getCharacter(1) NO-ERROR.
        MESSAGE("#### EXTRATO: " + c-id + " ####").        
    END.
    
    IF ip-tipo = 7 
    OR ip-tipo = 8 THEN DO:
        // Obtem o ID da linha
        c-id-lin = oRequestParser:getPathParams():getCharacter(3) NO-ERROR.
        MESSAGE("#### LINHA DO EXTRATO: " + c-id-lin + " ####").                    
    END.
    
    IF ip-tipo = 3 THEN DO:                              
        /** Criar os registros da temp-table com base body da requisicao **/
        CREATE tt-extrat_cta_corren.
        ASSIGN tt-extrat_cta_corren.cod_cta_corren               = oBody:getCharacter("contaCorrente")
               tt-extrat_cta_corren.des_refer_extrat_cta_corren  = oBody:getCharacter("referenciaExtrato")
               tt-extrat_cta_corren.dat_extrat_cta_corren_inic   = oBody:getDate("dataInicial")
               tt-extrat_cta_corren.dat_extrat_cta_corren_fim    = oBody:getDate("dataFinal")
               tt-extrat_cta_corren.val_extrat_cta_corren_inic   = oBody:getDecimal("saldoInicial")
               tt-extrat_cta_corren.val_extrat_cta_corren_fim    = oBody:getDecimal("saldoFinal").                   
                                                     
        MESSAGE " #### tt-extrat_cta_corren.cod_cta_corren:              " tt-extrat_cta_corren.cod_cta_corren SKIP
                " #### tt-extrat_cta_corren.num_extrat_cta_corren:       " tt-extrat_cta_corren.num_extrat_cta_corren SKIP
                " #### tt-extrat_cta_corren.des_refer_extrat_cta_corren  " tt-extrat_cta_corren.des_refer_extrat_cta_corren SKIP  
                " #### tt-extrat_cta_corren.dat_extrat_cta_corren_inic   " tt-extrat_cta_corren.dat_extrat_cta_corren_inic SKIP  
                " #### tt-extrat_cta_corren.dat_extrat_cta_corren_fim    " tt-extrat_cta_corren.dat_extrat_cta_corren_fim SKIP   
                " #### tt-extrat_cta_corren.val_extrat_cta_corren_inic   " tt-extrat_cta_corren.val_extrat_cta_corren_inic SKIP  
                " #### tt-extrat_cta_corren.val_extrat_cta_corren_fim    " tt-extrat_cta_corren.val_extrat_cta_corren_fim SKIP.
    END.    
            
    IF ip-tipo = 4 THEN DO:                              
        /** Altera os registros da temp-table com base body da requisicao **/
        CREATE tt-extrat_cta_corren.
        ASSIGN tt-extrat_cta_corren.des_refer_extrat_cta_corren  = oBody:getCharacter("referenciaExtrato")
               tt-extrat_cta_corren.dat_extrat_cta_corren_inic   = oBody:getDate("dataInicial")
               tt-extrat_cta_corren.dat_extrat_cta_corren_fim    = oBody:getDate("dataFinal")
               tt-extrat_cta_corren.val_extrat_cta_corren_inic   = oBody:getDecimal("saldoInicial")
               tt-extrat_cta_corren.val_extrat_cta_corren_fim    = oBody:getDecimal("saldoFinal").                   
    END.
    
    IF ip-tipo = 6 THEN DO:                              
        // Transfere o conteudo do JSON que esta em um longchar para a temp-table
        TEMP-TABLE tt-api-lin-extrato:READ-JSON('LONGCHAR',lcPayload,'EMPTY').
        FIND FIRST tt-api-lin-extrato.
    END. 
    
    IF ip-tipo = 7 THEN DO:                              
        /** Altera os registros da temp-table com base body da requisicao **/
        CREATE tt-lin_extrat_cta_corren.
        ASSIGN tt-lin_extrat_cta_corren.cod_docto_movto_cta_bco     = oBody:getCharacter("doctoBanco")
               tt-lin_extrat_cta_corren.cod_tip_lancto_extrat       = oBody:getCharacter("tipoLancamento")
               tt-lin_extrat_cta_corren.ind_fluxo_movto_cta_corren  = oBody:getCharacter("fluxoMovto")
               tt-lin_extrat_cta_corren.val_lin_extrat_cta_corren   = oBody:getDecimal("vlMovto")
               tt-lin_extrat_cta_corren.des_histor_movto_cta_corren = oBody:getCharacter("historicoMovto").                                                                                           
    END.    
        
    RETURN "OK".    
END PROCEDURE.

PROCEDURE pi-json-saida:
/*------------------------------------------------------------------------------
 Purpose: Realiza o parse e tratamento do json de saida devolvido na requisicao.
 Notes:                                                                  Y3
------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER ip-tipo     AS INTEGER              NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DEFINE VARIABLE oResponse           AS JsonAPIResponse      NO-UNDO.
                           
    /** Retorna o json de retorno para a interface HTML **/
    IF CAN-FIND(FIRST RowErrors NO-LOCK) THEN DO:       
        oResponse = NEW JsonAPIResponse(oJsonObject).
        oResponse:setHasNext(FALSE).
        oResponse:setRowErrors(JsonAPIUtils:convertTempTableToJsonObject(TEMP-TABLE RowErrors:HANDLE):getJsonArray("RowErrors")).        
                        
        IF CAN-FIND(FIRST RowErrors NO-LOCK
                    WHERE RowErrors.ErrorNumber = 2) THEN
            oResponse:setStatus(404).                    
        ELSE IF CAN-FIND(FIRST RowErrors NO-LOCK
                    WHERE RowErrors.ErrorNumber = 1) THEN
            oResponse:setStatus(409).
        ELSE
            oResponse:setStatus(400).                                                     
    END.
    ELSE DO:
        IF ip-tipo = 1 THEN DO: 
            FIND FIRST tt-param.
        
            /** Obtem um jsonArray com base no conteudo da temp-table **/
            aJsonArray  = JsonAPIUtils:convertTempTableToJsonArray(TEMP-TABLE tt-api-extrato:HANDLE).
            oResponse   = NEW JsonAPIResponse(aJsonArray).
            oResponse:setHasNext(tt-param.prox-pagina).
            oResponse:setStatus(200).
        END.
        
        IF ip-tipo = 2
        OR ip-tipo = 4 
        THEN DO:
            /** Obtem um JsonObject com base no conteudo do dataset **/
            oJsonObject  = JsonAPIUtils:convertDatasetFirstItemToJsonObject (DATASET ds-extrato:HANDLE).
            oResponse    = NEW JsonAPIResponse(oJsonObject).          
            oResponse:setStatus(200).
        END.
        
        IF ip-tipo = 3 
        THEN DO:
            /** Obtem um JsonObject com base no conteudo da temp-table **/
            oJsonObject  = JsonAPIUtils:convertTempTableFirstItemToJsonObject (TEMP-TABLE tt-api-extrato:HANDLE).
            oResponse    = NEW JsonAPIResponse(oJsonObject).          
            oResponse:setStatus(201).
        END.        
        
        IF ip-tipo = 6  THEN DO:
            /** Obtem um JsonObject com base no conteudo da temp-table **/
            oJsonObject  = JsonAPIUtils:convertTempTableFirstItemToJsonObject (TEMP-TABLE tt-api-lin-extrato:HANDLE).
            oResponse    = NEW JsonAPIResponse(oJsonObject).
            oResponse:setStatus(201).
        END.
        
        IF ip-tipo = 7  THEN DO:
            /** Obtem um JsonObject com base no conteudo da temp-table **/
            oJsonObject  = JsonAPIUtils:convertTempTableFirstItemToJsonObject (TEMP-TABLE tt-api-lin-extrato:HANDLE).
            oResponse    = NEW JsonAPIResponse(oJsonObject).
            oResponse:setStatus(200).
        END.        
        
        IF ip-tipo = 5  
        OR ip-tipo = 8
        THEN DO:        
            oJsonObject = NEW JSONObject().
            oJsonObject:ADD('code', 1).
            oJsonObject:ADD('message', 'Registro exclu¡do com sucesso').
            oJsonObject:ADD('type', 'information').
            oResponse   = NEW JsonAPIResponse(oJsonObject).
            oResponse:setStatus(200).        
        END.
        
        IF ip-tipo = 9  
        THEN DO:
            /** Obtem um JsonObject com base no conteudo do dataset **/
            oJsonObject  = JsonAPIUtils:convertTempTableFirstItemToJsonObject (TEMP-TABLE tt-api-conferencia:HANDLE).
            oResponse    = NEW JsonAPIResponse(oJsonObject).          
            oResponse:setStatus(200).
        END.        
        
    END.    
    oJsonOutput = oResponse:createJsonResponse().  
            
    /** Delete os handles usados no programa **/
    IF VALID-HANDLE(h-api-handler) THEN
        DELETE OBJECT h-api-handler.              
END PROCEDURE.

PROCEDURE pi-erros:
/*------------------------------------------------------------------------------
 Purpose: Realiza o tratamento de erros e cria a temp-table RowErrors
 Notes:
------------------------------------------------------------------------------*/
    DEFINE INPUT PARAMETER err AS PROGRESS.Lang.Error.

    DO  iCount = 1 TO err:NumMessages:
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber        = err:GetMessageNum(iCount)
               RowErrors.ErrorType          = "EMS"
               RowErrors.ErrorSubType       = "ERROR"                        
               RowErrors.ErrorDescription   = err:GetMessage(iCount).
    END.   
END PROCEDURE.

/**** Tipos de requisicao ****
      1 - Listar extratos
      2 - Consultar um extrato especifico
      3 - Criar um extrato
      4 - Alterar um extrato
      5 - Excluir um extrato
      6 - Criar uma linha de extrato
      7 - Alterar uma linha de extrato
      8 - Excluir uma linha de extrato
      9 - Realizar a conferencia de extrato
*****/
