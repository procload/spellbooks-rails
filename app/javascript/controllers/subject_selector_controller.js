import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];

  connect() {
    this.updateSelection();
  }

  toggle() {
    this.updateSelection();
  }

  updateSelection() {
    const isSelected = this.inputTarget.checked;
    this.element.classList.toggle("selected", isSelected);
  }
}
