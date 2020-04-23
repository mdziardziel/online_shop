// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require activestorage
//= require_tree .


function getCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(';');
  for(var i=0; i<ca.length; i++) {
      var c = ca[i].trim();
         if (c.indexOf(name)==0) return c.substring(name.length,c.length);
  }
  return null;
}  

function getCart(){
  let cartCookie = getCookie('cart')
  let cart = null
  if(cartCookie == null) {
    cart = {}
  } else {
    cart = JSON.parse(cartCookie)
  }
  return cart;
}

function addProductToCart(id) {
  let cart = getCart()
  if(cart[id] == undefined) {
    cart[id] = 1
  } else {
    cart[id] = parseInt(cart[id]) + 1
  }
  document.cookie = "cart=" + JSON.stringify(cart);
  displayCartProductsNum()
}

function clearCart(){
  document.cookie = "cart=" + JSON.stringify({});
  displayCartProductsNum()
}

function productsInCartNum(){
  let cart = getCart()
  return sum(cart)
}

function displayCartProductsNum(){
  let cart = getCart()
  $('#cart_min').text(sum(cart))
}

function sum(obj) {
  return Object.keys(obj).reduce((sum,key)=>sum+parseFloat(obj[key]||0),0);
}

$( document ).ready(function() {
  displayCartProductsNum()
});
