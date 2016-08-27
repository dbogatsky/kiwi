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

//= require bootstrap/jquery-migrate-1.2.1.min
//= require bootstrap/jquery-ui-1.10.3.min
//= require bootstrap/bootstrap.min
//= require bootstrap/modernizr.min
//= require bootstrap/jquery.sparkline.min
//= require bootstrap/toggles.min

//= require bootstrap/morris.min
//= require bootstrap/raphael-2.1.0.min
//= require bootstrap/jquery.datatables.min

//= require jquery.cookie
//= require jstz
//= require browser_timezone_rails/set_time_zone
//= require webshims/polyfiller


$.webshims.setOptions('basePath', '/assets/webshims/shims/')
$.webshims.polyfill('forms')