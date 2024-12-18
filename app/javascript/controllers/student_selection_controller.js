import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "search",
    "list",
    "student",
    "checkbox",
    "selectAll",
    "counter",
    "clearButton",
    "dropdown",
    "form",
  ];

  static values = {
    processing: Boolean,
  };

  initialize() {
    super.initialize();
    this.updateSelectedCount();
  }

  connect() {
    super.connect();
    this.updateCounter();
    this.updateRowStates();
    this.boundHandleClickOutside = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.boundHandleClickOutside);

    if (this.processingValue) {
      this.disableAllCheckboxes();
    }
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside);
  }

  processingValueChanged() {
    if (this.processingValue) {
      this.disableAllCheckboxes();
    } else {
      this.enableAllCheckboxes();
    }
  }

  disableAllCheckboxes() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.disabled = true;
    });
    this.selectAllTarget.disabled = true;
  }

  enableAllCheckboxes() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.disabled = false;
    });
    this.selectAllTarget.disabled = false;
  }

  updateSelection() {
    this.updateSelectAllState();
    this.updateCounter();
    this.submitForm();
  }

  updateSelectedCount() {
    const selectedCount = this.checkboxTargets.filter(
      (checkbox) => checkbox.checked
    ).length;
    this.counterTarget.textContent = `${selectedCount} students selected`;
    this.clearButtonTarget.classList.toggle("hidden", selectedCount === 0);
    this.selectAllTarget.checked =
      selectedCount === this.checkboxTargets.length && selectedCount > 0;
  }

  toggleAll(event) {
    const checked = event.target.checked;
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = checked;
    });
    this.updateSelectedCount();
    this.submitForm();
  }

  toggleStudent(event) {
    // Find the checkbox within the clicked row
    const checkbox = event.currentTarget.querySelector(
      'input[type="checkbox"]'
    );
    if (checkbox && !checkbox.disabled) {
      checkbox.checked = !checkbox.checked;
      this.updateSelectedCount();
      this.submitForm();
    }
  }

  stopPropagation(event) {
    // Stop the click event from bubbling up to the row
    event.stopPropagation();
  }

  clearSelection() {
    this.checkboxTargets.forEach((checkbox) => {
      checkbox.checked = false;
    });
    this.updateSelectedCount();
    this.submitForm();
  }

  filter() {
    const query = this.searchTarget.value.toLowerCase();
    this.studentTargets.forEach((student) => {
      const name = student.querySelector("p").textContent.toLowerCase();
      student.parentElement.style.display = name.includes(query) ? "" : "none";
    });
  }

  toggleList() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("hidden");
    }
  }

  showList() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.remove("hidden");
    }
  }

  hideList() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden");
    }
  }

  updateSelectAllState() {
    const totalCheckboxes = this.checkboxTargets.length;
    const checkedCheckboxes = this.checkboxTargets.filter(
      (checkbox) => checkbox.checked
    ).length;

    this.selectAllTarget.checked = totalCheckboxes === checkedCheckboxes;
    this.selectAllTarget.indeterminate =
      checkedCheckboxes > 0 && checkedCheckboxes < totalCheckboxes;
  }

  updateCounter() {
    const selectedCount = this.checkboxTargets.filter(
      (checkbox) => checkbox.checked
    ).length;
    this.counterTarget.textContent = `${selectedCount} selected`;
    this.clearButtonTarget.classList.toggle("hidden", selectedCount === 0);
  }

  updateRowStates() {
    this.studentTargets.forEach((row) => {
      const checkbox = row.querySelector('input[type="checkbox"]');
      if (checkbox) {
        row.classList.toggle("bg-gray-50", checkbox.checked);
      }
    });
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) && this.hasDropdownTarget) {
      this.hideList();
    }
  }

  submitForm(event) {
    // Don't submit if processing
    if (this.processingValue) return;

    // Find the closest form
    const form = this.element.closest("form");
    if (!form) return;

    // Prevent default form submission if event exists
    if (event) {
      event.preventDefault();
    }

    // Create FormData and add current checkbox states
    const formData = new FormData(form);

    // Get current selection state
    const selectedIds = Array.from(this.checkboxTargets)
      .filter((checkbox) => checkbox.checked)
      .map((checkbox) => checkbox.value);

    // Submit form with fetch
    fetch(form.action, {
      method: form.method,
      body: formData,
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest",
      },
      credentials: "same-origin",
    })
      .then((response) => response.text())
      .then((html) => {
        // Parse all Turbo Stream elements and apply them
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, "text/html");
        const streamElements = doc.querySelectorAll("turbo-stream");

        streamElements.forEach((streamElement) => {
          const target = document.getElementById(
            streamElement.getAttribute("target")
          );
          if (target) {
            const content =
              streamElement.querySelector("template").content.firstElementChild;

            // If updating student list, preserve checkbox states
            if (streamElement.getAttribute("target") === "student_list") {
              // Update the content
              target.innerHTML = content.innerHTML;

              // Restore checkbox states
              selectedIds.forEach((id) => {
                const checkbox = target.querySelector(`input[value="${id}"]`);
                if (checkbox) {
                  checkbox.checked = true;
                }
              });

              // Update counter and select all state
              this.updateSelectedCount();
            } else {
              // For other targets, just replace/update as normal
              if (streamElement.getAttribute("action") === "replace") {
                target.replaceWith(content);
              } else if (streamElement.getAttribute("action") === "update") {
                target.innerHTML = content.innerHTML;
              }
            }
          }
        });
      })
      .catch((error) => console.error("Error:", error));
  }

  sortStudents() {
    const container = this.listTarget;
    const items = Array.from(this.studentTargets);

    items.sort((a, b) => {
      const aChecked = a.querySelector('input[type="checkbox"]').checked;
      const bChecked = b.querySelector('input[type="checkbox"]').checked;

      if (aChecked === bChecked) {
        const aName = a.textContent.trim().toLowerCase();
        const bName = b.textContent.trim().toLowerCase();
        return aName.localeCompare(bName);
      }

      return bChecked ? 1 : -1;
    });

    items.forEach((item) => container.appendChild(item));
  }
}
