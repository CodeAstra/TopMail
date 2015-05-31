$(document).ready(function(){
  $("#sentiment").slider();
  $("#sentiment").on("slide", function(slideEvt) {
    $("#sentimentVal").text(slideEvt.value);
  });

    $("#length").slider();
  $("#length").on("slide", function(slideEvt) {
    $("#lengthVal").text(slideEvt.value);
  });

      $("#streak").slider();
  $("#streak").on("slide", function(slideEvt) {
    $("#streakVal").text(slideEvt.value);
  });

        $("#lastreply").slider();
  $("#lastreply").on("slide", function(slideEvt) {
    $("#lastreplyVal").text(slideEvt.value);
  });
});