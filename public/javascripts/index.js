$(document).ready(function () {
    $("#search-btn").on("click", function () {
        window.location.href = "/search/"+$("#search").val();
    });
});
