class CoursSupport < ApplicationRecord
  belongs_to :user
  has_many :module_formations, dependent: :destroy
  has_one_attached :fichier   # PDF, DOCX, TXT

  validates :titre, presence: true

  STATUTS = %w[brouillon pret].freeze

  scope :recents, -> { order(created_at: :desc) }

  def modules_count
    module_formations.count
  end

  def pret?
    statut == "pret" || contenu_texte.present?
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
end
