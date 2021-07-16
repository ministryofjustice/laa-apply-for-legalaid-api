# features/step_definitions/civil_application_journey.feature

Given(/^I am logged in as a provider$/) do
  @registered_provider = create(:provider, username: 'test_provider')
  login_as @registered_provider
  firm = @registered_provider.firm
  @registered_provider.offices << create(:office, firm: firm, code: 'London')
  @registered_provider.offices << create(:office, firm: firm, code: 'Manchester')
end

Given(/^I visit the application service$/) do
  visit providers_root_path
end

Given('I visit the select office page') do
  visit providers_select_office_path
end

Given('I visit the confirm office page') do
  visit providers_confirm_office_path
end

When(/^I visit the root page/) do
  visit root_path
end

When(/^I submit to saml/) do
  find('input[name*=commit]').click
end

Given('I have an existing office') do
  office = @registered_provider.firm.offices.find_by(code: 'London')
  @registered_provider.update!(selected_office: office)
end

Given(/^I visit the applications page$/) do
  visit providers_legal_aid_applications_path
end

Given('I have previously created multiple applications') do
  provider = create(:provider)
  create_list :legal_aid_application, 3, :with_non_passported_state_machine, provider: provider
  create_list :legal_aid_application, 3, :with_passported_state_machine, :at_assessment_submitted, provider: provider
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_passported_state_machine,
    :initiated,
    provider: provider
  )
  login_as @legal_aid_application.provider
end

Given('I have created and submitted an application') do
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_passported_state_machine,
    :with_merits_submitted_at,
    :initiated,
    provider: create(:provider)
  )
  login_as @legal_aid_application.provider
end

Given('I have created but not submitted an application') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :draft,
    :initiated,
    provider: create(:provider)
  )
  login_as @legal_aid_application.provider
end

Given('I previously created a passported application and left on the {string} page') do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_passported_state_machine,
    :initiated,
    provider: create(:provider),
    provider_step: provider_step.downcase
  )
  login_as @legal_aid_application.provider
end

Given('I previously created a passported application with no assets and left on the {string} page') do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :without_own_home,
    :with_proceeding_types,
    :with_no_other_assets,
    :with_policy_disregards,
    :with_passported_state_machine,
    :checking_passported_answers,
    provider: create(:provider),
    provider_step: provider_step.downcase
  )
  login_as @legal_aid_application.provider
end

Given('I have a passported application with no assets on the {string} page') do |provider_step|
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :without_own_home,
    :with_proceeding_types,
    :with_no_other_assets,
    :with_policy_disregards,
    :with_passported_state_machine,
    :provider_entering_means,
    provider: create(:provider),
    provider_step: provider_step.downcase
  )
  login_as @legal_aid_application.provider
end

Given('the setting to allow multiple proceedings is enabled') do
  Setting.setting.update!(allow_multiple_proceedings: true)
end

Given('the setting to manually review all cases is enabled') do
  Setting.setting.update!(manually_review_all_cases: true)
end

Given('the setting to allow DWP overrides is enabled') do
  Setting.setting.update!(override_dwp_results: true)
end

Then('I choose a {string} radio button') do |radio_button_name|
  choose(radio_button_name, allow_label_click: true)
end

Given(/^I view the previously created application$/) do
  find(:xpath, "//tr[contains(.,'#{@legal_aid_application.application_ref}')]/td[1]/a").click
end

Then(/^I should not see the previously created application$/) do
  expect(page).not_to have_content(@legal_aid_application.applicant.full_name)
end

Given(/^I click delete for the previously created application$/) do
  find(:xpath, "//tr[contains(.,'#{@legal_aid_application.application_ref}')]/td/a[contains(.,'Delete')]").click
end

Given(/^I view the first application in the table$/) do
  find(:xpath, '//tr/td[1]/a').click
end

Given('I start the journey as far as the applicant page') do
  steps %(
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
  )
end

Given('I start the journey as far as the client completed means page') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_everything,
    :with_vehicle,
    :with_non_passported_state_machine,
    :provider_assessing_means
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_client_completed_means_path(@legal_aid_application))
end

Given("I am checking the applicant's means answers") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_everything,
    :with_vehicle,
    :with_non_passported_state_machine,
    :provider_assessing_means
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_means_summary_path(@legal_aid_application))
end

Given('I have completed the non-passported means assessment and start the merits assessment') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_transaction_period,
    :with_policy_disregards,
    :with_benefits_transactions
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_start_chances_of_success_path(@legal_aid_application))
end

Given('I start the merits application') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the merits application with bank transactions with no transaction type category') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_uncategorised_credit_transactions,
    :with_uncategorised_debit_transactions
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the merits application with student finance') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards,
    :with_irregular_income,
    :with_transaction_period,
    :with_uncategorised_credit_transactions
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the application with a negative benefit check result') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :applicant_details_checked,
    :with_negative_benefit_check_result
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :check_benefits,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the application with a negative benefit check result and no used delegated functions') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :applicant_details_checked,
    :with_negative_benefit_check_result
  )

  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :check_benefits,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the merits application and the applicant has uploaded transaction data') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards,
    :with_transaction_period,
    :with_benefits_transactions
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I start the journey as far as the start of the vehicle section') do
  @legal_aid_application = create(
    :application,
    :passported
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_vehicle_journey,
    legal_aid_application: @legal_aid_application
  )
end

Given('I have completed a non-passported application and reached the merits task_list') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_multiple_proceeding_types_inc_section8,
    :with_non_passported_state_machine,
    :provider_entering_merits
  )
  create :legal_framework_merits_task_list, legal_aid_application: @legal_aid_application
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_merits_task_list_path(@legal_aid_application))
end

Given('I used delegated functions') do
  @legal_aid_application.application_proceeding_types.each do |apt|
    apt.update!(used_delegated_functions_on: Date.current,
                used_delegated_functions_reported_on: Date.current)
    apt.delegated_functions_scope_limitation = apt.proceeding_type.default_delegated_functions_scope_limitation
    apt.save!
  end
end

Given('I complete the journey as far as check your answers') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'User',
    national_insurance_number: 'CB987654A',
    date_of_birth: '03-04-1999'
  )
  create(
    :address,
    address_line_one: 'Transport For London',
    address_line_two: '98 Petty France',
    city: 'London',
    postcode: 'SW1H 9EA',
    lookup_used: true,
    applicant: applicant
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :at_entering_applicant_details,
    :with_proceeding_types,
    applicant: applicant
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the journey as far as check client details with multiple proceedings selected') do
  proceeding_one = ProceedingType.find_by(code: 'PR0208')
  proceeding_two = ProceedingType.find_by(code: 'PR0214')
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :at_entering_applicant_details,
    explicit_proceeding_types: [proceeding_one, proceeding_two]
  )
  add_scope_limitations(@legal_aid_application, proceeding_one)
  add_scope_limitations(@legal_aid_application, proceeding_two)
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the passported journey as far as check your answers') do
  proceeding_one = ProceedingType.find_by(code: 'PR0208')
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'Walker',
    national_insurance_number: 'JA293483A',
    date_of_birth: '10-01-1980',
    email: 'test@test.com'
  )
  create(
    :address,
    address_line_one: 'Transport For London',
    address_line_two: '98 Petty France',
    city: 'London',
    postcode: 'SW1H 9EA',
    lookup_used: true,
    applicant: applicant
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_passported_state_machine,
    :at_entering_applicant_details,
    :with_proceeding_types,
    explicit_proceeding_types: [proceeding_one],
    applicant: applicant
  )
  add_scope_limitations(@legal_aid_application, proceeding_one)
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the multiple proceedings journey as far as check passported answers with multiple proceedings') do
  proceeding_one = ProceedingType.find_by(code: 'PR0208')
  proceeding_two = ProceedingType.find_by(code: 'PR0214')
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :provider_entering_merits,
    :with_transaction_period,
    :with_attached_statement_of_case,
    :with_chances_of_success,
    :with_gateway_evidence,
    :with_policy_disregards,
    :with_benefits_transactions,
    explicit_proceeding_types: [proceeding_one, proceeding_two]
  )

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_merits_answers_path(@legal_aid_application))

  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the non-passported journey as far as check your answers') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'Test',
    national_insurance_number: 'JA123456A',
    date_of_birth: '01-01-1970',
    email: 'test@test.com'
  )
  create(
    :address,
    address_line_one: 'Transport For London',
    address_line_two: '98 Petty France',
    city: 'London',
    postcode: 'SW1H 9EA',
    lookup_used: true,
    applicant: applicant
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_non_passported_state_machine,
    :at_entering_applicant_details,
    :with_substantive_scope_limitation,
    applicant: applicant
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the passported journey as far as capital check your answers') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'Walker',
    national_insurance_number: 'JA293483A',
    date_of_birth: '10-01-1980',
    email: 'test@test.com'
  )
  create(
    :address,
    address_line_one: 'Transport For London',
    address_line_two: '98 Petty France',
    city: 'London',
    postcode: 'SW1H 9EA',
    lookup_used: true,
    applicant: applicant
  )
  @legal_aid_application = create(
    :legal_aid_application,
    :with_everything,
    :with_proceeding_types,
    :with_passported_state_machine,
    :provider_entering_means,
    applicant: applicant
  )
  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_passported_answers_path(@legal_aid_application))
  steps %(Then I should be on a page showing 'Check your answers')
end

Given('I complete the application and view the check your answers page') do
  applicant = create(
    :applicant,
    first_name: 'Test',
    last_name: 'User',
    national_insurance_number: 'CB987654A',
    date_of_birth: '03-04-1999'
  )
  create(
    :address,
    address_line_one: 'Transport For London',
    address_line_two: '98 Petty France',
    city: 'London',
    postcode: 'SW1H 9EA',
    lookup_used: true,
    applicant: applicant
  )
  proceeding_type = ProceedingType.all.sample

  @legal_aid_application = create(
    :legal_aid_application,
    :with_non_passported_state_machine,
    :applicant_entering_means,
    :with_proceeding_types,
    applicant: applicant,
    explicit_proceeding_types: [proceeding_type]
  )
  add_scope_limitations(@legal_aid_application, proceeding_type)

  login_as @legal_aid_application.provider
  visit(providers_legal_aid_application_check_provider_answers_path(@legal_aid_application))
end

Given('The means questions have been answered by the applicant') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_proceeding_types,
    :with_non_passported_state_machine,
    :provider_assessing_means,
    :with_policy_disregards,
    :with_uncategorised_debit_transactions,
    :with_uncategorised_credit_transactions
  )
  login_as @legal_aid_application.provider
  visit Flow::KeyPoint.path_for(
    journey: :providers,
    key_point: :start_after_applicant_completes_means,
    legal_aid_application: @legal_aid_application
  )
end

Given('I add the details for a child dependant') do
  steps %(
    Then I fill "Name" with "Wednesday Adams"
    And I enter a date of birth for a 17 year old
    And I choose "They're a child relative"
    And I choose option "dependant-in-full-time-education-field"
    And I choose option "dependant-has-income-field"
    And I choose option "dependant-has-assets-more-than-threshold-field"
  )
end

Given('Bank transactions exist') do
  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  bank_account = create :bank_account, bank_provider: bank_provider
  create_list :bank_transaction, 6, :credit, bank_account: bank_account
end

Then('I click on the View statements and add transactions link for {string}') do |transaction_type_name|
  within(:css, "div#list-item-#{transaction_type_name.underscore.tr(' ', '_')}") do
    click_link 'View statements and add transactions'
  end
end

When('the search for {string} is not successful') do |proceeding_search|
  fill_in('proceeding-search-input', with: proceeding_search)
end

Then('the result list on page returns a {string} message') do |string|
  expect(page).to have_content(string)
end

Then('I visit received benefit confirmation page') do
  visit providers_legal_aid_application_received_benefit_confirmation_path(@legal_aid_application)
end

And('I search for proceeding {string}') do |proceeding_search|
  fill_in('proceeding-search-input', with: proceeding_search)
  wait_for_ajax
end

And(/^I should (see|not see) ['|"](.*?)['|"]$/) do |visibility, text|
  if visibility == 'see'
    expect(page).to have_content(/#{text}/)
  else
    expect(page).not_to have_content(text)
  end
end

When(/^I click clear search$/) do
  page.find('#clear-proceeding-search').click
end

Then(/^proceeding search field is empty$/) do
  expect(page).to have_field('proceeding-search-input', with: '')
end

Then(/^the results section is empty$/) do
  expect(page).to_not have_css('#proceeding-list > .proceeding-item')
end

Then(/^proceeding suggestions has (results|no results)$/) do |results|
  wait_for_ajax
  case results
  when 'results'
    expect(page).to have_css('#proceeding-list > .proceeding-item')
  when 'no results'
    expect(page).to_not have_css('#proceeding-list > .proceeding-item')
  end
end

Given('I click Check Your Answers Change link for {string}') do |field_name|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  within "#app-check-your-answers__#{field_name}" do
    click_link('Change')
  end
end

Given('I click Check Your Answers Change link for dependant {string}') do |dependant|
  within "#app-check-your-answers__dependants_#{dependant}" do
    click_link('Change')
  end
end

Given('I click has other dependants remove link for dependant {string}') do |dependant|
  within "#dependant_#{dependant}" do
    click_link('Remove')
  end
end

Then('I click on the add payments link for income type {string}') do |income_type|
  income_type.downcase!
  within "#income-type-#{income_type}" do
    click_link(I18n.t(".citizens.income_summary.index.select.#{income_type}"))
  end
end

Then('I click on the add payments link for outgoing type {string}') do |outgoing_type|
  outgoing_type.downcase!
  within "#list-item-#{outgoing_type}" do
    click_link(I18n.t(".citizens.outgoings_summary.index.select.#{outgoing_type}"))
  end
end

Then('the answer for {string} should be {string}') do |field_name, answer|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  expect(page).to have_css("#app-check-your-answers__#{field_name}")
  expect(page).to have_content(answer)
end

Then('the answer for all {string} categories should be {string}') do |field_name, expected_answer|
  field_name.downcase!
  field_name.gsub!(/\s+/, '_')
  wrong_answer = expected_answer == 'No' ? 'Yes' : 'No'
  within "#app-check-your-answers__#{field_name}_items" do # search within the section to check that all answers are yes/no
    expect(page).to have_text(expected_answer)
    expect(page).to_not have_text(wrong_answer)
  end
end

Then('I select a proceeding type and continue') do
  find('#proceeding-list').first(:button, 'Select and continue').click
end

Then('I choose a proceeding type {string} radio button') do |radio_button_name|
  choose(radio_button_name, allow_label_click: true)
end

Then('I select proceeding type {int}') do |index|
  find('#proceeding-list').all(:button, 'Select')[index - 1].click
end

Then('I expect to see {int} proceeding types selected') do |number|
  expect(page).to have_selector(
    '.selected-proceeding-types .selected-proceeding-type',
    count: number
  )
end

Then('I click the first {string} in selected proceeding types') do |link|
  find('.selected-proceeding-types').first(:link, link).click
end

Then(/^I see the client details page$/) do
  expect(page).to have_content("Enter your client's details")
end

Then('I should be on the Applicant page') do
  expect(page).to have_css('input#applicant-first-name-field')
end

Then('I enter name {string}, {string}') do |first_name, last_name|
  fill_in('applicant-first-name-field', with: first_name)
  fill_in('applicant-last-name-field', with: last_name)
end

Then(/^I enter the date of birth '(\d+-\d+-\d+)'$/) do |dob|
  day, month, year = dob.split('-')
  fill_in('applicant_date_of_birth_3i', with: day)
  fill_in('applicant_date_of_birth_2i', with: month)
  fill_in('applicant_date_of_birth_1i', with: year)
end

Then('I enter the email address {string}') do |email|
  field = find('input[name*=email]')[:name]
  fill_in(field, with: email)
end

Then('I enter a date of birth for a {int} year old') do |number|
  date = (number.years + 1.month).ago
  fill_in('dependant_date_of_birth_3i', with: date.day)
  fill_in('dependant_date_of_birth_2i', with: date.month)
  fill_in('dependant_date_of_birth_1i', with: date.year)
end

Then(/^I enter the purchase date '(\d+-\d+-\d+)'$/) do |purchase_date|
  day, month, year = purchase_date.split('-')
  fill_in('purchased_on', with: day)
  fill_in('purchased_on_month', with: month)
  fill_in('purchased_on_year', with: year)
end

Then('I enter the {string} date of {int} days ago') do |name, number|
  name.gsub!(/\s+/, '_')
  date = number.days.ago
  fields = page.all("input[name*=#{name}]")
  fill_in(fields[0][:name].to_s, with: date.day)
  fill_in(fields[1][:name].to_s, with: date.month)
  fill_in(fields[2][:name].to_s, with: date.year)
end

Then('I enter a {string} for a {int} year old') do |name, number|
  name.gsub!(/\s+/, '_')
  date = (number.years + 1.month).ago
  fields = page.all("input[name*=#{name}]")
  fill_in(fields[0][:name].to_s, with: date.day)
  fill_in(fields[1][:name].to_s, with: date.month)
  fill_in(fields[2][:name].to_s, with: date.year)
end

Given('a {string} exists in the database') do |model|
  model.gsub!(/\s+/, '_')
  create model.to_sym
end

Then(/^I see a notice confirming an e-mail was sent to the citizen$/) do
  expect(page).to have_content('Application completed. An e-mail will be sent to the citizen.')
end

# Matches:
#   Then I enter a field name 'entry'
#   Then I enter the field name "entry"
#   Then I enter field name 'entry'
Then(/^I enter ((a|an|the)\s)?([\w\s]+?) ["']([\w\s]+)["']$/) do |_ignore, field_name, entry|
  field_name.downcase!
  field_id = field_name.gsub(/\s+/, '-')
  field_name.gsub!(/\s+/, '_')
  name = find("input[name*=#{field_name}], ##{field_id}")[:name]
  fill_in(name, with: entry)
end

Then(/^I select the first checkbox$/) do
  page.first("input[type='checkbox']", visible: false).click
end

Then(/^I select the second checkbox$/) do
  page.find("input[type='checkbox']", visible: false)[1].click
end

Then('I check {string}') do |string|
  check string, visible: false
end

Then('I pause') do
  sleep 5
end

Then('I am on the postcode entry page') do
  expect(page).to have_content("Enter your client's correspondence address")
end

Then(/^I click find address$/) do
  click_button('Find address')
end

Then(/^I select an address '(.*)'$/) do |address|
  select(address, from: 'address_selection[lookup_id]')
end

Then('I am on the application confirmation page') do
  expect(page).to have_content('Application created')
end

Then('I am on the legal aid applications') do
  expect(page).to have_content('Your applications')
end

Then('I am on the About the Financial Assessment page') do
  expect(page).to have_content('Give your client temporary access to the service')
end

Then('I am on the check your answers page for other assets') do
  expect(page).to have_content('Check your answers')
  expect(page).to have_content('Which types of assets does your client have?')
end

Then('I am on the check your answers page for policy disregards') do
  expect(page).to have_content('Check your answers')
  expect(page).to have_content('Payments from scheme or charities')
end

Then('I am on the read only version of the check your answers page') do
  expect(page).to have_content('Home')
  expect(page).not_to have_css('.change-link')
end

Then(/^I click How we checked your client's benefits status$/) do
  page.find('#checked-status').click
end

Then('I am on the {string} page') do |string|
  expect(page).to have_content(string)
end

# rubocop:disable Lint/Debugger
Then('show me the page') do
  save_and_open_page
end

Then('wait a bit') do
  sleep 2
end
# rubocop:enable Lint/Debugger

When('I click the browser back button') do
  page.go_back
end

def add_scope_limitations(laa, ptype)
  LegalFramework::AddAssignedScopeLimitationService.call(laa, ptype, :substantive)
  LegalFramework::AddAssignedScopeLimitationService.call(laa, ptype, :delegated) if laa.used_delegated_functions?
end
