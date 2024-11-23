import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["answerButton", "spinner", "form"];

  connect() {
    this.element.addEventListener(
      "turbo:submit-start",
      this.submitStart.bind(this)
    );
    this.element.addEventListener(
      "turbo:submit-end",
      this.submitEnd.bind(this)
    );
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

  selectAnswer(event) {
    event.preventDefault();

    // Remove selected state from all buttons
    this.answerButtonTargets.forEach((button) => {
      button.classList.remove("border-blue-500", "bg-blue-50", "text-blue-700");
      button.classList.add("border-gray-200", "bg-white");
    });

    // Add selected state to clicked button
    const button = event.currentTarget;
    button.classList.remove("border-gray-200", "bg-white");
    button.classList.add("border-blue-500", "bg-blue-50", "text-blue-700");

    // Submit the form after a shorter delay (150ms instead of 300ms)
    setTimeout(() => {
      const form = button.closest("form");
      form.requestSubmit(button);
    }, 0);
  }

  submitStart(event) {
    // Disable all buttons during submission but maintain selected state
    this.answerButtonTargets.forEach((button) => {
      button.disabled = true;
      button.classList.add("opacity-75");

      // Don't add cursor-not-allowed to maintain visual consistency
      if (!button.classList.contains("border-blue-500")) {
        button.classList.add("cursor-default");
      }
    });

    this.spinnerTarget.classList.remove("hidden");
  }

  submitEnd() {
    // Re-enable buttons but maintain selected state
    this.answerButtonTargets.forEach((button) => {
      button.disabled = false;
      button.classList.remove("opacity-75", "cursor-default");
    });
    this.spinnerTarget.classList.add("hidden");
  }
}
