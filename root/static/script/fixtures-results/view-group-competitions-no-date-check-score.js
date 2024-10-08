/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    "responsive": true,
    "paging": false,
    "fixedHeader": true,
    "searching": false,
    "info": false,
    "order": [[1, "asc"]],
    "ordering": false,
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Competition - invisible, as it's grouped
      "visible": false,
      "targets": 0
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 1
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 2
    }, {
      // Venue / score
      "responsivePriority": 3,
      "targets": 3
    }]
  });
});