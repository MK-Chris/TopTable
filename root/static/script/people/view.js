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
    "columnDefs": [{
      "visible": false,
      "targets": 0
    }, {
      "orderData": 0,
      "targets": 1
    }, {
      "orderable": false,
      "targets": [5, 6]
    }]
  });
});