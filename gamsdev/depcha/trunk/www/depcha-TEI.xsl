<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Project: depcha
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
    <xsl:include href="depcha-static.xsl"/>
    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>

    <xsl:template name="content">
        
        <xsl:variable name="cid" select="//t:ref[@type='context']/@target"/>
        
        <!-- ///////////// -->
        <!-- HEADER -->
        <div class="card-header">
            <h1>
                <xsl:text>Edition View: </xsl:text>
                <strong>
                    <xsl:value-of select="$TEI_HEADER/t:fileDesc/t:titleStmt/t:title"/>
                </strong>
            </h1>
        </div>
        <div class="card-body">
            <!-- METADATA ~ teiHeader -->
            <div class="row">
                <div class="col-sm-8">
                    <h3 class="card-title">Metadata</h3>
                    <xsl:call-template name="info_box_tei"/>
                </div>
                <div class="col-sm-2">
                    <h3 class="card-title">View</h3>
                    <a class="btn mt-1 btn-light btn-block" href="#">Data View</a>
                    <a class="btn mt-1 btn-light btn-block" href="#">Text</a>
                    <a class="btn mt-1 btn-light btn-block" href="#">Text-Viewer</a>
                    <a class="btn mt-1 btn-light btn-block" href="#">Viewer</a>                             
                </div>
                <div class="col-sm-2">
                    <h3 class="card-title">Export</h3>
                    <a class="btn mt-1 btn-light btn-block" href="{concat('/',$teipid,'/TEI_SOURCE')}" role="button" title="[Fulltext, Annotation]" target="_blank">
                        <img alt="TEI" height="25" id="tei" src="/templates/img/tei_icon.jpg" title="TEI"/>
                    </a>
                    <a class="btn mt-1 btn-light btn-block" href="{concat('/',$teipid,'/RDF')}" role="button" title="[Bookkeeping-Data]"  target="_blank">
                        <img alt="RDF" height="25" id="rdf" src="/templates/img/RDF_icon.png" title="RDF"/>
                        <br/>
                    </a>
                </div>
            </div>
            <div class="row">
                <div class="col-sm-12">
                    
                    <ul class="list-group list-group-horizontal">
                        <li class="list-group-item list-group-item"><h3>Indicies</h3></li>
                        <xsl:if test="$PERSONS">
                            <a class="list-group-item" href="{concat('/archive/objects/', $teipid, '/methods/sdef:TEI/get?mode=persons')}">
                                Persons
                            </a>
                        </xsl:if>
                        <xsl:if test="$ORGANISATIONS">
                            <a class="list-group-item" href="{concat('/archive/objects/', $teipid, '/methods/sdef:TEI/get?mode=organisations')}">
                                Organisations
                            </a>
                        </xsl:if>
                        <xsl:if test="$PLACES">
                            <a class="list-group-item" href="{concat('/archive/objects/', $teipid, '/methods/sdef:TEI/get?mode=places')}">
                                Places
                            </a>
                        </xsl:if>
                        <!-- Commodities etc. -->
                        <xsl:for-each select="$TAXONOMIES">
                            <a class="list-group-item" href="{concat('/archive/objects/', $teipid, '/methods/sdef:TEI/get?mode=taxonomy')}">
                                <xsl:value-of select="t:gloss[1]"/>
                            </a>
                        </xsl:for-each>
                        <!-- Units Currencies -->
                        <xsl:if test="$UNITS">
                            <a class="list-group-item" href="{concat('/archive/objects/', $teipid, '/methods/sdef:TEI/get?mode=units')}">
                                Units
                            </a>
                        </xsl:if>
                        <xsl:if test="not($PERSONS or $ORGANISATIONS or $PLACES or $TAXONOMIES or $UNITS)">
                            <a class="list-group-item">
                                <xsl:text>not Indicies defined</xsl:text>
                            </a>
                        </xsl:if>
                    </ul>
                </div>
            </div>
        </div>
        
        <!-- ///////////// -->
        <!-- BODY -->
        <div class="card-body" id="source">
            <xsl:choose>
                <!-- INDEX-VIEW -->
                <xsl:when test="$mode = 'persons'">
                    <xsl:apply-templates select="$PERSONS"/>
                </xsl:when>
                <xsl:when test="$mode = 'organisations'">
                    <xsl:apply-templates select="$ORGANISATIONS"/>
                </xsl:when>
                <xsl:when test="$mode = 'places'">
                    <xsl:apply-templates select="$PLACES"/>
                </xsl:when>
                <xsl:when test="$mode = 'units'">
                    <xsl:apply-templates select="$UNITS"/>
                </xsl:when>
                <xsl:when test="$mode = 'taxonomy'">
                    <xsl:apply-templates select="$TAXONOMIES"/>
                </xsl:when>
                <!-- ///////////// -->
                <!-- EDITION-VIEW -->
                <xsl:otherwise>
                    <xsl:apply-templates select="//t:text"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>  
    </xsl:template>
    
    <!-- HEAD -->
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:head">
        <h3><xsl:apply-templates/></h3>
    </xsl:template>
    
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:span[@type='subheading']">
        <tr>
            <td title="{t:date/@when}"><xsl:value-of select="t:date"/></td>
        </tr>
    </xsl:template>
    
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:table">
         <table class="table">
             <xsl:apply-templates/>
         </table>        
    </xsl:template>
    
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:row">
        <tr>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id" select="@xml:id"/>
            </xsl:if>
            <xsl:apply-templates>
                <xsl:with-param name="Cells" select="round(12 div count(t:cell))"/>
            </xsl:apply-templates>
        </tr>
    </xsl:template>
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:cell">
        <xsl:param name="Cells"/>
        <td>
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:text">
        <xsl:apply-templates/>
    </xsl:template>   
    
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:fw">
        <div class="row" title="forme work">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:front">
        <div id="front" class="lead">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:body">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:metamark">
        <xsl:apply-templates/>
        <xsl:choose>
            <xsl:when test="@rend='line'">
                <hr/>
            </xsl:when>
            <!-- ... -->
            <xsl:when test="@rend='dots'">
                <strong>...</strong>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- //////////////////////////////////////////////////////////// -->
    <xsl:template match="t:measure">
        <xsl:variable name="QuantityUnit">
            <xsl:choose>
                <xsl:when test="@quantity and @unit and @commodity">
                    <xsl:value-of select="concat(@quantity, ' ', @unit, ' ', @commodity)"/>
                </xsl:when>
                <xsl:when test="@quantity and @unit">
                    <xsl:value-of select="concat(@quantity, ' ', @unit)"/>
                </xsl:when>
                <xsl:when test="@commodity">
                    <xsl:value-of select="@commodity"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Error: in depcha-TEI t:measure</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text> </xsl:text>
        <abbr class="text-monospace" data-toggle="tooltip" data-html="true" title="{$QuantityUnit}">
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>
    
    <xsl:template match="t:div[@ana='#bk_entry']">
        <p>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id" select="@xml:id"/>
            </xsl:if>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <!-- pb -->
    <xsl:template match="t:pb[@facs|@n]">
        <div class="row border-bottom mt-5 mb-5">
            <a class="col-sm-12">
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
                        <xsl:text>folio </xsl:text>
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Scan </xsl:text><xsl:value-of select="position()"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@facs">
                   <xsl:text> </xsl:text><i class="fa fa-file-image-o" aria-hidden="true"><xsl:text> </xsl:text></i>
                </xsl:if>
            </a>
        </div>
    </xsl:template>
   
    <!-- /////////////////////////////////////// -->
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
    
    <!-- /////////////////////////////////////// -->
    <!-- del -->
    <xsl:template match="t:del">
        <del class="bg-warning" data-toggle="tooltip" title="deletion">
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- damage -->
    <xsl:template match="t:damage">
        <mark class="bg-danger" data-toggle="tooltip" title="damage">
            <xsl:apply-templates/>
        </mark> 
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- supplied -->
    <xsl:template match="t:supplied">
        <mark data-toggle="tooltip" title="supplied">
            <xsl:apply-templates/>
        </mark>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- add -->
    <xsl:template match="t:add">
        <mark class="bg-success" data-toggle="tooltip" title="add">
            <xsl:apply-templates/>
        </mark>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- subst -->
    <xsl:template match="t:subst">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- note -->
    <xsl:template match="t:note">
        <xsl:text> </xsl:text>
        <mark class="glyphicon glyphicon-star" data-toggle="tooltip" title="{normalize-space(.)}"><xsl:text> </xsl:text>
            <i class="fa fa-info" aria-hidden="true"><xsl:text> </xsl:text></i>
        </mark>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
	<xsl:template match="t:ex">
		<xsl:text>[</xsl:text><xsl:apply-templates/><xsl:text>]</xsl:text>
	</xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- choice -->
    <xsl:template match="t:choice">
        <abbr title="{t:expan}">
            <xsl:choose>
                <xsl:when test="t:abbr">
                    <xsl:value-of select="t:abbr"/>
                </xsl:when>
                <xsl:otherwise><xsl:comment>t:abbr missing in choice</xsl:comment></xsl:otherwise>
            </xsl:choose>   
        </abbr>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- /////////////////////////////////////// -->
    
    <!-- INDEX - TAXONOMY -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:unitDecl[@ana='bk:Taxonomy']">
        <xsl:call-template name="getIndexHeader">
            <xsl:with-param name="IndexTitle" select="'Units'"/>
        </xsl:call-template>
        <!--  -->
        <xsl:for-each-group select="t:unitDef" group-by="@type">
            <xsl:sort select="@type" data-type="text"/>
            <h4>
                <xsl:call-template name="capitalizeFirstCharacter">
                    <xsl:with-param name="String" select="current-grouping-key()"/>
                </xsl:call-template>
            </h4>
            <xsl:for-each select="current-group()">
                <xsl:sort select="t:label" data-type="text"/>
                <span class="ml-5 row">
                    <span class="col-4">
                         <xsl:call-template name="capitalizeFirstCharacter">
                             <xsl:with-param name="String" select="t:label"/>
                         </xsl:call-template>
                    </span>
                    <xsl:if test="contains(@ref, 'wd:')">
                        <xsl:text> </xsl:text>
                        <a target="_blank" href="{concat('https://www.wikidata.org/wiki/', substring-after(@ref, 'wd:'))}" title="Wikidata">
                            <img src="/depcha/trunk/www/img/wikidata.png" class="img-responsive" alt="Wikidata_Icon" width="50"/> 
                        </a>
                    </xsl:if>
                </span>
            </xsl:for-each>
          <!--  <dl>
                <dt>Unit</dt>
                <dd><xsl:value-of select="t:unit"/></dd>
                
            </dl>-->
        </xsl:for-each-group>  
    </xsl:template>
    <!-- /////////////////////////////////////// -->
 <!--   <xsl:template match="t:unitDef">
        <div class="list-group-item">
            <a href="@ref" target="_blank">
                <xsl:call-template name="capitalizeFirstCharacter">
                    <xsl:with-param name="String" select="t:label"/>
                </xsl:call-template>
            </a>
                
        </div>
    </xsl:template>
    
    -->
    <!-- INDEX - TAXONOMY -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:taxonomy[@ana='bk:Taxonomy']">
        <xsl:call-template name="getIndexHeader"/>
        <!--  -->
        <div class="list-group">
            <xsl:apply-templates select="t:unitDef"/>
        </div>
    </xsl:template>
    
  
    
    <!-- INDEX - PLACES -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:listPlace[@ana='bk:Between']">
        <xsl:call-template name="getIndexHeader"/>
        <!--  -->
        <div class="list-group">
            <xsl:apply-templates select="t:place"/>
        </div>
    </xsl:template>
    
    <!-- INDEX - ORGANISATIONS -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:listOrg[@ana='bk:Between']">
        <xsl:call-template name="getIndexHeader"/>
        <!--  -->
        <div class="list-group">
            <xsl:apply-templates select="t:org"/>
        </div>
    </xsl:template>
    
    <!-- INDEX - PERSON -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:listPerson[@ana='bk:Between']">
        <xsl:call-template name="getIndexHeader"/>
        <!--  -->
        <div class="list-group">
            <xsl:apply-templates select="t:person">
                <!--<xsl:sort select="t:persName/t:surname[1]|t:persName/t:name[1]"></xsl:sort>-->
            </xsl:apply-templates>
        </div>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!--  -->
    <xsl:template match="t:category">
        <xsl:param name="DEPTH"/>
        <!--<xsl:element name="{concat('h', $DEPTH)}">
           
            <xsl:apply-templates select="t:gloss"/>
        </xsl:element>-->
           
            <dt>
                <xsl:value-of select="t:gloss"/>
            </dt>
        <xsl:if test="t:p|t:ab|t:catDesc">
                <dd><xsl:value-of select="t:p|t:ab|t:catDesc"/></dd>
            </xsl:if>
             <xsl:apply-templates select="t:category">
                 <xsl:with-param name="DEPTH" select="$DEPTH+1"/>
             </xsl:apply-templates>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- person, place and org in a list -->
    <xsl:template match="t:listPerson[@ana='bk:Between']/t:person | 
                         t:listPlace[@ana='bk:Between']/t:place | 
                         t:listOrg[@ana='bk:Between']/t:org">
        <div class="list-group-item">
            <xsl:if test="@xml:id">
                <xsl:attribute name="id" select="@xml:id"/>
            </xsl:if>
            <span class="row">
                <xsl:apply-templates select="t:persName|t:placeName|t:orgName"/>
            </span>
            <!-- all children not beeing "persName" -->
            <xsl:if test="*[not(name() = 'persName')][not(name() = 'placeName')][not(name() = 'orgName')]">
                 <div class="row">
                     <ul class="small">
                         <xsl:apply-templates select="*[not(name() = 'persName')][not(name() = 'placeName')][not(name() = 'orgName')]"/>
                     </ul>
                 </div>
            </xsl:if>
        </div>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:person/*[not(name() = 'persName')] |
                         t:place/*[not(name() = 'placeName')] |
                         t:org/*[not(name() = 'orgName')]">
       <li>
           <!-- PRINT TEI ELEMENT-NAME -->
           <strong>
               <xsl:call-template name="capitalizeFirstCharacter">
                   <xsl:with-param name="String" select="local-name()"/>
               </xsl:call-template>
           </strong>
           <xsl:text>: </xsl:text>
           <xsl:choose>
               <xsl:when test="*|@*">
                   <xsl:apply-templates select="*|@*"/>
               </xsl:when>
               <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
           </xsl:choose>
       </li>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="@type">
        <xsl:value-of select=".."/><xsl:text> [</xsl:text><xsl:value-of select="."/><xsl:text>]</xsl:text>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:birth/@when">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="@notBefore">
        <span title="Not Before">
            <xsl:value-of select="."/>
        </span>
        <xsl:text> </xsl:text>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="@from">
        <xsl:value-of select="."/>
        <xsl:text>- </xsl:text>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="@to">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <!-- birthplace -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:birth/t:placeName">
       <xsl:for-each select="*">
           <xsl:value-of select="."/>
           <xsl:if test="not(position()=last())">
            <xsl:text>, </xsl:text>
           </xsl:if>
       </xsl:for-each>
    </xsl:template>
    
    <!-- residenceplace -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:residence/t:placeName">
        <xsl:for-each select="*">
            <xsl:value-of select="."/>
            <xsl:if test="not(position()=last())">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:sex/@value">
        <xsl:choose>
            <xsl:when test=". castable as xs:string">
                <xsl:call-template name="capitalizeFirstCharacter">
                    <xsl:with-param name="String" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test=". = 2">
                <xsl:text>Female</xsl:text>
            </xsl:when>
            <xsl:when test=". = 1">
                <xsl:text>Male</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:persName">
        <strong>
            <xsl:choose>
                <xsl:when test="t:name">
                    <xsl:apply-templates select="t:name"/>
                </xsl:when>
                <!-- SURNAME, FORENAME (ADDNAME) -->
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </strong>
    </xsl:template>
    <!-- /////////////////////////////////////// -->
    <!-- persName -->
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:surename">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:forename">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:surname/t:roleName">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:nameLink">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:surname/t:placeName">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:addName">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <xsl:template match="t:residence">
        <xsl:text> | </xsl:text>
        <xsl:for-each select=".">
            <xsl:apply-templates/>
        </xsl:for-each>
        <xsl:text> | </xsl:text>
    </xsl:template>
    
    <!-- /////////////////////////////////////// -->
    <!-- /////////////////////////////////////// -->
    <!-- CALLED TEMPLATES - HELPERS -->
    
    <!-- /////////////////////////////////////// -->
    <!-- defines heading and desc of index <listPerson> etc. <taxonomy> -->
    <xsl:template name="getIndexHeader">
        <xsl:param name="IndexTitle"/>
        <h3>
            <xsl:choose>
                <xsl:when test="t:head|t:gloss[1]">
                    <xsl:value-of select="t:head|t:gloss[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('Index View: ', $IndexTitle)"/>
                </xsl:otherwise>
            </xsl:choose>
        </h3>
        <xsl:if test="t:desc">
            <p class="font-weight-light">
                <xsl:apply-templates select="t:desc"/>
            </p>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
