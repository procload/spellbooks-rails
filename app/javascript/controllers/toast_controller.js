import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notification"];

  connect() {
    // Hide the notification after 5 seconds
    setTimeout(() => {
      this.hide();
    }, 5000);
  }

  hide() {
    this.notificationTarget.classList.add("opacity-0", "transition-opacity");
    setTimeout(() => {
      this.notificationTarget.remove();
    }, 500);
  }
}
