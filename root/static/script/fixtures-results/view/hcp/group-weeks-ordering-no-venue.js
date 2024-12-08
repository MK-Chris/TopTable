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
    ordering: true,
    orderFixed: {pre: [1, "asc"]},
    order: [[5, "asc"], [7, "asc"], [8, "asc"]],
    rowGroup: {
      dataSrc: 1
    },
    columnDefs: [{
      // Week beginning sortable, week beginning (grouped by), date sortable, day sortable, competition sortable
      visible: false,
      targets: [0, 1, 2, 4, 6]
    }, {
      // Week beginning - order by data in column 0
      orderData: 0,
      targets: 1
    }, {
      // Day
      orderData: 2,
      responsivePriority: 6,
      targets: 3
    }, {
      // Date
      orderData: 4,
      responsivePriority: 3,
      targets: 5
    }, {
      // Competition
      orderData: 6,
      responsivePriority: 5,
      targets: 7
    }, {
      // Home team
      responsivePriority: 6,
      targets: 8
    }, {
      // Home handicap
      responsivePriority: 1,
      targets: 8
    }, {
      // Away team
      responsivePriority: 6,
      targets: 9
    }, {
      // Away handicap
      responsivePriority: 7,
      targets: 9
    }, {
      // Score
      responsivePriority: 4,
      orderable: false,
      targets: 10
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});