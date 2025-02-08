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
      responsivePriority: 13,
      targets: 0
    }, {
      // Group position
      responsivePriority: 3,
      targets: 1
    }, {
      // Entrant (team / player / pair)
      responsivePriority: 2,
      targets: 2
    }, {
      // Matches played
      responsivePriority: 10,
      targets: 3
    }, {
      // Won
      responsivePriority: 8,
      targets: 4
    }, {
      // Drawn
      responsivePriority: 11,
      targets: 5
    }, {
      // Lost
      responsivePriority: 9,
      targets: 6
    }, {
      // For
      responsivePriority: 6,
      targets: 7
    }, {
      // Against
      responsivePriority: 7,
      targets: 8
    }, {
      // Handicap
      responsivePriority: 12,
      targets: 9
    }, {
      // Points / games difference
      responsivePriority: 5,
      targets: 10
    }, {
      // Points
      responsivePriority: 4,
      targets: 11
    }]
  });
  
  let select_tb = $("#non-auto-table").DataTable({
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
      // Selection ID (hidden)
      visible: 0,
      targets: 0
    }, {
      // Section checkbox
      responsivePriority: 1,
      targets: 1
    }, {
      // Group
      responsivePriority: 13,
      targets: 2
    }, {
      // Group position
      responsivePriority: 3,
      targets: 3
    }, {
      // Entrant (team / player / pair)
      responsivePriority: 2,
      targets: 4
    }, {
      // Matches played
      responsivePriority: 10,
      targets: 5
    }, {
      // Won
      responsivePriority: 8,
      targets: 6
    }, {
      // Drawn
      responsivePriority: 11,
      targets: 7
    }, {
      // Lost
      responsivePriority: 9,
      targets: 8
    }, {
      // For
      responsivePriority: 6,
      targets: 9
    }, {
      // Against
      responsivePriority: 7,
      targets: 10
    }, {
      // Handicap
      responsivePriority: 12,
      targets: 11
    }, {
      // Points / games difference
      responsivePriority: 5,
      targets: 12
    }, {
      // Points
      responsivePriority: 4,
      targets: 13
    }]
  });
  
  select_tb.on("click", "tbody tr", function(event) {
    let ent_id = select_tb.row(this).data()[0];
    
    if ( event.target.localName !== "a" ) {
      // Toggle checked property
      if ( $("#select-" + ent_id).prop("checked") ) {
        $("#select-" + ent_id).prettyCheckable("uncheck");
      } else {
        $("#select-" + ent_id).prettyCheckable("check");
      }
    }
  });
  
  $("select[name=auto-table_length], select[name=non-auto-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
  
  $("#accordion").accordion({heightStyle: "content"});
});