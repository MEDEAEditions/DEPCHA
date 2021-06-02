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
    
    <!-- ///////////////////////// -->
    <xsl:strip-space elements="*"/>
    <xsl:include href="depcha-static.xsl"/>
    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>
    
    <xsl:template name="content">
        <xsl:choose>
            <xsl:when test="$mode = 'dataview'">
                <!-- ///////////////////////// -->
                <!-- VARIABLES -->
                <xsl:variable name="Result" select="//s:result[1]"/>
                <xsl:variable name="CONTEXT" select="$Result/s:cid[1]"/>
                <!-- dc metadata of context -->
                <xsl:variable name="DC_Context-Metadata" select="document(concat('/', $CONTEXT, '/DC'))"/>
                
                <!-- ///////////////////////// -->
                <!-- QUERY RESULTS -->
                <xsl:variable name="BASE_URL" select="'https://gams.uni-graz.at/'"/>
                <xsl:variable name="Query_URL" select="encode-for-uri(concat('$1|&lt;',$BASE_URL, $CONTEXT, '&gt;'))"/>
                <!-- query:depcha.index-subjects -->
                <xsl:variable name="QUERY_INDEX_SUBJECTS" select="document(concat('/archive/objects/query:depcha.index-subjects/methods/sdef:Query/getXML?params=', $Query_URL))//s:results/s:result"/>
                <!-- query:depcha.index-goods -->
                <xsl:variable name="QUERY_INDEX_OBJECTS" select="document(concat('/archive/objects/query:depcha.index-objects/methods/sdef:Query/getXML?params=', $Query_URL))//s:results/s:result"/>
                    <xsl:variable name="QUERY_INDEX_OBJECTS_DISTINCT_COUNT" select="count(distinct-values($QUERY_INDEX_SUBJECTS/s:be/@uri))"/>
                

                
                
                <!-- query:depcha.index-where -->
                <xsl:variable name="QUERY_INDEX_WHERE" select="document(concat('/archive/objects/query:depcha.index-where/methods/sdef:Query/getXML?params=', $Query_URL))//s:results/s:result"/>
                <!-- overview count -->
                <xsl:variable name="QUERY_OVERVIEW_COUNT" select="document(concat('/archive/objects/query:depcha.overview-count/methods/sdef:Query/getXML?params=', $Query_URL))//s:results/s:result[1]"/>
                <!-- ///////////////////////// -->
                <!-- MAIN -->
                <div id="dataset_view" class="container-fluid m-3">
                    <div class="d-sm-flex align-items-center justify-content-between">
                        <h3 class="font-weight-bold card-title">
                          <xsl:text>Data - </xsl:text>
                          <xsl:value-of select="$Result/s:container"/>
                        </h3>
                        <div class="mr-3">
                                <div class="list-group list-group-horizontal float-right mr-3">
                                    <a href="#" class="list-group-item">Download</a>
                                    <a href="#" class="list-group-item">Databasket</a>
                                    <a href="#" class="list-group-item">Data URL</a>
                                </div>
                        </div>
                    </div>
                    <div>
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
                                <!-- but this is just the lastModifiedDate og the first o: inside the context:  -->
                                <xsl:value-of select="format-dateTime($Result//s:lastModifiedDate, '[D].[M].[Y]')"/>
                                <xsl:text>. </xsl:text>
                                <xsl:value-of select="concat('https://gams.uni-graz.at/', $DC_Context-Metadata//*:identifier)"/>
                                <xsl:text> </xsl:text>
                                <i class="fas fa-quote-right"><xsl:text> </xsl:text></i>
                            </small>
                        </p>
                    </div>
                    
                    <!-- ////////////////////////////////////////// -->
                    <!-- NAV TAB -->
                    <div class="row mt-4">
                        <div class="col-12 d-flex justify-content-center">
                            <ul class="nav nav-tabs" id="nav-tabs" role="tablist">
                                <!-- style to overwrite nav-link -->
                                <li class="nav-item mr-3">
                                    <a href="#overview" data-toggle="tab" id="dataview-tab">Dataview</a>
                                </li>
                                <li class="nav-item mr-3">
                                    <a href="#source" data-toggle="tab" id="source-tab">Source</a>
                                </li>
                                <li class="nav-item mr-3">
                                    <a href="#about" data-toggle="tab" id="about-tab">About</a>
                                </li>
                                <xsl:if test="$QUERY_INDEX_SUBJECTS">
                                    <li class="nav-item mr-3">
                                        <a href="#indices_subjects" data-toggle="tab" id="indices_subjects-tab">Index - Subject</a>
                                    </li>
                                </xsl:if>
                                <xsl:if test="$QUERY_INDEX_OBJECTS">
                                    <li class="nav-item mr-3">
                                        <a href="#indices_good" data-toggle="tab" id="indices_good-tab">Index - Economic Goods</a>
                                    </li>
                                </xsl:if>
                                <xsl:if test="$QUERY_INDEX_WHERE">
                                    <li class="nav-item mr-3">
                                        <a href="#indices_where" data-toggle="tab" id="indices_where-tab">Index - Places</a>
                                    </li>
                                </xsl:if>
                                <!--<xsl:if test="$QUERY_INDEX_WHERE">-->
                                    <li class="nav-item mr-3">
                                        <a href="#indices_unit" data-toggle="tab" id="indices_unit-tab">Index - Unit</a>
                                    </li>
                                <!--</xsl:if>-->
                                <!--<li class="nav-item">
                                <a href="#" class="nav-link font-weight-bold" style="color: #000000 !important;"  data-toggle="tab" id="edition-tab">Edition</a>
                                </li>-->
                            </ul>
                        </div>
                    </div>
                    
                    <!-- ////////////////////////////////////////// -->
                    <!-- TAB CONTENT -->
                    <div class="tab-content mt-4">
                        <!-- ////////////////////////////////////////// -->
                        <!-- OVERVIEW -->
                        <div class="tab-pane active" id="overview" role="tabpanel">
                            <div class="row">
                                <!-- ////////////////////////////////////////// -->
                                <!-- DASHBOARD LEFT -->
                                <div class="col-6">
                                    <!-- ////////////////////////////////////////// -->
                                    <!-- Overview View-->
                                    <div class="shadow">
                                        <xsl:call-template name="get_cardHeader_Dashboard">
                                            <xsl:with-param name="h6" select="'Overview'"/>
                                        </xsl:call-template>
                                    <!-- Card Body -->
                                    <div class="card-body">
                                        <div class="row">
                                            <!-- transaction card -->
                                            <div class="col-3">
                                                <div class="border mt-0 small">
                                                    <div class="card-body">
                                                        <div class="row no-gutters align-items-center">
                                                            <div class="col-10">
                                                                <div title="Sum of all Transactions">Transactions</div>
                                                                <div title="Sum of all Economic Subjects">Subjects</div>
                                                                <div title="Sum of all Economic Objects">Objects</div>
                                                            </div>
                                                            <div class="col-2">
                                                                <div>
                                                                    <xsl:value-of select="if ($QUERY_OVERVIEW_COUNT/s:transaction &gt; 0 ) then $QUERY_OVERVIEW_COUNT/s:transaction else '0'"/>
                                                                </div>
                                                                <div>
                                                                    <xsl:value-of select="if ($QUERY_OVERVIEW_COUNT/s:economic_subject &gt; 0 ) then $QUERY_OVERVIEW_COUNT/s:economic_subject else '0'"/>
                                                                </div>
                                                                <div>
                                                                    <xsl:value-of select="if ($QUERY_OVERVIEW_COUNT/s:economic_object &gt; 0 ) then $QUERY_OVERVIEW_COUNT/s:economic_object else '0'"/>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="card-footer">
                                                        <span class="font-weight-bold">Total</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <!-- agent card -->
                                            <div class="col-3">
                                                <div class="border mt-0 small">
                                                    <div class="card-body">
                                                        <div class="row no-gutters align-items-center">
                                                            <div class="col-6">
                                                                <div class="mb-0" title="Number of unique Economic Subjects">Unique</div>
                                                            </div>
                                                            <div class="col-auto">
                                                                <div><xsl:value-of select="if ($QUERY_INDEX_OBJECTS_DISTINCT_COUNT &gt; 0 ) then $QUERY_INDEX_OBJECTS_DISTINCT_COUNT else '0'"/></div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="card-footer">
                                                        <span class="font-weight-bold">Subjects</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <!-- currency card -->
                                            <div class="col-3">
                                                <div class="border mt-0 small">
                                                    <div class="card-body">
                                                        <div class="row no-gutters align-items-center">
                                                            <div class="col-6">
                                                                <div class="mb-0" title="Number of unique Economic Objects">Unique</div>
                                                            </div>
                                                            <div class="col-auto">
                                                                <div><xsl:value-of select="if ($QUERY_OVERVIEW_COUNT/s:economic_object_distinct &gt; 0 ) then $QUERY_OVERVIEW_COUNT/s:economic_object_distinct else '0'"/></div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="card-footer">
                                                        <span class="font-weight-bold">Objects</span>
                                                    </div>
                                                </div>
                                            </div>
                                            <!-- OTHER -->
                                            <div class="col-3">
                                                <div class="border mt-0 small">
                                                    <div class="card-body">
                                                        <div class="row no-gutters align-items-center">
                                                            <div class="col-6">
                                                                <div class="text-uppercase font-weight-bold">Total</div>
                                                                <div>Agents</div>
                                                                <div>Objects</div>
                                                            </div>
                                                            <div class="col-auto">
                                                                <div class="text-uppercase font-weight-bold">100</div>
                                                                <div>10</div>
                                                                <div>10</div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="card-footer">
                                                        <span class="font-weight-bold">Money</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                        </div>
                                    
                                    <!-- ////////////////////////////////////////// -->
                                    <!-- Transaction View-->
                                    <div class="row">
                                        <div class="col-12">
                                            <div class="card shadow">
                                                <!-- -->
                                                <xsl:call-template name="get_cardHeader_Dashboard">
                                                    <xsl:with-param name="h6" select="'Transactions'"/>
                                                </xsl:call-template>
                                                <!-- -->
                                                <div class="card-body">
                                                   <div class="table-responsive">
                                                        <table class="table small" id="data_table">
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
                                                                get_transactions_datatable(<xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>);
                                                            </script>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        
                                    </div>
                                </div>
                                <!-- ////////////////////////////////////////// -->
                                <!-- DASHBOARD RIGHT - InfoVis -->
                                <div class="col-6">
                                    <div class="shadow mr-3">
                                        <!-- -->
                                        <xsl:call-template name="get_cardHeader_Dashboard">
                                            <xsl:with-param name="h6" select="'Views'"/>
                                        </xsl:call-template>
                                        <!-- -->
                                        <div class="card-body">
                                            <h3 class="card-title">Barchar</h3>
                                            <div>
                                                <svg id="BarChart_Date_Value"><xsl:text> </xsl:text></svg>
                                                
                                                <script>
                                                    getBarChart_Date_Value('query:depcha.dataset_incomeExpense_date', '<xsl:value-of select="$CONTEXT"/>');
                                                </script>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            
                            
                          <!--  <h3 class="card-title">Overview</h3>
                            
                            <!-\- /// -\->
                            
                            <div>
                                <script src="https://vega.github.io/vega/vega.min.js"><xsl:text> </xsl:text></script>
                                <script src="https://cdn.jsdelivr.net/npm/topojson-client@3"><xsl:text> </xsl:text></script>
                                <script src="https://cdn.jsdelivr.net/npm/vega@5/build/vega-core.min.js"><xsl:text> </xsl:text></script>
                                <script src="https://cdn.jsdelivr.net/npm/vega-embed@6"><xsl:text> </xsl:text></script>
                                <h3 class="card-title">https://vega.github.io/vega/usage/</h3>
                                <div>
                                    <div id="view"><xsl:text> </xsl:text></div>
                                    <script>
                                        getVEGABarChart_Date_Value('query:depcha.incomevega', '<xsl:value-of select="$CONTEXT"/>');
                                    </script>
                                </div>
                            </div>
                            <div>
                                <h3 class="card-title">Barchar</h3>
                                <div>
                                    <svg id="BarChart_Date_Value"><xsl:text> </xsl:text></svg>
                                    
                                    <script>
                                        getBarChart_Date_Value('query:depcha.dataset_incomeExpense_date', '<xsl:value-of select="$CONTEXT"/>');
                                    </script>
                                </div>
                            </div>
                            <div class="card">
                                <h3 class="card-title">Treemap</h3>
                                <div>
                                    <svg id="Treemap"><xsl:text> </xsl:text></svg>
                                    <script>
                                        getTreemap('query:depcha.commodities_treemap', '<xsl:value-of select="$CONTEXT"/>');
                                    </script>
                                </div>
                            </div>
                            
                            <!-\- /// -\->
                         -->   
                        </div> 
                        <!-- ////////////////////// -->
                        <!-- METADATA BODY -->
                        <!-- ////////////////////// -->
                        <div class="tab-pane" id="source" role="tabpanel">
                            <h3 class="card-title">Source</h3>
                        </div>
                        <!-- ////////////////////// -->
                        <!-- ABOUT -->
                        <!-- ////////////////////// -->
                        <div class="tab-pane" id="about" role="tabpanel">
                            <h3 class="card-title">About</h3>
                        </div>
                        <!-- ////////////////////// -->
                        <!-- Index - Subject -->
                        <!-- ////////////////////// -->
                        <xsl:if test="$QUERY_INDEX_SUBJECTS">
                            <div class="tab-pane" id="indices_subjects" role="tabpanel">
                                <xsl:call-template name="create_indexlist_view">
                                    <xsl:with-param name="QUERY_INDEX_RESULTS" select="$QUERY_INDEX_SUBJECTS"/>
                                    <xsl:with-param name="h6" select="'Index - Subjects'"/>
                                    <xsl:with-param name="SEARCH_QUERY" select="'query:depcha.search-subjects'"/>
                                </xsl:call-template>
                            </div>
                        </xsl:if>
                        <!-- ////////////////////// -->
                        <!-- Index - Economic Goods -->
                        <!-- ////////////////////// -->
                        <xsl:if test="$QUERY_INDEX_OBJECTS">
                            <div class="tab-pane" id="indices_good" role="tabpanel">
                                <xsl:call-template name="create_indexlist_view">
                                    <xsl:with-param name="QUERY_INDEX_RESULTS" select="$QUERY_INDEX_OBJECTS"/>
                                    <xsl:with-param name="h6" select="'Index - Economic Goods'"/>
                                    <xsl:with-param name="SEARCH_QUERY" select="'query:depcha.search-objects'"/>
                                </xsl:call-template>
                            </div>
                        </xsl:if>
                        <!-- ////////////////////// -->
                        <!-- Index - Places -->
                        <!-- ////////////////////// -->
                        <div class="tab-pane" id="indices_where" role="tabpanel">
                            <xsl:call-template name="create_indexlist_view">
                                <xsl:with-param name="QUERY_INDEX_RESULTS" select="$QUERY_INDEX_WHERE"/>
                                <xsl:with-param name="h6" select="'Index - Places'"/>
                                <xsl:with-param name="SEARCH_QUERY" select="'query:depcha.search-where'"/>
                            </xsl:call-template>
                        </div>
                        <!-- ////////////////////// -->
                        <!-- Index - UNITS -->
                        <!-- ////////////////////// -->
                        <div class="tab-pane" id="indices_unit" role="tabpanel">
                            <xsl:text>todo</xsl:text>
                        </div>
                    </div>
                    
                    
                            
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
                            
                            
                            
                                <!--<div class="row placeholders mb-3">
                                    <div class="col-6 col-sm-3 placeholder text-center">
                                        <!-\-<img src="//placehold.it/200/dddddd/fff?text=1" class="mx-auto img-fluid rounded-circle" alt="Generic placeholder thumbnail"/>-\->
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
                                        <!-\- http://glossa.uni-graz.at/archive/objects/query:depcha.data-context/methods/sdef:Query/getHSSF?params=%241%7C%22context%3Adepcha.gwfp%22 -\->
                                        <xsl:variable name="Query_HSSF_Param" select="encode-for-uri(concat('$1|&lt;', 'https://gams.uni-graz.at/', //s:result[1]/s:cid,'&gt;'))"/>
                                        <!-\-<a class="mb-1 row" href="{concat('/archive/objects/query:depcha.data-context/methods/sdef:Query/getHSSF?params=', $Query_HSSF_Param)}" role="button">
                                                <span class="col-sm-2"><img alt="Excel" height="25" id="excel" src="{concat($gamsdev, '/img/TABELLENSYMBOL.png')}" title="Excel Export"/><xsl:text> </xsl:text></span>
                                             
                                            </a>-\->
                                        
                                    </div>
                                </div>-->
                    
                            
                            
                            
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
    
    
    <!-- /////////////////////////////// -->
    <!--  -->
    <xsl:template name="create_indexlist_view">
        <xsl:param name="QUERY_INDEX_RESULTS"/>
        <xsl:param name="h6"/>
        <xsl:param name="SEARCH_QUERY"/>
        
        <xsl:if test="$QUERY_INDEX_RESULTS">
            <div class="row">
                <div class="col-6">
                    <div class="shadow mr-3">
                        <!-- -->
                        <xsl:call-template name="get_cardHeader_Dashboard">
                            <xsl:with-param name="h6" select="'Index - Places'"/>
                        </xsl:call-template>
                        <!-- -->
                        <div class="card-body">
                            <p class="text-center text-monospace">
                                <xsl:value-of select="0"/>
                            </p>
                            <xsl:for-each-group select="$QUERY_INDEX_RESULTS" group-by="s:group/@uri">
                                <xsl:sort select="s:count" data-type="number" order="descending"/>
                                <div class="list-group-item list-group-item-action border-top">
                                    <a class="arrow" data-toggle="collapse" href="{concat('#c' , generate-id())}">
                                        <i>
                                            <xsl:text>▼ </xsl:text>
                                        </i>
                                        <xsl:value-of select="s:name"/>
                                    </a>
                                    <br/>
                                    <xsl:variable name="QUERY_URL_WHERE" select="concat('/archive/objects/', $SEARCH_QUERY, '/methods/sdef:Query/get?params=', encode-for-uri(concat('$1|&lt;', current-grouping-key(), '&gt;')))"/>
                                    <a href="{$QUERY_URL_WHERE}" class="text-muted" target="blank_">
                                        <xsl:value-of select="s:count"/><xsl:text> Transactions </xsl:text><i class="fas fa-search"><xsl:text> </xsl:text></i>
                                    </a>
                                    <div class="collapse" id="{concat('c' , generate-id())}">
                                        <div class="card card-body">
                                            <table class="table table-sm">
                                                <tbody>
                                                    <!-- iterating over all properties and there literal|uri -->
                                                    <xsl:for-each select="current-group()">
                                                        <xsl:sort select="s:prop/@uri"/>
                                                        <xsl:variable name="Property" select="s:prop/@uri"/>
                                                        <xsl:if test="not($Property = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type')">
                                                            <tr>
                                                                <th class="col-4">
                                                                    <xsl:value-of select="s:prop/@uri"/>
                                                                </th>
                                                                <td class="col-8">
                                                                    <xsl:value-of select="normalize-space(s:value)"/>
                                                                    <xsl:text> </xsl:text>
                                                                </td>
                                                            </tr>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </xsl:for-each-group>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <p>
                        <xsl:text>lorem</xsl:text>
                    </p>
                </div>
            </div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="get_cardHeader_Dashboard">
        <xsl:param name="h6"/>
        <div class="card-header d-flex flex-row align-items-center justify-content-between">
            <h6 class="m-0"><xsl:value-of select="$h6"/></h6>
            <div class="dropdown no-arrow">
                <a class="dropdown-toggle" href="#" role="button" id="dropdownMenuLink"
                    data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                    <i class="fas fa-ellipsis-v fa-sm fa-fw text-gray-400"><xsl:text> </xsl:text></i>
                </a>
             <div class="dropdown-menu dropdown-menu-right shadow"
                aria-labelledby="dropdownMenuLink">
                <div class="dropdown-header">Dropdown Header:</div>
                <a class="dropdown-item" href="#">Action</a>
                <a class="dropdown-item" href="#">Another action</a>
                <div class="dropdown-divider"><xsl:text> </xsl:text></div>
                <a class="dropdown-item" href="#">Something else here</a>
            </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>