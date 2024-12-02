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
    orderFixed: {pre: [5, "asc"]},
    order: [1, "asc"],
    ordering: true,
    rowGroup: {
      dataSrc: 5
    },
    columnDefs: [{
      // Date sortable, week day sortable, competition sortable, competition (used in group)
      visible: false,
      targets: [0, 2, 4, 5]
    }, {
      // Date
      responsivePriority: 3,
      orderData: 0,
      targets: 1
    }, {
      // Week day
      responsivePriority: 7,
      orderData: 2,
      targets: 3
    }, {
      // Competition
      orderData: 4,
      targets: 5
    }, {
      // Home team
      responsivePriority: 1,
      targets: 6
    }, {
      // Home handicap
      responsivePriority: 5,
      targets: 7
    }, {
      // Away team
      responsivePriority: 2,
      targets: 8
    }, {
      // Away handicap
      responsivePriority: 6,
      targets: 9
    }, {
      // Score
      responsivePriority: 4,
      orderable: false,
      targets: 10
    }, {
      // Venue
      responsivePriority: 8,
      targets: 11
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});