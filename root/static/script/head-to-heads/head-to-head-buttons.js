document.addEventListener("DOMContentLoaded", function() {
  // EXPORT REUSABLE ACCESSIBLE UTILITY
  window.initializeH2hIcons = function() {
    var h2hPlaceholders = document.querySelectorAll(".h2h-icon-trigger");

    Array.prototype.forEach.call(h2hPlaceholders, function(placeholder) {
      if (placeholder.children.length === 0) {
        var iconUrl = placeholder.getAttribute("data-icon");
        var iconTitle = placeholder.getAttribute("data-button-title");
        
        var img = document.createElement("img");
        img.src = iconUrl;
        img.alt = iconTitle;
        img.title = iconTitle;
        img.style.cursor = "pointer";
        img.style.verticalAlign = "middle";
        img.style.marginLeft = "5px";
        
        placeholder.appendChild(img);
      }
    });
  };

  window.initializeH2hIcons();

  // UNIVERSAL DELEGATED CLICK LISTENER
  document.body.addEventListener("click", function(e) {
    let trigger = e.target.closest(".h2h-icon-trigger");
    if (!trigger) return;
    
    e.preventDefault();
    
    let targetUrl = trigger.getAttribute("data-h2h-uri");
    let singleOpponent = trigger.getAttribute("data-opponent");
    let singleOpponentName = trigger.getAttribute("data-opponent-name"); // Pull the clean string name
    let opponent1 = trigger.getAttribute("data-opponent1");
    let opponent2 = trigger.getAttribute("data-opponent2");
    let opponent1Name = trigger.getAttribute("data-opponent1-name");
    let opponent2Name = trigger.getAttribute("data-opponent2-name");
    
    let textOpponentField = document.getElementById("opponent");
    let textOpponentsField = document.getElementById("opponents");
    
    // =======================================================
    // INTERCEPTION: Same-Page jQuery tokenInput API Trigger
    // =======================================================
    if ((textOpponentField && singleOpponent) || (textOpponentsField && opponent1Name && opponent2Name)) {
        let targetPathHelper = document.createElement("a");
        targetPathHelper.href = targetUrl;
        
        // Extract pure directories by splitting on tokens and stripping trailing slashes
        let currentBrowserPath = window.location.pathname.split(/[?#]/)[0].replace(/\/$/, "");
        let targetIconPath = targetPathHelper.pathname.split(/[?#]/)[0].replace(/\/$/, "");
        
        // If the paths align, use the plugin's API methods directly
        if (targetIconPath === currentBrowserPath) {
          // Wrap our native input selector with jQuery to gain access to tokenInput methods
          let $tokenField = singleOpponent ? jQuery(textOpponentField) : jQuery(textOpponentsField);
          
          if (typeof $tokenField.tokenInput === "function") {
            // 1. Clear out any previous tokens currently sitting in the box layout
            $tokenField.tokenInput("clear");
            
            // 2. Add the newly clicked token. 
            // This updates the interface and executes the onAdd callback function
            if ( singleOpponent ) {
              $tokenField.tokenInput("add", {
                id: singleOpponent,
                name: singleOpponentName || singleOpponent
              });
            } else {
              console.log("doubles", "add id1: " + opponent1 + ", name1: " + opponent1Name + ", id2: " + opponent2 + ", name2: " + opponent2Name);
              let populated = $tokenField.tokenInput("get");
              console.log("populated", populated);
              $tokenField.tokenInput("add", {
                id: opponent1,
                name: opponent1Name || opponent1
              });
              
              $tokenField.tokenInput("add", {
                id: opponent2,
                name: opponent2Name || opponent2
              });
            }
            
            // =======================================================
            // DYNAMIC TAB ACTIVATION OPTIMIZATION
            // =======================================================
            // 2. Locate all tab anchor nodes inside your active responsive tab list container
            let tabLinks = document.querySelectorAll("div#tabs ul li a");
            let targetIndex = -1;
            
            // Loop through the layout links to find which index points to the #head-to-head pane
            for (let i = 0; i < tabLinks.length; i++) {
              // Extract the href link target attribute (e.g. "#head-to-head")
              let hrefAttr = tabLinks[i].getAttribute("href");
              if (hrefAttr === "#head-to-head") {
                targetIndex = i;
                break;
              }
            }
            
            $("div#tabs").responsiveTabs("activate", targetIndex);
            
            return; // Stop execution safely, bypassing all page reloads
        }
      }
    }
    // =======================================================

    // FALLBACK: Standard Cross-Page Redirect (POST Form Generation)
    let form = document.createElement("form");
    form.method = "POST";
    form.action = targetUrl;
    
    if (singleOpponent) {
      let input = document.createElement("input");
      input.type = "hidden";
      input.name = "opponent";
      input.value = singleOpponent;
      form.appendChild(input);
    }
    
    if (opponent1) {
      let input1 = document.createElement("input");
      input1.type = "hidden";
      input1.name = "opponents";
      input1.value = opponent1;
      form.appendChild(input1);
    }
    
    if (opponent2) {
      let input2 = document.createElement("input");
      input2.type = "hidden";
      input2.name = "opponents";
      input2.value = opponent2;
      form.appendChild(input2);
    }
    
    document.body.appendChild(form);
    form.submit();
  });
});
