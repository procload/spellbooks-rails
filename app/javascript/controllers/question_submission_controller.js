import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["spinner", "submitButton"];

  connect() {
    this.element.addEventListener(
      "turbo:submit-start",
      this.submitStart.bind(this)
    );
    this.element.addEventListener(
      "turbo:submit-end",
      this.submitEnd.bind(this)
    );
    
    // Initialize disabled state
    if (this.hasSubmitButtonTarget) {
      const form = this.element.closest('form');
      const hasStudentAnswer = form.querySelector('input[type="radio"]:disabled');
      if (hasStudentAnswer) {
        this.submitButtonTarget.disabled = true;
      }
    }
  }

  disconnect() {
    this.element.removeEventListener(
      "turbo:submit-start",
      this.submitStart.bind(this)
    );
    this.element.removeEventListener(
      "turbo:submit-end",
      this.submitEnd.bind(this)
    );
  }

  submitStart() {
    this.spinnerTarget.classList.remove("hidden");
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true;
    }
  }

  submitEnd() {
    this.spinnerTarget.classList.add("hidden");
    
    // Ensure button stays disabled after submission
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true;
      this.submitButtonTarget.classList.add('opacity-50', 'cursor-not-allowed');
    }
    
    // Disable all radio inputs
    this.element.querySelectorAll('input[type="radio"]').forEach(input => {
      input.disabled = true;
    });
    
    // Update label styles
    this.element.querySelectorAll('label').forEach(label => {
      label.classList.remove('hover:bg-gray-50', 'cursor-pointer');
      label.classList.add('cursor-not-allowed', 'opacity-75');
    });
  }
}
