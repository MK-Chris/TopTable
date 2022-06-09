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
      // Week beginning, week beginning sortable, date sortable, division rank - not visible, just used for sorting and / or grouping
      "visible": false,
      "targets": [0, 1, 3, 5]
    }, {
      // Week beginning
      "orderData": 1,
      "targets": 0
    }, {
      // Date
      "orderData": 3,
      "responsivePriority": 4,
      "targets": 2
    }, {
      // Division
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
    allow_single_deselect: true
  });
});