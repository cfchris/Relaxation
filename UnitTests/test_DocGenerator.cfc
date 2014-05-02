component extends="mxunit.framework.TestCase" {

	/* this will run before every single test in this test case */
	public void function setUp() {
		variables.ConfigPath = "/Relaxation/UnitTests/RestConfig.json";
		variables.Framework = new Relaxation.Relaxation.Relaxation(variables.ConfigPath, getBeanFactory());
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
	* @hint "I test that getFullMeta works."
	**/
	public void function test_getFullMeta() {
		var DocGen = variables.Framework.getDocGenerator();
		var docMeta = DocGen.getFullMeta();
		//debug(docMeta);
		assertIsArray(docMeta);
		assertTrue(ArrayLen(docMeta) GT 1, "Shoot! We didn't get a populated array.'");
		assertIsStruct(docMeta[1]);
		assertTrue(StructKeyExists(docMeta[1],'pattern'), "Shoot! There is no 'pattern' key.");
		assertTrue(StructKeyExists(docMeta[1],'verbs'), "Shoot! There is no 'pattern' key.");
	}
	
	/**
	* @hint "I test that getFunctionMeta works."
	**/
	public void function test_getFunctionMeta() {
		var DocGen = variables.Framework.getDocGenerator();
		/* Test with function with very little specified. */
		var meta = DocGen.getFunctionMeta(minimalMetaForTest);
		assertIsStruct(meta);
		assertEquals('minimalMetaForTest', meta.name);
		assertEquals('private', meta.access);
		assertEquals('any', meta.returntype);
		assertEquals('', meta.hint);
		assertEquals(0, ArrayLen(meta.parameters));
		/* Test with function with everything specified. */
		var meta = DocGen.getFunctionMeta(fullMetaForTest);
		assertIsStruct(meta);
		//debug(meta);
		assertEquals('fullMetaForTest', meta.name);
		assertEquals('private', meta.access);
		assertEquals('boolean', meta.returntype);
		assertEquals('Function for metadata test.', meta.hint);
		assertEquals(2, ArrayLen(meta.parameters));
		/* Test with arg with everything specified */
		assertEquals('Arg1', meta.parameters[1].name);
		assertTrue(meta.parameters[1].required);
		assertEquals('string', meta.parameters[1].type);
		assertEquals('val1', meta.parameters[1]['default']); /* Seriously? WTF CF10? */
		/* Test with arg with very little specified */
		assertEquals('Arg2', meta.parameters[2].name);
		assertFalse(meta.parameters[2].required);
		assertEquals('any', meta.parameters[2].type);
	}
	
	/**
	* @hint "I test getResourceMeta."
	**/
	public void function test_getResourceMeta() {
		var DocGen = variables.Framework.getDocGenerator();
		var Config = variables.Framework.getConfig();
		//debug(config);
		/* Test on first resource. (Should be '/product') */
		var meta = DocGen.getResourceMeta(Config.Resources[1]);
		//debug(meta);
		assertIsStruct(meta);
		assertEquals('/product', meta.pattern);
		assertIsArray(meta.verbs);
		assertEquals(1, ArrayLen(meta.verbs));
		assertEquals('GET', meta.verbs[1].verb);
		assertEquals('I return the test products', meta.verbs[1].hint);
		assertEquals('array', meta.verbs[1].returntype);
		assertIsArray(meta.verbs[1].parameters);
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
	* @hint "Function for metadata test."
	**/
	private boolean function fullMetaForTest( required string Arg1 = "val1", Arg2 ) {
		return true;
	}
	/* No hint. Minimal meta info. */
	private function minimalMetaForTest() {}

}