//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require chosen.jquery

$(function() {
    $("select.chosen").each(function () {
        $(this).attr('data-placeholder', $(this).attr('placeholder'));
    }).chosen();

    $('a.back').click(function(){
        parent.history.back();
        return false;
    });
});