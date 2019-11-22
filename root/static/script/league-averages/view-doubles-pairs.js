/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  /*
    Focus on the first available field
  */
  $("#averages-doubles-pairs").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 7},
      {"responsivePriority": 4},
      {"responsivePriority": 5},
      {"responsivePriority": 6},
      {"responsivePriority": 3}
    ]
  });
});