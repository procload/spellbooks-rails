import { Controller } from "@hotwired/stimulus";

// Handles the interactive behavior of answer choice components
export default class extends Controller {
  static targets = ["input"];
  static values = {
    selected: Boolean,
    disabled: Boolean,
  };

  connect() {
    // Initialize state
    this.selectedValue = this.inputTarget.checked;
  }

  // Handle selection of the answer choice
  select(event) {
    if (this.disabledValue) return;

    // Prevent the default radio button behavior
    event.preventDefault();

    // Deselect all other answers in the form
    const form = this.element.closest("form");
    if (form) {
      form
        .querySelectorAll('[data-controller="answer-choice"]')
        .forEach((choice) => {
          const controller =
            this.application.getControllerForElementAndIdentifier(
              choice,
              "answer-choice"
            );
          if (controller && controller !== this) {
            controller.selectedValue = false;
          }
        });
    }

    // Update the radio button state and selected value
    this.inputTarget.checked = true;
    this.selectedValue = true;

    // Submit the form
    if (form) {
      // Create a hidden input with the answer value
      const hiddenInput = document.createElement("input");
      hiddenInput.type = "hidden";
      hiddenInput.name = "answer";
      hiddenInput.value = this.inputTarget.value;

      // Add it to the form temporarily
      form.appendChild(hiddenInput);

      // Submit the form using Turbo
      form.requestSubmit();

      // Remove the temporary input
      form.removeChild(hiddenInput);
    }
  }

  // Handle changes to the selected value
  selectedValueChanged() {
    if (this.selectedValue) {
      this.element.classList.add("border-primary", "bg-primary-muted/20");
      this.element
        .querySelector(".flex-shrink-0")
        .classList.add("bg-primary", "text-primary-foreground");
      this.element
        .querySelector(".flex-shrink-0")
        .classList.remove("bg-muted", "text-muted-foreground");
    } else {
      this.element.classList.remove("border-primary", "bg-primary-muted/20");
      this.element
        .querySelector(".flex-shrink-0")
        .classList.remove("bg-primary", "text-primary-foreground");
      this.element
        .querySelector(".flex-shrink-0")
        .classList.add("bg-muted", "text-muted-foreground");
    }
  }
}
