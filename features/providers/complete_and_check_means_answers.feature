Feature: Completing and checking means answers backwards and forwards

  @javascript
  Scenario: I select some outgoing transaction types and then remove them
    Given The means questions have been answered by the applicant
    Then I should be on a page showing 'Continue your application'
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's outgoings"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which regular payments does your client make?"
    Then I select 'Housing payments'
    Then I select 'Payments towards legal aid in a criminal case'
    Then I click 'Save and continue'
    Then I should be on a page showing "Sort your client's regular payments into categories"
    Then I should be on a page showing "Housing payments"
    Then I should be on a page showing "Payments towards legal aid in a criminal case"
    Then I click link 'Add another type of regular payment'
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Sort your client's regular payments into categories"
    Then I should be on a page not showing "Housing payments"
    Then I should be on a page not showing "Payments towards legal aid in a criminal case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"

  @javascript @vcr
  Scenario: I navigate to the Check your answers page and then add some outgoing transaction types
    Given The means questions have been answered by the applicant
    Then I should be on a page showing 'Continue your application'
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    Then I choose "Yes"
    Then I click 'Save and continue'
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
    When I select 'England Infected Blood Support Scheme'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    Then I click Check Your Answers Change link for 'Outgoings'
    Then I should be on a page showing "Sort your client's regular payments into categories"
    Then I click link 'Add another type of regular payment'
    Then I should be on a page showing 'Which regular payments does your client make?'
    Then I select 'Payments towards legal aid in a criminal case'
    Then I click 'Save and continue'
    Then I should be on a page showing "Sort your client's regular payments into categories"
    Then I should be on a page showing "Payments towards legal aid in a criminal case"
    Then I click link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

  @javascript
  Scenario: I change the applicant answer about having any dependants to Yes and add dependants
    Given I am checking the applicant's means answers
    Then the answer for 'dependants' should be 'No'
    Then I click Check Your Answers Change link for 'dependants'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I add the details for a child dependant
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I fill "Name" with "Granny Addams"
    And I enter a date of birth for a 80 year old
    When I choose "They're an adult relative"
    And I choose option "dependant-in-full-time-education-field"
    And I choose option "dependant-has-income-true-field"
    And I fill "monthly income" with "4321"
    And I choose option "dependant-has-assets-more-than-threshold-true-field"
    And I fill "assets value" with "8765"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And I should see 'Dependant 1'
    And I should see 'Dependant 2'
    And the answer for 'dependants' should be 'Yes'

  @javascript
  Scenario: I change the applicant answer about having any dependants to No
    Given I am checking the applicant's means answers
    Then the answer for 'dependants' should be 'No'
    Then I click Check Your Answers Change link for 'dependants'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I add the details for a child dependant
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And I should see 'Dependant 1'
    And the answer for 'dependants' should be 'Yes'
    When I click Check Your Answers Change link for 'dependants'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And I should not see 'Dependant 1'
    And the answer for 'dependants' should be 'No'

  @javascript
  Scenario: I change the applicant answer about owning a vehicle
    Given I am checking the applicant's means answers
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I should be on a page showing 'Does your client own a vehicle?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I change the applicant answers about details of their vehicle
    Given I am checking the applicant's means answers
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I choose 'Yes'
    Then I click 'Save and continue'
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
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I change the applicant answers about offline savings accounts
    Given I am checking the applicant's means answers
    Then I should be on a page showing 'Has savings accounts they cannot access online'
    And I should be on a page showing 'Amount in offline savings accounts'
    And the answer for 'has offline savings' should be 'Yes'
    Then I click Check Your Answers Change link for 'offline savings accounts'
    Then I should be on the 'applicant_bank_account' page showing 'Does your client have any savings accounts they cannot access online?'
    And I should be on a page showing 'Enter the total amount in all accounts.'
    Then I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And the answer for 'has offline savings' should be 'No'
    And I should not see 'Amount in offline savings accounts'

  @javascript
  Scenario: I go back and change the answer to second home from the means summary page
    Given I am checking the applicant's means answers
    Then I should be on a page showing 'Which types of assets does your client have?'
    And I should be on a page showing 'Second property or holiday home estimated value'
    Then I click Check Your Answers Change link for 'other assets'
    And I should be on a page showing 'Which types of assets does your client have?'
    And I should be on a page showing 'Select all that apply'
    Then I deselect 'Second property or holiday home'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And the answer for 'Second home' should be 'No'
    And I should not see 'Second property or holiday home estimated value'

