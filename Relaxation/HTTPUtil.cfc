component
	accessors="true"
	displayname="HTTP request / response utilities"
	hint="I am a collection of methods to help manipulate http requests."
	output="false"
{
	
	/**
	* @hint "I will return a date in the correct format for http headers."
	**/
	public string function formatHTTPDate(required date Date) {
		return DateFormat(arguments.Date,"ddd, dd mmm yyyy") & TimeFormat(arguments.Date,"HH:nn:ss") & ' GMT';
	}
	
	/**
	* @hint "I return a struct containing the user and password decoded from the Authorization header."
	**/
	public any function getBasicAuthCredentials() {
		try {
			var auth = ToString(ToBinary(ListRest(getRequestHeaders().Authorization, " ")));
			return {
				"user" = ListFirst(auth,":"),
				"password" = ListRest(auth,":")
			};
		}
		catch ( any e ) {
			return JavaCast("null", "");
		}
	}
	
	/**
	* @hint "I return the HTTP headers for the current request."
	**/
	public struct function getRequestHeaders() {
		return GetHTTPRequestData().Headers;
	}
	
	/**
	* @hint "I will set appropriate response headers to prompt clients for basic auth credentials."
	**/
	public void function promptForBasicAuth( string Realm = "REST API" ) {
		setResponseHeader( "WWW-Authenticate", 'basic realm="' & arguments.Realm & '"' );
		setResponseStatus( 401, "Unauthorized" );
	}
	
	/**
	* @hint "I set response content type."
	**/
	public void function setResponseContentType( required string ContentType ) {
		getpagecontext().getresponse().setContentType(JavaCast("string",arguments.ContentType));
	}
	
	/**
	* @hint "I set response headers."
	**/
	public void function setResponseHeader( required string Header, string HeaderText = "" ) {
		getpagecontext().getResponse().setHeader(JavaCast("string",arguments.Header), JavaCast("string",arguments.HeaderText));
	}
	
	/**
	* @hint "I set response status headers."
	**/
	public void function setResponseStatus( required numeric Status, string StatusText = "" ) {
		getpagecontext().getResponse().setStatus(JavaCast("int",arguments.Status), JavaCast("string",arguments.StatusText));
	}
	
	/**
	 * @hint I build an array of possible HTTP request methods and return it
	 **/
	 public array function getPossibleRequestMethods() {
	 	return [
	 		"OPTIONS",
			"GET",
			"HEAD",
			"POST",
			"PUT",
			"DELETE",
			"TRACE",
			"CONNECT"
		];
	}
}