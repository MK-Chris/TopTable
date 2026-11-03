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
    ordering: false,
    fixedHeader: isMobile ? false : true,
    searching: false
  });
});
