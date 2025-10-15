/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#report").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, $("#dt-lang").data("dt-paging-all")]],
    info: true,
    fixedHeader: true,
    colReorder: true,
    orderFixed: {pre: [0, "desc"]},
    rowGroup: {
      dataSrc: 0,
    },
    columnDefs: [{
      visible: false,
      targets: [0, 6, 8] // Total games, sortable data, sortable division
    }, {
      // Home team
      responsivePriority: 1,
      targets: 1
    }, {
      // Home games
      responsivePriority: 3,
      targets: 2
    }, {
      // Away team
      responsivePriority: 2,
      targets: 3
    }, {
      // Away games
      responsivePriority: 4,
      targets: 4
    }, {
      // Match score
      responsivePriority: 5,
      targets: 5
    }, {
      // Date
      orderData: 6,
      responsivePriority: 6,
      targets: 7
    }, {
      // Division
      orderData: 8,
      responsivePriority: 7,
      targets: 9
    }]
  });
  
  $("select").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});