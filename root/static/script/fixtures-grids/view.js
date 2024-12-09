/**
 *  Fixtures grid view scripts
 *
 */
$(document).ready(function() {
  /*
    DataTables
  */
  var matches = $("#matches-table").DataTable({
    "ordering": false,
    "fixedHeader": true,
    "responsive": true,
    "info": true,
    "order": [[1, "asc"]],
    "paging": true,
    "pageLength": 25,
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "ordering": false,
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Division rank, division name - division name invisible because it's grouped
      "visible": false,
      "targets": [0]
    }]
  });
  
  $("select[name=matches-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
  
  var division_positions = $("#division-positions-table").DataTable({
    "ordering": false,
    "fixedHeader": true,
    "responsive": true,
    "info": true,
    "orderFixed": {"pre": [1, "asc"]},
    "order": [[2, "asc"]],
    "paging": true,
    "pageLength": 25,
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "ordering": false,
    "rowGroup": {
      "dataSrc": 1
    },
    "columnDefs": [{
      // Division rank, division name - invisible because the rank is just for sorting, division name invisible because it's grouped
      "visible": false,
      "targets": [0, 1]
    }, {
      // Order data for division name column will be the division ID column
      "orderData": 0,
      "targets": [1]
    }]
  });
  
  $("select[name=division-positions-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
  
  var tournament_positions = $("#tournament-positions-table").DataTable({
    "ordering": false,
    "fixedHeader": true,
    "responsive": true,
    "info": true,
    "orderFixed": {"pre": [[0, "asc"], [2, "asc"]]},
    "order": [[2, "asc"]],
    "paging": true,
    "pageLength": 25,
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "ordering": false,
    "rowGroup": {
      "dataSrc": [0, 2]
    },
    "columnDefs": [{
      // Competition name invisible because it's grouped, group order column because it's a sort column
      "visible": false,
      "targets": [0, 1, 2]
    }, {
      // Order data for group column will be the group_order column
      "orderData": 1,
      "targets": 2
    }]
  });
  
  $("select[name=tournament-positions-table_length]").chosen({
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
        // Redraw the matches tables
        matches.responsive.recalc();
      } else if (tab.selector == "#division-positions") {
        // Redraw the fixtures table
        division_positions.responsive.recalc();
      } else if (tab.selector == "#tournament-positions") {
        tournament_positions.responsive.recalc();
      }
    }
  });
});