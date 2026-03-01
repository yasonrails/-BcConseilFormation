import { Controller } from "@hotwired/stimulus"

// Lecteur de quiz interactif — géré côté client uniquement
export default class extends Controller {
  static targets = ["question", "feedback", "feedbackText", "score", "scoreVal"]

  connect() {
    this.current  = 0
    this.correct  = 0
    this.total    = this.questionTargets.length
  }

  answer(event) {
    const btn      = event.currentTarget
    const qEl      = this.questionTargets[this.current]
    const correct  = parseInt(qEl.dataset.correct)
    const chosen   = parseInt(btn.dataset.index)
    const isRight  = chosen === correct

    if (isRight) this.correct++

    // Colorer les boutons
    qEl.querySelectorAll(".quiz-opt").forEach((b, i) => {
      b.disabled = true
      if (i === correct) b.classList.add("correct")
      else if (i === chosen && !isRight) b.classList.add("wrong")
    })

    // Afficher le feedback
    const fb = qEl.querySelector("[data-quiz-player-target='feedback']") ||
               qEl.querySelector(".quiz-feedback")
    const fbText = qEl.querySelector("[data-quiz-player-target='feedbackText']") ||
                   qEl.querySelector(".quiz-feedback-text")
    if (fbText) fbText.textContent = isRight ? "✅ Bonne réponse !" : "❌ Mauvaise réponse"
    if (fb) fb.style.display = "block"
  }

  next() {
    if (this.current < this.total - 1) {
      this.questionTargets[this.current].style.display = "none"
      this.current++
      this.questionTargets[this.current].style.display = "block"
    }
  }

  finish() {
    this.questionTargets.forEach(q => q.style.display = "none")
    this.scoreValTarget.textContent = `${this.correct} / ${this.total}`
    this.scoreTarget.style.display = "block"
  }

  restart() {
    this.correct = 0
    this.current = 0
    this.scoreTarget.style.display = "none"

    this.questionTargets.forEach((q, i) => {
      q.style.display = i === 0 ? "block" : "none"
      q.querySelectorAll(".quiz-opt").forEach(b => {
        b.disabled = false
        b.classList.remove("correct", "wrong")
      })
      const fb = q.querySelector(".quiz-feedback")
      if (fb) fb.style.display = "none"
    })
  }
}
