$(function() {
	
	function showResponse($button, data) {
		$button.next('.response')
			.find('pre')
			.html(JSON.stringify(data, undefined, 2))
			.end()
			.show();
	}
	
	function loadProducts() {
		$('select.products').find('option').remove();
		var $this = $(this);
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product',
			type: 'get',
			contentType: 'application/json',
			dataType: 'json'
		}).always(function(data){
			for (var v in data) {
				$('select.products').append(
					$('<option></option>').val(data[v].ProductID).html(data[v].Name).data('product',data[v])
				);
			}
			if (data.length == 0) {
				$('.noProducts').show();
			} else {
				$('.noProducts').hide();
			}
			$('select.products').change();
		});
	}
	
	loadProducts();
	
	$('select.products').on('change', function() {
		var product = $(this).find(':selected').first().data('product');
		$('input[name=productNameSave]').val(product.Name);
		$('input[name=priceSave]').val(product.Price);
		$('input[name=vendorSave]').val(product.Vendor);
	});
	
	$('.collapseResponse').on('click', function() {
		$(this).closest('.response').toggle();
	});
	
	$('.reinit').on('click', function() {
		var $this = $(this);
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product?reinit',
			type: 'get',
			contentType: 'application/json',
			dataType: 'json'
		}).always(function(data){
			$this.append('<i class="icon-ok"></i>');
			loadProducts();
		});
	});
	
	$('.getProducts').on('click', function() {
		var $this = $(this);
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product',
			type: 'get',
			contentType: 'application/json',
			dataType: 'json'
		}).always(function(data){
			showResponse($this, data);
		});
	});
	
	$('.getProductItemVerbOptions').on('click', function() {
		var $this = $(this);
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product/1',
			type: 'OPTIONS',
			complete: function(xhr){
				showResponse($this, xhr.getResponseHeader('Allow'));
			}
		});
	});
	
	$('.getProductVerbOptions').on('click', function() {
		var $this = $(this);
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product',
			type: 'OPTIONS',
			complete: function(xhr){
				showResponse($this, xhr.getResponseHeader('Allow'));
			}
		});
	});
	
	$('.addProduct').on('click', function() {
		var $this = $(this);
		var product = {
			Price: $('input[name=price]').val(),
			Name: $('input[name=productName]').val(),
			Vendor: $('input[name=vendor]').val()
		};
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product',
			type: 'post',
			data: JSON.stringify(product),
			contentType: 'application/json',
			dataType: 'json'
		}).always(function(data){
			showResponse($this, data);
			loadProducts();
		});
	});
	
	$('.getProduct').on('click', function() {
		var $this = $(this);
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product/1',
			type: 'get',
			contentType: 'application/json',
			dataType: 'json'
		}).always(function(data){
			showResponse($this, data);
		});
	});
	
	$('.saveProduct').on('click', function() {
		if ($('select[name=productToSave] option').length > 0) {
			var $this = $(this);
			var product = {
				Price: $('input[name=priceSave]').val(),
				Name: $('input[name=productNameSave]').val(),
				Vendor: $('input[name=vendorSave]').val()
			};
			$.ajax({
				url: '/Relaxation/Examples/Basic/index.cfm/product/' + $('select[name=productToSave]').val(),
				type: 'put',
				data: JSON.stringify(product),
				contentType: 'application/json',
				dataType: 'json'
			}).always(function(data){
				showResponse($this, data);
				loadProducts();
			});
		} else {
			$('.noProducts').show();
		}
	});
	
	$('.deleteProduct').on('click', function() {
		var $this = $(this);
		$.ajax({
			url: '/Relaxation/Examples/Basic/index.cfm/product/' + $('select[name=productToDelete]').val(),
			type: 'delete',
			contentType: 'application/json',
			dataType: 'json'
		}).always(function(data){
			showResponse($this, data);
			loadProducts();
		});
	});
	
});