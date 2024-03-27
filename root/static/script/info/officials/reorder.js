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
      var official_positions_array = $(this).sortable("toArray", {attribute: "data-official-id"});
      var official_positions = official_positions_array.join(",");
      $("#official_positions").val(official_positions);
      
      // Loop over the original array, setting the new grid position
      var position_number = 0;
      var old_text;
      $.each(official_positions_array, function( index, value ) {
        // Increment the game number
        position_number++;
        old_text = $("#official-" + value + "-position").text();
        $("#official-" + value + "-position").text(position_number);
      });
    }
  });
});