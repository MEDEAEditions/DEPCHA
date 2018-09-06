<xsl:stylesheet version="2.0" xmlns="http://www.tei-c.org/ns/1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>



	<!-- //////////////////////////////////////////////////////////// -->
	<!-- ///MAIN/// -->	
    <xsl:template match="/">
    	
    	<TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:t="http://www.tei-c.org/ns/1.0">
    		<teiHeader>
    			<fileDesc>
    				<titleStmt>
    					<title>
    						<xsl:value-of select="//row[1]/bookpage"/>
    					</title>
    				</titleStmt>
    				<publicationStmt>
    					<publisher><orgName>University of Virginia</orgName>
    					</publisher>
    					<authority>
    						<orgName ref="http://d-nb.info/gnd/1137284463"
    						corresp="https://informationsmodellierung.uni-graz.at">Zentrum für
    						Informationsmodellierung - Austrian Centre for Digital Humanities,
    						Karl-Franzens-Universität Graz</orgName></authority>
    					<distributor><orgName ref="https://gams.uni-graz.at">GAMS -
    						Geisteswissenschaftliches Asset Management System</orgName></distributor>
    					<availability>
    						<licence target="https://creativecommons.org/licenses/by-nc-sa/4.0">Creative
    							Commons BY-NC-SA 4.0</licence>
    					</availability>
    					<date when="2018">2018</date>
    					<pubPlace>Graz</pubPlace>
    					<idno type="PID">
    						<xsl:value-of select="concat('o:medea.washington.', ' ')"/>
    					</idno>
    				</publicationStmt>
    				<seriesStmt>
    					<title ref="http://gams.uni-graz.at/cpntext:depcha">DEPCHA</title>
    					<respStmt>
    						<resp>Projektleitung</resp>
    						<persName><forename>Georg</forename><surname>Vogeler</surname></persName>
    					</respStmt>
    				</seriesStmt>
    				<sourceDesc>
    					<ab>Pagebook: <xsl:value-of select="//row[1]/bookpage"/>, <xsl:value-of select="//row[1]/folioside"/></ab>
    				</sourceDesc>
    			</fileDesc>
    			<encodingDesc>
    				<editorialDecl>
    					<p>was über die editionsregeln und kodierungsrichtlinien</p>
    				</editorialDecl>
    				<projectDesc>
    					<ab> <!--<ref target="context:depcha" type="context">DEPCHA</ref>-->
    						<ref target="info:fedora/context:medea.wfp" type="context">The George Washington Financial Papers</ref></ab>
    					
    					<p>Projektbeschreibungsabsatzerl</p>
    				</projectDesc>
    			</encodingDesc>
    			<profileDesc>
    				<langUsage>
    					<language ident="eng">English</language>
    				</langUsage>
    				<textClass>
    					<keywords scheme="cirilo:normalizedPlaceNames">
    						<list>
    							<item/>
    						</list>
    					</keywords>
    					<keywords ana="account">
    						<list>
    							<xsl:for-each-group select="//row" group-by="AccountNameDataID">
    								<item><term>
    									<ref target="{current-grouping-key()}">
    									<xsl:value-of select="AccountNameData"/>
    								</ref></term></item>
    							</xsl:for-each-group>
    						</list>
    					</keywords>
    					<keywords ana="currency">
    						<list>
    							<xsl:for-each-group select="//row" group-by="CurrencyData">
    								<xsl:if test="not(current-grouping-key() ='')">
    									<item>
    										<term>
    										<ref target="{current-grouping-key()}">
    											<xsl:value-of select="current-grouping-key()"/>
    										</ref>
    										</term>
    									</item>
    								</xsl:if>
    							</xsl:for-each-group>
    						</list>
    					</keywords>
    				</textClass>
    			</profileDesc>
    		</teiHeader>
    		<text>
    			<body>
    				<table>
    					
    					<xsl:apply-templates select="//row"/>
    				</table>
    			</body>
    		</text>
    	</TEI>
  </xsl:template>
	
	<xsl:template match="row">
		 <row xml:id="{concat('wfp_', uuid)}" n="{linenumber}">
		 	<xsl:attribute name="ana">
		 		<xsl:choose>
		 			<xsl:when test="contains(./ClearText, '[Total]')">
		 				<xsl:text>#bk_total</xsl:text>
		 			</xsl:when>
		 			<xsl:otherwise>
		 				<xsl:text>#bk_entry</xsl:text>
		 			</xsl:otherwise>
		 		</xsl:choose>
		 	</xsl:attribute>
		 	
		 	
		 	<xsl:apply-templates/>
		 </row>
	</xsl:template>
	
	
	<xsl:template match="Date[text()]">
		<cell>
			<date ana="#bk_when">
				<xsl:choose>
					<xsl:when test="contains(../date-attribute, 'to')">
						<xsl:attribute name="when">
								<xsl:value-of select="normalize-space(substring-before(../date-attribute, 'to'))"/>
						</xsl:attribute>
						<!--<xsl:attribute name="to">
								<xsl:value-of select="normalize-space(substring-after(../date-attribute, 'to'))"/>
						</xsl:attribute>-->
					</xsl:when>
					<xsl:when test="not(../date-attribute = '')">
						<xsl:attribute name="when">
							<xsl:choose>
								<xsl:when test="../date-attribute castable as xs:date">
									<xsl:value-of select="../date-attribute"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<xsl:when test="contains(../date-attribute, '-')">
											<xsl:value-of select="../date-attribute"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat(../date-attribute, '-01')"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates/>
			</date>
		</cell>
	</xsl:template>
	
	<xsl:template match="date-attribute">
	</xsl:template>

	<xsl:template match="ClearText[text()]">
		<cell>
			<xsl:apply-templates/>
		</cell>
	</xsl:template>
		
	<xsl:template match="PoundsData[text()]">
		<cell>
			<measure ana="#bk_money #bk_to" commodity="currency" unit="Pounds"  quantity="{.}" >
					<!--<xsl:call-template name="CurrencyData"/>-->
					<xsl:value-of select="."/>
				</measure>
				</cell>
	</xsl:template>
	<xsl:template match="ShillingsData[text()]">
		<cell>
			<measure ana="#bk_money #bk_to" commodity="currency" unit="Shillings" quantity="{.}">
				<!--<xsl:call-template name="CurrencyData"/>-->
				<xsl:value-of select="."/>
			</measure>
		</cell>
	</xsl:template>
	<xsl:template match="PenceData[text()]">
		<cell>
			<measure ana="#bk_money #bk_to" commodity="currency" unit="Pence" quantity="{.}">
				<!--<xsl:call-template name="CurrencyData"/>-->
				<xsl:value-of select="."/>
			</measure>
		</cell>
	</xsl:template>
	<xsl:template match="DollarsData[text()]">
		<cell>
			<measure ana="#bk_money #bk_to" commodity="currency" unit="Dollars" quantity="{.}">
				<!--<xsl:call-template name="CurrencyData"/>-->
				<xsl:value-of select="."/>
			</measure>
		</cell>
	</xsl:template>
	<xsl:template match="CentsData[text()]">
		<cell>
			<measure ana="#bk_money #bk_to" commodity="currency" unit="Cents" quantity="{.}">
				<!--<xsl:call-template name="CurrencyData"/>-->
				<xsl:value-of select="."/>
			</measure>
		</cell>
	</xsl:template>
	
		
	<xsl:template match="AccountNameData">
		<cell>
			<name  ref="{../AccountNameDataID}">
				<xsl:attribute name="ana">
					<xsl:text>#bk_to</xsl:text>
					<xsl:if test="../drcr">
						<xsl:choose>
							<xsl:when test="../drcr = 'Credit'">
								<xsl:text> #bk_credit</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text> #bk_debit</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:attribute>
				<xsl:value-of select="."/>
			</name>
		</cell>
	</xsl:template>
	

	

	
		<xsl:template match="entry">
	</xsl:template>

		<xsl:template match="subtotal"/>

		<xsl:template match="page"/>
	<xsl:template match="symbol"/>
	
	
	<!--<xsl:template name="CurrencyData">
		<xsl:if test="../CurrencyData[text()]">
			<xsl:attribute name="ana">
				<xsl:value-of select="concat('#', ../CurrencyData)"/>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>-->

	
	<!-- skip -->
	<xsl:template match="AccountNameDataID"/>
	<xsl:template match="CurrencyData"/>
	<xsl:template match="year"></xsl:template>
	<xsl:template match="month"></xsl:template>
	<xsl:template match="day"></xsl:template>
	<xsl:template match="pounds"/>
	<xsl:template match="shillings"/>
	<xsl:template match="pence"/>
	<xsl:template match="dollars"/>
	<xsl:template match="cents"/>
	<xsl:template match="linenumber"/>
	<xsl:template match="uuid"/>
	<xsl:template match="bookpage"/>
	<xsl:template match="folioside"/>
	<xsl:template match="drcr"/>
	<xsl:template match="inenumber"/>
	<xsl:template match="accountname"/>
	
	
	

</xsl:stylesheet>