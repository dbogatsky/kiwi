var geocoder;
var map;
var marker;

// initialise the google maps objects, and add listeners
function gmaps_init(lat, lng){

  // center of the universe
  var latlng = new google.maps.LatLng(lat, lng);

  var options = {
    zoom: 16,
    center: latlng,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  // create our map object
  map = new google.maps.Map(document.getElementById("gmaps-canvas"), options);

  // the geocoder object allows us to do latlng lookup based on address
  geocoder = new google.maps.Geocoder();

  // the marker shows us the position of the latest address
  marker = new google.maps.Marker({
    position: latlng,
    map: map,
    draggable: true,
    title:  "Your location"
  });

  geocode_lookup( 'latLng', marker.getPosition() );

  // event triggered when marker is dragged and dropped
  google.maps.event.addListener(marker, 'dragend', function() {
    geocode_lookup( 'latLng', marker.getPosition() );
  });

  // event triggered when map is clicked
  google.maps.event.addListener(map, 'click', function(event) {
    marker.setPosition(event.latLng)
    geocode_lookup( 'latLng', event.latLng  );
  });
}

// move the marker to a new position, and center the map on it
function update_map( geometry ) {
  map.fitBounds( geometry.viewport )
    marker.setPosition( geometry.location )
}

// fill in the UI elements with new position data
function update_ui( address, latLng ) {
  $('#gmaps-input-address').autocomplete("close");
  $('#gmaps-input-address').val(address);
  $('#gmaps-output-latitude').html(latLng.lat());
  $('#gmaps-output-longitude').html(latLng.lng());
  $('#gmaps-output-latitude').val(latLng.lat());
  $('#gmaps-output-longitude').val(latLng.lng());
}

// Query the Google geocode object
//
// type: 'address' for search by address
//       'latLng'  for search by latLng (reverse lookup)
//
// value: search query
//
// update: should we update the map (center map and position marker)?
function geocode_lookup( type, value, update ) {
  // default value: update = false
  update = typeof update !== 'undefined' ? update : false;

  request = {};
  request[type] = value;

  geocoder.geocode(request, function(results, status) {
    $('#gmaps-error').html('');
    if (status == google.maps.GeocoderStatus.OK) {
      // Google geocoding has succeeded!
      if (results[0]) {
        // Always update the UI elements with new location data
        update_ui( results[0].formatted_address,
          results[0].geometry.location )
        console.log(results);

          // Only update the map (position marker and center map) if requested
          if( update ) { update_map( results[0].geometry ) }
      } else {
        // Geocoder status ok but no results!?
        $('#gmaps-error').html("Sorry, something went wrong. Try again!");
      }
    } else {
      // Google Geocoding has failed. Two common reasons:
      //   * Address not recognised (e.g. search for 'zxxzcxczxcx')
      //   * Location doesn't map to address (e.g. click in middle of Atlantic)

      if( type == 'address' ) {
        // User has typed in an address which we can't geocode to a location
        $('#gmaps-error').html("Sorry! We couldn't find " + value + ". Try a different search term, or click the map." );
      } else {
        // User has clicked or dragged marker to somewhere that Google can't do a
        // reverse lookup for. In this case we display a warning.
        $('#gmaps-error').html("Woah... that's pretty remote! You're going to have to manually enter a place name." );
        update_ui('', value)
      }
    };
  });
};

// initialise the jqueryUI autocomplete element
function autocomplete_init() {
  $("#gmaps-input-address").autocomplete({

    // source is the list of input options shown in the autocomplete dropdown.
    // see documentation: http://jqueryui.com/demos/autocomplete/
    source: function(request,response) {

      // the geocode method takes an address or LatLng to search for
      // and a callback function which should process the results into
      // a format accepted by jqueryUI autocomplete
      geocoder.geocode( {'address': request.term }, function(results, status) {
        response($.map(results, function(item) {
          return {
            label: item.formatted_address, // appears in dropdown box
          value: item.formatted_address, // inserted into input element when selected
          geocode: item                  // all geocode data
          }
        }));
      })
    },

    // event triggered when drop-down option selected
      select: function(event,ui){
        update_ui(  ui.item.value, ui.item.geocode.geometry.location )
          update_map( ui.item.geocode.geometry )
      }
  });

  // triggered when user presses a key in the address box
  $("#gmaps-input-address").bind('keydown', function(event) {
    if(event.keyCode == 13) {
      geocode_lookup( 'address', $('#gmaps-input-address').val(), true );

      // ensures dropdown disappears when enter is pressed
      $('#gmaps-input-address').autocomplete("disable")
    } else {
      // re-enable if previously disabled above
      $('#gmaps-input-address').autocomplete("enable")
    }
  });
}; // autocomplete_init

$(document).ready(function() {
  if( $('#gmaps-canvas').length  ) {
    navigator.geolocation.getCurrentPosition(function (position) {
      lat = position.coords.latitude
      lng = position.coords.longitude

      if (window.current_address_lat && window.current_address_lng) {
        lat = window.current_address_lat
        lng = window.current_address_lng
      }

      gmaps_init(lat, lng);
      autocomplete_init();
    });
  };
});