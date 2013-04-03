component output="false" {
	
	this.name = "RelaxationBasicTest";
	
	public function onRequestStart() {
		if ( isDefined("url.Reinit") || isNull(application.Relaxation) ) {
			var Relaxation = new com.Relaxation.Relaxation( getRESTConfig() ).setBeanFactory( new TestFactory() );
			application.Relaxation = Relaxation;
		}
	}
	
	/**
	* @hint "I handle requests."
	* @output true
	**/
	public void function onRequest() {
		var result = application.Relaxation.handleRequest( CGI.PATH_INFO );
		getpagecontext().getresponse().getresponse().setcontenttype('application/json');
		if ( result.Success ) {
			writeOutput( result.Output );
		} else {
			writeOutput( SerializeJSON(result) );
		}
	}
	
	/**
	* @hint "I get the test rest framework config"
	* @output false
	**/
	private struct function getRESTConfig() {
		return {
			"RequestPatterns": {
				"/product": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "GetAllProducts"
					}
				}
				,"/product/{ProductID}": {
					"GET": {
						"Bean": "ProductService"
						,"Method": "GetProductByID"
					}
				}
			}
		};
	}
	
}