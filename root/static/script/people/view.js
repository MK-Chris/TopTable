/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  var games = $("#datatable").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
    "info": true,
    "fixedHeader": true,
    "columnDefs": [{
      // Date display
      "orderData": 1,
      "responsivePriority": 5,
      "targets": 0
    }, {
      // Date sortable
      "visible": false,
      "responsivePriority": 4,
      "targets": 1
    }/*, {
      // Playing against (team)
      "responsivePriority": 3,
      "targets": 3
    }*/, {
      // Opponent (player)
      "responsivePriority": 1,
      "targets": 4
    }/*, {
      // Score
      "orderable": false,
      "targets": 5
    }*/, {
      // Result
      "orderable": false,
      "responsivePriority": 2,
      "targets": 6
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
  
  /*
    Responsive tabs
  */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if (tab.selector == "#games") {
        // Redraw the averages tables
        games.responsive.recalc();
      }
    }
  });
});