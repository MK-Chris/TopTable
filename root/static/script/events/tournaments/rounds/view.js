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
      responsivePriority: 5,
      targets: 3
    }, {
      // Home team
      responsivePriority: 1,
      targets: 4
    }, {
      // Away team
      responsivePriority: 2,
      targets: 5
    }, {
      // Score
      responsivePriority: 3,
      orderable: false,
      targets: 6
    }, {
      // Venue
      responsivePriority: 4,
      targets: 7
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
  
  let entrants_table = $("#entrants").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    searching: true,
    ordering: false,
  });
  
  $("select[name=entrants_length]").chosen({
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
      } else if (tab.selector == "#summary") {
        entrants_table.responsive.recalc();
      }
    }
  });
});