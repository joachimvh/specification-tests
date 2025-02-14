@parallel=false
Feature: With and without trailing slash cannot co-exist

  Background: Set up clients and paths
    * def testContainer = createTestContainer()
    * configure followRedirects = false

  Scenario: PUT container, then try resource with same name
    * def childContainerUrl = testContainer.getUrl() + 'foo/'
    Given url childContainerUrl
    And configure headers = clients.alice.getAuthHeaders('PUT', childContainerUrl)
    And header Content-Type = 'text/turtle'
    When method PUT
    Then assert responseStatus >= 200 && responseStatus < 300

    * def resourceUrl = testContainer.getUrl() + 'foo'
    Given url resourceUrl
    And configure headers = clients.alice.getAuthHeaders('GET', resourceUrl)
    When method GET
    * print response
    Then match [301, 404, 410] contains responseStatus

    Given url resourceUrl
    And configure headers = clients.alice.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = 'text/plain'
    And request "Hello"
    When method PUT
     # See https://www.rfc-editor.org/rfc/rfc7231.html#page-27 for why 409 or 415
    Then match [409, 415] contains responseStatus


  Scenario: PUT resource, then try container with same name
    * def resourceUrl = testContainer.getUrl() + 'foo'
    Given url resourceUrl
    And configure headers = clients.alice.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = 'text/plain'
    And request "Hello"
    When method PUT
    Then assert responseStatus >= 200 && responseStatus < 300

    * def childContainerUrl = testContainer.getUrl() + 'foo/'
    Given url childContainerUrl
    And configure headers = clients.alice.getAuthHeaders('GET', childContainerUrl)
    When method GET
    Then match [301, 404, 410] contains responseStatus

    * def childContainerUrl = testContainer.getUrl() + 'foo/'
    Given url childContainerUrl
    And configure headers = clients.alice.getAuthHeaders('PUT', childContainerUrl)
    And header Content-Type = 'text/turtle'
    When method PUT
     # See https://www.rfc-editor.org/rfc/rfc7231.html#page-27 for why 409 or 415
    Then match [409, 415] contains responseStatus

# TODO: Evil test to check various suffices.





