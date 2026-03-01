import { Controller } from "@hotwired/stimulus"

// Gère la génération de modules IA depuis un support de cours
export default class extends Controller {
  static targets = [
    "panel", "genBtn", "genBtnLabel",
    "nbSelector", "loading", "loadingText",
    "results", "resultsTitle", "modulesList",
    "error", "errorMsg"
  ]
  static values = {
    modulesUrl:  String,
    supportId:   Number
  }

  connect() {
    this.selectedNb = 3
  }

  selectNb(event) {
    const nb = parseInt(event.currentTarget.dataset.nb)
    this.selectedNb = nb
    this.nbSelectorTarget.querySelectorAll(".gen-nb-btn").forEach(btn => {
      btn.classList.toggle("active", parseInt(btn.dataset.nb) === nb)
    })
  }

  async genererModules() {
    this.#showLoading("Analyse du support en cours…")
    this.#hideResults()
    this.#hideError()
    this.genBtnTarget.disabled = true

    const messages = [
      "Analyse du support en cours…",
      "Structuration des modules pédagogiques…",
      "Définition des objectifs d'apprentissage…",
      "Génération du contenu détaillé…",
      "Finalisation des modules…"
    ]
    let msgIdx = 0
    const ticker = setInterval(() => {
      msgIdx = Math.min(msgIdx + 1, messages.length - 1)
      if (this.hasLoadingTextTarget) this.loadingTextTarget.textContent = messages[msgIdx]
    }, 4000)

    try {
      const res = await fetch(this.modulesUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ nb_modules: this.selectedNb })
      })
      const data = await res.json()

      if (!res.ok || data.error) throw new Error(data.error || "Erreur inconnue")

      clearInterval(ticker)
      this.#hideLoading()
      this.#renderResults(data.modules)
    } catch (err) {
      clearInterval(ticker)
      this.#hideLoading()
      this.#showError(err.message)
    } finally {
      this.genBtnTarget.disabled = false
      this.genBtnLabelTarget.textContent = "Régénérer les modules"
    }
  }

  // ── Privé ─────────────────────────────────────

  #showLoading(msg) {
    this.loadingTarget.style.display = "block"
    this.loadingTextTarget.textContent = msg
  }

  #hideLoading() { this.loadingTarget.style.display = "none" }

  #hideResults() { this.resultsTarget.style.display = "none" }

  #hideError() { this.errorTarget.style.display = "none" }

  #showError(msg) {
    this.errorTarget.style.display = "block"
    this.errorMsgTarget.textContent = `❌ ${msg}`
  }

  #renderResults(modules) {
    this.resultsTitleTarget.textContent = `✅ ${modules.length} module${modules.length > 1 ? "s" : ""} générés avec succès`
    this.modulesListTarget.innerHTML = modules.map((m, i) => `
      <div class="gen-module-preview">
        <div class="gmp-num">Module ${String(i + 1).padStart(2, "0")}</div>
        <h4 class="gmp-title">${this.#esc(m.titre)}</h4>
        <p class="gmp-dur">⏱ ${this.#esc(m.duree_estimee || "—")}</p>
        <ul class="gmp-objectifs">
          ${(m.objectifs || []).map(o => `<li>${this.#esc(o)}</li>`).join("")}
        </ul>
        <a href="${m.url}" class="btn ba bs" style="margin-top:8px">Voir le module →</a>
      </div>
    `).join("")
    this.resultsTarget.style.display = "block"

    // Scroll vers les résultats
    this.resultsTarget.scrollIntoView({ behavior: "smooth", block: "start" })

    // Reload après 3s pour afficher les modules dans la liste
    setTimeout(() => window.location.reload(), 2500)
  }

  #esc(str) {
    return String(str).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
  }
}
