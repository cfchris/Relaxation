component output="false" {
	
	this.name = "RelaxationBasicTest";
	
	/**
	* @hint "I handle the start of requests. (Make sure Relaxation is setup.)"
	* @output true
	**/
	public function onRequestStart() {
		if ( isDefined("url.Reinit") || isNull(application.REST) ) {
			var Relaxation = new Relaxation.Relaxation.Relaxation( "./RestConfig.json.cfm" );
			Relaxation.setBeanFactory( new TestFactory() );
			application.REST = Relaxation;
		}
	}
	
	/**
	* @hint "I handle requests. (Route requests using Relaxation.)"
	* @output true
	**/
	public void function onRequest() {
		var result = application.REST.handleRequest();
		getpagecontext().getresponse().setcontenttype('application/json');
		if ( result.Success ) {
			writeOutput( result.Output );
		} else {
			writeOutput( SerializeJSON(result) );
		}
	}
	
}