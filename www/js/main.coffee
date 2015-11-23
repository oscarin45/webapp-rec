$= Dom7
cat= []
buscar= []
prod= ''
titleCat= ''
inicio = true
base= 'http://recuadros.com/'


myApp = new Framework7
	swipePanel: 'left'
	hideToolbarOnPageScroll: true
	hideNavbarOnPageScroll: true
	showBarsOnPageScrollEnd: false

$(document).on 'ajaxStart', (e)->
	myApp.showIndicator()

$(document).on 'ajaxComplete',->
	myApp.hideIndicator()


addToHomescreen()

#ban = Template7.compile $$('.swiper-1').html()


mainView = myApp.addView '.view-main'

msg = (e)->
	e= eval("("+e.detail.data+")")
	if e.error 
		myApp.alert e.error, 'Error!'
	if e.msg
		myApp.alert e.msg, 'Mensaje'

	e

post = (url, data, success)->
	$.ajax
		url: url,
		method: 'POST'
		data: data
		success: success
		contentType: 'multipart/form-data'

index = ->
	$.getJSON base+'test', (data)->
		nav  = Template7.compile $('#navTpl').html()
		$('#navHtml').html nav data

		$('#cartItem').text data.items

		ban  = Template7.compile $('#banTpl').html()
		$('.swiper-1 .swiper-wrapper').html ban data
		mySwiper = myApp.swiper '.swiper-1', 
			autoplay:4000
			speed: 800
			loop:true

		if inicio
			cat.items = data.nov


		nov  = Template7.compile $('#novTpl').html()
		$('#novHtml').html nov data
		mySwiper2 = myApp.swiper '.swiper-2',
			slidesPerView: 2
			#spaceBetween: 20
			nextButton: '.slider-next-button'
			prevButton: '.slider-prev-button'

		if buscar.items.length && inicio==false
			cat= buscar
		else
			cat.items= data.nov



index()
myApp.onPageInit 'index', (e)->
	inicio= true
	index()
	


myApp.onPageInit 'contacto', (e)->
	$.get base+'post/captcha/1/1', (e)->
		$('#captcha').val e

	$('form.ajax-submit').on 'submitted', (e)->
		msg(e)


$.get 'login.php', (e)->
	$('.login-screen').html e
	$('form#aut-log').on 'submitted', (e)->
		p= msg(e)
		if p.msg
			myApp.closeModal '.login-screen'
			mainView.loadPage 'index.php'
			setTimeout ->
				mainView.loadPage 'cart.php'
			, 500

$.get 'registro.php', (e)->
	$('.popup-registro').html e

	$('form#aut-reg').on 'submitted', (e)->
		msg(e)



myApp.onPageInit 'categorias', (e)->
	$.getJSON base+'test/cats', (d)->
		li = Template7.compile $('#tplCat').html()
		$('#novCat').html li d

		$('.itemcat').click (event)->
			titleCat= $(this).parent().find('.card-content').text()
		#	event.preventDefault()
		#	hr = $(this).attr 'href'
			#mainView.router.loadContent '<!-- Top Navbar-->'+'<div class="navbar">'+'  <div class="navbar-inner">'+'    <div class="left"><a href="#" class="back link"><i class="icon icon-back"></i><span>Back</span></a></div>'+'    <div class="center sliding">Dynamic Page 10000</div>'+'  </div>'+'</div>'+'<div class="pages">'+'  <!-- Page, data-page contains page name-->'+'  <div data-page="dynamic-pages" class="page">'+'    <!-- Scrollable page content-->'+'    <div class="page-content">'+'      <div class="content-block">'+'        <div class="content-block-inner">'+'          <p>Here is a dynamic page created on '+ new Date()+' !</p>'+'          <p>Go <a href="#" class="back">back</a> or go to <a href="services.html">Services</a>.</p>'+'        </div>'+'      </div>'+'    </div>'+'  </div>'+'</div>'

			

myApp.onPageInit 'lista', (e)->
	hr=  e.url.replace 'list.php?', ''
	head = Template7.compile $('#tplHead').html()
	lic = Template7.compile $('#tplLi').html()

	i= 1
	carga = true
	$.getJSON base+'test/cat/'+hr+'/'+ i++, (ct)->
		ct.title= titleCat
		$('#list').html head ct
		$('#list .row').append lic ct
		cat= ct.items

		$('.infinite-scroll').on 'infinite', ->
			if carga
				$.getJSON base+'test/cat/'+hr+'/'+ i++, (rows)->

					$('#list .row').append lic rows
					#console.log ct
					#console.log rows
					for x in rows.items
						ct.items.push x

					cat= ct.items
					if rows.items.length==0
						carga = false



	#	mainView.router.loadContent(lic ct)
		#myApp.popup lic ct

myApp.onPageInit 'producto', (e)->
	hr=  e.url.replace 'prod.php?', ''
	pr= Template7.compile $('#tplPr').html()
	ct= like cat, 'id', hr
	prod= ct[0]
	if titleCat?
		prod['title']= titleCat
	#prod.title= if typeof titleCat !== "undefined" && titleCat !== null then titleCat else ''
	$('#det').html pr prod
	#$.getJSON '../test/prod/'+hr, (ct)->
	#	ct.title= titleCat
	#	prod= ct
	#	$('#det').html pr ct
		
myApp.onPageInit 'producto-detalle', (e)->
	pr = Template7.compile $('#tplPr2').html()
	$('#detpr').html(pr prod).find('.media-list').each (e)->
		$(this).find('input').eq(0).attr 'checked',true
	#.find('.media-list input').eq(0).attr 'checked',true

	
myApp.onPageInit 'prod3', (e)->
	formData = myApp.formToJSON('#detpr')
	frm= ''
	$.each formData, (k,v)->
		frm+= '<input type="hidden" name="'+k+'" value="'+v+'"/>'

	$('#tplFrm').append frm


	pr = Template7.compile $('#tplFrm').html()
	$('#form').html pr prod

	$.post base+'home/total', myApp.formToJSON('#form'), (e)->
		$('#form #total').html e
	#console.log formData
	#$.post '../total', 

	$('form#form').on 'submitted', (e)->
		$('#cartItem').text e.detail.data
		mainView.loadPage 'cart.php'
	
cart = ->
	cr = Template7.compile $('#tplCr').html()
	$.getJSON '../test/cart', (d)->
		$('#cart').html cr d
		$('.swipeout').on 'deleted', ->
			$.get '../upc/'+$(this).find('.swipeout-delete').data('id'), ->
				$.get '../test/item', (e)->
					$('#cartItem').text e
					mainView.router.reloadPage 'cart.php'
					myApp.alert 'El producto ha sido removido', 'Mensaje'


		$('#actualizar').click ->
			$('#redirect_path').val ''
			frm= myApp.formToJSON('#cart')
			$.post $('#cart').attr('action'), frm, (e)->
				mainView.router.reloadPage 'cart.php'
				$('#cartItem').text e
				#$('#cart .card .card-content-inner span').eq(0).text e+' Cuadros'
				myApp.alert 'El producto fue actualizado', 'Mensaje'


			$('#redirect_path').val ''
				
		$('#enviar').click ->
			$('#redirect_path').val 'enviar'
			frm= myApp.formToJSON('#cart')
			$.post $('#cart').attr('action'), frm, (e)->
				#e= eval("("+e.detail.data+")")
				e= eval("("+e+")")
				if e.paypal
					#window.open e.paypal, '_system'
					window.top.location.href = e.paypal
				if e.msg
					myApp.alert e.msg, 'Mensaje'
					mainView.loadPage 'index.php'



myApp.onPageInit 'cart', (e)->
	cart()
		#$('.action1').click (l)->
		#	myApp.alert $(this).data('id')


setTimeout ->
	$('#logout').click ->
		$.getJSON base+'auth/logout/1', (d)->
			mainView.loadPage 'index.php'

, 1500

$(document).on 'pageAfterBack pageInit', (e)->
	vw= e.detail.page.view.url
	switch vw
		when 'sear.php'
			inicio= false
			cat = buscar
			#console.log 'cat'+cat.items.length
			#console.log 'buscar'+buscar.items.length
		when 'index.php'
			inicio= true
			cat= []
		



myApp.onPageInit 'buscar', (e)->
	pr = Template7.compile $('#tplBus').html()
	#$.getJSON '../test/sear', (s)->
	#	$('.list-block-search').html pr s

	$('.searchbar input[type=search]').on 'keyup change', (e)->
		vl= $(this).val()
		if vl.length>3
			#$.post '../test/sear', like: vl, (s)->
			$.post '../test/sear', like: vl, (s)->
				s= eval("("+s+")")
				$('.list-block-search').html pr s
				cat.items= s.items
				buscar = s
				#$('.list-block-search a').click ->
				#	cat= s
				#	mainView.loadPage $(this).prop 'href'



################################################# SUBE TU FOTO ##############################################################
sube= ''
myApp.onPageInit 'sube2', (e)->
	id=  e.url.replace 'sube2.php?', ''
	pr = Template7.compile $('#tplCd').html()
	$.get '../test/sube/'+id, (s)->
		s= eval("("+s+")")
		$('#novCd').html pr s
		.find('.media-list').each (e)->
			$(this).find('input').eq(0).prop 'checked',true


formData= ''
myApp.onPageInit 'sube3', (e)->
	pr = Template7.compile $('#tplsb').html()
	formData = myApp.formToJSON('#novCd')
	formData.name = $('#novCd .back .item-after').text()
	tipo= Object.keys(formData)[1]
	cg= new Object()
	
	#console.log tipo
	med= $('#novCd input[value="'+formData[tipo]+'"]').parent().find('.medidas')
	#med= $('#novCd input[value="'+formData[tipo]+'"]').parent().find('.medidas')
	med.children('span').each (i)->
		cg[i]=
			w: $(this).data 'w'
			h: $(this).data 'h'
	#$.get '../test/suben/'+formData[formData.tipo]
	formData.id= med.data 'id'
	formData.carga= cg
	$('#sbCd').html pr formData
	#console.log formData

	$('input[type=file]').change (e)->
		$p= $(this)
		data = new FormData()
		files= e.target.files
		files['file']= files[0]
		#console.log files
		$.each files, (key, value)->
			data.append key, value

		$.ajax
			#url: '../test/upload'
			url: '../home/upload/'+formData.id+'/'+$p.data('w')+'/'+$p.data('h')+'/file/1'
			type: 'POST'
			data: data
			cache: false
			dataType: 'json'
			processData: false
			contentType: false
			statusCode:
				404: (xhr)->
					myApp.alert 'page not found'
			success:(data,status,xhr)->
				#console.log data
				if data.error
					myApp.alert data.error, 'Error'
				if data.upload_data
					$('#upload').html '<img>'
					myApp.popup '.popup-upload'
					$('#upload img').prop('src',data.upload_data.thumb).addClass 'br'
					#console.log data.upload_data.thumb

					$p.next().val data.upload_data.thumb
			#error:(xhr,status)->
			#	console.log status
			#	myApp.alert 'Error de conexión', 'Error'


	$('#avanzar').click (event)->
		img= myApp.formToJSON('#sbCd')
		#console.log img
		pasa= true
		$.each img, (key, value)->
			pasa= false if !value

		if pasa
			mainView.loadPage $(this).data 'ur'
		else
			myApp.alert 'Falta alguna imagen por subir', 'Mensaje'


myApp.onPageInit 'sube4', (e)->
	$('#name').text formData.name

	img= myApp.formToJSON('#sbCd')

	formData.canvas = img[Object.keys(img)[0]]
	cg= new Array()
	cg[0]= formData.base+'img/'+formData.estilo+'.jpg'
	cg[1]= img[Object.keys(img)[0]]
	formData.img= cg

	#console.log formData

	$.post '../home/img_in/0/1',formData, (e)->
		$('#total').html e


	$('form#form').on 'submitted', (e)->
		$('#cartItem').text e.detail.data
		mainView.loadPage 'cart.php'

