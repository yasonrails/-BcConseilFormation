import { Controller } from "@hotwired/stimulus"

// Génère un quiz IA pour un module individuel (async via SolidQueue).
// 1. POST → 202 (job enqueued)
// 2. Poll GET ia_statut toutes les 2s jusqu'à statut ok/erreur pour ce module
export default class extends Controller {
  static targets = ["status"]
  static values  = { url: String, statutUrl: String, moduleId: Number }

  #pollTimer = null

  disconnect() {
    clearInterval(this.#pollTimer)
  }

  async generer() {
    if (!confirm("Générer un quiz IA ? Les questions existantes seront remplacées.")) return
    this.#setStatus("⏳ Envoi de la demande…", "loading")

    try {
      const res = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ nb_questions: 7 })
      })
      if (!res.ok && res.status !== 202) {
        const data = await res.json()
        throw new Error(data.error || "Erreur lors de l'envoi")
      }
      this.#setStatus("⏳ Génération du quiz (IA)…", "loading")
      this.#startPolling()
    } catch (err) {
      this.#setStatus(`❌ ${err.message}`, "error")
    }
  }

  #startPolling() {
    const moduleId = String(this.moduleIdValue)
    this.#pollTimer = setInterval(async () => {
      try {
        const res  = await fetch(this.statutUrlValue)
        const data = await res.json()
        const s    = data?.quiz?.[moduleId]?.statut
        if (s === "ok") {
          clearInterval(this.#pollTimer)
          const count = data.quiz[moduleId].count || ""
          this.#setStatus(`✅ ${count} question(s) générées — rechargement…`, "ok")
          setTimeout(() => window.location.reload(), 1200)
        } else if (s === "erreur") {
          clearInterval(this.#pollTimer)
          this.#setStatus(`❌ ${data.quiz[moduleId].erreur || "Erreur IA"}`, "error")
        }
      } catch { /* réseau */ }
    }, 2000)
  }

  #setStatus(msg, type) {
    if (!this.hasStatusTarget) return
    const el = this.statusTarget
    el.textContent = msg
    el.style.display = "block"
    el.style.color = type === "ok" ? "#059669" : type === "error" ? "#dc2626" : "var(--ink-60)"
  }
}
