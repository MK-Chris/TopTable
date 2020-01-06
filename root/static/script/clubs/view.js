/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#datatable").DataTable({
    "responsive": true,
    "paging": false,
    "info": true,
    "fixedHeader": true,
    "columnDefs": [{
      "visible": false,
      "targets": [3, 5]
    }, {
      "orderData": 3,
      "targets": 2
    }, {
      "orderData": 5,
      "targets": 4
    }]
  });
});