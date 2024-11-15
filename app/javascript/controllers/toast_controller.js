import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notification"];

  connect() {
    console.log("Toast controller connected");
    this.show();

    if (this.element.classList.contains("auto-hide")) {
      console.log("Auto-hide enabled, will hide in 5 seconds");
      setTimeout(() => {
        this.hide();
      }, 5000);
    }
  }

  show() {
    console.log("Showing toast");
    requestAnimationFrame(() => {
      this.notificationTarget.classList.remove("hidden");

      requestAnimationFrame(() => {
        console.log("Animating toast in");
        this.notificationTarget.classList.remove("opacity-0", "translate-y-2");
        this.notificationTarget.classList.add("opacity-100", "translate-y-0");
      });
    });
  }

  hide() {
    console.log("Hiding toast");
    this.notificationTarget.classList.remove("opacity-100", "translate-y-0");
    this.notificationTarget.classList.add("opacity-0", "translate-y-2");

    setTimeout(() => {
      this.notificationTarget.classList.add("hidden");
      this.element.remove();
    }, 500);
  }
}
