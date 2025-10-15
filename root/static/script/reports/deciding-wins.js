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
      targets: [0, 1, 4] // Number of sets, sortable player name, sortable division rank
    }, {
      // Player name
      orderData: 1,
      responsivePriority: 1,
      targets: 2
    }, {
      // Registered team
      orderData: 2,
      responsivePriority: 2,
      targets: 3
    }, {
      // Registered division
      orderData: 4,
      responsivePriority: 3,
      targets: 5
    }]
  });
  
  $("select").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});