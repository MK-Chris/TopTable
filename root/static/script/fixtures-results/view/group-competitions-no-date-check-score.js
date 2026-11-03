/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  let isMobile = window.matchMedia("(max-width: 767px)").matches;
  
  $("#fixtures-table").DataTable({
    responsive: true,
    paging: false,
    fixedHeader: isMobile ? false : true,
    searching: false,
    info: false,
    order: [[2, "asc"]],
    ordering: false,
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
      targets: 2
    }, {
      // Away team
      responsivePriority: 2,
      targets: 3
    }, {
      // Venue / score
      responsivePriority: 3,
      targets: 4
    }]
  });
});