<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:gmr="http://www.gnome.org/gnumeric/v7" 
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" 
    xmlns:t="http://www.tei-c.org/ns/1.0"
     xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
     xmlns:xs="http://www.w3.org/2001/XMLSchema" 
     xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
     exclude-result-prefixes="xs" version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml"></xsl:output>
    <xd:doc>
        <xd:desc>Defaultstylesheet, um SPARQL-Ergebnisse als Spreadsheet herunterladen zu können.
            georg.vogeler@uni-graz.at, 2015-04-07</xd:desc>
    </xd:doc>
    <xsl:template match="/">
        
  
        <gmr:Workbook>
            <gmr:Sheets>
                <xsl:for-each-group select="//s:results/s:result" group-by="s:Collection/@uri">
                    <xsl:call-template name="createSheet"/>
                </xsl:for-each-group>
                
            </gmr:Sheets>
        </gmr:Workbook>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>creates 'Arbeitsmappe'/sheet in a single excel file for every Colelction (e.g. Fulltextsearch result contains of multiple collections</xd:desc>
    </xd:doc>
    <xsl:template name="createSheet">
        <gmr:Sheet>
            <gmr:Name>
                <xsl:value-of select="substring-after(current-grouping-key(), 'depcha.')"/>
            </gmr:Name>
            <gmr:MaxCol>
                <xsl:value-of select="count(//s:variable)"></xsl:value-of>
            </gmr:MaxCol>
            <gmr:MaxRow>
                <xsl:value-of select="(count(//s:result) + 1)"></xsl:value-of>
            </gmr:MaxRow>
            <gmr:Cells>
                <gmr:Cell Col="0" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>ENTRY</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="1" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>WHEN</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="2" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>FROM</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="3" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>TO</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <!--<gmr:Cell Col="4" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>MEASURABLE</xsl:text>
                    </gmr:Content>
                </gmr:Cell>     -->          
                <gmr:Cell Col="4" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>QUANTITY</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="5" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>UNIT</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="6" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>COMMODITY</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="7" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>QUANTITY 2</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="8" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>UNIT 2</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="9" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>COMMODITY 2</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="10" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>QUANTITY 3</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="11" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>UNIT 3</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
                <gmr:Cell Col="12" Row="0" ValueType="60">
                    <gmr:Content>
                        <xsl:text>COMMODITY 3</xsl:text>
                    </gmr:Content>
                </gmr:Cell>
            </gmr:Cells>
            <xsl:for-each-group select="current-group()" group-by="s:Transfer/@uri">
                <xsl:sort select="s:When"></xsl:sort>
                <xsl:variable name="row" select="position()"></xsl:variable>
                <!--  <gmr:Cell ValueType="10"> is needed if Cells are empty to keep them empty -->
                <gmr:Cell Col="0" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:Entry">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:value-of select="s:Entry"/>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>                                   
                </gmr:Cell>
                <gmr:Cell Col="1" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:When">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:value-of select="s:When"></xsl:value-of>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmr:Cell>
                <gmr:Cell Col="2" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:From_name">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:value-of select="s:From_name"></xsl:value-of>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmr:Cell>
                <gmr:Cell Col="3" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:To_name">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:value-of select="s:To_name"></xsl:value-of>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmr:Cell>
                <!--<gmr:Cell Col="4" Row="{$row}" ValueType="60">
                    <xsl:variable name="Measurable_type" select="substring-after(s:Measurable_type/@uri, '#')"/>
                    <xsl:choose>
                        <xsl:when test="$Measurable_type">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:choose>
                                    <xsl:when test="$Measurable_type = 'Money'">
                                        <!-\- for every shilling, pence, dollar, etc. -\->
                                        <xsl:for-each-group select="current-group()" group-by="s:Unit">
                                            <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/><br/>
                                        </xsl:for-each-group>
                                    </xsl:when>
                                    <xsl:when test="$Measurable_type = 'Service'">
                                        <xsl:for-each-group select="current-group()" group-by="s:Unit">
                                            <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/><br/>
                                        </xsl:for-each-group>
                                    </xsl:when>
                                    <xsl:when test="$Measurable_type = 'Commodity'">
                                        <!-\- as commodity is always something different (powder, knife) -\->
                                        <xsl:for-each-group select="current-group()" group-by="s:Commodity">
                                            <xsl:value-of select="s:Quantity"/><xsl:text> </xsl:text><xsl:value-of select="s:Unit"/><xsl:text> </xsl:text><xsl:value-of select="s:Commodity"/><br/>
                                        </xsl:for-each-group>
                                    </xsl:when>
                                    <xsl:otherwise>nope</xsl:otherwise>
                                </xsl:choose>
                                <xsl:text> </xsl:text>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmr:Cell>-->
                

      
                <!-- 1. Measurable -->
                <xsl:for-each-group select="current-group()" group-by="s:Unit">
                
                <!-- this is a strange part of code
                     grouping the already grouped Transfers by Unit to sperate 1 $ 50 Cents
                     position() returns the position if it 
                -->
                
                <xsl:variable name="Col5">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="4"/>
                        </xsl:when>
                        <xsl:when test="position() = 2">
                            <xsl:value-of select="7"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="Col6">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="5"/>
                        </xsl:when>
                        <xsl:when test="position() = 2">
                            <xsl:value-of select="8"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="11"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="Col7">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="6"/>
                        </xsl:when>
                        <xsl:when test="position() = 2">
                            <xsl:value-of select="9"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="12"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <gmr:Cell Col="{$Col5}" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:Quantity">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:value-of select="s:Quantity"/>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmr:Cell>
                <gmr:Cell Col="{$Col6}" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:Unit">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:value-of select="s:Unit"/>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmr:Cell>
                    <gmr:Cell Col="{$Col7}" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:Commodity">
                            <xsl:attribute name="ValueType" select="60"/>
                            <gmr:Content>
                                <xsl:value-of select="s:Commodity"/>
                            </gmr:Content>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmr:Cell>
                </xsl:for-each-group>
                
                
            </xsl:for-each-group>
        </gmr:Sheet>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            ToDo:
            @ValueType sollte man noch nach dem Zellinhalt bestimmen:
            @ValueType=&quot;10&quot; =&gt; empty  
            @ValueType&quot;20&quot; =&gt; boolean
            @ValueType&quot;30&quot; =&gt; integer
            @ValueType&quot;40&quot; =&gt; float  
            @ValueType&quot;50&quot; =&gt; error  
            @ValueType&quot;60&quot; =&gt; string 
            @ValueType&quot;70&quot; =&gt; cellrange
            @ValueType&quot;80&quot; =&gt; array 
        </xd:desc>
    </xd:doc>
    
</xsl:stylesheet>


<!-- <?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:gmr="http://www.gnome.org/gnumeric/v7" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:t="http://www.tei-c.org/ns/1.0">

	<xsl:variable name="rows" select="//t:body//t:*[matches(@ana, '#bk_entry')]"/>
	<xsl:output encoding="utf-8" indent="yes" method="xml"/>
	<xsl:template match="/">
		<gmr:Workbook>
			<gmr:Sheets>
				<gmr:Sheet>
					<gmr:Name>
						<xsl:value-of select="t:titleStmt/t:title[1]"/>
					</gmr:Name>
					<gmr:MaxCol>5</gmr:MaxCol>
					<gmr:MaxRow>
						<xsl:text>rows</xsl:text>
					</gmr:MaxRow>
					<gmr:Cells>
					<gmr:Cell Col="0" Row="0" ValueType="60">
						<gmr:Content>
							<xsl:text>ENTRY</xsl:text>
						</gmr:Content>
					</gmr:Cell>
						<gmr:Cell Col="1" Row="0" ValueType="60">
						<gmr:Content>
							<xsl:text>WHEN</xsl:text>
						</gmr:Content>
					</gmr:Cell>
					<gmr:Cell Col="2" Row="0" ValueType="60">
						<gmr:Content>
							<xsl:text>FROM</xsl:text>
						</gmr:Content>
					</gmr:Cell>
					<gmr:Cell Col="3" Row="0" ValueType="60">
						<gmr:Content>
							<xsl:text>TO</xsl:text>
						</gmr:Content>
					</gmr:Cell>
					<gmr:Cell Col="4" Row="0" ValueType="60">
						<gmr:Content>
							<xsl:text>MEASURABLE</xsl:text>
						</gmr:Content>
					</gmr:Cell>
				</gmr:Cells>
				
					<xsl:apply-templates select="//*[tokenize(@ana, ' ') = '#bk_entry'][*[tokenize(@ana, ' ') = '#bk_text']] | //*[matches(@ana, '#bk_total')][*[tokenize(@ana, ' ') = '#bk_text']]"/>
					
					
					
				</gmr:Sheet>
			</gmr:Sheets>
		</gmr:Workbook>
	</xsl:template>
	
	<xsl:template match="*[matches(@ana, '#bk_total')][*[tokenize(@ana, ' ') = '#bk_text']]">
		<gmr:Cells>
			<gmr:Cell Col="0" Row="{position()}" ValueType="60">
					<gmr:Content>
						<xsl:text>#bk_total</xsl:text>
					</gmr:Content>
			</gmr:Cell>

		</gmr:Cells>
	</xsl:template>

	<xsl:template match="*[matches(@ana, '#bk_entry')][*[tokenize(@ana, ' ') = '#bk_text']]">
		<gmr:Cells>
			<gmr:Cell Col="0" Row="{position()}" ValueType="60">
					<gmr:Content>
						<xsl:text>#bk_entry</xsl:text>
					</gmr:Content>
			</gmr:Cell>
			<gmr:Cell Col="1" Row="{position()}" ValueType="60">
				<gmr:Content>
					<xsl:apply-templates select="*[tokenize(@ana, ' ') = '#bk_text']"/>
				</gmr:Content>
			</gmr:Cell>
			<gmr:Cell Col="2" Row="{position()}" ValueType="60">
				<gmr:Content>
					<xsl:apply-templates select="*[tokenize(@ana, ' ') = '#bk_from']"/>
					</gmr:Content>
			</gmr:Cell>
			<xsl:if test="*[tokenize(@ana, ' ') = '#bk_to']">
				<gmr:Cell Col="3" Row="{position()}" ValueType="60">
					<gmr:Content>
						<xsl:apply-templates select="*[tokenize(@ana, ' ') = '#bk_to']"/>
					</gmr:Content>
				</gmr:Cell>
			</xsl:if>
			<gmr:Cell Col="4" Row="{position()}" ValueType="60">
				<gmr:Content>
					<xsl:apply-templates select="*[tokenize(@ana, ' ') = '#bk_money']"/>
					</gmr:Content>
				<xsl:text> </xsl:text>
			</gmr:Cell>
			<gmr:Cell Col="5" Row="{position()}" ValueType="60">
				<gmr:Content>
					<xsl:apply-templates select="*[tokenize(@ana, ' ') = '#bk_when']"/>
					</gmr:Content>
			</gmr:Cell>
			<gmr:Cell Col="6" Row="{position()}" ValueType="60">
				<gmr:Content>
				<xsl:apply-templates select="*[tokenize(@ana, ' ') = '#bk_when']//@when"/>
					</gmr:Content>
			</gmr:Cell>
		</gmr:Cells>
	</xsl:template>
	
	
	<xsl:template match="t:*[tokenize(@ana, ' ') = '#bk_from']">
		<xsl:value-of select="."/>
		<xsl:text> </xsl:text>
	</xsl:template>

<xsl:template match="t:*[tokenize(@ana, ' ') = '#bk_to']">
    <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="*[tokenize(@ana, ' ') = '#bk_text']">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="t:*[tokenize(@ana, ' ') = '#bk_when']">
    <xsl:value-of select="."/>
    <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="t:*[tokenize(@ana, ' ') = '#bk_debit']">
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="t:*[tokenize(@ana, ' ') = '#bk_money']">
    <xsl:value-of select="normalize-space(.)"/><xsl:text>, </xsl:text>
</xsl:template>

</xsl:stylesheet>
-->
