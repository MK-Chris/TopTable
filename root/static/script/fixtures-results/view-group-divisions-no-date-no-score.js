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
      // Division rank, division name - division name invisible because it's grouped
      "visible": false,
      "targets": [0, 1]
    }, {
      // Division name
      "orderData": 1,
      "targets": 0
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 2
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 3
    }, {
      // Venue
      "responsivePriority": 3,
      "targets": 4
    }]
  });
});