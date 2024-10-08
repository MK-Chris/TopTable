/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#fixtures-table").DataTable({
    "responsive": true,
    "paging": true,
    "pageLength": 25,
    //pagingType: "full_numbers",
    "lengthChange": true,
    "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    "info": true,
    "fixedHeader": true,
    "searching": true,
    "ordering": true,
    "orderFixed": {"pre": [0, "asc"]},
    "order": [[1, "asc"], [3, "asc"], [5, "asc"]],
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Week beginning (grouped by), week beginning sortable, date sortable, competition sort
      "visible": false,
      "targets": [0, 1, 3, 5]
    }, {
      // Week beginning - order by data in column 0
      "orderData": 1,
      "targets": 0
    }, {
      // Date
      "orderData": 3,
      "responsivePriority": 4,
      "targets": 2
    }, {
      // Competition
      "orderData": 5,
      "responsivePriority": 5,
      "targets": 4
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 6
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 7
    }, {
      // Score
      "responsivePriority": 3,
      "orderable": false,
      "targets": 8
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});