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
      // Date display
      "orderData": 1,
      "responsivePriority": 5,
      "targets": 0
    }, {
      // Date sortable
      "visible": false,
      "responsivePriority": 4,
      "targets": 1
    }/*, {
      // Playing against (team)
      "responsivePriority": 3,
      "targets": 3
    }*/, {
      // Opponent (player)
      "responsivePriority": 1,
      "targets": 4
    }/*, {
      // Score
      "orderable": false,
      "targets": 5
    }*/, {
      // Result
      "orderable": false,
      "responsivePriority": 2,
      "targets": 6
    }]
  });
});