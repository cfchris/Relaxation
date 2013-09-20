<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>REST Resource Docs</title>
	<link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
	<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
	<script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
	<script>
		$(function() {
			$( "#accordion" ).accordion({
				active: false,
				collapsible: true,
				heightStyle: "content"
			});
		});
	</script>
	<style>
		#accordion > div > div {
			margin-bottom: 30px;
		}
		#accordion p, #accordion ul {
			margin-left: 40px;
			line-height: .8em;
		}
		#accordion ul {
			line-height: 1.2em;
		}
		#accordion p:first-child {
			margin-left: 0; 
		}
	</style>
</head>
<cfoutput>
<body>
	<h1>Supported Resource Paths</h1>
	<div id="accordion">
		<cfloop array="#docMeta#" index="local.resource">
			<h2>#resource.Pattern#</h2>
			<div>
				<cfloop array="#resource.verbs#" index="local.method">
					<div>
						<p><strong>#method.Verb#</strong></p>
						<cfif StructKeyExists(method, "error")>
							<p><strong>ERROR:</strong> #method.error#</p>
						<cfelse>
							<p>"#method.Hint#"</p>
							<p><strong>Parameters:</strong></p>
							<ul>
								<cfloop array="#method.Parameters#" index="local.arg">
									<li>
										#arg.Required?'required':''#
										#arg.Type#
										#arg.Name#
										#isDefined("arg.Default")?'(default: '&arg.Default&')':''#
									</li>
								</cfloop>
								<cfif ArrayLen(method.Parameters) EQ 0>
									<li>(none)</li>
								</cfif>
							</ul>
							<p>
								<strong>Response:</strong>
								#method.returntype#
							</p>
						</cfif>
					</div>
				</cfloop>
			</div>
		</cfloop>
	</div>
</body>
</cfoutput>
</html>