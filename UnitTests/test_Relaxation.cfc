component extends="mxunit.framework.TestCase" {

	/* this will run before every single test in this test case */
	public void function setUp() {
		variables.RestFramework = new Relaxation.Relaxation.Relaxation(getFrameworkConfig());
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
	* @hint "I test findResourceConfig in the positive sense."
	* @output false
	**/
	public void function findResourceConfig_should_find_existing_configs() {
		var match = variables.RestFramework.findResourceConfig( "/product/1/colors", "GET" );
		//debug(match);
		assertIsStruct(match);
		assertTrue(!StructIsEmpty(match), "Shoot. The return struct is empty.");
		assertEquals(true, match.located);
		assertEquals("ProductService", match.Bean);
		assertEquals("GetProductColors", match.Method);
	}
	
	/**
	* @hint "I test findResourceConfig in the negative sense."
	* @output false
	**/
	public void function findResourceConfig_should_not_find_nonexisting_configs() {
		/* Ask for config for non-existing resource. */
		var match = variables.RestFramework.findResourceConfig( "/NON/EXISTING/PATH", "GET" );
		assertIsStruct(match);
		assertTrue(!StructIsEmpty(match), "Shoot. The return struct is empty.");
		assertEquals(false, match.located);
		assertEquals("ResourceNotFound", match.error);
		/* Ask for config for existing resource and non-existing verb. */
		var match2 = variables.RestFramework.findResourceConfig( "/product", "PUT" );
		assertIsStruct(match2);
		assertTrue(!StructIsEmpty(match2), "Shoot. The return struct is empty.");
		assertEquals(false, match2.located);
		assertEquals("VerbNotFound", match2.error);
	}
	
	/**
	* @hint "I test gatherRequestArguments."
	* @output false
	**/
	public void function gatherRequestArguments_should_work() {
		var URLScope = {"URLTestArg": "urltestvalue"};
		var FormScope = {"FormTestArg": "formtestvalue"};
		var RequestBody = '{"BodyTestArg": "bodytestvalue", "AnotherArgument": "AnotherTestValue"}';
		var Match = {
			"Path": "/product/321/colors/red/"
			,"Pattern": "/product/{ProductID}/colors/{Color}/"
			,"Regex": "^/product/([^/]+?)/colors/([^/]+?)/$"
		};
		var args = variables.RestFramework.gatherRequestArguments(ResourceMatch = Match, RequestBody = RequestBody, URLScope = URLScope, FormScope = FormScope );
		//debug(args);
		assertIsStruct(args);
		assertTrue(!StructIsEmpty(args), "Shoot. The return struct is empty.");
		assertEquals(URLScope.URLTestArg, args.URLTestArg);
		assertEquals(FormScope.FormTestArg, args.FormTestArg);
		assertEquals("bodytestvalue", args.BodyTestArg);
		assertEquals(321, args.ProductID);
		assertEquals("red", args.Color);
	}
	
	/**
	* @hint "I test handleRequest."
	* @output false
	**/
	public void function handleRequest_should_work() {
		variables.RestFramework.setBeanFactory( getBeanFactory() );
		var result = variables.RestFramework.handleRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		//debug(result);
		assertIsStruct(result);
		assertTrue(!StructIsEmpty(result), "Shoot. The return struct is empty.");
		assertEquals(true, result.Success);
		assertTrue(isJSON(result.Output),"Shoot result was not JSON.");
		assertTrue(FindNoCase("Relaxation REST Framework",result.Output),"Part of the JSON string that should be there IS NOT.");
	}
	
	/**
	* @hint "I test that the Authorization hook works."
	* @output false
	**/
	public void function authorization_hook_should_work() {
		variables.RestFramework.setBeanFactory( getBeanFactory() );
		
		/* First test without an Authorization Method. */
		var result = variables.RestFramework.handleRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(true, result.Success);
		
		/* Second, test with an auth method that WILL authorize. */
		variables.RestFramework.setAuthorizationMethod(
			function( struct Resource ) {
				debug(Resource);
				return true;
			}
		);
		var result = variables.RestFramework.handleRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(true, result.Success);
		
		/* Third, test with an auth method that WON'T authorize. */
		variables.RestFramework.setAuthorizationMethod(
			function( struct Resource ) {
				debug(Resource);
				return false;
			}
		);
		var result = variables.RestFramework.handleRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(false, result.Success);
		assertEquals("NotAuthorized", result.Error);
	}
	
	/*
	 * PRIVATE UTILITY METHODS
	 **/
	
	/**
	* @hint "I return a mock BeanFactory for testing."
	* @output false
	**/
	private any function getBeanFactory() {
		var bf = 
			Mock()
				.getBean('ProductService').returns(
					{
						"GetProductByID": function( string ProductID ) {
							if ( arguments.ProductID == 1 ) {
								return {
									"ProductID": 1
									,"Name": "Relaxation REST Framework"
									,"DateCreated": "April 1st 2013"
								};
							} else {
								return {
									"ProductID": ""
									,"Name": "Undefined"
									,"DateCreated": ""
								};
							}
						}
					}
				);
		return bf;
	}
	
	/**
	* @hint "I get the test Rest Framework config"
	* @output false
	**/
	private struct function getFrameworkConfig() {
		var config = 
		{
			"ReturnFormat": "JSON"
			,"RequestPatterns": {
				"/product": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "GetAllProducts"
					}
					,"POST": {
						"Bean": "ProductService"
						,"Method": "SaveProduct"
					}
				}
				,"/product/{ProductID}": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "GetProductByID"
					}
					,"POST": {
						"Bean": "ProductService"
						,"Method": "SaveProduct"
					}
				}
				,"/product/{ProductID}/colors": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "GetProductColors"
					}
				}
				,"/product/type": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "GetProductTypes"
					}
				}
			}
		};
		return config;
	}

}