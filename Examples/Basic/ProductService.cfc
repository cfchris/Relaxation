component displayname="Product Service" hint="I am the testing Product Service" output="false" persistent="false" {

	/**
	* @hint "I am the constructor"
	* @output false
	**/
	public component function init() {
		variables.Products = [
			{"ProductID":1, "Name": "Hot Sauce!", "Price": "$7.99", "Vendor": "REST And Relaxation Store"}
			,{"ProductID":2, "Name": "Awesome Sauce!", "Price": "$12.99", "Vendor": "REST And Relaxation Store"}
			,{"ProductID":3, "Name": "Beans And Rice", "Price": "$0.00", "Vendor": "REST And Relaxation Store"}
		];
		return this;
	}
	
	/**
	* @hint "I return the test products"
	* @output false
	**/
	public array function GetAllProducts() {
		return variables.Products;
	}
	
	/**
	* @hint "I get a product by it's ID"
	* @output false
	**/
	public struct function getProductByID( string ProductID, string Test = "default" ) {
		var ret = duplicate(variables.Products[arguments.ProductID]);
		ret["NonPathArg"] = arguments.Test;
		return ret;
	}

}