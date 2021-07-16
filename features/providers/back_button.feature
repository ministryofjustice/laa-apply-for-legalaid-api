#  The test below checks the back button functionality across multiple pages
#  Introduced as a check after issues with the the use of the back button were identified
#  This test can be uncommented to be used for regression testing of the back button
#Feature: Provider journey using the back button
#  @javascript @vcr
#  Scenario: Tests the back button across multiple pages
#    Given I complete the passported journey as far as check your answers
#    Then I click 'Save and continue'
#    Then I should be on a page showing 'receives benefits that qualify for legal aid'
#    Then I click 'Continue'
#    Then I should be on a page showing "Before you continue"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Does your client own the home that they live in?"
#    Then I choose "Yes, with a mortgage or loan"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "How much is your client's home worth?"
#    Then I fill "Property value" with "200000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
#    Then I fill "Outstanding mortgage amount" with "100000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Does your client own their home with anyone else?"
#    Then I choose "Yes, a partner or ex-partner"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "What % share of their home does your client legally own?"
#    Then I fill "Percentage home" with "50"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Does your client own a vehicle?"
#    Then I choose "No"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Which bank accounts does your client have?"
#    Then I select "Current account"
#    Then I fill "offline_current_accounts" with "-10"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Which types of savings or investments does your client have?"
#    Then I select "Money not in a bank account"
#    Then I fill "Cash" with "10000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Which types of assets does your client have?"
#    Then I select "Land"
#    Then I fill "Land value" with "50000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets?"
#    Then I choose 'Yes'
#    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
#    Then I click 'Save and continue'
#    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
#    When I select 'None of these'
#    And I click 'Save and continue'
#    Then I should be on a page showing "Check your answers"
#    Then I click link "Back"
#    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
#    Then I click link "Back"
#    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets?"
#    Then I click link "Back"
#    Then I should be on a page showing "Which types of assets does your client have?"
#    Then I click link "Back"
#    Then I should be on a page showing "Which types of savings or investments does your client have?"
#    Then I click link "Back"
#    Then I should be on a page showing "Which bank accounts does your client have?"
#    Then I click link "Back"
#    Then I should be on a page showing "Does your client own a vehicle?"
#    Then I click link "Back"
#    Then I should be on a page showing "What % share of their home does your client legally own?"
#    Then I click link "Back"
#    Then I should be on a page showing "Does your client own their home with anyone else?"
#    Then I click link "Back"
#    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
#    Then I click link "Back"
#    Then I should be on a page showing "How much is your client's home worth?"
#    Then I click link "Back"
#    Then I should be on a page showing "Does your client own the home that they live in?"
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I should be on a page showing 'We need to check if Test Walker should pay towards legal aid'
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Provide details of the case"
#    Then I click 'Continue'
#    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
#    Then I enter the 'told' date of 2 days ago
#    Then I enter the 'occurred' date of 2 days ago
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Opponent details"
#    Then I fill "Full Name" with "John Doe"
#    Then I choose option "Application merits task opponent understands terms of court order True field"
#    Then I choose option "Application merits task opponent warning letter sent True field"
#    Then I choose option "Application merits task opponent police notified True field"
#    Then I choose option "Application merits task opponent bail conditions set True field"
#    Then I fill "Bail conditions set details" with "Foo bar"
#    Then I fill "Police notified details" with "Foo bar"
#    Then I click 'Save and continue'
#    And I should not see "Client received legal help"
#    Then I should be on a page showing "Provide a statement of case"
#    Then I fill "Application merits task statement of case statement field" with "Statement of case"
#    Then I upload a pdf file
#    Then I click 'Upload'
#    Then I should not see "There was a problem uploading your file"
#    Then I reload the page
#    Then I should be on a page showing "hello_world.pdf"
#    Then I should be on a page showing "UPLOADED"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
#    Then I choose "No"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "What is the chance of a successful outcome?"
#    Then I choose "Borderline"
#    Then I fill "Success prospect details" with "Prospects of success"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Check your answers"
#    And I click Check Your Answers Change link for 'Statement of Case'
#    Then I enter the application merits task statement of case statement field 'This is some test data for the statement of case'
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Check your answers"
#    Then I should be on a page showing "hello_world.pdf (15.7 KB)"
#    And the answer for 'Statement of case' should be 'This is some test data for the statement of case'
#    And I should be on a page showing "Confirm the following"
#    Then I click link "Back"
#    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
#    Then I click link "Back"
#    Then I should be on a page showing "Provide a statement of case"
#    Then I click link "Back"
#    Then I should be on a page showing "Opponent details"
#    Then I click link "Back"
#    Then I should be on a page showing "Latest incident details"
#    Then I click link "Back"
#    Then I should be on a page showing "Provide details of the case"
#    Then I click 'Continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Save and continue'
#    Then I click 'Submit and continue'
#    Then I should be on a page showing "Application complete"
#    Then I click 'View completed application'
#    Then I should be on a page showing "Application for civil legal aid certificate"
#    Then I should be on a page showing "Passported"
#
#  @javascript
#  Scenario: I want to return to applicant from Contact page
#    Given I start the journey as far as the applicant page
#    Then I click link "Contact"
#    Then I should be on a page showing "Contact us"
#    Then I click link "Back"
#    Then I should be on the Applicant page
#
#  Scenario: I navigate to Contact page from application service and back
#    Given I am logged in as a provider
#    Given I visit the application service
#    Then I click link "Contact"
#    Then I should be on a page showing "Contact us"
#    Then I click link "Back"
#    Then I should be on a page showing "Apply for legal aid"
#
#  @javascript @vcr
#  Scenario: Enter feedback within provider journey then click Back
#    Given I start the journey as far as the applicant page
#    Then I click link "feedback"
#    Then I should be on a page showing "Help us improve this service"
#    Then I fill "improvement suggestion" with "Foo bar"
#    Then I should be on a page showing "Were you able to do what you needed today?"
#    Then I choose "Yes"
#    Then I should be on a page showing "How easy or difficult was it to use this service?"
#    Then I choose "Easy"
#    Then I choose "Satisfied"
#    Then I click "Send"
#    Then I should be on a page showing "Thank you for your feedback"
#    Then I click link "Back"
#    Then I should be on the Applicant page
#
#  @javascript @vcr
#  Scenario: I want to return to the check your answers page without changing first name
#    Given I complete the journey as far as check your answers
#    And I click Check Your Answers Change link for 'First name'
#    Then I click link "Back"
#    Then I should be on a page showing 'Check your answers'
#
#  @javascript @vcr
#  Scenario: I want to return to the check your answers page without changing proceeding type
#    Given I complete the journey as far as check your answers
#    And I click Check Your Answers Change link for 'Proceeding Type'
#    And I search for proceeding 'Non-molestation order'
#    Then proceeding suggestions has results
#    Then I click link "Back"
#    Then I should be on a page showing 'Check your answers'
#
#  @javascript @vcr
#  Scenario: I want to return to check your answers from address lookup
#    Given I complete the journey as far as check your answers
#    And I click Check Your Answers Change link for 'Address'
#    Then I am on the postcode entry page
#    Then I click link "Back"
#    Then I should be on a page showing 'Check your answers'
#
#  @javascript @vcr
#  Scenario: I want to return to check your answers from address select
#    Given I complete the journey as far as check your answers
#    And I click Check Your Answers Change link for 'Address'
#    Then I am on the postcode entry page
#    Then I enter a postcode 'SW1H 9EA'
#    Then I click find address
#    Then I click link "Back"
#    Then I click link "Back"
#    Then I should be on a page showing 'Check your answers'