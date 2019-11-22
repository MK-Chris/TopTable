/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "fixedHeader": true,
    "searching": true,
    "ordering": true,
    "rowGroup": {
      "dataSrc": 2
    },
    "columnDefs": [{
      // Date sortable, division rank
      "visible": false,
      "targets": [0, 3]
    }, {
      // Date printable
      "responsivePriority": 1,
      "orderData": 0,
      "targets": 1
    }, {
      // Division name
      "responsivePriority": 3,
      "orderData": 3,
      "targets": 2
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 4
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 5
    }, {
      // Score
      "responsivePriority": 4,
      "targets": 4
    }]
  });
});