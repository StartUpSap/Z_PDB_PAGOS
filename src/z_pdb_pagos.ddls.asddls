@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte PDB pagos'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_PDB_PAGOS 
with parameters
    P_CompanyCode         : bukrs,         // Sociedad
    P_AccountingDocument  : belnr_d,       // Documento
    P_FiscalYear          : gjahr          // Año
as select from I_JournalEntryItem 
    as JournalEntryItem
    
    inner join I_PaymentProposalItem
    as PaymentProposalItem
    on PaymentProposalItem.CompanyCode                  = JournalEntryItem.CompanyCode        //P_CompanyCode 
   and PaymentProposalItem.FiscalYear                   = JournalEntryItem.FiscalYear         //P_FiscalYear
   and PaymentProposalItem.AccountingDocument           = JournalEntryItem.AccountingDocument //P_AccountingDocument
   and PaymentProposalItem.AccountingDocumentItem       = substring(JournalEntryItem.LedgerGLLineItem, 4, 6)        //001    
   and PaymentProposalItem.PaymentDocument              = JournalEntryItem.ClearingJournalEntry
   association [1..1] to  ZC_I_T_0053  as _MetPago     on $projection.PaymentMethod  = _MetPago.PaymentMethod 
   association [1..1] to  ZC_I_T_0057  as _EntFina     on $projection.HouseBank      = _EntFina.HouseBank   
//   PaymentDocument   CompanyCode AccountingDocument  FiscalYear  AccountingDocumentItem
//   CLEARINGDOCFISCALYEAR    CLEARINGACCOUNTINGDOCUMENT  CLEARINGJOURNALENTRYFISCALYEAR       
    {
        key JournalEntryItem.SourceLedger,
        key JournalEntryItem.CompanyCode,
        key JournalEntryItem.FiscalYear,
        key JournalEntryItem.AccountingDocument,
        key JournalEntryItem.LedgerGLLineItem,
        key JournalEntryItem.Ledger,
            JournalEntryItem.ClearingJournalEntryFiscalYear,
            JournalEntryItem.ClearingJournalEntry,
     //       substring(JournalEntryItem.LedgerGLLineItem, 4, 6) as prueba2
            PaymentProposalItem.HouseBank,
            _EntFina.HouseBankSnt,
            PaymentProposalItem.DocumentDate,
            PaymentProposalItem.PaymentMethod,
            _MetPago.PaymentMethodSnt,
            @Semantics.amount.currencyCode: 'PaymentCurrency'
            abs(PaymentProposalItem.AmountInTransactionCurrency) as AmountInTransactionCurrency2,
            PaymentProposalItem.PaymentCurrency,
            PaymentProposalItem.FinancialAccountType,
            PaymentProposalItem.PaymentDocument,
            _MetPago     
    }
        where
            JournalEntryItem.SourceLedger           = '0L'
        and JournalEntryItem.Ledger                 = '0L'
        and JournalEntryItem.CompanyCode            = $parameters.P_CompanyCode
        and JournalEntryItem.FiscalYear             = $parameters.P_FiscalYear
        and JournalEntryItem.AccountingDocument     = $parameters.P_AccountingDocument
        and JournalEntryItem.LedgerGLLineItem       = '000001'                                     
        and JournalEntryItem.FinancialAccountType   = 'K'
