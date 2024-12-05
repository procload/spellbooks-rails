import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];

  toggle() {
    this.menuTarget.classList.toggle("hidden");
  }

  connect() {
    this.clickOutsideHandler = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.clickOutsideHandler);
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler);
  }

  handleClickOutside(event) {
    if (
      !this.element.contains(event.target) &&
      !this.menuTarget.classList.contains("hidden")
    ) {
      this.menuTarget.classList.add("hidden");
    }
  }
}
