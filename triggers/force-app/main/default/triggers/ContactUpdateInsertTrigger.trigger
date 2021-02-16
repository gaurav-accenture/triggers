trigger ContactUpdateInsertTrigger on Contact (before insert, before update) {

        List<Account> accli = new List<Account>();//to be updated
        List<Account> zeroli = new List<Account>();//list of accounts with zero primary
        List<Account> errorli = new List<Account>();//list of accounts with more than 1 primaries

        List<Id> ids = new List<Id>(); 
        for(Contact c : trigger.new){
            if(c.AccountId != null)
                ids.add(c.AccountId);
        }

        Map<Id, Account> Accmap = new Map<Id, Account>([SELECT Id, phone, (SELECT Id FROM Contacts WHERE Is_Primary__c = true) FROM Account WHERE id IN :ids]);
        System.debug(Accmap);

        Map<Id, Integer> AcCon = new Map<Id, Integer>();
        for(Id id : Accmap.keySet()){//id?
            AcCon.put(id, Accmap.get(id).contacts.size());
        }

        Account a;
        for(Contact c : trigger.new){
            if(AcCon.get(c.AccountId) == 1){
                a = Accmap.get(c.AccountId);
                a.Phone = c.Phone;
                accli.add(a);
            }
            else if (AcCon.get(c.AccountId) == 0) {
                zeroli.add(Accmap.get(c.AccountId));
            }else if(AcCon.get(c.AccountId) > 1){
                errorli.add(c.AccountId);
                //adderror                
            }
        }

        update accli;
}
