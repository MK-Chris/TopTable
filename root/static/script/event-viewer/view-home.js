/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  let isMobile = window.matchMedia("(max-width: 767px)").matches;
  
  $("#datatable").DataTable({
    responsive: true,
    paging: false,
    info: false,
    fixedHeader: isMobile ? false : true,
    searching: false,
    order: [[1, "desc"]],
    columns: [{
      visible: false,
      responsivePriority: 4
    }, {
      orderData: 0,
      responsivePriority: 1
    }, {
      responsivePriority: 3
    }, {
      responsivePriority: 2
    }]
  });
});