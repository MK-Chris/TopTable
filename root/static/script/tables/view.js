/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("table.league-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 3}, // Pos
      {responsivePriority: 1}, // Team / competitor
      {responsivePriority: 6}, // Played
      {responsivePriority: 7}, // Won
      {responsivePriority: 9}, // Drawn
      {responsivePriority: 8}, // Lost
      {responsivePriority: 2, className: "rank-priority all"}, // For
      {responsivePriority: 4}, // Against
      {responsivePriority: 5} // Points / games difference
    ],
  });
});