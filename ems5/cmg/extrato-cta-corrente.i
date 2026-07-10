DEFINE TEMP-TABLE tt-param NO-UNDO                                                             
    FIELD cod_cta_corren                    LIKE extrat_cta_corren.cod_cta_corren                                
    FIELD num_extrat_cta_corren             LIKE extrat_cta_corren.num_extrat_cta_corren
    FIELD dat_extrat_cta_corren_inic        LIKE extrat_cta_corren.dat_extrat_cta_corren_inic   INITIAL 01/01/1900        
    FIELD dat_extrat_cta_corren_final       LIKE extrat_cta_corren.dat_extrat_cta_corren_inic   INITIAL 12/31/2999
    FIELD registro-atual                    AS INTEGER
    FIELD qtd-paginas                       AS INTEGER
    FIELD prox-pagina                       AS LOGICAL
    FIELD buscar-texto                      AS CHARACTER.
    
DEFINE TEMP-TABLE tt-extrat_cta_corren LIKE extrat_cta_corren
    FIELD r-rowid  as ROWID.
    
DEFINE TEMP-TABLE tt-lin_extrat_cta_corren LIKE lin_extrat_cta_corren
    FIELD r-rowid  as ROWID.    
          
DEFINE TEMP-TABLE tt-api-extrato            NO-UNDO                                                 SERIALIZE-NAME "extrato"     
    FIELD cod_cta_corren                    LIKE extrat_cta_corren.cod_cta_corren                   SERIALIZE-NAME "contaCorrente" 
    FIELD num_extrat_cta_corren             LIKE extrat_cta_corren.num_extrat_cta_corren            SERIALIZE-NAME "extratoCtaCorrente"
    FIELD des_refer_extrat_cta_corren       LIKE extrat_cta_corren.des_refer_extrat_cta_corren      SERIALIZE-NAME "referenciaExtrato"  
    FIELD dat_extrat_cta_corren_inic        LIKE extrat_cta_corren.dat_extrat_cta_corren_inic       SERIALIZE-NAME "dataInicial"
    FIELD dat_extrat_cta_corren_fim         LIKE extrat_cta_corren.dat_extrat_cta_corren_fim        SERIALIZE-NAME "dataFinal"
    FIELD dat_gerac_movto                   LIKE extrat_cta_corren.dat_gerac_movto                  SERIALIZE-NAME "dataGeracaoMovto"
    FIELD val_extrat_cta_corren_inic        LIKE extrat_cta_corren.val_extrat_cta_corren_inic       SERIALIZE-NAME "saldoInicial"
    FIELD val_extrat_cta_corren_fim         LIKE extrat_cta_corren.val_extrat_cta_corren_fim        SERIALIZE-NAME "saldoFinal"    
    FIELD dat_ult_atualiz                   LIKE extrat_cta_corren.dat_ult_atualiz                  SERIALIZE-NAME "dataAlteracao"
    FIELD hra_ult_atualiz                   LIKE extrat_cta_corren.hra_ult_atualiz                  SERIALIZE-NAME "horaAlteracao"
    FIELD cod_usuar_ult_atualiz             LIKE extrat_cta_corren.cod_usuar_ult_atualiz            SERIALIZE-NAME "usuarioAlteracao"
    FIELD r-recid                           AS RECID                                                SERIALIZE-NAME "id".
        
DEFINE TEMP-TABLE tt-api-lin-extrato        NO-UNDO                                                 SERIALIZE-NAME "movimentos"                    
    FIELD cod_cta_corren                    LIKE lin_extrat_cta_corren.cod_cta_corren               SERIALIZE-NAME "contaCorrente"
    FIELD num_extrat_cta_corren             LIKE lin_extrat_cta_corren.num_extrat_cta_corren        SERIALIZE-NAME "extratoCtaCorrente"
    FIELD num_seq_extrat_cta_corren         LIKE lin_extrat_cta_corren.num_seq_extrat_cta_corren    SERIALIZE-NAME "sequencia"
    FIELD cod_docto_movto_cta_bco           LIKE lin_extrat_cta_corren.cod_docto_movto_cta_bco      SERIALIZE-NAME "doctoBanco"       
    FIELD cod_tip_lancto_extrat             LIKE lin_extrat_cta_corren.cod_tip_lancto_extrat        SERIALIZE-NAME "tipoLancamento"
    FIELD dat_movto_cta_corren              LIKE lin_extrat_cta_corren.dat_movto_cta_corren         SERIALIZE-NAME "dataMovto"
    FIELD des_histor_movto_cta_corren       LIKE lin_extrat_cta_corren.des_histor_movto_cta_corren  SERIALIZE-NAME "historicoMovto"
    FIELD ind_fluxo_movto_cta_corren        LIKE lin_extrat_cta_corren.ind_fluxo_movto_cta_corren   SERIALIZE-NAME "fluxoMovto"
    FIELD ind_ligac_concil_cta_corren       LIKE lin_extrat_cta_corren.ind_ligac_concil_cta_corren  SERIALIZE-NAME "ligacaoConciliacao"
    FIELD ind_sit_concil_movto_cta          LIKE lin_extrat_cta_corren.ind_sit_concil_movto_cta     SERIALIZE-NAME "situacaConciliacao"
    FIELD log_concil_cta_corren             LIKE lin_extrat_cta_corren.log_concil_cta_corren        SERIALIZE-NAME "conciliacao"         
    FIELD val_lin_extrat_cta_corren         LIKE lin_extrat_cta_corren.val_lin_extrat_cta_corren    SERIALIZE-NAME "vlMovto"
    FIELD val_pend_concil_cta_corren        LIKE lin_extrat_cta_corren.val_pend_concil_cta_corren   SERIALIZE-NAME "vlPendenteConciliacao"
    FIELD num_id_lin_extrat_cta             LIKE lin_extrat_cta_corren.num_id_lin_extrat_cta        SERIALIZE-NAME "id".
    
DEFINE TEMP-TABLE tt-api-conferencia        NO-UNDO                                                 SERIALIZE-NAME "conferencia"     
    FIELD cod_cta_corren                    LIKE extrat_cta_corren.cod_cta_corren                   SERIALIZE-NAME "contaCorrente" 
    FIELD num_extrat_cta_corren             LIKE extrat_cta_corren.num_extrat_cta_corren            SERIALIZE-NAME "extratoCtaCorrente"
    FIELD dat_extrat_cta_corren_inic        LIKE extrat_cta_corren.dat_extrat_cta_corren_inic       SERIALIZE-NAME "dataInicial"
    FIELD dat_extrat_cta_corren_fim         LIKE extrat_cta_corren.dat_extrat_cta_corren_fim        SERIALIZE-NAME "dataFinal"
    FIELD val_extrat_cta_corren_inic        LIKE extrat_cta_corren.val_extrat_cta_corren_inic       SERIALIZE-NAME "saldoInicial"
    FIELD val_extrat_cta_corren_fim         LIKE extrat_cta_corren.val_extrat_cta_corren_fim        SERIALIZE-NAME "saldoFinal"    
    FIELD dat_extrat_cta_corren_inic_inf    LIKE extrat_cta_corren.dat_extrat_cta_corren_inic       SERIALIZE-NAME "dataInicialInformado"
    FIELD dat_extrat_cta_corren_fim_inf     LIKE extrat_cta_corren.dat_extrat_cta_corren_fim        SERIALIZE-NAME "dataFinalInformado"
    FIELD val_extrat_cta_corren_fim_inf     LIKE extrat_cta_corren.val_extrat_cta_corren_fim        SERIALIZE-NAME "saldoFinalInformado"
    FIELD aprovado_data_inic                AS LOGICAL                                              SERIALIZE-NAME "dataInicialAprovado"
    FIELD aprovado_data_fim                 AS LOGICAL                                              SERIALIZE-NAME "dataFinalAprovado"
    FIELD aprovado_saldo_fim                AS LOGICAL                                              SERIALIZE-NAME "saldoAprovado".

