DEFINE TEMP-TABLE tt-param NO-UNDO                                                             
    FIELD cod-emitente                      LIKE cta-emitente.cod-emitente                                
    FIELD cod-banco                         LIKE cta-emitente.cod-banco
    FIELD agencia                           LIKE cta-emitente.agencia       
    FIELD conta-corrente                    LIKE cta-emitente.conta-corrente
    FIELD preferencial                      LIKE cta-emitente.preferencial  INITIAL ?
    FIELD registro-atual                    AS INTEGER
    FIELD qtd-paginas                       AS INTEGER
    FIELD prox-pagina                       AS LOGICAL
    FIELD buscar-texto                      AS CHARACTER.
    
DEFINE TEMP-TABLE tt-cta-emitente LIKE cta-emitente
    FIELD r-rowid  as ROWID.
            
DEFINE TEMP-TABLE tt-api-conta              NO-UNDO                                                 SERIALIZE-NAME "contas"     
    FIELD cod-emitente                      LIKE cta-emitente.cod-emitente                          SERIALIZE-NAME "emitente" 
    FIELD cod-banco                         LIKE cta-emitente.cod-banco                             SERIALIZE-NAME "banco"
    FIELD agencia                           LIKE cta-emitente.agencia                               SERIALIZE-NAME "agencia"  
    FIELD conta-corrente                    LIKE cta-emitente.conta-corrente                        SERIALIZE-NAME "contaCorrente"
    FIELD preferencial                      LIKE cta-emitente.preferencial                          SERIALIZE-NAME "preferencial"
    FIELD descricao                         LIKE cta-emitente.descricao                             SERIALIZE-NAME "descricao"
    FIELD r-recid                           AS RECID                                                SERIALIZE-NAME "id".

