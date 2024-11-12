import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["submitButton", "spinner"];

  submit(event) {
    // Prevent double submissions
    if (this.submitButtonTarget.disabled) return;

    // Disable the submit button and show spinner
    this.submitButtonTarget.disabled = true;
    this.spinnerTarget.classList.remove("hidden");
  }
}
