// DEPCHA - DATA VIEW
// name: dataView.js; 
// author: Christopher Pollin
// date: 2020
// dependencies DataTable.js

/* 
 * 
*/

////////////////////////////////////////////////
//
function getJsonBuildDataTable(PID){
    console.log(PID);
    let Base_URL = "https://glossa.uni-graz.at/archive/objects/query:depcha.data-context/methods/sdef:Query/getJSON?params="
    let Param = encodeURIComponent("$1|<https://gams.uni-graz.at/"+PID+">");
    let Query_URL = Base_URL + Param;

    console.log(Query_URL);
    
    //fetch JSON-SPARQL-Result
    fetch(Query_URL, {method: 'get'})
      // transform the data into json
      .then(response => response.json())
      //here you can further process the json (=data)
      .then(function(data)
      {
      
      console.log(data);
       //group all entries by the bk:Transaction-URI
       const groupedByTransaction = data.reduce( (aggr, transaction) => 
         {
          //depcha.taxroll.1296#T0
          let PID_id = transaction.t.substring(transaction.t.indexOf('#') + 2);
          let from_id = transaction.f ? transaction.f.substring(transaction.f.indexOf('#') + 1)  : null;
          let to_id = transaction.to ? transaction.to.substring(transaction.to.indexOf('#') + 1) : null;
          let measurementType = transaction.mt.substring(transaction.mt.indexOf('#') + 1);
         
         //fill the Map
         // Map(8) { from → "AB01", from_n → "Aalis", to → "P04", to_n → "Philippe", when → "1313", m_type → "Money", quantity → "4, 10", unit → "livres, sous" }
         aggr[PID_id] = aggr[PID_id] ? aggr[PID_id] : new Map()
         //entry
         aggr[PID_id].set('entry', transaction.e);
         //from_id
         aggr[PID_id].set('from', from_id);
         //from_name
         aggr[PID_id].set('from_n', transaction.fn ? transaction.fn : null);
         //to_id
         aggr[PID_id].set('to', to_id); 
         //to_name
         aggr[PID_id].set('to_n', transaction.tn ? transaction.tn : null);
         // when = date 
         aggr[PID_id].set('when', transaction.w);
         //measurable type (Money, Commodity, Service)
         aggr[PID_id].set('m_type', measurementType);
         //quantity
         aggr[PID_id].has('quantity') ? 
           aggr[PID_id].set('quantity', aggr[PID_id].get('quantity') + ", " +transaction.qu) : 
           aggr[PID_id].set('quantity', transaction.qu);
         //unit
         aggr[PID_id].has('unit') ? 
           aggr[PID_id].set('unit', aggr[PID_id].get('unit') + ", " +transaction.u) : 
           aggr[PID_id].set('unit', transaction.u);

          return aggr;
            } , {})
            
           console.log(groupedByTransaction);

            document.querySelector("#data_view_table").appendChild(buildTable(groupedByTransaction));
            $(document).ready( function () {
                $('#data_view_table').DataTable( {
                    responsive: true,
                    autoFill: true,
                    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
			       "pageLength": 15,
			        dom: 'Blfrtip',
                    buttons: ['csv', 'excel'],
			       // ordering -->
			        'columnDefs': [{
                        'targets': 0,
                        'searchable': true,
                        'orderable': true,
                        //checkboxen
                        'render': function (data, type, full, meta){
                            return '<input type="checkbox" title="Add entry to databasket"> ' + $('<div/>').text(data).html();
                        }
                     }],
			       "order": [[ 0, "asc" ]]
			       
                } );
            } );
    })
    .catch(function(error) 
    {
      console.log('Request failed', error);
    });    
    
}

////////////////////////////////////////////////
//
function isValidDate(d) {
  return d instanceof Date && !isNaN(d);
}

////////////////////////////////////////////////
// param: date
// return: a formatted date 
function getData(input_date)
{
  /*  const d = new Date(input_date);
    const year = d.getFullYear() 
    const month = d.getMonth() + "/";
    const day = d.getDate(); + "/";
    const date = day + month + year;*/
    
    return input_date;
    
}
 
////////////////////////////////////////////////
//
function getCell(value) {
      td = document.createElement("td");
      td.textContent = value;

      return td;
}

////////////////////////////////////////////////
// represents the bk:Traqnsaction Map as table
function buildTable(objectWithMaps) {
    let tbody  = document.createElement("tbody");
    for (map in objectWithMaps)
    {
     
    // do this better!! and for more than 2 measurables
     let Measurable = objectWithMaps[map].get('quantity').includes(",") ? 
       objectWithMaps[map].get('quantity').split(", ")[0] + " " + objectWithMaps[map].get('unit').split(", ")[0] + " " +
         objectWithMaps[map].get('quantity').split(", ")[1] + " " + objectWithMaps[map].get('unit').split(", ")[1] :
       objectWithMaps[map].get('quantity') + " " + objectWithMaps[map].get('unit');
        
     let row = document.createElement("tr");
     
      let cell_entry = document.createElement("td");
      cell_entry.textContent = objectWithMaps[map].get("entry");
      //cell_entry.setAttribute("rowspan", 2);
      row.appendChild(cell_entry);
      
      let cell_when = document.createElement("td");
      cell_when.textContent = getData(objectWithMaps[map].get("when"));
      //cell_when.setAttribute("rowspan", 2);
      row.appendChild(cell_when);

      row.appendChild(getCell(Measurable));
      row.appendChild(getCell(objectWithMaps[map].get('from_n')+ " "));
      row.appendChild(getCell(objectWithMaps[map].get('to_n')+ " "));

     tbody.appendChild(row);
    }
    return tbody;

  }
  
  
////////////////////////////////////////////////
// selects all input (checkboxes), iterates over them and sets checked to true
function selectAllCheckboxes(table)
{
   let rows = table.querySelectorAll('tbody > tr > td > input')
   rows.forEach(input => input.checked = true);
}
