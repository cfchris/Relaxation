component extends="mxunit.framework.TestCase" {

	/* this will run before every single test in this test case */
	public void function setUp() {
		variables.util = new Relaxation.Relaxation.HTTPUtil();
	}
	
	/* this will run after every single test in this test case */
	public void function tearDown() {}
	
	/* this will run once after initialization and before setUp() */
	public void function beforeTests() {}
	
	/* this will run once after all tests have been run */
	public void function afterTests() {}
	
	/*
	 * TESTS
	 **/
	
	/**
	* @hint "I test getting the request headers."
	**/
	public void function test_getRequestHeaders() {
		var headers = variables.util.getRequestHeaders();
		AssertIsStruct(headers);
	}
	
	/**
	* @hint "I test getting the basic auth user/pass."
	**/
	public void function test_getBasicAuthCredentials() {
		/* Mock know state for headers. */
		InjectMethod( variables.util, this, "getBasicAuthHeaders", "getRequestHeaders" );
		/* Test with user and pass */
		var creds = variables.util.getBasicAuthCredentials();
		AssertIsStruct( creds );
		AssertEquals( "John", creds.user );
		/* Test without credentials */
		InjectMethod( variables.util, this, "returnStruct", "getRequestHeaders" );
		var creds = variables.util.getBasicAuthCredentials();
		AssertTrue( isNull(creds), "Hmmm. Creds should be null.");
	}
	
	
	/*
	 * PRIVATE UTILITY METHODS
	 **/
	
	/**
	* @hint "I return HTTP headers for testing."
	**/
	private struct function getBasicAuthHeaders() {
		return { "Authorization" = "Basic " & ToBase64("John:Doe") };
	}
	
	/**
	* @hint "I return a struct."
	**/
	private struct function returnStruct() {
		return {};
	}

}