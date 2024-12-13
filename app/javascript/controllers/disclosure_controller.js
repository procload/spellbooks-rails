import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content", "icon", "trigger"];

  connect() {
    // Ensure dropdown content has high z-index
    this.contentTarget.classList.add("z-50");
  }

  toggle(event) {
    // Only toggle if the click was on the trigger (chevron)
    if (!event.target.closest("[data-disclosure-target='trigger']")) {
      return;
    }

    this.contentTarget.classList.toggle("hidden");
    this.iconTarget.classList.toggle("rotate-90");
  }

  open() {
    this.contentTarget.classList.remove("hidden");
    this.iconTarget.classList.add("rotate-90");
  }

  close() {
    this.contentTarget.classList.add("hidden");
    this.iconTarget.classList.remove("rotate-90");
  }
}
