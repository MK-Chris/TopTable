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
    columnDefs: [{
      // Game number
      targets: 0,
      responsivePriority: 5
    }, {
      // Result (X beat Y)
      targets: 1,
      responsivePriority: 1
    }, {
      // Detailed scores
      targets: 2,
      responsivePriority: 3
    }, {
      // Score (3-1)
      targets: 3,
      responsivePriority: 2
    }, {
      // Match score
      targets: 4,
      responsivePriority: 4
    }]
  });
  
  var teams_table = $("#teams-table").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: false,
    fixedHeader: true,
    searching: false,
    columnDefs: [{
      // Team
      targets: 0,
      responsivePriority: 1
    }, {
      // Division
      targets: 1,
      responsivePriority: 2
    }, {
      // Legs won
      targets: 2,
      responsivePriority: 4
    }, {
      // Legs average
      targets: 3,
      responsivePriority: 3
    }, {
      // Points won
      targets: 4,
      responsivePriority: 6
    }, {
      // Points average
      targets: 5,
      responsivePriority: 5
    }]
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
  