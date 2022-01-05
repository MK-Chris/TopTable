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
      "responsivePriority": 5,
      "type": "ip-address"
    }, {
      "visible": false
    }, {
      "orderData": 2,
      "responsivePriority": 1
    }, {
      "responsivePriority": 4
    }, {
      "responsivePriority": 2
    }]
  });
});
