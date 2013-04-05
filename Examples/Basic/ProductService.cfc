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
	public array function getAllProducts() {
		return variables.Products;
	}
	
	/**
	* @hint "I get a product by its ID"
	* @output false
	**/
	public struct function getProductByID( string ProductID ) {
		
		for (var p in variables.Products) {
			if (p.ProductID == arguments.ProductID) {
				return p;
			}	
		}
		
		return {};
	}
	
	/**
	* @hint "I add a product"
	* @output false
	**/
	public struct function addProduct( struct payload ) {
		
		payload['ProductID'] = getNextID();
		
		arrayAppend(variables.Products, payload);
		
		return {
			"ProductID": payload.ProductID,
			"self": "/product/#payload.ProductID#"
		};
		
	}
	
	/**
	* @hint "I save a product"
	* @output false
	**/
	public struct function saveProduct( numeric ProductID, struct payload ) {
		
		payload['ProductID'] = arguments.ProductID;
		
		for (var p in variables.Products) {
			if (p.ProductID == arguments.ProductID) {
				structAppend(p, payload, true);
				break;
			}	
		}
		
		return {
			"ProductID": payload.ProductID,
			"self": "/product/#payload.ProductID#"
		};
	}
	
	/**
	* @hint "I delete a product"
	* @output false
	**/
	public void function deleteProduct( numeric ProductID ) {
		
		for (var i=1; i<=ArrayLen(variables.Products); i++) {
			if (variables.Products[i].ProductID == arguments.ProductID) {
				ArrayDeleteAt(variables.Products, i);
				break;
			}	
		}
			
	}
	
	/**
	* @hint "I get the next available identifier for a product"
	* @output false
	**/
	private numeric function getNextID() {
		var ProductID = 0;
		
		for (var p in variables.Products) {
			if (p.ProductID >= ProductID) {
				ProductID = p.ProductID + 1;
			}
		}
		
		return ProductID;
	}

}