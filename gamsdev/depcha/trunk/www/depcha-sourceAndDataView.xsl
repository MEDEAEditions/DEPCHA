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
                <!-- ///////////// -->
                <!-- HEADER -->
                <div class="card-header">
                    <h1>
                        <xsl:text>Data View: </xsl:text>
                        <strong>
                            <xsl:value-of select="//s:result[1]/s:container"/>
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
                        </div>
                        <div class="col-sm-2">
                            <h3 class="card-title">Export</h3>
                        </div>
                    </div>
                    <div class="row">
                        <ul>
                            <li>
                                responsive: true,
                            </li>
                            <li>autoFill: true</li>
                        </ul>
                    </div>
                    <div class="row">
                        <div class="table-responsive">
                            <table class="table" id="data_view_table">
                                <thead>
                                    <tr>
                                        <!-- selectAllCheckboxes() with id of table -->
                                        <th scope="col"><input type="checkbox" name="select_all" value="1" id="example-select-all" onclick="selectAllCheckboxes(data_view_table)"/> ENTRY</th>
                                        <th scope="col">WHEN</th>
                                        <th scope="col">MEARSURMENT</th>
                                        <th scope="col">FROM</th>
                                        <th scope="col">TO</th>
                                    </tr>
                                </thead>
                                <!--<tbody id="data_view_table">
                                   <tr>
                                       <td rowspan="2">ENTRY</td>
                                       <td rowspan="2">WHEN</td>
                                       <td>WHAT1</td>
                                       <td>FROM1</td>
                                       <td>TO1</td>
                                   </tr>
                                   <tr>
                                       <td>WHAT2</td>
                                       <td>FROM2</td>
                                       <td>TO2</td>   
                                   </tr>
                                </tbody>-->
                            </table>
                        </div>
                    </div>
                    <script>
                        getJsonBuildDataTable(<xsl:value-of select="concat('&quot;',//s:result[1]/s:cid,'&quot;')"/>);
                    </script>
                </div>
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
