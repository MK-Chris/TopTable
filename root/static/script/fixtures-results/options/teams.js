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
    "rowGroup": {
      "dataSrc": 0
    },
    "columnDefs": [{
      // Club
      "visible": 0,
      "targets": 0
    }, {
      // Team
      "responsivePriority": 1,
      "targets": 1
    }, {
      // Number of matches
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