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
      {responsivePriority: 9}, // Won
      {responsivePriority: 11}, // Drawn
      {responsivePriority: 10}, // Lost
      {responsivePriority: 7}, // For
      {responsivePriority: 8}, // Against
      {responsivePriority: 5}, // Handicap
      {responsivePriority: 4}, // Points / games difference
      {responsivePriority: 2, className: "rank-priority all"} // Points
    ],
  });
});