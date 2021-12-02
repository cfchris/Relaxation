Relaxation
=====

Is building a REST API in ColdFusion stressing you out? You need a little REST and Relaxation.

Relaxation is a REST framework for ColdFusion that helps you build a REST API. And then it gets the heck out of your way.

With Relaxation, handling REST requests can be as easy as this:

	/* Somewhere in your initialization code */
	application.REST = new com.Relaxation.Relaxation( "./RestConfig.json.cfm", application.BeanFactory );
	
	/* In onRequest (or wherever) */
	application.REST.handleRequest();

There's a little more to it than that. But, I don't want to stress you out. 

If you want to know more, checkout the [QuickStart Guide](https://github.com/cfchris/Relaxation/wiki/QuickStart-Guide). Or download the files and poke around the examples. Or whatever. No pressure.

## Requirements

I have tested Relaxation on ACF (9 through 2016) and Railo 4. I suspect it _might_ work on CF8. But, it will likely not work on older versions of CF because it is written primarily in cfscript.

There are no external dependencies to use Relaxation.

## License

Copyright (c) 2013 Chris Phillips and Contributors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
