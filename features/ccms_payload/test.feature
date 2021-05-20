Feature: Civil application journeys
  @javascript
  Scenario: I am able to return to my legal aid applications
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    Then the CCMS payload skip attribute should be true
