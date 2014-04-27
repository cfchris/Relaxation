component
	displayname="Example Error Logger" 
	hint="I log errors for the Relaxation basic example."
{
	/**
	 * @Hint "I am the constructor."
	 **/
	public component function init() {
		return this;
	}
	
	/**
	 * @Hint "I handle logging an error."
	 **/
	public void function logError( required any Error ) {
		var msg = arguments.Error.Message;
		if ( isDefined("arguments.Error.TagContext") && ArrayLen(arguments.Error.TagContext) ) {
			msg &= ' ' & arguments.Error.TagContext[1].template & ' (line ' & arguments.Error.TagContext[1].line & ')';
		}
		writeToLog( msg );
	}
	
	/**
	 * @Hint "I write to a log file."
	 **/
	private void function writeToLog( required string Message ) {
		writeLog( file = "RelaxationExamples", text = arguments.Message );
	}
	
}