<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:functx="http://www.functx.com"
    xmlns:gn="http://www.geonames.org/ontology#" 
    xmlns:gams="https://gams.uni-graz.at/o:gams-ontology/#"
    xmlns:om="http://www.ontology-of-units-of-measure.org/resource/om-2/"
    xmlns:bk="https://gams.uni-graz.at/o:depcha.bookkeeping#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:t="http://www.tei-c.org/ns/1.0">
    <xsl:strip-space elements="*"/>
    

    <!--<xsl:include href="https://gams.uni-graz.at/gamsdev/pollin/depcha/trunk/www/depcha-templates.xsl"/>-->
    <!-- VARIABLES -->   
    <!-- //////////////////////////////// -->
    <!-- global Variables -->
    <xsl:variable name="TEIHeader" select="//t:teiHeader"/>
	<xsl:variable name="TEI" select="/"/>
    <xsl:variable name="Currrent_TEI_PID" select="//t:publicationStmt/t:idno[@type = 'PID']"/>
    <xsl:variable name="Currrent_Context">
        <xsl:choose>
            <xsl:when test="contains($TEIHeader//t:ref[@type = 'context']/@target, 'info:fedora/')">
                <xsl:value-of select="substring-after($TEIHeader//t:ref[@type = 'context']/@target, 'info:fedora/')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$TEIHeader//t:ref[@type = 'context']/@target"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- BK URI -->
    <xsl:variable name="BK_URI">
        <xsl:choose>
            <xsl:when test="//t:listPrefixDef/t:prefixDef/@ident = 'bk'">
                <xsl:value-of select="substring-before(//t:listPrefixDef/t:prefixDef/@replacementPattern, '$')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>bk prefix Def missing</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="BASE-URL" select="'https://gams.uni-graz.at/'"/>

    <!-- ////////////////////////// -->
    <!-- check PID -->
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:choose>
                <xsl:when test="$Currrent_TEI_PID">
                    <!-- COLLECTION rdf:about -->
                    <!--<xsl:for-each select="//t:teiHeader//*[@type='context']">
                        <xsl:variable name="MEASURES" select="//t:measure"/>
                        
                        <bk:DataSet rdf:about="{concat($BASE-URL, //t:teiHeader//*[@type='context']/@target)}">
                            <bk:name>
                                <xsl:value-of select="."/>
                            </bk:name>
                            <!-\- sum of all monetary values -\->
                            <xsl:variable name="Sum">
                                <xsl:variable name="Dollar" select="sum($MEASURES[@unit='dollars']/@quantity)"/>
                                <xsl:variable name="Cents" select="sum($MEASURES[@unit='cents']/@quantity) div 100"/>
                                <xsl:value-of select="number($Dollar) + number($Cents)"/>
                            </xsl:variable>
                            <bk:sum><xsl:value-of select="$Sum"/></bk:sum>
                            <!-\- COMMODITIES -\->
                            <xsl:for-each-group select="$MEASURES[contains(@ana, 'bk:commodity')]" group-by="@commodity">
                                <xsl:variable name="Type" select="current-grouping-key()"/>
                                <xsl:variable name="Count" select="count(current-group())"/>
                                <xsl:for-each-group select="current-group()" group-by="@unit">
                                    <bk:distinctCommodity>
                                        <bk:type><xsl:value-of select="$Type"/></bk:type>
                                        <bk:unit><xsl:value-of select="current-grouping-key()"/></bk:unit>
                                        <!-\- summe für die current unit -\->
                                        <bk:sum><xsl:value-of select="sum(current-group()/@quantity)"/></bk:sum>
                                        <!-\- wie oft es im dokument genannt wird -\->
                                        <bk:count><xsl:value-of select="$Count"/></bk:count>
                                        <bk:maincategory>Commodity</bk:maincategory>
                                        <xsl:call-template name="fakeCategory">
                                            <xsl:with-param name="Type" select="$Type"/>
                                        </xsl:call-template>
                                    </bk:distinctCommodity>
                                </xsl:for-each-group>
                            </xsl:for-each-group>
                            <!-\- SERVICE -\->
                            <xsl:for-each-group select="$MEASURES[contains(@ana, 'bk:service')]" group-by="@commodity">
                                <xsl:variable name="Type" select="current-grouping-key()"/>
                                <xsl:variable name="Count" select="count(current-group())"/>
                                <bk:distinctCommodity>
                                    <type><xsl:value-of select="$Type"/></type>
                                    <bk:count><xsl:value-of select="$Count"/></bk:count>
                                    <bk:maincategory>Service</bk:maincategory>
                                </bk:distinctCommodity>
                            </xsl:for-each-group>
                        </bk:DataSet>
                    </xsl:for-each>-->
                    
                    <xsl:apply-templates select="//t:text//*[tokenize(@ana, ' ') = 'bk:entry']"/>
                    
                    <!-- BETWEEN rdf:about -->
                    <!--<xsl:choose>
                        <!-\- if there is a list of person in the TEI -\->
                        <xsl:when test="//t:listPerson">
                            
                            
                        </xsl:when>
                    </xsl:choose>-->
                    <xsl:for-each-group select="//.[tokenize(@ana, ' ') = 'bk:to'][not(local-name() ='measure')] | //.[tokenize(@ana, ' ') = 'bk:from'][not(local-name() ='measure')]" group-by=".//@ref | .//@corresp">
	            	    <xsl:variable name="Between-URI">
	            	        <xsl:choose>
	            	            <xsl:when test="contains(current-grouping-key(), '#')">
	            	                <xsl:value-of select="concat($BASE-URL, $Currrent_TEI_PID, current-grouping-key())"/>
	            	            </xsl:when>
	            	            <xsl:otherwise>
	            	                <xsl:value-of select="concat($BASE-URL, $Currrent_TEI_PID, '#', current-grouping-key())"/>
	            	            </xsl:otherwise>
	            	        </xsl:choose>
	            	    </xsl:variable>
                        <!-- TODO -->
                        <!--<xsl:choose>
                            <xsl:when test="$TEIHeader//t:listPerson[@ana='bk:Between']">
                                <xsl:for-each select="t:person">
                                    <xsl:variable name="Between-URI"/>
                                    <bk:Between rdf:about="{$Between-URI}">
                                </xsl:for-each>
                            </xsl:when>
                        </xsl:choose>-->
                        <bk:Between rdf:about="{$Between-URI}">
	            	    	<xsl:for-each-group select="current-group()" group-by="current-grouping-key()">
				    			<bk:name>
				    			    <xsl:value-of select="."/>
				    				<!-- here is the place for further normalizing of the data -->
				    				<xsl:choose>
				    					<xsl:when test="@corresp">
				    						<xsl:value-of select="$TEIHeader//t:taxonomy//*[@xml:id = substring-after(current-grouping-key(), '#')]"/>
				    					</xsl:when>
				    				    <xsl:when test=".//@ref">
				    				        <xsl:value-of select="$TEIHeader//t:taxonomy//*[@xml:id = substring-after(current-grouping-key(), '#')]"/>
				    				    </xsl:when>
				    					<xsl:otherwise>
				    						<xsl:value-of select="."/>
				    					</xsl:otherwise>
				    				</xsl:choose>				    				
				    		     </bk:name>
				    		</xsl:for-each-group>
				    	</bk:Between>
	            	</xsl:for-each-group>
                    
                    <!-- ////////////////////////// -->
                    <!-- bk:Taxonomy to SKOS -->
                    <xsl:choose>
                        <xsl:when test="$TEIHeader//*[tokenize(@ana, ' ') = 'bk:Taxonomy']">
                            <xsl:apply-templates select="$TEIHeader//*[tokenize(@ana, ' ') = 'bk:Taxonomy']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:comment>No bk:Taxonomy defined</xsl:comment>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    
                    <xsl:for-each select="//t:unitDef">
                        <om:Unit rdf:about="{concat($BASE-URL, $Currrent_TEI_PID, '#', @xml:id)}">
                            <rdfs:label>
                                <xsl:value-of select="t:label"/>
                            </rdfs:label>
                        </om:Unit>
                    </xsl:for-each>
                    
                </xsl:when>
                <xsl:otherwise>
                	<xsl:text>ERROR: No PID defined in idno/@type="PID"</xsl:text>
                </xsl:otherwise>
            </xsl:choose>   
        </rdf:RDF>
    </xsl:template>
    
    
    <!-- ////////////////////////// -->
    <!--  -->
    <xsl:template match="*[tokenize(@ana, ' ') = 'bk:Taxonomy']">
        <skos:ConceptScheme rdf:about="{concat($BASE-URL, $Currrent_TEI_PID)}">
            <xsl:if test="t:gloss">
                <dc:title>
                    <xsl:value-of select="normalize-space(t:gloss)"/>
                </dc:title>
            </xsl:if>
            <xsl:if test="t:desc">
                <dc:description>
                    <xsl:value-of select="normalize-space(t:desc)"/>
                </dc:description>
            </xsl:if>
            <!-- hasTopConcepts -->
            <xsl:for-each select="t:category">
                <skos:hasTopConcept rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID, '#', @xml:id)}"/>
            </xsl:for-each>
        </skos:ConceptScheme>
        <xsl:apply-templates select="t:category"/>
    </xsl:template>
    
    <!-- ////////////////////////// -->
    <!--  -->
    <xsl:template match="t:category">
        <skos:Concept rdf:about="{concat($BASE-URL, $Currrent_TEI_PID, '#', @xml:id)}">
            <skos:inScheme rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID, '#')}"/>
            <xsl:for-each select="t:category">
                <skos:narrower rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID, '#', @xml:id)}"/>
            </xsl:for-each>
            <xsl:for-each select="parent::t:category">
                <skos:broader rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID, '#', @xml:id)}"/>
            </xsl:for-each>
            <xsl:if test="t:gloss">
                <skos:prefLabel>
                    <xsl:value-of select="normalize-space(t:gloss)"/>
                </skos:prefLabel>           
            </xsl:if>
            <xsl:if test="t:gloss/t:ref/@target">
                <!-- here get the prefix for wikidata -->
                <skos:relatedMatch rdf:resource="{t:gloss/t:ref/@target}"/>
            </xsl:if> 
        </skos:Concept>
        <xsl:apply-templates select="t:category"/>
    </xsl:template>
    
    

    
    <!-- ////////////////////////// -->
	<!-- bk_Entry -->
    <!-- goes through all Entries in a given TEI. Entries must be defined with @ana='bk:entry'. -->
    <xsl:template match="t:text//*[tokenize(@ana, ' ') = 'bk:entry']">
        <xsl:variable name="Position" select="count(preceding::node()[tokenize(@ana, ' ') = 'bk:entry'])"/>
        
        <!-- /////////// -->
        <!-- bk_Where -->
        <!-- todo -->
        
        <!-- /////////// -->
        <!--  BK:FROM -->
        <xsl:variable name="bk_From">
            <xsl:call-template name="getFromTO">
                <xsl:with-param name="Direction" select="'bk:from'"/>
            </xsl:call-template>
        </xsl:variable>
        <!--  BK:TO @ref -->
        <xsl:variable name="bk_From_ref">
            <xsl:call-template name="getFromTO_ref">
                <xsl:with-param name="Direction" select="'bk:from'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- /////////// -->
        <!-- BK:TO -->
        <xsl:variable name="bk_To">
            <xsl:call-template name="getFromTO">
                <xsl:with-param name="Direction" select="'bk:to'"/>
            </xsl:call-template>
        </xsl:variable>
        <!--  BK:TO @ref -->
        <xsl:variable name="bk_To_ref">
            <xsl:call-template name="getFromTO_ref">
                <xsl:with-param name="Direction" select="'bk:to'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- /////////// -->
        <!-- bk_Agent -->
        <xsl:variable name="bk_Agent">
        	<xsl:choose>
        		<xsl:when test=".//.[tokenize(@ana, ' ') = 'bk:agent']">
        			<xsl:value-of select=".//.[tokenize(@ana, ' ') = 'bk:agent']"/>
        		</xsl:when>
        		<xsl:otherwise/>
        	</xsl:choose>
        </xsl:variable>
    	<xsl:variable name="bk_Agent-ID">
    		<xsl:choose>
        		<xsl:when test=".//.[tokenize(@ana, ' ') = 'bk:agent']/@ref">
        		    <xsl:call-template name="getRefwithHash">
        		        <xsl:with-param name="Path" select=".//.[tokenize(@ana, ' ') = 'bk:agent']/@ref"/>
        		    </xsl:call-template> 
        		</xsl:when>
        		<xsl:otherwise/>
        	</xsl:choose>
        </xsl:variable>
        
        <!-- /////////// -->
        <!-- TRANSACTION -->
        <xsl:variable name="Transaction-ID" select="concat($BASE-URL, $Currrent_TEI_PID, '#T',  $Position)"/>
        <!-- | .//.[tokenize(@ana, ' ') = 'bk:price'] -->
        <xsl:variable name="bk_Measurables" select=".//.[tokenize(@ana, ' ') = 'bk:money'] | .//.[tokenize(@ana, ' ') = 'bk:service'] | .//.[tokenize(@ana, ' ') = 'bk:commodity']"/>
        <xsl:variable name="bk_Between_REF" select="$bk_To_ref | $bk_From_ref"/>
        
        <bk:Transaction rdf:about="{$Transaction-ID}">
            <!-- for each bk_measurable grouped by @commodity: there is a transfer for all bk_measurable entities. $ + sh are in the same transfer -->
            <xsl:for-each-group select="$bk_Measurables" group-by="@ana">
                <xsl:variable name="Transfer-ID" select="concat($Transaction-ID, 'T', position())"/>
                <bk:consistsOf rdf:resource="{$Transfer-ID}"/>
            </xsl:for-each-group>
            
            <!-- /////////// -->
            <!-- bk:when -->
                <xsl:choose>
                    <!-- bk_ in entry -->
                    <xsl:when test=".//.[@ana = 'bk:when'][1]/@when">
                        <bk:when>
                            <xsl:value-of select=".//.[@ana = 'bk:when'][1]/@when"/>
                        </bk:when>
                    </xsl:when>
                    <!-- if a <head> is before containing bk_when -->
                    <xsl:when test="preceding::t:head[1]//.[tokenize(@ana, ' ') = 'bk:when']/@when">
                        <bk:when>
                            <xsl:value-of select="preceding::t:head[1]//.[tokenize(@ana, ' ') = 'bk:when']/@when"/>
                        </bk:when>
                    </xsl:when>
                    <xsl:when test="preceding::t:date[@ana='bk:when'][1]/@when">
                        <bk:when>
                            <xsl:value-of select="preceding::t:date[@ana='bk:when'][1]/@when"/>
                        </bk:when>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
           
           <!-- /////////// -->
           <!-- transactionStatus pp. ; in full -->
             <xsl:for-each select=".//.[tokenize(@ana, ' ') = 'bk:status']">
                <bk:status>
                  <xsl:value-of select="."/>
                </bk:status>
            </xsl:for-each>
            
            <!-- /////////// -->
            <!-- entry-->
            <bk:entry>
                <xsl:for-each select=".//text()">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="not(position() = last())">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </bk:entry>
                        
           <!-- connect every Transaction to a Collection (like context:depcha.wheaton) -->
            <xsl:for-each select="//t:teiHeader//*[@type='context']">
                <gams:isMemberOfCollection rdf:resource="{concat($BASE-URL, $Currrent_Context)}"/>
            </xsl:for-each>
            
            <!-- partOfTEI -->
            <gams:isPartofTEI rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID)}"/>
           
         <!-- ////////////////////////// -->
         <!-- FULLTEXT for fulltextsearch with whitespace cleaning and normalization -->
    	<gams:textualContent>
        	<xsl:for-each select=".//text()">
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
    		<!-- add FROM, TO -->
    		<!-- TODO -->
    		<!--<xsl:for-each-group select="$bk_Between_REF" group-by=".">
	    		<xsl:for-each select="distinct-values($TEI//.[@ref = current-grouping-key()])">
	    				<xsl:value-of select="."/><xsl:text> </xsl:text>
	    		</xsl:for-each>	    	
    		</xsl:for-each-group>-->
    		<xsl:for-each-group select="$bk_Measurables" group-by="@ana">
    			 <xsl:value-of select="@quantity"/>
    			 <xsl:text> </xsl:text>
    			 <xsl:value-of select="@unit"/>
    			 <xsl:text> </xsl:text>
    			 <xsl:if test="not(@commodity ='currency')">
    			 	<xsl:value-of select="@commodity"/>
    			 	<xsl:text> </xsl:text>
    			 </xsl:if>
    		</xsl:for-each-group>
    		<xsl:if test="$bk_From">
	    		<xsl:value-of select="$bk_From"/>
    		</xsl:if>
    		<xsl:if test="$bk_To">
	    		<xsl:value-of select="$bk_To"/>
    		</xsl:if>
    		<xsl:if test="not($bk_Agent = '')">
    			<xsl:value-of select="$bk_Agent"/>
    		</xsl:if>
    	</gams:textualContent>
    </bk:Transaction>
    <!-- END TRANSACTON -->
        
        <!-- /////////// -->
        <!-- TRANSFERS -->
        <xsl:for-each-group select="$bk_Measurables" group-by="@ana">
            <xsl:variable name="Transfer-ID" select="concat($Transaction-ID, 'T', position())"/>
            <xsl:variable name="Measurable-ID" select="concat($BASE-URL, $Currrent_TEI_PID,  '#E',  $Position, 'M', position())"/>
            <bk:Transfer rdf:about="{$Transfer-ID}">  
                <!-- ////////////////////////////////////// -->
                <xsl:choose>
                    <xsl:when test="count(current-group()) > 1">
                        <xsl:for-each select="current-group()">
                            <bk:transfers rdf:resource="{concat($Measurable-ID, position())}"/>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <bk:transfers rdf:resource="{$Measurable-ID}"/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- bk_to; bk_from -->
                <!-- additional bk_to  ana="bk:money bk:to" defines to whom the measurable belongs   -->
                <xsl:choose>
                    <!-- CASE, this is turned arround  -->
                    <xsl:when test="contains(@ana,  'bk:to')">
                        <bk:from rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID,  $bk_To_ref)}"/>
                        <bk:to rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID,  $bk_From_ref)}"/>
                    </xsl:when>
                    <!-- CASE -->
                    <xsl:when test="contains(@ana, 'bk:from')">
                        <bk:from rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID,  $bk_From_ref)}"/>
                        <bk:to rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID,  $bk_To_ref)}"/>
                    </xsl:when>
                    <xsl:otherwise>
                       <xsl:comment>Error: problem identifying bk:to; bk:from; bk:Agent. The @ana need further bk:to bk:from like measure ana="bk:money bk:to"</xsl:comment>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- /////////// -->
                <!-- bk:by bk:Agent, if the <masure @ana> conains a  bk:agent the connection to the bk_Agent is build-->
                <xsl:if test="contains(current-grouping-key(), 'bk:agent')">
                    <bk:by rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID, 'A',  $Position, $bk_Agent-ID)}"/>
                </xsl:if>
                
            </bk:Transfer>
        </xsl:for-each-group>
    	<!-- END TRANSFER -->
        
        <!-- /////////// -->
        <!-- MEASURABLES -->
        <xsl:for-each-group select="$bk_Measurables" group-by="@ana">
            <xsl:variable name="Measurable-ID" select="concat($BASE-URL, $Currrent_TEI_PID,  '#E',  $Position, 'M', position())"/>
            <xsl:choose>
                <xsl:when test="contains(@ana, 'bk:money') or contains(@ana, 'bk:service') or contains(@ana, 'bk:commodity')">
                    <xsl:variable name="firstChar" select="upper-case(substring(substring-after(@ana, ':'),1,1))"/>
                    <xsl:variable name="SubClassofMeasurables">
                        <xsl:choose>
                            <!-- if @ana="bk:money bk:to" -->
                            <xsl:when test="contains(@ana, ' ')">
                                <xsl:value-of select="substring-before(concat($firstChar, substring(substring-after(@ana, ':'), 2),' '[not(last())]), ' ')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($firstChar, substring(substring-after(@ana, ':'), 2),' '[not(last())])"/> 
                            </xsl:otherwise>
                        </xsl:choose> 
                    </xsl:variable>
                    <!-- create bk:Money, bk:Commodity, bk_Service -->
                    <xsl:choose>
                        <!-- more than 1 measure, like 1 dollar 50 cents -->
                        <xsl:when test="count(current-group()) > 1">
                            <xsl:for-each select="current-group()">
                                <xsl:element name="{concat('bk:', $SubClassofMeasurables)}">
                                    <xsl:attribute name="rdf:about" select="concat($Measurable-ID, position())"/>
                                    <xsl:if test="@unit"> 
                                        <xsl:call-template name="getUnit"/>
                                    </xsl:if>
                                    <xsl:if test="@quantity">
                                        <xsl:call-template name="getQuantity"/>
                                    </xsl:if>
                                    <xsl:if test="@commodity and not(@commodity = 'currency')">
                                        <xsl:call-template name="getCommodity"/>
                                    </xsl:if>
                                    <!--<bk:text>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </bk:text>-->
                                    <xsl:for-each-group select=".//.[tokenize(@ana, ' ') = 'bk:price']" group-by=".">
                                    <xsl:variable name="Price-ID" select="concat($BASE-URL, $Currrent_TEI_PID,  '#E', $Position, 'P', position())"/>
                                    <bk:price rdf:resource="{$Price-ID}"/>
                                    </xsl:for-each-group>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:when>
                        <!-- 1 measure -->
                        <xsl:otherwise>
                            <xsl:element name="{concat('bk:', $SubClassofMeasurables)}">
                                <xsl:attribute name="rdf:about" select="$Measurable-ID"/>
                                <xsl:if test="@unit">
                                    <bk:unit>
                                        <xsl:value-of select="@unit"/>
                                    </bk:unit>
                                </xsl:if>
                                <!-- /// -->
                                <xsl:call-template name="getQuantity"/>
                                <xsl:if test="@commodity and not(@commodity = 'currency')">
                                    <bk:commodity>
                                        <xsl:value-of select="@commodity"/>
                                    </bk:commodity>
                                	<xsl:variable name="DBpediaTerm">
                                		<xsl:choose>
                                			<xsl:when test="contains(@commodity, ' ')">
                                				<!-- Potatoe, pine wood = Pine -->
                                				<xsl:value-of select="concat(upper-case(substring(substring-before(@commodity, ' '),1,1)), substring(substring-before(@commodity, ' '),2))"/>
                                			</xsl:when>
                                			<xsl:otherwise>
                                				<xsl:value-of select="concat(upper-case(substring(@commodity,1,1)), substring(@commodity,2))"/>
                                			</xsl:otherwise>
                                		</xsl:choose>
                                	</xsl:variable>
                                	<rdfs:seeAlso rdf:resource="{concat('https://dbpedia.org/resource/', $DBpediaTerm)}"/>
                                </xsl:if>
                            	<!-- wikidata reference in TEI -->
                            	<xsl:for-each select="tokenize(@ana, ' ')">
                            		<xsl:if test="contains(., '#wiki_')">
                            			<!-- rdfs:seeAlso !!! todo rdfs:namepsace -->
                            			<rdfs:seeAlso rdf:resource="{concat('https://www.wikidata.org/wiki/', substring-after(., '#wiki_'))}"/>
                            		</xsl:if>
                            	</xsl:for-each>                            	
                            	<!--<bk:text>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </bk:text>-->
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:comment>ERROR: Failed to create bk:Measurable: missing @ana;</xsl:comment>
                </xsl:otherwise>
            </xsl:choose> 
        </xsl:for-each-group>
        
        <!-- PRICE -->
       <!-- <xsl:for-each-group select=".//.[tokenize(@ana, ' ') = 'bk:price']" group-by=".">
            <xsl:variable name="Price-ID" select="concat($BASE-URL, $Currrent_TEI_PID,  '#E', $Position, 'P', position())"/>
            <bk:Price rdf:about="{$Price-ID}">
                <xsl:if test="@unit">
                    <bk:unit>
                        <xsl:value-of select="@unit"/>
                    </bk:unit>
                </xsl:if>
                <xsl:if test="@quantity">
                    <bk:quantity>
                        <xsl:value-of select="@quantity"/>
                    </bk:quantity>
                </xsl:if>
                <xsl:if test="@commodity and not(@commodity = 'currency')">
                    <bk:commodity>
                        <xsl:value-of select="@commodity"/>
                    </bk:commodity>
                </xsl:if>
                <bk:text>
                    <xsl:value-of select="normalize-space(.)"/>
                </bk:text>
            </bk:Price>
            
            
        </xsl:for-each-group>-->
        
    	<!-- END MEASURABLE-->
    	
    	<!-- /////////// -->
        <!-- BETWEEN -->
    	<!--<xsl:for-each-group select="$bk_Between_REF" group-by=".">
	    	<bk:Between rdf:about="{concat($BASE-URL, $Currrent_TEI_PID, '#E', $Position, current-grouping-key())}">
	    		<xsl:for-each select="distinct-values($TEI//.[@ref = current-grouping-key()])">
	    			<bk:name>
	    				<xsl:value-of select="."/>
	    		     </bk:name>
	    		</xsl:for-each>
	    	</bk:Between>
    	</xsl:for-each-group>-->
        
        <!-- /////////// -->
        <!-- Agent -->
        <xsl:if test="not($bk_Agent = '')">
        <xsl:for-each-group select="$bk_Agent" group-by=".">
            <bk:Agent rdf:about="{concat($BASE-URL, $Currrent_TEI_PID, 'A',  $Position, $bk_Agent-ID)}">
                    <bk:name>
                        <xsl:if test="./@ref = $bk_Agent-ID">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </bk:name>
            </bk:Agent>
        </xsl:for-each-group>
        </xsl:if>
  
    </xsl:template>

    <!-- ////////////////////////////////////////////////////////////////////// -->
    <!-- ////////////////////////////////////////////////////////////////////// -->
    <!-- CALLED TEMPLATES -->

   <!-- ////////////////////////// -->
   <!-- bk:Between -->
   <!-- <xsl:template name="Between">
        <xsl:param name="Between-ID"/>
        <xsl:param name="bk_to"/>
        <xsl:param name="bk_from"/>
        <xsl:for-each select="$bk_to">
            <bk:Between>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="concat($Between-ID, $bk_from)"/>
                </xsl:attribute>
            </bk:Between>
            <bk:Between>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="concat($Between-ID, $bk_to)"/>
                </xsl:attribute> 
            </bk:Between>
        </xsl:for-each>
    </xsl:template>
    -->
    <!-- this template gets "bk_from" or bk_to as parameter an gets through some cases in TEI files where this @ana from or to can exist  -->
    <xsl:template name="getFromTO">
        <xsl:param name="Direction"/>
        <xsl:choose>
            <!-- inside the current entry -->
            <xsl:when test=".//.[tokenize(@ana, ' ') = $Direction][not(local-name() ='measure')]">
                <xsl:value-of select=".//.[tokenize(@ana, ' ') = $Direction][not(local-name() ='measure')]"/>
            </xsl:when>
            <!-- if there is no bk_from in the current entry and in the header go to the first preceding-sibling and look for a bk_to -->
            <xsl:when test="preceding-sibling::*[not(tokenize(@ana, ' ') = 'bk:entry')][1]//*[@ana=$Direction]">
                <xsl:value-of select="preceding-sibling::*[not(tokenize(@ana, ' ') = 'bk:entry')][1]//*[@ana=$Direction]"/>
            </xsl:when>
            <xsl:when test="preceding::*[tokenize(@ana, ' ') = $Direction][1]">
                <xsl:call-template name="getRefwithHash">
                    <xsl:with-param name="Path" select="preceding::*[tokenize(@ana, ' ') = $Direction][1]"/>
                </xsl:call-template>
            </xsl:when>
            <!-- in the TEI header -->
            <xsl:when test="$TEIHeader//.[tokenize(@ana, ' ') = $Direction]">
                <xsl:value-of select="$TEIHeader//.[tokenize(@ana, ' ') = $Direction]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Anonymous</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- same as above, just for @ref  -->
    <xsl:template name="getFromTO_ref">
        <xsl:param name="Direction"/>
        <xsl:choose>
            <!-- not t:measure elements -->
            <xsl:when test=".//.[tokenize(@ana, ' ') = $Direction][not(local-name() ='measure')]/@ref">
                <xsl:call-template name="getRefwithHash">
                    <xsl:with-param name="Path" select=".//.[tokenize(@ana, ' ') = $Direction][not(local-name() ='measure')]/@ref"/>
                </xsl:call-template>  
            </xsl:when>
            <xsl:when test="preceding-sibling::*[not(tokenize(@ana, ' ') = 'bk:entry')][1]//*[@ana=$Direction]/@ref">
                <xsl:call-template name="getRefwithHash">
                    <xsl:with-param name="Path" select="preceding-sibling::*[not(tokenize(@ana, ' ') = 'bk:entry')][1]//*[@ana=$Direction]/@ref"/>
                </xsl:call-template> 
            </xsl:when>
            <xsl:when test="preceding::*[tokenize(@ana, ' ') = $Direction][1]//@ref">
                <xsl:call-template name="getRefwithHash">
                    <xsl:with-param name="Path" select="preceding::*[tokenize(@ana, ' ') = $Direction][1]//@ref"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$TEIHeader//.[tokenize(@ana, ' ') = $Direction]/@ref">
                <xsl:call-template name="getRefwithHash">
                    <xsl:with-param name="Path" select="$TEIHeader//.[tokenize(@ana, ' ') = $Direction]/@ref"/>
                </xsl:call-template> 
            </xsl:when>
        	<!-- @corresp in ancestor-div -->
        	<xsl:when test="ancestor::*[@ana = $Direction]/@corresp">
                <xsl:call-template name="getRefwithHash">
                    <xsl:with-param name="Path" select="ancestor::*[@ana = $Direction]/@corresp"/>
                </xsl:call-template>  
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>#anonymous</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ////////////////////////// -->
    <!-- This template returns the value of a @ref and checks if its starts with a '#', and adds it if it does not exist.  -->
    <xsl:template name="getRefwithHash">
        <xsl:param name="Path"/>
        <xsl:choose>
            <xsl:when test="contains($Path[1], '#')">
                <xsl:value-of select="normalize-space($Path[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space(concat('#', $Path[1]))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ////////////////////////// -->
    <!-- get @unit -->
    <xsl:template name="getUnit">
        <xsl:choose>
            <!-- if in @unit is a # its a reference -->
            <xsl:when test="substring(@unit,1,1) = '#'">
                <bk:unit rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID, @unit)}"/>
            </xsl:when>
            <!-- otherwise its a literal -->
            <xsl:when test="@unit">
                <bk:unit>
                    <xsl:value-of select="@unit"/>
                </bk:unit>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>no @unit</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ////////////////////////// -->
    <!-- get @quantity -->
    <xsl:template name="getQuantity">
        <xsl:choose>
            <xsl:when test="@quantity">
                <bk:quantity>
                    <xsl:value-of select="@quantity"/>
                </bk:quantity>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>no @quantity</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ////////////////////////// -->
    <!-- get @quantity -->
    <xsl:template name="getCommodity">
        <xsl:choose>
            <xsl:when test="substring(@unit,1,1) = '#'">
                <bk:commodity rdf:resource="{concat($BASE-URL, $Currrent_TEI_PID, @commodity)}"/>
            </xsl:when>
            <xsl:when test="@commodity">
                <bk:commodity>
                    <xsl:value-of select="@commodity"/>
                </bk:commodity>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>no @quantity</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- this template ist just to try out something -->
    <xsl:template name="fakeCategory">
        <xsl:param name="Type"/>
        <xsl:choose>
            <xsl:when test="contains($Type, 'potatoes') or contains($Type, 'meat') or contains($Type, 'Meat') or $Type = 'corn' or $Type = 'milk' or $Type = 'rye' or
                $Type = 'flour' or $Type = 'apples' or $Type = 'pork' or contains($Type, 'meat') or contains($Type, 'butter')
                or $Type = 'cheese'  or $Type = 'grain' 
                or $Type = 'beans' or $Type = 'fish' or $Type = 'ham' or $Type = 'beef'  or $Type = 'bacon'  or $Type = 'grain'">
                <bk:category>food</bk:category>
            </xsl:when>
            <xsl:when test="$Type = 'glass' or $Type = 'iron' or $Type = 'wood' or $Type = 'lumber' or $Type = 'Plank'">
                <bk:category>resource</bk:category>
            </xsl:when>
            <xsl:when test="$Type = 'cow' or $Type = 'Alpaca' or $Type = 'turkey' or $Type = 'Horse'">
                <bk:category>animal</bk:category>
            </xsl:when>
            <xsl:when test="$Type = 'shoes' or $Type = 'Alpaca' or $Type = 'turkey'">
                <bk:category>clothing</bk:category>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>