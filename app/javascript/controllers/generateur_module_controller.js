import { Controller } from "@hotwired/stimulus"

// Gère la génération de quiz IA pour un module individuel
export default class extends Controller {
  static targets = ["quizBtn", "loading", "quizResult", "quizMsg"]
  static values  = { quizUrl: String }

  async genererQuiz() {
    if (!confirm(`Générer un quiz IA pour ce module ? (Les questions existantes seront conservées.)`)) return

    this.quizBtnTarget.disabled = true
    this.loadingTarget.style.display = "block"
    this.quizResultTarget.style.display = "none"

    try {
      const res = await fetch(this.quizUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ nb_questions: 5 })
      })
      const data = await res.json()
      if (!res.ok || data.error) throw new Error(data.error || "Erreur inconnue")

      this.loadingTarget.style.display = "none"
      this.quizMsgTarget.textContent = `✅ ${data.questions.length} question${data.questions.length > 1 ? "s" : ""} générées`
      this.quizResultTarget.style.display = "block"

      setTimeout(() => window.location.reload(), 2000)
    } catch (err) {
      this.loadingTarget.style.display = "none"
      this.quizMsgTarget.textContent = `❌ ${err.message}`
      this.quizResultTarget.style.display = "block"
      this.quizBtnTarget.disabled = false
    }
  }
}
