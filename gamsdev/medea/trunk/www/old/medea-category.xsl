<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Project: GAMS Projekttemplate
    Company: ZIM-ACDH (Zentrum fÃ¼r Informationsmodellierung - Austrian Centre for Digital Humanities)
 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
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
                <div class="page-header text-center">
                    <h1>Category</h1>
                </div>
                <div class="col-md-6">
                    <p>
                        <xsl:text> </xsl:text>
                    </p>
                </div>
                <div class="col-md-6">
                    <xsl:text> </xsl:text>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="list-group">
                            <xsl:for-each-group select="//s:results/s:result" group-by="year-from-date(s:when)">
                                <xsl:sort select="current-grouping-key()"/>
                            	<h4><xsl:value-of select="current-grouping-key()"/></h4>
                            	<xsl:for-each-group select="current-group()" group-by="s:category/@uri">
                                <xsl:variable name="AccountQuery" 
                                    select="concat('https://glossa.uni-graz.at/archive/objects/query:medea.analyseAccount/methods/sdef:Query/get?params=$1|', concat('&lt;',replace(current-grouping-key(), '#', '%23'), '&gt;'))"/>
                                <a href="{$AccountQuery}" class="list-group-item">
                                    <xsl:value-of select="current-grouping-key()"/>
                                </a>
                            		</xsl:for-each-group>
                            </xsl:for-each-group>
                        </div>
                    </div>
                </div>
            </article>
        </section> 
    </xsl:template>    
</xsl:stylesheet>