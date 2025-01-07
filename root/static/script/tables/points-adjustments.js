/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#adjustments").DataTable({
    responsive: true,
    paging: false,
    info: false,
    ordering: true,
    fixedHeader: true,
    searching: false,
    orderFixed: {pre: [0, "asc"]},
    order: [2, "asc"],
    ordering: true,
    rowGroup: {
      dataSrc: 0
    },
    columnDefs: [{
      // Team, timestamp sortable
      visible: false,
      targets: [0, 1]
    }, {
      // Timestamp
      responsivePriority: 3,
      orderData: 1,
      targets: 2
    }, {
      // Adjustment
      responsivePriority: 1,
      targets: 3
    }, {
      // Reason
      responsivePriority: 2,
      targets: 4
    }]
  });
});