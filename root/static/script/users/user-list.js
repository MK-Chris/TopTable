/**
 *  Initialise datatable
 *
 */
$(document).ready(function(){
  var table = $("#datatable").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "order": [[1, "asc"]],
    "columnDefs": [{
      "targets": [1, 5, 7, 9],
      "visible": false
    }, {
      "targets": 2,
      "orderData": 1
    }, {
      "targets": 6,
      "orderData": 5
    }, {
      "targets": 8,
      "orderData": 7
    }, {
      "targets": 10,
      "orderData": 9
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});
