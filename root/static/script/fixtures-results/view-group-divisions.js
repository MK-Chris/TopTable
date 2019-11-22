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
    "order": [[2, "asc"]],
    "ordering": true,
    "rowGroup": {
      "dataSrc": 2
    },
    "columnDefs": [{
      // Day of week number, date sortable, division rank
      "visible": false,
      //"targets": [1, 3, 5]
      "targets": [1, 2, 3] // Whilst DataTables bug is investigated we don't have day name columns
    }, {
      // Date printable
      "responsivePriority": 1,
      "orderData": 1,
      "targets": 0
    }, {
      // Home team
      "responsivePriority": 2,
      "targets": 4
    }, {
      // Away team
      "responsivePriority": 3,
      "targets": 5
    }, {
      // Score
      "responsivePriority": 4,
      "targets": 6
    }, {
      // Division name
      "responsivePriority": 5,
      "orderData": 3,
      "targets": 2
    }/*, {
      // Venue
      "responsivePriority": 6,
      "targets": 9
    }, {
      // Day name
      "responsivePriority": 7,
      "targets": 0
    }*/]
    /*"columns": [{
      // Day name
      "orderData": 1,
      "responsivePriority": 6
    }, {
      // Day of week number
      "visible": false
    }, {
      // Date printable
      "orderData": 3,
      "responsivePriority": 1
    }, {
      // Date sortable
      "visible": false
    }, {
      // Division name
      "orderData": 5,
      "responsivePriority": 5
    }, {
      // Division rank
      "visible": false
    }, {
      // Home team
      "responsivePriority": 2
    }, {
      // Away team
      "responsivePriority": 3
    }, {
      // Score
      "responsivePriority": 4
    }, {
      // Venue
      "responsivePriority": 7
    }]*/
  });
});