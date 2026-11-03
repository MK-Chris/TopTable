/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  let isMobile = window.matchMedia("(max-width: 767px)").matches;
  
  $("#datatable").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    //pagingType: "full_numbers",
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info : true,
    fixedHeader: isMobile ? false : true,
    columnDefs: [{
      visible: false,
      targets: [2, 4, 6]
    }, {
      orderData: 2,
      targets: 1
    }, {
      orderData: 4,
      targets: 3
    }, {
      orderData: 6,
      targets: 5
    }]
  });
  
  $("select[name=datatable_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
});