import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "image", "button"];

  connect() {
    // Initialize any necessary state
  }

  regenerate(event) {
    event.preventDefault();

    // Show loading state
    this.element
      .querySelector('[data-loading-overlay-target="overlay"]')
      .classList.remove("hidden");
    this.buttonTarget.disabled = true;

    // Submit the form
    const form = event.target.closest("form");
    const submitPromise = new Promise((resolve) => {
      form.addEventListener("turbo:submit-end", () => resolve(), {
        once: true,
      });
      form.requestSubmit();
    });

    // After form submission, poll for image changes
    submitPromise.then(() => this.pollForImageChanges());
  }

  pollForImageChanges() {
    let attempts = 0;
    const maxAttempts = 30; // 30 seconds
    const originalSrc = this.imageTarget.src;
    const baseUrl = window.location.href;

    const checkImage = () => {
      if (attempts >= maxAttempts) {
        this.hideLoading();
        return;
      }

      // Instead of checking the image directly, fetch the assignment page
      fetch(baseUrl)
        .then((response) => response.text())
        .then((html) => {
          const parser = new DOMParser();
          const doc = parser.parseFromString(html, "text/html");
          const newImage = doc.querySelector(
            `[data-image-regeneration-target="image"]`
          );

          if (newImage && newImage.src !== originalSrc) {
            // New image found with different src, update our image
            this.imageTarget.src = newImage.src;
            this.hideLoading();
          } else {
            attempts++;
            setTimeout(checkImage, 1000);
          }
        })
        .catch(() => {
          attempts++;
          setTimeout(checkImage, 1000);
        });
    };

    setTimeout(checkImage, 2000); // Start checking after 2 seconds
  }

  hideLoading() {
    this.element
      .querySelector('[data-loading-overlay-target="overlay"]')
      .classList.add("hidden");
    this.buttonTarget.disabled = false;
  }
}
