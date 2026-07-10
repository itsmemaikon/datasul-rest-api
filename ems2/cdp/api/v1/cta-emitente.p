/*------------------------------------------------------------------------
    File        : cta-emitente.p
    Purpose     : API REST de leitura de conta correntes do emitente

    Syntax      : GET cta-emitente
                  GET cta-emitente/{id}
                  POST cta-emitente + payload
                  PUT cta-emitente/{id} + payload
                  DELETE cta-emitente/{id}
                  
    Description : API REST de leitura de conta correntes do emitente

    Author(s)   : Maikon Lopes
    Created     : Thu Jul 09 17:21:00 BRT 2026
    Notes       :
  ----------------------------------------------------------------------*/
BLOCK-LEVEL ON ERROR UNDO, THROW.
/* ***************************  Definitions  ************************** */
{utp/ut-api.i}
{utp/ut-api-utils.i}
{fwk/utils/fndApiServices.i}

{include/i-prgvrs.i programs 2.00.00.001} /*** "010001" ***/

{utp/ut-api-action.i pi-excluir-conta DELETE /~*/ }
{utp/ut-api-action.i pi-alterar-conta PUT /~*/ }
{utp/ut-api-action.i pi-criar-conta POST /~* }
{utp/ut-api-action.i pi-listar-contas GET / }
{utp/ut-api-action.i pi-consultar-conta GET /~* }

{utp/ut-api-notfound.i}

/** Definicao de temp-tables usadas no programa **/
{cdp/cta-emitente.i}
    
/** Definicao de datasets usados no programa **/       

   
/** Variaveis **/
DEFINE NEW GLOBAL SHARED VARIABLE c-seg-usuario AS CHARACTER FORMAT "x(12)" NO-UNDO. 
DEFINE VARIABLE oJsonObject                     AS JsonObject           NO-UNDO.
DEFINE VARIABLE aJsonArray                      AS JsonArray            NO-UNDO.
DEFINE VARIABLE iCount                          AS INTEGER              NO-UNDO.    
DEFINE VARIABLE lHasNext                        AS LOGICAL              NO-UNDO.                   
DEFINE VARIABLE c-id                            AS CHARACTER            NO-UNDO.
DEFINE VARIABLE c-id-lin                        AS CHARACTER            NO-UNDO.
DEFINE VARIABLE h-api-handler                   AS HANDLE               NO-UNDO.

/* **********************  Internal Procedures  *********************** */
PROCEDURE pi-listar-contas:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite retornar uma listagem de contas correntes de 
          emitente de acordo com os filtros informados na requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### LISTAGEM CTA CORRENTE EMITENTE - INICIO ####").

    DEFINE INPUT  PARAMETER oJsonInput      AS JsonObject       NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput     AS JsonObject       NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 1).
        RUN pi-listar-contas  IN h-api-handler(INPUT-OUTPUT TABLE tt-param,
                                               OUTPUT TABLE tt-api-conta,
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
    
        MESSAGE("#### LISTAGEM CTA CORRENTE EMITENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.     
END PROCEDURE.

PROCEDURE pi-consultar-conta:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite consultar os dados uma conta corrente especifica
          de um emitente de acordo com o recid informado na requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### CONSULTA DE CTA CORRENTE EMITENTE - INICIO ####").

    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 2).
        RUN pi-consultar-conta    IN h-api-handler(INPUT c-id,
                                                   OUTPUT TABLE tt-api-conta,                                                   
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
        
        MESSAGE("#### CONSULTA DE CTA CORRENTE EMITENTE - FIM ####").
        RETURN 'OK'.        
    END FINALLY.   
END PROCEDURE.

PROCEDURE pi-criar-conta:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite adicionar um nova conta corrente do emitente, 
          de acordo com os dados informados no corpo da requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### CRIACAO DE CTA CORRENTE EMITENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 3).
        RUN pi-criar-conta IN h-api-handler(INPUT TABLE tt-cta-emitente,
                                            OUTPUT TABLE tt-api-conta,                                                   
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
        
        MESSAGE("#### CRIACAO DE CTA CORRENTE EMITENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.

PROCEDURE pi-alterar-conta:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite alterar uma conta corrente do emitente, 
          de acordo com o recid da conta e os dados informados no corpo da 
          requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### ALTERACAO DE CTA CORRENTE EMITENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 4).
        RUN pi-alterar-conta IN h-api-handler(c-id,
                                              INPUT TABLE tt-cta-emitente,
                                              OUTPUT TABLE tt-api-conta,                                                   
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
        
        MESSAGE("#### ALTERACAO DE CTA CORRENTE EMITENTE - FIM ####").
        RETURN 'OK'.       
    END FINALLY.                   
END PROCEDURE.

PROCEDURE pi-excluir-conta:
/*------------------------------------------------------------------------------
 Purpose: Este endpoint permite excluir uma conta corrente do emitente existente, 
          de acordo com o recid informado na requisicao.
 Notes:
------------------------------------------------------------------------------*/
    MESSAGE("#### EXCLUSAO DE CTA CORRENTE EMITENTE - INICIO ####").
         
    DEFINE INPUT  PARAMETER oJsonInput  AS JsonObject           NO-UNDO.
    DEFINE OUTPUT PARAMETER oJsonOutput AS JsonObject           NO-UNDO.
    
    DO ON ERROR UNDO, THROW:  
        RUN pi-json-entrada(INPUT oJsonInput, 5).
        RUN pi-excluir-conta IN h-api-handler(c-id,
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
        
        MESSAGE("#### EXCLUSAO DE CTA CORRENTE EMITENTE - FIM ####").
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
        RUN cdp/cta-emitente.p PERSISTENT SET h-api-handler.      

    IF ip-tipo = 1 THEN DO:                
        CREATE tt-param.    
        /** Passando os parametros passados via Query Params para a temp-table tt-param **/     
        IF oQueryParams:Has("emitente") THEN
            ASSIGN tt-param.cod-emitente      = INT(oQueryParams:GetJsonArray("emitente"):GetCharacter(1)).
                   
        IF oQueryParams:Has("banco") THEN
            ASSIGN tt-param.cod-banco = INT(oQueryParams:GetJsonArray("banco"):GetCharacter(1)).
            
        IF oQueryParams:Has("agencia") THEN
            ASSIGN tt-param.agencia   = oQueryParams:GetJsonArray("agencia"):GetCharacter(1).
            
        IF oQueryParams:Has("contaCorrente") THEN
            ASSIGN tt-param.conta-corrente   = oQueryParams:GetJsonArray("contaCorrente"):GetCharacter(1).                                                             

        IF oQueryParams:Has("preferencial") THEN
            ASSIGN tt-param.preferencial  = IF oQueryParams:GetJsonArray("preferencial"):GetCharacter(1) = "true" THEN YES ELSE NO. 
                        
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
    THEN DO:    
        // Obtem o ID
        c-id = oRequestParser:getPathParams():getCharacter(1) NO-ERROR.
        MESSAGE("#### CTA CORRENTE EMITENTE: " + c-id + " ####").        
    END.
    
    IF ip-tipo = 3 THEN DO:                              
        /** Criar os registros da temp-table com base body da requisicao **/
        CREATE tt-cta-emitente.
        ASSIGN tt-cta-emitente.cod-emitente   = oBody:getInteger("emitente")
               tt-cta-emitente.cod-banco      = oBody:getInteger("banco")
               tt-cta-emitente.agencia        = oBody:getCharacter("agencia")
               tt-cta-emitente.conta-corrente = oBody:getCharacter("contaCorrente")
               tt-cta-emitente.preferencial   = oBody:getLogical("preferencial")
               tt-cta-emitente.descricao      = oBody:getCharacter("descricao").                   
                                                     
        MESSAGE " #### tt-cta-emitente.cod-emitente   " tt-cta-emitente.cod-emitente SKIP
                " #### tt-cta-emitente.cod-banco      " tt-cta-emitente.cod-banco SKIP
                " #### tt-cta-emitente.agencia        " tt-cta-emitente.agencia SKIP  
                " #### tt-cta-emitente.conta-corrente " tt-cta-emitente.conta-corrente SKIP  
                " #### tt-cta-emitente.preferencial   " tt-cta-emitente.preferencial SKIP   
                " #### tt-cta-emitente.descricao      " tt-cta-emitente.descricao SKIP.
    END.    
            
    IF ip-tipo = 4 THEN DO:                              
        /** Altera os registros da temp-table com base body da requisicao **/
        CREATE tt-cta-emitente.
        ASSIGN tt-cta-emitente.cod-banco      = oBody:getInteger("banco")
               tt-cta-emitente.agencia        = oBody:getCharacter("agencia")
               tt-cta-emitente.conta-corrente = oBody:getCharacter("contaCorrente")
               tt-cta-emitente.preferencial   = oBody:getLogical("preferencial")
               tt-cta-emitente.descricao      = oBody:getCharacter("descricao"). 
                              
        MESSAGE " #### tt-cta-emitente.cod-emitente   " tt-cta-emitente.cod-emitente SKIP
                " #### tt-cta-emitente.cod-banco      " tt-cta-emitente.cod-banco SKIP
                " #### tt-cta-emitente.agencia        " tt-cta-emitente.agencia SKIP  
                " #### tt-cta-emitente.conta-corrente " tt-cta-emitente.conta-corrente SKIP  
                " #### tt-cta-emitente.preferencial   " tt-cta-emitente.preferencial SKIP   
                " #### tt-cta-emitente.descricao      " tt-cta-emitente.descricao SKIP.               
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
            aJsonArray  = JsonAPIUtils:convertTempTableToJsonArray(TEMP-TABLE tt-api-conta:HANDLE).
            oResponse   = NEW JsonAPIResponse(aJsonArray).
            oResponse:setHasNext(tt-param.prox-pagina).
            oResponse:setStatus(200).
        END.
        
        IF ip-tipo = 2
        OR ip-tipo = 4 
        THEN DO:
            /** Obtem um JsonObject com base no conteudo do dataset **/
            oJsonObject  = JsonAPIUtils:convertTempTableFirstItemToJsonObject (TEMP-TABLE tt-api-conta:HANDLE).
            oResponse    = NEW JsonAPIResponse(oJsonObject).          
            oResponse:setStatus(200).
        END.
        
       IF ip-tipo = 3
        THEN DO:
            /** Obtem um JsonObject com base no conteudo do dataset **/
            oJsonObject  = JsonAPIUtils:convertTempTableFirstItemToJsonObject (TEMP-TABLE tt-api-conta:HANDLE).
            oResponse    = NEW JsonAPIResponse(oJsonObject).          
            oResponse:setStatus(201).
        END.        
                            
        IF ip-tipo = 5  
        THEN DO:        
            oJsonObject = NEW JSONObject().
            oJsonObject:ADD('code', 1).
            oJsonObject:ADD('message', 'Registro exclu¡do com sucesso').
            oJsonObject:ADD('type', 'information').
            oResponse   = NEW JsonAPIResponse(oJsonObject).
            oResponse:setStatus(204).        
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
      1 - Listar contas
      2 - Consultar uma conta especifica
      3 - Criar uma conta
      4 - Alterar uma conta 
      5 - Excluir uma conta
*****/
