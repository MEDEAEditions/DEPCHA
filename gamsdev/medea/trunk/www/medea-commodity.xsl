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
  
       
     <div class="row">
    
        <div class="col-md-12">
            <div class="card">
                <!-- HEADER -->
                <!-- ///////////////////////////////////// -->
                <div class="card-header"> 
	               <h1 class="card-title">Index of Commodities</h1>
                    <div class="card-text">
                        <p>Here can be a nice Text!</p>
                    </div>
                </div>
                <!-- BODY -->
                <!-- ///////////////////////////////////// -->
            
                <div class="card-body">
                    <!-- LIST -->
                 <ul class="list-group">
                     <xsl:for-each-group select="//s:results/s:result" group-by="s:Commodity">
                      <xsl:sort select="count(current-group())" order="descending"></xsl:sort>
                     	<li class="list-group-item justify-content-between">
                      <a href="{concat('/archive/objects/query:medea.index/methods/sdef:Query/get?params=$1|', current-grouping-key())}"> 
                       
                         <xsl:value-of select="current-grouping-key()"/><xsl:text> </xsl:text><span class="badge badge-secondary badge-pill"><xsl:value-of select="count(current-group())"/></span>
                       
                      </a>
                     		<xsl:text> </xsl:text>
                      <a href="{s:seeAlso/@uri}" target="_blank" title="To the dpbedia entry"><img src="https://upload.wikimedia.org/wikipedia/commons/7/73/DBpediaLogo.svg" height="40" width="40"></img></a>
                     	</li>
                     	<!--  -->
                     	
                     </xsl:for-each-group>
                 </ul>
                </div>
         </div>
      </div>
    </div>
    </xsl:template>

</xsl:stylesheet>

