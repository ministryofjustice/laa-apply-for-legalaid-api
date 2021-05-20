Feature: Citizen journey
  @javascript
  Scenario: Start citizen journey until TrueLayer Auth
    Given An application has been created
    And a "true layer bank" exists in the database
    Then I visit the start of the financial assessment
    Then I should be on a page showing 'Your legal aid application'
    Then I click link 'Start'
    Then I should be on a page showing 'Do you agree to share 3 months of bank statements with the LAA via TrueLayer?'
    Then I choose 'Yes'
    Then I click 'Continue'
    Then I should be on a page showing 'Select your bank'
    Then I should be on a page showing "Select one bank at a time. You'll be able to select more later if you have accounts with different banks."
    Then I click link "Back"
    Then I should be on a page showing 'Do you agree to share 3 months of bank statements with the LAA via TrueLayer?'
    Then I choose 'No'
    Then I click 'Continue'
    Then I should be on a page showing 'Contact your solicitor to continue your application'
    Then I click link "Back"
    Then I should be on a page showing 'Do you agree to share 3 months of bank statements with the LAA via TrueLayer?'
    Then I choose 'Yes'
    Then I click 'Continue'
    Then I choose 'HSBC'
    Then I click 'Continue'
    Then I am directed to TrueLayer

  @javascript @vcr
  Scenario: View privacy policy
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I should not see 'Sign In'
    Then I click link "Privacy policy"
    Then I should be on a page showing "Types of personal data we process"
    Then I should be on a page showing "Complaints"
    Then I click link "Back"
    Then I should be on a page showing 'Your legal aid application'

  @javascript @vcr
  Scenario: Follow citizen journey from Accounts page selecting no income or outgoing categories
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I visit the accounts page
    Then I click link 'Continue'
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "Yes"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you have current accounts you cannot access online?'
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Contact your solicitor'
    Then I click link "Back"
    Then I should be on a page showing 'Do you have current accounts you cannot access online?'
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Select your bank"
    Then I click link "Back"
    Then I click link "Back"
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which of the following payments do you receive?"
    And I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on the 'student_finance' page showing 'Do you get student finance?'
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'annual_amount' page showing 'How much student finance will you get this academic year?'
    When I enter amount '5000'
    And I click 'Save and continue'
    Then I should be on a page showing "Which of the following payments do you make?"
    And I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page not showing 'Excluded Benefits'
    Then I should be on a page showing "Confirm the following"
    Then I click "Agree and submit"
    Then I should be on a page showing "You've shared your financial information"
    Then I click link "feedback"
    Then I should be on a page showing "How easy or difficult was it to use this service?"

  @javascript @vcr
  Scenario: Follow citizen journey from Accounts page selecting both income and outgoing categories
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I visit the accounts page
    Then I click link 'Continue'
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "Yes"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you have current accounts you cannot access online?'
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Contact your solicitor'
    Then I click link "Back"
    Then I should be on a page showing 'Do you have current accounts you cannot access online?'
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Select your bank"
    Then I click link "Back"
    Then I click link "Back"
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which of the following payments do you receive?"
    And I select 'Benefits'
    Then I click 'Save and continue'
    Then I should be on the 'cash_income' page showing 'Select payments you receive in cash'
    Then I select 'Benefits'
    Then I enter benefits1 '100'
    Then I enter benefits2 '100'
    Then I enter benefits3 '100'
    And I click 'Save and continue'
    Then I should be on the 'student_finance' page showing 'Do you get student finance?'
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'annual_amount' page showing 'How much student finance will you get this academic year?'
    When I enter amount '5000'
    And I click 'Save and continue'
    Then I should be on a page showing "Which of the following payments do you make?"
    Then I select "Housing payments"
    Then I click 'Save and continue'
    Then I should be on the 'cash_outgoing' page showing 'Select payments you make in cash'
    Then I select 'Housing payments'
    Then I enter rent_or_mortgage1 '100'
    Then I enter rent_or_mortgage2 '100'
    Then I enter rent_or_mortgage3 '100'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page not showing 'Excluded Benefits'
    Then I should be on a page showing "Confirm the following"
    Then I click "Agree and submit"
    Then I should be on a page showing "You've shared your financial information"
    Then I click link "feedback"
    Then I should be on a page showing "How easy or difficult was it to use this service?"

  @javascript
  Scenario: I want to change income types via the check your answers page
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Benefits'
    And I click Check Your Answers Change link for 'incomings'
    Then I should be on a page showing 'Which of the following payments do you receive?'
    Then I select 'Maintenance payments'
    And I click 'Save and continue'
    Then I should be on the 'cash_income' page showing 'Select payments you receive in cash'
    Then I select 'Maintenance payments'
    Then I enter maintenance_in1 '100'
    Then I enter maintenance_in2 '100'
    Then I enter maintenance_in3 '100'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Maintenance payments from a former partner Yes'

  @javascript
  Scenario: I want to add another bank account via the check your answers page
    # TODO: Expand this feature
    # It should really do both:
    # 1) actually handle the true layer interaction and
    # 2) demonstrate the check_answer routing.
    # It currently only manages 2)
    Given I have completed an application
    And a "true layer bank" exists in the database
    And I complete the citizen journey as far as check your answers
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page not showing 'Account 2'
    When I visit the gather transactions page
    Then I should be on the 'accounts' page showing 'Your bank accounts'
    When I click link 'Continue'
    Then I should be on a page showing 'Check your answers'
