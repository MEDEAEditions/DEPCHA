<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Project: MEDEA
    Company: ZIM-ACDH (Zentrum fÃ¼r Informationsmodellierung - Austrian Centre for Digital Humanities)
    Author: Christopher Pollin 
    Last update: 2017
 -->



<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all">
     
    <xsl:strip-space elements="*"/>
    <xsl:include href="medea-static.xsl"/>
    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>
    
    <!-- VARIABLES -->   
    <!-- //////////////////////////////// -->
    <!-- global Variables are defined in medea-templates.xsl -->
    <xsl:variable name="TEI_HEADER" select="t:TEI/t:teiHeader"/>
   
    <xsl:template name="content">
        <!-- /// PAGE-CONTENT /// -->
        
        <section class="row equalheight">
            <!-- ///NAVIGATION/// -->
            <!--<article class="col-md-2 panel equal hidden-sm hidden-xs">
                    <div class="navigation">
                        <h3>Navigation</h3>
                        <div class="pre-scrollable">
                        <!-\-<xsl:for-each select="//t:head | t:front">
                            <xsl:sort select="."></xsl:sort>
                            
                            <p class="list-group-item-text">
                                <a  href="{concat('#', 'head-', generate-id())}" class="list-group-item" onclick="scrolldown(this)">
                                  <xsl:value-of select="."/>
                                  <xsl:if test=".//@when">
                                     <xsl:text> - </xsl:text>
                                     <xsl:value-of select=".//@when"/>
                                  </xsl:if>
                                </a>
                            </p>        
                        </xsl:for-each> -\->
                            <xsl:text> </xsl:text>
                        </div>
                    </div>
            </article>-->
            
            <!-- ///CONTENT/// -->
            <div class="col-md-12">
                <div class="card">
                    <!-- HEADER-->
                    <div class="card-header"> 
                        <h1 class="card-title">
                            <xsl:value-of select="$TEI_HEADER/t:fileDesc/t:titleStmt/t:title"/>
                        </h1>
                        <div class="card-text">
                            <p>Here can be a nice Text!</p>
                            <div class="btn-group">
                                <a href="{concat('/archive/objects/query:medea.getdata-tei/methods/sdef:Query/get?params=$1|&lt;https://glossa.uni-graz.at/', //t:idno[@type = 'PID'], '&gt;')}" id="datatable_button" class="btn">
                                    <xsl:text>Datatable</xsl:text>
                                </a>
                                <!-- TEI, RDF etc. button -->
                                <a class="button" href="{concat('/',$teipid,'/TEI_SOURCE')}" role="button" style="margin: 10px;" target="_blank">
                                    <img alt="TEI" height="25" id="tei" src="/templates/img/tei_icon.jpg" title="TEI"/>
                                </a>
                                <a class="button" href="{concat('/',$teipid,'/RDF')}" role="button" style="margin: 10px;" target="_blank">
                                    <img alt="RDF" height="25" id="rdf" src="/templates/img/RDF_icon.png" title="RDF"/>
                                </a>
                                <!--<a class="button" href="{concat('glossa.uni-graz.at/archive/objects/',$teipid, '/methods/sdef:TEI/getLaTeXPDF')}" role="button" style="margin: 10px;">
                                        <img alt="PDF" height="25" id="pdf" src="https://glossa.uni-graz.at/templates/img/pdf_icon.png" title="PDF"/>
                                    </a>-->
                                <!-- HSSF just for Query Results -->
                                <!--<a class="button" href="{concat('/archive/objects/',$teipid,'/methods/sdef:TEI/getHSSF')}" role="button" style="margin: 10px;">
                                    <img alt="RDF" height="25" id="rdf" src="/gamsdev/pollin/medea/trunk/www/img/TABELLENSYMBOL.png" title="HSSF"/>
                                </a> -->                           
                            </div>
                        </div>
                    </div>
                    <div class="card-body" id="source">
                        <xsl:apply-templates select="//t:text"/> 
                    </div>  
                    <div class="card-body" id="datatable">
                        <!--<xsl:apply-templates select="//t:text"/> -->
                    </div> 
                </div>
            </div>
        </section>
    </xsl:template>
    
    
    <!-- HEAD -->
    <xsl:template match="t:head">
        <h3><xsl:apply-templates/></h3>
        <!--<div class="bk_head container row" id="{concat('head-', generate-id())}">
            <xsl:apply-templates/>
        </div>-->
    </xsl:template>
    
    <!-- TABLE -->
    <xsl:template match="t:table">
        <table class="table">
            <xsl:apply-templates/>
        </table>
        <!--<div class="table">
            <xsl:apply-templates/><xsl:text> </xsl:text>
        </div>-->
    </xsl:template>
    
    <xsl:template match="t:row">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    <xsl:template match="t:cell">
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>
    
    
    <xsl:template match="t:text">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="t:front">
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="t:body">
            <xsl:apply-templates/>
    </xsl:template>
   
     
    <!-- pb -->
    <xsl:template match="t:pb">
            <a>
                <xsl:attribute name="href">
                    <xsl:choose>
                        <xsl:when test="@facs">
                            <!-- there is a intern reference in the TEI, @facs starts with # -->
                            <xsl:choose>
                                <xsl:when test="substring(@facs, 1, 1) = '#'">
                                    <!-- go to the element (e.g. t:surface) with the @xml:id and get the @url  -->
                                    <xsl:variable name="IDfromReference" select="substring-after(@facs, '#')"/>
                                    <xsl:value-of select="//.[@xml:id = $IDfromReference]//@url"/>
                                </xsl:when>
                                <!-- otherwise the @facs ist the URL  -->
                                <xsl:otherwise>
                                    <xsl:value-of select="@facs"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="@n">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </a>
    </xsl:template>
    
    <!-- p -->
    <xsl:template match="t:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <!-- DATE -->
    <xsl:template match="t:date">
       <a data-toggle="tooltip">
            <xsl:attribute name="title">
                <xsl:choose>
                    <xsl:when test="@when">
                        <xsl:value-of select="@when"/>
                    </xsl:when>
                    <xsl:when test="@from">
                        <xsl:value-of select="@from"/>
                        <xsl:text> to </xsl:text>
                        <xsl:value-of select="@to"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
    <!-- DEL, ADD etc. -->
    <!-- /////////////////////////////////////// -->
    
    <!-- del -->
    <xsl:template match="t:del">
        <del class="bg-warning" data-toggle="tooltip" title="deletion">
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    
    <!-- damage -->
    <xsl:template match="t:damage">
        <mark class="bg-danger" data-toggle="tooltip" title="damage">
            <xsl:apply-templates/>
        </mark> 
    </xsl:template>
    
    <!-- supplied -->
    <xsl:template match="t:supplied">
        <mark data-toggle="tooltip" title="supplied">
            <xsl:apply-templates/>
        </mark>
    </xsl:template>
    
    <!-- add -->
    <xsl:template match="t:add">
        <mark class="bg-success" data-toggle="tooltip" title="add">
            <xsl:apply-templates/>
        </mark>
    </xsl:template>
    
    <!-- subst -->
    <xsl:template match="t:subst">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- note -->
    <xsl:template match="t:note">
        <xsl:text> </xsl:text>
        <mark class="glyphicon glyphicon-star" data-toggle="tooltip" title="{normalize-space(.)}"><xsl:text> </xsl:text></mark>
    </xsl:template>
     
    <!-- hi --> 
    <xsl:template match="t:hi">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>
    
    <!-- choice -->
    <xsl:template match="t:choice">
        <xsl:text> </xsl:text>
        <a href="#" data-toggle="tooltip" title="{t:expan}">
            <xsl:choose>
                <xsl:when test="t:abbr">
                    <xsl:value-of select="t:abbr"/>
                </xsl:when>
                <xsl:otherwise><xsl:comment>t:abbr missing in choice</xsl:comment></xsl:otherwise>
            </xsl:choose>   
        </a>
        <xsl:text> </xsl:text>
    </xsl:template>
</xsl:stylesheet>