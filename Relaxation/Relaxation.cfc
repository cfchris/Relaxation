component
	accessors="true"
	displayname="Relaxation REST Framework"
	hint="I am the Relaxation framework for REST in CF. Relax, I got this!"
{

	property name="AuthorizationMethod" type="any";
	property name="BeanFactory" type="component";
	property name="cfmlFunctions" type="component";
	property name="DocGenerator" type="component";
	property name="HTTPUtil" type="component";
	property name="OnErrorMethod" type="any";
	
	variables.Config = {};
	variables.Defaults = {
		"WrapSimpleValues" = {
			"enabled" = "true",
			"objectProperty" = "result"
		}
	};
	
	/**
	* @hint "I initialize the object and get the routing all setup."
	**/
	public component function init( required any Config, component BeanFactory, any AuthorizationMethod, any OnErrorMethod ) {
		/* Set object to handle CFML stuff. */
		setcfmlFunctions( new cfmlFunctions() );
		/* Set object to handle HTTP response stuff. */
		setHTTPUtil( new HTTPUtil() );
		/* Set object to handle Doc Gen stuff. */
		var dc = new DocGenerator();
		dc.setRelaxation( this );
		setDocGenerator( dc );
		if ( structKeyExists(arguments,'BeanFactory') ) {
			setBeanFactory( arguments.BeanFactory );
		}
		if ( structKeyExists(arguments,'AuthorizationMethod') ) {
			setAuthorizationMethod( arguments.AuthorizationMethod );
		}
		if ( structKeyExists(arguments,'OnErrorMethod') ) {
			setOnErrorMethod( arguments.OnErrorMethod );
		}
		/* Deal with different types of configs passed in. */
		arguments.Config = translateConfig( arguments.Config );
		/* Store raw config. */
		variables.Config.raw = arguments.Config;
		/* Get the pattern matching for resources setup. */
		configureResources( arguments.Config );
		/* Always return the object. */
		return this;
	}
	
	/**
	* @hint "I return the configuration structure."
	**/
	public struct function getConfig() {
		return variables.Config;
	}
	
	/**
	* @hint "I return the defaults structure."
	**/
	public struct function getDefaults() {
		return variables.Defaults;
	}
	
	/**
	* @hint "I will handle a REST request including appropriate output and headers."
	**/
	public struct function handleRequest( string Path = CGI.PATH_INFO ) {
		/* Handle requests to the root of the API. */
		if ( ListLast(arguments.Path,"/") EQ 'index.cfm' OR reReplace(arguments.Path, "/$", "") EQ "" ) {
			/* No resource path specified. Show available resources. */
			getDocGenerator().renderDocs();
		}
		/* Process the request. */
		var result = processRequest( ArgumentCollection = arguments );
		/* Deal with rendering the result. */
		if ( result.Success ) {
			/* Happiness, the request was successful! */
			variables.HTTPUtil.setResponseHeader('Allow', result.AllowedVerbs);
			if ( len(trim(result.CacheHeaderSeconds)) ) {
				/* Add cache headers. */
				var httpnow = DateConvert('local2Utc',now());
				var httpexpires = DateAdd('s',val(result.CacheHeaderSeconds),httpnow);
				variables.HTTPUtil.setResponseHeader('Cache-Control', "max-age=" & val(result.CacheHeaderSeconds));
				variables.HTTPUtil.setResponseHeader('Date', variables.HTTPUtil.formatHTTPDate(httpnow));
				variables.HTTPUtil.setResponseHeader('Expires', variables.HTTPUtil.formatHTTPDate(httpexpires));
			}
			if ( len(trim(result.Output)) > 0 ) {
				/* Tell the client we are sending JSON. */
				variables.HTTPUtil.setResponseContentType('application/json');
				/* Give'em what they asked for. */
				writeOutput( result.Output );
			} else {
				/* No output means a 204 */
				variables.HTTPUtil.setResponseStatus(204,'No Content');
			}
		} else {
			/* Provide appropriate error responses. */
			switch(result.Error) {
				case "NotAuthorized": {
					var response = {
						"status" = 403,
						"statusText" = 'Forbidden',
						"responseText" = 'The user does not have access to this resource'
					};
					break;
				}
				case "ResourceNotFound": {
					var response = {
						"status" = 404,
						"statusText" = 'Not Found',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				case "VerbNotFound": {
					variables.HTTPUtil.setResponseHeader('Allow', result.AllowedVerbs);
					var response = {
						"status" = 405,
						"statusText" = 'Method Not Allowed',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				default: {
					var response = {
						"status" = 500,
						"statusText" = 'Unknown Error Type',
						"responseText" = result.ErrorMessage
					};
					break;
				}
			}
			/* Tell the client we are sending JSON. */
			variables.HTTPUtil.setResponseContentType('application/json');
			/* Output the response */
			variables.HTTPUtil.setResponseStatus(response.status, response.statusText);
			writeOutput( SerializeJSON(response) );
		}
		result["Rendered"] = true;
		return result;
	}
	
	/**
	* @hint "I will process a REST request. Given the requested path and verb, I will call the correct resource and method."
	**/
	public struct function processRequest(
		string Path = CGI.PATH_INFO,
		string Verb = CGI.REQUEST_METHOD,
		string RequestBody,
		struct URLScope,
		struct FormScope
	) {
		/* Try to get reasonable defauls set. */
		if ( isNull(arguments.URLScope) && isDefined("URL") && isStruct(URL) ) {
			arguments.URLScope = URL;
		}
		if ( isNull(arguments.FormScope) && isDefined("FORM") && isStruct(FORM) ) {
			arguments.FormScope = FORM;
		}
		if ( isNull(arguments.RequestBody) && isJSON(trim(ToString(GetHttpRequestData().Content))) ) {
			arguments.RequestBody = trim(ToString(GetHttpRequestData().Content));
		}
		var result = {
			"Success" = true
			,"Output" = ""
			,"Error" = ""
			,"ErrorMessage" = ""
			,"AllowedVerbs" = ""
			,"CacheHeaderSeconds" = ""
		};
		var resource = findResourceConfig( argumentCollection = arguments );
		if ( !resource.Located ) {
			/* We could not locate the configuration for handling this type of request. */
			result.Success = false;
			result.Error = resource.Error;
			if ( resource.Error == "ResourceNotFound" ) {
				result.ErrorMessage = "A resource to handle the pattern (#arguments.Path#) could not be found.";
			} else if ( resource.Error == "VerbNotFound" ) {
				result.ErrorMessage = "The resource (#arguments.Path#) is not configured to handle (#arguments.Verb#) requests.";
			}
			return result;
		}
		result.AllowedVerbs = resource.AllowedVerbs;
		if ( arguments.Verb == "OPTIONS" ) {
			/* They just wanted to know which verbs are supported. We're done. */
			return result;	
		}
		if ( !isNull(getAuthorizationMethod()) ) {
			var authorize = getAuthorizationMethod();
			var authArg = {
				"Bean" = resource.Bean,
				"Method" = resource.Method,
				"Path" = resource.Path,
				"Pattern" = resource.Pattern,
				"Verb" = resource.Verb
			};
			if ( !authorize(authArg) ) {
				result.Success = false;
				result.Error = "NotAuthorized";
				return result;
			}
		}
		result.CacheHeaderSeconds = StructKeyExists(resource, "CacheHeaderSeconds") ? resource.CacheHeaderSeconds : "";
		var bean = getMappedBean(resource.Bean);
		/* Gather the arguments needed to call the method. */
		var args = gatherRequestArguments( argumentCollection = arguments, ResourceMatch = resource);
		/* Now call the method on the bean! */
		try {
			var methodResult = variables.cfmlFunctions.cfmlInvoke(bean, resource.Method, args);
		} catch (Any e) {
			result.Success = false;
			result.ErrorMessage = e.Message;
			/* Allow called methods to throw special ErrorCodes to get specific HTTP status codes. */
			if ( ListFindNoCase("NotAuthorized,ResourceNotFound", e.ErrorCode) ) {
				result.Error = e.ErrorCode;
				return result;
			}
			if ( !isNull(getOnErrorMethod()) ) {
				var onError = getOnErrorMethod();
				onError(e, resource, args);
			} else {
				rethrow;
			}
		}
		if ( IsDefined("methodResult") ) {
			if( IsSimpleValue(methodResult) && resource.WrapSimpleValues.enabled ) {
				/* Wrap the simple value in an object so it's valid JSON */
				result.Output = SerializeJSON({"#resource.WrapSimpleValues.objectProperty#" = methodResult});
			} else {
				result.Output = SerializeJSON(methodResult);
			}
		} else {
			result.Output = "";
		}
		return result;
	}
	
	
	/*
	 * PRIVATE UTILITY FUNCTIONS
	 **/
	
	
	/**
	* @hint "I will configure the pattern matching for the different resources."
	**/
	private void function configureResources( required struct Config ) {
		if ( StructKeyExists(arguments.Config,"RequestPatterns") ) {
			var Patterns = arguments.Config.RequestPatterns; 
		} else if ( StructKeyExists(arguments.Config,"Patterns") ) {
			var Patterns = arguments.Config.Patterns; 
		}
		if ( !StructKeyExists(arguments.Config, "WrapSimpleValues") ) {
			arguments.Config["WrapSimpleValues"] = {};
		}
		StructAppend(arguments.Config.WrapSimpleValues, variables.Defaults.WrapSimpleValues, false);
		variables.Config.Resources = [];
		/* By sorting the keys this way, static patterns should take priority over dynamic ones. */
		var keyList = ListSort(StructKeyList(Patterns), 'textnocase', 'asc');
		for ( var key in ListToArray(keyList) ) {
			var resource = Patterns[key];
			/* Build "AllowedVerbs" for "Allow" header. */
			resource["AllowedVerbs"] = uCase(ListAppend(StructKeyList(resource),"OPTIONS"));
			resource["AllowedVerbs"] = ListSort(resource["AllowedVerbs"],"textnocase","ASC");
			/* Add trailing slash to make matching easier. */
			resource["Pattern"] = key & ( Right(trim(key),1) EQ '/' ? '' : '/' );
			/* Start building the regex for this pattern. */
			resource.Regex = resource["Pattern"];
			/* Replace the {} sections with capture groups. */
			resource.Regex = REReplace(resource.Regex, "{[^}]*?}", "([^/]+?)", "all");
			/* Make sure it matches exactly. (Start to finish) */
			resource.Regex = '^' & resource.Regex & '$';
			/* Pre-compute whether this resource should force valid JSON output */
			var httpRequestMethods = variables.HTTPUtil.getPossibleRequestMethods();
			for ( var resourceKey in resource ) {
				if ( ArrayFindNoCase(httpRequestMethods, resourceKey) ) {
					if ( !StructKeyExists(resource[resourceKey], "WrapSimpleValues") ) {
						resource[resourceKey]["WrapSimpleValues"] = {};
					}
					StructAppend(resource[resourceKey].WrapSimpleValues, arguments.Config.WrapSimpleValues, false);
				}
			}
			/* Add resources with arguments in the path to the bottom. */
			ArrayAppend( variables.Config.Resources, resource );
		}
	}
	
	/**
	* @hint "Give an resource path and verb, I will return the config object. This will contain everything that was in the (GET,PUT,POST,etc) key in the config."
	**/
	private struct function findResourceConfig( required string Path, required string Verb ) {
		/* Add trailing slash to make matching easier. */
		arguments.Path &= ( Right(trim(arguments.Path),1) EQ '/' ? '' : '/' );
		var result = {
			"AllowedVerbs" = ""
			,"Located" = false
			,"Error" = ""
			,"Path" = ""
			,"Pattern" = ""
			,"Regex" = ""
			,"Verb" = arguments.Verb
		};
		for ( var resource in variables.Config.Resources ) {
			if ( RefindNoCase(resource.Regex,arguments.Path) ) {
				var match = resource;
				break;
			}
		}
		if ( IsNull(match) ) {
			result.Error = "ResourceNotFound";
		} else {
			result.AllowedVerbs = match.AllowedVerbs;
			result.Path = arguments.Path;
			result.Pattern = match.Pattern;
			result.Regex = match.Regex;
			if ( arguments.Verb == "OPTIONS" ) {
				/* They just want the options. */
				result.Located = true;
				return result;
			}
			if ( !StructKeyExists(match, arguments.Verb) ) {
				result.Error = "VerbNotFound";
				return result;
			}
			result.Located = true;
			StructAppend(result, match[arguments.Verb]);
		}
		return result;
	}
	
	/**
	* @hint "I will gather all the request arguments up from the possible sources. (URL, Form, URI, Request Body)"
	**/
	private struct function gatherRequestArguments( required struct ResourceMatch, string RequestBody = "", struct URLScope = {}, struct FormScope = {} ) {
		/* Grab the DefaultArguments if they exist. */
		var DefaultArgs = isNull(arguments.ResourceMatch.DefaultArguments) ? {} : arguments.ResourceMatch.DefaultArguments;
		/* Get the arguments from the URIs (e.g. /product/321 to ProductID=321) */
		var PathValues = {};
		if ( ReFindNoCase("[{}]", ResourceMatch.Pattern) ) {
			var nameLenPos = RefindNoCase(ResourceMatch.Regex, ResourceMatch.Pattern, 1, true);
			var valueLenPos = RefindNoCase(ResourceMatch.Regex, ResourceMatch.Path, 1, true);
			if ( ArrayLen(nameLenPos.Len) == ArrayLen(valueLenPos.Len) && ArrayLen(valueLenPos.Len) > 1 ) {
				for ( var i = 2; i <= ArrayLen(nameLenPos.Len); i++ ) {
					var argName = ReReplaceNoCase(mid(ResourceMatch.Pattern, nameLenPos.Pos[i], nameLenPos.Len[i]), "[{}]", "", "all");
					PathValues[argName] = mid(ResourceMatch.Path, valueLenPos.Pos[i], valueLenPos.Len[i]);
				}
			}
		}
		/* Get the value of the Body. */
		var Payload = {};	
		if ( len(trim(arguments.RequestBody)) && isJSON(trim(arguments.RequestBody)) ) {
			/* The request body can be an array or something else that will not StructAppend. So, they are added to the args as "Payload". */
			Payload = DeserializeJSON(trim(arguments.RequestBody));
		}
		var args = {
			"Payload" = Payload,
			"ArgumentSources" = {
				"DefaultArguments" = DefaultArgs,
				"FormScope" = arguments.FormScope,
				"PathValues" = PathValues,
				"Payload" = Payload,
				"URLScope" = arguments.URLScope
			}
		};
		/* Coalesce all the sources together. User "overwrite" false and put the highest priority first.  */
		StructAppend(args, PathValues, false);	/* Path 1st */
		if ( isStruct(Payload) ) {
			StructAppend(args, Payload, false);	/* Body 2nd */
		}
		StructAppend(args, URLScope, false);	/* URL 3rd */
		StructAppend(args, FormScope, false);	/* Form 4th */
		StructAppend(args, DefaultArgs, false);	/* DefaultArguments 5th */
		return args;
	}
	
	/**
	* @hint "I will get the bean from the BeanFactory or as a new object."
	**/
	private component function getMappedBean( required string Bean ) {
		if ( isDefined("variables.BeanFactory") ) {
			return getBeanFactory().getBean(arguments.Bean);
		} else {
			var _bean = CreateObject("component", arguments.Bean);
			if ( IsDefined("_bean.init") ) {
				/* It has a constructor. So, call it. */
				_bean.init();
			}
			return _bean;
		}
	}
	
	/**
	* @hint "I will handle any type of config passed in."
	**/
	private struct function translateConfig( required any Config ) {
		/* Deal with different types of configs passed in. */
		
		if ( isStruct(arguments.Config) ) {
			/* It's already a struct. Return it. */
			return arguments.Config;
		}
		if ( isJSON(trim(arguments.Config)) ) {
			/* It's a JSON string. Deserialize and return it. */
			return DeserializeJSON(trim(arguments.Config));
		}
		if ( !fileExists(arguments.Config) && fileExists(expandPath(arguments.Config)) ) {
			arguments.Config = expandPath(arguments.Config);
		}
		if ( !fileExists(arguments.Config) ) {
			/* Throw error */
			throw( type="Relaxation.Config.InvalidPath", message="I could not find a file at the path you supplied. [#arguments.Config#]");
		}
		return DeserializeJSON(trim(fileRead(arguments.Config)));
	}
}