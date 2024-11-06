import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["explanation", "button", "answer", "feedback"];
  static classes = ["hidden", "correct", "incorrect"];
  static values = {
    correctAnswer: String,
  };

  connect() {
    this.updateButtonText();
  }

  toggle() {
    this.explanationTarget.classList.toggle("hidden");
    this.updateButtonText();
  }

  updateButtonText() {
    const isHidden = this.explanationTarget.classList.contains("hidden");
    this.buttonTarget.textContent = isHidden
      ? "Show Explanation"
      : "Hide Explanation";
  }

  checkAnswer(event) {
    const selectedAnswer = event.target;

    // Remove previous feedback classes from all answers
    this.answerTargets.forEach((answer) => {
      answer.classList.remove(this.correctClass, this.incorrectClass);
    });

    // Check if the selected answer is correct
    if (selectedAnswer.value === this.correctAnswerValue) {
      selectedAnswer
        .closest('[data-explanation-target="answer"]')
        .classList.add(this.correctClass);
      this.showFeedback("Correct! 🎉");
      // Show explanation automatically when correct
      this.explanationTarget.classList.remove(this.hiddenClass);
      this.updateButtonText();
    } else {
      selectedAnswer
        .closest('[data-explanation-target="answer"]')
        .classList.add(this.incorrectClass);
      this.showFeedback("Incorrect. Try again! 🤔");
    }
  }

  showFeedback(message) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message;
      this.feedbackTarget.classList.remove(this.hiddenClass);
      // Ensure screen readers announce the feedback
      this.feedbackTarget.setAttribute("aria-live", "assertive");
    }
  }
}
