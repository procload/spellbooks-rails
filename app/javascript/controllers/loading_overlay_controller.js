import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay"];

  connect() {
    // Listen for turbo stream events
    this.element.addEventListener(
      "turbo:before-stream-render",
      this.hideOverlay.bind(this)
    );
  }

  disconnect() {
    this.element.removeEventListener(
      "turbo:before-stream-render",
      this.hideOverlay.bind(this)
    );
  }

  showOverlay() {
    this.overlayTarget.classList.remove("hidden");
  }

  hideOverlay() {
    this.overlayTarget.classList.add("hidden");
  }
}
