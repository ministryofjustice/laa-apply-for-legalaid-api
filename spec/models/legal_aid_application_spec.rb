require 'rails_helper'

RSpec.describe LegalAidApplication, type: :model do
  let(:legal_aid_application) { create :legal_aid_application }

  describe 'validations' do
    let(:attributes) { { proceeding_type_codes: %w[invalid_code1 invalid_code2] } }
    let(:legal_aid_application) { described_class.new(attributes) }
    context 'when invalid proceeding type codes are provided' do
      it 'contains an invalid error for proceeding type codes' do
        expect(legal_aid_application).not_to be_valid
        expect(legal_aid_application.errors[:proceeding_type_codes]).to match_array(['is invalid'])
      end
    end

    context 'when valid proceeding type codes are provided' do
      let!(:proceeding_types) { create_list(:proceeding_type, 2) }
      let(:proceeding_type_codes) { proceeding_types.map(&:code) }
      let(:attributes) { { provider: create(:provider), proceeding_type_codes: proceeding_type_codes } }

      it 'will be valid' do
        expect(legal_aid_application).to be_valid
      end
    end
  end

  describe '#capture_policy_disregards?' do
    subject { legal_aid_application.capture_policy_disregards? }
    context 'calculation date nil' do
      before { expect(legal_aid_application).to receive(:calculation_date).and_return(nil) }
      context 'todays date before start of policy disregards' do
        it 'returns false' do
          travel_to Time.zone.local(2021, 1, 7, 13, 45)
          expect(subject).to be false
          travel_back
        end
      end

      context 'todays date after start of policy disregards' do
        it 'returns true' do
          travel_to Time.zone.local(2021, 1, 8, 13, 45)
          expect(subject).to be true
          travel_back
        end
      end
    end

    context 'calculation date set' do
      before { expect(legal_aid_application).to receive(:calculation_date).and_return(calculation_date) }
      context 'todays date before start of policy disregards' do
        let(:calculation_date) { Date.new(2021, 1, 7) }
        it 'returns false' do
          travel_to Time.zone.local(2021, 1, 7, 13, 45)
          expect(subject).to be false
          travel_back
        end
      end

      context 'todays date after start of policy disregards' do
        let(:calculation_date) { Date.new(2021, 1, 8) }
        it 'returns true' do
          travel_to Time.zone.local(2021, 1, 8, 13, 45)
          expect(subject).to be true
          travel_back
        end
      end
    end
  end

  describe '#policy_disregards?' do
    context 'no policy disregard record' do
      it 'returns false' do
        expect(legal_aid_application.policy_disregards).to be_nil
        expect(legal_aid_application.policy_disregards?).to be false
      end
    end

    context 'policy_disregards record exists' do
      context 'none selected is true' do
        before { create :policy_disregards, legal_aid_application: legal_aid_application }
        it 'returns false' do
          expect(legal_aid_application.policy_disregards?).to be false
        end
      end

      context 'none selected is false' do
        before { create :policy_disregards, legal_aid_application: legal_aid_application, national_emergencies_trust: true }
        it 'returns true' do
          expect(legal_aid_application.policy_disregards?).to be true
        end
      end
    end
  end

  describe '#proceeding_type_codes=' do
    context 'when all the provded codes match existent proceeding types' do
      let!(:proceeding_types) { create_list(:proceeding_type, 2) }
      let(:proceeding_type_codes) { proceeding_types.map(&:code) }

      it 'assigns the provides codes' do
        expect {
          legal_aid_application.proceeding_type_codes = proceeding_type_codes
        }.to change { legal_aid_application.proceeding_type_codes }.from(nil).to(proceeding_type_codes)
      end

      it 'assign all providing types matching the codes' do
        expect(legal_aid_application.proceeding_types).to be_empty
        legal_aid_application.proceeding_type_codes = proceeding_type_codes
        expect(legal_aid_application.proceeding_types).to eq(proceeding_types)
      end
    end

    context 'when not all the provided codes match existent proceeding types' do
      let!(:proceeding_type) { create(:proceeding_type) }
      let(:proceeding_type_codes) { [proceeding_type.code, 'non-existent-code'] }

      it 'assigns the provides codes' do
        expect {
          legal_aid_application.proceeding_type_codes = proceeding_type_codes
        }.to change { legal_aid_application.proceeding_type_codes }.from(nil).to(proceeding_type_codes)
      end

      it 'assign only the providing types matching the codes' do
        expect(legal_aid_application.proceeding_types).to be_empty
        legal_aid_application.proceeding_type_codes = proceeding_type_codes
        expect(legal_aid_application.proceeding_types).to eq([proceeding_type])
      end
    end
  end

  describe '#add_benefit_check_result' do
    let(:benefit_check_response) do
      {
        benefit_checker_status: Faker::Lorem.word,
        confirmation_ref: SecureRandom.hex
      }
    end

    before do
      legal_aid_application.save!
      allow(BenefitCheckService).to receive(:call).with(legal_aid_application).and_return(benefit_check_response)
    end

    it 'creates a check_benefit_result with the right values' do
      legal_aid_application.add_benefit_check_result
      expect(legal_aid_application.benefit_check_result.result).to eq(benefit_check_response[:benefit_checker_status])
      expect(legal_aid_application.benefit_check_result.dwp_ref).to eq(benefit_check_response[:confirmation_ref])
    end

    context 'benefit check service is down' do
      let(:benefit_check_response) { false }

      it 'returns false' do
        expect(legal_aid_application.add_benefit_check_result).to eq false
      end

      it 'leaves benefit_check_result empty' do
        legal_aid_application.add_benefit_check_result
        expect(legal_aid_application.benefit_check_result).to eq nil
      end
    end
  end

  describe '#lead_application_proceeding_type' do
    context 'application proceeding types exist' do
      let!(:legal_aid_application) do
        create :legal_aid_application, :with_applicant
      end
      let!(:application_proceeding_type1) { create :application_proceeding_type, lead_proceeding: true, legal_aid_application: legal_aid_application }
      let!(:application_proceeding_type2) { create :application_proceeding_type, lead_proceeding: false, legal_aid_application: legal_aid_application }

      it 'returns the lead application proceeding type' do
        expect(legal_aid_application.lead_application_proceeding_type).to eq application_proceeding_type1
      end
    end
    context 'application proceeding types do not exist' do
      let(:legal_aid_application) { create :legal_aid_application, :with_applicant }

      it 'is true' do
        expect(legal_aid_application.lead_application_proceeding_type).to eq nil
      end
    end
  end

  describe '#pre_dwp_check?' do
    let(:state) { :initiated }
    let!(:legal_aid_application) { create :legal_aid_application, :with_applicant, state }

    context 'in pre-dwp-check state' do
      it 'is true' do
        expect(legal_aid_application.pre_dwp_check?).to eq true
      end
    end

    context 'in non passported state' do
      let!(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :with_applicant, state }
      let(:state) { :checking_non_passported_means }

      it 'is false' do
        expect(legal_aid_application.pre_dwp_check?).to eq false
      end
    end

    context 'in passported state' do
      let(:state) { :checking_passported_answers }

      it 'is false' do
        expect(legal_aid_application.pre_dwp_check?).to eq false
      end
    end
  end

  describe 'benefit_check_result_needs_updating?' do
    let!(:legal_aid_application) { create :legal_aid_application, :with_applicant, :at_entering_applicant_details }
    let(:applicant) { legal_aid_application.applicant }
    it 'is true if no benefit check results' do
      expect(legal_aid_application).to be_benefit_check_result_needs_updating
    end

    context 'with up to date benefit check results' do
      let!(:benefit_check_result) { create :benefit_check_result, legal_aid_application: legal_aid_application }

      it 'returns false' do
        expect(legal_aid_application).not_to be_benefit_check_result_needs_updating
      end

      context 'but later, applicant first name updated' do
        before { applicant.update(first_name: Faker::Name.first_name) }
        let!(:benefit_check_result) { travel(-10.minutes) { create :benefit_check_result, legal_aid_application: legal_aid_application } }

        it 'returns true' do
          expect(legal_aid_application).to be_benefit_check_result_needs_updating
        end
      end

      context 'but later, state changes' do
        before do
          legal_aid_application.check_applicant_details!
        end

        it 'returns false' do
          expect(legal_aid_application).not_to be_benefit_check_result_needs_updating
        end
      end
    end
  end

  describe '#generate_secure_id' do
    let(:legal_aid_application) { create :legal_aid_application }
    let(:secure_data) { SecureData.last }

    subject { legal_aid_application.generate_secure_id }

    it 'generates a new secure data object' do
      expect { subject }.to change { SecureData.count }.by(1)
    end

    it 'returns the generated id' do
      expect(subject).to eq(secure_data.id)
    end

    it 'generates data that can be used to find legal_aid_application' do
      data = SecureData.for(subject)[:legal_aid_application]
      expect(data).to be_present
      expect(described_class.find_by(data)).to eq(legal_aid_application)
    end

    it 'generates data that contains a date which is in 8 days' do
      data = SecureData.for(subject)
      expire_date = (Time.current + LegalAidApplication::SECURE_ID_DAYS_TO_EXPIRE.days).end_of_day
      expect(data[:expired_at]).to be_between(expire_date - 1.minute, expire_date + 1.minute)
    end
  end

  describe 'state machine' do
    subject(:legal_aid_application) { create(:legal_aid_application) }

    it 'is created with a default state of "initiated"' do
      expect(legal_aid_application.state).to eq('initiated')
    end
  end

  describe '#merits_complete!' do
    let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant) }

    let(:date) { Date.new(2021, 1, 7) }

    it 'updates the application merits_submitted_at attribute' do
      travel_to(date) do
        legal_aid_application.merits_complete!
        expect(legal_aid_application.reload.merits_submitted_at).to eq(date)
      end
    end

    it 'calls on rails notification service' do
      expect(ActiveSupport::Notifications).to receive(:instrument).with(any_args)
      legal_aid_application.merits_complete!
    end
  end

  describe '#summary_state' do
    let!(:legal_aid_application) { create(:legal_aid_application, :with_applicant, merits_submitted_at: merits_submitted_at) }

    context 'merits not completed' do
      let(:merits_submitted_at) { nil }
      it 'returns :in_progress summary state' do
        expect(legal_aid_application.summary_state).to eq(:in_progress)
      end
    end

    context 'merits completed' do
      let(:merits_submitted_at) { Faker::Time.backward }

      it 'returns :in_progress summary state' do
        expect(legal_aid_application.summary_state).to eq(:submitted)
      end
    end
  end

  describe '#shared_ownership?' do
    subject(:legal_aid_application) { create(:legal_aid_application, shared_ownership: shared_ownership_reason) }

    context 'when applicant owns a share of a property' do
      let(:shared_ownership_reason) { LegalAidApplication::SHARED_OWNERSHIP_YES_REASONS.first }

      it 'return true that the applicant owns a share of a property' do
        expect(legal_aid_application.shared_ownership?).to eq true
      end
    end

    context 'when applicant is the sole owner of a property' do
      let(:shared_ownership_reason) { LegalAidApplication::SHARED_OWNERSHIP_NO_REASONS.first }
      it 'return true that the applicant owns a share of a property' do
        expect(legal_aid_application.shared_ownership?).to eq false
      end
    end
  end

  describe '#uncategorised_transactions?' do
    context 'transaction types have associated bank transactions' do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: applicant }
      let(:bank_account) { create :bank_account, bank_provider: bank_provider }
      let!(:transaction_type) { create :transaction_type, :credit, name: 'salary' }
      let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type: transaction_type, bank_account: bank_account }
      let(:legal_aid_application) { create :legal_aid_application, applicant: applicant, transaction_types: [transaction_type] }

      context 'income transactions' do
        let!(:transaction_type) { create :transaction_type, :credit, name: 'salary' }
        it 'returns false' do
          expect(legal_aid_application.uncategorised_transactions?(:credit)).to eq false
        end
      end

      context 'outgoing transactions' do
        let(:transaction_type) { create :transaction_type, :debit }
        let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type: transaction_type, bank_account: bank_account }
        it 'returns false' do
          expect(legal_aid_application.uncategorised_transactions?(:debit)).to eq false
        end
      end
    end
    context 'transaction types do not have associated bank transactions' do
      let(:applicant) { create :applicant }
      let(:bank_provider) { create :bank_provider, applicant: applicant }
      let(:bank_account) { create :bank_account, bank_provider: bank_provider }
      let!(:transaction_type) { create :transaction_type, :credit, name: 'salary' }
      let!(:bank_transaction) { create :bank_transaction, :credit, transaction_type: nil, bank_account: bank_account }
      let(:legal_aid_application) { create :legal_aid_application, applicant: applicant, transaction_types: [transaction_type] }

      context 'income transactions' do
        it 'returns true' do
          expect(legal_aid_application.uncategorised_transactions?(:credit)).to eq true
        end
      end

      context 'outgoing transactions' do
        let!(:bank_transaction) { create :bank_transaction, :debit, transaction_type: nil, bank_account: bank_account }
        let!(:transaction_type) { create :transaction_type, :debit }
        it 'returns true' do
          expect(legal_aid_application.uncategorised_transactions?(:debit)).to eq true
        end
      end
    end
  end

  describe '#own_home?' do
    context 'legal_aid_application.own_home is nil' do
      before { legal_aid_application.update!(own_home: nil) }
      it 'returns false' do
        expect(legal_aid_application.own_home?).to eq(false)
      end
    end

    context 'legal_aid_application.own_home is "no"' do
      let(:legal_aid_application) { create :legal_aid_application, :without_own_home }
      it 'returns false' do
        expect(legal_aid_application.own_home?).to eq(false)
      end
    end

    context 'legal_aid_application.own_home is not "no"' do
      let(:legal_aid_application) { create :legal_aid_application, :with_own_home_mortgaged }
      it 'returns true' do
        expect(legal_aid_application.own_home?).to eq(true)
      end
    end
  end

  describe '#own_capital?' do
    context 'no home, savings or assets' do
      let(:legal_aid_application) { create :legal_aid_application, own_home: nil }
      it 'returns nil' do
        expect(legal_aid_application.own_capital?).to be false
      end
    end

    context 'own home' do
      let(:legal_aid_application) { create :legal_aid_application, :with_own_home_mortgaged }
      it 'returns true' do
        expect(legal_aid_application.own_capital?).to eq(true)
      end
    end

    context 'has some assets' do
      before { legal_aid_application.update!(other_assets_declaration: create(:other_assets_declaration, :with_all_values)) }
      it 'returns true' do
        expect(legal_aid_application.own_capital?).to eq(true)
      end
    end

    context 'has some savings' do
      before { legal_aid_application.update!(savings_amount: create(:savings_amount, :with_values)) }
      it 'returns true' do
        expect(legal_aid_application.own_capital?).to eq(true)
      end
    end
  end

  describe 'set_transaction_period' do
    subject { legal_aid_application.set_transaction_period }

    it 'sets start' do
      subject
      expect(legal_aid_application.transaction_period_start_on).to eq(Date.current - 3.months)
    end

    it 'sets finish' do
      subject
      expect(legal_aid_application.transaction_period_finish_on).to eq(Date.current)
    end

    context 'delegated functions are used' do
      let(:legal_aid_application) { create :legal_aid_application, used_delegated_functions: true, used_delegated_functions_on: Faker::Date.backward }
      let(:used_delegated_functions_on) { legal_aid_application.used_delegated_functions_on }

      it 'sets start and finish relative to used_delegated_functions_on' do
        subject
        expect(legal_aid_application.transaction_period_start_on).to eq(used_delegated_functions_on - 3.months)
        expect(legal_aid_application.transaction_period_finish_on).to eq(used_delegated_functions_on)
      end
    end
  end

  describe '#submitted_to_ccms?' do
    context 'application not submitted to ccms' do
      let(:legal_aid_application) { create :legal_aid_application }
      it 'returns false' do
        expect(legal_aid_application.submitted_to_ccms?).to be(false)
      end
    end

    context 'application submitted to ccms' do
      let(:legal_aid_application) { create :legal_aid_application, :submitted_to_ccms }
      it 'returns true' do
        expect(legal_aid_application.submitted_to_ccms?).to be(true)
      end
    end
  end

  describe '#read_only?' do
    context 'provider application not submitted' do
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine }
      it 'returns false' do
        expect(legal_aid_application.read_only?).to be(false)
      end
    end

    context 'provider submitted' do
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :applicant_entering_means }
      it 'returns true' do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end

    context 'checking citizen answers?' do
      let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :checking_citizen_answers }
      it 'returns true' do
        expect(legal_aid_application.read_only?).to be(true)
      end
    end
  end

  describe 'attributes are synced on applicant_details_checked' do
    let(:legal_aid_application) { create :legal_aid_application, :with_everything, :without_own_home, :checking_applicant_details }

    it 'passes application to keep in sync service' do
      expect(CleanupCapitalAttributes).to receive(:call).with(legal_aid_application)
      legal_aid_application.applicant_details_checked!
    end

    context 'and attributes changed' do
      before do
        legal_aid_application.applicant_details_checked!
        legal_aid_application.reload
      end
      it 'resets property values' do
        expect(legal_aid_application.property_value).to be_blank
      end
      it 'resets outstanding mortgage' do
        expect(legal_aid_application.outstanding_mortgage_amount).to be_blank
      end
      it 'resets shared ownership' do
        expect(legal_aid_application.shared_ownership).to be_blank
      end
      it 'resets percentage home' do
        expect(legal_aid_application.percentage_home).to be_blank
      end
    end
  end

  # Main purpose: to ensure relationships to other objects set so that destroying application destroys all objects
  # that then become redundant.
  describe '.destroy_all' do
    let!(:legal_aid_application) do
      create :legal_aid_application, :with_everything, :with_proceeding_types, :with_negative_benefit_check_result, :with_bank_transactions
    end

    before do
      create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application
    end

    subject { described_class.destroy_all }

    # A bit verbose, but minimises the SQL calls required to complete spec
    it 'removes everything it needs to' do
      expect(ApplicationProceedingType.count).not_to be_zero
      expect(BenefitCheckResult.count).not_to be_zero
      expect(OtherAssetsDeclaration.count).not_to be_zero
      expect(SavingsAmount.count).not_to be_zero
      expect(ApplicationMeritsTask::StatementOfCase.count).not_to be_zero
      expect(ProceedingMeritsTask::ChancesOfSuccess.count).not_to be_zero
      expect(Applicant.count).not_to be_zero
      expect(BankAccount.count).not_to be_zero
      expect(BankTransaction.count).not_to be_zero
      expect(BankProvider.count).not_to be_zero
      expect(BankAccountHolder.count).not_to be_zero
      expect(BankError.count).not_to be_zero
      expect(LegalAidApplicationTransactionType.count).not_to be_zero
      expect { subject }.to change { described_class.count }.to(0)
      expect(ApplicationProceedingType.count).to be_zero
      expect(BenefitCheckResult.count).to be_zero
      expect(OtherAssetsDeclaration.count).to be_zero
      expect(SavingsAmount.count).to be_zero
      expect(ApplicationMeritsTask::StatementOfCase.count).to be_zero
      expect(ProceedingMeritsTask::ChancesOfSuccess.count).to be_zero
      expect(Applicant.count).to be_zero
      expect(BankAccount.count).to be_zero
      expect(BankTransaction.count).to be_zero
      expect(BankProvider.count).to be_zero
      expect(BankAccountHolder.count).to be_zero
      expect(BankError.count).to be_zero
      expect(LegalAidApplicationTransactionType.count).to be_zero
    end

    it 'leaves object it should not affect' do
      expect(ProceedingType.count).not_to be_zero
      expect(TransactionType.count).not_to be_zero
      subject
      expect(ProceedingType.count).not_to be_zero
      expect(TransactionType.count).not_to be_zero
    end
  end

  describe '#create_app_ref' do
    it 'generates an application_ref when the application is created' do
      legal_aid_application = LegalAidApplication.create!(provider: (create :provider))
      expect(legal_aid_application.application_ref).to match(/L(-[ABCDEFHJKLMNPRTUVWXY0-9]{3}){2}/)
    end
  end

  describe 'state label' do
    let(:states) { legal_aid_application.state_machine_proxy.aasm.states.map(&:name) }

    context 'passported states' do
      it 'has a translation for all states' do
        states.each do |state|
          expect(I18n.exists?("model_enum_translations.legal_aid_application.state.#{state}")).to be(true)
        end
      end
    end

    context 'non-passported states' do
      before { legal_aid_application.change_state_machine_type('NonPassportedStateMachine') }

      it 'has a translation for all states' do
        states.each do |state|
          expect(I18n.exists?("model_enum_translations.legal_aid_application.state.#{state}")).to be(true)
        end
      end
    end
  end

  describe 'reset delegated functions' do
    it 'resets it to a substantive application' do
      application = create :legal_aid_application, :with_delegated_functions
      expect(application.used_delegated_functions).to be true
      expect(application.used_delegated_functions_on).to eq Time.zone.today
      expect(application.used_delegated_functions_reported_on).to eq Time.zone.today
      application.reset_delegated_functions
      expect(application.used_delegated_functions).to be false
      expect(application.used_delegated_functions_on).to be_nil
      expect(application.used_delegated_functions_reported_on).to be_nil
    end
  end

  describe 'default_cost_limitations' do
    let(:proceeding_type) do
      create :proceeding_type,
             default_cost_limitation_substantive: 9_000,
             default_cost_limitation_delegated_functions: 2_500
    end
    context 'substantive' do
      let(:application) { create :legal_aid_application, proceeding_types: [proceeding_type] }
      it 'returns the substantive cost limitation for the first proceeding type' do
        expect(application.default_cost_limitation).to eq 9_000
      end
    end

    context 'delegated functions' do
      let(:application) { create :legal_aid_application, :with_delegated_functions, proceeding_types: [proceeding_type] }
      it 'returns the subtantive cost limitation for the first proceeding type' do
        expect(application.default_cost_limitation).to eq 9_000
      end
    end
  end

  describe '#bank_transactions' do
    let(:transaction_period_start_on) { '2019-08-10'.to_date }
    let(:transaction_period_finish_on) { '2019-08-20'.to_date }
    let(:date_before_start) { '2019-08-09 23:40 +0100'.to_time }
    let(:date_after_start)  { '2019-08-10 00:20 +0100'.to_time }
    let(:date_before_end)   { '2019-08-20 23:40 +0100'.to_time }
    let(:date_after_end)    { '2019-08-21 00:20 +0100'.to_time }
    let(:legal_aid_application) do
      create :legal_aid_application,
             :with_applicant,
             transaction_period_start_on: transaction_period_start_on,
             transaction_period_finish_on: transaction_period_finish_on
    end
    let(:bank_provider) { create :bank_provider, applicant: legal_aid_application.applicant }
    let(:bank_account) { create :bank_account, bank_provider: bank_provider }
    let!(:transaction_before_start) { create :bank_transaction, bank_account: bank_account, happened_at: date_before_start }
    let!(:transaction_after_start) { create :bank_transaction, bank_account: bank_account, happened_at: date_after_start }
    let!(:transaction_before_end) { create :bank_transaction, bank_account: bank_account, happened_at: date_before_end }
    let!(:transaction_after_end) { create :bank_transaction, bank_account: bank_account, happened_at: date_after_end }
    let(:transaction_ids) { subject.pluck(:id) }

    subject { legal_aid_application.bank_transactions }

    it 'returns the all transactions' do
      expect(transaction_ids).to include(transaction_after_start.id)
      expect(transaction_ids).to include(transaction_before_end.id)
      expect(transaction_ids).to include(transaction_before_start.id)
      expect(transaction_ids).to include(transaction_after_end.id)
    end
  end

  describe 'applicant_receives_benefit?' do
    context 'benefit_check_result exists?' do
      context 'passported' do
        before { create :benefit_check_result, :positive, legal_aid_application: legal_aid_application }
        context 'No DWP Override' do
          it 'returns true' do
            expect(legal_aid_application.applicant_receives_benefit?).to be true
          end

          it 'returns true for the aliased method #passported?' do
            expect(legal_aid_application.passported?).to be true
          end
        end

        context 'DWP override' do
          before { create :dwp_override, legal_aid_application: legal_aid_application }
          it 'returns true' do
            expect(legal_aid_application.applicant_receives_benefit?).to be true
          end
        end
      end

      context 'not passported' do
        before { create :benefit_check_result, legal_aid_application: legal_aid_application }
        context 'No DWP override' do
          it 'returns false' do
            expect(legal_aid_application.applicant_receives_benefit?).to be false
          end

          it 'returns true for the alias non_passported' do
            expect(legal_aid_application.non_passported?).to be true
          end
        end

        context 'DWP Override' do
          before { create :dwp_override, legal_aid_application: legal_aid_application }
          it 'returns true' do
            expect(legal_aid_application.applicant_receives_benefit?).to be true
          end

          it 'returns false for the alias non_passported' do
            expect(legal_aid_application.non_passported?).to be false
          end
        end
      end

      context 'undetermined' do
        before { create :benefit_check_result, :undetermined, legal_aid_application: legal_aid_application }
        context 'No DWP Override' do
          it 'returns false' do
            expect(legal_aid_application.applicant_receives_benefit?).to be false
          end
        end

        context 'DWP Override' do
          before { create :dwp_override, legal_aid_application: legal_aid_application }
          it 'returns true' do
            expect(legal_aid_application.applicant_receives_benefit?).to be true
          end
        end
      end
    end

    context 'benefit_check_result does not exist' do
      it 'returns false' do
        expect(legal_aid_application.applicant_receives_benefit?).to be false
      end
    end
  end

  describe '#generated_reports' do
    let(:legal_aid_application) { create :legal_aid_application, :generating_reports }
    let(:submit_applications_to_ccms) { true }

    before { allow(Rails.configuration.x.ccms_soa).to receive(:submit_applications_to_ccms).and_return(submit_applications_to_ccms) }

    it 'starts the ccms submission process' do
      expect(legal_aid_application.find_or_create_ccms_submission).to receive(:process_async!)
      legal_aid_application.generated_reports!
    end

    context 'submit_applications_to_ccms is set to false' do
      let(:submit_applications_to_ccms) { false }

      it 'does not start the ccms submission process' do
        expect(legal_aid_application.find_or_create_ccms_submission).not_to receive(:process_async!)
        legal_aid_application.generated_reports!
      end
    end
  end

  describe '#submitted_assessment' do
    let(:legal_aid_application) { create :legal_aid_application, :with_applicant, :checking_merits_answers }
    let(:feedback_url) { 'http://test/feedback/new' }

    it 'schedules a PostSubmissionProcessingJob ' do
      expect(PostSubmissionProcessingJob).to receive(:perform_later).with(
        legal_aid_application.id,
        feedback_url
      ).and_call_original
      legal_aid_application.generate_reports!
    end
  end

  describe 'complete means event' do
    let(:legal_aid_application) { create :legal_aid_application, :with_non_passported_state_machine, :checking_citizen_answers }
    it 'runs the complete means service and the bank transaction analyser' do
      expect(ApplicantCompleteMeans).to receive(:call).with(legal_aid_application)
      expect(BankTransactionsAnalyserJob).to receive(:perform_later).with(legal_aid_application)
      legal_aid_application.complete_non_passported_means!
    end
  end

  describe '.search' do
    let!(:application1) { create :legal_aid_application, application_ref: 'L-123-ABC' }
    let(:jacob) { create :applicant, first_name: 'Jacob', last_name: 'Rees-Mogg' }
    let!(:application2) { create :legal_aid_application, applicant: jacob }
    let(:ccms_submission) { create :submission, case_ccms_reference: '300000000009' }
    let!(:application3) { create :legal_aid_application, ccms_submission: ccms_submission }
    let(:non_alphanum) { /[^0-9a-zA-Z]/.random_example }

    it 'matches application_ref' do
      [
        'L 123 ABC',
        'L123ABC',
        'l123abc',
        'L/123/ABC',
        "L123#{non_alphanum}ABC"
      ].each do |term|
        expect(LegalAidApplication.search(term)).to include(application1), term
      end
      expect(LegalAidApplication.search('something')).not_to include(application1)
    end

    it "matches applicant's name" do
      [
        'Rees-Mogg',
        'Jacob Rees-Mogg',
        "Jacob Rees'Mogg",
        'reesmogg',
        'smog',
        'cobree',
        'sMOg',
        "jac#{non_alphanum}ob"
      ].each do |term|
        expect(LegalAidApplication.search(term)).to include(application2), term
      end
      expect(LegalAidApplication.search('something')).not_to include(application2)
    end

    it 'matches ccms case reference number' do
      [
        '300',
        '0',
        '9',
        '09',
        "0#{non_alphanum}9"
      ].each do |term|
        expect(LegalAidApplication.search(term)).to include(application3), term
      end
      expect(LegalAidApplication.search('something')).not_to include(application3)
    end
  end

  describe '#cfe_result' do
    it 'returns the result associated with the most recent CFE::Submission' do
      travel(-10.minutes) do
        legal_aid_application = create :legal_aid_application
        submission1 = create :cfe_submission, legal_aid_application: legal_aid_application
        create :cfe_v3_result, submission: submission1
      end
      submission2 = create :cfe_submission, legal_aid_application: legal_aid_application
      result2 = create :cfe_v3_result, submission: submission2

      expect(legal_aid_application.cfe_result).to eq result2
    end
  end

  describe '#transaction_types' do
    let(:legal_aid_application) { create :legal_aid_application }
    let!(:ff) { create :transaction_type, :friends_or_family }
    let!(:salary) { create :transaction_type, :salary }
    let!(:maintenance) { create :transaction_type, :maintenance_out }
    let!(:child_care) { create :transaction_type, :child_care }
    let!(:ff_tt) { create :legal_aid_application_transaction_type, transaction_type: ff, legal_aid_application: legal_aid_application }
    let!(:maintenance_tt) { create :legal_aid_application_transaction_type, transaction_type: maintenance, legal_aid_application: legal_aid_application }

    it 'returns an array of transaction type records' do
      expect(legal_aid_application.transaction_types).to eq [ff, maintenance]
    end

    describe '#transaction_type.for_outgoing_type?' do
      context 'there is no legal aid transaction type of the required type' do
        it 'returns false' do
          expect(legal_aid_application.transaction_types.for_outgoing_type?('child_care')).to be false
        end
      end

      context 'there is a legal aid transaction type of the rrquired type' do
        it 'returns true' do
          expect(legal_aid_application.transaction_types.for_outgoing_type?('maintenance_out')).to be true
        end
      end
    end
  end

  describe 'after_save hook' do
    context 'when an application is created' do
      let(:application) { create :legal_aid_application }

      it { expect(application.used_delegated_functions).to eq false }

      context 'and the used_delegated_functions is changed and saved' do
        subject { application.save }

        before do
          application.used_delegated_functions = true
          ActiveJob::Base.queue_adapter = :test
        end

        after { ActiveJob::Base.queue_adapter = :sidekiq }

        it 'fires an ActiveSupport::Notification' do
          expect { subject }.to have_enqueued_job(Dashboard::UpdaterJob).with('Applications').at_least(1).times
        end
      end
    end
  end

  describe '#parent_transaction_types' do
    before { Populators::TransactionTypePopulator.call }
    let(:benefits) { TransactionType.find_by(name: 'benefits') }
    let(:excluded_benefits) { TransactionType.find_by(name: 'excluded_benefits') }
    let(:pension) { TransactionType.find_by(name: 'pension') }

    context 'legal aid application parent, child and stand-alone transaction types' do
      before do
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: pension
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: benefits
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: excluded_benefits
      end

      it 'returns parent and stand-alone' do
        expect(legal_aid_application.parent_transaction_types).to match_array [pension, benefits]
      end
    end

    context 'legal aid application child and stand-alone transaction types' do
      before do
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: pension
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: excluded_benefits
      end

      it 'returns parent and stand-alone' do
        expect(legal_aid_application.parent_transaction_types).to match_array [pension, benefits]
      end
    end

    context 'legal aid application parent and stand-alone transaction types' do
      before do
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: pension
        create :legal_aid_application_transaction_type, legal_aid_application: legal_aid_application, transaction_type: benefits
      end

      it 'returns parent and stand-alone' do
        expect(legal_aid_application.parent_transaction_types).to match_array [pension, benefits]
      end
    end
  end

  context 'initializing a new object' do
    it 'instantiates the default state machine' do
      expect(legal_aid_application.state_machine_proxy.type).to eq 'PassportedStateMachine'
      expect(legal_aid_application.state).to eq 'initiated'
    end
  end

  context 'advancing state' do
    it 'advances state and saves' do
      legal_aid_application.enter_applicant_details!
      expect(legal_aid_application.state).to eq 'entering_applicant_details'
    end
  end

  context 'loading an existing record and advancing state' do
    before { legal_aid_application.enter_applicant_details! }

    it 'is in the expected state and can be advanced' do
      expect(legal_aid_application.state).to eq 'entering_applicant_details'
      legal_aid_application.check_applicant_details!
      expect(legal_aid_application.state).to eq 'checking_applicant_details'
    end
  end

  context 'switching state machines' do
    it 'switches to the new state machine' do
      expect(legal_aid_application.state_machine).to be_instance_of(PassportedStateMachine)
      legal_aid_application.change_state_machine_type('NonPassportedStateMachine')
      expect(legal_aid_application.state_machine).to be_instance_of(NonPassportedStateMachine)
    end
  end

  context 'delegated state machine methods' do
    let(:application) { create :legal_aid_application, :with_passported_state_machine }

    describe '#provider_assessing_means' do
      it 'returns false' do
        expect(application.provider_assessing_means?).to be false
      end
    end
  end
end
