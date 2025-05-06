import { LightningElement } from 'lwc';

export default class TestComponent extends LightningElement {
    handleClick() {
        console.log('Button clicked!');
    }
}