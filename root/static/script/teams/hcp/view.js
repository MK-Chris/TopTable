/**
 *  Team view scripts
 *
 */
$(document).ready(function() {
  /*
    DataTables
  */
  var averages_singles = $("#averages-singles").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 1},
      {responsivePriority: 2},
      {responsivePriority: 5},
      {responsivePriority: 8},
      {responsivePriority: 4},
      {responsivePriority: 6},
      {responsivePriority: 7},
      {responsivePriority: 3}
    ]
  });
  
  var averages_doubles_individuals = $("#averages-doubles-individuals").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 1},
      {responsivePriority: 2},
      {responsivePriority: 4},
      {responsivePriority: 5},
      {responsivePriority: 6},
      {responsivePriority: 3}
    ]
  });
  
  var averages_doubles_pairs = $("#averages-doubles-pairs").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 1},
      {responsivePriority: 2},
      {responsivePriority: 4},
      {responsivePriority: 5},
      {responsivePriority: 6},
      {responsivePriority: 3}
    ]
  });
  
  var fixtures_table = $("#fixtures-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    searching: true,
    ordering: true,
    order: [[1, "asc"]],
    columnDefs: [{
      // Date sort, week day sort, competition sort
      visible: false,
      targets: [0, 2, 4]
    }, {
      // Date
      orderData: 0,
      responsivePriority: 1,
      targets: 1
    }, {
      // Week day
      responsivePriority: 8,
      orderData: 2,
      targets: 3
    }, {
      // Competition
      responsivePriority: 6,
      orderData: 4,
      targets: 5
    }, {
      // Home / away
      responsivePriority: 3,
      targets: 5
    }, {
      // Opponent
      responsivePriority: 2,
      targets: 6
    }, {
      // Result
      responsivePriority: 4,
      targets: 7
    }, {
      // Score
      responsivePriority: 5,
      targets: 8
    }, {
      // Venue
      responsivePriority: 7,
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
      if (tab.selector == "#players") {
        // Redraw the averages tables
        averages_singles.responsive.recalc();
        averages_doubles_individuals.responsive.recalc();
        averages_doubles_pairs.responsive.recalc();
      } else if (tab.selector == "#fixtures-results") {
        // Redraw the fixtures table
        fixtures_table.responsive.recalc();
      }
    }
  });
});