component displayname="Testing Service" hint="I am a simple service to test request routing." output="false" {
	
	/**
	* @hint "I am the constructor."
	* @output false
	**/
	public component function init() { return this; }
	
	/**
	* @hint "I will get a product by ID"
	* @output false
	**/
	public struct function getProductByID( string ProductID ) {
		if ( arguments.ProductID == 1 ) {
			return {
				"ProductID": 1
				,"Name": "Relaxation REST Framework"
				,"DateCreated": "April 1st 2013"
			};
		} else {
			return {
				"ProductID": ""
				,"Name": "Undefined"
				,"DateCreated": ""
			};
		}
	}
	
	/**
	* @hint "I return void."
	* @output false
	**/
	public void function returnNothing() {
		return;
	}
	
}