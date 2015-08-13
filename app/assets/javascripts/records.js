$(function () {
    $("#hide").click(function () {
        $("#search_form").fadeOut();
        $("#show").show();
    });
    $("#show").click(function () {
        $("#search_form").fadeIn();
        $("#show").hide();
    });
    $('#session_start').datetimepicker({sideBySide: true, locale: 'ru'});
    $('#session_end').datetimepicker({sideBySide: true, locale: 'ru'});

});