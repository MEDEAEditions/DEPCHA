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
    
    
    <xsl:include href="depcha-static.xsl"/>
    
	<xsl:template name="content">
	 
	 <!-- //////////////////////////////////////////////// -->
	    <!-- select index: commodity or accounts -->
     <xsl:choose>
         <xsl:when test="//s:results/s:result[1]/s:Commodity">
             <xsl:call-template name="getCommodities"/>
         </xsl:when>
         <xsl:when test="//s:results/s:result[1]/s:From | //s:results/s:result[1]/s:To ">
             <xsl:call-template name="getAccounts"/>
         </xsl:when>
         <xsl:otherwise><xsl:comment>Error in depcha-ondex.xsl: index not available</xsl:comment></xsl:otherwise>
     </xsl:choose>
	</xsl:template>
    
    <!-- //////////////////////////////////////////////// -->
    <!-- INDEX COMMODITIES -->
    <xsl:template name="getCommodities">
        <section class="col-sm-12">
            <article class="card">
                    <!-- HEADER -->
                    <!-- ///////////////////////////////////// -->
                    <div class="card-header"> 
                        <h1 class="card-title">Index of Commodities</h1>
                        <div class="card-text">
                            <p> </p>
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
                                    <xsl:variable name="PARAM" select="encode-for-uri(concat('$1|', current-grouping-key()))"/>
                                    <a href="{concat('/archive/objects/query:depcha.index-commodity/methods/sdef:Query/get?params=', $PARAM)}"> 
                                        <xsl:value-of select="current-grouping-key()"/><xsl:text> </xsl:text><span class="badge badge-secondary badge-pill"><xsl:value-of select="count(current-group())"/></span>
                                    </a>
                                    <xsl:text> </xsl:text>
                                    <a href="{s:seeAlso/@uri}" target="_blank" title="To the dpbedia entry"><img src="https://upload.wikimedia.org/wikipedia/commons/7/73/DBpediaLogo.svg" height="40" width="40"></img></a>
                                </li>
                            </xsl:for-each-group>
                        </ul>
                    </div>
            </article>
        </section>
    </xsl:template>
    
    <!-- //////////////////////////////////////////////// -->
    <!-- INDEX ACCOUNTS -->
    <xsl:template name="getAccounts">
            <section class="col-sm-12">
                <article class="card">
                    <!-- HEADER -->
                    <!-- ///////////////////////////////////// -->
                    <div class="card-header"> 
                        <h1 class="card-title">Index of Accounts</h1>
                        <div class="card-text">
                            <p>Here can be a nice Text!</p>
                    </div>
                    </div>
                    <!-- BODY -->
                    <!-- ///////////////////////////////////// -->
                    <div class="card-body">
                        <!-- LIST -->
                        <xsl:for-each-group select="//s:results/s:result" group-by="s:Collection/@uri">
                            <xsl:sort select="substring-after(current-grouping-key(), 'uni-graz.at/')"/>
                            <!-- CONTEXT -->
                            <xsl:variable name="Context">
                                <xsl:choose>
                                    <xsl:when test="contains(current-grouping-key(), 'context:depcha')">
                                        <xsl:value-of select="substring-after(current-grouping-key(), 'uni-graz.at/')"/>
                                    </xsl:when>
                                    <xsl:otherwise><xsl:comment>error</xsl:comment></xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                          
                            <!-- CONTEXTTITLE -->
                            <xsl:variable name="ContextTitle">
                                <xsl:choose>
                                    <xsl:when test="contains($Context, 'context:depcha')">
                                        <xsl:value-of select="document(concat('/archive/objects/', $Context, '/methods/sdef:Object/getMetadata'))//s:results/s:result[1]/s:container"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$Context"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <h3>
                                <xsl:value-of select="$ContextTitle"/>
                            </h3>
                              <ul class="list-group">
                                  <xsl:for-each-group select="current-group()" group-by="s:From/@uri">
                                      <xsl:sort select="count(distinct-values(current-group()/s:Transfer/@uri))" order="descending"/>
                                      <xsl:variable name="PARAM" select="encode-for-uri(concat('$1|&lt;', normalize-space(current-grouping-key()), '&gt;'))"/>
                                      <li class="list-group-item justify-content-between">
                                          <a href="{concat('/archive/objects/query:depcha.index-accounts/methods/sdef:Query/get?params=', $PARAM)}"> 
                                              <xsl:value-of select="s:From_name[1]"/><xsl:text> </xsl:text><span class="badge badge-secondary badge-pill"><xsl:value-of select="count(distinct-values(current-group()/s:Transfer/@uri))"/></span>
                                          </a>
                                          <xsl:text> </xsl:text>
                                       
                                      </li>
                                  </xsl:for-each-group>
                              </ul>
                        </xsl:for-each-group>
                    </div>
                </article>
            </section>
    </xsl:template>
</xsl:stylesheet>
