/**
 *  Match view functions
 *
 */
$(document).ready(function(){
  /*
    Initialise datatables
  */
  var games_table = $("#games-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 5}, // Game number
      {responsivePriority: 1}, // Result (X beat Y)
      {responsivePriority: 3}, // Detailed scores
      {responsivePriority: 2}, // Score (3-1)
      {responsivePriority: 4} // Match score
    ]
  });
  
  var teams_table = $("#teams-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columns: [
      {responsivePriority: 1}, // Team
      {responsivePriority: 2}, // Division
      {responsivePriority: 3}, // Handicap
      {responsivePriority: 5}, // Legs won
      {responsivePriority: 4}, // Legs average
      {responsivePriority: 7}, // Points won
      {responsivePriority: 6} // Points average
    ]
  });
  
  var players_table = $("#players-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    rowGroup: {
      dataSrc: 0
    },
    columns: [
      {visible: false},
      {responsivePriority: 1},
      {responsivePriority: 2},
      {responsivePriority: 3},
      {responsivePriority: 4},
      {responsivePriority: 8},
      {responsivePriority: 5},
      {responsivePriority: 6},
      {responsivePriority: 9},
      {responsivePriority: 7}
    ]
  });
  
  /*
    Initialise responsive tabs
 */
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if (tab.selector == "#games") {
        // Recalculate the games table
        games_table.responsive.recalc();
      } else if (tab.selector == "#teams") {
        // Recalculate the teams table
        teams_table.responsive.recalc();
      } else if (tab.selector == "#players") {
        // Recalculate the players tables
        players_table.responsive.recalc();
      }
    }
  });
});
  