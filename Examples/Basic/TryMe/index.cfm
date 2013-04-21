<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>Try Relaxation</title>
<link href="http://netdna.bootstrapcdn.com/twitter-bootstrap/2.3.0/css/bootstrap-combined.min.css" rel="stylesheet">
<link href="tryme.css" rel="stylesheet">
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
<script type="text/javascript" src="tryme.js"></script>
</head>

<body>
	<div class="container">
		
		<div class="alert noProducts">
			<strong>Warning!</strong> There are no products saved. Either add a new product or reinitialize the application.
		</div>
		
		<div class="hero-unit">
			<h2>Relaxation</h2>
			<p>
				Relaxation is a REST framework for ColdFusion that helps you build a REST API. 
				And then it gets the heck out of your way.
			</p>
			<div class="well pagination-centered">
				<button class="btn btn-large reinit">Reinitialize the Application</button>
			</div>
		</div>
		
		<h3>Product Collection</h3>
		<div class="well">
			<p>
				<div>Resource: /product</div>
				<div>Method: OPTIONS</div>
			</p>
			<button class="btn btn-primary btn-large getProductVerbOptions">Get OPTIONS</button>
			<div class="response">
				<div>
					<h4>Response</h4>
					<div class="collapseResponse"><button class="btn">Collapse Response</button></div>
				</div>
				<div class="responseContent">
					<pre></pre>
				</div>
			</div>
		</div>
		
		<div class="well">
			<p>
				<div>Resource: /product</div>
				<div>Method: GET</div>
			</p>
			<button class="btn btn-primary btn-large getProducts">Get Products</button>
			<div class="response">
				<div>
					<h4>Response</h4>
					<div class="collapseResponse"><button class="btn">Collapse Response</button></div>
				</div>
				<div class="responseContent">
					<pre></pre>
				</div>
			</div>
		</div>
		
		<div class="well">
			<p>
				<div>Resource: /product</div>
				<div>Method: POST</div>
			</p>
			<form class="well">
				<label>Product Name</label>
				<input name="productName" />
				<label>Price</label>
				<input name="price" />
				<label>Vendor</label>
				<input name="vendor" />
			</form>
			<button class="btn btn-primary btn-large addProduct">Add a Product</button>
			<div class="response">
				<div>
					<h4>Response</h4>
					<div class="collapseResponse"><button class="btn">Collapse Response</button></div>
				</div>
				<div class="responseContent">
					<pre></pre>
				</div>
			</div>
		</div>
		
		<h3>Product Item</h3>
		<div class="well">
			<p>
				<div>Resource: /product/{ProductID}</div>
				<div>Method: OPTIONS</div>
			</p>
			<button class="btn btn-primary btn-large getProductItemVerbOptions">Get OPTIONS</button>
			<div class="response">
				<div>
					<h4>Response</h4>
					<div class="collapseResponse"><button class="btn">Collapse Response</button></div>
				</div>
				<div class="responseContent">
					<pre></pre>
				</div>
			</div>
		</div>
		<div class="well">
			<p>
				<div>Resource: /product/{ProductID}</div>
				<div>Method: GET</div>
			</p>
			<button class="btn btn-primary btn-large getProduct">Get a Product</button>
			<div class="response">
				<div>
					<h4>Response</h4>
					<div class="collapseResponse"><button class="btn">Collapse Response</button></div>
				</div>
				<div class="responseContent">
					<pre></pre>
				</div>
			</div>
		</div>
		
		<div class="well">
			<p>
				<div>Resource: /product/{ProductID}</div>
				<div>Method: PUT</div>
			</p>
			<form class="well">
				<label>Choose a product to update</label>
				<select name="productToSave" class="products"></select>
				<label>Product Name</label>
				<input name="productNameSave" />
				<label>Price</label>
				<input name="priceSave" />
				<label>Vendor</label>
				<input name="vendorSave" />
			</form>
			<button class="btn btn-primary btn-large saveProduct">Save a Product</button>
			<div class="response">
				<div>
					<h4>Response</h4>
					<div class="collapseResponse"><button class="btn">Collapse Response</button></div>
				</div>
				<div class="responseContent">
					<pre></pre>
				</div>
			</div>
		</div>
		
		<div class="well">
			<p>
				<div>Resource: /product/{ProductID}</div>
				<div>Method: DELETE</div>
			</p>
			<form class="well">
				<label>Choose a product to delete</label>
				<select name="productToDelete" class="products"></select>
			</form>
			<button class="btn btn-primary btn-large deleteProduct">Delete a Product</button>
			<div class="response">
				<div>
					<h4>Response</h4>
					<div class="collapseResponse"><button class="btn">Collapse Response</button></div>
				</div>
				<div class="responseContent">
					<pre></pre>
				</div>
			</div>
		</div>
		
	</div>
</body>