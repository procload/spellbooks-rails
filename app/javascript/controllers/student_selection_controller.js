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
  ];

  connect() {
    this.updateCounter();
    this.updateRowStates();
    this.boundHandleClickOutside = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.boundHandleClickOutside);
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleClickOutside);
  }

  filter() {
    const query = this.searchTarget.value.toLowerCase();
    this.studentTargets.forEach((student) => {
      const text = student.textContent.toLowerCase();
      student.classList.toggle("hidden", !text.includes(query));
    });
    this.sortStudents();
  }

  toggleAll(event) {
    const checked = event.target.checked;
    this.checkboxTargets.forEach((checkbox) => {
      if (
        !checkbox
          .closest("[data-student-selection-target='student']")
          .classList.contains("hidden")
      ) {
        checkbox.checked = checked;
      }
    });
    this.updateCounter();
    this.updateRowStates();
    this.sortStudents();
  }

  updateSelection() {
    this.updateCounter();
    this.updateSelectAllState();
    this.updateRowStates();
    this.sortStudents();
  }

  clearSelection() {
    this.checkboxTargets.forEach((checkbox) => (checkbox.checked = false));
    this.selectAllTarget.checked = false;
    this.updateCounter();
    this.updateRowStates();
    this.sortStudents();
  }

  updateCounter() {
    const selectedCount = this.checkboxTargets.filter((c) => c.checked).length;
    this.counterTarget.textContent = `${selectedCount} ${
      selectedCount === 1 ? "student" : "students"
    } selected`;
    this.clearButtonTarget.classList.toggle("hidden", selectedCount === 0);
  }

  updateSelectAllState() {
    const visibleCheckboxes = this.checkboxTargets.filter(
      (checkbox) =>
        !checkbox
          .closest("[data-student-selection-target='student']")
          .classList.contains("hidden")
    );
    const allChecked = visibleCheckboxes.every((c) => c.checked);
    const someChecked = visibleCheckboxes.some((c) => c.checked);

    this.selectAllTarget.checked = allChecked;
    this.selectAllTarget.indeterminate = someChecked && !allChecked;
  }

  updateRowStates() {
    this.checkboxTargets.forEach((checkbox) => {
      const row = checkbox.closest(".flex");
      if (row) {
        row.dataset.checked = checkbox.checked;
      }
    });
  }

  toggleList() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.toggle("hidden");
      if (!this.dropdownTarget.classList.contains("hidden")) {
        this.sortStudents();
      }
    }
  }

  showList() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.remove("hidden");
      this.sortStudents();
    }
  }

  hideList() {
    if (this.hasDropdownTarget) {
      this.dropdownTarget.classList.add("hidden");
    }
  }

  handleClickOutside(event) {
    // Only hide if the click is outside and we're not clicking inside the component
    if (!this.element.contains(event.target)) {
      this.hideList();
    }
  }

  sortStudents() {
    const studentList = this.listTarget;
    const students = Array.from(this.studentTargets);

    // Sort students: selected first, then alphabetically
    students.sort((a, b) => {
      const aChecked = a.querySelector('input[type="checkbox"]').checked;
      const bChecked = b.querySelector('input[type="checkbox"]').checked;

      if (aChecked && !bChecked) return -1;
      if (!aChecked && bChecked) return 1;

      const aName = a.querySelector(".text-gray-900").textContent.trim();
      const bName = b.querySelector(".text-gray-900").textContent.trim();
      return aName.localeCompare(bName);
    });

    // Reorder the DOM elements
    students.forEach((student) => studentList.appendChild(student));
  }
}
