trigger ContactUpdateInsertTrigger on Contact (after insert, after update) {
    
     // contacts will be having id,accountid , so adding to their respective id 
    Set<Id> accountIdSet= new Set<Id>();
    Set<Id> contactIdSet=new Set<Id>();
    //converting from List to set to avoid duplicate Id issue
    Set<Account> updateAccList=new Set<Account>();
    Set<Contact> Cnttoupdate=new Set<Contact>();
            
    for(Contact contact:Trigger.new)
    {
        accountIdSet.add(contact.accountId);
        contactIdSet.add(contact.Id);
    }
    //will have all unique contact and account
    // Get accounts with their contacts.
    Map<Id,Account> accountMap=new Map<Id,Account>([select id, Phone,(select id, Name from Contacts where Is_Primary__c=true and id not in :contactIdSet) from Account where Id in: accountIdSet]); 
    // will have accounts mapped with their ids with all contacts not in triggernew
    Map<Id,contact>cntMap=new Map<Id,Contact>();
    

    //why we use map of sobjects with their ids as their keys Here set should do fine ?
    for(Account acc: accountMap.values()){
        for(Contact con : acc.contacts){
            cntMap.put(con.Id,con);
        }   
    }
    // will have all contacts mapped with soon to be updated accounts                                                        
   // checking the data     
    for(Contact con:Trigger.new)
    {   
        // why 2 contradictory conditions only 2nd will do ?
        if(con.Is_Primary__c != null && con.Is_Primary__c){
            Account ac=accountMap.get(con.AccountId);
            if(!updateAccList.contains(ac))
            {
                // if not in updateacclist then this operation
                for(Contact existing_cnt : ac.contacts){
                    //falsing is_primary__c of all contact related to  ac
                    existing_cnt.Is_Primary__c=false;
                    cnttoupdate.add(existing_cnt);
                }	                   
                ac.Phone=con.Phone;    
                updateAccList.add(ac);
            }
            else{
                con.adderror('Error ! Cannot add another primary account');
            }
        }
    }
    if(!cnttoupdate.isEmpty()){
        //converting back to list since dml cannot happen on Set
        update new List<Contact>(cnttoupdate);
    }
    if(!updateAccList.isEmpty()){
        //converting back to list since dml cannot happen on Set
        update new List<Account>(updateAccList);  
    }
}