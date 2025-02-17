/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("table.round_view").DataTable({
    responsive: true,
    paging: false,
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
  
  let rounds_table = $("#rounds").DataTable({
    responsive: true,
    paging: false,
    info: false,
    fixedHeader: true,
    searching: false,
    ordering: false,
  });
  
  /*
    Responsive tabs
  */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if (tab.selector == "#summary") {
        // Redraw the adjustments table
        rounds_table.responsive.recalc();
      }
    }
  });
});