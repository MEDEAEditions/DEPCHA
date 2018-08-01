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
        
        
        <section class="row equalheight">
            <article class="col-md-12 col-sm-12 panel"> 
                <div class="page-header">
                    <h3>Register of Parties and Accounts</h3>
                </div>  
                <article class="row">	
                    <!-- /// NAVIGATION /// -->
                    <div class="col-md-12">
                        <div class="list-group">
                            <xsl:for-each-group select="//s:result" group-by="s:Between/@uri">
                                <xsl:sort select="s:name"></xsl:sort>
                                <xsl:if test="not(s:name = '')">
                                    <a href="{current-grouping-key()}" class="list-group-item">
                                        <h5 class="bk_head_register"><xsl:value-of select="s:name"/></h5>
                           
                                    </a>
                                </xsl:if>
                            </xsl:for-each-group>
                        </div>
                     
                    </div>
                </article>
            </article>
        </section>
        
        
    </xsl:template>
    
    
    
</xsl:stylesheet>