import { LightningElement, track, wire } from 'lwc';
import getProductDetails from '@salesforce/apex/ProductController.getProductDetails';

const columns = [
    { label: 'Product Name', fieldName: 'name' },
    { label: 'Product Code', fieldName: 'productCode' },
    { label: 'Description', fieldName: 'description' },
    { 
        label: 'Image', 
        fieldName: 'imageUrl', 
        type: 'image', 
        typeAttributes: { 
            altText: 'Product Image',
            fallbackValue: '/slds/icons/utility/image.svg'
        } 
    }
];

export default class ProductDataTable extends LightningElement {
    @track productData = [];
    columns = columns;

    @wire(getProductDetails)
    wiredData({ error, data }) {
        if (data) {
            this.productData = data;
            console.log('Product Data:', JSON.stringify(this.productData));
        } else if (error) {
            console.error('Error fetching product data:', error);
        }
    }
}
