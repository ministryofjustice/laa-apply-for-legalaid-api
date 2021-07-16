Feature: Provider accessibility

  @javascript @vcr
  Scenario: I start a new non-passported application and enter client details
    Given I am logged in as a provider
    Then I visit the application service
    And the page is accessible
    Then I click link "Start"
    And the page is accessible
    Then I click link "Make a new application"
    And the page is accessible
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    And the page is accessible
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    And the page is accessible
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    And the page is accessible
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I should be on the 'proceedings_types' page showing 'Search for legal proceedings'
    And the page is accessible
    Then I search for proceeding 'Non-molestation order'
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    And the page is accessible
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Covered under a substantive certificate"
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    And the page is accessible

  @javascript @vcr
  Scenario: I complete the financial assessment eligibility section for a non-passported application
    Given I complete the non-passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    When I click 'Continue'
    Then I should be on a page showing 'Is your client employed?'
    And the page is accessible
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check if you can continue using this service'
    And the page is accessible
    Then I choose 'Yes, I agree'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What your client has to do'
    And the page is accessible
    Then I click link 'Continue'
    Then I should be on a page showing 'Enter your client\'s email address'
    And the page is accessible
    And I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Give your client temporary access to the service'
    And the page is accessible
    When I click 'Send link'
    Then I should be on a page showing 'Application created'
    And the page is accessible
    When I click link 'Back to your applications'
    Then I should be on a page showing 'Your applications'
    And the page is accessible

  @javascript @vcr
  Scenario: I complete the non-passported means assessment and it is accessible
    Given I start the merits application with bank transactions with no transaction type category
    Then I should be on the 'client_completed_means' page showing 'Continue your application'
    And the page is accessible
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    And the page is accessible
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of income does your client receive?"
    And the page is accessible
    Then I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And the page is accessible
    Then I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select benefits payments'
    And the page is accessible
    Then I select the first checkbox
    And I click 'Save and continue'
    Then the page is accessible
    Then I click 'Save and continue'
    Then I should be on the 'dependants' page showing "Does your client have any dependants?"
    And the page is accessible
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Enter dependant details'
    And the page is accessible
    Given I add the details for a child dependant
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client have any other dependants?"
    And the page is accessible
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's outgoings"
    And the page is accessible
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which regular payments does your client make?"
    And the page is accessible
    Then I select 'Housing payments'
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click the first link 'View statements and add transactions'
    And the page is accessible
    Then I select the first checkbox
    And I click 'Save and continue'
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    And the page is accessible
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "How much is your client's home worth?"
    And the page is accessible
    Then I fill "Property value" with "200000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    And the page is accessible
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own their home with anyone else?"
    And the page is accessible
    Then I choose "Yes, a partner or ex-partner"
    Then I click 'Save and continue'
    Then I should be on a page showing "What % share of their home does your client legally own?"
    And the page is accessible
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    And the page is accessible
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "What is the estimated value of the vehicle?"
    And the page is accessible
    Then I fill "Estimated value" with "4000"
    And I click "Save and continue"
    Then I should be on a page showing "Are there any payments left on the vehicle?"
    And the page is accessible
    Then I choose "Yes"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "Did your client buy the vehicle over 3 years ago?"
    And the page is accessible
    Then I choose 'Yes'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    And the page is accessible
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "Your client’s bank accounts"
    And the page is accessible
    Then I choose 'Yes'
    Then I should be on a page showing 'Enter the total amount in all accounts.'
    And the page is accessible
    Then I fill 'Offline savings accounts' with '3000'
    And I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    And the page is accessible
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    And the page is accessible
    Then I select "Any valuable items worth £500 or more"
    And I fill 'Valuable items value' with '600'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
    And the page is accessible
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
    Then I select 'England Infected Blood Support Scheme'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on the 'capital_income_assessment_result' page showing 'How we calculated your client\'s eligibility'
    And the page is accessible
    Then I click 'Save and continue'

  @javascript @vcr
  Scenario: I complete the client details section of a passported application and it is accessible
    Given I complete the passported journey as far as check your answers
    Then I should be on a page showing 'Check your answers'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'
    And the page is accessible

  @javascript
  Scenario: I complete the non-passported merits assessment and it is accessible
    Given I have completed the non-passported means assessment and start the merits assessment
    Then I should be on a page showing 'Provide details of the case'
    And the page is accessible
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    And the page is accessible
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    And the page is accessible
    Then I fill "Full Name" with "John Doe"
    Then I choose option "Application merits task opponent understands terms of court order True field"
    Then I choose option "Application merits task opponent warning letter sent True field"
    Then I choose option "Application merits task opponent police notified True field"
    Then I choose option "Application merits task opponent bail conditions set True field"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    And the page is accessible
    Then I fill "Application merits task statement of case statement field" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    And the page is accessible
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    And the page is accessible
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the page is accessible
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    And the page is accessible
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And the page is accessible
