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
    "order": [2, "asc"],
    "orderFixed": [0, "asc"],
    "ordering": true,
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Week beginning, week beginning sortable, date sortable
      "visible": 0,
      "targets": [0, 1, 3]
    }, {
      // Week beginning
      "orderData": 1,
      "targets": 0
    }, {
      // Date
      "responsivePriority": 1,
      "orderData": 3,
      "targets": 2
    }, {
      // Number of matches
      "responsivePriority": 2,
      "targets": 4
    }]
  });
  
  $("select[name=fixtures-options_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});