<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Project: GAMS Projekttemplate
    Company: ZIM-ACDH (Zentrum fÃ¼r Informationsmodellierung - Austrian Centre for Digital Humanities)
 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all">
    
    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>
    
    
    <xsl:include href="medea-static.xsl"/>
    
	<xsl:template name="content">
    <!-- VARIABLES -->
    <!-- ///////////////////////////////////// -->
    <!-- extract context out of <query></context:medea.wfp></query> -->
   
    <!-- if Query contains a context its a Collection, otherwise a searchresult -->
    <!-- CONTEYT -->
    <xsl:variable name="Context">
        <xsl:choose>
            <xsl:when test="contains(//s:results/s:result[1]/s:query, 'context:medea')">
                <xsl:value-of select="substring-before(substring-after(//s:results/s:result[1]/s:query, 'uni-graz.at/'), '>')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="//s:results/s:result[1]/s:query"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- CONTEXTTITLE -->
    <xsl:variable name="ContextTitle">
        <xsl:choose>
            <xsl:when test="contains($Context, 'context:medea')">
                <xsl:value-of select="document(concat('/archive/objects/', $Context, '/methods/sdef:Object/getMetadata'))//s:results/s:result[1]/s:container"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$Context"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    
    <!-- d3.js CSS -->
		
		<!-- delet? -->
		
<!--    <style>
        table.ex1 {
        empty-cells: hide;
        }
        
        table.ex2 {
        empty-cells: show;
        }
    </style>
    <style>
        .links line{
        stroke: #999;
        stroke-opacity: 0.6;
        }
        
        .nodes circle{
        stroke: #fff;
        stroke-width: 1.5px;
        }
    </style>-->
       
     <div class="row">
         <!-- ///////////////////////////////////////////////////////////// -->
         <!-- NAV -->
         <!-- //////////////////////////////////////// -->
        <!--<div class="col-md-2">
            <div class="card" id="sticky-sidebar">
                <div class="card-header">
                    <h3>Navigation</h3>
                    <!-\-<a href="#" target="_blank">
                        <img alt="RDF" id="rdf" src="/templates/img/RDF_icon.png" title="RDF" height="25"/>
                    </a>-\->
                    <br/>
                    
                </div>
                <div class="card-body">  
                    <ul>
                        <li>
                            <a href="#Actors" onclick="scrolldown(this)">Actors</a>
                        </li>
                        <li>
                            <a href="#Measurables" onclick="scrolldown(this)">Measurables</a>
                        </li>
                        <li>
                            <a href="#Visualisation"  onclick="scrolldown(this)">Visualisation</a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>-->
        <!-- ///////////////////////////////////////////////////////////// -->
        <!-- CONTENT-->
         <!-- //////////////////////////////////////// -->
        <div class="col-md-12">
            <div class="card">
                <xsl:choose>
                	<!-- if query = search or collection -->
                	<xsl:when test="//s:results/s:result[1]/s:query">
                		<div class="card-header"> 
	                        <h1 class="card-title">
	                            <xsl:choose>
	                                <xsl:when test="contains($Context, 'context:medea')">
	                                    <xsl:value-of select="$ContextTitle"/>
	                                </xsl:when>
	                                <xsl:when test="contains($Context, 'o:medea')">
	                                    <xsl:text>TEI SOURCE: </xsl:text>
	                                    <xsl:value-of select="document(concat((substring-before(substring-after(//s:results/s:result[1]/s:query, '&lt;'), '&gt;')), '/TEI_SOURCE'))//t:titleStmt/t:title"/>
	                                </xsl:when>
	                                <xsl:otherwise>
	                                    <xsl:text>SEARCH: </xsl:text><mark><xsl:value-of select="$ContextTitle"/></mark>
	                                	<br/>
	                                	<xsl:text>SEARCHRESULT: </xsl:text><xsl:value-of select="count(distinct-values(//s:results/s:result/s:Transfer/@uri))"/>
	                                </xsl:otherwise>
	                            </xsl:choose>
	                        </h1>
	                        <div>
	                            <p>
	                            	<xsl:text>Here can be a nice Text!</xsl:text>
	                            </p>
	                        </div>
	                    </div>
                		<!-- //////////////////////////////////////// -->
	                    <!-- DATATABLE -->
	                    <!-- //////////////////////////////////////// -->
	                    <div class="card-body" id="datatable">
	                        <!--<h3 class="card-title">
	                            Data Entries
	                        </h3>-->
	                    	
	                    	 <xsl:for-each-group select="//s:result" group-by="s:Collection/@uri">
	                    	     <!-- https://glossa.uni-graz.at/archive/objects/context:medea.wfp/methods/sdef:Object/getMetadata -->
	                    	     <xsl:if test="not(contains($Context, 'context:medea'))">
	                    	         <a href="{concat('/archive/objects/query:medea.getdata-context/methods/sdef:Query/get?params=$1|&lt;', current-grouping-key(), '&gt;')}">
	                    	             <h3 class="card-title"><xsl:value-of select="document(concat('/archive/objects/', substring-after(current-grouping-key(), '//gams.uni-graz.at/'), '/methods/sdef:Object/getMetadata'))//s:results/s:result[1]/s:container"/>
	                    	             </h3>
	                    	         </a>
	                    	     </xsl:if>
	                    	     
								<!-- export for objects -->
	                    	 	 <div class="card-text">
	                    	 	 	<xsl:if test="contains($Context, 'o:medea')">
		                    	 	    <a class="btn" href="{concat(substring-before(substring-after(//s:results/s:result[1]/s:query, '&lt;'), '&gt;'),'/RDF')}" role="button" style="margin: 10px;" target="_blank">
	                                    	<img alt="RDF" height="25" id="rdf" src="/templates/img/RDF_icon.png" title="RDF"/>
		                    	 	    </a>
	                    	 	 		<a href="{concat('/archive/objects/query:medea.getdata-tei/methods/sdef:Query/get?params=$1|&lt;https://glossa.uni-graz.at/', //t:idno[@type = 'PID'], '&gt;')}" id="datatable_button" class="btn">
                         	 	        	<xsl:text>Datatable</xsl:text>
                         	 	   		 </a>
	                    	 	 		<a class="button" href="{concat(substring-before(substring-after(//s:results/s:result[1]/s:query, '&lt;'), '&gt;'),'/TEI_SOURCE')}" role="button" style="margin: 10px;" target="_blank">
                    	 	            	<img alt="TEI" height="25" id="tei" src="/templates/img/tei_icon.jpg" title="TEI"/>
                    	 	        	</a>
                    	 	    </xsl:if>
	                    	 	
	                    	 	<!-- ecreate query -->
	                    	 	<xsl:variable name="QueryParam">
	                    	 	<xsl:choose>
	                    	 		<!-- if its a search query -->
	                    	 		<xsl:when test="contains(s:query, 'context:medea')">
	                    	 			<xsl:value-of select="concat('/archive/objects/query:medea.getdata-context/methods/sdef:Query/getHSSF?params=$1|', s:query)"/>
	                    	 		</xsl:when>
	                    	 	    <xsl:when test="contains(s:query, 'o:medea')">
	                    	 	        <xsl:value-of select="concat('/archive/objects/query:medea.getdata-tei/methods/sdef:Query/getHSSF?params=$1|', s:query)"/>
	                    	 	    </xsl:when>
	                    	 		<!-- it is a collection -->
	                    	 		<xsl:otherwise>
	                    	 			<xsl:value-of select="concat('/archive/objects/query:medea.fulltext/methods/sdef:Query/getHSSF?params=$1|', s:query)"/>
	                    	 		</xsl:otherwise>
	                    	 	</xsl:choose>
	                    	 	</xsl:variable>
	                    	 	
	                    	 	<!-- /archive/objects/query:medea.getcollection/methods/sdef:Query/getHSSF?params=$1|<https%3A%2F%2Fglossa.uni-graz.at%2Fcontext:medea.schlitz> -->
                                <a class="btn" href="{$QueryParam}" role="button" style="margin: 10px;">
                                    <img alt="Excel" height="25" id="rdf" src="/gamsdev/pollin/medea/trunk/www/img/TABELLENSYMBOL.png" title="HSSF"/>
                                </a>
	                    		</div>
	                    		
	                    		<xsl:variable name="Table-ID" select="concat('table_id', position())"/>
		                    	<!-- call DataTable -->
								<script>
								    $(document).ready(function() {
								    $('#<xsl:value-of select="$Table-ID"/>').DataTable();
								    } );
								</script>
	                    	 	
	                    	 	<!-- DATATABLE -->
		                        <table id="{$Table-ID}" class="table table-striped table-bordered display" style="width:100%">
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
		                            	<!-- //////////////////////////////////////// -->
		                                <xsl:for-each-group select="current-group()" group-by="s:Transfer/@uri">
		                                    <xsl:sort select="s:When"/>
		                                  
		                                  <!--<xsl:for-each select="current-group()">-->
		                                    <!-- variables -->
		                                    <!-- TEI-PID: gams.uni-graz.at/ o:medea.wheaton.181 #Transaction-31-Transfer-1 -->
		                                    <xsl:variable name="TEI" select="substring-before(substring-after(s:Transfer/@uri, 'https://gams.uni-graz.at/'), '#')"/>
		                                	
		                                	<!-- Entry -->
		                                    <xsl:variable name="Entry" select="normalize-space(s:Entry)"/>
		                                    
		                                	<!-- DATE -->
		                                    <xsl:variable name="Date" select="normalize-space(s:When)"/>
		                                    <xsl:variable name="Year">
		                                        <xsl:choose>
		                                            <xsl:when test="$Date castable as xs:date">
		                                                <xsl:value-of select="year-from-date(xs:date($Date))"/>
		                                            </xsl:when>
		                                            <xsl:otherwise/>
		                                        </xsl:choose>
		                                    </xsl:variable>
		                                    <xsl:variable name="Month">
		                                        <xsl:choose>
		                                            <xsl:when test="$Date castable as xs:date">
		                                                <xsl:value-of select="month-from-date(xs:date($Date))"/>
		                                            </xsl:when>
		                                            <xsl:otherwise/>
		                                        </xsl:choose>
		                                    </xsl:variable>
		                                    <xsl:variable name="Day">
		                                        <xsl:choose>
		                                            <xsl:when test="$Date castable as xs:date">
		                                                <xsl:value-of select="day-from-date(xs:date($Date))"/>
		                                            </xsl:when>
		                                            <xsl:otherwise/>
		                                        </xsl:choose>
		                                    </xsl:variable>
		                                	
		       								<!-- FROM/TO name -->
		                                    <xsl:variable name="From" select="normalize-space(s:From_name)"/>
		                                    <xsl:variable name="To" select="normalize-space(s:To_name)"/>
		                                    <!-- MEASURABLE -->
		                                    
		                                	<xsl:variable name="Measurable_type" select="substring-after(s:Measurable_type/@uri, '#')"/>
		                                    <!--<xsl:variable name="Measurable">
		                                        <xsl:choose>
		                                            <xsl:when test="$Measurable_type = 'Money'">
		                                                <xsl:for-each-group select="current-group()" group-by="s:Unit">
		                                                    <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/>
		                                                </xsl:for-each-group>
		                                            </xsl:when>
		                                            <xsl:when test="$Measurable_type = 'Service'">
		                                                <xsl:for-each-group select="current-group()" group-by="s:Unit">
		                                                    <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/>
		                                                </xsl:for-each-group>
		                                            </xsl:when>
		                                            <xsl:when test="$Measurable_type = 'Commodity'">
		                                                <xsl:for-each-group select="current-group()" group-by="s:Unit">
		                                                    <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/>
		                                                </xsl:for-each-group>
		                                            </xsl:when>
		                                            <xsl:otherwise>nope</xsl:otherwise>
		                                        </xsl:choose>
		                                    </xsl:variable>-->
		                                    <tr>
		                                        <td>
		                                            <a href="/{$TEI}" data-toggle="tooltip" title="To the TEI Source">
		                                            	<xsl:value-of select="$Entry"/>
		                                            </a>
		                                        </td>
		                                        <td>
		                                            <xsl:if test="$Day">
		                                                <xsl:value-of select="$Day"/><xsl:text>.</xsl:text>
		                                            </xsl:if>
		                                            <xsl:if test="$Month">
		                                                <xsl:value-of select="$Month"/><xsl:text>.</xsl:text>
		                                            </xsl:if>
		                                            <xsl:value-of select="$Year"/><xsl:text> </xsl:text>
		                                        </td>
		                                        <td>
		                                            <xsl:value-of select="$From"/><xsl:text> </xsl:text>
		                                        </td>
		                                        <td>
		                                            <xsl:value-of select="$To"/><xsl:text> </xsl:text>
		                                        </td>
		                                        <td>
		                                            <xsl:choose>
		                                                <xsl:when test="$Measurable_type = 'Money'">
		                                                    <!-- for every shilling, pence, dollar, etc. -->
		                                                    <xsl:for-each-group select="current-group()" group-by="s:Unit">
		                                                        <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/><br/>
		                                                    </xsl:for-each-group>
		                                                </xsl:when>
		                                                <xsl:when test="$Measurable_type = 'Service'">
		                                                    <xsl:for-each-group select="current-group()" group-by="s:Unit">
		                                                        <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/><br/>
		                                                    </xsl:for-each-group>
		                                                </xsl:when>
		                                                <xsl:when test="$Measurable_type = 'Commodity'">
		                                                    <!-- as commodity is always something different (powder, knife) -->
		                                                    <xsl:for-each-group select="current-group()" group-by="s:Commodity">
		                                                        <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/><br/>
		                                                    </xsl:for-each-group>
		                                                </xsl:when>
		                                                <xsl:otherwise>nope</xsl:otherwise>
		                                            </xsl:choose>
		                                           <!-- <xsl:value-of select="$Measurable"/><xsl:text> </xsl:text>-->
		                                        </td>
		                                        <td>
		                                            <a href="{concat('/', $TEI)}" target="_blank" title="To the data source">SOURCE</a>
		                                        </td>
		                                    </tr>
		                                  <!--</xsl:for-each>-->
		                                </xsl:for-each-group>
		                            </tbody>
		                        </table>
	                    	 </xsl:for-each-group>
	                    </div>
	                        
                        <!-- //////////////////////////////////////// -->
                        <!-- MEASURABLES -->
                        <!-- //////////////////////////////////////// -->
                		<div class="col-md-12" id="Measurables">
                            <div class="card">
	                            <h2 class="card-title">
	                                Measurables
	                            </h2>
                                <h3>Commodities</h3>
                                <ul>
                                    <xsl:for-each select="distinct-values(//s:results/s:result/s:Commodity)">
                                        <li>
                                            <xsl:value-of select="."/>
                                        </li>
                                    </xsl:for-each>
                                </ul>

                                <h3>Services</h3>
                            </div>
	                    </div> 
                		
	                    <!-- //////////////////////////////////////// -->
	                    <!-- VISUALISATION -->
	                    <!-- //////////////////////////////////////// -->
	                    <div class="col-md-12" id="Visualisation">
	                        <div class="card">
	                            <h3 class="card-title">
	                                Visualisation
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
	    							<!-- ///////////////////////////////////// -->
	                            	<div id="barchart">
	                            		<xsl:call-template name="getBarChart"/>
	                            	</div>
			                    </div>
		                     </div>
	                    </div>
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
         </div>
      </div>
    </div>
    </xsl:template>
	
	<!-- ///////////////////////////////////// -->
    <!--  Bar Chart https://bl.ocks.org/mbostock/3885304 -->
    <!-- ///////////////////////////////////// -->
	<xsl:template name="getBarChart">
		<svg width="900" height="700"><xsl:text> </xsl:text></svg>
		<script> 
		    // The new data variable.
		    
		    var data = [
		    <!-- select all results, group them by YYYY-valid entries -->
		    <xsl:for-each-group select="//s:results/s:result[s:When castable as xs:date]" group-by="year-from-date(s:When)">
		        <xsl:sort select="current-grouping-key()"/>
		        
		        <xsl:variable name="Sum">
		            <xsl:choose>
		                <!-- WASHINGTON punds, shilling, pence-->
		                <xsl:when test="contains(//s:result[1]/s:query,'context:medea.wfp')">
		                    <xsl:value-of select="round((sum(current-group()/s:Quantity[../s:Unit = 'Pounds'][distinct-values(../s:Transfer/@uri)])) + (sum(current-group()/s:Quantity[../s:Unit = 'Shillings'][distinct-values(../s:Transfer/@uri)]) div / 10)) + (sum(current-group()/s:Quantity[../s:Unit = 'Pence'][distinct-values(../s:Transfer/@uri)]) div / 100)"/>
		                </xsl:when>
		                <!-- WHEATON dollar, cent -->
		                <xsl:when test="contains(//s:result[1]/s:query,'context:medea.wheaton')">
		                    <xsl:value-of select="round((sum(current-group()/s:Quantity[../s:Unit = 'dollars'][distinct-values(../s:Transfer/@uri)])) + (sum(current-group()/s:Quantity[../s:Unit = 'cents'][distinct-values(../s:Transfer/@uri)]) div / 100))"/>
		                </xsl:when>
		                <xsl:otherwise>
		                    <xsl:value-of select="1"/>
		                </xsl:otherwise>
		            </xsl:choose>
		        </xsl:variable>
		        <!-- year= x-axis ; amount = y-axis-->
		        {year: "<xsl:value-of select="current-grouping-key()"/>", amount: "<xsl:value-of select="$Sum"/>"}, 
		    </xsl:for-each-group>
			
		    ];
		    var svg = d3.select("svg"),
		    margin = {top: 20, right: 20, bottom: 30, left: 40},
		    width = +svg.attr("width") - margin.left - margin.right,
		    height = +svg.attr("height") - margin.top - margin.bottom;
		    
		    var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
		    y = d3.scaleLinear().rangeRound([height, 0]);
		    
		    var g = svg.append("g")
		    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
		    
		    // The following code was contained in the callback function.
		    x.domain(data.map(function(d) { return d.year; }));
		    y.domain([0, d3.max(data, function(d) { return parseFloat(d.amount); })]);
		    
		    g.append("g")
		    .attr("class", "axis axis--x")
		    .attr("transform", "translate(0," + height + ")")
		    .call(d3.axisBottom(x));
		    
		    g.append("g")
		    .attr("class", "axis axis--y")
		    .call(d3.axisLeft(y))
		    .append("text")
		    
		    g.selectAll(".bar")
		    .data(data)
		    .enter().append("rect")
		    .attr("class", "bar")
		    .attr("x", function(d) { return x(d.year); })
		    .attr("y", function(d) { return y(d.amount); })
		    .attr("width", x.bandwidth())
		    .attr("height", function(d) { return height - y(d.amount); });
		</script>
	</xsl:template>
	
</xsl:stylesheet>

