////////////////////////////
////////////////////////////
// author: Pollin Christopher 
// 



////////////////////////////
// getData()
function getData(input) 
{
	//Entry is one div, indentified by its ID entry_id
	var parts = input.split('b');
    var entry_id = parts[parts.length - 1]
	var entry = document.getElementById(entry_id);
	var check = entry.getAttribute("data-check");
	var entry_text = entry.childNodes[1].text;


	if (check == 'unchecked') 
	{
		//adds the data to the entry
		var checked = entry.setAttribute("data-check", "checked"); 
		addItem(entry.dataset.uri, entry.dataset.entry, entry.dataset.from, 
		entry.dataset.to, entry.dataset.when, entry.dataset.measurable, entry.dataset.check);
	}
	else
	{
	  deletEntryDatabasket(entry_id);
	  var checked = entry.setAttribute("data-check", "unchecked"); 
	}
	//adapts number, without refreshing whole webside, Datenkorb(13)
	clear();
	//countEntrys(); 
}


////////////////////////////
// deletEntryDatabasket() 
// Delets entry in the databasekt using splice() to remove it from the array, than creates a new array and put it into the localStorage
function deletEntryDatabasket(id) 
{
	var datenkorbArray = JSON.parse(localStorage.getItem('depcha'));	
	for (var count=0; count< datenkorbArray.length; count++) 
	{
		if (datenkorbArray[count].uri == id) 
		{
		  //delets selected entry from array
		  datenkorbArray.splice(count,1);
		}
	}
	//creates new array and puts it into localStorage
	datenkorbArray = JSON.stringify(datenkorbArray);
	localStorage.setItem("itemsArray", datenkorbArray);	
}	

////////////////////////////
//	clearData()
//	clears the localStorage if 'Leeren'-Button is pressed
function clearData()
{
	localStorage.clear();
	location.reload();
}

////////////////////////////
//	countEntrys()
// 	called by onLoad();
//	and Datenkorb(n), where n is number of objects in the localStorage
function countEntrys() 
{
	var datenkorbArray = JSON.parse(localStorage.getItem('depcha'));
	
	if(typeof datenkorbArray !== 'undefined' && datenkorbArray.length > 0)
	//databasket is empty
	{
		document.getElementById('databasket_static').innerHTML = ' ('+ datenkorbArray.length +')';
	}
}

////////////////////////////
//	clear()
// 	called by onLoad();
function clear() 
		{
          document.getElementById("datenkorb_static").innerHTML = "";
        }	
////////////////////////////
//	checkDatabasketStart()
// 	called by onLoad()
//	Goes through the databasket and checks all objects in localStorage if they are in the databasket
function keepCheckboxes() 
{	
	var datenkorbArray = JSON.parse(localStorage.getItem('depcha'));
	var url = window.location.href;

	if(JSON.parse(localStorage.getItem('depcha')) != null)
	{
		for (var count = 0; count < datenkorbArray.length; count++) 
		{
		    var parts = datenkorbArray[count].uri.split('#');
            var id = parts[parts.length - 1];  //SZDBIB.1249
            var collection = parts[parts.length - 2]; //glossa.uni-graz.at/o:szd.bibliothekskatalog
		   
		    //keepCheckboxes just for all entries at the actual site/collection. 
		    if(url.indexOf(collection) !== -1)
		    {
              var actualBox =  document.getElementById('cb'+id);
              actualBox.setAttribute("checked", "true");
              var actualEntry = document.getElementById(id);
              actualEntry.setAttribute("data-check", "checked");
            }
		}	
	}	
}
////////////////////////////
// addItem()
//adds the data from the data property attributs to the entry
function addItem(uri, from, to, entry, when, measurable, check) 
{
  var datenkorbArray = JSON.parse(localStorage.getItem('depcha')) || []; 
  var newItem = 
  { 
	"uri" : uri, 
	"from": from,
	"to": to, 	
	"entry": entry, 
	"when": when,
	"measurable": measurable,
	"check" : check
  } 
  
  //pushs item on a array
  datenkorbArray.push(newItem);
  //saves entry in the localStorage
  localStorage.setItem('depcha', JSON.stringify(datenkorbArray));
};
////////////////////////////
//	showData()
//
function showData() 
{	

	//initalize the localStorage-Array
	var datenkorbArray = JSON.parse(localStorage['depcha']);
	var datenkorbArrayLength = datenkorbArray.length;	
    var databasekt_tbody = document.getElementById("databasekt_tbody");

	
	//for every object in the array create a ul = datenkorbArrayLength 
	for (var outerCount = 0; outerCount < datenkorbArrayLength; outerCount++) 
	{

		var tr = document.createElement('tr');
		databasekt_tbody.appendChild(tr);
		
		var td_entry = document.createElement('td');
		tr.appendChild(td_entry);
		
		var a = document.createElement('a');
		//https://gams.uni-graz.at/o:depcha.schlitz.1#Transaction-5-Transfer-1"
        var uri = datenkorbArray[outerCount].uri;		
		a.setAttribute("href", uri.substr(0, uri.indexOf('-T')));
		a.setAttribute("style", "color:#337ab7");
		a.setAttribute("title", "Zum Eintrag");
	    td_entry.appendChild(a)
		a.appendChild(document.createTextNode(datenkorbArray[outerCount].from));

		//td_entry.appendChild(document.createTextNode(datenkorbArray[outerCount].entry));
		
		var td_when = document.createElement('td');
		tr.appendChild(td_when);
		td_when.appendChild(document.createTextNode(datenkorbArray[outerCount].when));
		
		var td_from = document.createElement('td');
		tr.appendChild(td_from);
		td_from.appendChild(document.createTextNode(datenkorbArray[outerCount].entry));
		
		var td_to = document.createElement('td');
		tr.appendChild(td_to);
		td_to.appendChild(document.createTextNode(datenkorbArray[outerCount].to));
		
		var td_measurable = document.createElement('td');
		tr.appendChild(td_measurable);
		td_measurable.appendChild(document.createTextNode(datenkorbArray[outerCount].measurable));
		
		var td_delete = document.createElement('td');
		tr.appendChild(td_delete);
		var button_delet = document.createElement('button');
		button_delet.setAttribute("type", "button");
		button_delet.setAttribute("class", "btn disabled");
		button_delet.setAttribute("onclick", "");
		button_delet.appendChild(document.createTextNode('x'));
		td_delete.appendChild(button_delet);
    }	
}


////////////////////////////
////////////////////////////
//
function printDatabasket() 
{
    var doc = new jsPDF();
    var specialElementHandlers = {
    '#editor': function (element, renderer) 
    {
        return true;
    }
};

$('#cmd').click(function () {
    doc.fromHTML($('#content').html(), 15, 15, {
        'width': 170,
            'elementHandlers': specialElementHandlers
    });
    doc.save('sample-file.pdf');
});
}

/*$(window).on('load', function() {
  countEntrys();
});*/

