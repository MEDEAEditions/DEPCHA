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
                <!--<xsl:for-each-group select="//s:results/s:result" group-by="s:Collection/@uri">-->
                    <xsl:call-template name="createSheet"/>
                <!--</xsl:for-each-group>-->
                
            </gmr:Sheets>
        </gmr:Workbook>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>creates 'Arbeitsmappe'/sheet in a single excel file for every Colelction (e.g. Fulltextsearch result contains of multiple collections</xd:desc>
    </xd:doc>
    <xsl:template name="createSheet">
        <gmr:Sheet>
           
            
            <gmr:Cells>
                <gmr:Cell Col="1" Row="1" ValueType="30">
                    <xsl:value-of select="1"/>
                    
                </gmr:Cell>
          
            <!--<xsl:for-each-group select="//s:result" group-by="s:tr/@uri">
                <xsl:variable name="row" select="position()"></xsl:variable>
                <!-\-  <gmr:Cell ValueType="10"> is needed if Cells are empty to keep them empty -\->
                <gmr:Cell Col="0" Row="{$row}" ValueType="60">
                    <xsl:choose>
                        <xsl:when test="s:e">
                            <xsl:text>sdd</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="ValueType" select="10"/>
                        </xsl:otherwise>
                    </xsl:choose>                                   
                </gmr:Cell>
            </xsl:for-each-group>-->
            </gmr:Cells>
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
