import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["questions", "result", "scoreDisplay", "message", "nextBtn", "explication"]
  static values  = { progressionUrl: String }

  connect() {
    this.current  = 0
    this.correct  = 0
    this.answers  = []
    this.allQ     = this.questionsTarget.querySelectorAll(".quiz-q")
    this.total    = this.allQ.length
  }

  // Clic sur une option de réponse
  select(event) {
    const btn     = event.currentTarget
    const qEl     = this.allQ[this.current]
    const correct = parseInt(qEl.dataset.correct)
    const chosen  = parseInt(btn.dataset.value)
    const isRight = chosen === correct

    if (isRight) this.correct++
    this.answers.push({ chosen, correct, isRight })

    // Colorier les options
    qEl.querySelectorAll(".quiz-opt").forEach((b, i) => {
      b.disabled = true
      b.classList.remove("quiz-opt--correct", "quiz-opt--wrong")
      if (i === correct)             b.classList.add("quiz-opt--correct")
      else if (i === chosen && !isRight) b.classList.add("quiz-opt--wrong")
    })

    // Afficher l'explication si disponible
    const explic = qEl.querySelector("[data-quiz-player-target='explication']")
    if (explic) explic.style.display = "block"

    // Afficher le bouton suivant/terminer
    const nextWrap = qEl.querySelector("[data-quiz-player-target='nextBtn']")
    if (nextWrap) nextWrap.style.display = "flex"
  }

  next() {
    this.allQ[this.current].style.display = "none"
    this.current++
    if (this.current < this.total) {
      this.allQ[this.current].style.display = "block"
    }
  }

  async finish() {
    const score = Math.round((this.correct / this.total) * 100)
    const pass  = score >= 70

    // Soumettre la progression au serveur
    try {
      const meta = document.querySelector("meta[name='csrf-token']")
      await fetch(this.progressionUrlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": meta?.content },
        body: JSON.stringify({ score })
      })
    } catch { /* silencieux */ }

    // Afficher le résultat
    this.questionsTarget.style.display = "none"
    this.resultTarget.style.display    = "block"
    this.scoreDisplayTarget.textContent = `${score}%`
    this.scoreDisplayTarget.className   = `qr-score ${pass ? "qr-score--pass" : "qr-score--fail"}`
    this.messageTarget.textContent = pass
      ? `🎉 Félicitations ! Vous avez validé ce module (${this.correct}/${this.total} bonnes réponses).`
      : `⏱ Continuez à vous entraîner. ${this.correct}/${this.total} bonnes réponses — 70% minimum requis.`
  }

  restart() {
    this.correct  = 0
    this.current  = 0
    this.answers  = []

    this.resultTarget.style.display    = "none"
    this.questionsTarget.style.display = "block"

    this.allQ.forEach((q, i) => {
      q.style.display = i === 0 ? "block" : "none"
      q.querySelectorAll(".quiz-opt").forEach(b => {
        b.disabled = false
        b.classList.remove("quiz-opt--correct", "quiz-opt--wrong")
      })
      const explic  = q.querySelector("[data-quiz-player-target='explication']")
      const nextBtn = q.querySelector("[data-quiz-player-target='nextBtn']")
      if (explic)  explic.style.display  = "none"
      if (nextBtn) nextBtn.style.display = "none"
    })
  }
}


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
