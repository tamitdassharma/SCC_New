@EndUserText.label: 'Include/Exclude Items in Calculation'
define abstract entity /ESRCC/C_USAGECALCULATION  
{   
    @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_USAGECALCULATION', element: 'usagecal' }}]    
    @UI.textArrangement: #TEXT_ONLY
    usagecal : /esrcc/usage;
    
}
