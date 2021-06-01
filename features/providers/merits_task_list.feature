Feature: Merits task list

  @javascript @vcr
  Scenario: When the flag is enabled
    Given the feature flag for allow_multiple_proceedings is enabled
    And the method populate of ProceedingType is rerun
    And the method populate of ProceedingTypeScopeLimitation is rerun
    And I start the journey as far as the applicant page
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
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'proceedings_types' page showing 'What does your client want legal aid for?'
    Then I search for proceeding 'Child'
    Then I choose a 'Child arrangements order (residence)' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

  @javascript @vcr
  Scenario: When the flag is disabled
    Given the feature flag for allow_multiple_proceedings is disabled
    And the method populate of ProceedingType is rerun
    And the method populate of ProceedingTypeScopeLimitation is rerun
    And I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Child arrangements order'
    Then proceeding suggestions has no results
    Then I search for proceeding 'non-mol'
    Then proceeding suggestions has results
    When I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'