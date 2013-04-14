<cfcomponent hint="I handle stuff that needs to be written in CFML." output="false">
	
	<cffunction name="init" access="public" returntype="component" output="false" hint="I am the constructor.">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="cfmlInvoke" access="public" returntype="any" output="false" hint="I handle calling cfinvoke.">
		<cfargument name="object" type="component" required="true" />
		<cfargument name="method" type="string" required="true" />
		<cfargument name="args" type="struct" required="true" default="#{}#" />
		
		<cfinvoke component="#arguments.object#"
				  method="#arguments.method#"
				  argumentcollection="#arguments.args#"
				  returnvariable="local.result" />
		
		<cfreturn IsNull(local.result) ? JavaCast("null", "") : local.result />
	</cffunction>
	
</cfcomponent>