@EndUserText.label: 'Change Cost Indicator'
define abstract entity /ESRCC/C_COSTIND  
{   
    @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTIND', element: 'costind' }}]    
    @EndUserText.label: 'Cost Indicator'
    @UI.textArrangement: #TEXT_ONLY
    costind : /esrcc/costind_de;
    
}
