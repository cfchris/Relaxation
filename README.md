Relaxation
=====

Is building a REST API in ColdFusion stressing you out? You need a little REST and Relaxation.

Relaxation is a REST framework for ColdFusion that helps you build a REST API. And then it gets the heck out of your way.

With Relaxation, handling REST requests can be as easy as this:

	/* Somewhere in your initialization code */
	application.Relaxation = new Relaxation.Relaxation( "./RestConfig.json" ).setBeanFactory( application.BeanFactory );
	
	/* In onRequest (or wherever) */
	result = application.Relaxation.handleRequest();
	writeOutput(result.Output);

There's a little more to it than that. But, I don't want to stress you out. 

If you want to know more, checkout the [QuickStart Guide](https://github.com/cfchris/Relaxation/wiki/QuickStart-Guide). Or download the files and poke around the examples. Or whatever. No pressure.

# License

Copyright (c) 2012 DealerPeak LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.