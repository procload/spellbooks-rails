import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    url: String,
    status: String,
  };

  async update(event) {
    event.preventDefault();

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('[name="csrf-token"]').content,
        },
        body: JSON.stringify({ status: this.statusValue }),
      });

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      // Update button styles
      this.element.querySelectorAll("button").forEach((button) => {
        const isSelected =
          button.dataset.assignmentStatusValue === this.statusValue;
        button.className = `px-3 py-1 rounded text-sm font-medium ${
          isSelected
            ? "bg-primary text-white"
            : "bg-gray-100 text-gray-700 hover:bg-gray-200"
        }`;
      });
    } catch (error) {
      console.error("Error:", error);
    }
  }
}
