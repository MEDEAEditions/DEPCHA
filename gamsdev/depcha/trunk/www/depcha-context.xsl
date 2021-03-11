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


    <xsl:include href="depcha-static.xsl"/>

    <xsl:template name="content">
        <xsl:choose>
            <!-- //////////////////////////////////////////////////////////// -->
            <!-- IMPRESSUM ABOUT and HOME are static datastream in context:depcha -->
            <xsl:when test="$mode = 'imprint'">
                <div class="card-header">
                    <h1 class="card-title">Imprint</h1>
                </div>
                <div class="card-body">
                    <xsl:apply-templates select="document(concat('/context:depcha/', 'IMPRINT'))/t:TEI/t:text/t:body/t:div"/>
                </div>
            </xsl:when>
            
            <!-- ///////////////////////// -->
            <!-- ABOUT -->
            <xsl:when test="$mode = 'about'">
                <div class="card-header">
                    <h1 class="card-title">About</h1>
                </div>
                <div class="card-body">
                    <xsl:apply-templates select="document(concat('/context:depcha/', 'ABOUT'))/t:TEI/t:text/t:body/t:div"/>
                </div>
            </xsl:when>
         
            <!-- ///////////////////////// -->
            <!-- DATABASKET -->
            <xsl:when test="$mode = 'databasket'">
                <div class="col-md-12">
                    <div  class="card">
                        <div class="card-header"> 
                            <h1 class="card-title">
                                <xsl:text>DATA BASKET</xsl:text>
                            </h1>
                            <div>
                                <p>
                                    <xsl:text>Data entries can be added to the data basket.</xsl:text><br/>
                                </p>
                                <div class="btn-group" role="group" aria-label="Sortieren">
                                    <button type="button" class="btn hidden-print" style="font-size:18px; background: none"  onclick="window.print()"><xsl:text>PRINT</xsl:text><span class="glyphicon glyphicon-print" aria-hidden="true"><xsl:text> </xsl:text></span></button>
                                    <button class="btn disabled" href="#" role="button" style="margin: 10px;">
                                        <img alt="Excel" height="25" id="rdf" src="{concat($gamsdev, '/img/TABELLENSYMBOL.png')}" title="HSSF"/>
                                    </button>
                                    
                                    <button type="button" class="btn" style="font-size:18px; background: none;"  onclick="clearData()"><xsl:text>CLEAR</xsl:text><span class="glyphicon glyphicon-remove"><xsl:text> </xsl:text></span></button>
                                </div>
                                <xsl:variable name="Table-ID" select="concat('table_id', position())"/>
                                <!-- call DataTable -->
                                <script>
                                    $(document).ready(function() {
                                    $('#databasket_table').DataTable();
                                    } );
                                </script>
                                <table id="databasket_table" class="table table-bordered" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th><xsl:text>ENTRY</xsl:text></th>
                                            <th><xsl:text>WHEN</xsl:text></th>
                                            <th><xsl:text>FROM</xsl:text></th>
                                            <th><xsl:text>TO</xsl:text></th>
                                            <th><xsl:text>MEASURABLE</xsl:text></th>
                                            <th><xsl:text></xsl:text></th>
                                        </tr>
                                    </thead>
                                    <tbody id="databasekt_tbody">
                                        
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div id="databasekt_content">
                                    <xsl:text> </xsl:text>
                                </div>
                                <script>
                                    showData();
                                </script>
                            </div>    
                        </div>
                    </div>
                </div>
            </xsl:when>
            <!-- ///////////////////////// -->
            <!-- HOWTO -->
            <xsl:when test="$mode = 'howto'">
            	<xsl:variable name="HOWTO_TEI" select="document(concat('/context:depcha/', 'HOWTO'))"/>
                <div class="row row-offcanvas row-offcanvas-left">
                    <!-- sidebar, which will move to the top on a small screen -->
                    <div class="col-sm-2 pt-3 mt-2">
                        <nav id="toc" data-toggle="toc" class="sticky-top">
                            <ul class="nav">
                             <xsl:for-each select="$HOWTO_TEI//t:TEI/t:text/t:body/t:div/t:div[t:head[@xml:id]]">
                                 <a class="text-body" href="{concat('#',t:head/@xml:id)}">
                                     <xsl:value-of select="t:head"/>
                                 </a>
                                 <xsl:if test=".//t:div[t:head[@xml:id]]">
                                     <ul class="small">
                                         <xsl:for-each select=".//t:div[t:head[@xml:id]]">
                                           <li>
                                               <a href="{concat('#',t:head/@xml:id)}" class="text-body">
                                                   <xsl:value-of select="t:head"/>
                                               </a>
                                           </li>
                                       </xsl:for-each>
                                     </ul>
                                 </xsl:if>
                             </xsl:for-each>
                            </ul>
                        </nav>
                    </div>
                    <!-- main content area -->
                	<div class="col">
	                   <xsl:apply-templates select="$HOWTO_TEI//t:TEI/t:text/t:body/t:div"/>
                	</div>
                 </div>
            </xsl:when>
            <!-- ///////////////////////// -->
            <!-- DATA SETS -->
            <xsl:when test="$mode = 'datasets'">
                <div class="card-header">
                    <div class="row">
                        <div class="col-sm-8">
                            <h1 class="card-title">Data Sets</h1>
                        </div>
                        <div class="col-sm-4">
                            <h1 class="card-title">Overview</h1>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <xsl:call-template name="datasets"/>
                </div>
            </xsl:when>
            <!-- ///////////////////////// -->
            <!-- DATA VIEW -->
            <xsl:when test="$mode = 'dataview'">
                <div class="card-header">
                    <div class="row">
                        <div class="col-sm-8">
                            <h1 class="card-title">aa</h1>
                        </div>
                        <div class="col-sm-4">
                            <h1 class="card-title">bbb</h1>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <xsl:text>aa</xsl:text>
                </div>
            </xsl:when>
            
            <!-- ///////////////////////// -->
            <!-- HOME -->
            <xsl:otherwise>
                <div class="card-body">
                    <xsl:apply-templates select="document(concat('/context:depcha/', 'HOME'))/t:TEI/t:text/t:body/t:div"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    

    <!-- /////////////////////////////////////// -->
    <!-- DATA SETS -->
    <xsl:template name="datasets">
        
        <!-- PARAM context:depcha.wheaton for querying all data in a context  -->
        <xsl:variable name="Query_URL" select="'/archive/objects/query:depcha.data-context/methods/sdef:Query/get?params='"/>
        
        <!-- every context:depcha.xy is a dataset; depcha:context is the root context from all of them -->
        <xsl:variable name="Context" select="document('/context:depcha/METADATA')"/>
      
        <div class="row">
            <!-- //////// -->
            <!-- DATASETS -->
            <div class="col-sm-8">
                <div id="MainMenu">
                    <div class="list-group">
                        <xsl:for-each select="//s:results/s:result">
                            <xsl:sort select="s:title"/>
                          
                            <xsl:variable name="PARAM" select="encode-for-uri(concat('$1|&lt;https://gams.uni-graz.at/', s:identifier, '&gt;'))"/>
                            
                            <div class="list-group-item">
                                <div class="row">
                                    <!-- METADATA -->
                                    <div class="col-sm-8">
                                        <strong class="color" title="{s:identifier}"><xsl:value-of select="s:title"/></strong>
                                        <p><xsl:value-of select="s:description"/></p>
                                        <ul>
                                            <li><xsl:value-of select="s:date"/></li>
                                            <li><xsl:value-of select="s:coverage"/></li>
                                            <li><xsl:value-of select="s:language"/></li>
                                        </ul>
                                    </div>
                                    <!-- VIEWS and EXPORTS -->
                                    <div class="col-sm-4">
                                        <!--<a class="btn btn-light mt-1 btn-block" href="{concat($Query_URL, $PARAM)}">Data View</a>-->
                                        <a class="btn btn-light mt-1 btn-block" href="{concat('/archive/objects/', s:identifier, '/methods/sdef:Context/get?mode=dataview')}">Data</a>
                                            
                                        <a class="btn btn-light mt-1 btn-block" href="{concat('/', s:identifier)}">Sources</a>
                                        <a class="btn btn-light mt-1 btn-block" href="#">Discover</a>
                                        <a class="btn btn-light mt-1 btn-block" href="#">About</a>
                                    </div>
                                </div> 
                            </div>
                        </xsl:for-each>
                    </div>
                </div>
            </div>
            <!-- //////// -->
            <!-- OVERVIEW -->
            <div class="col-sm-4">
                <xsl:text>lorum</xsl:text>
            </div>
            
        </div>
        
        
        
        <!--    <div class="col-12 col-md-12 card">
                <div class="card-header"> 
                    <h1 class="card-title">Data Sets</h1>
                    <div class="card-text">
                        <p>
                            <xsl:text>Here you can find an overview over all available data sets.</xsl:text><br/>
                        </p>
                        <p class="font-weight-bold">
                            <xsl:text>Attention: This version is a prototype with limited functionality and is currently under development.</xsl:text>
                            <br/>
                            <xsl:text>More coming soon!</xsl:text>
                        </p>
                    </div>
                </div>
                <div class="card-body">
                     <div class="row">
                         <xsl:for-each select="$Context//s:result">
                             <xsl:sort/>
                             <xsl:variable name="PARAM" select="encode-for-uri(concat('$1|&lt;https://gams.uni-graz.at/', s:identifier, '&gt;'))"/>
                             <div class="col-10 col-lg-10">
                                 <a href="{concat('/archive/objects/query:depcha.data-context/methods/sdef:Query/get?params=', $PARAM)}">
                                     <h2><xsl:value-of select="s:title"/></h2>
                                 </a>
                             </div>
                         </xsl:for-each>
                     </div>
                </div>
            </div>-->
    </xsl:template>
    
    

</xsl:stylesheet>