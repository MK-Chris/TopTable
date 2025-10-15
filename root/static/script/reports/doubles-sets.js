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
      targets: [0, 2] // Number of sets, sortable division rank
    }, {
      // Team
      orderData: 1,
      responsivePriority: 1,
      targets: 1
    }, {
      // Division
      orderData: 2,
      responsivePriority: 2,
      targets: 3
    }]
  });
  
  $("select").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});