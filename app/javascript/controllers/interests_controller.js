import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "tags", "field"]
  static values = {
    suggestions: Array
  }

  connect() {
    this.updateTags()
  }

  add(event) {
    if (event.type === "keydown" && event.key !== "Enter") {
      return
    }
    
    event.preventDefault()
    const interest = this.inputTarget.value.trim()
    if (interest) {
      this.addInterest(interest)
      this.inputTarget.value = ""
    }
  }

  addSuggested(event) {
    event.preventDefault()
    const interest = event.currentTarget.textContent.trim()
    this.addInterest(interest)
  }

  remove(event) {
    event.preventDefault()
    const interest = event.currentTarget.dataset.interest
    const currentInterests = this.currentInterests
    const index = currentInterests.indexOf(interest)
    
    if (index > -1) {
      currentInterests.splice(index, 1)
      this.fieldTarget.value = currentInterests.join(", ")
      this.updateTags()
    }
  }

  addInterest(interest) {
    const currentInterests = this.currentInterests
    if (!currentInterests.includes(interest)) {
      currentInterests.push(interest)
      this.fieldTarget.value = currentInterests.join(", ")
      this.updateTags()
    }
  }

  updateTags() {
    const interests = this.currentInterests
    this.tagsTarget.innerHTML = interests.map(interest => `
      <span class="bg-spellbooks-sidebar text-foreground px-3 py-1 rounded-full text-sm flex items-center">
        ${interest}
        <button type="button" 
                data-interests-target="removeButton"
                data-action="click->interests#remove"
                data-interest="${interest}"
                class="ml-2 text-foreground hover:text-spellbooks-element-hover">×</button>
      </span>
    `).join("")
  }

  get currentInterests() {
    return this.fieldTarget.value.split(",").map(i => i.trim()).filter(i => i)
  }
}
