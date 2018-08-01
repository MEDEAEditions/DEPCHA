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
        <xsl:choose>
            <!-- COLLECTION -->
            <xsl:when test="$mode = 'collection'">
                <section class="row">
                    <article class="col-md-12">
                            <xsl:call-template name="collection"/>
                    </article>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="home"/>
            </xsl:otherwise>
        </xsl:choose>
        
       
        
        
        
    </xsl:template>
    
    
    <!-- HOME -->
    <xsl:template name="home">
        <section class="row">
            <div class="col-md-6 card">
                <div class="card-body">
                 <img class="img-fluid" src="https://medea.hypotheses.org/files/2016/07/660px-Nuremberg_chronicles_-_CRACOVIA.png" alt="Card image cap"  width="400"/>
                 <img class="img-fluid" src="https://gams.uni-graz.at/context:srbas/STARTBILD" alt="Card image cap" width="400"/>
                </div>
            </div>
            <div class="col-md-6 card">
                <div class="card-body">
                    <h3 class="card-title">
                    Welcome to the MEDEA-Page!
                    </h3>
                <p>
                    Since the semantic web offers opportunities to collect and compare data from multiple digital projects, the MEDEA project
                    looks to the potential of developing broad standards for producing semantically enriched digital editions of accounts. For its
                    initial stage, the MEDEA project will bring together economic historians, scholarly editors, and technical experts to discuss and test
                    emerging methods for semantic markup of account books.
                </p>
                <p> 
                    Contact: 
                    <br></br>
                    <a href="mailto:medea.workshop@ur.de">medea.workshop@ur.de</a>
                    <br></br>
                    <a href="mailto:christopher.pollin@uni-graz.at">christopher.pollin@uni-graz.at</a>
                </p></div>
            </div>
        </section>
    </xsl:template>
    
    <!-- COLLECTIOOn -->
    <xsl:template name="collection">
        <!-- every context is a dataset -->
        <xsl:variable name="Context" select="document('/archive/objects/context:medea/methods/sdef:Object/getMetadata')"/>
            <div class="col-12 col-md-12 card">
                <div class="card-body">
                    <h1 class="card-title">Collection</h1>
                    <p class="lead">List of all data sets</p>
                
                <div class="row">
                    <xsl:for-each select="$Context//s:result">
                        <xsl:sort/>
                        
                        <div class="col-10 col-lg-10">
                            <a href="{concat('/archive/objects/query:medea.getdata-context/methods/sdef:Query/get?params=$1|%3Chttps%3A%2F%2Fgams.uni-graz.at%2F', s:identifier, '%3E')}">
                                <h2><xsl:value-of select="s:title"/></h2>
                            </a>
                        </div>
                    </xsl:for-each>
                </div>
                </div><!--/row-->
            </div><!--/span-->
            
            <!--<div class="col-6 col-md-3 sidebar-offcanvas" id="sidebar">
                <div class="list-group">
                    <a href="#" class="list-group-item active">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                    <a href="#" class="list-group-item">Link</a>
                </div>
            </div>--><!--/span-->
        <!--/row-->
    </xsl:template>

</xsl:stylesheet>