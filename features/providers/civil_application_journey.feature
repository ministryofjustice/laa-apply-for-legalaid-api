Feature: Civil application journeys
  @javascript
  Scenario: I am able to return to my legal aid applications
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    And I click link "Apply for legal aid"
    Then I am on the legal aid applications

  @javascript
  Scenario: I am able to select an office
    Given I am logged in as a provider
    Then I visit the select office page
    Then I choose 'London'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

  @javascript
  Scenario: I am able to confirm my office
    Given I am logged in as a provider
    Given I have an existing office
    Then I visit the confirm office page
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

  @javascript
  Scenario: I am able to change my registered office
    Given I am logged in as a provider
    Given I have an existing office
    Then I visit the confirm office page
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'office handling this application'

  @javascript @vcr
  Scenario: No results returned is seen on screen when invalid proceeding search entered
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    When the search for "cakes" is not successful
    Then the result list on page returns a "No results found." message

  @javascript @vcr
  Scenario: I am able to clear proceeding on the proceeding page
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    And I search for proceeding 'app'
    Then proceeding suggestions has results
    When I click clear search
    Then the results section is empty
    Then proceeding search field is empty

  @javascript @vcr
  Scenario: Completes the application using address lookup
    Given the setting to allow multiple proceedings is enabled
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 1 proceeding'
    Then I should be on a page showing 'Non-molestation order'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Search for legal proceedings'
    Then I search for proceeding 'non'
    Then proceeding suggestions has results
    Then I should be on a page showing 'Harassment - injunction'
    And I should be on a page not showing 'Non-molestation order'
    Then I search for proceeding 'Occupation order'
    Then proceeding suggestions has results
    Then I choose a 'Occupation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 2 proceedings'
    Then I should be on a page showing 'Non-molestation order'
    Then I should be on a page showing 'Occupation order'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I click the first link 'Remove'
    Then I click the first link 'Remove'
    Then I should be on a page showing 'Search for legal proceedings'
    Then I search for proceeding 'FGM Protection Order'
    Then proceeding suggestions has results
    Then I choose a 'FGM Protection Order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 1 proceeding'
    Then I should be on a page showing 'FGM Protection Order'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I search for proceeding 'Occupation order'
    Then proceeding suggestions has results
    Then I choose a 'Occupation order' radio button
    Then I click 'Save and continue'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I search for proceeding 'Harassment - injunction'
    Then proceeding suggestions has results
    Then I choose a 'Harassment - injunction' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 3 proceedings'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'
    Then I select 'Occupation order'
    Then I enter the 'occupation order used delegated functions on' date of 35 days ago
    Then I select 'Harassment - injunction'
    Then I enter the 'harassment injunction used delegated functions on' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Confirm when you used delegated functions"
    Then I choose a 'These dates are correct' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing 'Occupation order'
    Then I should be on a page showing 'Harassment - injunction'
    Then I should be on a page showing 'Emergency certificate'
    Then I should be on a page showing 'Substantive certificate'
    Then I should be on a page showing "Do you want to request a higher cost limit?"
    When I choose 'Yes'
    And I enter a emergency cost requested '5000'
    And I enter legal aid application emergency cost reasons field 'This is why I require extra funding'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Proceeding 1 FGM Protection Order'
    Then I should be on a page showing 'Proceeding 2 Harassment - injunction'
    Then I should be on a page showing 'Proceeding 3 Occupation order'
    Then I should not see 'Legal Aid, Sentencing and Punishment of Offenders Act'
    Then I should be on a page showing 'Delegated functions'
    Then I should be on a page showing 'FGM Protection Order Not used'
    Then I should be on a page showing 'Harassment - injunction' with a date of 2 days ago using '%-d %B %Y' format
    Then I should be on a page showing 'Occupation order' with a date of 35 days ago using '%-d %B %Y' format
    Then I should be on a page showing 'Covered under an emergency certificate'
    Then I should be on a page showing 'Covered under a substantive certificate'

  @javascript @vcr
  Scenario: Completes the application using address lookup
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Covered under a substantive certificate'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I should be on a page showing 'Is your client employed?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check if you can continue using this service"
    Then I choose 'Yes, I agree'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What your client has to do'
    Then I click link 'Continue'
    Then I should be on a page showing "Enter your client's email address"
    Then I should be on a page showing "We'll use this to send your client a link to the service."
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I click 'Send link'
    Then I am on the application confirmation page

  @localhost_request @javascript @vcr
  Scenario: Completes the application using manual address
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'XX1 1XX'
    Then I click find address
    Then I enter address line one 'Fake Road'
    Then I enter city 'Fake City'
    Then I enter postcode 'XX1 1XX'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I should be on a page showing 'Is your client employed?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check if you can continue using this service"
    Then I choose 'Yes, I agree'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What your client has to do'
    Then I click link 'Continue'
    Then I should be on a page showing "Enter your client's email address"
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I click 'Send link'
    Then I am on the application confirmation page

  @javascript @vcr
  Scenario: I can see that the applicant receives benefits
    Given I start the journey as far as the applicant page
    And a "bank holiday" exists in the database
    Then I enter name 'Test', 'Walker'
    Then I enter the date of birth '10-01-1980'
    Then I enter national insurance number 'JA293483A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'Yes'
    Then I enter the 'used delegated functions on' date of 35 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Confirm you used delegated functions on" with a date of 35 days ago using '%-d %B %Y' format
    Then I choose "This date is correct"
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click link "Back"
    Then I should be on a page showing "Confirm you used delegated functions on" with a date of 35 days ago using '%-d %B %Y' format
    Then I choose "I used delegated functions on a different date"
    Then I enter the 'used delegated functions' date of 3 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing "Covered under an emergency certificate"
    Then I should be on a page showing "Covered under a substantive certificate"
    Then I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'

  @javascript @vcr
  Scenario: I can see that the applicant does not receive benefits
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Paul'
    Then I enter the date of birth '10-12-1961'
    Then I enter national insurance number 'JA293483B'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Covered under a substantive certificate"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"

  @javascript @vcr
  Scenario: I am instructed to use CCMS on the passported journey with an applicant does not receive benefits
    When I start the journey as far as the applicant page
    Then I enter name 'Test', 'Paul'
    Then I enter the date of birth '10-12-1961'
    Then I enter national insurance number 'JA293483B'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Covered under a substantive certificate"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I should be on a page showing 'Is your client employed?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check if you can continue using this service"
    Then I choose 'Yes, I agree'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What your client has to do'
    Then I click link 'Continue'
    Then I should be on a page showing "Enter your client's email address"
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    And I click link 'Change'
    Then I should be on a page showing 'Email address'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I should be on a page showing 'test@test.com'

  @javascript @vcr
  Scenario: I am instructed to use CCMS when the applicant is not eligible
    Given I start the application with a negative benefit check result
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I should be on a page showing 'Is your client employed?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check if you can continue using this service"
    Then I choose 'No, I do not agree'
    Then I click 'Save and continue'
    Then I should be on a page showing 'You need to complete this application in CCMS'

  @javascript @vcr
  Scenario: I want to change first name from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'First name'
    Then I enter the first name 'Bartholomew'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'First name' should be 'Bartholomew'

  @javascript @vcr
  Scenario: I want to change the proceeding type from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Proceeding Type'
    And I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change address from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Address'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change address manually from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Address'
    Then I am on the postcode entry page
    Then I enter a postcode 'XX1 1XX'
    Then I click find address
    Then I enter address line one 'Fake Road'
    Then I enter city 'Fake City'
    Then I enter postcode 'XX1 1XX'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change email address from the about financial assessment page
    Given I complete the journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I should be on a page showing 'Is your client employed?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check if you can continue using this service"
    Then I choose 'Yes, I agree'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What your client has to do'
    Then I click link 'Continue'
    Then I should be on a page showing "Enter your client's email address"
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    And I click link 'Change'
    Then I should be on a page showing 'Email address'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I should be on a page showing 'test@test.com'

  @javascript @vcr
  Scenario: I am able to view the client completed means answers
    Given I start the merits application and the applicant has uploaded transaction data
    Then I should be on a page showing 'Continue your application'
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'identify_types_of_income' page showing "Which types of income does your client receive?"
    Then I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select benefits payments'
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    When I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's outgoings"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client’s bank accounts"
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "Land"
    Then I fill "Land value" with "50000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets?"
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
    Then I select 'England Infected Blood Support Scheme'
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    Then I click Check Your Answers Change link for 'Income'
    Then I should be on a page showing "Sort your client's income into categories"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing 'We need to check if'
    And I should be on a page showing 'whether or not the scheme or charity payments'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'

  @javascript @vcr
  Scenario: Completes the merits application for applicant that does not receive passported benefits
    Given I start the merits application and the applicant has uploaded transaction data
    Then I should be on a page showing 'Continue your application'
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'identify_types_of_income' page showing "Which types of income does your client receive?"
    Then I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's outgoings"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client’s bank accounts"
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing 'may need to pay towards legal aid'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    Then I fill "Full Name" with "John Doe"
    Then I choose option "Application merits task opponent understands terms of court order True field"
    Then I choose option "Application merits task opponent warning letter sent True field"
    Then I choose option "Application merits task opponent police notified True field"
    Then I choose option "Application merits task opponent bail conditions set True field"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    And I should not see "Proceedings currently before court"
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "Application merits task statement of case statement field" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page showing "Confirm the following"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And I should not see "Passported"

  @javascript @vcr
  Scenario: Receives benefits and completes the application happy path no back button
    Given I complete the passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'
    Then I click 'Continue'
    Then I should be on a page showing "Before you continue"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "How much is your client's home worth?"
    Then I fill "Property value" with "200000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I choose "Yes, a partner or ex-partner"
    Then I click 'Save and continue'
    Then I should be on a page showing "What % share of their home does your client legally own?"
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select "Current account"
    Then I fill "offline_current_accounts" with "-10"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "Money not in a bank account"
    Then I fill "Cash" with "10000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "Land"
    Then I fill "Land value" with "50000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets?"
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
    When I select 'None of these'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    Then I should be on a page showing 'We need to check if Test Walker should pay towards legal aid'
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    Then I fill "Full Name" with "John Doe"
    Then I choose option "Application merits task opponent understands terms of court order True field"
    Then I choose option "Application merits task opponent warning letter sent True field"
    Then I choose option "Application merits task opponent police notified True field"
    Then I choose option "Application merits task opponent bail conditions set True field"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "Application merits task statement of case statement field" with "Statement of case"
    Then I upload a pdf file
    Then I click 'Upload'
    Then I should not see "There was a problem uploading your file"
    Then I reload the page
    Then I should be on a page showing "hello_world.pdf"
    Then I should be on a page showing "UPLOADED"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And I click Check Your Answers Change link for 'Statement of Case'
    Then I enter the application merits task statement of case statement field 'This is some test data for the statement of case'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page showing "hello_world.pdf (15.7 KB)"
    And the answer for 'Statement of case' should be 'This is some test data for the statement of case'
    And I should be on a page showing "Confirm the following"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    Then I should be on a page showing "Passported"

  @javascript @vcr
  Scenario: Enter feedback within provider journey
    Given I start the journey as far as the applicant page
    Then I click link "feedback"
    Then I should be on a page showing "Help us improve this service"
    Then I fill "improvement suggestion" with "Foo bar"
    Then I should be on a page showing "How easy or difficult was it to use this service?"
    Then I choose "Yes"
    Then I should be on a page showing "Were you able to do what you needed today?"
    Then I choose "Easy"
    Then I choose "Satisfied"
    Then I click "Send"
    Then I should be on a page showing "Thank you for your feedback"
    Then I click link "Back to your application"
    Then I should be on the Applicant page

  @javascript
  Scenario: Complete the vehicle part of the journey
    Given I start the journey as far as the start of the vehicle section
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "What is the estimated value of the vehicle?"
    Then I fill "Estimated value" with "4000"
    And I click "Save and continue"
    Then I should be on a page showing "Are there any payments left on the vehicle?"
    Then I choose "Yes"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "Did your client buy the vehicle over 3 years ago?"
    Then I choose 'Yes'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"

  @javascript @vcr
  Scenario: Going to the search page
    Given I am logged in as a provider
    And An application has been created
    Then I visit the application service
    Then I click link "Start"
    Then I click link "Search applications"
    Then I should be on a page showing "Search applications"

  @javascript @vcr
  Scenario: Using the back button to change none_of_these checkboxes
    Given I am checking the applicant's means answers
    When I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on the "savings_and_investment" page showing "Which types of savings or investments does your client have?"
    When I select "None of these"
    And I click "Save and continue"
    And I click "Save and continue"
    Then I should be on the 'means_summary' page showing 'Check your answers'
    When I click link "Back"
    When I click link "Back"
    Then I should be on the "savings_and_investment" page showing "Which types of savings or investments does your client have?"
    When I deselect "None of these"
    And I click "Save and continue"
    Then I should be on the "savings_and_investment" page showing "Select if your client has any of these savings or investments"
    When I select "None of these"
    And I click "Save and continue"
    And I click "Save and continue"
    Then I should be on the 'means_summary' page showing 'Check your answers'
    When I click Check Your Answers Change link for 'Other assets'
    Then I should be on the "other_assets" page showing "Which types of assets does your client have?"
    When I select "None of these"
    And I click "Save and continue"
    Then I should be on a page showing "Check your answers"
    When I click link "Back"
    Then I should be on the "other_assets" page showing "Which types of assets does your client have?"
    When I deselect "None of these"
    And I click "Save and continue"
    Then I should be on the "other_assets" page showing "Select if your client has any of these types of assets"
    Then I select "None of these"
    Then I click "Save and continue"
    Then I should be on a page showing "Check your answers"
    And I click Check Your Answers Change link for 'policy disregards'
    Then I should be on a page showing 'schemes or charities'
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the answer for all 'policy disregards' categories should be 'No'
    Then I click Check Your Answers Change link for 'policy disregards'
    And I deselect 'None of these'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'Select if your client has received any of these payments'
    Then I select "None of these"
    Then I click "Save and continue"

  # I want to replace the test below with the one that is commented out
  # this test currently fails on CircleCI but passes locally
  # fails on the second call to benefitchecker with the new details
  @javascript @vcr
  Scenario: I want to change client details after a failed benefit check
    Given I start the application with a negative benefit check result
    Then I should be on a page showing "We used the following details to check your client's benefits status with the DWP"
    When I click link "Change your client's details"
    Then I should be on a page showing "Enter your client's details"
    Then I enter name 'Kyle', 'Walker'
    Then I enter the date of birth '10-1-1980'
    Then I enter national insurance number 'JA293483A'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    Then I should be on a page showing "receives benefits that qualify for legal aid"

  @javascript @vcr
  Scenario: When the DWP override is enabled, a positive benefit check result behaves as usual
    Given the setting to allow DWP overrides is enabled
    And I complete the passported journey as far as check your answers
    When I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'

  @javascript @vcr
  Scenario: When the DWP override is enabled, a negative benefit check allows the solicitor to continue without overriding the result
    Given the setting to allow DWP overrides is enabled
    And I complete the non-passported journey as far as check your answers
    When I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client does not receive a passporting benefit – is this correct?'
    Then I choose 'Yes'
    And I click 'Continue'
    Then I should be on a page showing 'Is your client employed?'

  @javascript @vcr
  Scenario: When the DWP override is enabled, a negative benefit check allows the solicitor to override the result
    Given the setting to allow DWP overrides is enabled
    And I complete the non-passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client does not receive a passporting benefit – is this correct?'
    Then I choose 'No'
    And I click 'Continue'
    Then I should be on a page showing "Check your client's details"
    Then I choose 'I need to change these details'
    And I click 'Save and continue'
    Then I should be on a page showing "Enter your client's details"
    When I click link "Back"
    Then I choose 'These details are correct'
    And I click 'Save and continue'
    Then I should be on a page showing 'Which passporting benefit does your client receive?'
    Then I choose 'None of these'
    And I click 'Save and continue'
    Then I should be on a page showing 'Is your client employed?'
    When I click link "Back"
    Then I choose 'Income Support'
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you have evidence that your client receives Income Support?'
    Then I choose "Yes"
    Then I scroll down
    Then I click 'Save and continue'
    Then I should be on a page showing 'Before you continue'
    When I click link "Back"
    Then I should be on a page showing 'Do you have evidence that your client receives Income Support?'
    Then I choose 'No'
    Then I scroll down
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client employed?'

  @javascript @vcr
  Scenario: Allows return to, and proceed from, Delegated Function date view
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'Yes'
    Then I enter the 'used delegated functions on' date of 5 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    When I click link "Back"
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
