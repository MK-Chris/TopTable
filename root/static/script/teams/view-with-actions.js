/**
 *  Team view scripts
 *
 */
$(document).ready(function() {
  /*
    DataTables
  */
  var averages_singles = $("#averages-singles").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columnsDefs": [
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 5},
      {"responsivePriority": 3},
      {"responsivePriority": 6},
      {"responsivePriority": 7},
      {"responsivePriority": 4}
    ]
  });
  
  var averages_doubles_individuals = $("#averages-doubles-individuals").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 4},
      {"responsivePriority": 5},
      {"responsivePriority": 6},
      {"responsivePriority": 3}
    ]
  });
  
  var averages_doubles_pairs = $("#averages-doubles-pairs").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 4},
      {"responsivePriority": 5},
      {"responsivePriority": 6},
      {"responsivePriority": 3}
    ]
  });
  
  var fixtures_table = $("#fixtures-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": true,
    "fixedHeader": true,
    "order": [[3, "asc"]],
    "columnDefs": [{
        // Day name
        "orderData": 1,
        "responsivePriority": 7,
        "targets": 0
      }, {
        // Day of week number
        "visible": false,
        "targets": 1
      }, {
        // Date display
        "responsivePriority": 1,
        "orderData": 3,
        "targets": 2
      }, {
        // Date sortable
        "visible": false,
        "targets": 3
      }, {
        // Home / away
        "responsivePriority": 3,
        "targets": 4
      }, {
        // Opponent
        "responsivePriority": 2,
        "targets": 5
      }, {
        // Result
        "responsivePriority": 4,
        "targets": 6
      }, {
        // Score
        "responsivePriority": 5,
        "targets": 7
      }, {
        // Venue
        "responsivePriority": 6,
        "targets": 8
      }, {
        // Actions
        "responsivePriority": 7,
        "targets": 9
      }
    ]
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