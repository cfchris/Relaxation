Relaxation
=====

Relaxation is a REST framework for ColdFusion that helps you build a REST API. And then it gets the heck out of your way.

Are other REST frameworks stressing you out? You might need a little REST and Relaxation.

Imagine if handling REST requests could be as easy as this:

	/* Somewhere in your initialization code */
	application.Relaxation = new Relaxation.Relaxation( restConfigPath ).setBeanFactory( beanFactory );
	
	/* In on request start (or wherever) */
	result = application.Relaxation.handleRequest( CGI.PATH_INFO );
	writeOutput(result.Output);
	
There's a little more to it than that. But, I don't want to stress you out.