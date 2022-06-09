/**
 *  Initialise datatable
 *
 */
$(document).ready(function(){
  var table = $("#datatable").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "order": [[1, "asc"]],
    "columnDefs": [{
      "targets": [3, 7, 10],
      "visible": false
    }, {
      "targets": [4],
      "orderData": 2
    }, {
      "targets": [8],
      "orderData": 6
    }, {
      "targets": 9,
      "orderData": 10
    }, {
      "targets": [0],
      "orderable": false
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
  
  // If we change the number of records shown, or to a different page, recalculate
  // whether or not the 'check all' box should be ticked
  table.on("draw", calculateChecked);
  
  /**
   *  Trigger a 'check all' function
   *
   */
  $("input#checkall").on("change", function(){
    var t = $(this);
    
    if ( t.prop("checked") === false ) {
      // Uncheck everything
      $("input.single-check").prettyCheckable("uncheck");
    } else {
      // Check everything
      $("input.single-check").prettyCheckable("check");
    }
  });
   
  
  // Recalculate whether or not the 'check all' box should be ticked when we tick or untick one
  $("input.single-check").on("change", calculateChecked);
});

  /**
   *  Loop through and work out whether 'check all' should be checked or not.
   *
   */
function calculateChecked() {
  var checked = 0;
  var checkboxes = 0;
  
  $("input.single-check").each(function(){
    if ( $(this).prop("checked") ) {
      // This box is checked, increase the count of checked boxes
      checked++;
    }
    
    // Always increase the total number of checkboxes
    checkboxes++;
  });
  
  //console.log( "totel: " + checkboxes + ", checked: " + checked + ", unchecked: " + unchecked );
  
  if ( checked === checkboxes ) {
    // If we have the same number checked as checkboxes, everything is checked and so should the check all box
    $("input#checkall").prettyCheckable("check");
  } else {
    // If there's a different number checked to checkboxes, some must be unckecked and so should the check all box
    $("input#checkall").prettyCheckable("uncheck");
  }
}