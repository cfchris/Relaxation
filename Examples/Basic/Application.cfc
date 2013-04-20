component output="false" {
	
	this.name = "RelaxationBasicTest";
	
	/**
	* @hint "I handle the start of requests. (Make sure Relaxation is setup.)"
	* @output true
	**/
	public function onRequestStart() {
		if ( isDefined("url.Reinit") || isNull(application.REST) ) {
			var Relaxation = new Relaxation.Relaxation.Relaxation( "./RestConfig.json.cfm", new TestFactory() );
			Relaxation.setOnErrorMethod( handleError );
			application.REST = Relaxation;
		}
	}
	
	/**
	* @hint "I handle requests. (Route requests using Relaxation.)"
	* @output true
	**/
	public void function onRequest() {
		application.REST.handleRequest();
	}
	
	/**
	* @hint "I handle errors. (By doing nothing.)"
	* @output false
	**/
	private void function handleError(Any e) {
		return;
	}
	
}