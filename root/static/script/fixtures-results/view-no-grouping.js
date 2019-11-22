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
    "order": [[1, "asc"]],
    "rowGroup": {
      "dataSrc": 2
    },
    "columnDefs": [{
      // Date sortable
      "visible": false,
      "targets": 0
    }, {
      // Date printable
      "responsivePriority": 1,
      "orderData": 0,
      "targets": 1
    }, {
      // Home team
      "responsivePriority": 2,
      "targets": 2
    }, {
      // Away team
      "responsivePriority": 3,
      "targets": 3
    }, {
      // Score
      "responsivePriority": 4,
      "targets": 4
    }/*, {
      // Venue
      "responsivePriority": 6,
      "targets": 9
    }*/]
  });
});