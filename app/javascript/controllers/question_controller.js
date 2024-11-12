import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["displayContent", "editForm", "feedback", "correctAnswer"];

  connect() {
    // Initialize any necessary state when the controller connects
    this.setupAnswerSelectionHandlers();

    this.element.addEventListener(
      "turbo:submit-start",
      this.handleSubmitStart.bind(this)
    );
    this.element.addEventListener(
      "turbo:submit-end",
      this.handleSubmitEnd.bind(this)
    );
  }

  setupAnswerSelectionHandlers() {
    // Find all correct answer checkboxes within this controller's scope
    const checkboxes = this.element.querySelectorAll(
      'input[type="checkbox"][name*="[is_correct]"]'
    );
    checkboxes.forEach((checkbox) => {
      checkbox.addEventListener("change", (event) =>
        this.handleCorrectAnswerSelection(event)
      );
    });
  }

  handleCorrectAnswerSelection(event) {
    const selectedCheckbox = event.target;

    if (selectedCheckbox.checked) {
      // Uncheck all other checkboxes within this question's form
      const form = selectedCheckbox.closest("form");
      form
        .querySelectorAll('input[type="checkbox"][name*="[is_correct]"]')
        .forEach((checkbox) => {
          if (checkbox !== selectedCheckbox) {
            checkbox.checked = false;
          }
        });
    }
  }

  toggleEdit(event) {
    event.preventDefault();
    this.displayContentTarget.classList.toggle("hidden");
    this.editFormTarget.classList.toggle("hidden");
  }

  submitAnswer(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);

    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
      },
      credentials: "same-origin",
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.correct) {
          this.showFeedback(
            "Correct! " + data.explanation,
            "bg-green-100 text-green-800"
          );
        } else {
          this.showFeedback(
            "Incorrect. " + data.explanation,
            "bg-red-100 text-red-800"
          );
        }
      })
      .catch((error) => {
        console.error("Error submitting answer:", error);
        this.showFeedback(
          "Error submitting answer. Please try again.",
          "bg-red-100 text-red-800"
        );
      });
  }

  showFeedback(message, classes) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message;
      this.feedbackTarget.className = `p-4 rounded-lg mt-4 ${classes}`;
      this.feedbackTarget.classList.remove("hidden");
    }
  }

  update(event) {
    event.preventDefault();
    const form = event.target;
    const formData = new FormData(form);

    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content,
      },
      credentials: "same-origin",
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          this.displayContentTarget.innerHTML = data.html;
          this.toggleEdit(event);
        } else {
          // Handle errors
          console.error("Failed to update question:", data.errors);
        }
      })
      .catch((error) => {
        console.error("Error updating question:", error);
      });
  }

  handleSubmit(event) {
    event.preventDefault();
    const form = event.target.closest("form");
    const selectedRadio = form.querySelector(
      'input[name="correct_answer"]:checked'
    );

    if (selectedRadio) {
      // Reset all answers to false
      form.querySelectorAll('input[name$="[is_correct]"]').forEach((input) => {
        input.value = "false";
      });

      // Set the selected answer to true
      const selectedAnswerId = selectedRadio.value;
      const selectedHiddenField = form.querySelector(
        `input[name$="[${selectedAnswerId}][is_correct]"]`
      );
      if (selectedHiddenField) {
        selectedHiddenField.value = "true";
      }
    }

    form.submit();
  }

  handleSubmitStart(event) {
    console.log("Form submission started", event.detail);
  }

  handleSubmitEnd(event) {
    console.log("Form submission completed", event.detail);
  }
}
