// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require social-share-button
//= require jquery.cookie
//= require jstz
//= require browser_timezone_rails/set_time_zone
//= require_tree .


$(document).on('click', '.checkin', function(){
  checkin(this);
});

$(document).on('click', '.checkout', function(){
  checkout(this);
});

function checkin(parent) {
  var self = parent;
  //immediately show loader
  $('#'+self.id).hide();
  $('#preloader').show();

  navigator.geolocation.getCurrentPosition(
    function(position) {
      savePosition(position, "checkin", "success", self.id);
    },
    function(position) {
      savePosition(position, "checkin", "error", self.id);
    }
  );
}

function checkout(parent) {
  var self = parent;
  //immediately show loader
  $('#'+self.id).hide();
  $('#preloader').show();

  navigator.geolocation.getCurrentPosition(
    function(position) {
      savePosition(position, "checkout", "success", self.id);
    },
    function(position) {
      savePosition(position, "checkout", "error", self.id);
    }
  );
}

function savePosition(position, type, result, cid) {
  var url = null;
  var lat = null;
  var lng = null;

  if (result == "success") {
    lat = position.coords.latitude;
    lng = position.coords.longitude;
  }

  if(type == "checkin") {
    url = '/accounts/check_in';
  }

  if(type == "checkout") {
    url = '/accounts/check_out';
  }

  $.getJSON("https://api.ipify.org?format=json", function(data){
    var ip_address = data.ip;
    $.ajax({
      url : url,
      method: 'POST',
      data: { cid: cid, lat: lat, lng: lng, ip_address: ip_address },
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      complete: function() {
        $('#preloader').hide();
        if(type == "checkin"){
          $('#'+cid).switchClass("checkin", "checkout");
          $('#'+cid).parent().find('#position_button').text('Check Out');
          $('#'+cid).parent().find('.fa-sign-in').switchClass("fa-sign-in", "fa-sign-out");
          $('#'+cid).show();
        }
      },
      success: function() {
      },
      error:function() {
      }
    });
  });
}