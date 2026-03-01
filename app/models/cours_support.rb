class CoursSupport < ApplicationRecord
  include Statutable
  include ListAttribute

  belongs_to :user
  has_many :module_formations, dependent: :destroy
  has_many :inscriptions,      dependent: :destroy
  has_many :eleves,            through: :inscriptions, source: :user
  has_one_attached :fichier   # PDF, DOCX, TXT

  validates :titre, presence: true

  STATUTS    = %w[brouillon pret publie].freeze
  MODALITES  = %w[presentiel distanciel hybride].freeze
  CATEGORIES = %w[RH Droit Organisation Management].freeze

  scope :recents,    -> { order(created_at: :desc) }
  scope :publies,    -> { where(statut: "publie") }
  scope :brouillons, -> { where(statut: "brouillon") }

  # Attributs virtuels pour le formulaire (programme_json / sessions_disponibles)
  attr_writer :programme_avant, :programme_pendant, :programme_apres, :sessions_texte

  before_save :serialize_programme
  before_save :serialize_sessions

  def programme_avant
    @programme_avant || Array(programme_json&.dig("avant")).join("\n")
  end

  def programme_pendant
    @programme_pendant || Array(programme_json&.dig("pendant")).join("\n")
  end

  def programme_apres
    @programme_apres || Array(programme_json&.dig("apres")).join("\n")
  end

  def sessions_texte
    @sessions_texte || Array(sessions_disponibles).join("\n")
  end

  def publie? = statut == "publie"
  def nb_eleves = inscriptions.count
  def modules_count = module_formations.count
  def pret? = statut == "pret" || contenu_texte.present?

  def duree_label
    parts = []
    parts << "#{duree_jours} jour#{'s' if duree_jours.to_i > 1}" if duree_jours.present?
    parts << "#{duree_heures}h" if duree_heures.present?
    parts.join(" / ")
  end

  def prix_label
    return nil unless prix_inter.present?
    "#{format('%.2f', prix_inter)} € HT"
  end

  # Extrait le texte du fichier attaché selon son type
  def extraire_texte
    return contenu_texte if contenu_texte.present?
    return "" unless fichier.attached?

    case fichier.content_type
    when "application/pdf"
      extraire_pdf
    when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      extraire_docx
    when "application/vnd.openxmlformats-officedocument.presentationml.presentation"
      extraire_pptx
    when "text/plain"
      fichier.download
    else
      ""
    end
  rescue => e
    Rails.logger.error "Extraction fichier échouée : #{e.message}"
    ""
  end

  private

  def serialize_programme
    return unless @programme_avant || @programme_pendant || @programme_apres
    self.programme_json = {
      "avant"   => lines(@programme_avant),
      "pendant" => lines(@programme_pendant),
      "apres"   => lines(@programme_apres)
    }
  end

  def serialize_sessions
    return unless @sessions_texte
    self.sessions_disponibles = lines(@sessions_texte)
  end

  def lines(text)
    text.to_s.split("\n").map(&:strip).reject(&:blank?)
  end

  def extraire_pdf
    require "pdf-reader"
    reader = PDF::Reader.new(StringIO.new(fichier.download))
    reader.pages.map(&:text).join("\n")
  end

  def extraire_docx
    require "docx"
    tmpfile = Tempfile.new(["support", ".docx"])
    tmpfile.binmode
    tmpfile.write(fichier.download)
    tmpfile.flush
    doc = Docx::Document.open(tmpfile.path)
    doc.paragraphs.map(&:text).join("\n")
  ensure
    tmpfile&.close!
  end

  def extraire_pptx
    require "zip"
    slides_text = []
    Zip::InputStream.open(StringIO.new(fichier.download)) do |zip|
      while (entry = zip.get_next_entry)
        next unless entry.name.match?(%r{ppt/slides/slide\d+\.xml})
        xml = zip.read
        # Extraire uniquement le texte des balises <a:t>
        slides_text << xml.scan(/<a:t[^>]*>(.*?)<\/a:t>/m).flatten
                          .map { |t| CGI.unescapeHTML(t.strip) }
                          .reject(&:blank?)
                          .join(" ")
      end
    end
    slides_text.each_with_index.map { |t, i| "=== Slide #{i + 1} ===\n#{t}" }.join("\n\n")
  end
end
