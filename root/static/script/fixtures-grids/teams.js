/**
 *  Handle sorting action
 *
 *
 */
$(document).ready(function(){    
  $(".sortable").sortable({
    axis: "y",
    cursor: "move",
    update: function( event, ui ) {
      // IE doesn't register the blur when sorting
      // so trigger focusout handlers to remove .ui-state-focus
      //ui.item.children("li").triggerHandler( "focusout" );
      
      // Get an array of team positions, join them with commas and set them into the hidden field
      var team_positions_array  = $(this).sortable( "toArray", {attribute: "data-team-id"} );
      var team_positions        = team_positions_array.join(",");
      var division              = ui.item.parent("ul").data("division");
      $("#division-positions-" + division).val( team_positions );
      
      // Loop over the original array, setting the new grid position
      var position_number = 0;
      var old_text;
      $.each( team_positions_array, function( index, value ) {
        // Increment the game number
        position_number++;
        old_text = $("#division-" + division + "-team-" + value + "-position").text( );
        $("#division-" + division + "-team-" + value + "-position").text( position_number );
      });
    }
  });
});