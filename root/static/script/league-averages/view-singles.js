/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#averages-singles").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 8},
      {"responsivePriority": 5},
      {"responsivePriority": 9},
      {"responsivePriority": 4},
      {"responsivePriority": 6},
      {"responsivePriority": 7},
      {"responsivePriority": 3}
    ]
  });
});