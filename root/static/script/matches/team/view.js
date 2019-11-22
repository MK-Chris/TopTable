/**
 *  Match view functions
 *
 */
$(document).ready(function(){
  /*
    Initialise datatables
  */
  var games_table = $("#games-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 4},
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 3}
    ]
  });
  
  var teams_table = $("#teams-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1},
      {"responsivePriority": 3},
      {"responsivePriority": 2},
      {"responsivePriority": 5},
      {"responsivePriority": 4}
    ]
  });
  
  var home_players_table = $("#home-players-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 3},
      {"responsivePriority": 4},
      {"responsivePriority": 8},
      {"responsivePriority": 5},
      {"responsivePriority": 6},
      {"responsivePriority": 9},
      {"responsivePriority": 7}
    ]
  });
  
  var away_players_table = $("#away-players-table").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false,
    "columns": [
      {"responsivePriority": 1},
      {"responsivePriority": 2},
      {"responsivePriority": 3},
      {"responsivePriority": 4},
      {"responsivePriority": 8},
      {"responsivePriority": 5},
      {"responsivePriority": 6},
      {"responsivePriority": 9},
      {"responsivePriority": 7}
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
      } else if (tab.selector == "#teams") {
        // Recalculate the players tables
        home_players_table.responsive.recalc();
        away_players_table.responsive.recalc();
      }
    }
  });
});
  