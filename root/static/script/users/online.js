$(document).ready(function(){
  /**
   *  Initialise datatables
   *
   */
  let isMobile = window.matchMedia("(max-width: 767px)").matches;
  
  $("#datatable").DataTable({
    responsive: true,
    paging: false,
    info: true,
    fixedHeader: isMobile ? false : true,
    columnDefs: [{
      visible: false,
      targets: 6
    }, {
      orderData: 6,
      targets: 5
    }]
  });
});
