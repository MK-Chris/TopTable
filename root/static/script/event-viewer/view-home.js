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
    "order": [[1, "desc"]],
    "columns": [{
      "visible": false,
      "responsivePriority": 4
    }, {
      "orderData": 0,
      "responsivePriority": 1
    }, {
      "responsivePriority": 3
    }, {
      "responsivePriority": 2
    }]
  });
});