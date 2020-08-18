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
        if (patt.test(this.name) && ((this.value != '' && this.type!='radio' && this.type!='checkbox')|| this.checked)) { //select?
            if (params != '') {
                params += ";"
            }
            var value = encodeURIComponent(this.value) ; //Das hier kann durch eine komplexere Funktion ersetzt werden, in der z.B. andere Formularfelder zusammegefÃ¼gt werden.
            params += this.name + encodeURIComponent("|") + value;
	}
    });
	var actionUrl = form.attr('action') + "params=" + params ;
     
    window.location.href=actionUrl.trim();
    return false ;
}


/*
$(function() {
    var suche = "#volltextsuche" ;
    $(suche).on('submit', function () {
        form2params($(suche)) ;
        return false;
    });
});

var me = {} ;

function form2params(form) {
    /\*
     * ToDo:
     * Sollten nicht auch die $n-Anfragen vorverarbeitet werden?
     *\/
     me = form ;
     var params = "" ;
     var param2 = "" ;
     var suchwort= "" ;
     var jahrVor = {'value':''} ;
     var jahrNach = {'value':''} ;
     var patt = new RegExp(/^\$[0-9]{1,6}$/);
     var suchart = 'fulltext' ;
     if ( typeof($(form.selector + ' #regex')[0]) != 'undefined' ) { 
     	 suchart =  $(form.selector + ' #regex')[0].checked ? 'regex' : 'fulltext' ; //Unterscheidung ob suche mit regulären Ausdrücken oder einfache Volltextsuche
     }
     $(form.selector + ' :input').each(function() { //Alle Input-Elemente des ausgewählten Formulars durchgehen
        if (patt.test(this.name) && ((this.value != '' && this.type!='radio' && this.type!='checkbox')|| this.checked)) { //1. Textfelder mit $n als Name werden direkt in $n-Parameter des Queryobjekts übersetzt
            if (params != '') {
                params += ";"
            }
            else  {
                suchwort = value ;
            }
            var value = encodeURI(this.value);
            params +=  this.name + "|" + encodeURI(value) ;
    	}
        //Inputfelder mit expliziten Namen
        else if(this.name == 'Stichwort') { //Die Stichwörter müssen vorverarbeitetet werden => kann ich das mit dem oben verschmelzen?
            param2 = (addParamsExt(this.value, suchart)) ;
            suchwort = this.value ;
	        }
        else if (this.name == 'Nach') {
            jahrNach = this ;
        }
        else if (this.name == 'Vor') {
            jahrVor = this ;
        }
    });
        // Zeitconstraint hinzufügen:
        /\* ToDo: Anpassen!! z.B.
            Null-Wert abfangen und als $3 einfügen?
            "2004-12-06"^^xsd:date 
            bzw. app:customDate(?date) > "2005-02-28T00:00:00Z"^^xsd:dateTime where app:customDate identifies an extension function to turn the date format into an xsd:dateTime RDF term => https://www.w3.org/TR/sparql11-query/#extensionFunctions
            => ToRDF Datumsangabe-Datentyp checken? Oder als Stringvergleich riskieren?
         *\/
    if(jahrVor.value != '' || jahrNach.value != '') {
    	// Ergänze von/bis ?eintrag uf:hasDatumUrfehde ?d . ?d tei:when ?datum .
          param2 += ' %3Feintrag uf:hasDatumUrfehde %3Fd . %3Fd tei:when %3Fdatum . FILTER(' ;
          if(jahrVor.value !='') {
                 param2 += '%3Fdatum <= "'+ jahrVor.value + '"';
          }
          if(jahrVor.value !='' && jahrNach.value != '') {
           if(jahrVor.value >= jahrNach.value) {
               param2 +=' %26%26 ' ;
           }
           else {
               param2 +=' || ' ;
           }
       }
          if(jahrNach.value !='') {
                 param2 += '%3Fdatum >= "'+ jahrNach.value + '"';
          }
          param2 +=')'; //richtig in params einfügen: $3 ?
          //params += ';$3|' + param2 ;
   }
	//params.value="%241|" + value + ";%242|" + param2 ;
	if(param2!='') { 
	   params +=  "$1|" + encodeURI(suchwort.replace(/[\+]/g,"%2B"));
	   params += ";$2|" + param2; 
	}
	/\* TODO: Ein Test, ob mindestens ein Suchbegriff mit +-Operator vorhanden ist: Wie kann ich einfach einen Array auf die Existenz eines solchen Wertes abfragen? *\/
    var actionUrl = form.attr('action') + "?params=" + params ;
    //alert ("Debug: " + actionUrl.trim()) ; //Debug
    window.location.href=actionUrl.trim();
    return false ;
}

function addParamsExt(value, suchart) {
    /\* TODO: Kontrolle, daß ein Suchbegriff übergeben wird: me.Stichwort.value darf nicht NULL sein, sonst ...?*\/
	/\* me ist das aktuelle Formular, da es auf einer Seite mehrere Formulare geben kann
	Es muß dann die Verarbeitung der $2-Parameter folgen *\/
    value.replace(/[\+]/g,"%2B");
    var Stichwoerter = searchTerms(value) ; // Gibt einen Array aus Stichwörtern und Operatoren zurück
	//console.log(Stichwoerter['Stichwoerter'][1] + ' ' + Stichwoerter['operators'][1]); //Debug
	//Hier aus den Stichwörtern und Operatoren je nach Suchart einen einschlägigen Suchstring bilden:
    if (Stichwoerter['operators'].indexOf('+') != -1 && value.length > 0) {
	   var param2 = new String() ;
    	if(suchart =='fulltext' ) { 
    		var ands = new String();
    		if(value != '*') {
        		for(i=0; i < Stichwoerter['Stichwoerter'].length; i++) {
        			if(Stichwoerter['operators'][i] == '-') {
        				param2 += " MINUS %7B %3Finhalt bds:search " + '"' +  Stichwoerter['Stichwoerter'][i] + '" . %7D';
        			}
        			else if(Stichwoerter['operators'][i] == '|') {
        				param2 += " UNION %7B %3Finhalt bds:search " + '"' +  Stichwoerter['Stichwoerter'][i] + '" . %7D';
        			}
        			else {
        				ands += Stichwoerter['Stichwoerter'][i] + " ";
        			}
        		}
        		param2 = "%7B %3Finhalt bds:search " + '"' + ands.trim() + '" . %3Finhalt bds:matchAllTerms "true" . %7D' + param2 ;
    		}
    	}
    	else if(suchart='regex') {
    		/\* regex-Ausdrücke maskieren
    		*\/
    		Stichwoerter.sort(function(a, b){
                var opA=a.operators, opB=b.operators
                if (opA < opB) //sort string ascending
                 return -1
                if (opA > opB)
                 return 1
                return 0 //default return value (no sorting)
               }); //FixMe: Sortieren des Arrays nach Operatoren???
               //Alternativer Weg: die Stichwörter gruppenweise mit "$().each" auswerten
               //Oder vorschreiben, daß das erste Suchwort ein + sein muß.
    		param2 += " FILTER(" ;
    		for(i = 0; i < Stichwoerter['Stichwoerter'].length; i++){
    			if(i > 0) { //FixMe: das geht davon aus, daß der erste Suchbegriff keinen Operator hat ...
    				if(Stichwoerter['operators'][i] == '|') {
    						param2+=' || ';
    				}
    				else {
    					param2 +=' %26%26 '; 
    					if(Stichwoerter['operators'][i] == '-') {
    						param2 +=' !' ; //Nicht-Operator
    					}
    				}
    			}
    			param2 +='regex(%3Finhalt,"'+ encodeURIComponent('\\\\b' + Stichwoerter['Stichwoerter'][i] + '\\\\b').replace(/%2B/g,"%252B") +'","i")';
    		}
    		param2 +=")" ;
    	}
    	
/\*    	alert("http://fedora.host/fedora/objects/query:srbas.search/methods/sdef:Query/getXML?params=" + me.params.value); //Debug*\/
    }
    else {
        alert('Bitte geben Sie mindestens ein Suchwort ein, das in den Treffern vorkommen muss.') ;
    }
    return param2;	
}

function searchTerms(stichwort) {
	// alert("Stichwort:" + stichwort);
	/\* gibt einen Array der Stichwörter und der Operatoren zurück *\/
	var result = new Array() ;
	/\* Die Stichwoerter: *\/
	var Stichwoerter= stichwort.split(" ");
	/\* und noch die Operatoren extrahieren, d.h. einleitende Zeichen, wenn sie + = und, - = nicht oder | = oder sind: *\/
	var operators = new Array() ;
	for(i = 0; i < Stichwoerter.length; i++){
		if(Stichwoerter[i].charAt(0).search(/[\+\-\|]/) != -1) {
			//alert("|" + Stichwoerter[i].charAt(0) + "|");
			operators[i] = Stichwoerter[i].charAt(0) ;
			Stichwoerter[i] = Stichwoerter[i].substr(1).replace(/[\+]/g,"%252B");
		}
		else {
			operators[i] = "+" ;
		}
	}
	result['Stichwoerter'] = Stichwoerter ;
	result['operators'] = operators ;
	return result ;
}*/