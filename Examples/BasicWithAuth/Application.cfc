component output="false" {
	
	this.name = hash( getCurrentTemplatePath() );
	this.ApplicationTimeout = CreateTimeSpan(0,0,30,0);
	
	/**
	* @hint "I handle the Application Start event."
	**/
	public boolean function onApplicationStart() {
		try {
			application.BeanFactory = new Relaxation.Examples.Basic.TestFactory();
			var Relaxation = new Relaxation.Relaxation.Relaxation( "/Relaxation/Examples/Basic/RestConfig.json.cfm" );
			Relaxation.setBeanFactory( application.BeanFactory );
			Relaxation.setOnErrorMethod( handleError );
			Relaxation.setAuthorizationMethod( handleAuth );
			application.REST = Relaxation;
			return true;
		}
		catch ( any e ) {
			return false;
		}
	}
	
	/**
	* @hint "I handle the start of requests. (Make sure Relaxation is setup.)"
	**/
	public function onRequestStart() {
		if ( isDefined("url.Reinit") || isNull(application.REST) ) {
			onApplicationStart();
		}
	}
	
	/**
	* @hint "I handle requests. (Route requests using Relaxation.)"
	**/
	public void function onRequest() {
		var auth = application.REST.getHTTPUtil().getBasicAuthCredentials();
		if ( IsNull(auth) || !(auth.user == "Maxin" && auth.password == "Relaxin") ) {
			application.REST.getHTTPUtil().promptForBasicAuth( "API Demo" );
		} else {
			application.REST.handleRequest();
		}
	}
	
	/**
	* @hint "I handle errors."
	**/
	private void function handleError(Any e) {
		application.BeanFactory.getBean("ErrorLogger").logError( arguments.e );
		return;
	}
	
	private boolean function handleAuth(resource) {
		return true;
	}
	
}