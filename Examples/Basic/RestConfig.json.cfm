{
	"RequestPatterns": {
		"/login": {
			"Bean": "AccountService"
			,"Method": "logIn"
		}
		,"/product": {
			"GET": {
				"Bean": "ProductService"
				,"Method": "getAllProducts"
				,"CacheHeaderSeconds": 60
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