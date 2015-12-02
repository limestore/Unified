public class EMP_HowToBuyController {
    public List<EMP_HowToBuy__c> HowToBuy{ get; set; }
    public EMP_HowToBuyController(){
        HowToBuy = EMP_HowToBuy__c.getAll().values();
        
    }
}