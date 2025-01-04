/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    responsive: true,
    paging: false,
    fixedHeader: true,
    searching: false,
    info: false,
    orderFixed: {pre: [1, "asc"]},
    order: [[2, "asc"]],
    ordering: true,
    rowGroup: {
      dataSrc: 1
    },
    columnDefs: [{
      // Competition sort, competition (grouped)
      visible: false,
      targets: [0, 1]
    }, {
      // Competition - invisible, as it's grouped
      visible: false,
      targets: 1,
      orderData: 0
    }, {
      // Home team
      responsivePriority: 1,
      orderable: false,
      targets: 2
    }, {
      // Home handicap
      responsivePriority: 4,
      orderable: false,
      targets: 3
    }, {
      // Away team
      responsivePriority: 2,
      orderable: false,
      targets: 4
    }, {
      // Away handicap
      responsivePriority: 5,
      orderable: false,
      targets: 5
    }, {
      // Venue / score
      responsivePriority: 3,
      orderable: false,
      targets: 6
    }]
  });
});