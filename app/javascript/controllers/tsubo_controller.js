import { Controller } from "@hotwired/stimulus"

// ㎡ ⇔ 坪 の相互換算（土地登録フォーム）。保存時はモデル側でも再計算する。
const TSUBO_PER_SQM = 0.3025

export default class extends Controller {
  static targets = ["sqm", "tsubo"]

  fromSqm() {
    const sqm = parseFloat(this.sqmTarget.value)
    this.tsuboTarget.value = Number.isFinite(sqm) ? (sqm * TSUBO_PER_SQM).toFixed(2) : ""
  }

  fromTsubo() {
    const tsubo = parseFloat(this.tsuboTarget.value)
    this.sqmTarget.value = Number.isFinite(tsubo) ? (tsubo / TSUBO_PER_SQM).toFixed(2) : ""
  }
}
