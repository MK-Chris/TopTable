/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("table.league-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1}, // Pos
      {"responsivePriority": 2}, // Team / competitor
      {"responsivePriority": 5}, // Played
      {"responsivePriority": 6}, // Won
      {"responsivePriority": 8}, // Drawn
      {"responsivePriority": 7}, // Lost
      {"responsivePriority": 3}, // For
      {"responsivePriority": 4} // Against
    ],
  });
});