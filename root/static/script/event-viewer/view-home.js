/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#datatable").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "fixedHeader": true,
    "searching": false,
    "order": [[1, "asc"]],
    "columns": [{
      "visible": false,
      "responsivePriority": 4
    }, {
      "orderData": 1,
      "responsivePriority": 1
    }, {
      "responsivePriority": 2
    }, {
      "responsivePriority": 3
    }]
  });
});