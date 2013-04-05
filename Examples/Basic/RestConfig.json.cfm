{
	"RequestPatterns": {
		"/product": {
			"GET": {
				"Bean": "ProductService"
				,"Method": "GetAllProducts"
			}
		}
		,"/product/{ProductID}": {
			"GET": {
				"Bean": "ProductService"
				,"Method": "GetProductByID"
			}
		}
	}
}