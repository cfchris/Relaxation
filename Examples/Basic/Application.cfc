component output="false" {
	
	this.name = "RelaxationBasicTest";
	
	/**
	* @hint "I handle the start of requests. (Make sure Relaxation is setup.)"
	* @output true
	**/
	public function onRequestStart() {
		if ( isDefined("url.Reinit") || isNull(application.REST) ) {
			application.BeanFactory = new TestFactory();
			var Relaxation = new Relaxation.Relaxation.Relaxation( "./RestConfig.json.cfm" );
			Relaxation.setBeanFactory( application.BeanFactory );
			Relaxation.setOnErrorMethod( handleError );
			Relaxation.setAuthorizationMethod( handleAuth );
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
	* @hint "I handle errors."
	* @output false
	**/
	private void function handleError(Any e) {
		application.BeanFactory.getBean("ErrorLogger").logError( arguments.e );
		return;
	}
	
	private boolean function handleAuth(resource) {
		return true;
	}
	
}