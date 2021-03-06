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
/*function getBarChart_Date_Value(query, PID, date, value)
{
    let Base_URL = "https://glossa.uni-graz.at/archive/objects/" + query + "/methods/sdef:Query/getJSON?params="
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
        const width = 1100;
        const height = 750;
        const margin = {'top':35, 'right': 35, 'bottom': 35, 'left': 45};
        const innerWidth = width - margin.left - margin.right;
        const innerHeight = height - margin.top - margin.bottom;

        const svg = d3.select('svg')
          //.attr('width', width)
          //.attr('height', height);
          .attr("viewBox", [0, 0, width, height]);
        
        const graph = svg.append('g')
          .attr('width', innerWidth)
          .attr('height', innerHeight)
          .attr('transform', `translate(${margin.left}, ${margin.top})`);
        
        const bk_income = d => d.income;
        const bk_expens = d => d.expens;
        const bk_date = d => d.date;
        
        const y = d3.scaleLinear()
          .domain([0, d3.max(data, bk_expens)]) 
          .range([innerHeight, 0])
          .nice();  

        const x = d3.scaleBand()
          .domain(data.map(bk_date))
          .range([0,innerWidth])
          .padding(0.05);

        // y-Axis
        const gYAxis = graph.append('g');
      
        const yAxis = d3.axisLeft(y)
          .ticks(10)
          .tickSize(-innerWidth)
          .tickFormat(d => `£ ${d / 1000}K`);  
        
        gYAxis.call(yAxis);
   
        const rects = graph.selectAll('rect')
        .data(data);  

      
            
        rects.attr('width', x.bandwidth)
          .attr('class', 'bar-rect')
          .attr('height', d => innerHeight - y(d.expens))
          .attr('x', d => x(d.date))
          .attr('y', d => y(d.expens));  
            
        rects.enter()
          .append('rect')
          .attr('class', 'bar-rect')
          .attr('width', x.bandwidth)
          .attr('height', d => innerHeight - y(d.expens))
          .attr('x', d => x(d.date))
          .attr('y', d => y(d.expens));  

        const gXAxis = graph.append('g')
          .attr('transform', `translate(0, ${innerHeight})`);

        const xAxis = d3.axisBottom(x);
        // show x-axis  
        gXAxis.call(xAxis);
        // style text of x-axis
        gXAxis.selectAll('text')
          .style("text-anchor", "end")
          .attr("dx", "-.8em")
          .attr("dy", ".15em")
          .attr("transform", "rotate(-65)");
      })
    .catch(function(error) 
    {
      console.log('Request failed', error);
    });    
    
}*/

function a()
{
                        ! function (e) {
                        function r(r) {
                        for (var n, a, l = r[0], f = r[1], i = r[2], p = 0, s =[]; p < l.length; p++) a = l[p], Object.prototype.hasOwnProperty.call(o, a) && o[a] && s.push(o[a][0]), o[a] = 0;
                        for (n in f) Object.prototype.hasOwnProperty.call(f, n) &&(e[n] = f[n]);
                        for (c && c(r);
                        s.length;) s.shift()();
                        return u.push.apply(u, i ||[]), t()
                        }
                        function t() {
                        for (var e, r = 0; r < u.length; r++) {
                        for (var t = u[r], n = ! 0, l = 1; l < t.length; l++) {
                        var f = t[l];
                        0 !== o[f] &&(n = ! 1)
                        }
                        n &&(u.splice(r--, 1), e = a(a.s = t[0]))
                        }
                        return e
                        }
                        var n = {
                        },
                        o = {
                        1: 0
                        },
                        u =[];
                        function a(r) {
                        if (n[r]) return n[r].exports;
                        var t = n[r] = {
                        i: r, l: ! 1, exports: {
                        }
                        };
                        return e[r].call(t.exports, t, t.exports, a), t.l = ! 0, t.exports
                        }
                        a.m = e, a.c = n, a.d = function (e, r, t) {
                        a.o(e, r) || Object.defineProperty(e, r, {
                        enumerable: ! 0, get: t
                        })
                        },
                        a.r = function (e) {
                        "undefined" != typeof Symbol && Symbol.toStringTag && Object.defineProperty(e, Symbol.toStringTag, {
                        value: "Module"
                        }), Object.defineProperty(e, "__esModule", {
                        value: ! 0
                        })
                        },
                        a.t = function (e, r) {
                        if (1 & r &&(e = a(e)), 8 & r) return e;
                        if (4 & r && "object" == typeof e && e && e.__esModule) return e;
                        var t = Object.create(null);
                        if (a.r(t), Object.defineProperty(t, "default", {
                        enumerable: ! 0, value: e
                        }), 2 & r && "string" != typeof e) for (var n in e) a.d(t, n, function (r) {
                        return e[r]
                        }.bind(null, n));
                        return t
                        },
                        a.n = function (e) {
                        var r = e && e.__esModule ? function () {
                        return e. default
                        }: function () {
                        return e
                        };
                        return a.d(r, "a", r), r
                        },
                        a.o = function (e, r) {
                        return Object.prototype.hasOwnProperty.call(e, r)
                        },
                        a.p = "/";
                        var l = this[ "webpackJsonpreact-d3-dashboard"] = this[ "webpackJsonpreact-d3-dashboard"] ||[], f = l.push.bind(l);
                        l.push = r, l = l.slice();
                        for (var i = 0; i < l.length; i++) r(l[i]);
                        var c = f;
                        t()
                        }
                        ([])}


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


     ////////////////////////////////////////////////
            ////////////////////////////////////////////////
            // InfoVis
function InfoVis()
{
                
    var svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");
    console.log(svg);
            
            
}
