document.addEventListener("DOMContentLoaded", function() {
    var h2hPlaceholders = document.querySelectorAll(".h2h-icon-trigger");

    Array.prototype.forEach.call(h2hPlaceholders, function(placeholder) {
        let iconUrl = placeholder.getAttribute("data-icon");
        let iconTitle = placeholder.getAttribute("data-button-title");
        
        let img = document.createElement("img");
        img.src = iconUrl;
        img.alt = iconTitle;
        img.title = iconTitle;
        img.style.cursor = "pointer";
        img.style.verticalAlign = "middle";
        img.style.marginLeft = "5px";
        
        placeholder.appendChild(img);
        
        placeholder.addEventListener("click", function(e) {
            e.preventDefault();
            
            // Using "this" inside the handler securely binds to the clicked element scope
            let targetUri = this.getAttribute("data-h2h-uri");
            let singleOpponent = this.getAttribute("data-opponent");
            let opponent1 = this.getAttribute("data-opponent1");
            let opponent2 = this.getAttribute("data-opponent2");
            
            let form = document.createElement("form");
            form.method = "POST";
            form.action = targetUri;
            
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
});
