Feature: Bob can only read an RDF resource to which he is only granted default read access via the parent

  Background: Create test resource with default read-only access for Bob
    * def setup =
    """
      function() {
        const testContainer = createTestContainerImmediate();
        const access = testContainer.getAccessDatasetBuilder(webIds.alice)
              .setInheritableAgentAccess(testContainer.getUrl(), webIds.bob, ['read'])
              .build();
        karate.log('ACL:\n' + access.asTurtle());
        testContainer.setAccessDataset(access);
        return testContainer.createChildResource('.ttl', karate.readAsString('../fixtures/example.ttl'), 'text/turtle');
      }
    """
    * def resource = callonce setup
    * assert resource.exists()
    * def resourceUrl = resource.getUrl()
    * url resourceUrl

  Scenario: Bob can read the resource with GET
    Given headers clients.bob.getAuthHeaders('GET', resourceUrl)
    When method GET
    Then status 200

  Scenario: Bob can read the resource with HEAD
    Given headers clients.bob.getAuthHeaders('HEAD', resourceUrl)
    When method HEAD
    Then status 200

  Scenario: Bob cannot PUT to the resource
    Given request '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .'
    And headers clients.bob.getAuthHeaders('PUT', resourceUrl)
    And header Content-Type = 'text/turtle'
    When method PUT
    Then status 403

  Scenario: Bob cannot PATCH the resource
    Given request 'INSERT DATA { <> a <http://example.org/Foo> . }'
    And headers clients.bob.getAuthHeaders('PATCH', resourceUrl)
    And header Content-Type = 'application/sparql-update'
    When method PATCH
    Then status 403

  Scenario: Bob cannot POST to the resource
    Given request '<> <http://www.w3.org/2000/01/rdf-schema#comment> "Bob replaced it." .'
    And headers clients.bob.getAuthHeaders('POST', resourceUrl)
    And header Content-Type = 'text/turtle'
    When method POST
    Then status 403

  Scenario: Bob cannot DELETE the resource
    Given headers clients.bob.getAuthHeaders('DELETE', resourceUrl)
    When method DELETE
    Then status 403
