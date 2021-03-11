
// name: gamsInfoVis.js 
// author: Christopher Pollin
// date: 2020
// dependencies D3.js

////////////////////////////////////////////////
//
function getBarChart_Date_Value(query_pid, PID)
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
        const width = 1100;
        const height = 750;
        const margin = {'top':35, 'right': 35, 'bottom': 35, 'left': 45};
        const innerWidth = width - margin.left - margin.right;
        const innerHeight = height - margin.top - margin.bottom;

        const svg = d3.select('svg#' + value_type)
          //.attr('width', width)
          //.attr('height', height);
          .attr("viewBox", [0, 0, width, height]);
        
        const graph = svg.append('g')
          .attr('width', innerWidth)
          .attr('height', innerHeight)
          .attr('transform', `translate(${margin.left}, ${margin.top})`);
        
        // + ... cast to number as d3.max from datatype string is different
        const bk_value = d => +d[value_type];

        //const bk_income = d => d.income;
        //const bk_expens = d => d.expens;
        
        const y = d3.scaleLinear()
          .domain([0, d3.max(data, bk_value)]) 
          .range([innerHeight, 0])
          .nice();  

        // scale on x axis
        const x = d3.scaleBand()
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
     
        rects.attr('width', x.bandwidth)
          .attr('class', 'bar-rect')
          .attr('height', d => innerHeight - y(d[value_type]))
          .attr('x', d => x(d.d))
          .attr('y', d => y(d[value_type]));  
            
        rects.enter()
          .append('rect')
            .attr('class', 'bar-rect')
            .attr('width', x.bandwidth)
            .attr('height', d => innerHeight - y(d[value_type]))
            .attr('x', d => x(d.d))
            .attr('y', d => y(d[value_type])) 
          .append('title')
            .text(d => d[value_type]); 

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

          //console.log(data);
          //console.log(bk_value);
          //console.log(d3.max(data, bk_value));

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
        };

        let treemap_data = {
          "children":
          [
            
          ],"name":"data"
        };


        const aaa = data.reduce((acc, value) => {
            // Group initialization
            if (!acc[value.c_broader]) {
              acc[value.c_broader] = [];
            }
          
            // Grouping
            //acc[value.c_broader].push(value);
            treemap_data["children"].push({"name":value.c_broader.split('#')[1], "value":value.t_count});

          return acc;
        }, {});

        console.log(treemap_data)
       
        const width = 1100;
        const height = 900;
        const margin = {'top':35, 'right': 35, 'bottom': 35, 'left': 45};
        const innerWidth = width - margin.left - margin.right;
        const innerHeight = height - margin.top - margin.bottom;
         
        const svg = d3.select('svg#tree')
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