/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#auto-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 10,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    searching: true,
    ordering: false,
    columnDefs: [{
      // Group
      responsivePriority: 11,
      targets: 0
    }, {
      // Group position
      responsivePriority: 2,
      targets: 1
    }, {
      // Entrant (team / player / pair)
      responsivePriority: 1,
      targets: 2
    }, {
      // Matches played
      responsivePriority: 8,
      targets: 3
    }, {
      // Won
      responsivePriority: 7,
      targets: 4
    }, {
      // Drawn
      responsivePriority: 10,
      targets: 5
    }, {
      // Lost
      responsivePriority: 9,
      targets: 6
    }, {
      // For
      responsivePriority: 5,
      targets: 7
    }, {
      // Against
      responsivePriority: 6,
      targets: 8
    }, {
      // Points / games difference
      responsivePriority: 4,
      targets: 9
    }, {
      // Points
      responsivePriority: 3,
      targets: 10
    }]
  });
  
  $("#non-auto-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: -1,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    searching: true,
    ordering: false,
    columnDefs: [{
      // Group
      responsivePriority: 11,
      targets: 0
    }, {
      // Group position
      responsivePriority: 2,
      targets: 1
    }, {
      // Entrant (team / player / pair)
      responsivePriority: 1,
      targets: 2
    }, {
      // Matches played
      responsivePriority: 8,
      targets: 3
    }, {
      // Won
      responsivePriority: 7,
      targets: 4
    }, {
      // Drawn
      responsivePriority: 10,
      targets: 5
    }, {
      // Lost
      responsivePriority: 9,
      targets: 6
    }, {
      // For
      responsivePriority: 5,
      targets: 7
    }, {
      // Against
      responsivePriority: 6,
      targets: 8
    }, {
      // Points / games difference
      responsivePriority: 4,
      targets: 9
    }, {
      // Points
      responsivePriority: 3,
      targets: 10
    }]
  });
  
  $("select[name=auto-table_length], select[name=non-auto-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});