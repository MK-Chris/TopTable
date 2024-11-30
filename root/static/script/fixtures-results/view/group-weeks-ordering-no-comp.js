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
    order: [[2, "asc"], [4, "asc"]],
    rowGroup: {
      dataSrc: 1
    },
    columnDefs: [{
      // Week beginning sortable, week beginning (grouped by), date sort, day sort
      visible: false,
      targets: [0, 1, 2, 4]
    }, {
      // Week beginning - order by data in column 0
      orderData: 0,
      targets: 1
    }, {
      // Date
      orderData: 3,
      responsivePriority: 4,
      targets: 2
    }, {
      // Date
      orderData: 3,
      responsivePriority: 4,
      targets: 2
    }, {
      // Home team
      responsivePriority: 1,
      targets: 4
    }, {
      // Away team
      responsivePriority: 2,
      targets: 5
    }, {
      // Score
      responsivePriority: 3,
      orderable: false,
      targets: 6
    }, {
      // Venue
      responsivePriority: 5,
      targets: 7
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});