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
			/*
			 * Setting the Basic Auth Check Method will enable Basic Auth requirement.
			 * If method returns false, Relaxation will promt http client for basic auth credentials.
			 */
			Relaxation.setBasicAuthCheckMethod( handleBasicAuth );
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
		application.REST.handleRequest();
	}
	
	/**
	* @hint "I handle checking basic auth creds."
	**/
	private boolean function handleBasicAuth( required struct Credentials, struct ResourceInfo ) {
		if ( arguments.ResourceInfo.Pattern == '/product/' && arguments.ResourceInfo.Verb == 'GET' ) {
			/* GET /product is not secured. */
			return true;
		}
		if ( !arguments.Credentials.Specified ) {
			/* No basic auth header was provided. */
			return false;
		}
		/* Basic auth provided. Test against credential store. */
		return application.BeanFactory.getBean("Security").isAuthenticated( arguments.Credentials.User, arguments.Credentials.Password );
	}
	
	/**
	* @hint "I handle errors."
	**/
	private void function handleError(Any e) {
		application.BeanFactory.getBean("ErrorLogger").logError( arguments.e );
		return;
	}
	
}