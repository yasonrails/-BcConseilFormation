module ApplicationHelper
  # ──────────────────────────────────────────────────────────────────
  # French-aware pluralization (avoids ActionView::Helpers::TextHelper#pluralize
  # which uses English rules by default).
  #   pluralize_fr(1, "module")   → "1 module"
  #   pluralize_fr(3, "module")   → "3 modules"
  # ──────────────────────────────────────────────────────────────────
  def pluralize_fr(count, word, plural: nil)
    plural ||= "#{word}s"
    "#{count} #{count == 1 ? word : plural}"
  end

  # ──────────────────────────────────────────────────────────────────
  # Renders a status badge <span> for any model with `statut` + a truth predicate.
  #
  # obj       — an ActiveRecord instance (CoursSupport, ModuleFormation…)
  # true_val  — statut value considered "positive" (default: first truthy check)
  # true_lbl  — label when positive (default: "✓ Prêt")
  # false_lbl — label when negative (default: "Brouillon")
  #
  # Examples:
  #   statut_tag(@support)                          → ✓ Prêt  |  Brouillon
  #   statut_tag(@module, true_lbl: "✓ Publié")     → ✓ Publié | Brouillon
  # ──────────────────────────────────────────────────────────────────
  def statut_tag(obj, true_lbl: "✓\u00a0Prêt", false_lbl: "Brouillon")
    positive = obj.respond_to?(:pret?) ? obj.pret? : (obj.respond_to?(:publie?) ? obj.publie? : false)
    css = positive ? "tg" : "tgr"
    lbl = positive ? true_lbl : false_lbl
    content_tag(:span, lbl, class: "tag #{css}")
  end

  # ─────────────────────────────────────────────────────────────────────────────
  # Platform page topbar wrapper.
  # Renders <div class="topbar"> with a title h1 and optional right-side block.
  #
  # title     — plain or html_safe title string
  # subtitle  — wrapped in <em>, appended after title (optional)
  # block     — ERB block yielded into the right side of the topbar (optional)
  #
  # Examples:
  #   <%= topbar_tag "Supports", subtitle: "de cours" do %>
  #     <%= link_to "Nouveau", new_path, class: "btn bp" %>
  #   <% end %>
  # ─────────────────────────────────────────────────────────────────────────────
  def topbar_tag(title, subtitle: nil, &block)
    full_title = if subtitle.present?
                   safe_join([title.to_s, content_tag(:em, subtitle)], " ")
                 else
                   title.to_s
                 end
    right = block ? capture(&block) : "".html_safe

    content_tag(:div, class: "topbar") do
      safe_join([
        content_tag(:h1, full_title.html_safe, class: "topbar-title"),
        content_tag(:div, right, class: "row")
      ])
    end
  end
end
