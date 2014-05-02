component displayname="Testing Service" hint="I am a simple service to test request routing." output="false" {
	
	/**
	* @hint "I am the constructor."
	**/
	public component function init() {
		variables.Products = [
			{"ProductID" = 1, "Name" = "Hot Sauce!", "Price" = "$7.99", "Vendor" = "REST And Relaxation Store"}
			,{"ProductID" = 2, "Name" = "Awesome Sauce!", "Price" = "$12.99", "Vendor" = "REST And Relaxation Store"}
			,{"ProductID" = 3, "Name" = "Beans And Rice", "Price" = "$0.00", "Vendor" = "REST And Relaxation Store"}
		];
		return this;
	}
	
	/**
	* @hint "I return the test products"
	**/
	public array function getAllProducts() {
		return variables.Products;
	}
	
	/**
	* @hint "I get a product by its ID"
	**/
	public struct function getProductByID( string ProductID ) {
		for (var p in variables.Products) {
			if (p.ProductID == arguments.ProductID) {
				return p;
			}	
		}
		return {};
	}
	
	public string function getProductPrice( string ProductID ) {
		for (var product in variables.Products) {
			if (product.ProductID == arguments.ProductID) {
				return product.Price;
			}	
		}
		return "";
	}
	
	/* METHODS THAT THE UNIT TESTING NEEDS */
	
	/**
	* @hint "I will return all available product colors."
	**/
	public array function getProductColors() {}
	
	/**
	* @hint "I will return the colors for a specific product."
	**/
	public array function getProductColorsByProduct( required string ProductID ) {}
	
	/**
	* @hint "I will save a product."
	**/
	public struct function saveProduct( required struct Product ) {}
	
	/**
	* @hint "???"
	**/
	public array function JustForPatternMatchTesting() {}
	
	/**
	* @hint "I return void."
	**/
	public void function returnNothing() {
		return;
	}
	
}