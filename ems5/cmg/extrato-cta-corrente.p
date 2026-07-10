/**********************************************************************************
**  Programa....: extrat_cta_corren.p - Manutencao Extrato Conta Corrente
**  Data........: 20/04/2026
**  Autor.......: Maikon Lopes
**  Objetivo....: Realiza o consultas e manutencao na tabela extrat_cta_corren e 
                  na tabela lin_extrat_cta_corren
**  Observa‡äes.:     
***********************************************************************************
**  Altera‡äes..:
***********************************************************************************/

/** Definicao de temp-tables usadas no programa **/
{cmg/extrato-cta-corrente.i}
{method/dbotterr.i}            /** Definicao temp-table RowErrors **/

DEFINE VARIABLE h-dbo-extrat_cta_corren     AS HANDLE      NO-UNDO.
DEFINE VARIABLE h-dbo-lin_extrat_cta_corren AS HANDLE      NO-UNDO.
DEFINE VARIABLE iCount                      AS INTEGER     NO-UNDO.

DEFINE BUFFER bf-extrat_cta_corren      FOR extrat_cta_corren.
DEFINE BUFFER bf-lin_extrat_cta_corren  FOR lin_extrat_cta_corren.

/**PROCEDURES INTERNAS **/    
PROCEDURE pi-listar-extratos:
/*------------------------------------------------------------------------------
  Purpose:     Retorna uma listagem de registros de extratos de conta corrent 
               de acordo com os filtros informados.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/       
    DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR tt-param.
    DEFINE OUTPUT        PARAMETER TABLE FOR tt-api-extrato.
    DEFINE OUTPUT        PARAMETER TABLE FOR RowErrors.

    DEFINE VARIABLE i-contagem          AS INTEGER     NO-UNDO.
    DEFINE VARIABLE c-query             AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE c-matches           AS CHARACTER   NO-UNDO.
        
    DO ON ERROR UNDO, THROW:      
        FIND FIRST tt-param.
                                         
        /** Montando a query para buscar na tabela **/
        ASSIGN c-query = "FOR EACH extrat_cta_corren NO-LOCK WHERE extrat_cta_corren.dat_extrat_cta_corren_inic >= '" + string(tt-param.dat_extrat_cta_corren_inic, "99/99/9999") + "' AND extrat_cta_corren.dat_extrat_cta_corren_inic <='" + string(tt-param.dat_extrat_cta_corren_final , "99/99/9999") + "' ".
           
        IF tt-param.cod_cta_corren <> "" THEN
            ASSIGN c-query = c-query + "AND extrat_cta_corren.cod_cta_corren = '" + tt-param.cod_cta_corren + "' ".
                                                   
        IF tt-param.num_extrat_cta_corren > 0 THEN
            ASSIGN c-query = c-query + "AND extrat_cta_corren.num_extrat_cta_corren = '" + string(tt-param.num_extrat_cta_corren) + "' ".
                                    
        /** Executa a query para buscar as informacoes de acordo com os filtros e paginanacao **/
        DEFINE QUERY findQuery FOR extrat_cta_corren
        SCROLLING.
        
        QUERY findQuery:QUERY-PREPARE(c-query).
        QUERY findQuery:QUERY-OPEN().
        QUERY findQuery:REPOSITION-TO-ROW(tt-param.registro-atual).
        
        EMPTY TEMP-TABLE tt-api-extrato.
        
        REPEAT:
            GET NEXT findQuery.
            IF QUERY findQuery:QUERY-OFF-END THEN LEAVE.
            
            IF tt-param.qtd-paginas EQ i-contagem THEN DO:
                ASSIGN tt-param.prox-pagina = TRUE.
                LEAVE.
            END.
            ELSE
                ASSIGN tt-param.prox-pagina = FALSE.
            
                                                
            /** Filtrar registros pelo campo de search **/
            IF tt-param.buscar-texto <> "" THEN DO:        
                ASSIGN c-matches = "*" + TRIM(tt-param.buscar-texto) + "*".        
                                             
                IF NOT (extrat_cta_corren.cod_cta_corren MATCHES c-matches 
                    OR  string(extrat_cta_corren.num_extrat_cta_corren) MATCHES c-matches 
                    OR  extrat_cta_corren.des_refer_extrat_cta_corren MATCHES c-matches 
                    ) THEN NEXT.
            END.      
                                                                             
            CREATE tt-api-extrato.
            BUFFER-COPY extrat_cta_corren TO tt-api-extrato
            ASSIGN tt-api-extrato.r-recid  = RECID(extrat_cta_corren).               
                  
            ASSIGN i-contagem = i-contagem + 1.        
        END.
        QUERY findQuery:QUERY-CLOSE().
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:         
        RETURN "OK".
    END FINALLY.         
END PROCEDURE.

PROCEDURE pi-consultar-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Retorna o registro de um extrato de conta corrente de acordo 
               com o recid informado.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT PARAMETER ip-id        AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-extrato.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-lin-extrato.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors. 

    DO ON ERROR UNDO, THROW:      
        FIND FIRST extrat_cta_corren NO-LOCK
             WHERE RECID(extrat_cta_corren) = INT64(ip-id) NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:
            CREATE tt-api-extrato.
            BUFFER-COPY extrat_cta_corren TO tt-api-extrato
            ASSIGN tt-api-extrato.r-recid  = RECID(extrat_cta_corren).
                   
            FOR EACH lin_extrat_cta_corren NO-LOCK
               WHERE lin_extrat_cta_corren.cod_cta_corren        = extrat_cta_corren.cod_cta_corren
                 AND lin_extrat_cta_corren.num_extrat_cta_corren = extrat_cta_corren.num_extrat_cta_corren:
                 
                CREATE tt-api-lin-extrato.
                BUFFER-COPY lin_extrat_cta_corren 
                         TO tt-api-lin-extrato.                                                     
            END.                                                                                              
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
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

PROCEDURE pi-criar-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Adiciona um  registro de extrato de conta corrente de acordo 
               com a temp-table informada.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/   
    DEFINE INPUT  PARAMETER TABLE FOR tt-extrat_cta_corren.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-extrato.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
  
    DO ON ERROR UNDO, THROW:    
        FIND FIRST tt-extrat_cta_corren.
        
        /** Define o numero da sequencia **/
        FIND LAST bf-extrat_cta_corren NO-LOCK
            WHERE bf-extrat_cta_corren.cod_cta_corren        =  tt-extrat_cta_corren.cod_cta_corren NO-ERROR.
        IF AVAIL bf-extrat_cta_corren THEN
            ASSIGN tt-extrat_cta_corren.num_extrat_cta_corren = bf-extrat_cta_corren.num_extrat_cta_corren + 1.
        ELSE
            ASSIGN tt-extrat_cta_corren.num_extrat_cta_corren = 1.
        /** **/ 
       

        /** Instancia os handles que serao usados no programa **/
        IF NOT VALID-HANDLE(h-dbo-extrat_cta_corren) THEN
            RUN prgfin/cmg/cmg910wh.py PERSISTENT SET h-dbo-extrat_cta_corren.               
               
        RUN openQueryStatic     IN h-dbo-extrat_cta_corren(INPUT "Main":U).
        RUN emptyRowErrors      IN h-dbo-extrat_cta_corren.    
        RUN newRecord           IN h-dbo-extrat_cta_corren.
        RUN setRecord           IN h-dbo-extrat_cta_corren (TABLE tt-extrat_cta_corren).
        RUN createRecord        IN h-dbo-extrat_cta_corren.     
        RUN getRowErrors        IN h-dbo-extrat_cta_corren(OUTPUT TABLE RowErrors).
                                                
        /** Transfere o resultado da temp-table da DBO para a temp-table de retorno **/
        FIND FIRST extrat_cta_corren NO-LOCK
            WHERE extrat_cta_corren.cod_cta_corren        = tt-extrat_cta_corren.cod_cta_corren
              AND extrat_cta_corren.num_extrat_cta_corren = tt-extrat_cta_corren.num_extrat_cta_corren NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:       
            CREATE tt-api-extrato.
            BUFFER-COPY extrat_cta_corren TO tt-api-extrato
                 ASSIGN tt-api-extrato.r-recid = RECID(extrat_cta_corren).                        
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".         
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-dbo-extrat_cta_corren) THEN
            DELETE OBJECT h-dbo-extrat_cta_corren.      
       
        RETURN "OK".
    END FINALLY.           
END PROCEDURE.

PROCEDURE pi-alterar-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Altera o registro de um extrato de conta corrente de acordo 
               com a temp-table informada.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT  PARAMETER ip-id  AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER TABLE FOR tt-extrat_cta_corren.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-extrato.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
    
    DO ON ERROR UNDO, THROW:    
        FIND FIRST tt-extrat_cta_corren. 
        
        FIND FIRST extrat_cta_corren NO-LOCK
             WHERE RECID(extrat_cta_corren) = INT64(ip-id) NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:
            BUFFER-COPY extrat_cta_corren 
                 EXCEPT extrat_cta_corren.des_refer_extrat_cta_corren  
                        extrat_cta_corren.dat_extrat_cta_corren_inic  
                        extrat_cta_corren.dat_extrat_cta_corren_fim   
                        extrat_cta_corren.val_extrat_cta_corren_inic  
                        extrat_cta_corren.val_extrat_cta_corren_fim
                     TO tt-extrat_cta_corren
                 ASSIGN tt-extrat_cta_corren.r-rowid  = ROWID(extrat_cta_corren).    
                   
            /** Instancia os handles que serao usados no programa **/
            IF NOT VALID-HANDLE(h-dbo-extrat_cta_corren) THEN
                RUN prgfin/cmg/cmg910wh.py PERSISTENT SET h-dbo-extrat_cta_corren.               
                   
            RUN openQueryStatic     IN h-dbo-extrat_cta_corren(INPUT "Main":U).
            RUN goToKey             IN h-dbo-extrat_cta_corren(INPUT tt-extrat_cta_corren.cod_cta_corren,
                                                               INPUT tt-extrat_cta_corren.num_extrat_cta_corren).
            RUN emptyRowErrors      IN h-dbo-extrat_cta_corren.    
            RUN setRecord           IN h-dbo-extrat_cta_corren (TABLE tt-extrat_cta_corren).
            RUN updateRecord        IN h-dbo-extrat_cta_corren.     
            RUN getRowErrors        IN h-dbo-extrat_cta_corren(OUTPUT TABLE RowErrors).
                                                    
            /** Transfere o resultado da temp-table da DBO para a temp-table de retorno **/
            CREATE tt-api-extrato.
            BUFFER-COPY tt-extrat_cta_corren TO tt-api-extrato
                 ASSIGN tt-api-extrato.r-recid = RECID(extrat_cta_corren).                                                 
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".         
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-dbo-extrat_cta_corren) THEN
            DELETE OBJECT h-dbo-extrat_cta_corren.      
       
        RETURN "OK".
    END FINALLY.              
END PROCEDURE.

PROCEDURE pi-excluir-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Excluir o registro um extrato de conta corrente de acordo o id do 
               extrato informado.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT         PARAMETER ip-id        AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
    
    DO ON ERROR UNDO, THROW:     
        FIND FIRST extrat_cta_corren NO-LOCK
             WHERE RECID(extrat_cta_corren) = INT64(ip-id) NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:                                                 
            /** Transfere o resultado da tabela real para a temp-table da DBO **/
            CREATE tt-extrat_cta_corren.
            BUFFER-COPY extrat_cta_corren 
                     TO tt-extrat_cta_corren.
                    
            /** Instancia os handles que serao usados no programa **/
            IF NOT VALID-HANDLE(h-dbo-extrat_cta_corren) THEN
                RUN prgfin/cmg/cmg910wh.py PERSISTENT SET h-dbo-extrat_cta_corren.                  
                    
            RUN openQueryStatic             IN h-dbo-extrat_cta_corren(INPUT "Main":U). 
            RUN goToKey                     IN h-dbo-extrat_cta_corren(INPUT tt-extrat_cta_corren.cod_cta_corren,
                                                                       INPUT tt-extrat_cta_corren.num_extrat_cta_corren           
                                                                       ).                                              
            RUN emptyRowErrors              IN h-dbo-extrat_cta_corren.    
            RUN deleteRecord                IN h-dbo-extrat_cta_corren.     
            RUN getRowErrors                IN h-dbo-extrat_cta_corren(OUTPUT TABLE RowErrors).            
                                                                                                            
              
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".                 
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-dbo-extrat_cta_corren) THEN
            DELETE OBJECT h-dbo-extrat_cta_corren.     
       
        RETURN "OK".
    END FINALLY.                
END PROCEDURE.

PROCEDURE pi-criar-lin-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Criar o registro de um linha de extrato de conta corrente de 
               acordo o id do extrato e com a temp-table informada.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT         PARAMETER ip-id  AS CHARACTER   NO-UNDO.
    DEFINE INPUT-OUTPUT  PARAMETER TABLE FOR tt-api-lin-extrato.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
  
    DO ON ERROR UNDO, THROW:
        FIND FIRST tt-api-lin-extrato. 
        
        FIND FIRST extrat_cta_corren NO-LOCK
             WHERE RECID(extrat_cta_corren) = INT64(ip-id) NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:          
            /** Transfere o resultado da temp-table enviada para a temp-table da DBO **/
            CREATE tt-lin_extrat_cta_corren.
            BUFFER-COPY tt-api-lin-extrato 
                     TO tt-lin_extrat_cta_corren.
                     
            ASSIGN tt-lin_extrat_cta_corren.cod_cta_corren        = extrat_cta_corren.cod_cta_corren
                   tt-lin_extrat_cta_corren.num_extrat_cta_corren = extrat_cta_corren.num_extrat_cta_corren.
                   
            /** Define o numero da sequencia **/
            FIND LAST bf-lin_extrat_cta_corren NO-LOCK
                WHERE bf-lin_extrat_cta_corren.cod_cta_corren        =  extrat_cta_corren.cod_cta_corren
                  AND bf-lin_extrat_cta_corren.num_extrat_cta_corren = extrat_cta_corren.num_extrat_cta_corren NO-ERROR.
            IF AVAIL bf-lin_extrat_cta_corren THEN
                ASSIGN tt-lin_extrat_cta_corren.num_seq_extrat_cta_corren = bf-lin_extrat_cta_corren.num_seq_extrat_cta_corren + 1.
            ELSE
                ASSIGN tt-lin_extrat_cta_corren.num_seq_extrat_cta_corren = 1.
            /** **/                   
                                                                                        
            /** Instancia os handles que serao usados no programa **/
            IF NOT VALID-HANDLE(h-dbo-lin_extrat_cta_corren) THEN
                RUN prgfin/cmg/cmg910wi.py PERSISTENT SET h-dbo-lin_extrat_cta_corren.                  
                    
            RUN openQueryStatic             IN h-dbo-lin_extrat_cta_corren(INPUT "Main":U).        
            RUN emptyRowErrors              IN h-dbo-lin_extrat_cta_corren.
            RUN newRecord                   IN h-dbo-lin_extrat_cta_corren.       
            RUN setRecord                   IN h-dbo-lin_extrat_cta_corren (TABLE tt-lin_extrat_cta_corren).
            RUN createRecord                IN h-dbo-lin_extrat_cta_corren.     
            RUN getRowErrors                IN h-dbo-lin_extrat_cta_corren(OUTPUT TABLE RowErrors).
            
            /** Transfere o resultado do registro criado para a temp-table de retorno **/        
            FIND LAST lin_extrat_cta_corren NO-LOCK
                WHERE lin_extrat_cta_corren.cod_cta_corren            = tt-lin_extrat_cta_corren.cod_cta_corren
                  AND lin_extrat_cta_corren.num_extrat_cta_corren     = tt-lin_extrat_cta_corren.num_extrat_cta_corren 
                  AND lin_extrat_cta_corren.dat_movto_cta_corren      = tt-lin_extrat_cta_corren.dat_movto_cta_corren 
                  AND lin_extrat_cta_corren.num_seq_extrat_cta_corren = tt-lin_extrat_cta_corren.num_seq_extrat_cta_corren NO-ERROR.
            IF AVAIL lin_extrat_cta_corren THEN DO:
                EMPTY TEMP-TABLE tt-api-lin-extrato.
                CREATE tt-api-lin-extrato.
                BUFFER-COPY lin_extrat_cta_corren 
                         TO tt-api-lin-extrato.            
            END.
            ELSE DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber      = 2
                       RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                       RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
                       RowErrors.ErrorSubType     = "ERROR".          
            
            END.                                                                                                                                                   
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".         
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-dbo-lin_extrat_cta_corren) THEN
            DELETE OBJECT h-dbo-lin_extrat_cta_corren.    
            
        RETURN "OK".
    END FINALLY.                
END PROCEDURE.

PROCEDURE pi-alterar-lin-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Alterar o registro de uma linha de extrato de conta corrente de 
               acordo o id do extrato, id da linha do extrado e com a temp-table 
               informada.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT  PARAMETER ip-id        AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER ip-id-lin    AS CHARACTER   NO-UNDO.    
    DEFINE INPUT  PARAMETER TABLE FOR tt-lin_extrat_cta_corren.                                                     
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-lin-extrato.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
    
    DO ON ERROR UNDO, THROW:
        FIND FIRST tt-lin_extrat_cta_corren.       
          
        FIND FIRST extrat_cta_corren NO-LOCK
             WHERE RECID(extrat_cta_corren) = INT64(ip-id) NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:   
            FIND FIRST lin_extrat_cta_corren NO-LOCK
                 WHERE lin_extrat_cta_corren.num_id_lin_extrat_cta = INT64(ip-id-lin) NO-ERROR.                                                                                                                                                                 
            IF AVAIL lin_extrat_cta_corren THEN DO:                                       
                /** Transfere o resultado da tabela real para a temp-table da DBO **/
                BUFFER-COPY lin_extrat_cta_corren 
                     EXCEPT lin_extrat_cta_corren.cod_docto_movto_cta_bco     
                            lin_extrat_cta_corren.cod_tip_lancto_extrat       
                            lin_extrat_cta_corren.ind_fluxo_movto_cta_corren  
                            lin_extrat_cta_corren.val_lin_extrat_cta_corren   
                            lin_extrat_cta_corren.des_histor_movto_cta_corren                       
                         TO tt-lin_extrat_cta_corren.
                                                       
                MESSAGE " #### tt-lin_extrat_cta_corren.cod_cta_corren:             " tt-lin_extrat_cta_corren.cod_cta_corren SKIP
                        " #### tt-lin_extrat_cta_corren.num_extrat_cta_corren:      " tt-lin_extrat_cta_corren.num_extrat_cta_corren SKIP
                        " #### tt-lin_extrat_cta_corren.num_seq_extrat_cta_corren:  " tt-lin_extrat_cta_corren.num_seq_extrat_cta_corren SKIP                
                        " #### tt-lin_extrat_cta_corren.dat_movto_cta_corren:       " tt-lin_extrat_cta_corren.dat_movto_cta_corren SKIP
                        " #### tt-lin_extrat_cta_corren.cod_docto_movto_cta_bco:    " tt-lin_extrat_cta_corren.cod_docto_movto_cta_bco SKIP
                        " #### tt-lin_extrat_cta_corren.cod_tip_lancto_extrat       " tt-lin_extrat_cta_corren.cod_tip_lancto_extrat SKIP  
                        " #### tt-lin_extrat_cta_corren.ind_fluxo_movto_cta_corren  " tt-lin_extrat_cta_corren.ind_fluxo_movto_cta_corren SKIP  
                        " #### tt-lin_extrat_cta_corren.val_lin_extrat_cta_corren   " tt-lin_extrat_cta_corren.val_lin_extrat_cta_corren SKIP   
                        " #### tt-lin_extrat_cta_corren.des_histor_movto_cta_corren " tt-lin_extrat_cta_corren.des_histor_movto_cta_corren SKIP.                                               
                                                       
                /** Instancia os handles que serao usados no programa **/
                IF NOT VALID-HANDLE(h-dbo-lin_extrat_cta_corren) THEN
                    RUN prgfin/cmg/cmg910wi.py PERSISTENT SET h-dbo-lin_extrat_cta_corren.                  
                        
                RUN openQueryStatic             IN h-dbo-lin_extrat_cta_corren(INPUT "Main":U). 
                RUN goToKey                     IN h-dbo-lin_extrat_cta_corren(INPUT tt-lin_extrat_cta_corren.cod_cta_corren,
                                                                               INPUT tt-lin_extrat_cta_corren.num_extrat_cta_corren,
                                                                               INPUT tt-lin_extrat_cta_corren.dat_movto_cta_corren,
                                                                               INPUT tt-lin_extrat_cta_corren.num_seq_extrat_cta_corren            
                                                                              ).                                              
                RUN emptyRowErrors              IN h-dbo-lin_extrat_cta_corren.    
                RUN setRecord                   IN h-dbo-lin_extrat_cta_corren (TABLE tt-lin_extrat_cta_corren).
                RUN updateRecord                IN h-dbo-lin_extrat_cta_corren.       
                RUN getRowErrors                IN h-dbo-lin_extrat_cta_corren(OUTPUT TABLE RowErrors). 
                
            /** Transfere o resultado da temp-table da DBO para a temp-table de retorno **/
                CREATE tt-api-lin-extrato.
                BUFFER-COPY tt-lin_extrat_cta_corren TO tt-api-lin-extrato.                                                                                                                                           
            END.
            ELSE DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber      = 2
                       RowErrors.ErrorDescription = "NÆo encontrado(a) linha de extrato de conta corrente para chave informada."
                       RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para linha de extrato de conta corrente com a chave informada."
                       RowErrors.ErrorSubType     = "ERROR".                 
            END.
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".         
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-dbo-lin_extrat_cta_corren) THEN
            DELETE OBJECT h-dbo-lin_extrat_cta_corren.     
       
        RETURN "OK".
    END FINALLY.             
END PROCEDURE.


PROCEDURE pi-excluir-lin-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Excluir o registro de uma linha de extrato de conta corrente de 
               acordo o id do extrato e id da linha do extrado informado.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT         PARAMETER ip-id        AS CHARACTER   NO-UNDO.
    DEFINE INPUT         PARAMETER ip-id-lin    AS CHARACTER   NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors.     
      
    DO ON ERROR UNDO, THROW:
        FIND FIRST extrat_cta_corren NO-LOCK
             WHERE RECID(extrat_cta_corren) = INT64(ip-id) NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:           
            FIND FIRST lin_extrat_cta_corren NO-LOCK
                 WHERE lin_extrat_cta_corren.num_id_lin_extrat_cta = INT64(ip-id-lin) NO-ERROR.                                                                                                                                                                 
            IF AVAIL lin_extrat_cta_corren THEN DO:                                       
                /** Transfere o resultado da tabela real para a temp-table da DBO **/
                CREATE tt-lin_extrat_cta_corren.
                BUFFER-COPY lin_extrat_cta_corren 
                        TO tt-lin_extrat_cta_corren.
                        
                /** Instancia os handles que serao usados no programa **/
                IF NOT VALID-HANDLE(h-dbo-lin_extrat_cta_corren) THEN
                    RUN prgfin/cmg/cmg910wi.py PERSISTENT SET h-dbo-lin_extrat_cta_corren.                  
                        
                RUN openQueryStatic             IN h-dbo-lin_extrat_cta_corren(INPUT "Main":U). 
                RUN goToKey                     IN h-dbo-lin_extrat_cta_corren(INPUT tt-lin_extrat_cta_corren.cod_cta_corren,
                                                                               INPUT tt-lin_extrat_cta_corren.num_extrat_cta_corren,
                                                                               INPUT tt-lin_extrat_cta_corren.dat_movto_cta_corren,
                                                                               INPUT tt-lin_extrat_cta_corren.num_seq_extrat_cta_corren            
                                                                              ).                                              
                RUN emptyRowErrors              IN h-dbo-lin_extrat_cta_corren.    
                RUN deleteRecord                IN h-dbo-lin_extrat_cta_corren.     
                RUN getRowErrors                IN h-dbo-lin_extrat_cta_corren(OUTPUT TABLE RowErrors).                                                                                                                                       
            END.
            ELSE DO:
                CREATE RowErrors.
                ASSIGN RowErrors.ErrorNumber      = 2
                       RowErrors.ErrorDescription = "NÆo encontrado(a) linha de extrato de conta corrente para chave informada."
                       RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para linha de extrato de conta corrente com a chave informada."
                       RowErrors.ErrorSubType     = "ERROR".                 
            END.
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
                   RowErrors.ErrorSubType     = "ERROR".         
        END.
    END.
    CATCH err AS PROGRESS.Lang.Error: 
        RUN pi-erros(INPUT err). 
    END CATCH.
    FINALLY:
        /** Delete os handles usados no programa **/
        IF VALID-HANDLE(h-dbo-lin_extrat_cta_corren) THEN
            DELETE OBJECT h-dbo-lin_extrat_cta_corren.      
       
        RETURN "OK".
    END FINALLY.                         
END PROCEDURE.

PROCEDURE pi-conferencia-extrato:
/*------------------------------------------------------------------------------
  Purpose:     Retorna o registro de um extrato de conta corrente de acordo 
               com o recid informado.
  Parameters: 
  Notes:       
------------------------------------------------------------------------------*/ 
    DEFINE INPUT PARAMETER ip-id        AS CHARACTER NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-api-conferencia.
    DEFINE OUTPUT PARAMETER TABLE FOR RowErrors. 
    
    DO ON ERROR UNDO, THROW:      
        FIND FIRST extrat_cta_corren NO-LOCK
             WHERE RECID(extrat_cta_corren) = INT64(ip-id) NO-ERROR.
        IF AVAIL extrat_cta_corren THEN DO:
            CREATE tt-api-conferencia.
            ASSIGN tt-api-conferencia.cod_cta_corren                = extrat_cta_corren.cod_cta_corren
                   tt-api-conferencia.num_extrat_cta_corren         = extrat_cta_corren.num_extrat_cta_corren    
                   tt-api-conferencia.dat_extrat_cta_corren_inic    = extrat_cta_corren.dat_extrat_cta_corren_inic
                   tt-api-conferencia.dat_extrat_cta_corren_fim     = extrat_cta_corren.dat_extrat_cta_corren_fim               
                   tt-api-conferencia.val_extrat_cta_corren_inic    = extrat_cta_corren.val_extrat_cta_corren_inic
                   tt-api-conferencia.val_extrat_cta_corren_fim     = extrat_cta_corren.val_extrat_cta_corren_fim 
                   tt-api-conferencia.val_extrat_cta_corren_fim_inf = extrat_cta_corren.val_extrat_cta_corren_inic.        
        
        
            FIND FIRST lin_extrat_cta_corren NO-LOCK
                 WHERE lin_extrat_cta_corren.cod_cta_corren        = extrat_cta_corren.cod_cta_corren
                   AND lin_extrat_cta_corren.num_extrat_cta_corren = extrat_cta_corren.num_extrat_cta_corren NO-ERROR.
            IF AVAIL lin_extrat_cta_corren THEN DO:             
                ASSIGN tt-api-conferencia.dat_extrat_cta_corren_inic_inf = lin_extrat_cta_corren.dat_movto_cta_corren.

                FIND LAST lin_extrat_cta_corren NO-LOCK
                    WHERE lin_extrat_cta_corren.cod_cta_corren        = extrat_cta_corren.cod_cta_corren
                      AND lin_extrat_cta_corren.num_extrat_cta_corren = extrat_cta_corren.num_extrat_cta_corren NO-ERROR.
                ASSIGN tt-api-conferencia.dat_extrat_cta_corren_fim_inf = lin_extrat_cta_corren.dat_movto_cta_corren.

                FOR EACH lin_extrat_cta_corren NO-LOCK
                   WHERE lin_extrat_cta_corren.cod_cta_corren        = extrat_cta_corren.cod_cta_corren
                     AND lin_extrat_cta_corren.num_extrat_cta_corren = extrat_cta_corren.num_extrat_cta_corren:

                    IF lin_extrat_cta_corren.ind_fluxo_movto_cta_corren = "ENT" THEN
                        ASSIGN tt-api-conferencia.val_extrat_cta_corren_fim_inf = tt-api-conferencia.val_extrat_cta_corren_fim_inf + lin_extrat_cta_corren.val_lin_extrat_cta_corren.
                    ELSE
                        ASSIGN tt-api-conferencia.val_extrat_cta_corren_fim_inf = tt-api-conferencia.val_extrat_cta_corren_fim_inf - lin_extrat_cta_corren.val_lin_extrat_cta_corren.
                END.
            END.    
            
            IF tt-api-conferencia.dat_extrat_cta_corren_inic = tt-api-conferencia.dat_extrat_cta_corren_inic_inf THEN
                ASSIGN tt-api-conferencia.aprovado_data_inic = YES.
            
            IF tt-api-conferencia.dat_extrat_cta_corren_fim = tt-api-conferencia.dat_extrat_cta_corren_fim_inf THEN
                ASSIGN tt-api-conferencia.aprovado_data_fim = YES.
                
            IF tt-api-conferencia.val_extrat_cta_corren_fim = tt-api-conferencia.val_extrat_cta_corren_fim_inf THEN
                ASSIGN tt-api-conferencia.aprovado_saldo_fim = YES.         
                
            /*MESSAGE "############################# Conta Corrente:   " tt-api-conferencia.cod_cta_corren SKIP
                    "############################# Extrato:          " tt-api-conferencia.num_extrat_cta_corren SKIP
                    "############################# Data Inicial:     " tt-api-conferencia.dat_extrat_cta_corren_inic " | "  tt-api-conferencia.dat_extrat_cta_corren_inic_inf " | " tt-api-conferencia.aprovado_data_inic SKIP                                                           
                    "############################# Saldo Inicial     " tt-api-conferencia.val_extrat_cta_corren_inic SKIP   
                                                         
                    "############################# Data Final:       " tt-api-conferencia.dat_extrat_cta_corren_fim " | " tt-api-conferencia.dat_extrat_cta_corren_fim_inf " | " tt-api-conferencia.aprovado_data_fim  SKIP   
                    "############################# Saldo Final:      " tt-api-conferencia.val_extrat_cta_corren_fim " | " tt-api-conferencia.val_extrat_cta_corren_fim_inf " | " tt-api-conferencia.aprovado_saldo_fim  SKIP.*/                                              
        END.
        ELSE DO:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber      = 2
                   RowErrors.ErrorDescription = "NÆo encontrado(a) extrato de conta corrente para chave informada."
                   RowErrors.ErrorHelp        = "NÆo foi encontrada ocorrˆncia para extrato de conta corrente com a chave informada."
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
    RETURN "NOK". 
END PROCEDURE.
