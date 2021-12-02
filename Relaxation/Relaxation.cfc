component
	accessors="true"
	displayname="Relaxation REST Framework"
	hint="I am the Relaxation framework for REST in CF. Relax, I got this!"
{

	property name="AuthorizationMethod" type="any";
	property name="BasicAuthCheckMethod" type="any";
	property name="BeanFactory" type="component";
	property name="cfmlFunctions" type="component";
	property name="DocGenerator" type="component";
	property name="HTTPUtil" type="component";
	property name="OnErrorMethod" type="any";
	
	variables.Config = {};
	variables.Defaults = {
		"Arguments" = {
			"PayloadArgument" = "Payload"
			,"PayloadRawArgument" = "PayloadRaw"
			,"MergeScopes" = {
				"Path" = true
				,"Payload" = true
				,"URL" = true
				,"Form" = true
			}
		}
		,"CrossOrigin" = {
			"enabled" = false
		}
		,"JSONP" = {
			"enabled" = false
			,"callbackParameter" = "jsonp"
		}
		,"WrapSimpleValues" = {
			"enabled" = true
			,"objectProperty" = "result"
		}
		,"SerializeValues" = {
			"enabled" = true
		}
	};
	
	/**
	* @hint "I initialize the object and get the routing all setup."
	**/
	public component function init( required any Config, component BeanFactory, any AuthorizationMethod, any BasicAuthCheckMethod, any OnErrorMethod ) {
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
		if ( structKeyExists(arguments,'BasicAuthCheckMethod') ) {
			setBasicAuthCheckMethod( arguments.BasicAuthCheckMethod );
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
	* @hint "I apply the BasicAuthCheckMethod if it exists."
	**/
	private boolean function basicAuthCredentialsPass( required struct ResourceInfo ) {
		var credentials = variables.HTTPUtil.getBasicAuthCredentials();
		var checkCredentials = getBasicAuthCheckMethod();
		if ( IsNull(credentials) ) {
			/* No credentials supplied. */
			var credentials = {
				"specified" = false
				,"user" = ""
				,"password" = ""
			};
		}
		return checkCredentials( credentials, ResourceInfo );
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
				if ( IsJson(result.Output) ) {
					/* Tell the client we are responding with JSON. */
					variables.HTTPUtil.setResponseContentType('application/json');
				} else if ( IsXml(result.Output) ) {
					/* Tell the client we are responding with XML. */
					variables.HTTPUtil.setResponseContentType('text/xml');
				}
				/* Give'em what they asked for. */
				writeOutput( result.Output );
			} else {
				/* No output means a 204 */
				variables.HTTPUtil.setResponseStatus(204,'No Content');
			}
		} else {
			/* Provide appropriate error responses. */
			switch(result.Error) {
				case "ClientError": {
					result["Response"] = {
						"status" = 400,
						"statusText" = 'Bad Request',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				case "NotAuthorized": {
					result["Response"] = {
						"status" = 403,
						"statusText" = 'Forbidden',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				case "ResourceNotFound": {
					result["Response"] = {
						"status" = 404,
						"statusText" = 'Not Found',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				case "VerbNotFound": {
					variables.HTTPUtil.setResponseHeader('Allow', result.AllowedVerbs);
					result["Response"] = {
						"status" = 405,
						"statusText" = 'Method Not Allowed',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				case "ConflictError": {
					result["Response"] = {
						"status" = 409,
						"statusText" = 'Conflict',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				case "ServerError": {
					result["Response"] = {
						"status" = 500,
						"statusText" = 'Internal Server Error',
						"responseText" = result.ErrorMessage
					};
					break;
				}
				default: {
					result["Response"] = {
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
			variables.HTTPUtil.setResponseStatus(result.Response.status, result.Response.statusText);
			if ( result.Resource.Located && !result.Resource.SerializeValues.enabled ) {
				writeOutput( result.Response.responseText );
			} else {
				writeOutput( SerializeJSON(result.Response) );
			}
		}
		// Find the Origin of the request
		var headers = variables.HTTPUtil.getRequestHeaders();
		if ( result.Resource.CrossOrigin.enabled ) {
			// Add "Vary" header so HTTP clients know the response can vary based on the "Origin" header.
			variables.HTTPUtil.setResponseHeader('Vary', 'Origin');
			if ( StructKeyExists( headers, 'Origin') && Len(headers["Origin"]) > 0  ) {
				variables.HTTPUtil.setResponseHeader('Access-Control-Allow-Credentials', 'true');
				variables.HTTPUtil.setResponseHeader('Access-Control-Allow-Headers', 'Cookie, Content-Type');
				variables.HTTPUtil.setResponseHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, PUT, DELETE, OPTIONS');
				variables.HTTPUtil.setResponseHeader('Access-Control-Allow-Origin', headers['Origin']);
				variables.HTTPUtil.setResponseHeader('Access-Control-Max-Age', '86400');
			}
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
		if ( isNull(arguments.RequestBody) && len(trim(ToString(GetHttpRequestData().Content))) ) {
			arguments.RequestBody = trim(ToString(GetHttpRequestData().Content));
		}
		var result = {
			"Success" = true
			,"Output" = ""
			,"Error" = ""
			,"ErrorMessage" = ""
			,"AllowedVerbs" = ""
			,"CacheHeaderSeconds" = ""
			,"Resource" = findResourceConfig( argumentCollection = arguments )
		};
		var resource = result.Resource;
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
			result.resource.CrossOrigin.enabled = variables.Config.raw.CrossOrigin.enabled;
			/* They just wanted to know which verbs are supported. We're done. */
			return result;	
		}
		result.CacheHeaderSeconds = StructKeyExists(resource, "CacheHeaderSeconds") ? resource.CacheHeaderSeconds : "";
		/* Gather the arguments needed to call the method (and for auth methods). */
		var args = gatherRequestArguments( argumentCollection = arguments, ResourceMatch = resource);
		var authArg = {
			"CallArgs" = args,
			"Bean" = resource.Bean,
			"Method" = resource.Method,
			"Path" = resource.Path,
			"Pattern" = resource.Pattern,
			"Verb" = resource.Verb
		};
		/* Now call the method on the bean! */
		try {
			if ( !IsNull(getBasicAuthCheckMethod()) ) {
				if ( !basicAuthCredentialsPass( authArg ) ) {
					variables.HTTPUtil.promptForBasicAuth( "REST API" );
				}
			}
			if ( !IsNull(getAuthorizationMethod()) ) {
				var authorize = getAuthorizationMethod();
				if ( !authorize(authArg) ) {
					result.Success = false;
					result.Error = "NotAuthorized";
					result.ErrorMessage = "You are not authorized to do this";
					return result;
				}
			}
			var bean = getMappedBean(resource.Bean);
			var methodResult = variables.cfmlFunctions.cfmlInvoke(bean, resource.Method, args);
		} catch (Any e) {
			result.Success = false;
			result.ErrorMessage = e.Message;
			/* Allow called methods to throw special ErrorCodes to get specific HTTP status codes. */
			if ( ListFindNoCase("NotAuthorized,ResourceNotFound,ClientError,ConflictError,ServerError,VerbNotFound", e.ErrorCode) ) {
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
			if ( resource.SerializeValues.enabled ) {
				if( IsSimpleValue(methodResult) && resource.WrapSimpleValues.enabled ) {
					/* Wrap the simple value in an object so it's valid JSON */
					result.Output = SerializeJSON({"#resource.WrapSimpleValues.objectProperty#" = methodResult});
				} else {
					result.Output = SerializeJSON(methodResult);
				}
			} else {
				result.Output = methodResult;
			}
			if ( arguments.Verb == "GET" && resource.JSONP.enabled && StructKeyExists(arguments.URLScope, resource.JSONP.callbackParameter) ) {
				/* Add JSONP "padding". */
				var jsonpMethod = arguments.URLScope[resource.JSONP.callbackParameter];
				result.Output = jsonpMethod & "(" & result.Output & ")";
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
		/* Apply defaults to top level config. */
		if ( !StructKeyExists(arguments.Config, "Arguments") ) {
			arguments.Config["Arguments"] = {};
		}
		if ( !StructKeyExists(arguments.Config, "CrossOrigin") ) {
			arguments.Config["CrossOrigin"] = {};
		}
		if ( !StructKeyExists(arguments.Config, "JSONP") ) {
			arguments.Config["JSONP"] = {};
		}
		if ( !StructKeyExists(arguments.Config, "SerializeValues") ) {
			arguments.Config["SerializeValues"] = {};
		}
		if ( !StructKeyExists(arguments.Config, "WrapSimpleValues") ) {
			arguments.Config["WrapSimpleValues"] = {};
		}
		StructAppend(arguments.Config.Arguments, variables.Defaults.Arguments, false);
		StructAppend(arguments.Config.Arguments.MergeScopes, variables.Defaults.Arguments.MergeScopes, false);
		StructAppend(arguments.Config.CrossOrigin, variables.Defaults.CrossOrigin, false);
		StructAppend(arguments.Config.JSONP, variables.Defaults.JSONP, false);
		StructAppend(arguments.Config.SerializeValues, variables.Defaults.SerializeValues, false);
		StructAppend(arguments.Config.WrapSimpleValues, variables.Defaults.WrapSimpleValues, false);
		/* By sorting the keys this way, static patterns should take priority over dynamic ones. */
		var keyList = ListSort(StructKeyList(Patterns), 'textnocase', 'asc');
		variables.Config.Resources = [];
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
					if ( !StructKeyExists(resource[resourceKey], "Arguments") ) {
						resource[resourceKey]["Arguments"] = {};
					}
					if ( !StructKeyExists(resource[resourceKey], "CrossOrigin") ) {
						resource[resourceKey]["CrossOrigin"] = {};
					}
					if ( !StructKeyExists(resource[resourceKey], "JSONP") ) {
						resource[resourceKey]["JSONP"] = {};
					}
					if ( !StructKeyExists(resource[resourceKey], "SerializeValues") ) {
						resource[resourceKey]["SerializeValues"] = {};
					}
					if ( !StructKeyExists(resource[resourceKey], "WrapSimpleValues") ) {
						resource[resourceKey]["WrapSimpleValues"] = {};
					}
					StructAppend(resource[resourceKey].Arguments, arguments.Config.Arguments, false);
					StructAppend(resource[resourceKey].Arguments.MergeScopes, arguments.Config.Arguments.MergeScopes, false);
					StructAppend(resource[resourceKey].CrossOrigin, arguments.Config.CrossOrigin, false);
					if ( StructKeyExists(resource[resourceKey], "DefaultArguments") && IsStruct(resource[resourceKey].DefaultArguments) ) {
						/* Remap legacy config to new position. */
						resource[resourceKey].Arguments["Defaults"] = resource[resourceKey].DefaultArguments;
					}
					StructAppend(resource[resourceKey].JSONP, arguments.Config.JSONP, false);
					if ( !resource[resourceKey].JSONP.enabled ) {
						/* Remove callbackParameter if JSONP disabled. */
						StructDelete(resource[resourceKey].JSONP, "callbackParameter");
					}
					StructAppend(resource[resourceKey].SerializeValues, arguments.Config.SerializeValues, false);
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
		/* Remove extensions (e.g. .json, .xml, etc) */
		arguments.Path = ReReplaceNoCase(arguments.Path, "\.[a-z]+$", "");
		/* Add trailing slash to make matching easier. */
		arguments.Path &= ( Right(trim(arguments.Path),1) EQ '/' ? '' : '/' );
		var result = {
			"AllowedVerbs" = ""
			,"CrossOrigin" = variables.Defaults.CrossOrigin
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
		var DefaultArgs = isNull(arguments.ResourceMatch.Arguments.Defaults) ? {} : arguments.ResourceMatch.Arguments.Defaults;
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
			"ArgumentSources" = {
				"DefaultArguments" = DefaultArgs,
				"FormScope" = arguments.FormScope,
				"PathValues" = PathValues,
				"Payload" = Payload,
				"URLScope" = arguments.URLScope
			}
		};
		/* Insert payload with specified (or default) argument name. */
		args[arguments.ResourceMatch.Arguments.PayloadArgument] = Payload;
		/* Insert raw payload with specified (or default) argument name. */
		args[arguments.ResourceMatch.Arguments.PayloadRawArgument] = trim(arguments.RequestBody);
		/* Coalesce all the sources together. Use "overwrite" false and put the highest priority first.  */
		if ( arguments.ResourceMatch.Arguments.MergeScopes.Path ) {
			StructAppend(args, PathValues, false);	/* Path 1st */
		}
		if ( isStruct(Payload) && arguments.ResourceMatch.Arguments.MergeScopes.Payload ) {
			StructAppend(args, Payload, false);	/* Body 2nd */
		}
		if ( arguments.ResourceMatch.Arguments.MergeScopes.URL ) {
			StructAppend(args, URLScope, false);	/* URL 3rd */
		}
		if ( arguments.ResourceMatch.Arguments.MergeScopes.Form ) {
			StructAppend(args, FormScope, false);	/* Form 4th */
		}
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
