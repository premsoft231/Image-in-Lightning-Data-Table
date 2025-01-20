import { LightningElement, api } from 'lwc';
export default class ImageControl extends LightningElement {

    @api url;
    @api altText;

    handleImageError(event) {
        // Fallback to a default image if the provided URL fails to load
        event.target.src = '/slds/icons/utility/image.svg';
        console.log(' event.target.src:::>>' , event.target.src );
    }
}
