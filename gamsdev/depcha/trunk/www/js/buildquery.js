$(function() {
    var suche = "#fulltext_search" ;
    $(suche).on('submit', function () {
        form2params($(suche)) ;
        return false;
    });
});

function form2params(form) {
     var params = "";
     var patt = new RegExp(/^\$[0-9]{1,6}$/);
     $('#fulltext_search :input').each(function() {
        if (patt.test(this.name) && ((this.value != '' && this.type!='radio' && this.type!='checkbox')|| this.checked)) {
            if (params != '') {
                params += ";"
            }
            var value = encodeURIComponent(this.value) ; 
            params += this.name + encodeURIComponent("|") + value;
	}
    });
	var actionUrl = form.attr('action') + "params=" + params ;
     
    window.location.href=actionUrl.trim();
    return false ;
}