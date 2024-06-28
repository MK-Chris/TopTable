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
  
  var positions = $("#positions-table").DataTable({
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
  
  $("select[name=positions-table_length]").chosen({
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
      } else if (tab.selector == "#positions") {
        // Redraw the fixtures table
        positions.responsive.recalc();
      }
    }
  });
});