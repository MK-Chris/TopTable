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
      // Season sort, registered name sort, division sort
      visible: false,
      targets: [0, 2, 5]
    }, {
      // Season
      orderData: 0,
      responsivePriority: 1,
      targets: 1
    }, {
      // Person name
      orderData: 3,
      responsivePriority: 6,
      targets: 2
    }, {
      // Division
      orderData: 5,
      responsivePriority: 2,
      targets: 6
    }, {
      // Played
      responsivePriority: 3,
      targets: 7
    }, {
      // Won
      responsivePriority: 4,
      targets: 8
    }, {
      // Average
      responsivePriority: 5,
      targets: 9
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});
