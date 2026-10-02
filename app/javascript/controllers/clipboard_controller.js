import { Controller } from "@hotwired/stimulus"

// テキストをクリップボードにコピーし、ボタン表記で完了を知らせる
export default class extends Controller {
  static targets = ["source", "button"]

  async copy() {
    await navigator.clipboard.writeText(this.sourceTarget.value)
    const label = this.buttonTarget.textContent
    this.buttonTarget.textContent = "コピーしました"
    setTimeout(() => { this.buttonTarget.textContent = label }, 1500)
  }
}
