import { Controller } from "@hotwired/stimulus"

// Quiz interactif — engageant, respecte la concentration humaine
// Fonctionnalités : streak, confiance, micro-pause toutes les 5 questions,
// révision des erreurs, navigation clavier, progression animée
export default class extends Controller {
  static targets = [
    "question", "feedback", "feedbackIcon",
    "progressBar", "counter", "scoreLive",
    "streak", "streakCount",
    "pause", "body",
    "result", "scoreDisplay", "resultLabel", "resultStats",
    "review", "reviewList"
  ]
  static values = {
    total:          Number,
    progressionUrl: String
  }

  connect() {
    this.current    = 0
    this.correct    = 0
    this.streak     = 0
    this.maxStreak  = 0
    this.answered   = false
    this.results    = []   // { index, correct, chosen, enonce, bonne_option }

    // Navigation clavier
    this._onKey = this.#handleKey.bind(this)
    document.addEventListener("keydown", this._onKey)

    this.#updateProgress()
  }

  disconnect() {
    document.removeEventListener("keydown", this._onKey)
  }

  // ── Répondre ───────────────────────────────────────────────────────────────
  repondre(event) {
    if (this.answered) return
    this.answered = true

    const btn     = event.currentTarget
    const qEl     = this.questionTargets[this.current]
    const correct = parseInt(qEl.dataset.correct)
    const chosen  = parseInt(btn.dataset.index)
    const isRight = chosen === correct

    // Enregistrer
    const enonce    = qEl.querySelector(".qi-enonce")?.textContent || ""
    const opts      = qEl.querySelectorAll(".qi-opt")
    const bonneOpt  = opts[correct]?.querySelector(".qi-opt-label")?.textContent || ""
    this.results.push({ index: this.current, correct: isRight, chosen, correctIdx: correct, enonce, bonne_option: bonneOpt })

    if (isRight) {
      this.correct++
      this.streak++
      if (this.streak > this.maxStreak) this.maxStreak = this.streak
    } else {
      this.streak = 0
    }

    // Colorier les boutons
    opts.forEach((b, i) => {
      b.disabled = true
      b.classList.remove("qi-opt--correct", "qi-opt--wrong")
      const icon = b.querySelector(".qi-opt-icon")
      if (i === correct) {
        b.classList.add("qi-opt--correct")
        if (icon) { icon.textContent = "✓"; icon.style.display = "inline" }
      } else if (i === chosen && !isRight) {
        b.classList.add("qi-opt--wrong")
        if (icon) { icon.textContent = "✗"; icon.style.display = "inline" }
      }
    })

    // Feedback
    const feedback = qEl.querySelector("[data-quiz-interactif-target='feedback']")
    if (feedback) {
      const icon = qEl.querySelector("[data-quiz-interactif-target='feedbackIcon']")
      if (icon) {
        icon.textContent  = isRight ? "🎉 Bonne réponse !" : "❌ Mauvaise réponse"
        icon.className    = `qi-feedback-icon ${isRight ? "qi-fb--correct" : "qi-fb--wrong"}`
      }
      feedback.style.display = "block"
      feedback.classList.add("qi-feedback--show")
    }

    // Streak
    this.#updateStreak()
    this.#updateScoreLive()
  }

  // ── Confiance (après réponse) ──────────────────────────────────────────────
  confiance(event) {
    const niveau = event.currentTarget.dataset.niveau
    const last   = this.results[this.results.length - 1]
    if (last) last.confiance = niveau
    // Désactiver les 3 boutons
    event.currentTarget.closest(".qi-confiance-btns")
      ?.querySelectorAll(".qi-conf-btn")
      .forEach(b => { b.disabled = true; b.classList.toggle("qi-conf-btn--active", b === event.currentTarget) })
  }

  // ── Question suivante ──────────────────────────────────────────────────────
  suivant() {
    if (!this.answered) return
    const next = this.current + 1
    if (next >= this.totalValue) return

    // Micro-pause toutes les 5 questions
    if (next % 5 === 0 && next < this.totalValue) {
      this.#showPause(next)
      return
    }
    this.#goTo(next)
  }

  reprendre() {
    this.pauseTarget.style.display = "none"
    this.bodyTarget.style.display  = "block"
    this.#goTo(this._pausedNext)
  }

  terminer() {
    this.#showResult()
  }

  relancer() {
    this.current   = 0
    this.correct   = 0
    this.streak    = 0
    this.maxStreak = 0
    this.answered  = false
    this.results   = []

    this.resultTarget.style.display = "none"
    this.bodyTarget.style.display   = "block"

    this.questionTargets.forEach((q, i) => {
      q.style.display = i === 0 ? "block" : "none"
      q.querySelectorAll(".qi-opt").forEach(b => {
        b.disabled = false
        b.classList.remove("qi-opt--correct", "qi-opt--wrong")
        const icon = b.querySelector(".qi-opt-icon")
        if (icon) icon.style.display = "none"
      })
      const fb = q.querySelector("[data-quiz-interactif-target='feedback']")
      if (fb) { fb.style.display = "none"; fb.classList.remove("qi-feedback--show") }
      const confs = q.querySelectorAll(".qi-conf-btn")
      confs.forEach(b => { b.disabled = false; b.classList.remove("qi-conf-btn--active") })
    })

    this.streakTarget.style.display = "none"
    this.#updateProgress()
    this.#updateScoreLive()
  }

  // ── Privé ──────────────────────────────────────────────────────────────────

  #goTo(index) {
    this.questionTargets[this.current].style.display = "none"
    this.current  = index
    this.answered = false
    this.questionTargets[this.current].style.display = "block"
    // Animation d'entrée
    this.questionTargets[this.current].classList.remove("qi-enter")
    requestAnimationFrame(() => this.questionTargets[this.current].classList.add("qi-enter"))
    this.#updateProgress()
  }

  #showPause(next) {
    this._pausedNext = next
    this.bodyTarget.style.display  = "none"
    this.pauseTarget.style.display = "flex"
  }

  #updateProgress() {
    const pct = ((this.current) / this.totalValue) * 100
    if (this.hasProgressBarTarget) this.progressBarTarget.style.width = `${pct}%`
    if (this.hasCounterTarget)     this.counterTarget.textContent = `${this.current + 1} / ${this.totalValue}`
  }

  #updateScoreLive() {
    if (this.hasScoreLiveTarget)
      this.scoreLiveTarget.textContent = `${this.correct} ✓`
  }

  #updateStreak() {
    if (!this.hasStreakTarget) return
    if (this.streak >= 2) {
      this.streakTarget.style.display = "flex"
      this.streakCountTarget.textContent = this.streak
    } else {
      this.streakTarget.style.display = "none"
    }
  }

  async #showResult() {
    const score = Math.round((this.correct / this.totalValue) * 100)
    const pass  = score >= 70

    // Envoyer la progression
    try {
      const meta = document.querySelector("meta[name='csrf-token']")
      await fetch(this.progressionUrlValue, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": meta?.content },
        body: JSON.stringify({ score })
      })
    } catch { /* silencieux */ }

    this.bodyTarget.style.display   = "none"
    this.resultTarget.style.display = "block"

    // Score
    this.scoreDisplayTarget.textContent = `${score}%`
    this.scoreDisplayTarget.className   = `qi-result-score ${pass ? "qi-score--pass" : "qi-score--fail"}`

    // Label
    const labels = pass
      ? ["🏆 Excellent !", "🎉 Félicitations !", "⭐ Très bien !"]
      : ["📚 Continuez à apprendre", "💪 Presque ! Encore un effort"]
    this.resultLabelTarget.textContent = labels[Math.floor(Math.random() * labels.length)]

    // Stats
    this.resultStatsTarget.innerHTML = `
      <div class="qi-stat"><span>${this.correct} / ${this.totalValue}</span><small>bonnes réponses</small></div>
      <div class="qi-stat"><span>${this.maxStreak}</span><small>meilleure série</small></div>
      <div class="qi-stat"><span>${score >= 70 ? "✓" : "✗"}</span><small>70% requis</small></div>
    `

    // Révision des erreurs
    const erreurs = this.results.filter(r => !r.correct)
    if (erreurs.length > 0) {
      this.reviewTarget.style.display = "block"
      this.reviewListTarget.innerHTML = erreurs.map(e => `
        <div class="qi-review-item">
          <p class="qi-review-enonce">${e.enonce}</p>
          <p class="qi-review-reponse">✓ <strong>${e.bonne_option}</strong></p>
        </div>
      `).join("")
    }
  }

  #handleKey(evt) {
    if (evt.key === "ArrowRight" || evt.key === "Enter") {
      if (this.answered) {
        const next = this.current + 1
        if (next >= this.totalValue) this.terminer()
        else this.suivant()
      }
    }
    if (evt.key === "1" || evt.key === "a") this.#selectByIndex(0)
    if (evt.key === "2" || evt.key === "b") this.#selectByIndex(1)
    if (evt.key === "3" || evt.key === "c") this.#selectByIndex(2)
    if (evt.key === "4" || evt.key === "d") this.#selectByIndex(3)
  }

  #selectByIndex(idx) {
    if (this.answered) return
    const qEl = this.questionTargets[this.current]
    const btn = qEl?.querySelectorAll(".qi-opt")[idx]
    if (btn) btn.click()
  }
}
