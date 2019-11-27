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
    "order": [[2, "desc"]],
    "columns": [{
      "responsivePriority": 3
    }, {
      "visible": false,
      "responsivePriority": 5
    }, {
      "orderData": 1,
      "responsivePriority": 1
    }, {
      "responsivePriority": 2
    }, {
      "responsivePriority": 4
    }]
  });
});