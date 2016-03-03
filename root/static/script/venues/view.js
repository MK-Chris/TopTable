$(document).ready(function(){
  $("#geolocation").on("click", function() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(handle_geo, show_geo_error);
    } else {
      $("div.error-message span.message-text").text("Geolocation is not supported by this browser.");
      $("div.error-message").show();
    }
  });
  
  // Handle the user entering a location, rather than clicking the button
  $("#manual_directions").on("click", function() {
    $("#search_type").val("manual");
    $("#lat").val("");
    $("#lng").val("");
    
    get_directions($("#user_location").val(), destination_coordinates);
  });
  
  // Handle changing the transport mode box if we already are showing directions
  $("#travel_mode").on("change", function() {
    if ( $("#search_type").val() == "manual" && $("#user_location").val() != "" ) {
      // Manual searching, use the text box value
      get_directions($("#user_location").val(), destination_coordinates);
    } else if ( $("#search_type").val() == "gps" && $("#lat").val() != "" && $("#lng").val() != "" ) {
      get_directions($("#lat").val() + "," + $("#lng").val(), destination_coordinates);
    }
  });

  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    activate: function() {
      google.maps.event.trigger(map, "resize");
      map.setCenter(map_location);
    }
  });
});