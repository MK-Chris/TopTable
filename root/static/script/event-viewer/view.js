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
    order: [[2, "desc"]],
    columns: [{
      responsivePriority: 3
    }, {
      visible: false
    }, {
      orderData: 1,
      responsivePriority: 1
    }, {
      responsivePriority: 4
    }, {
      responsivePriority: 2
    }]
  });
});