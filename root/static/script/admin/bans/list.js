/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#bans-list").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "columnDefs": [{
      "visible": false,
      "targets": [1, 7]
    }, {
      "orderData": 1,
      "targets": 2
    }, {
      "orderData": 7,
      "targets": 8
    }]
  });
  
  $("select[name=bans-list_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});
