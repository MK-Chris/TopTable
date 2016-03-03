$(document).ready(function(){
  $(".tip").qtip({
  style: {
    //classes: "qtip-plain qtip-shadow qtip-rounded",
    classes: "qtip-tipsy"
  },
  show: {
    delay: 600,
    solo: true
  },
  hide: {
    fixed: true,
    delay: 200
  },
  position: {
    my: "top center",
    at: "bottom center",
  }
  });
});