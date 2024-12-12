import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["control"];

  connect() {
    this.updateSelection();
  }

  toggle(event) {
    this.updateSelection();
  }

  updateSelection() {
    const selectedInput = this.element.querySelector("input:checked");
    if (selectedInput) {
      // You can add custom behavior here when selection changes
      console.log("Selected value:", selectedInput.value);
    }
  }
}
