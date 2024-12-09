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
    rowGroup: {
      dataSrc: 1
    },
    orderFixed: [1, "asc"],
    order: [[3, "asc"], [7, "asc"], [8, "asc"]],
    columnDefs: [{
      // Week beginning sort, week beginning (grouped), competition sort, day sort, date sort
      visible: false,
      targets: [0, 1, 2, 4, 6]
    }, {
      // Week beginning
      orderData: 0,
      targets: 1
    }, {
      // Competition
      responsivePriority: 5,
      orderData: 2,
      targets: 3
    }, {
      // Day
      responsivePriority: 6,
      orderData: 4,
      targets: 5
    }, {
      // Date
      responsivePriority: 4,
      orderData: 6,
      targets: 7
    }, {
      // Home team
      responsivePriority: 1,
      targets: 8
    }, {
      // Away team
      responsivePriority: 2,
      targets: 9
    }, {
      // Score
      responsivePriority: 3,
      orderable: false,
      targets: 10
    }, {
      // Venue
      responsivePriority: 5,
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