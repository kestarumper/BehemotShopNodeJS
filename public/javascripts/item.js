$(document).ready(function () {
   $("#addToCart").on("click", function (e) {
       var item = {
           name: $("#itemName").html(),
           price: parseFloat($("#price").html()),
           quantity: 1
       }
      $.post("/cart/add", item, function (response) {
          alert(response);
      })
   });
});