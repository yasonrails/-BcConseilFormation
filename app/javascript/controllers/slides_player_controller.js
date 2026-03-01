import { Controller } from "@hotwired/stimulus"

// Lecteur slides — navigation clavier + notes formateur + plein écran
export default class extends Controller {
  static targets = ["slide", "counter", "prevBtn", "nextBtn", "notes", "progress"]
  static values  = { total: Number }

  connect() {
    this.current    = 0
    this.notesShown = false
    this._onKey = this.#handleKey.bind(this)
    document.addEventListener("keydown", this._onKey)
    this.#update()
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKey)
  }

  next() {
    if (this.current < this.totalValue - 1) {
      this.#go(this.current + 1)
    }
  }

  prev() {
    if (this.current > 0) {
      this.#go(this.current - 1)
    }
  }

  toggleNotes() {
    this.notesShown = !this.notesShown
    this.notesTargets.forEach(n => {
      n.style.display = this.notesShown ? "block" : "none"
    })
  }

  // ── Privé ──────────────────────────────────────────────────────────────────

  #go(index) {
    this.slideTargets[this.current].style.display = "none"
    this.current = index
    this.slideTargets[this.current].style.display = "block"
    this.slideTargets[this.current].classList.add("sp-slide--enter")
    setTimeout(() => this.slideTargets[this.current]?.classList.remove("sp-slide--enter"), 400)
    this.#update()
  }

  #update() {
    if (this.hasCounterTarget)
      this.counterTarget.textContent = `${this.current + 1} / ${this.totalValue}`

    if (this.hasPrevBtnTarget)
      this.prevBtnTarget.disabled = this.current === 0

    if (this.hasNextBtnTarget)
      this.nextBtnTarget.disabled = this.current === this.totalValue - 1

    if (this.hasProgressTarget) {
      const pct = ((this.current + 1) / this.totalValue * 100).toFixed(1)
      this.progressTarget.style.width = `${pct}%`
    }
  }

  #handleKey(evt) {
    if (evt.key === "ArrowRight" || evt.key === "ArrowDown" || evt.key === " ") {
      evt.preventDefault(); this.next()
    }
    if (evt.key === "ArrowLeft" || evt.key === "ArrowUp") {
      evt.preventDefault(); this.prev()
    }
    if (evt.key === "n" || evt.key === "N") this.toggleNotes()
    if (evt.key === "f" || evt.key === "F")
      document.fullscreenElement
        ? document.exitFullscreen()
        : document.documentElement.requestFullscreen()
  }
}
