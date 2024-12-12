import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["spinner", "form"];

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

  submitStart() {
    this.spinnerTarget.classList.remove("hidden");

    // Disable all answer choices during submission
    this.element
      .querySelectorAll('[data-controller="answer-choice"]')
      .forEach((choice) => {
        choice.dataset.answerChoiceDisabledValue = "true";
      });
  }

  submitEnd() {
    this.spinnerTarget.classList.add("hidden");

    // Re-enable all answer choices after submission
    this.element
      .querySelectorAll('[data-controller="answer-choice"]')
      .forEach((choice) => {
        choice.dataset.answerChoiceDisabledValue = "false";
      });
  }
}
