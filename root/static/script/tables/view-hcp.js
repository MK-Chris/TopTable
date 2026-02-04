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
      {responsivePriority: 7}, // Played
      {responsivePriority: 8}, // Won
      {responsivePriority: 10}, // Drawn
      {responsivePriority: 9}, // Lost
      {responsivePriority: 2, className: "rank-priority all"}, // For
      {responsivePriority: 4}, // Against
      {responsivePriority: 6}, // Handicap
      {responsivePriority: 5} // Points / games difference
    ],
  });
});