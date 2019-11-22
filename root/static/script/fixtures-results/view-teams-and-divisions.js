/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "fixedHeader": false,
    "searching": false,
    "order": [[1, "asc"]],
    "columns": [{
      "visible": false,
      "responsivePriority": 4
    }, {
      "orderData": 0,
      "responsivePriority": 3
    }, {
      "responsivePriority": 1
    }, {
      "responsivePriority": 2
    }]
  });
});