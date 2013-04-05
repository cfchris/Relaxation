{
	"RequestPatterns": {
		"/product": {
			"GET": {
				"Bean": "ProductService"
				,"Method": "getAllProducts"
			},
			"POST": {
				"Bean": "ProductService"
				,"Method": "addProduct"
			}
		}
		,"/product/{ProductID}": {
			"GET": {
				"Bean": "ProductService"
				,"Method": "getProductByID"
			},
			"PUT": {
				"Bean": "ProductService"
				,"Method": "saveProduct"
			},
			"DELETE": {
				"Bean": "ProductService"
				,"Method": "deleteProduct"
			}
		}
	}
}