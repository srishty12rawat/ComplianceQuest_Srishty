public class PartProductAssociation_Schedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        List<SQX_Part__c> partsToAssociate = [SELECT Id, Name, Part_Number__c, Product__c, Active__c FROM SQX_Part__c 
            									WHERE Active__c = true AND Product__c = null];

        Set<String> partNames = new Set<String>();
        Set<String> partNumbers = new Set<String>();
        for (SQX_Part__c part : partsToAssociate) {
            partNames.add(part.Name);
            partNumbers.add(part.Part_Number__c);
        }

        Map<String, Product2> existingProductsByCode = new Map<String, Product2>();
        for (Product2 prod : [SELECT Id, Name, ProductCode FROM Product2 WHERE Name IN :partNames OR ProductCode IN :partNumbers]) {
            existingProductsByCode.put(prod.ProductCode, prod);
        }

        List<Product2> productsToCreate = new List<Product2>();
        List<SQX_Part__c> partsToUpdate = new List<SQX_Part__c>();

        for (SQX_Part__c part : partsToAssociate) {
            Product2 existingProd = existingProductsByCode.get(part.Part_Number__c);

            if (existingProd != null) {
                part.Product__c = existingProd.Id;
                partsToUpdate.add(part);
            } else {
                Product2 newProd = new Product2(Name = part.Name, ProductCode = part.Part_Number__c, IsActive = true);
                productsToCreate.add(newProd);
            }
        }

        if (!productsToCreate.isEmpty()) {
            Database.insert(productsToCreate, false);
            Map<String, Id> newProductIdsByCode = new Map<String, Id>();
            for (Product2 prod : productsToCreate) {
                if(prod.Id != null){
                	newProductIdsByCode.put(prod.ProductCode, prod.Id);
                }
            }
            for (SQX_Part__c part : partsToAssociate) {
                if (part.Product__c == null) { 
                    part.Product__c = newProductIdsByCode.get(part.Part_Number__c);
                    partsToUpdate.add(part);
                }
            }
        }

        if (!partsToUpdate.isEmpty()) {
            Database.update(partsToUpdate, false);
        }
    }

}