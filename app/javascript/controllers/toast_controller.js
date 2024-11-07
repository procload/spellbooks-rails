import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notification"];

  connect() {
    this.show();

    if (this.element.classList.contains("auto-hide")) {
      setTimeout(() => {
        this.hide();
      }, 5000);
    }
  }

  show() {
    this.notificationTarget.classList.remove("hidden");
    setTimeout(() => {
      this.notificationTarget.classList.add(
        "opacity-100",
        "transform",
        "translate-y-0"
      );
      this.notificationTarget.classList.remove(
        "opacity-0",
        "transform",
        "translate-y-2"
      );
    }, 100);
  }

  hide() {
    this.notificationTarget.classList.add(
      "opacity-0",
      "transform",
      "translate-y-2"
    );
    this.notificationTarget.classList.remove(
      "opacity-100",
      "transform",
      "translate-y-0"
    );

    setTimeout(() => {
      this.notificationTarget.classList.add("hidden");
    }, 500);
  }
}
