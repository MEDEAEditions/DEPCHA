<?xml version="1.0" encoding="UTF-8"?>
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
<!--    <xsl:variable name="ResultsResult" select="//s:results/s:result"/>-->
    <xsl:variable name="FirstResult" select="//s:results/s:result[1]"/>
    <xsl:variable name="FirstResult_Query" select="$FirstResult/s:query/string()"/>
    <xsl:variable name="collection-uri" select="concat('&lt;',$FirstResult_Query, '&gt;')"/>
    <xsl:variable name="getJSON" select="concat('/archive/objects/query:depcha.bycommodity/methods/sdef:Query/getJSON?params=$1%7C', $collection-uri)"/>
    <xsl:variable name="server">https://gams.uni-graz.at</xsl:variable>
    <!--    <xsl:variable name="getJSON" select="concat('/archive/objects/query:depcha.bycommodity/methods/sdef:Query/getJSON?params=%241%7C', encode-for-uri('&lt;https://gams.uni-graz.at/context/depcha.wheaton&gt;'))"/>-->
<!--    <xsl:variable name="getJSON"><xsl:text>file:/Z:/Documents/uni/HistInf/Rechnungen/Mellon2017/Chicago2019/commodities.json</xsl:text></xsl:variable>-->
    
    <xsl:include href="/depcha/www/depcha-static.xsl"/>
    <xsl:template name="content">
        <!-- ///////////////////////////////////////////////////////////// -->
        <!-- CONTENT-->
        <div class="card">
            <div class="card-header"> 
            <h1 class="card-title">
                <xsl:text>Statistics of Commodities: </xsl:text><xsl:value-of select="substring-after($FirstResult_Query, '/context:depcha.')"/>
<!--                <xsl:choose>
                    <xsl:when test="contains($FirstResult_Query, '#')">
                        <xsl:text>Accounts SEARCH: </xsl:text><xsl:value-of select="$FirstResult/s:From_name"/>
                    </xsl:when>
                    <xsl:when test="contains($FirstResult_Query, 'context:depcha')">
                        <xsl:value-of select="$FirstResult/s:Collection_name"/>
                    </xsl:when>
                    <xsl:when test="contains($FirstResult_Query, 'o:depcha')">
                        <xsl:text>TEI SOURCE: </xsl:text>
                        <xsl:value-of select="document(concat((substring-before(substring-after($FirstResult_Query, '&lt;'), '&gt;')), '/TEI_SOURCE'))//t:titleStmt/t:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>SEARCH: </xsl:text><mark><xsl:value-of select="$FirstResult_Query"/></mark>
                        <br/>
                        <xsl:text>SEARCHRESULT: </xsl:text><xsl:value-of select="count(distinct-values($ResultsResult/s:Transfer/@uri))"/>
                    </xsl:otherwise>
                </xsl:choose>-->
            </h1>
        </div>
            <xsl:call-template name="getBubbleChart"/>
        </div>
    </xsl:template>
    <xsl:template name="getBubbleChart">
        <!-- //////////////////////////////////////// -->
        <!-- MEASURABLES BUBBLE CHART -->
        <div class="col-md-12" id="Measurables">
            <div class="card">
                <h3 class="card-title">Commodities and Services: Number of Entries</h3>
                        <div id="bubble">
                            <script>
                                <!-- data is stored as json for d3.js -->
                                var data = {
                                "name": "Measurables",
                                "children":
                                <xsl:value-of select="unparsed-text(concat('/archive/objects/query:depcha.bycommodity/methods/sdef:Query/getJSON?params=%241%7C%3C',encode-for-uri($FirstResult_Query),'%3E'))"/>
                                <!--[<xsl:for-each-group select="$ResultsResult" group-by="s:Commodity">
                                    {"name": "<xsl:value-of select="s:Commodity"/>","children": 
                                    [{"name": "<xsl:value-of select="s:Commodity"/>","size": <xsl:value-of select="count(current-group())"/>}]               
                                    }
                                    <xsl:if test="not(position()=last())">
                                        <xsl:text>,</xsl:text>
                                    </xsl:if>
                                </xsl:for-each-group> ]-->
                                };
                                
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
            </div>
        </div> 
    </xsl:template>
    <xsl:template match="*"/>
</xsl:stylesheet>