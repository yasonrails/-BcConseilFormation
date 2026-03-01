# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_01_500000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "certificats", force: :cascade do |t|
    t.datetime "approuve_le"
    t.bigint "approuve_par_id"
    t.bigint "cours_support_id", null: false
    t.datetime "created_at", null: false
    t.text "message_admin"
    t.string "numero", null: false
    t.string "statut", default: "en_attente", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["approuve_par_id"], name: "index_certificats_on_approuve_par_id"
    t.index ["cours_support_id"], name: "index_certificats_on_cours_support_id"
    t.index ["numero"], name: "index_certificats_on_numero", unique: true
    t.index ["statut"], name: "index_certificats_on_statut"
    t.index ["user_id", "cours_support_id"], name: "index_certificats_on_user_id_and_cours_support_id", unique: true
    t.index ["user_id"], name: "index_certificats_on_user_id"
  end

  create_table "cours_supports", force: :cascade do |t|
    t.integer "acompte_pct", default: 20
    t.string "categorie"
    t.text "contenu_texte"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "duree_heures"
    t.integer "duree_jours"
    t.text "financement_info"
    t.integer "max_participants"
    t.string "modalite", default: "presentiel"
    t.text "prerequis"
    t.decimal "prix_inter", precision: 8, scale: 2
    t.jsonb "programme_json", default: {}
    t.text "public_cible"
    t.string "ref_formation"
    t.jsonb "sessions_disponibles", default: []
    t.string "statut", default: "brouillon"
    t.string "titre", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["categorie"], name: "index_cours_supports_on_categorie"
    t.index ["ref_formation"], name: "index_cours_supports_on_ref_formation", unique: true, where: "(ref_formation IS NOT NULL)"
    t.index ["user_id"], name: "index_cours_supports_on_user_id"
  end

  create_table "inscriptions", force: :cascade do |t|
    t.bigint "cours_support_id", null: false
    t.datetime "created_at", null: false
    t.datetime "inscrit_le", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cours_support_id"], name: "index_inscriptions_on_cours_support_id"
    t.index ["user_id", "cours_support_id"], name: "index_inscriptions_on_user_id_and_cours_support_id", unique: true
    t.index ["user_id"], name: "index_inscriptions_on_user_id"
  end

  create_table "module_formations", force: :cascade do |t|
    t.text "contenu"
    t.bigint "cours_support_id", null: false
    t.datetime "created_at", null: false
    t.string "duree_estimee"
    t.jsonb "objectifs", default: []
    t.integer "ordre", default: 0
    t.string "statut", default: "brouillon"
    t.string "titre", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cours_support_id"], name: "index_module_formations_on_cours_support_id"
    t.index ["user_id"], name: "index_module_formations_on_user_id"
  end

  create_table "progressions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "module_formation_id", null: false
    t.integer "score"
    t.boolean "termine", default: false, null: false
    t.datetime "termine_le"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["module_formation_id"], name: "index_progressions_on_module_formation_id"
    t.index ["user_id", "module_formation_id"], name: "index_progressions_on_user_id_and_module_formation_id", unique: true
    t.index ["user_id"], name: "index_progressions_on_user_id"
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.integer "bonne_reponse", null: false
    t.datetime "created_at", null: false
    t.text "enonce", null: false
    t.text "explication"
    t.bigint "module_formation_id", null: false
    t.string "niveau", default: "comprehension"
    t.jsonb "options", default: []
    t.integer "ordre", default: 0
    t.string "point_cle"
    t.text "pourquoi"
    t.string "type_question", default: "qcm"
    t.datetime "updated_at", null: false
    t.index ["module_formation_id"], name: "index_quiz_questions_on_module_formation_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "nom"
    t.string "prenom"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "eleve", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "certificats", "cours_supports"
  add_foreign_key "certificats", "users"
  add_foreign_key "certificats", "users", column: "approuve_par_id"
  add_foreign_key "cours_supports", "users"
  add_foreign_key "inscriptions", "cours_supports"
  add_foreign_key "inscriptions", "users"
  add_foreign_key "module_formations", "cours_supports"
  add_foreign_key "module_formations", "users"
  add_foreign_key "progressions", "module_formations"
  add_foreign_key "progressions", "users"
  add_foreign_key "quiz_questions", "module_formations"
end
