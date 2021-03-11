// DEPCHA
// name: depcha.js; 
// author: Christopher Pollin
// date: 2021
// dependencies gams.js

/*
gamsJs.navigate.demandHttps();


gamsJs.dom.alignHashNavAwareOnLoad();


window.location.href = gamsJs.query.build("https://gams.uni-graz.at",{"$1":"home", "$2":"something else"});

let queryUrl = new gamsJs.url.GAMSUrl("http://glossa.uni-graz.at/archive/objects/query:derla.oneperson/methods/sdef:Query/get");


console.log(queryUrl );
console.log(2);
*/

function fetchSPARQL_Json(PID){
  console.log(PID);

  let context_uri = "<https://gams.uni-graz.at/"+PID+">";
  let query_url = gamsJs.query.build("https://glossa.uni-graz.at/archive/objects/query:depcha.data-context/methods/sdef:Query/getJSON",{"$1":context_uri});

  console.log(query_url);
  //fetch JSON-SPARQL-Result
  fetch(query_url, {method: 'get'})
    .then(response => response.json())
    .then(function(data)
    {
      const properties = Object.keys(data[0]);
      let groupedTransactions = gamsJs.utils.groupBy(data, 't');
      //console.log(groupedTransactions);
      buildTable(groupedTransactions, properties);

    })
  .catch(function(error) 
  {
    console.log('Request failed', error);
  });    

}


////////////////////////////////////////////////
// represents the bk:Traqnsaction Map as table
function buildTable(groupedTransactions, properties) {
  //const data_table_thead = document.getElementById("data_table_head");
  const data_table_tbody = document.getElementById("data_table_body");
  

  console.log(Object.entries(groupedTransactions));
  /*
  properties.forEach(columName => {
    if()
    const head_th = document.createElement("th");
    head_th.textContent = columName;
    data_table_thead.appendChild(head_th);
  });
  */

  //https://glossa.uni-graz.at/archive/objects/query:depcha.data-context/methods/sdef:Query/getJSON?params=%241%7C%3Chttps%3A%2F%2Fgams.uni-graz.at%2Fcontext%3Adepcha.stagville%3E
  for (const [key, value] of Object.entries(groupedTransactions)) {
    
    let tr = document.createElement("tr");
    td = document.createElement("td");
    tr.appendChild(td);
    // all bk:Measurable are in an array;
    //console.log(value.co);
    //console.log(value.qu);
    //console.log(value.u);
    if(value.mt.includes("Commodity"))
    {
      // if bk:Transaction has a bk:Commodity add a "+"
      let i = document.createElement("i");
      i.setAttribute('class', 'fas fa-plus');
      i.setAttribute('title', 'Show bk:Commodity');
      i.setAttribute('onclick', 'fas fa-plus');
      td.setAttribute('class', 'detail');
      td.appendChild(i);
     
    }
    
     
    
    
    // bk:when
    if(value.w)
    {
      tr.appendChild(getCell(formateDate(value.w[0])));
    }
    else{ tr.appendChild(getCell(' '))}
    // bk:entry
    value.e ? tr.appendChild(getCell(value.e[0])) : tr.appendChild(getCell(' '));
    // bk:quantity
    value.qu ? tr.appendChild(getCell(value.qu)) : tr.appendChild(getCell(' '));
    // bk:unit
    value.u ? tr.appendChild(getCell(value.u)) : tr.appendChild(getCell(' '));
    // bk:from
    if(value.fn)
      {value.fn ? tr.appendChild(getCell(value.fn[0])) : tr.appendChild(getCell(' '));}
    else
      {value.f ? tr.appendChild(getCell(value.f[0])) : tr.appendChild(getCell(' '));}
    // bk:to
    if(value.tn)
      {value.tn ? tr.appendChild(getCell(value.tn[0])) : tr.appendChild(getCell(' '));}
    else
      {value.t ? tr.appendChild(getCell(value.t[0])) : tr.appendChild(getCell(' '));}
    // bk:to

    value.co ? tr.appendChild(getCell(value.qu[0] + " " + " " + value.u[0] + value.co[0])) : tr.appendChild(getCell(' '));

/*
    for (let count=0; count<value.mt.length; count++) {
        
      if(value.mt[count] == "Commodity" || value.mt[count] == "Service")
      {
        value.co ? tr.appendChild(getCell(value.qu[count] + " " + " " + value.u[count] + value.co[count])) : tr.appendChild(getCell(' '));
        // data-c0="potatoe" data-c-qu0="3" data-c-u0="lb"
        //tr.setAttribute('data-c' + count, value.co[count]);
        //tr.setAttribute('data-quant' + count, value.qu[count]);
        //tr.setAttribute('data-unit' + count, value.u[count]);
      }
      else
      {
        tr.appendChild(getCell(' '));
      }
      
    }
*/

    data_table_tbody.appendChild(tr);
  }


  $(document).ready( function () {
    var data_table = $('#data_table').DataTable( {
      columns: [
        { title: "" },
        { title: "Date" },
        { title: "Entry" },
        { title: "Quantity" },
        { title: "Unit" },
        { title: "From" },
        { title: "To" },
        { title: "Commodity" }
      ],
        responsive: true,
        autoFill: true,
        "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
        "pageLength": 15,
        dom: 'Blfrtip',
        
        buttons: [
          {
          extend: 'csv',
          exportOptions: {
          columns: [ 1, 2, 3, 4, 5, 6]
          }
        }
        ],
        // ordering -->
        'columnDefs': 
        [
          {
          'targets': 0,
          'searchable': false,
          'orderable': true
          },
          //checkboxen
          /*'render': function (data, type, full, meta){
            return '<input type="checkbox" title="Add entry to databasket"> ' + $('<div/>').text(data).html();
          }
          },*/
          {
            'targets': [ 7 ],
            "visible": true
          }
        
        
        ],
        "order": [[ 1, "desc" ]]
 
    } );

      // Add event listener for opening and closing details
      $('#data_table_body').on('click', 'td.detail', function () {

        var tr = $(this).closest('tr');
        var row = data_table.row( tr );
 
        if ( row.child.isShown() ) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        }
        else {
         /* if (tr.data('c0')) {
            console.log(tr.data('quant0') + "-" + tr.data('unit0')+  "-"+ tr.data('c0'));
            //row.child(format(tr.data('c0'), tr.data('c-qu0'), tr.data('c-u0'))).show();
            let childRows = '<ul>'+ '<li>'+ tr.data('quant0') + ' ' + tr.data('unit0') + ' ' + tr.data('c0')+'</li>';
          if(tr.data('c1'))
            {childRows =  childRows +'<li>'+ tr.data('quant1') + ' ' + tr.data('unit1') + ' ' + tr.data('c1')+'</li>';}
            if(tr.data('c2'))
            {childRows =  childRows +'<li>'+ tr.data('quant2') + ' ' + tr.data('unit2') + ' ' + tr.data('c2')+'</li>';}
            childRows = childRows + '</ul>';
            row.child(childRows).show();
          }
          */
         
         
            tr.addClass('shown');
        }
    } );


} );

}




////////////////////////////////////////////////
//
function getCell(value) {
  td = document.createElement("td");
  td.textContent = value;

  return td;
}

////////////////////////////////////////////////
// formateDate: formate date correctly for YYYY-MM-DD, YYYY-MM, YYYY; otherwise return false
function formateDate(date) {

  const regEx_Date_YYYY_MM_DD  = /^\d{4}-\d{2}-\d{2}$/;
  const regEx_Date_YYYY_MM = /^\d{4}-\d{2}$/;
  const regEx_Date_YYYY = /^\d{4}$/;
  if(date.match(regEx_Date_YYYY_MM_DD))
  {
    const when = new Date(date);
    return when.getDate() + "." + (when.getMonth()+1) + "." + when.getFullYear();
  }
  else if(date.match(regEx_Date_YYYY_MM))
  {
    const when = new Date(date);
    return (when.getMonth()+1) + "." + when.getFullYear();
  }
  else if(regEx_Date_YYYY)
    return date;
  else
  {
    return false
  } 

}

