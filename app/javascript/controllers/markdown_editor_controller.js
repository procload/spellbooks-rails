import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["passage", "editor", "editButton", "saveButton"]
  static values = {
    updateUrl: String
  }
  
  connect() {
    this.editor = null
  }

  toggleEdit() {
    if (!this.editor) {
      this.initializeEditor()
    }
    this.editorTarget.classList.toggle("hidden")
    this.passageTarget.classList.toggle("hidden")
    this.editButtonTarget.classList.toggle("hidden")
    this.saveButtonTarget.classList.toggle("hidden")
    
    // If we're hiding the editor, also hide SimpleMDE's wrapper
    if (this.editor && this.editorTarget.classList.contains("hidden")) {
      this.editor.toTextArea()
      this.editor = null
    }
  }

  initializeEditor() {
    this.editor = new SimpleMDE({
      element: this.editorTarget,
      spellChecker: false,
      status: false,
      toolbar: [
        "bold", "italic", "heading", "|",
        "quote", "unordered-list", "ordered-list", "|",
        "link", "table", "|",
        "preview", "guide"
      ]
    })
    this.editor.value(this.passageTarget.getAttribute("data-original-content"))
  }

  async save() {
    const csrfToken = document.querySelector("[name='csrf-token']").content
    
    try {
      const response = await fetch(this.updateUrlValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          assignment: {
            markdown_passage: this.editor.value()
          }
        })
      })
      
      if (response.ok) {
        const data = await response.json()
        this.passageTarget.innerHTML = data.rendered_passage
        this.toggleEdit()
        this.dispatch("success", { detail: { message: "Passage updated successfully" } })
      } else {
        this.dispatch("error", { detail: { message: "Failed to update passage" } })
      }
    } catch (error) {
      this.dispatch("error", { detail: { message: "An error occurred while saving" } })
    }
  }
}
