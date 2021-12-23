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
    "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
    "info": true,
    "fixedHeader": true,
    "order": [[1, "asc"]],
    "columnDefs": [{
      "targets": [2, 6, 8, 10],
      "visible": false
    }, {
      "targets": 3,
      "orderData": 2
    }, {
      "targets": 7,
      "orderData": 6
    }, {
      "targets": 9,
      "orderData": 8
    }, {
      "targets": 11,
      "orderData": 10
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});
