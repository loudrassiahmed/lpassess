import { LightningElement, api } from 'lwc';
import getConsentsBySObjectId from '@salesforce/apex/LPLAN_ConsentsManagementController.getConsentsBySObjectId';
import updateCustomerConsentsByEmail from '@salesforce/apex/LPLAN_ConsentsManagementController.updateCustomerConsentsByEmail';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveButton from '@salesforce/label/c.LPAN_UpdateConsents_SaveButton';
import manageConsentsTitle from '@salesforce/label/c.LPAN_UpdateConsents_Title';
import optOut from '@salesforce/label/c.LPAN_UpdateConsents_OptOut';
import optIn from '@salesforce/label/c.LPAN_UpdateConsents_OptIn';

export default class Lplan_consentsManagementCmp extends LightningElement {
    @api recordId;
    isLoading = true;
    editMode = true;
    labels = {
        saveButton,
        optOut,
        optIn,
        manageConsentsTitle
    };
    consentsWrapper;
    connectedCallback() {
        this.getConsentsBySObjectId();
    }
    getConsentsBySObjectId() {
        getConsentsBySObjectId({ payload: { recordId: this.recordId } })
            .then((result) => {
                this.consentsWrapper = result
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Something went wrong with the Lplan_consentsManagementCmp', error)
                this.isLoading = false;
            });
    }
    handleChangeItem(event) {
        this.consentsWrapper.consentItems[event.target.dataset.index].fieldValue = event.target.checked;
    }
    handleSaveClick() {
        this.isLoading = true;
        this.updateCustomerConsentsByEmail();
    }

    updateCustomerConsentsByEmail() {
        updateCustomerConsentsByEmail({ consentWrapper: this.consentsWrapper })
            .then((result) => {
                this.showToast('', result, 'success', 'pester');
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Something went wrong with the updateCustomerConsentsByEmail', error)
                this.isLoading = false;
            });
    }
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}