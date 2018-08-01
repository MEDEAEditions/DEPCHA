<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Project: GAMS Projekttemplate
    Company: ZIM-ACDH (Zentrum fÃ¼r Informationsmodellierung - Austrian Centre for Digital Humanities)
 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all">
    
    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>
    
    
    <xsl:include href="medea-static.xsl"/>
    
    <xsl:template name="content">
          <nav class="navbar navbar-default navbar-lower" role="navigation" style="margin-bottom: 0px; background-color: #e8e8e8;">
  				  				<div class="container"  style="margin-top: 5px;">
                	<div class="panel" style="margin-bottom: 0px;">
  						<div class="row">
  						<ul class="list-group list-group-horizontal">
  							<li class="list-group-item">Query: <xsl:value-of select="//s:results/s:result[1]/s:query"/></li>
  							<li class="list-group-item">Results: <xsl:value-of select="count(distinct-values(//s:results/s:result/s:entry/@uri))"/></li>
  						</ul>
                		<!-- ///Navigation of author or title //-->
  						</div>
  					<div class="testimonial-group">
  					<div class="row text-center">
                		<xsl:for-each-group select="//s:results/s:result" group-by="substring-before(s:entry/@uri, '#')">
                			<xsl:sort select="current-grouping-key()"/>
                			<!-- gets title of TEI-File -->
                			<xsl:variable name="TEI_Title" select="document(concat(current-grouping-key(), '/TEI_SOURCE'))//*:titleStmt/*:title"/>
                			
                			<div class="col-xs-3">
                				
                			<a  href="{concat('#',translate($TEI_Title, ' ', ''))}" onclick="scrolldown(this)" data-toggle="tooltip" title="{concat('Go to ', $TEI_Title)}">
                				<xsl:value-of select="$TEI_Title"/>
                			</a>
                			</div>
                		</xsl:for-each-group>
                		</div>
  								</div>
  						<!-- 
                               <div class="col-md-3 col-sm-3 sidebar-outer hidden-xs">
                                   <div class="list-group">
                                       <xsl:for-each-group select="//s:result" group-by="s:entry/@uri">
                                           <a href="{concat( '#', substring-after(current-grouping-key(), '#'))}" class="list-group-item" onclick="scrolldown(this)" id="{concat( '#', substring-after(current-grouping-key(), '#'))}">
                                               <xsl:text>"</xsl:text><i><xsl:value-of select="substring(s:text/text(),1,40)"/></i><xsl:text>" ... </xsl:text>
                                           </a>
                                       </xsl:for-each-group>
                                   </div>
                               </div> -->
  						
  						
                	</div>
  				</div>
			</nav>
            <script>$('.navbar-lower').affix({offset: {top: 70}});</script>

        <section>
                <article class="col-md-12 col-sm-12 panel"> 
                    <xsl:choose>
                    	<!-- if there is a searchresult -->
                        <xsl:when test="//s:results/s:result[1]">	
                           <!-- /// PAGE-CONTENT /// -->
                        	
                        	
                        	
                           <div class="col-md-12 col-sm-12">
                               <!-- group by objects -->
                               <xsl:for-each-group select="//s:results/s:result" group-by="substring-before(s:entry/@uri, '#')">
                                   <xsl:sort select="current-grouping-key()"></xsl:sort>
	                               <!-- gets title of TEI-File -->
	                               <xsl:variable name="TEI_Title" select="document(concat(current-grouping-key(), '/TEI_SOURCE'))//*:titleStmt/*:title"/>
	                               <table class="table table-bordered table-hover">
	                                   <thead>
	                                       <tr>
	                                       		<h2 id="{translate($TEI_Title, ' ', '')}" style="padding:15px;">
	                                       			<a href="{current-grouping-key()}" target="_blank">
	                                       				<xsl:value-of select="$TEI_Title"/>
	                                       			</a>
	                                       		</h2>
	                                       </tr>
	                                   </thead>
	                                   <tbody>
	                                       <xsl:for-each select="current-group()">
	                                           <xsl:sort select="s:text"></xsl:sort>
	                                           <tr>
	                                               <td class="col-md-4">
	                                                   <a href="{s:entry/@uri}"><xsl:value-of select="substring(s:text/text(),1,30)"/><xsl:text> </xsl:text><xsl:text> ... </xsl:text></a>
	                                               </td>
	                                               <td class="col-md-3">
	                                                   <!-- TODO: Normalized form in RDF of names -->
	                                                   <xsl:value-of select="substring-after(s:from/@uri, '-Between-')"/>
	                                                   <xsl:text> </xsl:text><span class="glyphicon glyphicon-arrow-right"><xsl:text> </xsl:text></span><xsl:text> </xsl:text>
	                                                   <xsl:value-of select="substring-after(s:to/@uri, '-Between-')"/>
	                                               </td>
	                                               <td class="col-md-1">
	                                                   <xsl:value-of select="s:quantity"/>
	                                               	   <xsl:text> </xsl:text>
	                                               </td>
	                                               <td class="col-md-1">
	                                                   <xsl:value-of select="substring-after(s:unit/@uri, 'https://gams.uni-graz.at/#')"/>
	                                               	   <xsl:text> </xsl:text>
	                                               </td>
	                                               <td class="col-md-2">
	                                                   <xsl:value-of select="s:date"/>
	                                               	   <xsl:text> </xsl:text>
	                                               </td>
	                                               <td class="col-md-1">
	                                               	<xsl:text> </xsl:text>
	                                                   <label class="pull-right"><input onclick="" type="checkbox" class=""/><xsl:text> </xsl:text></label>
	                                               </td>
	                                           </tr>
	                                       </xsl:for-each>
	                                   	
	                                   	
	                                   		<xsl:variable name="Summa" select="sum(.//s:quantity)"/>
	                                   	
	                                   	   <tr>
		                                       <td class="col-md-12">
		                                           <xsl:text> </xsl:text>
		                                       </td>
	                                   	   </tr>
	                                   	   <tr>
	                                               <td class="col-md-4">
	                                                   <xsl:text>Summa</xsl:text>
	                                               </td>
	                                               <td class="col-md-3">
	                                                  <xsl:text> </xsl:text>
	                                               </td>
	                                               <td class="col-md-2">
	                                                  <b><xsl:value-of select="$Summa"/></b>
	                                               </td>
	                                   	   		   <td class="col-md-2">
	                                                  <b><xsl:text>unit</xsl:text></b>
	                                               </td>
	                                               <td class="col-md-2">
	                                                   <xsl:text> </xsl:text>
	                                               </td>
	                                               <td class="col-md-1">
	                                               	<xsl:text> </xsl:text>
	                                               </td>
	                                           </tr>
	                                   </tbody>
	                               </table>
                               	
                               	
                               	
                               </xsl:for-each-group>

                           </div>
                        
                       </xsl:when>
                        <xsl:otherwise>
                            <div class="row">	
                                <!-- /// NAVIGATION /// -->
                                <div class="col-md-3 col-sm-3 sidebar-outer hidden-xs">
                                    <div class="list-group">
                                        Lorem
                                    </div>
                                </div>
                                
                                <!-- /// PAGE-CONTENT /// -->
                                <div class="col-md-9 col-sm-9">
                                    No search results, sry. :(
                                </div>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
            </article>
        </section>
        
        
    </xsl:template>
    
    
    
</xsl:stylesheet>