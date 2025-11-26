@isTest
public class PartProductAssociation_Schedule_Test {
	static testMethod void testPartProductAssociation() {
        Profile adminProf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            LastName = 'User',
            FirstName = 'adminTest',
            Email = 'adminTestUser@compliance.com',
            Username = 'adminTestUser@compliance.com',
            ProfileId = adminProf.Id
        );
        insert testUser;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CQ_Product_Admin' LIMIT 1];
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
        insert psa;

        Product2 existingProd = new Product2(
            Name = 'Existing Product Name',
            ProductCode = 'PN-12345',
            IsActive = true
        );
        insert existingProd;
        
        SQX_Part__c part1 = new SQX_Part__c(
            Name = 'Existing Product',
            Part_Number__c = 'PN-12345',
            Active__c = true,
            Product__c = null
        );

        SQX_Part__c part2 = new SQX_Part__c(
            Name = 'New Product',
            Part_Number__c = 'PN-67890',
            Active__c = true,
            Product__c = null
        );

        insert new List<SQX_Part__c>{part1, part2};
        System.runAs(testUser) {
            Test.startTest();
            PartProductAssociation_Schedule classSchedule = new PartProductAssociation_Schedule();
            String jobId = System.schedule('Test Association Job', '0 0 * * * ?', classSchedule);
            Test.stopTest();
        }

        SQX_Part__c updatedPart1 = [SELECT Id, Product__c FROM SQX_Part__c WHERE Id = :part1.Id];
        System.assertEquals(existingProd.Id, updatedPart1.Product__c, 'Part 1 should be linked to the existing product.');

        SQX_Part__c updatedPart2 = [SELECT Id, Product__c FROM SQX_Part__c WHERE Id = :part2.Id];
        System.assertNotEquals(null, updatedPart2.Product__c, 'Part 2 should have a product lookup reference.');

        Product2 newProd = [SELECT Id, Name, ProductCode, IsActive FROM Product2 WHERE ProductCode = 'PN-67890' LIMIT 1];
        System.assertEquals('New Product Name', newProd.Name, 'The new product should have the correct name.');
        System.assertEquals(true, newProd.IsActive, 'The new product should be active.');
        System.assertEquals(newProd.Id, updatedPart2.Product__c, 'Part 2 should be linked to the newly created product.');

        List<Product2> allProducts = [SELECT Id FROM Product2];
        System.assertEquals(2, allProducts.size(), 'Only two products should exist in the test context (one existing, one new).');
    }
}