/**
 *  Initialise datatable
 *
 */
$(document).ready(function() {
  var singles_games = $("#singles-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    layout: {
      topStart: "pageLength",
      topEnd: "search",
      bottomStart: "info",
      bottomEnd: "paging",
      bottom2Start: "searchPanes"
    },
    searchPanes: {
      layout: "columns-6",
      collapse: false,
      clear: false,
      dtOpts: {
        select: {style: "multi"}
      }
    },
    language: {
      searchPanes: {
        emptyPanes: null,
        title: $("#dt-data-only").data("dt-filter")
      }
    },
    columnDefs: [{
      // Date display
      orderData: 1,
      responsivePriority: 6,
      searchPanes: {show: false},
      targets: 0
    }, {
      // Date sortable
      visible: false,
      searchPanes: {show: false},
      targets: 1
    }, {
      // Playing for (team)
      responsivePriority: 5,
      searchPanes: {show: false},
      targets: 2
    }, {
      // Playing against (team)
      responsivePriority: 4,
      searchPanes: {show: false},
      targets: 3
    }, {
      // Opponent (player)
      responsivePriority: 1,
      searchPanes: {show: false},
      targets: 4
    }, {
      // Score
      orderable: false,
      responsivePriority: 3,
      searchPanes: {show: false},
      targets: 5
    }, {
      // Result
      orderable: false,
      responsivePriority: 2,
      searchPanes: {show: false},
      targets: 6
    }, {
      // Membership type
      visible: false,
      searchPanes: {
        //show: true,
        controls: false
      },
      targets: 7
    }]
  });
  
  var doubles_games = $("#doubles-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    layout: {
      topStart: "pageLength",
      topEnd: "search",
      bottomStart: "info",
      bottomEnd: "paging",
      bottom2Start: "searchPanes"
    },
    searchPanes: {
      layout: "columns-6",
      collapse: false,
      clear: false,
      dtOpts: {
        select: {style: "multi"}
      }
    },
    language: {
      searchPanes: {
        emptyPanes: null,
        title: $("#dt-data-only").data("dt-filter")
      }
    },
    columnDefs: [{
      // Date display
      orderData: 1,
      responsivePriority: 5,
      searchPanes: {show: false},
      targets: 0
    }, {
      // Date sortable
      visible: false,
      responsivePriority: 5,
      searchPanes: {show: false},
      targets: 1
    }, {
      // Playing for (team)
      responsivePriority: 7,
      searchPanes: {show: false},
      targets: 2
    }, {
      // Playing against (team)
      responsivePriority: 6,
      searchPanes: {show: false},
      targets: 3
    }, {
      // Partner (player)
      responsivePriority: 1,
      searchPanes: {show: false},
      targets: 4
    }, {
      // Opponents (doubles pair)
      responsivePriority: 2,
      searchPanes: {show: false},
      targets: 5
    }, {
      // Score
      orderable: false,
      responsivePriority: 4,
      searchPanes: {show: false},
      targets: 6
    }, {
      // Result
      orderable: false,
      responsivePriority: 3,
      searchPanes: {show: false},
      targets: 7
    }, {
      // Membership type
      visible: false,
      searchPanes: {
        //show: true,
        controls: false
      },
      targets: 8
    }]
  });
  
  let frequent_opponents = $("#frequent-opponents-table").DataTable({
    responsive: true,
    paging: true,
    pageLength: 25,
    lengthChange: true,
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
    info: true,
    fixedHeader: true,
    order: [[3, "desc"], [0, "asc"]],
    columns: [{
      // Position
      data: "position",
      responsivePriority: 3,
      orderable: false
    }, {
      // Opponent
      data: "opponent-name",
      orderData: 1,
      responsivePriority: 1,
      render: function (data, type, row) {
        if (type === 'display') {
          let config = document.getElementById("h2h-config");
          let h2hUri = config.getAttribute("data-h2h-uri");
          let iconUri = config.getAttribute("data-icon");
          
          // Because we preserved 'h2h-data' in the loop, it's fully accessible here!
          let h2hTitle = row["h2h-data"].title;
          let opponentKey = row["h2h-data"].opponent_url_key;
          let opponentName = row["h2h-data"].opponent_name;

          // Construct the clean link using the pre-built 'data' link string and your span trigger layout
          let linkHtml = data + ' ' +
                        '<span class="h2h-icon-trigger" ' +
                        'data-h2h-uri="' + h2hUri + '" ' +
                        'data-opponent="' + opponentKey + '" ' +
                        'data-opponent-name="' + opponentName + '" ' +
                        'data-icon="' + iconUri + '" ' +
                        'data-button-title="' + h2hTitle + '"></span>';
                        
          return linkHtml;
        }
        return data;
      }
    }, {
      // Opponent (sortable)
      data: "opponent-name-sortable",
      visible: false
    }, {
      // Sets played
      data: "total-games",
      responsivePriority: 2
    }],
    drawCallback: function () {
      let api = this.api();
      let personClasses = api.column(1).header().className;
      api.column(0).header().className = personClasses;
      
      if (typeof window.initializeH2hIcons === "function") {
        // Automatically scans and paints the icons onto newly loaded elements
        window.initializeH2hIcons();
      }
  }
  });
  
  $("select[name=singles-table_length], select[name=doubles-table_length], select[name=frequent-opponents-table_length]").chosen({
    disable_search: true,
    single_backstroke_delete: false,
    allow_single_deselect: true,
    width: "75px"
  });
  
  /*
    Responsive tabs
  */
  let frequent_opponents_drawn = false;
  
  $("div#tabs").responsiveTabs({
    startCollapsed: false,
    setHash: false,
    activate: function(event, tab) {
      if ( tab.selector == "#singles-games" ) {
        // Redraw singles games table
        singles_games.responsive.recalc();
      } else if ( tab.selector == "#doubles-games" ) {
        // Redraw doubles games table
        doubles_games.responsive.recalc();
      } else if ( tab.selector == "#frequent-opponents" ) {
        let uri = $("#frequent-opponents-data").data("uri");
        
        console.log("URI", uri);
        if ( frequent_opponents_drawn === false ) {
          $.ajax({
            url: uri,
            type: "POST",
            dataType: "json",
            //data: {opponent: item.id},
            success: function(response) {
              // Process the games that have been returned
              let dt_rows = [];

              $.each(response.table, function(index) {
                // Start a clean, empty row data bucket
                let dt_row = {};
                
                $.each(response.table[index], function(key, val) {
                  // 1. SPECIAL CASE HANDLING: Pass h2h-data object straight through untouched
                  if (key === "h2h-data") {
                    dt_row[key] = val; // Preserves your 'title' and 'opponent-url-key' object properties
                  } 
                  // 2. Default field handling for everything else
                  else if (val && val.uri === undefined) {
                    // No URL, just display
                    dt_row[key] = val.display;
                  } else if (val) {
                    // Set a URL with the display text
                    dt_row[key] = '<a href="' + val.uri + '">' + val.display + '</a>';
                  }
                });
                
                dt_rows.push(dt_row);
              });
              
              opponent_populated = true;
              frequent_opponents.rows.add(dt_rows).draw();
            },
            error: function(xhr, ajax_options, thrown_error) {
              if ( typeof xhr.responseJSON === "undefined" ) {
                $().toastmessage("showToast", {
                  text: "<br />" + thrown_error + ": " + $("#frequent-opponents-data").data("txt-ajax-error-refresh"),
                  sticky: true,
                  position: "top-center",
                  type: "error"
                });
              } else {
                show_messages(xhr.responseJSON);
              }
            }
          });
          
          frequent_opponents_drawn = true;
        }
      }
    }
  });
});