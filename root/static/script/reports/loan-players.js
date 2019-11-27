/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  var report_table = $("#report").DataTable({
    responsive: true,
    paging: true,
    pageLength: 30,
    lengthChange: false,
    info: true,
    fixedHeader: true,
    colReorder: {
      fixedColumnsLeft: 1
    },
    rowGroup: {
      enable: false,
      dataSrc: 0,
      startRender: function (rows, group) {
        return group + " (" + rows.count() + " rows)";
      }
    },
    columnDefs: [{
      visible: false,
      targets: [4, 6, 9]
    }, {
      orderData: 4,
      targets: 3
    }, {
      orderData: 6,
      targets: 5
    }, {
      orderData: 9,
      targets: 8
    }]
  });
  
  /*
    Put the checkbox inside the table div.
  */
  $("#report-grouper").prependTo("#report_wrapper");
  
  /*
    Handle chosen selectbox change
  */
  $("#group-table").on("change", function() {
    var $this = $(this);
    
    // Set the previous column to visible.
    var $previous_value = $this.data("previous-value");
    report_table.column($previous_value).visible(true);
    
    if ( $this.val() === "" ) {
      // No grouping, disable grouping and redraw the table
      report_table.columns.adjust();
      report_table.rowGroup().disable().draw();
    } else {
      // Group by select value's column index
      report_table.column( $this.val() ).visible(false);
      report_table.columns.adjust();
      report_table.rowGroup().dataSrc( $this.val() );
      report_table.rowGroup().enable().draw();
    }
    
    // Set the previous value
    $this.data("previous-value", $this.val());
  });
});