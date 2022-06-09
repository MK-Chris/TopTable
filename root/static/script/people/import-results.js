$(document).ready(function(){
  /**
   *  Initialise datatables
   *
   */
  $("#failed-imports, #successful-imports").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "ordering": true,
    "fixedHeader": true,
    "searching": true
  });
  
  $("select[name=successful-imports_length], select[name=failed-imports_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});
