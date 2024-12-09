/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    searching: true,
    orderFixed: {
      pre: [[1, "asc"], [3, "asc"]]
    },
    order: [7, "asc"],
    ordering: true,
    rowGroup: {
      dataSrc: [1, 3]
    },
    columnDefs: [{
      /*
        0 = week beginning sortable
        1 = week beginning (used in group)
        2 = competition sort
        3 = competitions name (used in group)
        4 = week day sortable
        6 = date sortable
      */
      visible: false,
      targets: [0, 1, 2, 3, 4, 6]
    }, {
      // Week beginning
      orderData: 0,
      targets: 1
    }, {
      // Competition
      orderData: 2,
      targets: 3
    }, {
      // Day name
      responsivePriority: 5,
      orderData: 4,
      targets: 5
    }, {
      // Date printable
      responsivePriority: 3,
      orderData: 6,
      targets: 7
    }, {
      // Home team
      responsivePriority: 1,
      targets: 8
    }, {
      // Home handicap
      responsivePriority: 5,
      targets: 9
    }, {
      // Away team
      responsivePriority: 2,
      targets: 10
    }, {
      // Away handicap
      responsivePriority: 6,
      targets: 11
    }, {
      // Score
      responsivePriority: 4,
      orderable: false,
      targets: 12
    }, {
      // Venue
      responsivePriority: 8,
      targets: 13
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});