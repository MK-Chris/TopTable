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
      // Month sort data
      "visible": false,
      "targets": 1
    }, {
      // Month
      "responsivePriority": 1,
      "orderData": 1,
      "targets": 0
    }, {
      // Number
      "responsivePriority": 2,
      "targets": 2
    }]
  });
  
  $("select[name=fixtures-options_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});