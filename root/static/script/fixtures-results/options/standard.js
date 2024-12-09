/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-options").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "searching": true,
    "order": [0, "asc"],
    "ordering": true,
    "columnDefs": [{
      // Option column
      "responsivePriority": 1,
      "targets": 0
    }, {
      // Number of matches
      "responsivePriority": 1,
      "targets": 1
    }]
  });
  
  $("select[name=fixtures-options_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});