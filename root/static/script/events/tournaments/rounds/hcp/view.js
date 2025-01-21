/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  let matches_table = $("#fixtures-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    searching: true,
    ordering: true,
    orderFixed: {pre: [1, "asc"]},
    order: [4, "asc"],
    rowGroup: {
      dataSrc: 1
    },
    columnDefs: [{
      // Day sort, day (grouped), date sort
      visible: false,
      targets: [0, 1, 2]
    }, {
      // Week day
      orderData: 0,
      targets: 1
    }, {
      // Date
      orderData: 2,
      responsivePriority: 7,
      targets: 3
    }, {
      // Home team
      responsivePriority: 1,
      targets: 4
    }, {
      // Home handicap
      responsivePriority: 3,
      targets: 5
    }, {
      // Away team
      responsivePriority: 2,
      targets: 6
    }, {
      // Away handicap
      responsivePriority: 4,
      targets: 7
    }, {
      // Score
      responsivePriority: 5,
      orderable: false,
      targets: 8
    }, {
      // Venue
      responsivePriority: 6,
      targets: 9
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
  
  /*
    Responsive tabs
  */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if (tab.selector == "#matches") {
        // Redraw the adjustments table
        matches_table.responsive.recalc();
      }
    }
  });
});