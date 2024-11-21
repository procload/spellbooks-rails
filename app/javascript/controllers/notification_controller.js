import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content"];
  static values = {
    type: String,
    autoHide: { type: Boolean, default: true },
    duration: { type: Number, default: 5000 },
  };

  connect() {
    this.show();

    if (this.autoHideValue) {
      this.hideTimeout = setTimeout(() => this.hide(), this.durationValue);
    }
  }

  disconnect() {
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
    }
  }

  show() {
    requestAnimationFrame(() => {
      this.contentTarget.classList.remove("hidden");

      requestAnimationFrame(() => {
        this.contentTarget.classList.remove("opacity-0", "translate-y-2");
        this.contentTarget.classList.add("opacity-100", "translate-y-0");
      });
    });
  }

  hide() {
    this.contentTarget.classList.remove("opacity-100", "translate-y-0");
    this.contentTarget.classList.add("opacity-0", "translate-y-2");

    setTimeout(() => {
      this.element.remove();
    }, 300);
  }
}
