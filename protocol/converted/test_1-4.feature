Feature: Create: PUT Turtle resources to into a deep hierarchy.

  Background: Setup
    * def testContainer = createTestContainerImmediate()

  Scenario: Test 4.1 Conflict creating /foo/bar/dahut-bc.ttl as a container
    * def requestUri = testContainer.getUrl() + 'foo/bar/dahut-bc.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#BasicContainer>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "Container Interaction Model"@en .'
    When method PUT
    Then status 409

    # Test 4.2 Resource should not have been creaed
    * def requestUri = testContainer.getUrl() + 'foo/bar/dahut-bc.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 404

    # Test 4.3 No container created: /foo
    * def requestUri = testContainer.getUrl() + 'foo'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 404

  Scenario: Test 4.4 Create RDFSource at /foo/baz/dahut-rs.ttl
    * def requestUri = testContainer.getUrl() + 'foo/baz/dahut-rs.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And header Link = '<http://www.w3.org/ns/ldp#RDFSource>; rel="type"'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "RDF source Interaction Model"@en .'
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

    # Test 4.5 Check resource exists: /foo/baz/dahut-rs.ttl
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

    # Test 4.6 Check container exists: /foo/
    * def requestUri = testContainer.getUrl() + 'foo/'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200

  Scenario: Test 4.7 Create No Interaction model resource at /foobar/baz/dahut-no.ttl
    * def requestUri = testContainer.getUrl() + 'foobar/baz/dahut-no.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('PUT', requestUri)
    And header Content-Type = 'text/turtle'
    And request '@prefix dc: <http://purl.org/dc/terms/>. <> dc:title "No Interaction Model"@en .'
    When method PUT
    Then match [200, 201, 204, 205] contains responseStatus

    # Test 4.8 Check resource exists /foobar/baz/dahut-no.ttl
    * def requestUri = testContainer.getUrl() + 'foobar/baz/dahut-no.ttl'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200
    # TODO Would the link header show RDFSource

  # Test 4.9 Check container exists: /foobar/
    * def requestUri = testContainer.getUrl() + 'foobar/'
    Given url requestUri
    And configure headers = clients.alice.getAuthHeaders('GET', requestUri)
    When method GET
    Then status 200
