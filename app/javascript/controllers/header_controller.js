import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["logo"];

  connect() {
    // Initialize last scroll position
    this.lastScrollTop = 0;
    this.isCompact = false;

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

    // Toggle compact mode when scrolling past threshold
    if (scrollTop > 10 && !this.isCompact) {
      this.element.classList.add("header-compact");
      this.isCompact = true;
    } else if (scrollTop <= 10 && this.isCompact) {
      this.element.classList.remove("header-compact");
      this.isCompact = false;
    }

    this.lastScrollTop = scrollTop;
  }
}
