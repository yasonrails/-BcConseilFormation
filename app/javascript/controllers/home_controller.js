import { Controller } from "@hotwired/stimulus"

// Connects to: data-controller="home"
// Manages cursor, scroll reveal, login modal and mobile nav.
export default class extends Controller {
  static targets = ["siteLayer", "loginLayer", "nav"]

  connect() {
    this.#initCursor()
    this.#initScrollReveal()
    this.#initNavClose()
  }

  // ── Mobile nav ─────────────────────────────────────────────────
  toggleNav(event) {
    const nav = event.currentTarget.closest("nav")
    const isOpen = nav.classList.toggle("nav-open")
    event.currentTarget.setAttribute("aria-expanded", isOpen)
    document.body.style.overflow = isOpen ? "hidden" : ""
  }

  // ── Login modal ────────────────────────────────────────────────
  openLogin() {
    // Close mobile nav first if open
    const nav = this.element.querySelector("nav")
    if (nav) { nav.classList.remove("nav-open"); document.body.style.overflow = "" }

    this.loginLayerTarget.style.display = "block"
    document.body.style.overflow = "hidden"
  }

  closeLogin() {
    this.loginLayerTarget.style.display = "none"
    document.body.style.overflow = ""
  }

  closeLoginOnOverlay(event) {
    if (event.target === event.currentTarget) this.closeLogin()
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  // ── Private helpers ─────────────────────────────────────────────
  #initNavClose() {
    // Close mobile nav when a link inside it is clicked
    const nav = this.element.querySelector("nav")
    if (!nav) return
    nav.querySelectorAll(".nav-links a").forEach((link) => {
      link.addEventListener("click", () => {
        nav.classList.remove("nav-open")
        document.body.style.overflow = ""
      })
    })
    // Close on outside click
    document.addEventListener("click", (e) => {
      if (nav.classList.contains("nav-open") && !nav.contains(e.target)) {
        nav.classList.remove("nav-open")
        document.body.style.overflow = ""
      }
    })
  }

  #initCursor() {
    const cur  = document.getElementById("cur")
    const ring = document.getElementById("ring")
    if (!cur || !ring) return

    let mx = 0, my = 0, rx = 0, ry = 0

    document.addEventListener("mousemove", (e) => {
      mx = e.clientX
      my = e.clientY
      cur.style.left = mx + "px"
      cur.style.top  = my + "px"
    }, { passive: true })

    const animate = () => {
      rx += (mx - rx) * 0.11
      ry += (my - ry) * 0.11
      ring.style.left = rx + "px"
      ring.style.top  = ry + "px"
      requestAnimationFrame(animate)
    }
    animate()
  }

  #initScrollReveal() {
    const elements = document.querySelectorAll(".reveal")
    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("visible")
          observer.unobserve(entry.target)
        }
      })
    }, { threshold: 0.12 })

    elements.forEach((el) => observer.observe(el))
  }
}

