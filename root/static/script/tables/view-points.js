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
      {"responsivePriority": 8}, // Won
      {"responsivePriority": 10}, // Drawn
      {"responsivePriority": 9}, // Lost
      {"responsivePriority": 6}, // For
      {"responsivePriority": 7}, // Against
      {"responsivePriority": 4}, // Points / games difference
      {"responsivePriority": 3} // Points
    ],
  });
});