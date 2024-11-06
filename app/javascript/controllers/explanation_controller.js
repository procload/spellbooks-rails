import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["explanation", "button"];
  static classes = ["hidden"];

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
}
