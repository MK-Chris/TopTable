/**
 * Hybrid Event-Delegated progressive Navigation Controller (5+ Levels Safe)
 * Seamlessly Synchronizes Natural Desktop Hovers with SmartMenus Tap-To-Navigate.
 */
document.addEventListener("DOMContentLoaded", function () {
  let hamButton = document.getElementById("gen-ham");
  let navContainer = document.getElementById("gen-nav");
  let menuList = document.getElementById("gen-menu");
  let moreBtn = document.getElementById("gen-more-btn");
  let moreSubmenu = document.getElementById("gen-more-submenu");

  if (!menuList || !moreBtn || !moreSubmenu || !navContainer) return;

  // Gather top-level menu nodes to track initial structural widths
  let items = Array.from(menuList.children).filter(function(item) {
    return item !== moreBtn;
  });

  // 1. Mobile Menu Drawer Toggle Click Handler
  if (hamButton) {
    hamButton.addEventListener("click", function() {
      let isOpen = menuList.classList.toggle("open");
      navContainer.classList.toggle("mobile-open", isOpen);
    });
  }

  // 2. Pure Calculation Truncation Engine
  function calculateOverflow() {
    let isMobile = hamButton && getComputedStyle(hamButton).display !== "none";

    items.forEach(function(el) { el.removeAttribute("data-overflow"); });
    moreSubmenu.innerHTML = "";
    moreBtn.style.display = "none";
    menuList.classList.remove("has-overflow-active");

    if (isMobile) return; 

    let containerWidth = menuList.offsetWidth;
    let accumulatedWidth = 0;
    let isOverflowing = false;
    let MORE_BUTTON_WIDTH = 90;

    for (let i = 0; i < items.length; i++) {
      let item = items[i];
      let itemWidth = item.offsetWidth;

      if (isOverflowing || (accumulatedWidth + itemWidth > containerWidth - MORE_BUTTON_WIDTH)) {
        isOverflowing = true;
        item.setAttribute("data-overflow", "true");
        
        let clone = item.cloneNode(true);
        moreSubmenu.appendChild(clone);
      } else {
        accumulatedWidth += itemWidth;
      }
    }

    if (isOverflowing) {
      moreBtn.style.display = "block";
      menuList.classList.add("has-overflow-active");
      menuList.appendChild(moreBtn); 
    }
  }

  // 3. Optimized Layout Window Observers
  if (window.ResizeObserver) {
    let observer = new ResizeObserver(function() {
      requestAnimationFrame(calculateOverflow);
    });
    observer.observe(navContainer);
  } else {
    window.addEventListener("resize", calculateOverflow);
  }

  // Helper function to cleanly clear dropdown activation tags across the viewport
  function clearAllDropdownsExcept(exceptionLi) {
    let activeClasses = ["sm-activated", "is-clicked", "sub-open"];
    document.querySelectorAll(".gen-nav li").forEach(function(li) {
      if (li !== exceptionLi && (!exceptionLi || !exceptionLi.contains(li))) {
        activeClasses.forEach(function(cls) { li.classList.remove(cls); });
      }
    });
  }

  // 4. CORE EVENT DELEGATION: Universal SmartMenus Interaction Engine
  navContainer.addEventListener("click", function(e) {
    let isMobile = hamButton && getComputedStyle(hamButton).display !== "none";
    
    // Find the closest list anchor link inside a menu tree entry path
    let targetAnchor = e.target.closest("li > a");
    if (!targetAnchor) {
      clearAllDropdownsExcept(null);
      return;
    }

    let parentLi = targetAnchor.parentElement;
    let subMenu = targetAnchor.nextElementSibling;

    // INTERCEPT RULES: Execute only if this element directly references an underlying submenu dropdown
    if (subMenu && subMenu.tagName === "UL") {
      if (isMobile) {
        // --- MOBILE ACCORDION LOGIC ---
        if (!parentLi.classList.contains("mob-activated")) {
          e.preventDefault(); // Stop instant navigation on the very first touch
          e.stopPropagation(); // Block parent click bubble triggers from clearing states
          
          // Clear active mobile classes from parallel sibling link branches at this level depth
          let siblingLis = parentLi.parentElement.children;
          for (let i = 0; i < siblingLis.length; i++) {
            if (siblingLis[i] !== parentLi) {
              siblingLis[i].classList.remove("sub-open", "mob-activated");
              siblingLis[i].querySelectorAll("li").forEach(function(childLi) {
                childLi.classList.remove("sub-open", "mob-activated");
              });
            }
          }
          
          // Expand the mobile accordion branch
          parentLi.classList.add("sub-open", "mob-activated");
        } else {
          // SECOND MOBILE TOUCH: Evaluate link destinations
          let hrefValue = targetAnchor.getAttribute("href");
          if (!hrefValue || hrefValue.includes("javascript:") || hrefValue === "#") {
            e.preventDefault();
            // Toggle menu shut if tapping an already open placeholder link a second time
            parentLi.classList.remove("sub-open", "mob-activated");
          } else {
            // Visually collapse the main hamburger menu drawer and all nested branches instantly
            if (menuList) menuList.classList.remove("open");
            if (navContainer) navContainer.classList.remove("mobile-open");
            clearAllDropdownsExcept(null);
            
            // Allow the link to navigate naturally to the new page
          }
        }
      } else {
        // --- DESKTOP VIEWPORT SMARTMENUS LOGIC ---
        let hrefValue = targetAnchor.getAttribute("href");
        
        if (!hrefValue || hrefValue.includes("javascript:") || hrefValue === "#") {
          // If it is an unlinked placeholder, trap the reload and toggle the menu view instead
          e.preventDefault();
          parentLi.classList.toggle("sm-activated");
        }
        // Valid destination URLs are skipped here, letting the desktop browser follow the link instantly!
      }
    }
  });
  
  // 5. DESKTOP VIEWPORT MOUSE-LEAVE CLEANER: Resets navigation locks when user walks cursor away
  document.addEventListener("mouseover", function(e) {
    let isMobile = hamButton && getComputedStyle(hamButton).display !== "none";
    if (isMobile) return;

    if (navContainer && !navContainer.contains(e.target)) {
      clearAllDropdownsExcept(null);
    }
  });

  // Automatically reset verification states if a user hovers completely off a specific branch item row
  navContainer.addEventListener("mouseout", function(e) {
    setTimeout(function() {
      let relatedTarget = e.relatedTarget;
      let li = e.target.closest("li.has-sub");
      
      if (li && (!relatedTarget || !li.contains(relatedTarget))) {
        li.classList.remove("sm-activated", "is-clicked");
      }
    }, 5000);
  });

  calculateOverflow();
});