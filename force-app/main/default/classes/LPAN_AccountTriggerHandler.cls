public class LPAN_AccountTriggerHandler extends TriggerHandler {

    private Map<Id, Account> oldAccountMap, newAccountMap;

    public LPAN_AccountTriggerHandler() {
        oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
        newAccountMap = (Map<Id, Account>) Trigger.newMap;
    }

    public override void afterUpdate()  {
        Set<ID> ownerIds = new Set<Id>();
        Set<String> accountSencodaryOwnerSet = new  Set<String> ();
        List<Account> accountsToHandle = new List<Account>();

        for(Account account : newAccountMap.values()) {
            Account oldAccount = oldAccountMap.get(account.Id);
            boolean toAdd = false;
            if(!account.OwnerId.equals(oldAccount.OwnerId)) {
                ownerIds.add(account.OwnerId);
                toAdd = true;
            }
            if (String.isNotBlank(account.SecondaryOwner__c) && !account.SecondaryOwner__c.equals(oldAccount.SecondaryOwner__c) && !account.Id.equals(account.SecondaryOwner__c)) {
                ownerIds.add(account.SecondaryOwner__c);
                accountSencodaryOwnerSet.add(account.Id +''+ account.SecondaryOwner__c);
                toAdd = true;
            }
            if (toAdd) {
                accountsToHandle.add(account);
            }
        }

        Map<Id, User> managers = new Map<Id, User>([Select Id, (Select Id, ManagerId, Name FROM ManagedUsers WHERE UserRole.DeveloperName = :LPLAN_Constants.SALES_REP_ROLE) FROM User WHERE Id IN :ownerIds]);
        List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();
        List<AccountShare> accountShareList = new List<AccountShare>();
        for(Account account : accountsToHandle) {
            List<User> salesReps = new List<User> ();

            if(managers.containsKey(account.OwnerId)) {
                salesReps.addAll(managers.get(account.OwnerId).ManagedUsers);
            }

            if(managers.containsKey(account.SecondaryOwner__c) && String.isNotBlank(account.SecondaryOwner__c)) {
                salesReps.addAll(managers.get(account.SecondaryOwner__c).ManagedUsers);
            }

			for(User salesRep: salesReps) {
                Boolean isSecondaryOwner = accountSencodaryOwnerSet.contains(account.id +''+ salesRep.ManagerId);
                AccountTeamMember accountTeamMember = new AccountTeamMember();
                accountTeamMember.AccountId = account.Id;
				accountTeamMember.userId = salesRep.Id;
                accountTeamMember.TeamMemberRole = isSecondaryOwner ? LPLAN_Constants.ACCOUNT_SALESREP_READ_ROLE : LPLAN_Constants.ACCOUNT_SALESREP_EDIT_ROLE;
                accountTeamMemberList.add(accountTeamMember);
                AccountShare accountShare = new AccountShare();
				accountShare.AccountId = account.Id;
				accountShare.UserOrGroupId = salesRep.Id;
                accountShare.AccountAccessLevel = isSecondaryOwner ? LPLAN_Constants.READ_ACCESS : LPLAN_Constants.EDIT_ACCESS;
				accountShare.OpportunityAccessLevel = isSecondaryOwner ? LPLAN_Constants.READ_ACCESS : LPLAN_Constants.EDIT_ACCESS;
				accountShareList.add(accountShare);
			}
        }
        List<SObject> sobjectsToInsert = new List<SObject>();
        sobjectsToInsert.addAll(accountShareList);
        sobjectsToInsert.addAll(accountTeamMemberList);
        insert sobjectsToInsert;
    }

}
