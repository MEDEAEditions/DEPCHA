<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Project: depcha
    Company: ZIM-ACDH (Zentrum fÃ¼r Informationsmodellierung - Austrian Centre for Digital Humanities)
    Author: Christopher Pollin 
    Last update: 2020
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
        
        <xsl:choose>
            <!-- ///////////////////////// -->
            <!-- DATA VIEW -->
            <xsl:when test="$mode = 'dataview'">
                <!-- ///////////////////////// -->
                <!-- VARIABLES -->
                <xsl:variable name="Result" select="//s:result[1]"/>
                <xsl:variable name="CONTEXT" select="$Result/s:cid[1]"/>
                <!-- dc metadata of context -->
                <xsl:variable name="DC_Context-Metadata" select="document(concat('/', $CONTEXT, '/DC'))"/>
                
                <div id="main">
                    <div class="row row-offcanvas row-offcanvas-left">
                        <!--<div class="col-md-2 col-lg-2 sidebar-offcanvas bg-secondary pl-0" id="sidebar" role="navigation">
                            <ul class="nav flex-column sticky-top pl-0 pt-5 mt-3">
                                <li class="nav-item"><a class="nav-link" href="#">Overview</a></li>
                                <li class="nav-item">
                                    <a class="nav-link" href="#submenu1" data-toggle="collapse" data-target="#submenu1">Source▾</a>
                                    <ul class="list-unstyled flex-column pl-3 collapse" id="submenu1" aria-expanded="false">
                                        <xsl:for-each select="//s:result">
                                            <xsl:sort select="s:title" data-type="text" lang="en"/>
                                            <li class="nav-item">
                                                <a class="nav-link" href="{concat('/', s:identifier)}" target="_blank">
                                                    <xsl:value-of select="s:title"/>
                                                </a>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </li>
                                <li class="nav-item"><a class="nav-link" href="{concat('/', $CONTEXT)}">About</a></li>
                            </ul>
                        </div>-->
                        <!--/col-->
                        
                        <div class="col main pt-3 mt-2">
                            
                            <h1 class="d-none d-sm-block font-weight-bold">
                                <xsl:value-of select="$Result/s:container"/>
                            </h1>
                            <p class="d-none d-sm-block">
                                <xsl:if test="$DC_Context-Metadata//*:date">
                                    <xsl:value-of select="$DC_Context-Metadata//*:date"/>
                                    <xsl:text> | </xsl:text>
                                </xsl:if>
                                <xsl:if test="$DC_Context-Metadata//*:language">
                                    <xsl:value-of select="$DC_Context-Metadata//*:language"/>
                                    <xsl:text> | </xsl:text>
                                </xsl:if>
                                <xsl:if test="$DC_Context-Metadata//*:coverage">
                                    <xsl:value-of select="$DC_Context-Metadata//*:coverage"/>
                                </xsl:if>
                                <br/>
                                <small class="font-weight-light">
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$DC_Context-Metadata//*:contributor"/>
                                    <xsl:text>: </xsl:text>
                                    <xsl:value-of select="$DC_Context-Metadata//*:title"/>
                                    <xsl:text>. In: DEPCHA. </xsl:text>
                                    <!-- but this is just the lastModifiedDate og the first o: inside the contect:  -->
                                    <xsl:value-of select="format-dateTime($Result//s:lastModifiedDate, '[D].[M].[Y]')"/>
                                    <xsl:text>. </xsl:text>
                                    <xsl:value-of select="concat('https://gams.uni-graz.at/', $DC_Context-Metadata//*:identifier)"/>
                                    <xsl:text> </xsl:text>
                                    <i class="fas fa-quote-right"><xsl:text> </xsl:text></i>
                                </small>
                            </p>
                            
                            <div class="alert alert-warning fade collapse" role="alert" id="myAlert">
                                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                                    <span aria-hidden="true">×</span>
                                    <span class="sr-only">Close</span>
                                </button>
                                <strong>Holy guacamole!</strong> It's free.. this is an example theme.
                            </div>
                            
                            <hr/>
                                <div class="row placeholders mb-3">
                                    <div class="col-6 col-sm-3 placeholder text-center">
                                        <!--<img src="//placehold.it/200/dddddd/fff?text=1" class="mx-auto img-fluid rounded-circle" alt="Generic placeholder thumbnail"/>-->
                                        <h4>Analysis</h4>
                                        <span class="text-muted">
                                            <xsl:text>Loremp Ipsum</xsl:text>
                                        </span>
                                    </div>
                                    <div class="col-6 col-sm-3 placeholder text-center">
                                        <h4>Search</h4>
                                        <span class="text-muted">
                                            <xsl:text>Loremp Ipsum</xsl:text>
                                        </span>
                                    </div>
                                    <div class="col-6 col-sm-3 placeholder text-center">
                                        <h4>Discovery</h4>
                                        <span class="text-muted">
                                            <xsl:text>Loremp Ipsum</xsl:text>
                                        </span>
                                    </div>
                                    <div class="col-6 col-sm-3 placeholder text-center">
                                        <h4>Export</h4>
                                        <!-- http://glossa.uni-graz.at/archive/objects/query:depcha.data-context/methods/sdef:Query/getHSSF?params=%241%7C%22context%3Adepcha.gwfp%22 -->
                                        <xsl:variable name="Query_HSSF_Param" select="encode-for-uri(concat('$1|&lt;', 'https://gams.uni-graz.at/', //s:result[1]/s:cid,'&gt;'))"/>
                                        <!--<a class="mb-1 row" href="{concat('/archive/objects/query:depcha.data-context/methods/sdef:Query/getHSSF?params=', $Query_HSSF_Param)}" role="button">
                                                <span class="col-sm-2"><img alt="Excel" height="25" id="excel" src="{concat($gamsdev, '/img/TABELLENSYMBOL.png')}" title="Excel Export"/><xsl:text> </xsl:text></span>
                                             
                                            </a>-->
                                        
                                    </div>
                                </div>
                                <hr/>
                                <div class="card">
                                    <h3 class="card-title">Barchar</h3>
                                    <div>
                                        <svg id="in"></svg>
                                        
                                        <script>
                                            getBarChart_Date_Value('query:depcha.dataset_incomeExpense_date', '<xsl:value-of select="$CONTEXT"/>');
                                        </script>
                                        
                                        
                                    </div>
                                </div>
                            <div class="card">
                                <h3 class="card-title">Treemap</h3>
                                <div>
                                    <svg id="tree"></svg>
                                    
                                    <script>
                                        getTreemap('query:depcha.commodities_treemap', '<xsl:value-of select="$CONTEXT"/>');
                                    </script>
                                    
                                    
                                </div>
                            </div>
                            
                            
                            
                                    <!--<p class="lead mt-5">
                                        Lorem Ipsum
                                    </p>
                                    <div class="row my-4">
                                        <div class="col-lg-12 col-md-12">
                                            <div  class="table-responsive">
                                                <table class="table table-sm" id="data_table">
                                                    <thead id="data_table_head" class="thead-inverse">
                                                        
                                                    </thead>
                                                    <tbody id="data_table_body"/>
                                                    
                                                    <script>
                                                        fetchSPARQL_Json(<xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>);
                                                    </script>
                                                    
                                                </table>
                                            </div>
                                        </div>
                                    </div>-->
                        </div>
                    </div>
                </div>
                
                
                
                
                
                <!-- ///////////// -->
                <!-- HEADER -->
             <!--       <h1>
                        <xsl:text>Data View </xsl:text>
                        <strong>
                            <xsl:value-of select="//s:result[1]/s:container"/>
                        </strong>
                    </h1>
                
                <div class="card-body">
                    <!-\- METADATA ~ teiHeader -\->
                    <div class="row">
                        <div class="col-sm-8">
                            <h3 class="card-title">Metadata</h3>
                            <xsl:call-template name="info_box_tei"/>
                        </div>
                        <div class="col-sm-2">
                            <h3 class="card-title">View</h3>                       
                        </div>
                        <div class="col-sm-2">
                            <h3 class="card-title">Export</h3>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-3">
                            <xsl:text> </xsl:text>
                        </div>
                        <div class="col-9">
                            <div  class="table-responsive">
                                <table class="table" id="data_table">
                                    <thead id="data_table_head">
                                        
                                        <th>Date</th>
                                        <th>Entry</th>
                                        <th>Quantity</th>
                                        <th>Unit</th>
                                        <th>From</th>
                                        <th>To</th>
                                    </thead>
                                    <tbody id="data_table_body"/>
                                    
                                    <script>
                                        fetchSPARQL_Json(<xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>);
                                    </script>
                                    
                                </table>
                            </div>
                        </div>
                    </div>
                </div>-->   
                    
                        
                    
                    
                    
                       <!-- <div id="root" class="row"><xsl:text> </xsl:text></div>
                        <script>
                            a();
                        </script>
                        <script src="{concat($gamsdev,'/react-d3-dashboard/js/2.3d2ebb48.chunk.js')}"><xsl:text> </xsl:text></script>
                        <script src="{concat($gamsdev,'/react-d3-dashboard/js/main.eb246c70.chunk.js')}"><xsl:text> </xsl:text></script>-->
                    
                    <!--<div class="row">
                        <ul>
                            <li>
                                responsive: true,
                            </li>
                            <li>autoFill: true</li>
                            <xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>
                        </ul>
                    </div>-->
                    
                    <!--<div class="row">
                        <h3>Debit</h3>
                        <svg id="income"><xsl:text> </xsl:text></svg>
                    </div>
                    <div class="row" >
                        <h3>Credit</h3>
                        <svg id="expens"><xsl:text> </xsl:text></svg>
                    </div>
                    
                    <style>
 
                        rect.bar-rect { fill: steelblue; }
                        
                       
                        rect.bar-rect:hover { 
                            fill: #349dc9;
                            transition: all .2s;
                        }
                        
                        text{
                            font-size: 1.2em;
                            fill: #635F5D;
                            
                        }
                        
                        .tick line {
                            stroke: #C0C0BB;
                            stroke-opacity:0.75;
                            stroke-dasharray:2,2,2;
                        }
                    </style>
                    
                    
                    <!-\- getBarChart_Date_Value(query_pid, pid, value_type) -\->
                    <script>
                        getBarChart_Date_Value('query:depcha.dataset-date-income-expenses', <xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>, 'expens');
                    </script>
                    
                    <script>
                        getBarChart_Date_Value('query:depcha.dataset-date-income-expenses', <xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>, 'income');
                    </script>-->
                    
                    <!--<script>
                        getJsonBuildDataTable(<xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>);
                    </script>-->
                
            </xsl:when>
            <!-- //////// -->
            <!-- SOURCE VIEW -->
            <xsl:otherwise>
                <div class="card-header">
                    <div class="row">
                        <div class="col-sm-8">
                            <h1 class="card-title">Source View</h1>
                        </div>
                        <div class="col-sm-4">
                            <h1 class="card-title">Overview</h1>
                        </div>
                    </div>
                </div>
                <div class="card-body">

                    <div class="row">
                        <div class="col-sm-8">
                            <div id="MainMenu">
                                <div class="list-group">
                                    <xsl:for-each select="//s:results/s:result">
                                        <xsl:sort select="s:title"/>
                                        <div class="list-group-item">
                                            <div class="row">
                                                <!-- THUMBNAIL -->
                                                <div class="col-sm-2">
                                                    <img src="{concat('/', s:identifier, '/IMG.1')}" alt="..." class="img-fluid"/>
                                                </div>
                                                <!-- METADATA -->
                                                <div class="col-sm-7">
                                                    <strong class="color"><xsl:value-of select="s:title"/></strong>
                                                    <!--<ul>
                                                        <li><xsl:value-of select="s:date"/></li>
                                                        <li><xsl:value-of select="s:coverage"/></li>
                                                        <li><xsl:value-of select="s:language"/></li>
                                                    </ul>-->
                                                </div>
                                                <!-- VIEWS and EXPORTS -->
                                                <div class="col-sm-3">
                                                    <a class="btn btn-light mt-1 btn-block" href="{concat('/', s:identifier)}" title="Edition view of source object">Edition View</a>
                                                    <!-- open TEI/METS in Mirador: http://glossa.uni-graz.at/archive/objects/o:depcha.washington.42/methods/sdef:IIIF/getMirador -->
                                                    <a class="btn btn-light mt-1 btn-block" href="{concat('/archive/objects/', s:identifier, '/methods/sdef:IIIF/getMirador')}" title="Facsimile View in Mirador-Viewer">Facsimile View</a>
                                                    <a class="btn btn-light mt-1 btn-block" href="#" title="Data View of source object">Data View</a>
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
                            <xsl:text>aa</xsl:text>
                        </div>
                    </div>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
