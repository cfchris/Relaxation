component extends="mxunit.framework.TestCase" {

	/* this will run before every single test in this test case */
	public void function setUp() {
		variables.ConfigPath = "/Relaxation/UnitTests/RestConfig.json";
		variables.ConfigPathNoBeanFactory = "/Relaxation/UnitTests/RestConfig-NoBeanFactory.json";
		variables.RestFramework = new Relaxation.Relaxation.Relaxation(variables.ConfigPath, getBeanFactory());
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
	* @hint "I test that argument config defaults work."
	**/
	public void function argument_config_defaults_should_work() {
		var testConfig = '{
			"RequestPatterns": {
				"/product/{ProductID}/": {
					"PUT": {
						"Bean": "ProductService"
						,"Method": "updateProduct"
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = relaxationInstance.getConfig();
		
		AssertIsStruct(config.Resources[1].PUT.Arguments);
		AssertEquals('Payload', config.Resources[1].PUT.Arguments.PayloadArgument);
		AssertTrue(config.Resources[1].PUT.Arguments.MergeScopes.Path);
		AssertTrue(config.Resources[1].PUT.Arguments.MergeScopes.Payload);
		AssertTrue(config.Resources[1].PUT.Arguments.MergeScopes.URL);
		AssertTrue(config.Resources[1].PUT.Arguments.MergeScopes.Form);
	}
	
	/**
	* @hint "I test that argument config defaults work."
	**/
	public void function argument_config_top_level_should_work() {
		var testConfig = '{
			"Arguments": {
				"PayloadArgument": "TestPayloadArg"
				,"MergeScopes": {
					"Path": false
					,"Payload": false
					,"URL": false
					,"Form": false
				}
			}
			,"RequestPatterns": {
				"/product/{ProductID}/": {
					"PUT": {
						"Bean": "ProductService"
						,"Method": "updateProduct"
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = relaxationInstance.getConfig();
		
		AssertIsStruct(config.Resources[1].PUT.Arguments);
		AssertEquals('TestPayloadArg', config.Resources[1].PUT.Arguments.PayloadArgument);
		AssertFalse(config.Resources[1].PUT.Arguments.MergeScopes.Path);
		AssertFalse(config.Resources[1].PUT.Arguments.MergeScopes.Payload);
		AssertFalse(config.Resources[1].PUT.Arguments.MergeScopes.URL);
		AssertFalse(config.Resources[1].PUT.Arguments.MergeScopes.Form);
	}
	
	/**
	* @hint "I test that argument config defaults work."
	**/
	public void function argument_config_verb_level_should_work() {
		var testConfig = '{
			"Arguments": {
				"PayloadArgument": "TestPayloadArg"
				,"MergeScopes": {
					"Path": true
					,"Payload": true
					,"URL": true
				}
			}
			,"RequestPatterns": {
				"/product/{ProductID}/": {
					"PUT": {
						"Bean": "ProductService"
						,"Method": "updateProduct"
						,"Arguments": {
							"PayloadArgument": "Product"
							,"MergeScopes": {
								"Payload": false
							}
						}
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = relaxationInstance.getConfig();
		
		AssertIsStruct(config.Resources[1].PUT.Arguments);
		AssertEquals('Product', config.Resources[1].PUT.Arguments.PayloadArgument);
		AssertTrue(config.Resources[1].PUT.Arguments.MergeScopes.Path);
		AssertFalse(config.Resources[1].PUT.Arguments.MergeScopes.Payload);
		AssertTrue(config.Resources[1].PUT.Arguments.MergeScopes.URL);
		AssertTrue(config.Resources[1].PUT.Arguments.MergeScopes.Form);
	}
	
	/**
	* @hint "I test that the payload argument is used to build arguments."
	**/
	public void function argument_merge_config_works_when_building_arguments() {
		var testConfig = '{
			"RequestPatterns": {
				"/widget/{WidgetID}/something": {
					"POST": {
						"Bean": "WidgetService"
						,"Method": "addSomething"
						,"Arguments": {
							"MergeScopes": {
								"Path": true
								,"Payload": true
								,"URL": true
								,"Form": true
							}
						}
					}
				}
				,"/product": {
					"POST": {
						"Bean": "ProductService"
						,"Method": "addProduct"
						,"Arguments": {
							"MergeScopes": {
								"Path": false
								,"Payload": false
								,"URL": false
								,"Form": false
							}
						}
					}
				}
				,"/product/{ProductID}/": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "getProductByID"
					}
					,"PUT": {
						"Bean": "ProductService"
						,"Method": "updateProduct"
						,"Arguments": {
							"MergeScopes": {
								"Payload": false
							}
						}
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = relaxationInstance.getConfig();
		
		/* Make method for finding the correct config and building args public. */
		makePublic(relaxationInstance,"findResourceConfig");
		makePublic(relaxationInstance,"gatherRequestArguments");
		
		/* Test widget POST arg merging. */
		var Match = relaxationInstance.findResourceConfig("/widget/999/something","POST");
		var args = relaxationInstance.gatherRequestArguments(ResourceMatch = Match, RequestBody = '{"isActive":true, "color":"red"}', URLScope = {"urlArg":1}, FormScope = {"formArg":2} );
		AssertIsStruct(args);
		AssertTrue(StructKeyExists(args,"WidgetID"), 'Missing "WidgetID" path key in args.');
		AssertTrue(StructKeyExists(args,"isActive"), 'Missing "isActive" payload key in args.');
		AssertTrue(StructKeyExists(args,"urlArg"), 'Missing "urlArg" URL key in args.');
		AssertTrue(StructKeyExists(args,"formArg"), 'Missing "formArg" FORM key in args.');
		
		/* Test product POST arg merging. */
		var Match = relaxationInstance.findResourceConfig("/product","POST");
		var args = relaxationInstance.gatherRequestArguments(ResourceMatch = Match, RequestBody = '{"isActive":true, "color":"red"}', URLScope = {"urlArg":1}, FormScope = {"formArg":2} );
		AssertIsStruct(args);
		/* The config for this resource+verb is to NOT merge any scopes. */
		AssertEquals(2, ListLen(StructKeyList(args)));
		AssertTrue(ListFindNoCase(StructKeyList(args),"ArgumentSources"));
		AssertTrue(ListFindNoCase(StructKeyList(args),"Payload"));
	}
	
	/**
	* @hint "I test that the Authorization hook works."
	**/
	public void function authorization_hook_should_work() {
		
		/* First test without an Authorization Method. */
		var result = variables.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(true, result.Success);
		
		/* Second, test with an auth method that WILL authorize. */
		variables.RestFramework.setAuthorizationMethod( returnTrue );
		var result = variables.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(true, result.Success);
		
		/* Third, test with an auth method that WON'T authorize. */
		variables.RestFramework.setAuthorizationMethod( returnFalse );
		var result = variables.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(false, result.Success);
		assertEquals("NotAuthorized", result.Error);
	}
	
	/**
	* @hint "I test the BasicAuthCheckMethod."
	**/
	public void function basic_auth_hook_should_work() {
		/* Mock httpUtil methods needed for this scenario. */
		var httpUtil = mock();
		httpUtil.promptForBasicAuth("{string}").returns();
		httpUtil.getBasicAuthCredentials().returns();
		variables.RestFramework.setHTTPUtil( httpUtil );
		
		/* Test first with NO auth method. */
		var result = variables.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		
		/* Test with an auth method that WILL authenticate. */
		variables.RestFramework.setBasicAuthCheckMethod( returnTrue );
		var result = variables.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		
		/* Test with an auth method that WON'T authenticate. */
		variables.RestFramework.setBasicAuthCheckMethod( returnFalse );
		var result = variables.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		
		/* Test that having method set triggers call to httputil.getBasicAuthCredentials(). */
		httpUtil.verifyTimes(2).getBasicAuthCredentials();
		
		/* Test that processing two requests only calls promptForBasicAuth once (for the time where the mock returned false). */
		httpUtil.verifyTimes(1).promptForBasicAuth("{string}");
	}
	
	/**
	* @hint "I test all of the different styles of Config args."
	**/
	public void function different_config_types_should_work() {
		makePublic(variables.RestFramework,"translateConfig");
		/* Test with the non-expanded path. */
		var config = variables.RestFramework.translateConfig( variables.ConfigPath );
		assertIsStruct(config);
		assertIsStruct(config.RequestPatterns);
		assertTrue(structKeyExists(config.RequestPatterns,"/product"),"The (/product) resource was not defined in the config.");
		/* Test with the expanded path. */
		var config = variables.RestFramework.translateConfig( expandPath(variables.ConfigPath) );
		assertIsStruct(config);
		assertIsStruct(config.RequestPatterns);
		assertTrue(structKeyExists(config.RequestPatterns,"/product"),"The (/product) resource was not defined in the config.");
		/* Test with a JSON string. */
		var config = variables.RestFramework.translateConfig( fileRead(expandPath(variables.ConfigPath)) );
		assertIsStruct(config);
		assertIsStruct(config.RequestPatterns);
		assertTrue(structKeyExists(config.RequestPatterns,"/product"),"The (/product) resource was not defined in the config.");
		/* Test with a struct. */
		var config = variables.RestFramework.translateConfig( getFrameworkConfig() );
		assertIsStruct(config);
		assertIsStruct(config.RequestPatterns);
		assertTrue(structKeyExists(config.RequestPatterns,"/product"),"The (/product) resource was not defined in the config.");
	}
	
	/**
	* @hint "I test that a valid exception is thrown if an invalid config is supplied."
	**/
	public void function expect_invalidpath_config_exception() {
		expectException("Relaxation.Config.InvalidPath");
		makePublic(variables.RestFramework,"translateConfig");
		/* Test with a BAD path. */
		var config = variables.RestFramework.translateConfig( "/THIS/BAD/PATH" );
	}
	
	/**
	* @hint "I test findResourceConfig in the positive sense."
	**/
	public void function findResourceConfig_should_find_existing_configs() {
		makePublic(variables.RestFramework,"findResourceConfig");
		/* Test static URL. */
		var match = variables.RestFramework.findResourceConfig( "/product/colors", "GET" );
		assertIsStruct(match);
		assertEquals(true, match.located);
		assertEquals("ProductService", match.Bean);
		assertEquals("getProductColors", match.Method);
		assertEquals("GET,OPTIONS", match.AllowedVerbs);
		/* Test dynamic URL. */
		var match = variables.RestFramework.findResourceConfig( "/product/1", "GET" );
		assertIsStruct(match);
		assertEquals(true, match.located);
		assertEquals("ProductService", match.Bean);
		assertEquals("getProductByID", match.Method);
		assertEquals("GET,OPTIONS,POST", match.AllowedVerbs);
		/* Test deeper dynamic URL. */
		var match = variables.RestFramework.findResourceConfig( "/product/1/colors", "GET" );
		assertIsStruct(match);
		assertEquals(true, match.located);
		assertEquals("ProductService", match.Bean);
		assertEquals("getProductColorsByProduct", match.Method);
	}
	
	/**
	* @hint "I test findResourceConfig in the negative sense."
	**/
	public void function findResourceConfig_should_not_find_nonexisting_configs() {
		makePublic(variables.RestFramework,"findResourceConfig");
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
	**/
	public void function gatherRequestArguments_should_work() {
		makePublic(variables.RestFramework,"findResourceConfig");
		makePublic(variables.RestFramework,"gatherRequestArguments");
		var URLScope = {"URLTestArg" = "urltestvalue", "PriorityTestArg" = "From URL"};
		var FormScope = {"FormTestArg" = "formtestvalue", "PriorityTestArg" = "From Form"};
		var RequestBody = '{"BodyTestArg": "bodytestvalue", "AnotherArgument": "AnotherTestValue", "PriorityTestArg": "From Body"}';
		var RequestBodyValues = DeserializeJSON(RequestBody);
		var Match = variables.RestFramework.findResourceConfig("/product/321/colors/red/priority/from-uri","POST");
		var args = variables.RestFramework.gatherRequestArguments(ResourceMatch = Match, RequestBody = RequestBody, URLScope = URLScope, FormScope = FormScope );
		assertIsStruct(args);
		assertIsStruct(args.ArgumentSources);
		assertIsStruct(args.ArgumentSources.URLScope);
		assertIsStruct(args.ArgumentSources.FormScope);
		assertIsStruct(args.ArgumentSources.PathValues);
		/* Confirm body args are in "payload". */
		assertEquals(RequestBodyValues.BodyTestArg, args.payload.BodyTestArg);
		assertEquals(RequestBodyValues.AnotherArgument, args.payload.AnotherArgument);
		/* Confirm body args are also in the root (Only works if it's a JSON object). */
		assertEquals(RequestBodyValues.BodyTestArg, args.BodyTestArg);
		assertEquals(RequestBodyValues.AnotherArgument, args.AnotherArgument);
		/* Confirm that the correct value for the priority test arg was set. */
		assertEquals("from-uri", args.PriorityTestArg);
		/* Confirm misc values are correct. */
		assertEquals(URLScope.URLTestArg, args.URLTestArg);
		assertEquals(321, args.ProductID);
		assertEquals("red", args.Color);
		assertEquals(FormScope.FormTestArg, args.FormTestArg);
		
		/* LEGACY: Run a request that has "DefaultArguments" configured. */
		var Match = variables.RestFramework.findResourceConfig("/product/all-active","GET");
		var args = variables.RestFramework.gatherRequestArguments(ResourceMatch = Match, RequestBody = "", URLScope = {}, FormScope = {} );
		assertEquals(1, args.Active);
		assertEquals('Available', args.Status);
		
		/* Run a request that has "Arguments.Defaults" configured. */
		var Match = variables.RestFramework.findResourceConfig("/product/inactive","GET");
		var args = variables.RestFramework.gatherRequestArguments(ResourceMatch = Match, RequestBody = "", URLScope = {}, FormScope = {} );
		assertEquals(0, args.Active);
	}
	
	/**
	* @hint "I test handleRequest."
	**/
	public void function handleRequest_should_work() {
		var httpUtil = variables.RestFramework.getHTTPUtil();
		injectMethod(local.httpUtil, this, "doNothing", "setResponseStatus");
		/* Test good response */
		var result = variables.RestFramework.handleRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertIsStruct(result);
		assertEquals(true, result.Success);
		assertEquals(true, result.Rendered);
		/* Test bad response */
		result = variables.RestFramework.handleRequest( Path = "/product/this/will/never/work", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertIsStruct(result);
		assertEquals(false, result.Success);
		assertEquals(true, result.Rendered);
	}
	
	/**
	* @hint "I test that the JSONP callback is applied when specified."
	**/
	public void function jsonp_config_is_applied_when_appropriate() {
		var testConfig = '{
			"JSONP": {
				"enabled": true
			}
			,"RequestPatterns": {
				"/product/": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getAllProducts"
					}
				}
			}
		}';
		var instance = new Relaxation.Relaxation.Relaxation(testConfig);
		instance.setBeanFactory( getBeanFactory() );
		instance.setHttpUtil( getHttpUtil() );
		
		/* Test a call without asking for JSONP. */
		var jsonResult = instance.processRequest( 
			Path = '/product/',
			Verb = 'GET',
			RequestBody = '', URLScope = {}, FormScope = {}
		);
		AssertTrue( isJSON(jsonResult.Output) );
		
		/* Test a call requesting JSONP. */
		var jsonResult = instance.processRequest(
			Path = '/product/',
			Verb = 'GET',
			RequestBody = '', URLScope = {"jsonp"="myJSFunction"}, FormScope = {}
		);
		AssertTrue( ReFindNoCase("^myJSFunction\(", jsonResult.Output) );
	}
	
	/**
	* @hint "I test that jsonp default configuration is applied appropriately."
	**/
	public void function jsonp_default_config_is_applied_correctly() {
		var testConfig = '{
			"RequestPatterns": {
				"/product/": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getAllProducts"
					}
				}
			}
		}';
		var instance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = instance.getConfig();
		
		assertFalse(config.Resources[1].GET.JSONP.enabled);
		assertFalse(StructKeyExists(config.Resources[1].GET.JSONP, "callbackParameter"), "callbackParameter key should not exist when the setting is not enabled.");
	}
	
	/**
	* @hint "I test that jsonp manual configuration is applied appropriately."
	**/
	public void function jsonp_manual_config_is_applied_correctly() {
		/* Example config with param specified at the top and overwritten for resources. */
		var testConfig = '{
			"JSONP": {
				"enabled": false
				,"callbackParameter": "topLevelCB"
			}
			,"RequestPatterns": {
				"/product/": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "getAllProducts"
					}
				}
				,"/product/{ProductID}/": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "getProductByID"
						,"JSONP": {
							"enabled": true
						}
					}
				}
				,"/product/type": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "getProductTypes"
						,"JSONP": {
							"enabled": true
							,"callbackParameter": "getLevelCB"
						}
					}
				}
			}
		}';
		var instance = new Relaxation.Relaxation.Relaxation(testConfig);
		MakePublic(instance, "findResourceConfig", "findResourceConfig");
		
		var config = instance.findResourceConfig( '/product/', 'GET' );
		assertFalse(config.JSONP.enabled);
		assertFalse(StructKeyExists(config.JSONP, "callbackParameter"), "callbackParameter key should not exist when the setting is not enabled.");
		
		var config = instance.findResourceConfig( '/product/123', 'GET' );
		assertTrue(config.JSONP.enabled);
		assertEquals('topLevelCB', config.JSONP.callbackParameter);
		
		var config = instance.findResourceConfig( '/product/type/', 'GET' );
		assertTrue(config.JSONP.enabled);
		assertEquals('getLevelCB', config.JSONP.callbackParameter);
	}
	
	/**
	* @hint "I test that the payload argument is used to build arguments."
	**/
	public void function payload_argument_is_applied_when_building_arguments() {
		var testConfig = '{
			"RequestPatterns": {
				"/widget": {
					"POST": {
						"Bean": "WidgetService"
						,"Method": "addWidget"
					}
				}
				,"/product": {
					"POST": {
						"Bean": "ProductService"
						,"Method": "addProduct"
						,"Arguments": {
							"PayloadArgument": "NewProduct"
						}
					}
				}
				,"/product/{ProductID}/": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "getProductByID"
					}
					,"PUT": {
						"Bean": "ProductService"
						,"Method": "updateProduct"
						,"Arguments": {
							"PayloadArgument": "ExistingProduct"
						}
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = relaxationInstance.getConfig();
		
		/* Make method for finding the correct config and building args public. */
		makePublic(relaxationInstance,"findResourceConfig");
		makePublic(relaxationInstance,"gatherRequestArguments");
		
		/* Test widget POST arg mapping. */
		var Match = relaxationInstance.findResourceConfig("/widget","POST");
		var args = relaxationInstance.gatherRequestArguments(ResourceMatch = Match, RequestBody = '{"isActive":true, "color":"red"}', URLScope = {}, FormScope = {} );
		AssertIsStruct(args);
		AssertTrue(StructKeyExists(args,"Payload"), "Could not find expected arg key.");
		AssertIsStruct(args.Payload);
		AssertEquals("red", args.Payload.color);
		
		/* Test product POST arg mapping. */
		var Match = relaxationInstance.findResourceConfig("/product","POST");
		var args = relaxationInstance.gatherRequestArguments(ResourceMatch = Match, RequestBody = '{"isActive":true, "color":"red"}', URLScope = {}, FormScope = {} );
		AssertIsStruct(args);
		AssertFalse(StructKeyExists(args,"Payload"), "Payload key found. It should not be there.");
		AssertTrue(StructKeyExists(args,"NewProduct"), "Could not find expected arg key.");
		AssertIsStruct(args.NewProduct);
		AssertEquals("red", args.NewProduct.color);
		
		/* Test product item PUT arg mapping. */
		var Match = relaxationInstance.findResourceConfig("/product/123","PUT");
		var args = relaxationInstance.gatherRequestArguments(ResourceMatch = Match, RequestBody = '{"isActive":true, "color":"red"}', URLScope = {}, FormScope = {} );
		AssertIsStruct(args);
		AssertFalse(StructKeyExists(args,"Payload"), "Payload key found. It should not be there.");
		AssertTrue(StructKeyExists(args,"ExistingProduct"), "Could not find expected arg key.");
		AssertIsStruct(args.ExistingProduct);
		AssertEquals("red", args.ExistingProduct.color);
	}
	
	/**
	* @hint "I test processRequest."
	**/
	public void function processRequest_should_work() {
		var result = variables.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertIsStruct(result);
		assertTrue(!StructIsEmpty(result), "Shoot. The return struct is empty.");
		assertEquals(true, result.Success);
		assertTrue(isJSON(result.Output),"Shoot result was not JSON.");
		assertTrue(FindNoCase("Hot Sauce!",result.Output),"Part of the JSON string that should be there IS NOT.");
		/* Test empty response */
		result = variables.RestFramework.processRequest( Path = "/product/do/nothing", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertIsStruct(result);
		assertTrue(!StructIsEmpty(result), "Shoot. The return struct is empty.");
		assertEquals(true, result.Success);
		assertEquals("", result.Output);
	}
	
	/**
	* @hint "I test processRequest WITHOUT a BeanFactory."
	**/
	public void function processRequest_should_work_without_BeanFactory() {
		/* Create new instance with NO bean factory. */
		var RestFramework = new Relaxation.Relaxation.Relaxation(variables.ConfigPathNoBeanFactory);
		/* Test regular get. */
		var result = local.RestFramework.processRequest( Path = "/product/1", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertIsStruct(result);
		assertTrue(!StructIsEmpty(result), "Shoot. The return struct is empty.");
		assertEquals(true, result.Success);
		assertTrue(isJSON(result.Output),"Shoot result was not JSON.");
		assertTrue(FindNoCase("Hot Sauce!",result.Output),"Part of the JSON string that should be there IS NOT.");
	}
	
	/**
	* @hint "I test that throwing specific errorcodes are mapped to specific http status codes."
	**/
	public void function thrown_errors_should_map_correctly() {
		var httpUtil = getHttpUtil();
		variables.RestFramework.setHTTPUtil( httpUtil );
		
		/* Mock a known request state to test status code mapping. */
		InjectMethod( variables.RestFramework, this, 'return403Result', 'processRequest' );
		/* Call handleRequest. */
		var result = variables.RestFramework.handleRequest( '/na' );
		httpUtil.verify().setResponseStatus(403, 'Forbidden');
		AssertEquals(return403Result().ErrorMessage, result.response.responseText);
		
		/* Mock a known request state to test status code mapping. */
		InjectMethod( variables.RestFramework, this, 'return404Result', 'processRequest' );
		/* Call handleRequest. */
		var result2 = variables.RestFramework.handleRequest( '/na' );
		httpUtil.verify().setResponseStatus(404, 'Not Found');
		AssertEquals(return404Result().ErrorMessage, result2.response.responseText);
	}
	
	/**
	 * @hint I test that the WrapSimpleValues portion of the configuration works properly
	 **/
	public void function wrap_simple_values_config_should_work() {
		var testConfig = '{
			"WrapSimpleValues": {
				"enabled": true,
				"objectProperty": "requestResult"
			},
			"RequestPatterns": {
				"/product/{ProductID}/": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductByID",
						"WrapSimpleValues": {
							"enabled": false
						}
					},
					"PUT": {
						"Bean": "ProductService",
						"Method": "updateProduct",
						"WrapSimpleValues": {
							"objectProperty": "id"
						}
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = relaxationInstance.getConfig();

		assertFalse(config.Resources[1].GET.WrapSimpleValues.enabled);
		assertEquals('requestResult', config.Resources[1].GET.WrapSimpleValues.objectProperty);
		
		assertTrue(config.Resources[1].PUT.WrapSimpleValues.enabled);
		assertEquals('id', config.Resources[1].PUT.WrapSimpleValues.objectProperty);
	}
	
	/**
	 * @hint I test that the WrapSimpleValues portion of the configuration works properly
	 **/
	public void function wrap_simple_values_default_config_should_work() {
		var testConfig = '{
			"RequestPatterns": {
				"/product/{ProductID}/": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductByID",
						"WrapSimpleValues": {
							"enabled": false
						}
					},
					"PUT": {
						"Bean": "ProductService",
						"Method": "updateProduct",
						"WrapSimpleValues": {
							"objectProperty": "id"
						}
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig);
		var config = relaxationInstance.getConfig();

		assertFalse(config.Resources[1].GET.WrapSimpleValues.enabled);
		assertEquals(relaxationInstance.getDefaults().WrapSimpleValues.objectProperty, config.Resources[1].GET.WrapSimpleValues.objectProperty);
		
		assertTrue(config.Resources[1].PUT.WrapSimpleValues.enabled);
		assertEquals('id', config.Resources[1].PUT.WrapSimpleValues.objectProperty);
	}
	
	/**
	 * @hint I test that top-level WrapSimpleValues settings properly cascace into verb-level ones
	 **/
	public void function wrap_simple_values_top_settings_should_affect_behavior() {
		var defaultObjectProperty = "requestResult";
		
		var testConfig = '{
			"WrapSimpleValues": {
				"enabled": true,
				"objectProperty": "#defaultObjectProperty#"
			},
			"RequestPatterns": {
				"/product/{ProductID}/": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductByID",
						"WrapSimpleValues": {
							"enabled": false
						}
					},
					"PUT": {
						"Bean": "ProductService",
						"Method": "saveProduct",
						"WrapSimpleValues": {
							"objectProperty": "id"
						}
					}
				},
				"/product/{ProductID}/price": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductPrice",
						"WrapSimpleValues": {
							"enabled": true
						}
					}
				},
				"/product/{ProductID}/price/raw": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductPrice",
						"WrapSimpleValues": {
							"enabled": false
						}
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig, getBeanFactory());
		
		// test simple value wrapping behavior
		result = local.relaxationInstance.processRequest( Path = "/product/1/price", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(serializeJson({"#defaultObjectProperty#":"$7.99"}), result.output);

		// test the legacy behavior of returning the raw simple value
		result = local.relaxationInstance.processRequest( Path = "/product/1/price/raw", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals('"$7.99"', result.output);
	}
	
	/**
	 * @hint I test that top-level WrapSimpleValues settings properly cascace into verb-level ones
	 **/
	public void function wrap_simple_values_default_settings_should_affect_behavior() {
		var testConfig = '{
			"RequestPatterns": {
				"/product/{ProductID}/": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductByID",
						"WrapSimpleValues": {
							"enabled": false
						}
					},
					"PUT": {
						"Bean": "ProductService",
						"Method": "saveProduct",
						"WrapSimpleValues": {
							"objectProperty": "id"
						}
					}
				},
				"/product/{ProductID}/price": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductPrice",
						"WrapSimpleValues": {
							"enabled": true
						}
					}
				},
				"/product/{ProductID}/price/raw": {
					"GET": {
						"Bean": "ProductService",
						"Method": "getProductPrice",
						"WrapSimpleValues": {
							"enabled": false
						}
					}
				}
			}
		}';
		var relaxationInstance = new Relaxation.Relaxation.Relaxation(testConfig, getBeanFactory());
		var defaultObjectProperty = relaxationInstance.getDefaults().WrapSimpleValues.objectProperty;
		
		// test simple value wrapping behavior
		result = local.relaxationInstance.processRequest( Path = "/product/1/price", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals(serializeJson({"#defaultObjectProperty#":"$7.99"}), result.output);

		// test the legacy behavior of returning the raw simple value
		result = local.relaxationInstance.processRequest( Path = "/product/1/price/raw", Verb = "GET", RequestBody = "", URLScope = {}, FormScope = {});
		assertEquals('"$7.99"', result.output);
	}
	
	
	
	/*
	 * PRIVATE UTILITY METHODS
	 **/
	
	/**
	* @hint "I return a mock BeanFactory for testing."
	**/
	private any function getBeanFactory() {
		var bf = Mock();
		var service = new Relaxation.UnitTests.ProductService();
		bf.getBean('ProductService').returns( service );
		return bf;
	}
	
	/**
	* @hint "I return a mock httpUtil for testing."
	**/
	private any function getHttpUtil() {
		var httpUtil = mock();
		httpUtil.setResponseHeader('{string}', '{string}').returns();
		httpUtil.setResponseContentType('{string}').returns();
		httpUtil.setResponseStatus(403, 'Forbidden').returns();
		httpUtil.setResponseStatus(404, 'Not Found').returns();
		return httpUtil;
	}
	
	/**
	* @hint "I get the test Rest Framework config"
	**/
	private struct function getFrameworkConfig() {
		return DeserializeJSON(fileRead(expandPath(variables.ConfigPath)));
	}
	
	/**
	* @hint "I return a result that should trigger a 403."
	**/
	private struct function return403Result() {
		var result = {
			"Success" = false
			,"Output" = ""
			,"Error" = "NotAuthorized"
			,"ErrorMessage" = "You can't touch this!"
			,"AllowedVerbs" = ""
			,"CacheHeaderSeconds" = ""
		};
		return result;
	}
	
	/**
	* @hint "I return a result that should trigger a 404."
	**/
	private struct function return404Result() {
		var result = {
			"Success" = false
			,"Output" = ""
			,"Error" = "ResourceNotFound"
			,"ErrorMessage" = "Where's the beef!"
			,"AllowedVerbs" = ""
			,"CacheHeaderSeconds" = ""
		};
		return result;
	}
	
	/**
	* @hint "I return false."
	**/
	private boolean function returnFalse() {
		return false;
	}
	
	/**
	* @hint "I return true."
	**/
	private boolean function returnTrue() {
		return true;
	}
	
	/**
	* @hint "I do nothing."
	**/
	private void function doNothing() {
		/* Do nothing. */
	}

}