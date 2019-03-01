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
                    <h3>Suchergebnisse</h3>
                </div>  
                    <article class="row">	
                        <!-- /// NAVIGATION /// -->
                        <div class="col-md-3 col-sm-3 sidebar-outer hidden-xs">
                            <div class="list-group">
                                <xsl:for-each-group select="//s:result" group-by="s:entry/@uri">
                                    <a href="{concat( '#', substring-after(current-grouping-key(), '#'))}" class="list-group-item" onclick="scrolldown(this)" id="{concat( '#', substring-after(current-grouping-key(), '#'))}">
                                        <xsl:text>"</xsl:text><i><xsl:value-of select="substring(s:text/text(),1,40)"/></i><xsl:text>" ... </xsl:text>
                                    </a>
                                </xsl:for-each-group>
                            </div>
                        </div>
                        
                        <!-- /// PAGE-CONTENT /// -->
                        <div class="col-md-9 col-sm-9">
                            <!-- group by objects -->
                            <xsl:for-each-group select="//s:results/s:result" group-by="substring-before(s:entry/@uri, '#')">
                                <xsl:sort select="current-grouping-key()"></xsl:sort>
                                <table class="table table-bordered table-hover">
                                    <thead>
                                        <tr><h2><xsl:value-of select="current-grouping-key()"/></h2></tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="current-group()">
                                            <xsl:sort select="s:text"></xsl:sort>
                                            <tr>
                                                <td class="col-md-4">
                                                    <a href="{s:entry/@uri}"><xsl:value-of select="substring(s:text/text(),1,30)"/><xsl:text> </xsl:text><xsl:text> ... </xsl:text></a>
                                                </td>
                                                <xsl:variable name="FromSpreadsheet" select="'todo'"/>
                                                <xsl:variable name="ToSpreadsheet" select="'todo'"/>
                                                <td class="col-md-3">
                                                    <xsl:value-of select="$FromSpreadsheet"/>
                                                    <xsl:text> </xsl:text><span class="glyphicon glyphicon-arrow-right"><xsl:text> </xsl:text></span><xsl:text> </xsl:text>
                                                    <xsl:value-of select="$ToSpreadsheet"/>
                                                </td>
                                                <td class="col-md-2">
                                                   what
                                                </td>
                                                <td class="col-md-2">
                                                    comment
                                                </td>
                                                <td class="col-md-1">
                                                    <label class="pull-right"><input onclick="" type="checkbox" class=""/><xsl:text> </xsl:text></label>
                                                </td>
                                            </tr>
                                            
                                            
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                                
                                
                            </xsl:for-each-group>
                            
                            
                            <!--<table class="table">
                                <tbody>
                                    <tr>
                                        <!-\- <xsl:for-each select=".//.[tokenize(@ana, ' ') = '#bk_amount']">-\->
                                        <xsl:variable name="FromSpreadsheet">
                                            <xsl:choose>
                                                <xsl:when test="@ref">
                                                    <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_from']/@ref"/>
                                                </xsl:when>
                                                <xsl:when test="@corresp">
                                                    <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_from']/@corresp"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_from']"/>
                                                </xsl:otherwise>
                                            </xsl:choose> 
                                        </xsl:variable>
                                        
                                        <xsl:variable name="ToSpreadsheet">
                                            <xsl:choose>
                                                <xsl:when test="@ref">
                                                    <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_to']/@ref"/>
                                                </xsl:when>
                                                <xsl:when test="@corresp">
                                                    <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_to']/@corresp"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_to']"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        
                                        
                                        <td class="col-md-4">
                                            <xsl:value-of select="$FromSpreadsheet"/>
                                            <xsl:text> </xsl:text><span class="glyphicon glyphicon-arrow-right"><xsl:text> </xsl:text></span><xsl:text> </xsl:text>
                                            <xsl:value-of select="$ToSpreadsheet"/>
                                        </td>
                                        <td class="col-md-2">
                                            <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_amount']//@quantity"/><xsl:text> </xsl:text>                       
                                        </td>
                                        <td class="col-md-2"> 
                                            <xsl:value-of select=".//.[tokenize(@ana, ' ') = '#bk_amount']//@unit"/><xsl:text> </xsl:text>  
                                        </td>
                                        <td class="col-md-2"> 
                                            <label class="pull-right"><input onclick="" type="checkbox" class=""/><xsl:text> </xsl:text></label>
                                        </td>
                                        
                                        <!-\-</xsl:for-each>-\-> 
                                    </tr>
                                    
                                   <!-\- <xsl:if test="position() = last()">
                                        <tr>
                                            <td class="col-md-2">
                                                <b>SUMME</b><xsl:text> </xsl:text>                     
                                            </td>
                                            <td class="col-md-2">
                                                <xsl:sequence select="sum(.//@quantity/number(translate(., ',', '.')))"/>     
                                            </td>
                                            <td class="col-md-2">
                                                <xsl:text> </xsl:text>                       
                                            </td>
                                        </tr>
                                    </xsl:if>-\->
                                    
                                </tbody>
                            </table>-->
                            
                            
                            
                            
                            
                         <!--    
                        <div class="list-group">
                            <xsl:for-each-group select="//s:result" group-by="s:entry/@uri">     
                                <a href="{current-grouping-key()}" class="list-group-item list-group-item-action flex-column align-items-start" onclick="scrolldown(this)" id="{substring-after(current-grouping-key(), '#')}">
                                    <div class="d-flex w-100 justify-content-between">
                                        <h4 class="mb-1"> <xsl:text>"</xsl:text><i><xsl:value-of select="substring(s:text/text(),1,40)"/></i><xsl:text>" ... </xsl:text><br/></h4>
                                    </div>
                                   <table class="table">
                                        <thead>
                                            <tr>
                                                <th>Date</th>
                                                <th>To</th>
                                                <th>Measurable</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td class="col-md-4">
                                                    <xsl:choose>
                                                        <xsl:when test="s:date">
                                                            <xsl:value-of select="s:date"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text> </xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                                <td class="col-md-4">
                                                    <xsl:choose>
                                                        <xsl:when test="s:Between">
                                                            <xsl:value-of select="s:Between"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text> </xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                                <td class="col-md-4">
                                                    <xsl:choose>
                                                        <xsl:when test="s:quantity">
                                                            <xsl:value-of select="s:quantity"/>
                                                            <xsl:text> </xsl:text><xsl:value-of select="substring-after(s:unit, 'http://glossa.uni-graz.at/#')"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <xsl:text> </xsl:text>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </a> 
                            </xsl:for-each-group>
                       </div>-->
                        </div>
                </article>
            </article>
        </section>
        
        
    </xsl:template>
    
    
    
</xsl:stylesheet>