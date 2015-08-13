$(document).ready(function () {
    $("#hide").click(function () {
        $("#search_form").fadeOut();
        $("#show").show();
    });
    $("#show").click(function () {
        $("#search_form").fadeIn();
        $("#show").hide();
    });
});