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

ActiveRecord::Schema.define(version: 2021_07_12_112003) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "actor_permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "permittable_type"
    t.uuid "permittable_id"
    t.uuid "permission_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["permittable_type", "permittable_id", "permission_id"], name: "actor_permissions_unqiueness", unique: true
    t.index ["permittable_type", "permittable_id"], name: "index_actor_permissions_on_permittable_type_and_permittable_id"
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address_line_one"
    t.string "address_line_two"
    t.string "city"
    t.string "county"
    t.string "postcode"
    t.uuid "applicant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organisation"
    t.boolean "lookup_used", default: false, null: false
    t.string "lookup_id"
    t.index ["applicant_id"], name: "index_addresses_on_applicant_id"
  end

  create_table "admin_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "admin_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name"
    t.string "email"
    t.string "national_insurance_number"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "true_layer_secure_data_id"
    t.datetime "remember_created_at"
    t.string "remember_token"
    t.boolean "employed"
    t.index ["confirmation_token"], name: "index_applicants_on_confirmation_token", unique: true
    t.index ["email"], name: "index_applicants_on_email"
    t.index ["unlock_token"], name: "index_applicants_on_unlock_token", unique: true
  end

  create_table "application_proceeding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "proceeding_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "proceeding_case_id"
    t.boolean "lead_proceeding", default: false, null: false
    t.date "used_delegated_functions_on"
    t.date "used_delegated_functions_reported_on"
    t.index ["legal_aid_application_id"], name: "index_application_proceeding_types_on_legal_aid_application_id"
    t.index ["proceeding_case_id"], name: "index_application_proceeding_types_on_proceeding_case_id", unique: true
    t.index ["proceeding_type_id"], name: "index_application_proceeding_types_on_proceeding_type_id"
  end

  create_table "application_proceeding_types_linked_children", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "involved_child_id", null: false
    t.uuid "application_proceeding_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_proceeding_type_id", "involved_child_id"], name: "index_application_proceeding_involved_children"
    t.index ["involved_child_id", "application_proceeding_type_id"], name: "index_involved_children_application_proceeding"
  end

  create_table "application_proceeding_types_scope_limitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "application_proceeding_type_id", null: false
    t.uuid "scope_limitation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "type"
    t.index ["scope_limitation_id", "application_proceeding_type_id"], name: "index_scope_limitation_application_proceeding"
    t.index ["type", "application_proceeding_type_id", "scope_limitation_id"], name: "index_application_proceeding_scope_limitation", unique: true
  end

  create_table "attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.string "attachment_type"
    t.uuid "pdf_attachment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "attachment_name"
    t.text "original_filename"
  end

  create_table "attempts_to_settles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "attempts_made"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "application_proceeding_type_id", null: false
    t.index ["application_proceeding_type_id"], name: "index_attempts_to_settles_on_application_proceeding_type_id"
  end

  create_table "bank_account_holders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_provider_id", null: false
    t.json "true_layer_response"
    t.string "full_name"
    t.json "addresses"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_provider_id"], name: "index_bank_account_holders_on_bank_provider_id"
  end

  create_table "bank_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_provider_id", null: false
    t.json "true_layer_response"
    t.json "true_layer_balance_response"
    t.string "true_layer_id"
    t.string "name"
    t.string "currency"
    t.string "account_number"
    t.string "sort_code"
    t.decimal "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_type"
    t.index ["bank_provider_id"], name: "index_bank_accounts_on_bank_provider_id"
  end

  create_table "bank_errors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "applicant_id", null: false
    t.string "bank_name"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_bank_errors_on_applicant_id"
  end

  create_table "bank_holidays", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "dates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bank_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "applicant_id", null: false
    t.json "true_layer_response"
    t.string "credentials_id"
    t.string "token"
    t.datetime "token_expires_at"
    t.string "name"
    t.string "true_layer_provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_bank_providers_on_applicant_id"
  end

  create_table "bank_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id", null: false
    t.json "true_layer_response"
    t.string "true_layer_id"
    t.string "description"
    t.decimal "amount"
    t.string "currency"
    t.string "operation"
    t.string "merchant"
    t.datetime "happened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "transaction_type_id"
    t.string "meta_data"
    t.decimal "running_balance"
    t.json "flags"
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id"
    t.index ["transaction_type_id"], name: "index_bank_transactions_on_transaction_type_id"
  end

  create_table "benefit_check_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.string "result"
    t.string "dwp_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_benefit_check_results_on_legal_aid_application_id"
  end

  create_table "cash_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "legal_aid_application_id"
    t.decimal "amount"
    t.date "transaction_date"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "month_number"
    t.uuid "transaction_type_id"
    t.index ["legal_aid_application_id", "transaction_type_id", "month_number"], name: "cash_transactions_unique", unique: true
  end

  create_table "ccms_opponent_ids", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "serial_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "ccms_submission_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.string "status"
    t.string "document_type"
    t.string "ccms_document_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "attachment_id"
  end

  create_table "ccms_submission_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id", null: false
    t.string "from_state"
    t.string "to_state"
    t.boolean "success"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "request"
    t.text "response"
    t.index ["submission_id"], name: "index_ccms_submission_histories_on_submission_id"
  end

  create_table "ccms_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.string "applicant_ccms_reference"
    t.string "case_ccms_reference"
    t.string "aasm_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "applicant_add_transaction_id"
    t.integer "applicant_poll_count", default: 0
    t.string "case_add_transaction_id"
    t.integer "case_poll_count", default: 0
    t.index ["legal_aid_application_id"], name: "index_ccms_submissions_on_legal_aid_application_id"
  end

  create_table "cfe_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "submission_id"
    t.text "result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type", default: "CFE::V1::Result"
  end

  create_table "cfe_submission_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.string "url"
    t.string "http_method"
    t.text "request_payload"
    t.integer "http_response_status"
    t.text "response_payload"
    t.string "error_message"
    t.string "error_backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cfe_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "assessment_id"
    t.string "aasm_state"
    t.string "error_message"
    t.text "cfe_result"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_cfe_submissions_on_legal_aid_application_id"
  end

  create_table "chances_of_successes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "application_purpose"
    t.string "success_prospect"
    t.text "success_prospect_details"
    t.boolean "success_likely"
    t.uuid "application_proceeding_type_id", null: false
    t.index ["application_proceeding_type_id"], name: "index_chances_of_successes_on_application_proceeding_type_id"
  end

  create_table "debugs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "debug_type"
    t.string "legal_aid_application_id"
    t.string "session_id"
    t.text "session"
    t.string "auth_params"
    t.string "callback_params"
    t.string "callback_url"
    t.string "error_details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "browser_details"
  end

  create_table "dependants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.integer "number"
    t.string "name"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "relationship"
    t.decimal "monthly_income"
    t.boolean "has_income"
    t.boolean "in_full_time_education"
    t.boolean "has_assets_more_than_threshold"
    t.decimal "assets_value"
    t.index ["legal_aid_application_id"], name: "index_dependants_on_legal_aid_application_id"
  end

  create_table "dwp_overrides", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.text "passporting_benefit"
    t.boolean "has_evidence_of_benefit"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["legal_aid_application_id"], name: "index_dwp_overrides_on_legal_aid_application_id", unique: true
  end

  create_table "feedbacks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "done_all_needed"
    t.integer "satisfaction"
    t.text "improvement_suggestion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "os"
    t.string "browser"
    t.string "browser_version"
    t.string "source"
    t.integer "difficulty"
    t.string "email"
    t.string "originating_page"
  end

  create_table "firms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ccms_id"
    t.string "name"
  end

  create_table "gateway_evidences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.uuid "provider_uploader_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["legal_aid_application_id"], name: "index_gateway_evidences_on_legal_aid_application_id"
    t.index ["provider_uploader_id"], name: "index_gateway_evidences_on_provider_uploader_id"
  end

  create_table "incidents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "occurred_on"
    t.text "details"
    t.uuid "legal_aid_application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "told_on"
    t.index ["legal_aid_application_id"], name: "index_incidents_on_legal_aid_application_id"
  end

  create_table "involved_children", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.string "full_name"
    t.date "date_of_birth"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "ccms_opponent_id"
    t.index ["legal_aid_application_id"], name: "index_involved_children_on_legal_aid_application_id"
  end

  create_table "irregular_incomes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "legal_aid_application_id"
    t.string "income_type"
    t.string "frequency"
    t.decimal "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "legal_aid_application_transaction_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "transaction_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "laa_trans_type_on_legal_aid_application_id"
    t.index ["transaction_type_id"], name: "laa_trans_type_on_transaction_type_id"
  end

  create_table "legal_aid_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "application_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "applicant_id"
    t.boolean "has_offline_accounts"
    t.boolean "open_banking_consent"
    t.datetime "open_banking_consent_choice_at"
    t.string "own_home"
    t.decimal "property_value", precision: 10, scale: 2
    t.string "shared_ownership"
    t.decimal "outstanding_mortgage_amount"
    t.decimal "percentage_home"
    t.string "provider_step"
    t.uuid "provider_id"
    t.boolean "draft"
    t.date "transaction_period_start_on"
    t.date "transaction_period_finish_on"
    t.boolean "transactions_gathered"
    t.datetime "completed_at"
    t.json "applicant_means_answers"
    t.datetime "declaration_accepted_at"
    t.json "provider_step_params"
    t.boolean "own_vehicle"
    t.date "substantive_application_deadline_on"
    t.boolean "substantive_application"
    t.boolean "has_dependants"
    t.uuid "office_id"
    t.boolean "has_restrictions"
    t.string "restrictions_details"
    t.boolean "no_credit_transaction_types_selected"
    t.boolean "no_debit_transaction_types_selected"
    t.boolean "provider_received_citizen_consent"
    t.boolean "student_finance"
    t.datetime "discarded_at"
    t.datetime "merits_submitted_at"
    t.boolean "in_scope_of_laspo"
    t.boolean "emergency_cost_override"
    t.decimal "emergency_cost_requested"
    t.string "emergency_cost_reasons"
    t.boolean "no_cash_income"
    t.boolean "no_cash_outgoings"
    t.index ["applicant_id"], name: "index_legal_aid_applications_on_applicant_id"
    t.index ["application_ref"], name: "index_legal_aid_applications_on_application_ref", unique: true
    t.index ["discarded_at"], name: "index_legal_aid_applications_on_discarded_at"
    t.index ["office_id"], name: "index_legal_aid_applications_on_office_id"
    t.index ["provider_id"], name: "index_legal_aid_applications_on_provider_id"
  end

  create_table "legal_framework_merits_task_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.text "serialized_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["legal_aid_application_id"], name: "idx_lfa_merits_task_lists_on_legal_aid_application_id"
  end

  create_table "legal_framework_submission_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "submission_id"
    t.string "url"
    t.string "http_method"
    t.text "request_payload"
    t.integer "http_response_status"
    t.text "response_payload"
    t.string "error_message"
    t.string "error_backtrace"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "legal_framework_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "request_id"
    t.string "error_message"
    t.text "result"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["legal_aid_application_id"], name: "index_legal_framework_submissions_on_legal_aid_application_id"
  end

  create_table "malware_scan_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uploader_type"
    t.uuid "uploader_id"
    t.boolean "virus_found", null: false
    t.text "scan_result"
    t.json "file_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "scanner_working"
    t.index ["uploader_type", "uploader_id"], name: "index_malware_scan_results_on_uploader"
  end

  create_table "offices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ccms_id"
    t.string "code"
    t.uuid "firm_id"
    t.index ["firm_id"], name: "index_offices_on_firm_id"
  end

  create_table "offices_providers", id: false, force: :cascade do |t|
    t.uuid "office_id", null: false
    t.uuid "provider_id", null: false
    t.index ["office_id"], name: "index_offices_providers_on_office_id"
    t.index ["provider_id"], name: "index_offices_providers_on_provider_id"
  end

  create_table "opponents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.boolean "understands_terms_of_court_order"
    t.text "understands_terms_of_court_order_details"
    t.boolean "warning_letter_sent"
    t.text "warning_letter_sent_details"
    t.boolean "police_notified"
    t.text "police_notified_details"
    t.boolean "bail_conditions_set"
    t.text "bail_conditions_set_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.integer "ccms_opponent_id"
    t.index ["legal_aid_application_id"], name: "index_opponents_on_legal_aid_application_id"
  end

  create_table "other_assets_declarations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.decimal "second_home_value"
    t.decimal "second_home_mortgage"
    t.decimal "second_home_percentage"
    t.decimal "timeshare_property_value"
    t.decimal "land_value"
    t.decimal "valuable_items_value"
    t.decimal "inherited_assets_value"
    t.decimal "money_owed_value"
    t.decimal "trust_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "none_selected"
    t.index ["legal_aid_application_id"], name: "index_other_assets_declarations_on_legal_aid_application_id", unique: true
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "role"
    t.string "description"
    t.index ["role"], name: "index_permissions_on_role", unique: true
  end

  create_table "policy_disregards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "england_infected_blood_support"
    t.boolean "vaccine_damage_payments"
    t.boolean "variant_creutzfeldt_jakob_disease"
    t.boolean "criminal_injuries_compensation_scheme"
    t.boolean "national_emergencies_trust"
    t.boolean "we_love_manchester_emergency_fund"
    t.boolean "london_emergencies_trust"
    t.boolean "none_selected"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "legal_aid_application_id"
    t.index ["legal_aid_application_id"], name: "index_policy_disregards_on_legal_aid_application_id"
  end

  create_table "proceeding_type_scope_limitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "proceeding_type_id"
    t.uuid "scope_limitation_id"
    t.boolean "substantive_default"
    t.boolean "delegated_functions_default"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proceeding_type_id", "delegated_functions_default"], name: "index_proceedings_scopes_unique_delegated_default", unique: true, where: "(delegated_functions_default = true)"
    t.index ["proceeding_type_id", "scope_limitation_id"], name: "index_proceedings_scopes_unique_on_ids", unique: true
    t.index ["proceeding_type_id", "substantive_default"], name: "index_proceedings_scopes_unique_substantive_default", unique: true, where: "(substantive_default = true)"
    t.index ["proceeding_type_id"], name: "index_proceeding_type_scope_limitations_on_proceeding_type_id"
    t.index ["scope_limitation_id"], name: "index_proceeding_type_scope_limitations_on_scope_limitation_id"
  end

  create_table "proceeding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "ccms_code"
    t.string "meaning"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ccms_category_law"
    t.string "ccms_category_law_code"
    t.string "ccms_matter"
    t.string "ccms_matter_code"
    t.decimal "default_cost_limitation_delegated_functions", precision: 8, scale: 2
    t.decimal "default_cost_limitation_substantive", precision: 8, scale: 2
    t.boolean "involvement_type_applicant"
    t.string "additional_search_terms"
    t.uuid "default_service_level_id"
    t.tsvector "textsearchable"
    t.string "name"
    t.index ["code"], name: "index_proceeding_types_on_code"
    t.index ["default_service_level_id"], name: "index_proceeding_types_on_default_service_level_id"
    t.index ["textsearchable"], name: "textsearch_idx", using: :gin
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username", null: false
    t.string "type"
    t.text "roles"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "office_codes"
    t.uuid "firm_id"
    t.uuid "selected_office_id"
    t.string "name"
    t.string "email"
    t.boolean "portal_enabled", default: true
    t.integer "contact_id"
    t.string "invalid_login_details"
    t.index ["firm_id"], name: "index_providers_on_firm_id"
    t.index ["selected_office_id"], name: "index_providers_on_selected_office_id"
    t.index ["type"], name: "index_providers_on_type"
    t.index ["username"], name: "index_providers_on_username", unique: true
  end

  create_table "savings_amounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.decimal "offline_current_accounts"
    t.decimal "cash"
    t.decimal "other_person_account"
    t.decimal "national_savings"
    t.decimal "plc_shares"
    t.decimal "peps_unit_trusts_capital_bonds_gov_stocks"
    t.decimal "life_assurance_endowment_policy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "none_selected"
    t.decimal "offline_savings_accounts"
    t.boolean "no_account_selected"
    t.index ["legal_aid_application_id"], name: "index_savings_amounts_on_legal_aid_application_id"
  end

  create_table "scheduled_mailings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.string "mailer_klass", null: false
    t.string "mailer_method", null: false
    t.string "arguments", null: false
    t.datetime "scheduled_at", null: false
    t.datetime "sent_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "addressee"
    t.string "govuk_message_id"
  end

  create_table "scope_limitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "meaning"
    t.string "description"
    t.boolean "substantive", default: false
    t.boolean "delegated_functions", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_scope_limitations_on_code"
  end

  create_table "secure_data", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_levels", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "service_level_number"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_level_number"], name: "index_service_levels_on_service_level_number"
  end

  create_table "settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mock_true_layer_data", default: false, null: false
    t.boolean "manually_review_all_cases", default: true
    t.string "bank_transaction_filename", default: "db/sample_data/bank_transactions.csv"
    t.boolean "allow_welsh_translation", default: false, null: false
    t.boolean "allow_multiple_proceedings", default: false, null: false
    t.boolean "override_dwp_results", default: false, null: false
  end

  create_table "state_machine_proxies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.string "type"
    t.string "aasm_state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ccms_reason"
  end

  create_table "statement_of_cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.text "statement"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "provider_uploader_id"
    t.index ["legal_aid_application_id"], name: "index_statement_of_cases_on_legal_aid_application_id"
    t.index ["provider_uploader_id"], name: "index_statement_of_cases_on_provider_uploader_id"
  end

  create_table "transaction_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "operation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sort_order"
    t.datetime "archived_at"
    t.boolean "other_income", default: false
    t.string "parent_id"
    t.index ["parent_id"], name: "index_transaction_types_on_parent_id"
  end

  create_table "true_layer_banks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "banks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "estimated_value"
    t.decimal "payment_remaining"
    t.date "purchased_on"
    t.boolean "used_regularly"
    t.uuid "legal_aid_application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "more_than_three_years_old"
    t.index ["legal_aid_application_id"], name: "index_vehicles_on_legal_aid_application_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "applicants"
  add_foreign_key "application_proceeding_types", "legal_aid_applications"
  add_foreign_key "application_proceeding_types", "proceeding_types"
  add_foreign_key "attempts_to_settles", "application_proceeding_types"
  add_foreign_key "bank_account_holders", "bank_providers"
  add_foreign_key "bank_accounts", "bank_providers"
  add_foreign_key "bank_errors", "applicants"
  add_foreign_key "bank_providers", "applicants"
  add_foreign_key "bank_transactions", "bank_accounts"
  add_foreign_key "benefit_check_results", "legal_aid_applications"
  add_foreign_key "ccms_submission_documents", "ccms_submissions", column: "submission_id"
  add_foreign_key "ccms_submission_histories", "ccms_submissions", column: "submission_id"
  add_foreign_key "ccms_submissions", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "cfe_submissions", "legal_aid_applications"
  add_foreign_key "chances_of_successes", "application_proceeding_types"
  add_foreign_key "dependants", "legal_aid_applications"
  add_foreign_key "dwp_overrides", "legal_aid_applications"
  add_foreign_key "gateway_evidences", "legal_aid_applications"
  add_foreign_key "involved_children", "legal_aid_applications"
  add_foreign_key "legal_aid_applications", "applicants"
  add_foreign_key "legal_aid_applications", "offices"
  add_foreign_key "legal_aid_applications", "providers"
  add_foreign_key "legal_framework_merits_task_lists", "legal_aid_applications"
  add_foreign_key "legal_framework_submissions", "legal_aid_applications"
  add_foreign_key "offices", "firms"
  add_foreign_key "offices_providers", "offices"
  add_foreign_key "offices_providers", "providers"
  add_foreign_key "opponents", "legal_aid_applications"
  add_foreign_key "policy_disregards", "legal_aid_applications"
  add_foreign_key "providers", "firms"
  add_foreign_key "providers", "offices", column: "selected_office_id"
  add_foreign_key "savings_amounts", "legal_aid_applications"
  add_foreign_key "scheduled_mailings", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "statement_of_cases", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "statement_of_cases", "providers", column: "provider_uploader_id"
  add_foreign_key "vehicles", "legal_aid_applications"
end
