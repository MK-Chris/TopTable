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
    "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
    "info": true,
    "fixedHeader": true,
    "searching": true,
    "ordering": true,
    "order": [[1, "asc"], [3, "asc"], [5, "asc"]],
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Week beginning, date sortable, division rank - not visible, just used for sorting
      "visible": false,
      "targets": [0, 2, 4]
    }, {
      // Date
      "responsivePriority": 4,
      "targets": 1,
      "orderData": 2
    }, {
      // Division
      "responsivePriority": 5,
      "targets": 3,
      "orderData": 4
    }, {
      // Home team
      "responsivePriority": 1,
      "targets": 5
    }, {
      // Away team
      "responsivePriority": 2,
      "targets": 6
    }, {
      // Score
      "responsivePriority": 3,
      "targets": 7
    }]
  });
  
  $("select[name=fixtures-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true
  });
});