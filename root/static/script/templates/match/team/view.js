$(document).ready(function(){
  /**
   *  Initialise datatables
   *
   */
  $("#datatable").DataTable({
    "responsive": true,
    "paging": false,
    "info": false,
    "ordering": false,
    "fixedHeader": true,
    "searching": false
  });
});
