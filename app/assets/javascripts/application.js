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
//= require popper
//= require bootstrap
//= require material
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

function removeProductFromCart(id, sf) {
  let cart = getCart()
  if(cart[id] != undefined) {
    delete cart[id]
  }
  document.cookie = "cart=" + JSON.stringify(cart);
  $(sf).closest('#cart-product').remove()
  displayCartProductsNum()
}

function decrementProductFromCart(id) {
  let cart = getCart()
  if(cart[id] == undefined) {
    cart[id] = 1
  } else {
    let quantity = parseInt(cart[id]) 
    if(quantity > 0) { cart[id] = quantity - 1 }
  }
  document.cookie = "cart=" + JSON.stringify(cart);
  let counter = $("#product-" + id + "-quantity")
  let counter_val = parseInt(counter.val())
  if(counter_val > 0) { counter.val( counter_val - 1 ) }
  displayCartProductsNum()
}

function incrementProductToCart(id) {
  let cart = getCart()
  if(cart[id] == undefined) {
    cart[id] = 1
  } else {
    cart[id] = parseInt(cart[id]) + 1
  }
  document.cookie = "cart=" + JSON.stringify(cart);
  let counter = $("#product-" + id + "-quantity")
  counter.val( parseInt(counter.val()) + 1 )
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
