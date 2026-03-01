import { Controller } from "@hotwired/stimulus"

// Génère des modules IA pour un support de cours (async via SolidQueue).
// 1. POST → 202 (job enqueued)
// 2. Poll GET ia_statut toutes les 2s jusqu'à statut ok/erreur
export default class extends Controller {
  static targets = ["status", "nbModules", "results"]
  static values  = { modulesUrl: String, statutUrl: String, supportId: Number }

  #pollTimer = null

  disconnect() {
    clearInterval(this.#pollTimer)
  }

  async generer() {
    const nb = this.hasNbModulesTarget ? parseInt(this.nbModulesTarget.value) || 3 : 3
    this.#setStatus("⏳ Envoi de la demande…", "loading")
    if (this.hasResultsTarget) this.resultsTarget.innerHTML = ""

    try {
      const res = await fetch(this.modulesUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ nb_modules: nb })
      })
      if (!res.ok && res.status !== 202) {
        const data = await res.json()
        throw new Error(data.error || "Erreur lors de l'envoi")
      }
      this.#setStatus("⏳ Génération en cours (IA)…", "loading")
      this.#startPolling()
    } catch (err) {
      this.#setStatus(`❌ ${err.message}`, "error")
    }
  }

  #startPolling() {
    const messages = ["Analyse du support…", "Structuration pédagogique…", "Rédaction des objectifs…", "Finalisation…"]
    let tick = 0
    this.#pollTimer = setInterval(async () => {
      tick++
      if (tick % 3 === 0) {
        this.#setStatus(`⏳ ${messages[Math.min(Math.floor(tick / 3), messages.length - 1)]}`, "loading")
      }
      try {
        const res  = await fetch(this.statutUrlValue)
        const data = await res.json()
        const s    = data?.modules?.statut
        if (s === "ok") {
          clearInterval(this.#pollTimer)
          this.#setStatus("✅ Modules générés — rechargement…", "ok")
          setTimeout(() => window.location.reload(), 1200)
        } else if (s === "erreur") {
          clearInterval(this.#pollTimer)
          this.#setStatus(`❌ ${data.modules.erreur || "Erreur IA"}`, "error")
        }
      } catch { /* réseau temporairement indispo */ }
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
