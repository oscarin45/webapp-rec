(function() {
  var $, base, buscar, cart, cat, formData, index, inicio, mainView, msg, myApp, post, prod, sube, titleCat;

  $ = Dom7;

  cat = [];

  buscar = [];

  prod = '';

  titleCat = '';

  inicio = true;

  base = 'http://recuadros.com/';

  myApp = new Framework7({
    swipePanel: 'left',
    hideToolbarOnPageScroll: true,
    hideNavbarOnPageScroll: true,
    showBarsOnPageScrollEnd: false
  });

  $(document).on('ajaxStart', function(e) {
    return myApp.showIndicator();
  });

  $(document).on('ajaxComplete', function() {
    return myApp.hideIndicator();
  });

  addToHomescreen();

  mainView = myApp.addView('.view-main');

  msg = function(e) {
    e = eval("(" + e.detail.data + ")");
    if (e.error) {
      myApp.alert(e.error, 'Error!');
    }
    if (e.msg) {
      myApp.alert(e.msg, 'Mensaje');
    }
    return e;
  };

  post = function(url, data, success) {
    return $.ajax({
      url: url,
      method: 'POST',
      data: data,
      success: success,
      contentType: 'multipart/form-data'
    });
  };

  index = function() {
    return $.getJSON(base + 'test', function(data) {
      var ban, mySwiper, mySwiper2, nav, nov;
      nav = Template7.compile($('#navTpl').html());
      $('#navHtml').html(nav(data));
      $('#cartItem').text(data.items);
      ban = Template7.compile($('#banTpl').html());
      $('.swiper-1 .swiper-wrapper').html(ban(data));
      mySwiper = myApp.swiper('.swiper-1', {
        autoplay: 4000,
        speed: 800,
        loop: true
      });
      if (inicio) {
        cat.items = data.nov;
      }
      nov = Template7.compile($('#novTpl').html());
      $('#novHtml').html(nov(data));
      mySwiper2 = myApp.swiper('.swiper-2', {
        slidesPerView: 2,
        nextButton: '.slider-next-button',
        prevButton: '.slider-prev-button'
      });
      if (buscar.items.length && inicio === false) {
        return cat = buscar;
      } else {
        return cat.items = data.nov;
      }
    });
  };

  index();

  myApp.onPageInit('index', function(e) {
    inicio = true;
    return index();
  });

  myApp.onPageInit('contacto', function(e) {
    $.get(base + 'post/captcha/1/1', function(e) {
      return $('#captcha').val(e);
    });
    return $('form.ajax-submit').on('submitted', function(e) {
      return msg(e);
    });
  });

  $.get('login.php', function(e) {
    $('.login-screen').html(e);
    return $('form#aut-log').on('submitted', function(e) {
      var p;
      p = msg(e);
      if (p.msg) {
        myApp.closeModal('.login-screen');
        mainView.loadPage('index.php');
        return setTimeout(function() {
          return mainView.loadPage('cart.php');
        }, 500);
      }
    });
  });

  $.get('registro.php', function(e) {
    $('.popup-registro').html(e);
    return $('form#aut-reg').on('submitted', function(e) {
      return msg(e);
    });
  });

  myApp.onPageInit('categorias', function(e) {
    return $.getJSON(base + 'test/cats', function(d) {
      var li;
      li = Template7.compile($('#tplCat').html());
      $('#novCat').html(li(d));
      return $('.itemcat').click(function(event) {
        return titleCat = $(this).parent().find('.card-content').text();
      });
    });
  });

  myApp.onPageInit('lista', function(e) {
    var carga, head, hr, i, lic;
    hr = e.url.replace('list.php?', '');
    head = Template7.compile($('#tplHead').html());
    lic = Template7.compile($('#tplLi').html());
    i = 1;
    carga = true;
    return $.getJSON(base + 'test/cat/' + hr + '/' + i++, function(ct) {
      ct.title = titleCat;
      $('#list').html(head(ct));
      $('#list .row').append(lic(ct));
      cat = ct.items;
      return $('.infinite-scroll').on('infinite', function() {
        if (carga) {
          return $.getJSON(base + 'test/cat/' + hr + '/' + i++, function(rows) {
            var j, len, ref, x;
            $('#list .row').append(lic(rows));
            ref = rows.items;
            for (j = 0, len = ref.length; j < len; j++) {
              x = ref[j];
              ct.items.push(x);
            }
            cat = ct.items;
            if (rows.items.length === 0) {
              return carga = false;
            }
          });
        }
      });
    });
  });

  myApp.onPageInit('producto', function(e) {
    var ct, hr, pr;
    hr = e.url.replace('prod.php?', '');
    pr = Template7.compile($('#tplPr').html());
    ct = like(cat, 'id', hr);
    prod = ct[0];
    if (titleCat != null) {
      prod['title'] = titleCat;
    }
    return $('#det').html(pr(prod));
  });

  myApp.onPageInit('producto-detalle', function(e) {
    var pr;
    pr = Template7.compile($('#tplPr2').html());
    return $('#detpr').html(pr(prod)).find('.media-list').each(function(e) {
      return $(this).find('input').eq(0).attr('checked', true);
    });
  });

  myApp.onPageInit('prod3', function(e) {
    var formData, frm, pr;
    formData = myApp.formToJSON('#detpr');
    frm = '';
    $.each(formData, function(k, v) {
      return frm += '<input type="hidden" name="' + k + '" value="' + v + '"/>';
    });
    $('#tplFrm').append(frm);
    pr = Template7.compile($('#tplFrm').html());
    $('#form').html(pr(prod));
    $.post(base + 'home/total', myApp.formToJSON('#form'), function(e) {
      return $('#form #total').html(e);
    });
    return $('form#form').on('submitted', function(e) {
      $('#cartItem').text(e.detail.data);
      return mainView.loadPage('cart.php');
    });
  });

  cart = function() {
    var cr;
    cr = Template7.compile($('#tplCr').html());
    return $.getJSON('../test/cart', function(d) {
      $('#cart').html(cr(d));
      $('.swipeout').on('deleted', function() {
        return $.get('../upc/' + $(this).find('.swipeout-delete').data('id'), function() {
          return $.get('../test/item', function(e) {
            $('#cartItem').text(e);
            mainView.router.reloadPage('cart.php');
            return myApp.alert('El producto ha sido removido', 'Mensaje');
          });
        });
      });
      $('#actualizar').click(function() {
        var frm;
        $('#redirect_path').val('');
        frm = myApp.formToJSON('#cart');
        $.post($('#cart').attr('action'), frm, function(e) {
          mainView.router.reloadPage('cart.php');
          $('#cartItem').text(e);
          return myApp.alert('El producto fue actualizado', 'Mensaje');
        });
        return $('#redirect_path').val('');
      });
      return $('#enviar').click(function() {
        var frm;
        $('#redirect_path').val('enviar');
        frm = myApp.formToJSON('#cart');
        return $.post($('#cart').attr('action'), frm, function(e) {
          e = eval("(" + e + ")");
          if (e.paypal) {
            window.top.location.href = e.paypal;
          }
          if (e.msg) {
            myApp.alert(e.msg, 'Mensaje');
            return mainView.loadPage('index.php');
          }
        });
      });
    });
  };

  myApp.onPageInit('cart', function(e) {
    return cart();
  });

  setTimeout(function() {
    return $('#logout').click(function() {
      return $.getJSON(base + 'auth/logout/1', function(d) {
        return mainView.loadPage('index.php');
      });
    });
  }, 1500);

  $(document).on('pageAfterBack pageInit', function(e) {
    var vw;
    vw = e.detail.page.view.url;
    switch (vw) {
      case 'sear.php':
        inicio = false;
        return cat = buscar;
      case 'index.php':
        inicio = true;
        return cat = [];
    }
  });

  myApp.onPageInit('buscar', function(e) {
    var pr;
    pr = Template7.compile($('#tplBus').html());
    return $('.searchbar input[type=search]').on('keyup change', function(e) {
      var vl;
      vl = $(this).val();
      if (vl.length > 3) {
        return $.post('../test/sear', {
          like: vl
        }, function(s) {
          s = eval("(" + s + ")");
          $('.list-block-search').html(pr(s));
          cat.items = s.items;
          return buscar = s;
        });
      }
    });
  });

  sube = '';

  myApp.onPageInit('sube2', function(e) {
    var id, pr;
    id = e.url.replace('sube2.php?', '');
    pr = Template7.compile($('#tplCd').html());
    return $.get('../test/sube/' + id, function(s) {
      s = eval("(" + s + ")");
      return $('#novCd').html(pr(s)).find('.media-list').each(function(e) {
        return $(this).find('input').eq(0).prop('checked', true);
      });
    });
  });

  formData = '';

  myApp.onPageInit('sube3', function(e) {
    var cg, med, pr, tipo;
    pr = Template7.compile($('#tplsb').html());
    formData = myApp.formToJSON('#novCd');
    formData.name = $('#novCd .back .item-after').text();
    tipo = Object.keys(formData)[1];
    cg = new Object();
    med = $('#novCd input[value="' + formData[tipo] + '"]').parent().find('.medidas');
    med.children('span').each(function(i) {
      return cg[i] = {
        w: $(this).data('w'),
        h: $(this).data('h')
      };
    });
    formData.id = med.data('id');
    formData.carga = cg;
    $('#sbCd').html(pr(formData));
    $('input[type=file]').change(function(e) {
      var $p, data, files;
      $p = $(this);
      data = new FormData();
      files = e.target.files;
      files['file'] = files[0];
      $.each(files, function(key, value) {
        return data.append(key, value);
      });
      return $.ajax({
        url: '../home/upload/' + formData.id + '/' + $p.data('w') + '/' + $p.data('h') + '/file/1',
        type: 'POST',
        data: data,
        cache: false,
        dataType: 'json',
        processData: false,
        contentType: false,
        statusCode: {
          404: function(xhr) {
            return myApp.alert('page not found');
          }
        },
        success: function(data, status, xhr) {
          if (data.error) {
            myApp.alert(data.error, 'Error');
          }
          if (data.upload_data) {
            $('#upload').html('<img>');
            myApp.popup('.popup-upload');
            $('#upload img').prop('src', data.upload_data.thumb).addClass('br');
            return $p.next().val(data.upload_data.thumb);
          }
        }
      });
    });
    return $('#avanzar').click(function(event) {
      var img, pasa;
      img = myApp.formToJSON('#sbCd');
      pasa = true;
      $.each(img, function(key, value) {
        if (!value) {
          return pasa = false;
        }
      });
      if (pasa) {
        return mainView.loadPage($(this).data('ur'));
      } else {
        return myApp.alert('Falta alguna imagen por subir', 'Mensaje');
      }
    });
  });

  myApp.onPageInit('sube4', function(e) {
    var cg, img;
    $('#name').text(formData.name);
    img = myApp.formToJSON('#sbCd');
    formData.canvas = img[Object.keys(img)[0]];
    cg = new Array();
    cg[0] = formData.base + 'img/' + formData.estilo + '.jpg';
    cg[1] = img[Object.keys(img)[0]];
    formData.img = cg;
    $.post('../home/img_in/0/1', formData, function(e) {
      return $('#total').html(e);
    });
    return $('form#form').on('submitted', function(e) {
      $('#cartItem').text(e.detail.data);
      return mainView.loadPage('cart.php');
    });
  });

}).call(this);
