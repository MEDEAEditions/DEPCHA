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
        <section class="row equalheight">
            <article class="col-md-12 col-sm-12 panel"> 
                <div class="page-header">
                    <h3>Analysis of <xsl:value-of select="substring-after(//s:results/s:result[1]/s:entry/@uri, 'uni-graz.at/')"/></h3>
                </div>  
                <div class="col-md-12 col-sm-12 panel">  
                    
                   <!-- <xsl:for-each-group select="//s:results/s:result" group-by="year-from-date(s:date)">
                        <xsl:sort select="current-grouping-key()"/>
                        <xsl:variable name="Pfund" select="sum(current-group()[s:unit/@uri = 'https://glossa.uni-graz.at/#lb']/s:quantity)"/>
                        <xsl:variable name="Schilling" select="sum(current-group()[s:unit/@uri = 'https://glossa.uni-graz.at/#ß-w']/s:quantity)"/>
                        <xsl:variable name="Pfennig" select="sum(current-group()[s:unit/@uri = 'https://glossa.uni-graz.at/#d']/s:quantity)"/>
                        <xsl:variable name="Sum_Pfennig_Year" select="$Pfund * 240 + $Schilling * 20 + $Pfennig"/>
                        <xsl:value-of select="$Sum_Pfennig_Year"/><xsl:text> </xsl:text>
                        
                        
                    </xsl:for-each-group>-->
                    
                    
                    <style>
                        .bar {
                        fill: steelblue;
                        }
                        .bar:hover {
                        fill: brown;
                        }
                        .axis--x path {
                        display: none;
                        }
                    </style>
                    <!--  Bar Chart https://bl.ocks.org/mbostock/3885304
                        s:results/s:result are put into this .tsv data foramt for further representation in the chart -->
                    <svg width="800" height="400"></svg>
                    <script> 
                        
                        // The new data variable.
                        var data = [
                        <xsl:for-each-group select="//s:results/s:result" group-by="year-from-date(s:date)">
                            <xsl:sort select="current-grouping-key()"/>
                            <!-- check allowed units in sparql medea-accounts.sparql -->
                            <!-- Dollar -->
                            <xsl:variable name="Dollar" select="sum(current-group()[s:unit[@uri ='https://glossa.uni-graz.at/#dollars']]/s:quantity)"/>
                            <xsl:variable name="Cent" select="sum(current-group()[s:unit[@uri ='https://glossa.uni-graz.at/#cents']]/s:quantity)"/>
                            <!-- PFUND -->
                             <xsl:variable name="Pfund" select="sum(current-group()[s:unit[@uri ='https://glossa.uni-graz.at/#lb']]/s:quantity)"/>
                             <xsl:variable name="Schilling" select="sum(current-group()[s:unit[@uri ='https://glossa.uni-graz.at/#ß-w']]/s:quantity)"/>
                             <xsl:variable name="Pfennig" select="sum(current-group()[s:unit[@uri ='https://glossa.uni-graz.at/#d']]/s:quantity)"/>


                             <!-- im vergleich mit srbas konten stimmen dei Zahlen fast, passt was noch nicht ind er umrechnung -->
                             <xsl:variable name="Summe">
                                 <xsl:choose>
                                     <xsl:when test="current-group()/s:unit/@uri = 'https://glossa.uni-graz.at/#lb'">
                                         <xsl:value-of select="$Pfund * 240 + $Schilling * 30 + $Pfennig"/>
                                     </xsl:when>
                                     <xsl:when test="current-group()/s:unit/@uri = 'https://glossa.uni-graz.at/#dollars'">
                                         <xsl:value-of select="$Dollar * 100 + $Cent"/>
                                     </xsl:when>
                                     <!-- return 0 if no defined currency -->
                                     <xsl:otherwise>0</xsl:otherwise>
                                 </xsl:choose>
                             </xsl:variable>
                            <!-- year= x-axis ; amount = y-axis-->
                            {year: "<xsl:value-of select="current-grouping-key()"/>", amount: "<xsl:value-of select="$Summe"/>"},
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
                        
                        <!--       d3.tsv(data, function(d) {
                d.amount = +d.amount;
                return d;
                }, function(error, data) {
                if (error) throw error;-->
                        
                        // The following code was contained in the callback function.
                        x.domain(data.map(function(d) { return d.year; }));
                        y.domain([0, d3.max(data, function(d) { return d.amount; })]);
                        
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
                        <!--  } );-->
                        
                        
                    </script>
                </div>
            </article>
        </section> 
    </xsl:template>    
</xsl:stylesheet>

