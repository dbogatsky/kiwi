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


// Main
//= require bootstrap/jquery-migrate-1.2.1.min
//= require bootstrap/jquery-ui-1.10.3.min
//= require bootstrap/bootstrap.min
//= require bootstrap/modernizr.min
//= require bootstrap/jquery.sparkline.min
//= require bootstrap/toggles.min
//= require bootstrap/morris.min
//= require bootstrap/raphael-2.1.0.min
//= require bootstrap/jquery.datatables.min
//= require bootstrap/gmaps
//= require bootstrap/jquery.twbsPagination.min
//= require bootstrap/holder

// Vertical timeline
//= require vertical-timeline/main

// Form elements - status and date picker
//= require bootstrap/bootstrap-timepicker.min
//= require bootstrap/jquery.maskedinput.min
//= require bootstrap/jquery.tagsinput.min
//= require bootstrap/jquery.mousewheel
//= require bootstrap/select2.min
//= require bootstrap/jquery.validate.min

// <script src="assets/bootstrap/js/additional-methods.min.js"></script>
//= require bootstrap/bootstrap-editable.min
//= require bootstrap/bootstrap-datetimepicker.min
//= require bootstrap/moment.min
//= require bootstrap/jquery.cookies
//= require bootstrap/jquery.autogrow-textarea
//= require bootstrap/cropper.min
//= require bootstrap/jquery.gritter.min
//= require bootstrap/bootstrap-wizard.min

// wysiwyg editor
//= require wyshtml5/wyshtml5
//= require wyshtml5/bootstrap-wysihtml5
//= require wysihtml5_size_matters

// full calendar
//= require bootstrap/fullcalendar.min

// other
//= require bootstrap/jquery.ui.touch-punch.min
//= require bootstrap/jquery.confirm
//= require jquery.cookie

// timezone
//= require jstz
//= require browser_timezone_rails/set_time_zone

// webshim
//= require webshims/polyfiller

// photo
//= require bootstrap/jquery.prettyPhoto

// custom
//= require bootstrap/custom


$.webshims.setOptions('basePath', '/assets/webshims/shims/')
$.webshims.polyfill('forms')

function url_status() {
  flag = true
  if ($("#vtab3").hasClass('active')){
    $(".url_validate").each(function() {
      var status = valid_url($(this))
      if (!status){
        flag = false;
        return flag;
      }
    });
  }else{
    return flag
  }
  return flag
}

function phonenumber(inputtxt) {
  var phoneno = /^\(?([0-9]{3})\)?[-]?([0-9]{3})[-]?([0-9]{4})$/;
  if(inputtxt.val().match(phoneno)){
    return true;
  }
  else{
    return false;
  }
}

function valid_url(inputtxt) {
  var url = /^((https?):\/\/)?(.)+[a-zA-Z0-9\-\.]{3,}\.[a-zA-Z]{2,}(\.[a-zA-Z]{2,})?$/;
  if(inputtxt.val().match(url)){
    return true;
  }
  else{
    return false;
  }
}

function phonenumber_status() {
  flag = true
  if ($("#vtab3").hasClass('active')){
    $(".phone_validate").each(function() {
      var status = phonenumber($(this))
      if (!status){
        flag = false;
        return flag;
      }
    });
  }else{
    return flag
  }
  return flag
}
