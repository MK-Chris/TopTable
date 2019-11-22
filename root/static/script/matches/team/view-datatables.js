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
  
  var players_tables = $("#home-players-table, #away-players-table").DataTable({
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
});
