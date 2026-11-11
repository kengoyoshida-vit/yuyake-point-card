import { Controller } from "@hotwired/stimulus"

// Shows the company-name field only for sponsor / government categories.
export default class extends Controller {
  static targets = ["category", "company"]

  toggle() {
    const selected = this.categoryTargets.find((radio) => radio.checked)?.value
    this.companyTarget.hidden = !["zero_yen_sponsor", "government"].includes(selected)
  }
}
