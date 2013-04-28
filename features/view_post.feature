Feature: View posts
  In order to show a site's content
  Users should be able to
  View a specific post's page

  Scenario: View a post
    Given there is a post in section blog named test1 
    When I attempt to access the post
    Then I am shown the post

  Scenario: Attempt to view a post that does not exist
    Given there is not a post in section blog named mystery_post 
    When I attempt to access the post
    Then I am shown file not found 

  Scenario: View index for a section
    Given a section named blog with posts best_post, second_best, ok_post
    When I visit the section's index
    Then I am provided links to the section's entries 
    And I am provided with their summaries

  Scenario: Attempt to view an indec for a section that does not exist
    Given there is not a section named foo
    When I visit the section's index
    Then I am shown file not found
