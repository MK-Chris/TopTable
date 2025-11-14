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
    orderFixed: {pre: [1, "desc"]},
    rowGroup: {
      dataSrc: 1,
    },
    columnDefs: [{
      visible: false,
      targets: [0, 1, 2, 4, 6, 9] // Score sortable, score display (grouped), winner sortable, opponent sortable, division sortable
    }, {
      // Score
      orderData: 0,
      targets: 1
    }, {
      // Date
      orderData: 2,
      responsivePriority: 5,
      targets: 3
    }, {
      // Winner
      orderData: 4,
      responsivePriority: 1,
      targets: 5
    }, {
      // Opponent
      orderData: 6,
      responsivePriority: 2,
      targets: 7
    }, {
      // Match
      responsivePriority: 3,
      targets: 8
    }, {
      // Division
      orderData: 9,
      responsivePriority: 4,
      targets: 10
    }]
  });
  
  $("select").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});