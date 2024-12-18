import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "tagsContainer", "field", "suggestions"];
  static values = {
    debounce: { type: Number, default: 300 },
  };

  connect() {
    this.updateTags();
    this.boundDebouncedFetch = this.debounce(
      this.fetchSuggestions.bind(this),
      this.debounceValue
    );

    // Listen for changes to the field value
    this.fieldTarget.addEventListener('change', () => this.updateTags());
  }

  add(event) {
    if (event.type === "keydown" && event.key !== "Enter") {
      return;
    }

    event.preventDefault();
    const interest = this.inputTarget.value.trim();
    if (interest) {
      this.addInterest(interest);
      this.inputTarget.value = "";
      this.suggestionsTarget.innerHTML = "";
    }
  }

  addSuggested(event) {
    event.preventDefault();
    const button = event.currentTarget;
    const interest = button.textContent.trim();
    this.addInterest(interest);
    this.inputTarget.value = "";
    this.suggestionsTarget.innerHTML = "";
    
    // Replace the clicked suggestion with a new one
    this.replaceSuggestion(button);
  }

  async replaceSuggestion(button) {
    const response = await fetch('/interests/random');
    const data = await response.json();
    if (data.interest) {
      button.textContent = data.interest;
    } else {
      button.remove();
    }
  }

  remove(event) {
    event.preventDefault();
    const interest = event.currentTarget.dataset.interest;
    const currentInterests = this.currentInterests;
    const index = currentInterests.indexOf(interest);

    if (index > -1) {
      currentInterests.splice(index, 1);
      this.fieldTarget.value = currentInterests.join(", ");
      this.updateTags();
    }
  }

  addInterest(interest) {
    const currentInterests = this.currentInterests;
    if (!currentInterests.includes(interest)) {
      currentInterests.push(interest);
      this.fieldTarget.value = currentInterests.join(", ");
      this.updateTags();
    }
  }

  get currentInterests() {
    return this.fieldTarget.value
      .split(",")
      .map((i) => i.trim())
      .filter((i) => i);
  }

  updateTags() {
    const interests = this.currentInterests;
    this.tagsContainerTarget.innerHTML = interests
      .map(
        (interest) => `
      <span class="bg-spellbooks-sidebar text-foreground px-3 py-1 rounded-full text-sm flex items-center gap-1">
        ${interest}
        <button type="button" 
                data-interests-target="removeButton"
                data-action="click->interests#remove"
                data-interest="${interest}"
                class="text-foreground hover:text-spellbooks-element-hover">×</button>
      </span>
    `
      )
      .join("");
  }

  // Typeahead functionality
  async input(event) {
    this.boundDebouncedFetch(event.target.value);
  }

  async fetchSuggestions(query) {
    if (!query || query.length < 2) {
      this.suggestionsTarget.innerHTML = "";
      return;
    }

    try {
      const response = await fetch(
        `/interests/suggestions?query=${encodeURIComponent(query)}`,
        {
          headers: {
            Accept: "text/vnd.turbo-stream.html",
          },
        }
      );
      const html = await response.text();
      this.suggestionsTarget.innerHTML = html;
    } catch (error) {
      console.error("Error fetching suggestions:", error);
    }
  }

  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
}
