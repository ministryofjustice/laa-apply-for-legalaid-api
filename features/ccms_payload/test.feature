Feature: Civil application journeys
  @javascript
  Scenario: I am able to return to my legal aid applications
    Given I start the application with a negative benefit check result
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then The case should be flagged for manual review
