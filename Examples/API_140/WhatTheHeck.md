# Tweet A REST API

What?

I tweeted the code that it takes to setup and run Relaxation a while back.

> https://twitter.com/cfchris/status/325422668172128256
> 
> Meet Relaxation!
Load
application.REST = new com.Relaxation.Relaxation("./RestConfig.json",BeanFactory)
Run
application.REST.handleRequest()

I think that tweet inspired Adam Tuttle to tweet a fully functional Taffy example.

> https://twitter.com/cf_taffy/status/327415972581486592
> 
> component extends="taffy.core.api"{}  
component extends="taffy.core.resource" taffy_uri="/hi"{function get(){return representationOf('hi');}}

I took that as a challenge. So, I came up with this example for Relaxation.

> https://twitter.com/cfchris/status/327529641923448832  
> 
> component{new Relaxation({"Patterns":{"/hi":{"GET":{"Bean":"hi","Method":"hi"}}}}).handleRequest();}  
component{function hi(){return 'hi';}}

This folder contains that example.

Locally, I can browse to http://localhost/Relaxation/Examples/API_140/index.cfm/hi and get back "hi".

## Compromises  

140 characters is really small! 

To make this work (because it REALLY does), I had to:

* Put the core files in the same folder as the Application.cfc
* Not cache the framework
* Run it in the pseudo-constructor of the Application.cfc

So, pretty much, don't use this as the example for your API!
