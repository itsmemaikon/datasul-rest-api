/**********************************************************************************
**  Programa....: cta-emitente.p - Manutencao Conta Corrente de Emitente
**  Data........: 09/07/2026
**  Autor.......: Maikon Lopes
**  Objetivo....: Realiza o consultas e manutencao na tabela cta-emitente 
**  Observaá‰es.:     
***********************************************************************************
**  Alteraá‰es..:
***********************************************************************************/

/** Definicao de temp-tables usadas no programa **/
{cdp/cta-emitente.i}
{method/dbotterr.i}            /** Definicao temp-table RowErrors **/

{utp/ut-glob.i}

DEFINE VARIABLE iCount                      AS INTEGER                      NO-UNDO.

DEFINE VARIABLE i                           AS INTEGER                      NO-UNDO.
DEFINE VARIABLE l-integra                   AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE l-dig                       AS LOGICAL      INITIAL NO      NO-UNDO.
DEFINE VARIABLE c-agencia                   AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE c-agencia-aux               AS CHARACTER    FORMAT "x(9)"   NO-UNDO.
DEFINE VARIABLE c-agencia-aux2              AS CHARACTER    FORMAT "x(9)"   NO-UNDO.
DEFINE VARIABLE c-formato-agencia           AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE c-char                      AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE c-conta-corrente            AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE c-conta-aux                 AS CHARACTER    FORMAT "x(12)"  NO-UNDO.
DEFINE VARIABLE c-conta-aux2                AS CHARACTER    FORMAT "x(12)"  NO-UNDO.
DEFINE VARIABLE c-formato-conta             AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE c-char2                     AS CHARACTER                    NO-UNDO.
DEFINE VARIABLE l-valid-cta-pref            AS LOGICAL                      NO-UNDO.
DEFINE VARIABLE i-nr-prefer                 AS INTEGER                      NO-UNDO.

DEFINE BUFFER b-emitente                    FOR emitente.
DEFINE BUFFER b-cta-emitente                FOR cta-emitente.


/**PROCEDURES INTERNAS **/    
PROCEDURE pi-listar-contas:
/*------------------------------------------------------------------------------
  Purpose:     Retorna uma listagem de registros de contas correntes de emitente 
               de acordo com os filtros informados.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/       
    DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR tt-param.
    DEFINE OUTPUT        PARAMETER TABLE FOR tt-api-conta.
    DEFINE OUTPUT        PARAMETER TABLE FOR RowErrors.

    DEFINE VARIABLE i-contagem          AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-query             AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-matches           AS CHARACTER   NO-UNDO.
        
    DO ON ERROR UNDO, THROW:      
        FIND FIRST tt-param.
                                         
        /** MontANDo a query para buscar na tabela **/
        ASSIGN c-query = "FOR EACH cta-emitente NO-LOCK WHERE 0 = 0 ".
           
        IF tt-param.cod-emitente > 0 THEN
            ASSIGN c-query = c-query + "AND cta-emitente.cod-emitente = '" + string(tt-param.cod-emitente) + "' ".
                                                   
        IF tt-param.cod-banco > 0 THEN
            ASSIGN c-query = c-query + "AND cta-emitente.cod-banco = '" + string(tt-param.cod-banco) + "' ".
            
        IF tt-param.agencia <> "" THEN
            ASSIGN c-query = c-query + "AND cta-emitente.agencia = '" + tt-param.agencia + "' ".            
            
        IF tt-param.conta-corrente <> "" THEN
            ASSIGN c-query = c-query + "AND cta-emitente.conta-corrente = '" + tt-param.conta-corrente + "' ". 
            
        IF tt-param.preferencial <> ? THEN
            ASSIGN c-query = c-query + "AND cta-emitente.preferencial = '" + string(tt-param.preferencial) + "' ".             
                                    
        /** Executa a query para buscar as informacoes de acordo com os filtros e paginanacao **/
        DEFINE QUERY FINDQuery FOR cta-emitente
        SCROLLING.
        
        QUERY FINDQuery:QUERY-PREPARE(c-query).
        QUERY FINDQuery:QUERY-OPEN().
        QUERY FINDQuery:REPOSITION-TO-ROW(tt-param.registro-atual).
        
        EMPTY TEMP-TABLE tt-api-conta.
        
        REPEAT:
            GET NEXT FINDQuery.
            IF QUERY FINDQuery:QUERY-OFF-END THEN LEAVE.
            
            IF tt-param.qtd-paginas EQ i-contagem THEN DO:
                ASSIGN tt-param.prox-pagina = TRUE.
                LEAVE.
            END.
            ELSE
                ASSIGN tt-param.prox-pagina = FALSE.
            
                                                
            /** Filtrar registros pelo campo de search **/
            IF tt-param.buscar-texto <> "" THEN DO:        
                ASSIGN c-matches = "*" + TRIM(tt-param.buscar-texto) + "*".        
                                             
                IF NOT (string(cta-emitente.cod-emitente) MATCHES c-matches 
                    OR  string(cta-emitente.cod-banco)    MATCHES c-matches 
                    OR  cta-emitente.agencia              MATCHES c-matches 
                    OR  cta-emitente.conta-corrente       MATCHES c-matches 
                    OR  cta-emitente.descricao            MATCHES c-matches
                    ) THEN NEXT.
            END.      
                                                                             
            CREATE tt-api-conta.
            BUFFER-COPY cta-emitente TO tt-api-conta
            ASSIGN tt-api-conta.r-recid  = RECID(cta-emitente).               
                  
            ASSIGN i-contagem = i-contagem + 1.        
        END.
        QUERY FINDQuery:QUERY-CLOSE().
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:         
        RETURN "OK".
    END FINALLY.         
END PROCEDURE.

PROCEDURE pi-consultar-conta:
/*------------------------------------------------------------------------------
  Purpose:     Retorna o registro de uma conta corrente de emitente de acordo 
               com o recid informado.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT PARAMETER ip-id        AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-conta.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors. 

    DO ON ERROR UNDO, THROW:      
        FIND FIRST cta-emitente NO-LOCK
             WHERE RECID(cta-emitente) = INT64(ip-id) NO-ERROR.
        IF AVAIL cta-emitente THEN DO:
            CREATE tt-api-conta.
            BUFFER-COPY cta-emitente TO tt-api-conta
            ASSIGN tt-api-conta.r-recid  = RECID(cta-emitente).
                                                                                                          
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "N∆o encontrado(a) conta corrente de emitente para chave informada."
                   RowErrors.ErrorHelp        = "N∆o foi encontrada ocorrància para conta corrente de emitente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".         
        END.
    END.        
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:         
        RETURN "OK".
    END FINALLY.          
END PROCEDURE.

PROCEDURE pi-criar-conta:
/*------------------------------------------------------------------------------
  Purpose:     Adiciona um  registro de conta corrente de emitente de acordo 
               com a temp-table informada.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/   
    DEFINE INPUT  PARAMETER TABLE FOR tt-cta-emitente.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-conta.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.
                  
    DO ON ERROR UNDO, THROW:    
        FIND FIRST tt-cta-emitente.

        RUN pi-validar(INPUT 1).            
            
        IF NOT CAN-FIND(FIRST RowErrors NO-LOCK
                        WHERE RowErrors.ErrorSubType = "ERROR") THEN DO:
                                                                                                                                       
            CREATE cta-emitente.
            ASSIGN cta-emitente.cod-emitente   = tt-cta-emitente.cod-emitente
                   cta-emitente.cod-banco      = tt-cta-emitente.cod-banco
                   cta-emitente.agencia        = tt-cta-emitente.agencia
                   cta-emitente.conta-corrente = tt-cta-emitente.conta-corrente
                   cta-emitente.descricao      = tt-cta-emitente.descricao
                   cta-emitente.preferencial   = tt-cta-emitente.preferencial.                        
                                                                                  
            /** Transfere o resultado da temp-table da DBO para a temp-table de retorno **/
            FIND FIRST cta-emitente NO-LOCK
                WHERE cta-emitente.cod-emitente   = tt-cta-emitente.cod-emitente
                  AND cta-emitente.cod-banco      = tt-cta-emitente.cod-banco 
                  AND cta-emitente.agencia        = tt-cta-emitente.agencia 
                  AND cta-emitente.conta-corrente = tt-cta-emitente.conta-corrente NO-ERROR.
            IF AVAIL cta-emitente THEN DO: 
                IF tt-cta-emitente.preferencial = YES THEN
                    RUN pi-atualiza-emitente. /** Realiza a atualizacao da conta na tabela do emitente **/             
                        
                RUN pi-integra-ems. /** Integracao 2.00 X 5.00 **/ 
                        
                CREATE tt-api-conta.
                BUFFER-COPY cta-emitente TO tt-api-conta
                     ASSIGN tt-api-conta.r-recid = RECID(cta-emitente).                        
            END.
            ELSE DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber      = 2
                       RowErrors.ErrorDescription = "N∆o encontrado(a) conta corrente do emitente para chave informada."
                       RowErrors.ErrorHelp        = "N∆o foi encontrada ocorrància para conta corrente do emitente com a chave informada."
                       RowErrors.ErrorSubType     = "ERROR".         
            END.
        END.                                                
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:
        RETURN "OK".
    END FINALLY.           
END PROCEDURE.

PROCEDURE pi-alterar-conta:
/*------------------------------------------------------------------------------
  Purpose:     Altera o registro de uma conta corrente de emitente de acordo 
               com o recid informado e a temp-table informada.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT  PARAMETER ip-id  AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR tt-cta-emitente.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-conta.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
    
    DO ON ERROR UNDO, THROW:    
        FIND FIRST tt-cta-emitente.         
        FIND FIRST cta-emitente EXCLUSIVE-LOCK
             WHERE RECID(cta-emitente) = INT64(ip-id) NO-ERROR.
        IF AVAIL cta-emitente THEN DO:
            BUFFER-COPY cta-emitente 
                 EXCEPT cta-emitente.cod-banco  
                        cta-emitente.agencia  
                        cta-emitente.conta-corrente   
                        cta-emitente.preferencial  
                        cta-emitente.descricao
                     TO tt-cta-emitente
                 ASSIGN tt-cta-emitente.r-rowid  = ROWID(cta-emitente).          
                
            RUN pi-validar(INPUT 2).            
                
            IF NOT CAN-FIND(FIRST RowErrors NO-LOCK
                            WHERE RowErrors.ErrorSubType = "ERROR") THEN DO:            
                                                           
                ASSIGN cta-emitente.cod-banco       = tt-cta-emitente.cod-banco                           
                       cta-emitente.agencia         = tt-cta-emitente.agencia                             
                       cta-emitente.conta-corrente  = tt-cta-emitente.conta-corrente                      
                       cta-emitente.preferencial    = tt-cta-emitente.preferencial                        
                       cta-emitente.descricao       = tt-cta-emitente.descricao.
                
                IF tt-cta-emitente.preferencial = YES THEN
                    RUN pi-atualiza-emitente. /** Realiza a atualizacao da conta na tabela do emitente **/ 
                
                RUN pi-integra-ems. /** Integracao 2.00 X 5.00 **/            
                 
                /** Transfere o resultado da temp-table da DBO para a temp-table de retorno **/
                CREATE tt-api-conta.
                BUFFER-COPY cta-emitente TO tt-api-conta
                     ASSIGN tt-api-conta.r-recid = RECID(cta-emitente).
            END.                     
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "N∆o encontrado(a) conta corrente do emitente para chave informada."
                   RowErrors.ErrorHelp        = "N∆o foi encontrada ocorrància para conta corrente do emitente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".            
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:       
        RETURN "OK".
    END FINALLY.              
END PROCEDURE.

PROCEDURE pi-excluir-conta:
/*------------------------------------------------------------------------------
  Purpose:     Excluir o registro uma conta corrente de emitente de acordo 
               o recid informado.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT         PARAMETER ip-id        AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
    
    DO ON ERROR UNDO, THROW:     
        FIND FIRST cta-emitente EXCLUSIVE-LOCK
             WHERE RECID(cta-emitente) = INT64(ip-id) NO-ERROR.
        IF AVAIL cta-emitente THEN DO:
            CREATE tt-cta-emitente.
            BUFFER-COPY cta-emitente TO tt-cta-emitente
                 ASSIGN tt-cta-emitente.r-rowid = ROWID(cta-emitente).
            FIND FIRST tt-cta-emitente NO-LOCK NO-ERROR.                  
                
            RUN pi-validar(INPUT 3).            
                
            IF NOT CAN-FIND(FIRST RowErrors NO-LOCK
                            WHERE RowErrors.ErrorSubType = "ERROR") THEN DO:            
                
                DELETE cta-emitente.
                
                /** Limpa a conta na tabela do emitente, se a conta excluida for preferencial **/
                IF tt-cta-emitente.preferencial = YES THEN DO:
                    FIND FIRST emitente EXCLUSIVE-LOCK
                         WHERE emitente.cod-emitente = tt-cta-emitente.cod-emitente
                           AND emitente.agencia      = tt-cta-emitente.agencia
                           AND emitente.conta-corren = tt-cta-emitente.conta-corrente NO-ERROR.
                    IF AVAIL emitente THEN
                        ASSIGN emitente.cod-banco    = 0
                               emitente.agencia      = '000000-00'
                               emitente.conta-corren = '0000000000-00'.
                END.
                                                               
                RUN pi-integra-ems. /** Integracao 2.00 X 5.00 **/
            END.
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "N∆o encontrado(a) conta corrente do emitente para chave informada."
                   RowErrors.ErrorHelp        = "N∆o foi encontrada ocorrància para conta corrente do emitente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".                
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:       
        RETURN "OK".
    END FINALLY.                
END PROCEDURE.

PROCEDURE pi-erros:
/*------------------------------------------------------------------------------
  Purpose:      Realiza o tratamento de erros e cria a temp-table RowErrors
  Parameters: 
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
    RETURN "NOK". 
END PROCEDURE.

PROCEDURE pi-validar :
/*------------------------------------------------------------------------------
  Purpose:      Validar os dados informados
  Parameters: 
  Notes:        
------------------------------------------------------------------------------*/
    DEFINE INPUT  PARAMETER ip-tipo            AS INTEGER     NO-UNDO.

    IF ip-tipo = 1 
    OR ip-tipo = 2 THEN DO: /** Inclusao ou Alteracao **/           
        /** Validacao de existencia de banco **/
        IF NOT CAN-FIND(FIRST banco NO-LOCK
                        WHERE banco.cod-banco = tt-cta-emitente.cod-banco) THEN DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "N∆o encontrado(a) banco para chave informada."
                   RowErrors.ErrorHelp        = "N∆o foi encontrada ocorrància para banco com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".              
        END.
        
        /** Validacao do formato do campo agencia (adaptado do programa cdp\cd0401h-v01.w) **/   
        ASSIGN c-agencia = tt-cta-emitente.agencia.            
               l-integra = no.  
        &IF DEFINED(BF_FIN_EMS2_X_MG) &THEN
            FIND FIRST funcao NO-LOCK
                 WHERE funcao.cd-funcao = "spp-ems2fin-x-mg" 
                   AND funcao.ativo     = YES  NO-ERROR.
            IF AVAIL funcao then
                ASSIGN l-integra = YES.
        &ENDIF

        IF (LENGTH(c-agencia, "character") < 8)
        OR (LENGTH(c-agencia, "character") = 8
        AND SUBSTRING(c-agencia, 8,2) = "-") THEN DO: 
            ASSIGN  c-agencia-aux = TRIM(SUBSTRING(c-agencia, 1,6)) 
                    c-agencia = FILL("0", 6 - LENGTH(c-agencia-aux)) + c-agencia-aux.
        END.

        ASSIGN c-formato-agencia = c-agencia NO-ERROR.
        IF ERROR-STATUS:ERROR
        OR LENGTH(c-agencia) > 8 THEN DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 15271
                   RowErrors.ErrorDescription = "O formato informado para a agància n∆o Ç valido."
                   RowErrors.ErrorHelp        = "ê necess†rio que o campo da agància seja composto por 6 n£meros da agància e mais 2 n£meros do d°gito da agància."
                   RowErrors.ErrorSubType     = "ERROR".         
                   
            {utp/ut-field.i mgadm cta-emitente agencia 1} 
            ASSIGN c-agencia-aux = TRIM(SUBSTRING(c-agencia, 1,6))
                   c-agencia = FILL("0", 6 - LENGTH(c-agencia-aux)) + c-agencia-aux. 
        END.
        ELSE DO:
            IF  c-agencia = "" then
                ASSIGN c-agencia = "000000-00".                                             
            ELSE
                RUN pi-valida-formato (INPUT "agencia", INPUT l-integra).
        END.
        ASSIGN ERROR-STATUS:ERROR = no.   
        /** **/
        
        /** Validacao do formato da conta-corrente (adaptado do programa cdp\cd0401h-v01.w)**/
        ASSIGN c-conta-corrente = tt-cta-emitente.conta-corrente.
               l-integra = no.
        &IF DEFINED(BF_FIN_EMS2_X_MG) &THEN
            FIND FIRST funcao NO-LOCK
                 WHERE funcao.cd-funcao = "spp-ems2fin-x-mg" 
                   AND funcao.ativo     = YES NO-ERROR.
            IF AVAIL funcao then
                ASSIGN l-integra = YES.
        &ENDIF

        IF l-integra = NO THEN DO:
            IF (LENGTH(c-conta-corrente, "character") < 11) /*sem digito*/ THEN DO:
                ASSIGN c-conta-aux = TRIM(SUBSTRING(c-conta-corrente, 1,10))
                       c-conta-corrente = FILL("0", 10 - LENGTH(c-conta-aux)) + c-conta-aux.
            END.
        END.
        ELSE DO:
            IF (LENGTH(c-conta-corrente, "character") < 11) THEN DO:
                ASSIGN c-conta-aux = TRIM(SUBSTRING(c-conta-corrente, 1,9))
                       c-conta-corrente = FILL("0", 9 - LENGTH(c-conta-aux)) + c-conta-aux.
            END.
        END.

        ASSIGN c-formato-conta = c-conta-corrente NO-ERROR.
        IF ERROR-STATUS:ERROR 
        OR LENGTH(c-conta-corrente) > 12 THEN DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 15271
                   RowErrors.ErrorDescription = "O formato informado para a conta corrente n∆o Ç valido."
                   RowErrors.ErrorHelp        = "ê necess†rio que o campo da conta corrente seja composto por 10 n£meros da conta corrente e mais 2 n£meros do d°gito da conta."
                   RowErrors.ErrorSubType     = "ERROR".        
            
            IF l-integra = NO THEN
                ASSIGN c-conta-aux = TRIM(SUBSTRING(c-conta-corrente, 1,10))
                       c-conta-corrente = FILL("0", 10 - LENGTH(c-conta-aux)) + c-conta-aux.
            ELSE
                ASSIGN c-conta-aux = TRIM(SUBSTRING(c-conta-corrente, 1,9))
                       c-conta-corrente = FILL("0", 9 - LENGTH(c-conta-aux)) + c-conta-aux.
        END.
        ELSE DO:
            IF c-conta-corrente = "" THEN DO:
                IF l-integra THEN
                    ASSIGN c-conta-corrente = "000000000-00".                                                   
                ELSE
                    ASSIGN c-conta-corrente = "0000000000-00".          
            END.
            ELSE
                RUN pi-valida-formato (input "conta corrente", INPUT l-integra).
        END.

        ASSIGN ERROR-STATUS:ERROR = NO.
        /** **/    
            
        ASSIGN tt-cta-emitente.agencia        = c-agencia
               tt-cta-emitente.conta-corrente = c-conta-corrente.             
    END.
    
    IF ip-tipo = 1 THEN DO: /** Inclusao **/
        /** Validacao de ja existencia do registro **/
        IF CAN-FIND(FIRST b-cta-emitente NO-LOCK
                    WHERE b-cta-emitente.cod-emitente         = tt-cta-emitente.cod-emitente
                      AND b-cta-emitente.cod-banco            = tt-cta-emitente.cod-banco
                      AND TRIM(b-cta-emitente.agencia)        = TRIM(tt-cta-emitente.agencia)
                      AND TRIM(b-cta-emitente.conta-corrente) = TRIM(tt-cta-emitente.conta-corrente)) THEN DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 1
                   RowErrors.ErrorDescription = "J† existe ocorrància conta corrente do emitente informada."
                   RowErrors.ErrorHelp        = "J† existe ocorrància em conta corrente do emitente a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".                 
        END.
        
        /** Validacao de existencia de emitente **/
        IF NOT CAN-FIND(FIRST emitente NO-LOCK
                        WHERE emitente.cod-emitente = tt-cta-emitente.cod-emitente
                        AND   emitente.identIFic   <> 1) THEN DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "N∆o encontrado(a) emitente para chave informada."
                   RowErrors.ErrorHelp        = "N∆o foi encontrada ocorrància para emitente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".              
        END.        
        
    END.
    
    IF ip-tipo = 3 THEN DO: /** Exclusao **/
        /** Valida existencia de uma conta preferencial existente (adaptado do programa cdp\cd0401h-v01.w) **/ 
        RUN pi-ver-param-cta-prefer.
        IF l-valid-cta-pref THEN DO:
            ASSIGN i-nr-prefer = 0.

            FOR EACH b-cta-emitente NO-LOCK
               WHERE b-cta-emitente.cod-emitente = cta-emitente.cod-emitente:
                IF  b-cta-emitente.preferencial = YES THEN
                    ASSIGN i-nr-prefer = i-nr-prefer + 1.
            END.

            IF  i-nr-prefer = 0 THEN DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber      = 33128
                       RowErrors.ErrorDescription = "Fornecedor n∆o possui conta definida como preferencial."
                       RowErrors.ErrorHelp        = "Deve existir pelo menos uma conta preferencial para este fornecedor."
                       RowErrors.ErrorSubType     = "ERROR".                  
            END.
        END.         END.    
        
    RETURN "OK".
END PROCEDURE. 

PROCEDURE pi-atualiza-emitente:
/*------------------------------------------------------------------------------
  Purpose:     Realiza a atualizacao da conta na tabela do emitente e retira o 
               flag de preferencial das demais contas.
  Parameters: 
  Notes:       Adaptado do programa cdp\cd0401h-v01.w
------------------------------------------------------------------------------*/ 
    FIND FIRST emitente EXCLUSIVE-LOCK
         WHERE emitente.cod-emitente = cta-emitente.cod-emitente
           AND emitente.identIFic   <> 1 NO-ERROR.        
    IF AVAIL emitente THEN DO:                       
        ASSIGN emitente.cod-banco    = cta-emitente.cod-banco
               emitente.agencia      = TRIM(cta-emitente.agencia)
               emitente.conta-corren = TRIM(cta-emitente.conta-corrente).
    END.
   
    /** Retira o flag de preferencial das demais contas  **/
    FOR EACH b-cta-emitente NO-LOCK
       WHERE b-cta-emitente.cod-emitente = cta-emitente.cod-emitente
         AND ROWID(b-cta-emitente)      <> ROWID(cta-emitente):
        IF b-cta-emitente.preferencial = YES THEN
            ASSIGN i-nr-prefer = i-nr-prefer + 1.
    END.

    IF i-nr-prefer > 0 THEN DO:
        FOR EACH b-cta-emitente EXCLUSIVE-LOCK
           WHERE b-cta-emitente.cod-emitente = cta-emitente.cod-emitente
             AND ROWID(b-cta-emitente)      <> ROWID(cta-emitente):
            ASSIGN b-cta-emitente.preferencial = NO.                
        END.                     
    END.         
END PROCEDURE.

PROCEDURE pi-integra-ems:
/*------------------------------------------------------------------------------
  Purpose:     Realiza a integracao entre o EMS2 e o EMS5.
  Parameters: 
  Notes:       Adaptado do programa cdp\cd0401h-v01.w
------------------------------------------------------------------------------*/ 
    FIND FIRST emitente NO-LOCK
         WHERE emitente.cod-emitente = tt-cta-emitente.cod-emitente
           AND emitente.identIFic   <> 1 NO-ERROR.
                  
    IF AVAIL emitente THEN DO:
        /************* Integracao 2.00 X 5.00 *****************/
        IF  can-FIND(funcao WHERE funcao.cd-funcao = "adm-cdf-ems-5.00"
        AND funcao.ativo = YES
        AND funcao.log-1 = YES) THEN DO:
            FIND FIRST param-global NO-LOCK NO-ERROR.
            
            IF AVAIL param-global 
            AND param-global.log-2 = YES THEN DO:
               validate emitente NO-ERROR.
               run cdp/cd1608.p (INPUT emitente.cod-emitente,
                                 INPUT emitente.cod-emitente,
                                 INPUT emitente.identIFic,
                                 INPUT YES,
                                 INPUT 1,
                                 INPUT 0,
                                 INPUT "utb765zb.tmp",
                                 INPUT "terminal":U,
                                 INPUT "").
            END.
        END.  
        /*********** Fim Integracao 2.00 X 5.00 ****************/                          
    END.
END PROCEDURE.


PROCEDURE pi-valida-formato :
/*------------------------------------------------------------------------------
  Purpose:     Valida o formato do campo de agencia e conta-corrente preenchendo
               com a mascara correta.
  Parameters: 
  Notes:       Adaptado do programa cdp\cd0401h-v01.w
------------------------------------------------------------------------------*/    

    def input param c-campo   as char no-undo.
    def input param p-integra as log no-undo.

    case c-campo:
        when "agencia" then do:
            if  i-pais-impto-usuario = 1 then  do:
                if  c-agencia <> "" then do:

                    assign c-agencia-aux = c-agencia.
                   
                    if  ERROR-STATUS:NUM-MESSAGES > 0 then do:
                        assign c-agencia-aux2 = "".
                        do   i = 1 to length(c-agencia-aux):
                             assign c-char = substr(c-agencia-aux,i,1).
                             if  not can-do("-",c-char) then
                                 assign c-agencia-aux2 = c-agencia-aux2 + c-char.
                        end.

                        assign c-agencia = fill("0", 8 - length(c-agencia-aux2)) + c-agencia-aux2.
                    end.
                end.
                else
                    assign c-agencia = "000000-00".
            end.
        end.
        when "conta corrente" then do:
            if  i-pais-impto-usuario = 1 then do:

                assign c-conta-aux = c-conta-corrente.

                if  p-integra = no then do:
                    if  c-conta-corrente <> "" then do:
                        if  ERROR-STATUS:NUM-MESSAGES > 0 then do:
                            assign c-conta-aux2 = ""
                                   c-char2      = ""
                                   l-dig        = no.
                            do  i = 1 to length(c-conta-aux):
                                assign c-char = substr(c-conta-aux,i,1).
                                if  not can-do("-",c-char) then do:
                                    assign c-conta-aux2 = c-conta-aux2 + c-char.

                                    if  l-dig = yes then
                                        assign c-char2 = c-char2 + c-char.
                                end.
                                else
                                    assign l-dig = yes.
                            end.
                            assign c-conta-corrente = fill("0", 10 + length(c-char2) - length(c-conta-aux2)) + c-conta-aux2.
                        end.
                    end.
                    else
                        assign c-conta-corrente = "0000000000-00".
                end.
                else do:
                    if  c-conta-corrente <> "" then do:
                        if  ERROR-STATUS:NUM-MESSAGES > 0 then do:
                            assign c-conta-aux2 = ""
                                   c-char2      = ""
                                   l-dig        = no.
                            do   i = 1 to length(c-conta-aux):
                                 assign c-char = substr(c-conta-aux,i,1).
                                 if  not can-do("-",c-char) then do:
                                     assign c-conta-aux2 = c-conta-aux2 + c-char.

                                     if  l-dig = yes then
                                         assign c-char2 = c-char2 + c-char.
                                 end.
                                 else
                                     assign l-dig = yes.
                            end.
                            assign c-conta-corrente = fill("0", 9 + length(c-char2) - length(c-conta-aux2)) + c-conta-aux2.
                        end.
                    end.
                   else
                       assign c-conta-corrente = "000000000-00".
                end.
            end.
        end.
    end.    
END PROCEDURE.

PROCEDURE pi-ver-param-cta-prefer:
/*------------------------------------------------------------------------------
  Purpose:     Valida a necessidade de existir uma conta corrente preferencial
               para o emitente.
  Parameters: 
  Notes:       Adaptado do programa cdp\cd0401h-v01.w
------------------------------------------------------------------------------*/    
    find first param-global no-lock no-error.

     &if "{&mgadm_version}" >= "2.02" &then
         if  avail param-global then do:
             if  param-global.modulo-ap = yes then do:
                 find first param-ap 
                     where param-ap.ep-codigo = i-ep-codigo-usuario no-lock no-error.
                 
                 if  avail param-ap then do:
                     &if  defined(BF_FIN_205) &then
                          if  param-ap.Parm-Valid-Conta-Pref = yes then do:
                              assign l-valid-cta-pref = yes.
                          end.
                          else do:
                              assign l-valid-cta-pref = no.
                          end.
                     &else
                          if  substr(param-ap.char-1,8,1) = "n" then do:
                              assign l-valid-cta-pref = no.
                          end.
                          else do:
                              assign l-valid-cta-pref = yes.
                          end.
                     &endif
                 end.
             end.
         end.
     &endif.
END PROCEDURE.
