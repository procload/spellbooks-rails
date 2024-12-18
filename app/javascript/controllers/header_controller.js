import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["logo"];

  connect() {
    // Initialize last scroll position and state
    this.lastScrollTop = 0;
    this.isHidden = false;

    // Bind the scroll handler to maintain correct context
    this.handleScroll = this.handleScroll.bind(this);

    // Add scroll event listener
    window.addEventListener("scroll", this.handleScroll, { passive: true });
  }

  disconnect() {
    // Clean up event listener when controller disconnects
    window.removeEventListener("scroll", this.handleScroll);
  }

  handleScroll() {
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    const scrollDelta = scrollTop - this.lastScrollTop;

    // Don't do anything if the scroll amount is too small
    if (Math.abs(scrollDelta) <= 5) {
      return;
    }

    // Hide header when scrolling down, show when scrolling up
    if (scrollDelta > 0 && !this.isHidden && scrollTop > 100) {
      // Scrolling down & header is visible & past threshold
      this.element.classList.add("header-hidden");
      this.isHidden = true;
    } else if ((scrollDelta < 0 || scrollTop <= 100) && this.isHidden) {
      // Scrolling up or at top & header is hidden
      this.element.classList.remove("header-hidden");
      this.isHidden = false;
    }

    this.lastScrollTop = scrollTop;
  }
}
