component {
	
	/**
	* @hint "I test basic auth credentials against a credential store. (Well, I would if I was real.)"
	**/
	public boolean function isAuthenticated( required string User, required string Password ) {
		return (arguments.User == "Maxin" && arguments.Password == "Relaxin");
	}
	
}