import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["menu"];
  static values = {
    loading: Boolean,
  };

  connect() {
    this.clickOutsideHandler = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.clickOutsideHandler);
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler);
  }

  toggle(event) {
    event.stopPropagation();
    this.menuTarget.classList.toggle("hidden");
  }

  handleClickOutside(event) {
    if (
      !this.element.contains(event.target) &&
      !this.menuTarget.classList.contains("hidden")
    ) {
      this.menuTarget.classList.add("hidden");
    }
  }

  // Method to handle any action click
  async handleAction(event) {
    event.preventDefault();
    const action = event.currentTarget.dataset.action;
    const url = event.currentTarget.dataset.url;
    const method = event.currentTarget.dataset.method || "POST";

    this.loadingValue = true;

    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          Accept: "text/vnd.turbo-stream.html",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
      });

      if (!response.ok)
        throw new Error(`HTTP error! status: ${response.status}`);

      const html = await response.text();
      Turbo.renderStreamMessage(html);
    } catch (error) {
      console.error("Error:", error);
    } finally {
      this.loadingValue = false;
      this.menuTarget.classList.add("hidden");
    }
  }
}
