<xsl:stylesheet version="2.0" xmlns="http://www.tei-c.org/ns/1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>

	<!-- //////////////////////////////////////////////////////////// -->
	<!-- ///PARAMS/// -->
    <xsl:param name="csv-encoding" as="xs:string" select="'iso-8859-1'"/>
	<xsl:param name="csv-uri" as="xs:string" select="'GLSCouttsAccts_3.csv'"/>


	<!-- //////////////////////////////////////////////////////////// -->
	<!-- ///MAIN/// -->	
    <xsl:template match="/" name="csv2xml">
    	<TEI>
    	<teiHeader>
		<fileDesc>
			<titleStmt>
				<title>Here title</title>
			</titleStmt>
			<publicationStmt>
				<publisher>Zentrum für Informationsmodellierung - Universität Graz</publisher>
				<idno type="PID"><xsl:value-of select="concat('o:medea.', substring-before($csv-uri, '.'))"/></idno>
			</publicationStmt>
			<sourceDesc>
				<ab>test</ab>
			</sourceDesc>
		</fileDesc>
	</teiHeader>
    		<text>
        <body>
        	<table>
            <xsl:choose>
            	<!-- check if valid CSV -->
                <xsl:when test="unparsed-text-available($csv-uri, $csv-encoding)">
                    <xsl:variable name="CSV" select="unparsed-text($csv-uri, $csv-encoding)"/>
                    <!-- get  CSV-Header -->
                    <xsl:variable name="CSV_Header" as="xs:string*">
                        <xsl:analyze-string select="$CSV" regex="\r\n?|\n">
                            <xsl:non-matching-substring>
                                <xsl:if test="position()=1">
                                    <xsl:copy-of select="tokenize(.,',')"/>                                        
                                </xsl:if>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:variable>
                	<!-- ////////////////////////////////////////// -->
                	<!-- for every CSV line except the header -->
                	<xsl:analyze-string select="$CSV" regex="\r\n?|\n">
                        <xsl:non-matching-substring>
                            <xsl:if test="not(position()=1)">
                            	
                                <row ana="#bk_entry">
                                	<!-- for each token in line -->
                                	<!-- here change the CSV delimiter, if needed -->
                                    <xsl:for-each select="tokenize(.,',')">
                                        <xsl:variable name="pos" select="position()"/>
                                    	
                                    	<!-- if the CSV data cell ist not empty -->
                                    	<xsl:if test="."> 
                                    	<!-- create t:cell -->
                                        <xsl:element name="cell">
                                        	<!-- checks the current position with the header, if its a defined bookkeeping term add the @ana-->
                                        	<!-- load the bk_owl and read this terms generic? -->
                                        	<xsl:choose>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_title'">
	                                        		<!-- add @ana -->
		                                        	<xsl:attribute name="ana">
		                                        		<xsl:text>#title</xsl:text>
		                                        	</xsl:attribute>
	                                        		<!-- cell content -->
	                                        		<xsl:value-of select="."/>
                                        		</xsl:when>
                                        		<!-- @xml:if for t:row, the ID for every entry? -->
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_id'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#id</xsl:text>
                                        			</xsl:attribute>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_text'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#text</xsl:text>
                                        			</xsl:attribute>
                                        			<xsl:value-of select="normalize-space(.)"/>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_from'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_from</xsl:text>
                                        			</xsl:attribute>
                                        			<!-- ToDo @ref -->
                                        			<name>
                                        				<xsl:value-of select="."/>
                                        			</name>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_to'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_to</xsl:text>
                                        			</xsl:attribute>
                                        			<!-- ToDo @ref -->
                                        			<name>
                                        				<xsl:value-of select="."/>
                                        			</name>
                                        		</xsl:when>
                                        		<!--  '£' not working -->
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_amount (L)'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_amount</xsl:text>
                                        			</xsl:attribute>
                                        			<measure commodity="currency">
                                        				<xsl:attribute name="unit" select="'L'"/>
                                        				<xsl:value-of select="."/>
                                        			</measure>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_amount (sh)'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_amount</xsl:text>
                                        			</xsl:attribute>
                                        			<measure commodity="currency">
                                        				<xsl:attribute name="unit" select="'sh'"/>
                                        				<xsl:value-of select="."/>
                                        			</measure>
                                        		</xsl:when>
												<xsl:when test="$CSV_Header[$pos] = 'bk_amount (d)'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_amount</xsl:text>
                                        			</xsl:attribute>
                                        			<measure commodity="currency">
                                        				<xsl:attribute name="unit" select="'d'"/>
                                        				<xsl:value-of select="."/>
                                        			</measure>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_what'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_what</xsl:text>
                                        			</xsl:attribute>
                                        			<measure commodity="todo">
                                        				<xsl:attribute name="unit" select="'todo'"/>
                                        				<xsl:value-of select="."/>
                                        			</measure>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_when'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_when</xsl:text>
                                        			</xsl:attribute>
                                        			<!-- t:date with @when -->
                                        			<xsl:element name="date">
	                                        			<xsl:choose>
	                                        				<!-- todo: this should be a template -->
	                                        				<!-- if YYYY-MM-DD -->
	                                        				<xsl:when test=". castable as xs:date">
	                                        					<xsl:attribute name="when">
	                                        						<xsl:value-of select="."/>
	                                        					</xsl:attribute>
	                                        					<xsl:value-of select="."/>
	                                        				</xsl:when>
	                                        				<!-- if M MM/DD/YYYY -->
	                                        				<xsl:when test="matches(., '\d{2}/\d{2}/\d{4}')">
	                                        					<xsl:variable name="Month" select="substring-before(.,'/')"/>
	                                        					<xsl:variable name="Day" select="substring-before(substring-after(.,'/'), '/')"/>
	                                        					<xsl:variable name="Year" select="substring-after(substring-after(.,'/'), '/')"/>
	                                        					<xsl:attribute name="when">
	                                        						<xsl:value-of select="concat($Year,'-', $Month, '-', $Day)"/>
	                                        					</xsl:attribute>
	                                        					<xsl:value-of select="."/>
	                                        				</xsl:when>
	                                        				<!-- if YYYY-MM -->
	                                        				<xsl:when test="substring-after(., '-')">
	                                        					<xsl:attribute name="when">
	                                        						<xsl:value-of select="."/>
	                                        					</xsl:attribute>
	                                        					<xsl:value-of select="."/>
	                                        				</xsl:when>
	                                        				<!-- if YYYY ToDo: check if year-->
	                                        				<xsl:when test="string-length(.) = 4">
	                                        					<xsl:attribute name="when">
	                                        						<xsl:value-of select="."/>
	                                        					</xsl:attribute>
	                                        					<xsl:value-of select="."/>
	                                        				</xsl:when>
	                                        				<!-- no valid date -->
	                                        				<xsl:otherwise>
	                                        					<xsl:text>not valid: </xsl:text><xsl:value-of select="."/>
	                                        				</xsl:otherwise>
	                                        			</xsl:choose>
                                        			</xsl:element>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_folium'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#folium</xsl:text>
                                        			</xsl:attribute>
                                        			<xsl:value-of select="."/>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_debit'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_debit</xsl:text>
                                        			</xsl:attribute>
                                        			<xsl:value-of select="."/>
                                        		</xsl:when>
                                        		<xsl:when test="$CSV_Header[$pos] = 'bk_credit'">
                                        			<xsl:attribute name="ana">
                                        				<xsl:text>#bk_credit</xsl:text>
                                        			</xsl:attribute>
                                        			<xsl:value-of select="."/>
                                        		</xsl:when>
                                        		<xsl:otherwise>
                                        		</xsl:otherwise>
                                        	</xsl:choose>
                                        </xsl:element>
                                    	</xsl:if>
                                    </xsl:for-each>
                                </row>
                            </xsl:if>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:when>	
            	
            	<!-- ////////////////////////////////////////////////////// -->
            	<!-- ERROR -->
                <xsl:otherwise>
                    <xsl:variable name="error">
                        <xsl:text>Error reading "</xsl:text>
                        <xsl:value-of select="$csv-uri"/>
                        <xsl:text>" (encoding "</xsl:text>
                        <xsl:value-of select="$csv-encoding"/>
                        <xsl:text>").</xsl:text>
                    </xsl:variable>
                    <xsl:message><xsl:value-of select="$error"/></xsl:message>
                    <xsl:value-of select="$error"/>
                </xsl:otherwise>
            </xsl:choose>
        </table>
      </body>
    </text>
   </TEI>
  </xsl:template>

</xsl:stylesheet>