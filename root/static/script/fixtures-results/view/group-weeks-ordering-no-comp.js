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
    order: [[5, "asc"], [6, "asc"]],
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
      // Week day
      orderData: 2,
      responsivePriority: 7,
      targets: 3
    }, {
      // Date
      orderData: 4,
      responsivePriority: 5,
      targets: 5
    }, {
      // Home team
      responsivePriority: 1,
      targets: 6
    }, {
      // Away team
      responsivePriority: 2,
      targets: 7
    }, {
      // Score
      responsivePriority: 3,
      orderable: false,
      targets: 8
    }, {
      // Venue
      responsivePriority: 6,
      targets: 9
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});