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
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#">
    
    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>
    <xsl:include href="medea-static.xsl"/>
    
    <!-- ///////////////////////////////////////////////////////////// -->
    <!-- ToDo Explanation -->
    
    <xsl:template name="content">
    	<div class="row">
	    	<div class="col-md-2">
	    		<div class="card" id="sticky-sidebar">
	    			<div class="card-header">
	    				<h3>Navigation</h3>
						<a href="/o:medea.bookkeeping/ONTOLOGY" target="_blank">
							<img alt="RDF" id="rdf" src="/templates/img/RDF_icon.png" title="RDF" height="25"/>
						</a>
	    				<br/>
	    				<a href="#Visualisation"  onclick="scrolldown(this)">Visualisation</a>
	    			</div>
		            <div class="card-body" style="overflow-y: scroll;">  
		            	<div id="accordion" class="small">
		            		<div id="ClassAccordion">
						        <button class="btn btn-link" data-toggle="collapse" data-target="#collapseClass" aria-expanded="true" aria-controls="collapseOne">
						          <xsl:text>Class</xsl:text>
						        </button>
						    </div>
		            		<div id="collapseClass" class="collapse show" aria-labelledby="ClassAccordion" data-parent="#accordion" >
						      	<ul>
						      		<xsl:for-each-group select="//rdfs:Class[@rdf:about][not(rdfs:subClassOf[contains(text(),  'http://www.cidoc-crm.org/')])]" group-by="(@rdf:about)" >
						      			<li>
						      				<a href="#{substring-after(current-grouping-key(), '#')}" onclick="scrolldown(this)">
									    		<xsl:value-of select="rdfs:label[@xml:lang='en']"/>
								  			</a>
						      			</li>
						      		</xsl:for-each-group>
								</ul>
						    </div>
		            		<div id="PropertyAccordion">
						        <button class="btn btn-link" data-toggle="collapse" data-target="#collapseProperty" aria-expanded="true" aria-controls="collapseOne">
						          <xsl:text>Property</xsl:text>
						        </button>
						    </div>
		            		<div id="collapseProperty" class="collapse" aria-labelledby="PropertyAccordion" data-parent="#accordion">
						      	<ul>
						      		 <xsl:for-each-group select="//rdf:Property[@rdf:about]" group-by="(@rdf:about)">
						      		 	<li>
						      		 		<a href="#{substring-after(current-grouping-key(), '#')}" onclick="scrolldown(this)">
									    		<xsl:value-of select="rdfs:label[@xml:lang='en']"/>
								  			</a>
						      		 	</li>
						      		 </xsl:for-each-group>
						      	</ul>
						    </div>
		            	</div>
		            </div>
	    		</div>
	    	</div>
	    	<div class="col-md-10">
	    	<div class="card">
	            <div class="card-body">    
	                <h1 class="card-title">
	                    <xsl:value-of select="rdf:RDF/owl:Ontology/dc:title"/>
	                </h1>
			        <div class="row">
			            <div class="col">
			                <p>
			                    <xsl:value-of select="rdf:RDF/owl:Ontology/owl:versionInfo"/>
			                </p>
			                <p class="card-text">
			                    <xsl:value-of select="rdf:RDF/owl:Ontology/dc:description"/>
			                </p>
			            </div>
			        </div>
	                <!-- ///////////////////////////////////////////////////////////// -->
	                <!-- CONTENT-->
	                <div class="col-md-12" id="Classes" style="margin-top:50px">
	                    <h1>Classes</h1>
	                    <!-- CLASSES without CIDOC-superclass -->
	                    <xsl:for-each-group select="//rdfs:Class[@rdf:about][not(rdfs:subClassOf[contains(text(),  'http://www.cidoc-crm.org/')])]" group-by="(@rdf:about)" >
	                        <h3 id="{substring-after(current-grouping-key(), '#')}">
	                            <xsl:value-of select="rdfs:label[@xml:lang='en']"/>
	                        </h3>
	                        <!-- create TABLE for current class -->
	                        <xsl:call-template name="createTable"/>
	                        <!-- for each SUBCLASSES of the current class -->
	                        <xsl:if test="//rdfs:Class[@rdf:about][rdfs:subClassOf/@rdf:resource = current-grouping-key()]">
	                            <xsl:for-each-group select="//rdfs:Class[@rdf:about][rdfs:subClassOf/@rdf:resource = current-grouping-key()]" group-by="(@rdf:about)" >
	                                    <h3 id="{substring-after(current-grouping-key(), '#')}">
	                                        <xsl:value-of select="rdfs:label[@xml:lang='en']"/>
	                                    </h3>
	                                    <xsl:call-template name="createTable"/>
	                            </xsl:for-each-group>
	                        </xsl:if>
	                    </xsl:for-each-group>
	                </div>
	                <!-- ///////////////////////////////////////////////////////////// -->
	                <div class="col-md-12" id="Properties" style="margin-top:50px">
	                    <h1>Properties</h1>
	                        <!-- CLASSES without CIDOC-superclass -->
	                        <xsl:for-each-group select="//rdf:Property[@rdf:about]" group-by="(@rdf:about)">
	                            <div  style="padding-bottom:10px">
	                                <h3 id="{substring-after(current-grouping-key(), '#')}">
	                                    <xsl:value-of select="rdfs:label[@xml:lang='en']"/>
	                                </h3>
	                                <!-- create Table -->
	                                <xsl:call-template name="createTable"/>
	                            </div>
	                        </xsl:for-each-group>
	                </div>
	                <!-- ///////////////////////////////////////////////////////////// -->
	                <div class="row" id="Visualisation" style="margin-top:50px">
	                    <h1>Visualisation</h1>
	                    <embed 
	                        src="http://visualdataweb.de/webvowl/#iri=http://glossa.uni-graz.at/archive/objects/o:medea.bookkeeping/datastreams/ONTOLOGY/content"
	                        height="1000px"
	                        width="100%"/>
	                </div>      
	        	</div>
	        </div>
	    </div>
    </div>
    </xsl:template>
    
    <!-- ///////////////////////////////////////////////////////////// -->
    <!-- createTable -->
    <xsl:template name="createTable">
        <div class="table-responsive">
        <table class="table table-bordered" id="{current-grouping-key()}">
            <tbody>
                <xsl:if test="rdfs:subClassOf">
                    <tr class="d-flex">
                        <td class="col-md-2" style="font-weight: bold;">Subclass of</td>
                        <td class="col-md-10">
                        	<xsl:for-each select="rdfs:subClassOf/@rdf:resource">
                        		<a href="{.}">
                        			<xsl:choose>
                        				<xsl:when test="contains(., 'cidoc-crm')">
                        				    <xsl:value-of select="substring-after(., 'cidoc-crm/')"/>
                        				</xsl:when>
                        				<xsl:otherwise>
                        					<xsl:variable name="currentClass" select="."/>
                        					<xsl:value-of select="//rdfs:Class[@rdf:about = $currentClass]/rdfs:label[@xml:lang='en']"/>
                        				</xsl:otherwise>
                        			</xsl:choose></a>
                        		<br/>
                        	</xsl:for-each>
                            
                        </td>
                    </tr>
                </xsl:if>
                <tr class="d-flex">
                    <td class="col-md-2" style="font-weight: bold;">Description</td>
                    <td class="col-md-10">
                        <xsl:value-of select="rdfs:comment[@xml:lang='en']"/>
                    </td>
                </tr>
                <xsl:if test="skos:example">
                    <tr class="d-flex">
                     <td class="col-md-2" style="font-weight: bold;">Usage</td>
                     <td class="col-md-10">
                         <xsl:call-template name="createExample"/>
                     </td>
                 </tr>
                </xsl:if>
                <xsl:if test="rdfs:seeAlso/@rdf:resource">
                    <tr class="d-flex">
                    <td class="col-md-2" style="font-weight: bold;">seeAlso</td>
                    <td class="col-md-10">
                        <xsl:for-each select="rdfs:seeAlso/@rdf:resource">
                            <a href="{.}" target="_blank">
                                <xsl:value-of select="substring-before(substring-after(.,'.'), '/')"/>
                            </a>
                        </xsl:for-each>
                    </td>
                </tr>
                </xsl:if>
               
                <xsl:variable name="Domain" select="rdfs:domain/@rdf:resource | //rdf:Property[rdfs:domain/@rdf:resource = current-grouping-key()]"/>
                    <xsl:if test="$Domain">
                        <tr class="d-flex">
                            <td class="col-md-2" style="font-weight: bold;">Domain</td>
                            <td class="col-md-10"> 
                             <xsl:for-each select="//rdfs:Class[@rdf:about = $Domain]/rdfs:label[@xml:lang='en']">
                                 <a href="{concat('#', translate(.,' ',''))}" onclick="scrolldown(this)" style="margin-right: 40px;"><xsl:value-of select="."/></a><xsl:text> </xsl:text>
                             </xsl:for-each>
                            <xsl:for-each select="$Domain/rdfs:label[@xml:lang='en']">
                                <a href="{concat('#', translate(.,' ',''))}" onclick="scrolldown(this)" style="margin-right: 40px;"><xsl:value-of select="."/></a><xsl:text> </xsl:text>
                            </xsl:for-each>
                         </td>
                        </tr>
                    </xsl:if>
                <xsl:variable name="Range" select="rdfs:range/@rdf:resource | //rdf:Property[rdfs:range/@rdf:resource = current-grouping-key()]"/>
                <xsl:if test="$Range">
                    <tr class="d-flex">
                        <td class="col-md-2" style="font-weight: bold;">Range</td>
                        <td class="col-md-10">
                            <xsl:choose>
                                <xsl:when test="//rdfs:Class[@rdf:about = $Range]/rdfs:label[@xml:lang='en']">
                                    <xsl:for-each select="//rdfs:Class[@rdf:about = $Range]/rdfs:label[@xml:lang='en']">
                                        <a href="{concat('#', translate(.,' ',''))}" onclick="scrolldown(this)" style="margin-right: 40px;"><xsl:value-of select="."/></a><xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:when test="$Range/rdfs:label[@xml:lang='en']">
                                    <xsl:for-each select="$Range/rdfs:label[@xml:lang='en']">
                                        <a href="{concat('#', translate(.,' ',''))}" onclick="scrolldown(this)" style="margin-right: 40px;"><xsl:value-of select="."/></a><xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="$Range">
                                        <a href="{.}" style="margin-right: 40px;">
                                            <xsl:value-of select="substring-after(., '#')"/>
                                        </a>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                            
                        </td>
                    </tr>
                </xsl:if>
            </tbody>
        </table>
      </div>
    </xsl:template>
    
    <!-- ///////////////////////////////////////////////////////////// -->
    <!-- createExample -->
    <xsl:template name="createExample">
        <h4 style="font-weight: bold;">TEI</h4>
        <xsl:for-each select="skos:example[@rdf:parseType = 'Literal']">
            <div class="well">
                <xsl:apply-templates select="./element()"/>
            </div>
        </xsl:for-each>
    	<h4 style="font-weight: bold;">RDF</h4>
    	<xsl:for-each select="skos:example[not(@rdf:parseType)]">
            <div class="well">
                <xsl:for-each select="tokenize(., ';')">
                    <xsl:analyze-string select="." regex="&lt;|&gt;">
                        <xsl:matching-substring>
                            <span style="font-weight: bold; color:blue;">
                                <xsl:value-of select="."/>
                            </span>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:analyze-string select="." regex="bk:\w+">
                                <xsl:matching-substring>
                                    <span style="color:blue;">
                                        <xsl:value-of select="."/>
                                    </span>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:value-of select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                    <xsl:if test="not(position()=last())">
                        <xsl:text>;</xsl:text>
                    </xsl:if><br/>
                </xsl:for-each>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <!-- ///////////////////////////////////////////////////////////// -->
    <!-- element has  @ -->
    <!-- styles all elements with attributes for examples and usage -->
    <xsl:template match="element()[@*]">
        <span style="color:blue;"><xsl:text>&lt;</xsl:text><xsl:value-of select="name()"/><xsl:text> </xsl:text></span>
        <xsl:for-each select="@*">
            <span style="color:orange;"><xsl:value-of select="name(.)"/>
                <xsl:text> = </xsl:text>
            </span>
            <span style="color:rgb(150, 0, 0);"><xsl:text>"</xsl:text>
            <xsl:value-of select="."/><xsl:text>" </xsl:text></span>
        </xsl:for-each>
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates></xsl:apply-templates>
        <span style="color:blue;"><xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text></span>
    </xsl:template>
    
    <!-- ///////////////////////////////////////////////////////////// -->
    <!-- element has no @ -->
    <!-- styles all elements without attributes for examples and usage -->
    <xsl:template match="element()">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- ///////////////////////////////////////////////////////////// -->
    <!-- for every CSV-Example -->
    <xsl:template match="skos:example[not(@rdf:parseType)]">
        <div class="well">
        <b><xsl:value-of select="substring-before(., ' ')"/></b><br/>
        <xsl:value-of select="substring-after(., ' ')"/>
        </div>
        <xsl:text> </xsl:text>
    </xsl:template>
    
</xsl:stylesheet>