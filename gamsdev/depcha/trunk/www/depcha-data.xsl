<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Project: DEPCHA
    Company: ZIM-ACDH
    Author: Christopher Pollin
 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/">
    
    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>
    
    
    <xsl:include href="depcha-static.xsl"/>
    
    
    <!-- GLOBAL VARIABLES -->
    <!-- ///////////////////////////////////// -->
    <xsl:variable name="ResultsResult" select="//s:results/s:result"/>
    <xsl:variable name="FirstResult" select="//s:results/s:result[1]"/>
    <xsl:variable name="FirstResult_Query" select="$FirstResult/s:q"/>
    <xsl:variable name="BASE_URL" select="'https://glossa.uni-graz.at'"/>
    <xsl:variable name="PID" select="substring-before(substring-after($FirstResult_Query, 'gams.uni-graz.at/'), '&gt;')"/>
    <!-- every context:depcha.xy is a dataset; depcha:context is the root context of all of them -->
    <xsl:variable name="Context" select="document(concat($BASE_URL, '/', $PID, '/METADATA'))"/>
    
	<xsl:template name="content">
        <!-- CONTENT-->
                <xsl:choose>
                	<!-- if query = search or collection -->
                	<xsl:when test="$FirstResult_Query">
                	    <!-- ///////////// -->
                	    <!-- HEADER -->
                	    <div class="card-header">
                	        <h1>
                	            <xsl:text>Data View: </xsl:text>
                	            <strong>
                	                <xsl:value-of select="concat($BASE_URL, '/', $PID, '/METADATA')"/>
                	            </strong>
                	        </h1>
                	    </div>
                	    <div class="card-body">
                	        <!-- METADATA ~ teiHeader -->
                	        <div class="row">
                	            <div class="col-sm-8">
                	                <h3 class="card-title">Metadata</h3>
                	                <xsl:call-template name="info_box_tei"/>
                	            </div>
                	            <div class="col-sm-2">
                	                <h3 class="card-title">View</h3>
                	               <!-- <a class="btn mt-1 btn-light btn-block" href="#">Data View</a>
                	                <a class="btn mt-1 btn-light btn-block" href="#">Text</a>
                	                <a class="btn mt-1 btn-light btn-block" href="#">Text-Viewer</a>
                	                <a class="btn mt-1 btn-light btn-block" href="#">Viewer</a> -->                            
                	            </div>
                	            <div class="col-sm-2">
                	                <h3 class="card-title">Export</h3>
                	                <!--<a class="btn mt-1 btn-light btn-block" href="{concat('/',$teipid,'/TEI_SOURCE')}" role="button" title="[Fulltext, Annotation]" target="_blank">
                	                    <img alt="TEI" height="25" id="tei" src="/templates/img/tei_icon.jpg" title="TEI"/>
                	                </a>
                	                <a class="btn mt-1 btn-light btn-block" href="{concat('/',$teipid,'/RDF')}" role="button" title="[Bookkeeping-Data]"  target="_blank">
                	                    <img alt="RDF" height="25" id="rdf" src="/templates/img/RDF_icon.png" title="RDF"/>
                	                    <br/>
                	                </a>-->
                	            </div>
                	        </div>
                	    </div>
                		
                		<!-- //////////////////////////////////////// -->
	                    <!-- DATATABLE -->
	                    <!-- //////////////////////////////////////// -->
                	    
                	    <!-- PARAM context:depcha.wheaton for querying all data in a context  -->
                	    <xsl:variable name="Query_URL" select="'/archive/objects/query:depcha.data-context/methods/sdef:Query/get?params='"/>
                	    

                	    
                	    <div id="datatable">
                	       <script>
                	           getJsonDATA(<xsl:value-of select="concat('&quot;',$PID,'&quot;')"/>);
                	       </script>
                	    </div>
                	    
                	    
	                    <!--<div id="datatable">
	                        <!-\-<h3 class="card-title">
	                            Data Entries
	                        </h3>-\->
	                    	
	                    	 <xsl:for-each-group select="$ResultsResult" group-by="s:Collection/@uri">
	                    	     <xsl:variable name="Table-ID" select="concat('table_id', position())"/>
	                    	     <xsl:if test="not(contains($FirstResult_Query, 'context:depcha'))">
	                    	         <a href="{concat('/archive/objects/query:depcha.data-context/methods/sdef:Query/get?params=$1%7C&lt;', current-grouping-key(), '&gt;')}">
	                    	             <h3 class="card-title" id="{concat($Table-ID, 'name')}">
	                    	                 <xsl:value-of select="s:Collection_name[1]"/>
	                    	                 <xsl:text> </xsl:text>
	                    	             </h3>
	                    	         </a>
	                    	     </xsl:if>
								<!-\- export for objects -\->
	                    	 	 <div class="card-text">
	                    	 	     <xsl:choose>
	                    	 	         <xsl:when test="contains(s:query, '#Between')">
	                    	 	             
	                    	 	         </xsl:when>
	                    	 	         <xsl:when test="contains($FirstResult_Query, 'o:depcha')">
	                    	 	             <a class="btn" href="{concat(substring-before(substring-after($FirstResult_Query, '&lt;'), '&gt;'),'/RDF')}" role="button" style="margin: 10px;" target="_blank">
	                    	 	                 <img alt="RDF" height="25" id="rdf" src="/templates/img/RDF_icon.png" title="RDF"/>
	                    	 	             </a>
	                    	 	            <!-\- <a href="{concat('/archive/objects/query:depcha.data-tei/methods/sdef:Query/get?params=$1%7C&lt;', encode-for-uri(concat('https://gams.uni-graz.at/', //t:idno[@type = 'PID'])), '&gt;')}" id="datatable_button" class="btn">
	                    	 	                 <xsl:text>Datatable</xsl:text>
	                    	 	             </a>-\->
	                    	 	             <a class="button" href="{concat(substring-before(substring-after($FirstResult_Query, '&lt;'), '&gt;'),'/TEI_SOURCE')}" role="button" style="margin: 10px;" target="_blank">
	                    	 	                 <img alt="TEI" height="25" id="tei" src="/templates/img/tei_icon.jpg" title="TEI"/>
	                    	 	             </a>
	                    	 	         </xsl:when>
	                    	 	         <xsl:otherwise/>
	                    	 	     </xsl:choose>
	                    	 	     
	                    	 	<!-\- ecreate query -\->
	                    	 	<xsl:variable name="QueryParam">
	                    	 	<xsl:choose>
	                    	 		<xsl:when test="contains(s:query, 'context:depcha')">
	                    	 		    <xsl:choose>
	                    	 		        <!-\- its a person -\->
	                    	 		        <xsl:when test="contains(s:query, '#')">
	                    	 		            <xsl:value-of select="concat('/archive/objects/query:depcha.index-accounts/methods/sdef:Query/getHSSF?params=$1%7C', encode-for-uri(s:query))"/>
	                    	 		        </xsl:when>
	                    	 		        <!-\- its a context -\->
	                    	 		        <xsl:otherwise>
	                    	 		            <xsl:value-of select="concat('/archive/objects/query:depcha.data-context/methods/sdef:Query/getHSSF?params=$1%7C', s:query)"/>
	                    	 		        </xsl:otherwise>
	                    	 		    </xsl:choose>
	                    	 		</xsl:when>
	                    	 	    <!-\- its a tei -\->
	                    	 	    <xsl:when test="contains(s:query, 'o:depcha')">
	                    	 	        <xsl:value-of select="concat('/archive/objects/query:depcha.data-tei/methods/sdef:Query/getHSSF?params=$1%7C', s:query)"/>
	                    	 	    </xsl:when>
	                    	 		<!-\- it a fulltext search -\->
	                    	 		<xsl:otherwise>
	                    	 			<xsl:value-of select="concat('/archive/objects/query:depcha.fulltext/methods/sdef:Query/getHSSF?params=$1%7C', s:query)"/>
	                    	 		</xsl:otherwise>
	                    	 	</xsl:choose>
	                    	 	</xsl:variable>
	                    	 
                                <a class="btn" href="{$QueryParam}" role="button" style="margin: 10px;">
                                    <img alt="Excel" height="25" id="rdf" src="{concat($gamsdev, '/img/TABELLENSYMBOL.png')}" title="HSSF"/>
                                </a>
                    	 	     <!-\-  -\->
	                    	 	<xsl:if test="contains(s:query, 'gams.uni-graz.at')">
	                    	 	 <xsl:variable name="PARAM" select="encode-for-uri(concat('$1|', s:query))"/>
	                    	 	 <a class="btn" href="{concat('/archive/objects/query:depcha.bycommodity/methods/sdef:Query/get?params=', $PARAM)}">
                    	 	         <xsl:text>Bubble Visualization Commodities</xsl:text>
                    	 	     </a>
	                    	 	 </xsl:if>
	                    		</div>
	                    		
	                    		<xsl:variable name="Table-ID" select="concat('table_id', position())"/>
		                    	<!-\- call DataTable -\->
								<script>
								    $(document).ready(function() {
								    $('#<xsl:value-of select="$Table-ID"/>').DataTable();
								    } );
								</script>
	                    	 	
	                    	 	<!-\- DATATABLE -\->
		                        <table id="{$Table-ID}" class="table table-bordered" style="width:100%">
		                            <thead>
		                                <tr>
		                                    <th><xsl:text>ENTRY</xsl:text></th>
		                                    <th><xsl:text>WHEN</xsl:text></th>
		                                    <th><xsl:text>FROM</xsl:text></th>
		                                    <th><xsl:text>TO</xsl:text></th>
		                                    <th><xsl:text>MEASURABLE</xsl:text></th>
		                                    <th><xsl:text></xsl:text></th>
		                                </tr>
		                            </thead>
		                            <tbody>
		                            </tbody>
		                        </table>
	                    	 </xsl:for-each-group>
	                    </div>-->
                	</xsl:when>
	            	<xsl:otherwise>
		            	<div class="card-header"> 
	                        <h1 class="card-title">
	                            <xsl:text>Nothing found</xsl:text>
	                        </h1>
	                        <div class="card-body">
	                            <p>Here is some help for super cool search queries!</p>
	                        </div>
		                </div>
	            	</xsl:otherwise>
           </xsl:choose> 
         
      
    
    </xsl:template>
    
    
    
    <!-- ///////////////////////////////////// -->
    <!--  Bar Chart with Negative Values https://bl.ocks.org/WillTurman/9c4142944f6132855fd318350f552b7b -->
    <!-- ///////////////////////////////////// -->
    <xsl:template name="getBarChartInandOutcome">
        <div id="barchart_in_out">
        <!-- //////////////////////////////////////// -->
        <!-- VISUALISATION -->
        <!-- //////////////////////////////////////// -->
        <div class="col-md-12" id="Barchart">
            <div class="card">
                <h3 class="card-title">
                    <xsl:text>In and Outcomes of recording author</xsl:text>
                </h3>
                <div class="row" id="Visualisation">
                    <style>
                        .bar {
                        fill: steelblue;
                        }
                        .bar:hover {
                        fill: brown;
                        }
                        .axis-\-x path {
                        display: none;
                        }
                    </style>
                    <!-- ///////////////////////////////////// -->
                    <!--  Bar Chart https://bl.ocks.org/mbostock/3885304 -->
                    <!--<xsl:call-template name="getBarChart"/>-->         
                    <script>
                        var data = 
                        [<xsl:for-each-group select="$ResultsResult[s:When castable as xs:date]" group-by="year-from-date(s:When)">
                    		<xsl:sort select="current-grouping-key()"/><xsl:variable name="From_Sum">
                          		<xsl:call-template name="calculateSum_From">
                          		    <xsl:with-param name="Collection_URI" select="s:Collection/@uri"/>
                          		    <!-- must be a RDF triple and query result -->
                          		    <xsl:with-param name="Main_Recording_Author">
                          		        <xsl:choose>
                          		            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:sampleData'">
                          		                <xsl:value-of select="'CP_Pers.01'"/>
                          		            </xsl:when>
                          		            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.wheaton'">
                          		                <xsl:value-of select="'pers_MightyWheatonHimself'"/>
                          		            </xsl:when>
                          		            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.stagville'">
                          		                <xsl:value-of select="'StagyStagville'"/>
                          		            </xsl:when>
                          		            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.wfp'">
                          		                <xsl:value-of select="'11833'"/>
                          		            </xsl:when>
                          		            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.schlitz'">
                          		                <xsl:value-of select="'pers_TheSchlitzBros'"/>
                          		            </xsl:when>
                          		            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.regensburg'">
                          		                <xsl:value-of select="'bk_Regensburg'"/>
                          		            </xsl:when>
                          		        </xsl:choose>
                          		    </xsl:with-param>
                          		</xsl:call-template>
                    		</xsl:variable>
                            <xsl:variable name="To_Sum">
                                <xsl:call-template name="calculateSum_To">
                                    <xsl:with-param name="Collection_URI" select="s:Collection/@uri"/>
                                    <xsl:with-param name="Main_Recording_Author">
                                        <xsl:choose>
                                            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:sampleData'">
                                                <xsl:value-of select="'CP_Pers.01'"/>
                                            </xsl:when>
                                            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.wheaton'">
                                                <xsl:value-of select="'pers_MightyWheatonHimself'"/>
                                            </xsl:when>
                                            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.stagville'">
                                                <xsl:value-of select="'StagyStagville'"/>
                                            </xsl:when>
                                            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.wfp'">
                                                <xsl:value-of select="'11833'"/>
                                            </xsl:when>
                                            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.schlitz'">
                                                <xsl:value-of select="'pers_TheSchlitzBros'"/>
                                            </xsl:when>
                                            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.regensburg'">
                                                <xsl:value-of select="'bk_Regensburg'"/>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:variable>
                            <!-- mittelwert -->
                            <xsl:variable name="test">
                                <xsl:value-of select="$To_Sum + $From_Sum"/>
                            </xsl:variable>
                         	{"date": <xsl:value-of select="current-grouping-key()"/>,"from": <xsl:value-of select="$From_Sum"/>,"to": <xsl:value-of select="$To_Sum"/>,"cfnai": <xsl:value-of select="$test"/>}
            				<xsl:if test="not(position()=last())">
            					<xsl:text>,</xsl:text>
            				</xsl:if>
                         </xsl:for-each-group>];
               
                   	var margin = {top: 20, right: 20, bottom: 30, left: 40};
                   	var width = 960 - margin.left - margin.right;
                   	var height = 500 - margin.top - margin.bottom;
                   
                    var timeFormat = d3.timeFormat("%Y");
                   	var parseDate = d3.timeParse("%Y");
            
                   	var x = d3.scaleTime()
                   		.range([0, width]);
                   
                   	var y = d3.scaleLinear()
                   		.range([height, margin.top]);
                   
                   	var center = d3.scaleLinear()
                   		.range([0, width]);
                   
                   	var color = d3.scaleOrdinal()
                   	.range(["#B13C3D","#BBCDA3" ]);
                   
                   	var labels = ["From", "To"];
                   
                   <!-- ticks sind die einzelnen Sprünge im Diagramm, x-Achse, die datumsangaben, y-Achse die Werte
                        https://stackoverflow.com/questions/52057498/d3-timeparsey-dates-1895-before-are-not-labled-correctly
                   -->
                        var xAxis = d3.axisBottom(x)
                        .ticks(10)
                        .tickFormat(function(d) { return  timeFormat(d); })
                        var yAxis = d3.axisLeft(y).ticks(20);
                   
                   	var centerLine = d3.axisTop(center).ticks(0);
                   	data = data.slice(data.length - 125, data.length );
                   	var keys = d3.keys(data[0]);
                   	var keys = keys.filter(function(key) { 
                   		if (key !== "id" <xsl:text disable-output-escaping = "yes"><![CDATA[&&]]></xsl:text>  key !== "date" <xsl:text disable-output-escaping = "yes"><![CDATA[&&]]></xsl:text> key !== "cfnai") {
                   			return key; 
                   		}  
                   	});
                   	
                   	data.forEach(function(d) {
                       	var y0_positive = 0;
                       	var y0_negative = 0;
                       	d.components = keys.map(function(key) 
                       	{
                       		if (d[key] <xsl:text disable-output-escaping = "yes"><![CDATA[>]]></xsl:text>= 0) {
                       			return {key: key, y1: y0_positive, y0: y0_positive += d[key] };
                       		} 
                       		<!-- < > = -->
                       		else if (d[key] <xsl:text disable-output-escaping = "yes"><![CDATA[<]]></xsl:text> 0) {
                       			return {key: key, y0: y0_negative, y1: y0_negative += d[key] };
                       		}
                       	})
                   	})
                   	
                   	var y_min = d3.min(data, function(d) { return d.cfnai - 0.1 });
                   	var y_max = d3.max(data, function(d) { return d.cfnai + 0.1 });
                   	
                   	var datestart = d3.min(data, function(d) { return parseDate(d.date); });
                   	var dateend = d3.max(data, function(d) { return parseDate(d.date); });
                   	
                   	x.domain([datestart, dateend]);
                   	y.domain([y_min, y_max]);
                   	color.domain(keys);
                   
                   <!--	var cfnai_ma3 = d3.line()
                   		.x(function(d) { return x(parseDate(d.date)); })
                   		.y(function(d) { return y(d.cfnai_ma3); });-->
                   
                   	var svg = d3.select("#barchart_in_out").append("svg")
                   								.attr("width", width + margin.left + margin.right)
                   								.attr("height", height + margin.top + margin.bottom)
                   								.append("g")
                   								.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
                   								
                   	svg.append("g")
                   		.attr("class", "x axis")
                   		.attr("transform", "translate(0," + height + ")")
                   		.call(xAxis);
                   
                   	svg.append("g")
                   		.attr("class", "y axis")
                   		.call(yAxis);
                   
                   	svg.append("g")
                   		.attr("class", "centerline")
                   		.attr("transform", "translate(0," + y(0) + ")")
                   		.call(centerLine);
                   
                   	var entry = svg.selectAll(".entry")
                   		.data(data)
                   		.enter().append("g")
                   		.attr("class", "g")
                   		.attr("transform", function(d) { return "translate(" + x(parseDate(d.date)) + ", 0)"; });
                   		
                       <!-- here <rect> every bar can be edited -->
                   	entry.selectAll("rect")
                   		.data(function(d) { return d.components; })
                   		.enter().append("a")
                   		.attr("xlink:href", "www.wiki.at")
                   		.append("rect")
                   		.attr("width", 3)
                   		.attr("y", function(d) { return y(d.y0); })
                   		.attr("height", function(d) { return Math.abs(y(d.y0) - y(d.y1)); })
                   		.style("fill", function(d) { return color(d.key); } )
                   		.append("title")
                   		.text(function(d) { return  "All entries in " + d.date; });
                   		
                <!--   	var cfnai_ma3_line = svg.append("path")
                   		.datum(data)
                   		.attr("class", "line")
                   		.attr("d", cfnai_ma3);
                   -->
                   	var legend = svg.selectAll(".legend")
                   		.data(color.domain())
                   		.enter().append("g")
                   		.attr("class", "legend")
                   		.attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });
                   
                   	legend.append("rect")
                   		.attr("x", 675)
                   		.attr("y", function(d, i) { return i * 25 + 300 })
                   		.attr("width", 18)
                   		.attr("height", 18)
                   		.style("fill", color )
                   
                   	legend.append("text")
                   		.attr("x", 700)
                   		.attr("y", function(d, i) { return i * 25 + 309; })
                   		.attr("dy", ".35em")
                   		.style("text-anchor", "start")
                   		.text(function(d, i) { return labels[i]; });
                    </script>
                </div>
            </div>
        </div>
        </div>
    </xsl:template>

    
    
    <!-- ///////////////////////////////////// -->
    <!--  Bubble Chart https://bl.ocks.org/john-guerra/0d81ccfd24578d5d563c55e785b3b40a with json -->
    <!-- ///////////////////////////////////// -->
    <xsl:template name="getBubbleChart">
        <!-- //////////////////////////////////////// -->
        <!-- MEASURABLES BUBBLE CHART -->
        <div class="col-md-12" id="Measurables">
                    <div class="card">
                        <h3 class="card-title">Commodities and Services</h3>
                        <xsl:choose>
                            <xsl:when test="$ResultsResult/s:Commodity">
                        <div id="bubble">
                             <script>
                             <!-- data is stored as json for d3.js -->
                             var data = {
                              "name": "Measurables",
                              "children": 
                              [<xsl:for-each-group select="$ResultsResult" group-by="s:Commodity">
                                 {"name": "<xsl:value-of select="s:Commodity"/>","children": 
                                 [{"name": "<xsl:value-of select="s:Commodity"/>","size": <xsl:value-of select="count(current-group())"/>}]               
                                 }
                                 <xsl:if test="not(position()=last())">
                                     <xsl:text>,</xsl:text>
                                 </xsl:if>
                              </xsl:for-each-group> ]};
                     
                              var diameter = 960,
                              format = d3.format(",d"),
                              color = d3.scaleOrdinal(d3.schemeCategory20c);
                              
                              var bubble = d3.pack()
                              .size([diameter, diameter])
                              .padding(1.5);
                              
                              var svg = d3.select("#bubble").append("svg")
                              .attr("width", diameter)
                              .attr("height", diameter)
                              .attr("class", "bubble");
                              
                              var root = d3.hierarchy(classes(data))
                              .sum(function(d) { return d.value; })
                              .sort(function(a, b) { return b.value - a.value; });
                              
                              bubble(root);
                              var node = svg.selectAll(".node")
                              .data(root.children)
                              .enter().append("g")
                              .attr("class", "node")
                              .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });
                              
                              node.append("title")
                              .text(function(d) { return d.data.className + ": " + format(d.value); });
                              node.append("a")
                              <!-- createsthe @href searchquery with d.data.className = bk:Commodity  -->
                                 .attr("xlink:href", function(d) { return "/archive/objects/query:depcha.index-commodity/methods/sdef:Query/get?params=$1%7C" + d.data.className})
                              .append("circle")
                              .attr("r", function(d) { return d.r; })
                              .style("fill", function(d) { 
                              return color(d.data.packageName); 
                              });
                              
                              node.append("text")
                              .attr("dy", ".3em")
                              .style("text-anchor", "middle")
                              .text(function(d) { return d.data.className.substring(0, d.r / 3); });
                              
                              // Returns a flattened hierarchy containing all leaf nodes under the root.
                              function classes(root) {
                              var classes = [];
                              
                              function recurse(name, node) {
                              if (node.children) node.children.forEach(function(child) { recurse(node.name, child); });
                              else classes.push({packageName: name, className: node.name, value: node.size});
                              }
                              
                              recurse(null, root);
                              return {children: classes};
                              }
                              
                              d3.select(self.frameElement).style("height", diameter + "px");
                             </script>
                        </div>
                        </xsl:when>
                       <xsl:otherwise>
                           <p>No Commodities exist.</p>
                       </xsl:otherwise>
                   </xsl:choose>
                  </div>
        </div> 
    </xsl:template>
    
    <xsl:template name="calculateSum_To">
        <xsl:param name="Collection_URI"/>
        <xsl:param name="Main_Recording_Author"/>
        <xsl:choose>
            <!-- 1 Pounds = 12 shilling = 20 Pence-->
            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.stagville' or s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.wfp'">
                <xsl:value-of select="round(sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'Pounds' or ../s:Unit = 'pounds']) +
                    (sum(current-group()[contains(s:To/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'Shillings' or ../s:Unit = 'shillings']) div 12) +
                    (sum(current-group()[contains(s:To/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'Pence' or ../s:Unit = 'pence']) div 20))"/>
            </xsl:when>
            <!-- contains(s:Collection/@uri,'context:depcha.wheaton') -->
            <xsl:when test="current-group()[1]/s:Collection/@uri = $Collection_URI">
                <xsl:value-of select="round(sum(current-group()[contains(s:To/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'dollars']) +
                    (sum(current-group()[contains(s:To/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'cents']) div 100))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>	
    </xsl:template>
    
    <xsl:template name="calculateSum_From">
        <xsl:param name="Collection_URI"/>
        <xsl:param name="Main_Recording_Author"/>
        <xsl:choose>
            <!-- 1 Pounds = 12 shilling = 20 Pence-->
            <xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.stagville' or s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.wfp'">
                <xsl:variable name="Sum" select="sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'Pounds' or ../s:Unit = 'pounds']) +
                    (sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'Shillings' or ../s:Unit = 'shillings']) div 12) +
                    (sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'Pence' or ../s:Unit = 'pence']) div 20)"/>
                <xsl:choose>
                    <xsl:when test="$Sum = 0">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="-(round($Sum))"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        	<xsl:when test="s:Collection/@uri = 'https://gams.uni-graz.at/context:depcha.regensburg' ">
                <xsl:variable name="Sum" select="sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'lb']) +
                    (sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'ß' or ../s:Unit = 'shillings']) div 12) +
                    (sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'd' or ../s:Unit = 'pence']) div 20)"/>
                <xsl:choose>
                    <xsl:when test="$Sum = 0">
                        <xsl:value-of select="0"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="-(round($Sum))"/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- contains(s:Collection/@uri,'context:depcha.wheaton'); -() makes it a negative value -->
           <xsl:when test="s:Collection/@uri = $Collection_URI">
               <xsl:variable name="Sum" select="sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'dollars']) +
                   (sum(current-group()[contains(s:From/@uri, $Main_Recording_Author)][s:Measurable_type/@uri='https://gams.uni-graz.at/o:depcha.bookkeeping#Money']/s:Quantity[../s:Unit = 'cents']) div 100)"/>
               <xsl:choose>
                   <xsl:when test="$Sum = 0">
                       <xsl:value-of select="0"/>
                   </xsl:when>
                   <xsl:otherwise><xsl:value-of select="-(round($Sum))"/></xsl:otherwise>
               </xsl:choose>
           </xsl:when>
           <xsl:otherwise>
               <xsl:value-of select="0"/>
           </xsl:otherwise>
           </xsl:choose>	
    </xsl:template>

    <!-- ///////////////////////////////////// -->
    <!-- adds @data- to a HTML structure which is than used for databasket.js -->
    <xsl:template name="addDatabasket">
        <xsl:param name="URI"/>
        <xsl:param name="ENTRY"/>
        <xsl:param name="FROM"/>
        <xsl:param name="TO"/>
        <xsl:param name="WHEN"/>
        <xsl:param name="MEASURABLE"/>
        <xsl:attribute name="data-check">
            <xsl:text>unchecked</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="data-uri">
            <xsl:value-of select="$URI"/>
        </xsl:attribute>
        <xsl:if test="$ENTRY">
            <xsl:attribute name="data-entry">
                <xsl:value-of select="$ENTRY"/>
            </xsl:attribute>
        </xsl:if>
        <!-- FROM -->
        <xsl:choose>
            <xsl:when test="$FROM">
                <xsl:attribute name="data-from">
                    <xsl:value-of select="$FROM"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <!-- TO -->
        <xsl:choose>
            <xsl:when test="$TO">
                <xsl:attribute name="data-to">
                    <xsl:value-of select="$TO"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <!-- WHEN-->
        <xsl:choose>
            <xsl:when test="$WHEN">
                <xsl:attribute name="data-when">
                    <xsl:value-of select="$WHEN"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
        <!-- WHEN-->
        <xsl:choose>
            <xsl:when test="$MEASURABLE">
                <xsl:attribute name="data-measurable">
                    <xsl:value-of select="$MEASURABLE"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
	
	<!-- Begin TEI info box -->
    
    
    
   
	
</xsl:stylesheet>


