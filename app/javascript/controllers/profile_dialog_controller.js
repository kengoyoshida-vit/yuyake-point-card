import { Controller } from "@hotwired/stimulus"

// Opens the first-login profile dialog as a modal. Both submit and skip
// navigate away (Turbo), so no explicit close handling is needed.
export default class extends Controller {
  connect() {
    if (!this.element.open) this.element.showModal()
  }
}
