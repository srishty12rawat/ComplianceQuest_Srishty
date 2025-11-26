# ComplianceQuest_Srishty
-> Added PartProductAssociation_Schedule, which will be scheduled to associate Part with Product.
-> Added Permission Set 'CQ_Product_Admin'
-> To schedule this job, there are 2 ways to implement:-
    -> <img width="1481" height="677" alt="image" src="https://github.com/user-attachments/assets/e03ca077-0fab-4992-b45e-70099d864895" />
    -> Or, we can use cron expression to schedule this job -
    System.schedule('PartProductAssociationJob', '0 0 6 * * ?', new PartProductAssociation_Schedule());
-> Added a permission set with apex class access
