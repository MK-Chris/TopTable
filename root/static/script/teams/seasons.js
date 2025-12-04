/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  $("#datatable").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    //pagingType: "full_numbers",
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    order: [1, "desc"],
    columnDefs: [{
      // Season sort, division rank, captain name sort
      visible: false,
      targets: [0, 4, 7]
    }, {
      // Season name
      orderData: 0,
      responsivePriority: 1,
      targets: 1
    }, {
      // Registered name
      responsivePriority: 4,
      targets: 2
    }, {
      // Club name
      responsivePriority: 5,
      targets: 3
    }, {
      // Division
      orderData: 4,
      responsivePriority: 2,
      targets: 5
    }, {
      // League position
      responsivePriority: 3,
      targets: 6
    }, {
      // Captain name
      orderData: 7,
      responsivePriority: 6,
      targets: 8
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});
