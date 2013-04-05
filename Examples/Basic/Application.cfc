component output="false" {
	
	this.name = "RelaxationBasicTest";
	
	/**
	* @hint "I handle the start of requests. (Make sure Relaxation is setup.)"
	* @output true
	**/
	public function onRequestStart() {
		if ( isDefined("url.Reinit") || isNull(application.Relaxation) ) {
			var Relaxation = new com.Relaxation.Relaxation( "./RestConfig.json.cfm" ).setBeanFactory( new TestFactory() );
			application.Relaxation = Relaxation;
		}
	}
	
	/**
	* @hint "I handle requests. (Route requests using Relaxation.)"
	* @output true
	**/
	public void function onRequest() {
		var result = application.Relaxation.handleRequest( CGI.PATH_INFO );
		getpagecontext().getresponse().setcontenttype('application/json');
		if ( result.Success ) {
			writeOutput( result.Output );
		} else {
			writeOutput( SerializeJSON(result) );
		}
	}
	
}