$(function() {
    // Setup leaflet map
    map = new L.Map('map');

    var basemapLayer = new L.TileLayer('http://{s}.tiles.mapbox.com/v3/github.map-xgq2svrz/{z}/{x}/{y}.png');

    // Center map and default zoom level
    map.setView([mapsetView0, mapsetView1], 3);

    // Set zoom level default
    map.setZoom(17);

    // Adds the background layer to the map
    map.addLayer(basemapLayer);

    // Colors for AwesomeMarkers
    var _colorIdx = 0,
        _colors = [
          'orange',
          'green',
          'blue',
          'purple',
          'darkred',
          'cadetblue',
          'red',
          'darkgreen',
          'darkblue',
          'darkpurple'
        ];

    function _assignColor() {
        return _colors[_colorIdx++%10];
    }

    // =====================================================
    // =============== Playback ============================
    // =====================================================

    // Playback options
    var playbackOptions = {
        // layer and marker options
        layer: {
            pointToLayer : function(featureData, latlng){
               //console.log('latlng',latlng);
                var result = {};

                if (featureData && featureData.properties && featureData.properties.path_options){
                    result = featureData.properties.path_options;
                }

                if (!result.radius){
                    result.radius = 5;
                }

                return new L.CircleMarker(latlng, result);
            }
        },

        marker: function(){

            return {
                icon: L.AwesomeMarkers.icon({
                    prefix: '',
                    icon: '',
                    markerColor: _assignColor()
                })
            };
        }
    };

    // Initialize playback
    var playback = new L.Playback(map, demoTracks, null, playbackOptions);

    // Initialize custom control
    var control = new L.Playback.Control(playback);
    control.addTo(map);

    map.on("click", function (event) {
        var currentPosition = event.latlng;
        playback._clock.setCursor(playback._trackController.getTimeStampFromLatLng(currentPosition));
    });

});
