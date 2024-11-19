import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notification"];

  connect() {
    console.log("[Toast] Controller connected", {
      element: this.element,
      hasAutoHide: this.element.classList.contains("auto-hide"),
      notificationTarget: this.notificationTarget,
    });
    this.show();

    if (this.element.classList.contains("auto-hide")) {
      console.log("[Toast] Auto-hide enabled, scheduling hide in 5 seconds");
      setTimeout(() => {
        this.hide();
      }, 5000);
    }
  }

  show() {
    console.log("[Toast] Show method called");
    requestAnimationFrame(() => {
      console.log("[Toast] First animation frame - removing hidden class");
      this.notificationTarget.classList.remove("hidden");

      requestAnimationFrame(() => {
        console.log(
          "[Toast] Second animation frame - adding animation classes"
        );
        this.notificationTarget.classList.remove("opacity-0", "translate-y-2");
        this.notificationTarget.classList.add("opacity-100", "translate-y-0");
      });
    });
  }

  hide() {
    console.log("[Toast] Hide method called");
    this.notificationTarget.classList.remove("opacity-100", "translate-y-0");
    this.notificationTarget.classList.add("opacity-0", "translate-y-2");

    setTimeout(() => {
      console.log("[Toast] Cleanup - removing element");
      this.notificationTarget.classList.add("hidden");
      this.element.remove();
    }, 500);
  }
}
