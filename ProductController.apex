/**
* @File Name : ProductController.cls
* @Description : Controller to fetch Product details along with associated images.
* @Author :Prem Singh Foujdar
* @Last Modified By :Prem Singh Foujdar
* @Last Modified On : January 20, 2025
**/


public class ProductController {
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> getProductDetails() {
        List<Product2> getProducts = [SELECT Id, Name, ProductCode, Description FROM Product2 LIMIT 5];

        Set<Id> productIds = new Set<Id>();
        for (Product2 product : getProducts) {
            productIds.add(product.Id);
        }

        Map<Id, String> productToImageMap = new Map<Id, String>();

        if (!productIds.isEmpty()) {
            // Query ContentDocumentLinks for the Products
            List<ContentDocumentLink> links = [
                SELECT LinkedEntityId, ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN :productIds
            ];
            System.debug('ContentDocumentLinks: ' + links);

            // Collect ContentDocumentIds
            Set<Id> contentDocIds = new Set<Id>();
            for (ContentDocumentLink link : links) {
                contentDocIds.add(link.ContentDocumentId);
            }
            System.debug('ContentDocument IDs: ' + contentDocIds);

            if (!contentDocIds.isEmpty()) {
                // Query ContentVersions for the ContentDocuments
                List<ContentVersion> versions = [
                    SELECT ContentDocumentId, Id 
                    FROM ContentVersion 
                    WHERE ContentDocumentId IN :contentDocIds
                ];
                System.debug('ContentVersions: ' + versions);

                // Build the Product to Image Map by using LinkedEntityId (Product Id)
                for (ContentVersion version : versions) {
                    for (ContentDocumentLink link : links) {
                        if (link.ContentDocumentId == version.ContentDocumentId) {
                            productToImageMap.put(link.LinkedEntityId, '/sfc/servlet.shepherd/version/download/' + version.Id);
                        }
                    }
                }
            }
        }

        System.debug('Product to Image Map: ' + productToImageMap);

        // Build the ProductWrapper List
        List<ProductWrapper> productList = new List<ProductWrapper>();
        for (Product2 product : getProducts) {
            String imageUrl = productToImageMap.containsKey(product.Id) 
                ? productToImageMap.get(product.Id) 
                : null;
            productList.add(new ProductWrapper(product, imageUrl));
        }
        System.debug('Product List (with Images): ' + productList);

        return productList;
    }

    public class ProductWrapper {
        @AuraEnabled public Id productId;
        @AuraEnabled public String name;
        @AuraEnabled public String productCode;
        @AuraEnabled public String description;
        @AuraEnabled public String imageUrl;

        public ProductWrapper(Product2 product, String imageUrl) {
            this.productId = product.Id;
            this.name = product.Name;
            this.productCode = product.ProductCode;
            this.description = product.Description;
            this.imageUrl = imageUrl;
        }
    }
}
