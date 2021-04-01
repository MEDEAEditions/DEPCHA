
// name: gamsInfoVis.js 
// author: Christopher Pollin
// date: 2020
// dependencies D3.js


// TODO:
//https://github.com/sgratzl/d3tutorial#code-structure


////////////////////////////////////////////////
//
function getVEGABarChart_Date_Value(query_pid, PID)
{
  let Base_URL = "https://glossa.uni-graz.at/archive/objects/" + query_pid + "/methods/sdef:Query/getJSON?params="
    let Param = encodeURIComponent("$1|<https://gams.uni-graz.at/"+PID+">");
    let Query_URL = Base_URL + Param;
    //let value_type = "in"
    console.log(Query_URL);
    
    //fetch JSON-SPARQL-Result
    fetch(Query_URL, {method: 'get'})
      // transform the data into json
      .then(response => response.json())
      //here you can further process the json (=data)
      .then(function(data)
      {
        //TODO merge VEGA_JSON with SPARQL_RESULT
        let values = [];
        let values_JSON_stmt = {};
        data.forEach(obj => {
          values_JSON_stmt = {"category": obj["d"], "amount": obj["in"]};
          values.push(values_JSON_stmt);
        });
      //console.log(values);


        var VEGA_JSON = {
      "$schema": "https://vega.github.io/schema/vega/v5.json",
      "description": "A basic bar chart example, with value labels shown upon mouse hover.",
      "width": 1000,
      "height": 400,
      "padding": 10,
        
      "data": [
        //console.log("test");
       
        {
           /*,
          "name": "table",
         
          "values": [
            {"category": "A", "amount": 28},
            {"category": "B", "amount": 55},
            {"category": "C", "amount": 43},
            {"category": "D", "amount": 91},
            {"category": "E", "amount": 81},
            {"category": "F", "amount": 53},
            {"category": "G", "amount": 19},
            {"category": "H", "amount": 87}
          ]*/
        }
       
      ],
    
      "signals": [
        {
          "name": "tooltip",
          "value": {},
          "on": [
            {"events": "rect:mouseover", "update": "datum"},
            {"events": "rect:mouseout",  "update": "{}"}
          ]
        }
      ],
    
      "scales": [
        {
          "name": "xscale",
          "type": "band",
          "domain": {"data": "table", "field": "category"},
          "range": "width",
          "padding": 0.05,
          "round": true
        },
        {
          "name": "yscale",
          "domain": {"data": "table", "field": "amount"},
          "nice": true,
          "range": "height"
        }
      ],
    
      "axes": [
        { "orient": "bottom", "scale": "xscale" },
        { "orient": "left", "scale": "yscale" }
      ],
    
      "marks": [
        {
          "type": "rect",
          "from": {"data":"table"},
          "encode": {
            "enter": {
              "x": {"scale": "xscale", "field": "category"},
              "width": {"scale": "xscale", "band": 1},
              "y": {"scale": "yscale", "field": "amount"},
              "y2": {"scale": "yscale", "value": 0}
            },
            "update": {
              "fill": {"value": "steelblue"}
            },
            "hover": {
              "fill": {"value": "red"}
            }
          }
        },
        {
          "type": "text",
          "encode": {
            "enter": {
              "align": {"value": "center"},
              "baseline": {"value": "bottom"},
              "fill": {"value": "#333"}
            },
            "update": {
              "x": {"scale": "xscale", "signal": "tooltip.category", "band": 0.5},
              "y": {"scale": "yscale", "signal": "tooltip.amount", "offset": -2},
              "text": {"signal": "tooltip.amount"},
              "fillOpacity": [
                {"test": "datum === tooltip", "value": 0},
                {"value": 1}
              ]
            }
          }
        }
      ]
          }
          
        VEGA_JSON["data"] = {  "name" : "table", "values" : values}
        
        vegaEmbed('#view',VEGA_JSON );
        console.log(VEGA_JSON);
      })
      .catch(function(error) 
      {
        console.log('Request failed', error);
      });  

  
    

  }

////////////////////////////////////////////////
//
function getBarChart_Date_Value(query_pid, PID)
{
    let Base_URL = "https://glossa.uni-graz.at/archive/objects/" + query_pid + "/methods/sdef:Query/getJSON?params="
    let Param = encodeURIComponent("$1|<https://gams.uni-graz.at/"+PID+">");
    let Query_URL = Base_URL + Param;
    //let value_type = "in"
    console.log(Query_URL);
    
    //fetch JSON-SPARQL-Result
    fetch(Query_URL, {method: 'get'})
      // transform the data into json
      .then(response => response.json())
      //here you can further process the json (=data)
      .then(function(data)
      {
        // "ds" = bk:Dataset URI
        const groupKey = "d"
        // DIMENSIONS
        const width = 1000;
        const height = 800;
        const margin = {'top':30, 'right': 30, 'bottom': 30, 'left': 45};
        const innerWidth = width - margin.left - margin.right;
        const innerHeight = height - margin.top - margin.bottom;  

        // COLOR SCHEME
        color = d3.scaleOrdinal().range(["#638ccc", "#ca5670"])

        // TOOLTIP
        var div = d3.select("body").append("div")
          .attr("class", "tooltip")
          .style("opacity", 0);
    
        // VARIABLES
        const keys = ["in", "ex"]
        
        // MAIN SVG
        const svg = d3.select('svg#' + "BarChart_Date_Value")
          .attr('width', width)
          .attr('height', height)
          .attr("viewBox", [0, 0, width, height]);

        //
        const graph = svg.append('g')
          .attr('width', innerWidth)
          .attr('height', innerHeight)
          .attr('transform', `translate(${margin.left}, ${margin.top})`);

    // x0
    const x0 = d3.scaleBand()
      .domain(
      // define sorting 
      data.map(d => d[groupKey]).sort(function(a, b) {return a - b; })
      )
      //.domain(data.map(d => d[groupKey]))
      .rangeRound([0, innerWidth])
      .paddingInner(0.1)

    x1 = d3.scaleBand()
          .domain(keys)
          .rangeRound([0, x0.bandwidth()])
          .paddingInner(0.1)

    const y = d3.scaleLinear()
         .domain([0, d3.max(data, d => d3.max(keys, key => +d[key]))])
         .rangeRound([innerHeight, margin.top])
         //.domain([0, d3.max(data, d => +d["in"])]) 
         //.range([innerHeight, 0])
         .nice();  

      

        svg.append("g")
          .selectAll("g")
          .data(data)
          .join("g")
            //calcualtes position of the bar; translate() changes position on axis
            // todo: why ${30} ?? somewhere to change the y value for the g, which contains the rect
            .attr("transform", d => `translate(${x0(d[groupKey])}, ${30})`)
          .selectAll("rect")
          .data(d => keys.map(key => ({key, value: d[key]})))
         
            .join("rect")
            .attr('class', 'bar-rect')
            .attr("x", d => x1(d.key))
            .attr("y", d => y(d.value))
            //.attr("width", x1.bandwidth())
            // if react are too big
            .attr("width", function(d) {
              return x1.bandwidth() < 100 ? x1.bandwidth() : width/15;
            })
            .attr("height", d => y(0) - y(d.value))
            .attr("fill", d => color(d.key))
            // here to add the tooltip mouseover bar-react
            .on("mouseover", function(event,d) {
              div.transition()
                .duration(200)
                .style("opacity", .9);
              div.html(d.key + ": " + d.value + "<br/>" + "Click to query all transactions")
                .style("left", (event.pageX) + "px")
                .style("top", (event.pageY) + "px");
              })
            .on("mouseout", function(d) {
              div.transition()
                .duration(100)
                .style("opacity", 0);
              })
              .on("click", function(d) {
              
                //window.location.href = "https://gams.uni-graz.at";
            });
            ;

/*
            rects.attr('width', x0.bandwidth)
            .attr('class', 'bar-rect')
            .attr('height', d => innerHeight - y(d["in"]))
            .attr('x', d => x0(d.d))
            .attr('y', d => y(d["in"]));  
  
         
            rects.attr('width', x1.bandwidth)
            .attr('class', 'bar-rect')
            .attr('height', d => innerHeight - y(d["ex"]))
            .attr('x', d => x1(d.d)+1)
            .attr('y', d => y(d["ex"])); 
  */


            
      // y-Axis
      const yAxis = d3.axisLeft(y)
        //.ticks(10)
        //.tickSize(-innerWidth)
        .tickFormat(d => `£ ${d / 1000}K`); 
      const gYAxis = graph.append('g');
      gYAxis.call(yAxis);
    
      // x-Axis
      const xAxis = d3.axisBottom(x0);
      const gXAxis = graph.append('g')
        .attr('transform', `translate(0, ${innerHeight})`);
        //.call(d3.axisBottom(x0).tickSizeOuter(0))
        //.call(g => g.select(".domain").remove());
      
      
        gXAxis.call(xAxis);

      // format text in x-axis
      gXAxis.selectAll('text')
        .style("text-anchor", "end")
        .attr("dx", "-.8em")
        .attr("dy", ".15em")
        .attr("transform", "rotate(-65)");



          
                legend = svg => {
                  const g = svg
                      .attr("transform", `translate(${width},0)`)
                      .attr("text-anchor", "end")
                      .attr("font-family", "sans-serif")
                      .attr("font-size", 10)
                    .selectAll("g")
                    .data(color.domain().slice().reverse())
                    .join("g")
                      .attr("transform", (d, i) => `translate(0,${i * 20})`);
                
                  g.append("rect")
                      .attr("x", -19)
                      .attr("width", 19)
                      .attr("height", 19)
                      .attr("fill", color);
                
                  g.append("text")
                      .attr("x", -24)
                      .attr("y", 9.5)
                      .attr("dy", "0.35em")
                      .text(d => d);
                }


            svg.append("g")
              .call(legend);
              

               // legend = ƒ(svg)


        /*


       

        
        const graph = svg.append('g')
          .attr('width', innerWidth)
          .attr('height', innerHeight)
          .attr('transform', `translate(${margin.left}, ${margin.top})`);
        
        // + ... cast to number as d3.max from datatype string is different
        const bk_value = d => +d["in"];

        //const bk_income = d => d.income;
        //const bk_expens = d => d.expens;
        
        const y = d3.scaleLinear()
          .domain([0, d3.max(data, bk_value)]) 
          .range([innerHeight, 0])
          .nice();  

        // scale on x0 axis
        const x0 = d3.scaleBand()
          .domain(
            // define sorting 
            data.map(d => d.d).sort(function(a, b) {return a - b; })
            )
          .range([0,innerWidth])
          .padding(0.05);

        // scale on x0 axis
        const x1 = d3.scaleBand()
          .domain(
            // define sorting 
            data.map(d => d.d).sort(function(a, b) {return a - b; })
            )
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
     
        rects.attr('width', x0.bandwidth)
          .attr('class', 'bar-rect')
          .attr('height', d => innerHeight - y(d["in"]))
          .attr('x', d => x0(d.d))
          .attr('y', d => y(d["in"]));  

       
          rects.attr('width', x1.bandwidth)
          .attr('class', 'bar-rect')
          .attr('height', d => innerHeight - y(d["ex"]))
          .attr('x', d => x1(d.d)+1)
          .attr('y', d => y(d["ex"])); 


        //var color = d3.scale.ordinal()
        //  .range(["#ca0020","#f4a582","#d5d5d5","#92c5de","#0571b0"]);  
            
        rects.enter()
          .append('rect')
            .attr('class', 'bar-rect')
            .attr('width', x0.bandwidth)
            .attr('height', d => innerHeight - y(d["in"]))
            .attr('x', d => x0(d.d))
            .attr('y', d => y(d["in"]))
            //change color of bar 
            .style('fill', 'steelblue')
          .append('title')
            .text(d => d["in"]); 

     
            rects.enter()
            .append('rect')
              .attr('class', 'bar-rect')
              .attr('width', x1.bandwidth)
              .attr('height', d => innerHeight - y(d["ex"]))
              .attr('x', d => x1(d.d))
              .attr('y', d => y(d["ex"]))
              //change color of bar 
              .style('fill', 'red')
            .append('title')
              .text(d => d["ex"]);  

        const gXAxis = graph.append('g')
          .attr('transform', `translate(0, ${innerHeight})`);

        const xAxis = d3.axisBottom(x0);
        // show x-axis  
        gXAxis.call(xAxis);
        // style text of x-axis
        gXAxis.selectAll('text')
          .style("text-anchor", "end")
          .attr("dx", "-.8em")
          .attr("dy", ".15em")
          .attr("transform", "rotate(-65)");

          //console.log(data);
          //console.log(bk_value);
          //console.log(d3.max(data, bk_value));

      */
      })
    .catch(function(error) 
    {
      console.log('Request failed', error);
    });    

}


////////////////////////////////////////////////
//
function getBubble(query_pid, PID)
{
  
}

////////////////////////////////////////////////
//
function getTreemap(query_pid, PID)
{

  let Base_URL = "https://glossa.uni-graz.at/archive/objects/" + query_pid + "/methods/sdef:Query/getJSON?params="
    let Param = encodeURIComponent("$1|<https://gams.uni-graz.at/"+PID+">");
    let Query_URL = Base_URL + Param;
    let value_type = "in"
    console.log(Query_URL);
    
    //fetch JSON-SPARQL-Result
    fetch(Query_URL, {method: 'get'})
      // transform the data into json
      .then(response => response.json())
      //here you can further process the json (=data)
      .then(function(data)
      {
        //console.log(JSON.stringify(data))
        /*

        
        treemap_data_ = {
          "children":
          [
            {"name":"boss1","children":
              [
                {"name":"mister_a","group":"A","value":28,"colname":"level3"},
                {"name":"mister_b","group":"A","value":19,"colname":"level3"},
                {"name":"mister_c","group":"C","value":18,"colname":"level3"},
                {"name":"mister_d","group":"C","value":19,"colname":"level3"}
              ],"colname":"level2"
            },
            {"name":"boss2","children":
              [
                {"name":"mister_e","group":"C","value":14,"colname":"level3"},
                {"name":"mister_f","group":"A","value":11,"colname":"level3"},
                {"name":"mister_g","group":"B","value":15,"colname":"level3"},
                {"name":"mister_h","group":"B","value":16,"colname":"level3"}
              ],"colname":"level2"
            },
            {"name":"boss3","children":
              [
                {"name":"mister_i","group":"B","value":10,"colname":"level3"},
                {"name":"mister_j","group":"A","value":13,"colname":"level3"},
                {"name":"mister_k","group":"A","value":13,"colname":"level3"},
                {"name":"mister_l","group":"D","value":25,"colname":"level3"},
                {"name":"mister_m","group":"D","value":16,"colname":"level3"},
                {"name":"mister_n","group":"D","value":28,"colname":"level3"}
              ],"colname":"level2"
            }
          ],"name":"CEO"
        };*/

      

        var lookup = {};
        var items = data;
        var result = {};
        var broadest_array = [];
        var broader_array = [];
        result["children"] =  broadest_array;
   
        for (let item, i = 0; item = items[i++];) {
          
          let broadest = item.c_broadest.split('#c_')[1];
          let broader = item.c_broader.split('#c_')[1];
          let commodity = item.c.split('#c_')[1];
         
          if (!(broadest in lookup)) {

            lookup[broadest] = 1;
            let broadest_stmt = {"name":broadest,"children": broader_array}
            broadest_array.push(broadest_stmt)

              //console.log(item)
    
            //let broader_stmt =  {"name":commodity,"group":"B","value":item.t_count}
            let broader_stmt =  {"name":broadest,"group":"B","value":50}
            //console.log(broadest);
            broader_array.push(broader_stmt);
            //console.log(broadest_array);
      
     
           // 
          }
          
        

          
        
        

        }
        console.log(result);
        let treemap_data = result;
        //console.log(JSON.stringify(treemap_data));

        /*
        const aaa = data.reduce((acc, value) => {
            // Group initialization
            let broadest = value.c_broadest.split('#c_')[1];
            let broader = value.c_broader.split('#c_')[1];
            if (!acc[value.broadest]) {
              acc[value.broadest] = [];
            }
          
            // Grouping
            //acc[value.c_broader].push(value);
            //treemap_data["children"].push({"name":value.c_broadest.split('#')[1], "value":value.t_count});
            treemap_data["children"].push({"name":broader, "value":value.t_count});
          return acc;
        }, {});*/


  
       
       
        const width = 1100;
        const height = 900;
        const margin = {'top':35, 'right': 35, 'bottom': 35, 'left': 45};
        const innerWidth = width - margin.left - margin.right;
        const innerHeight = height - margin.top - margin.bottom;
         
        const svg = d3.select('svg#Treemap')
        .attr("viewBox", [0, 0, width, height])
        .style("font", "10px sans-serif");
        //const root = d3.treemap(treemap_data);
 
        var root = d3.hierarchy(treemap_data).sum(function(d){ 
          
          //console.log(d);
          return d.value
        
        }); // Here the size of each leave is given in the 'value' field in input data

              // Then d3.treemap computes the position of each element of the hierarchy
            d3.treemap()
            .size([width, height])
            .padding(2)
            (root)
            
            svg
            .selectAll("rect")
            .data(root.leaves())
            .enter()
            .append("rect")
              .attr('x', function (d) { return d.x0; })
              .attr('y', function (d) { return d.y0; })
              .attr('width', function (d) { return d.x1 - d.x0; })
              .attr('height', function (d) { return d.y1 - d.y0; })
              .style("stroke", "black")
              .style("fill", "slateblue")
        

  // and to add the text labels
  svg
    .selectAll("text")
    .data(root.leaves())
    .enter()
    .append("text")
      .attr("x", function(d){ return d.x0+5})    // +10 to adjust position (more right)
      .attr("y", function(d){ return d.y0+20})    // +20 to adjust position (lower)
      .text(function(d){ return d.data.name })
      .attr("font-size", "15px")
      .attr("fill", "white")

      
          return svg.node();

      })

      .catch(function(error) 
      {
        console.log('Request failed', error);
      });   
      
     
}