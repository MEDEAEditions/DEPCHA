<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  version="2.0"
	xmlns:gmr="http://www.gnome.org/gnumeric/v7" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:t="http://www.tei-c.org/ns/1.0">
	<xsl:output encoding="utf-8" indent="yes" method="xml"/>
	<xsl:variable name="rows" select="//t:body//t:*[matches(@ana, '#bk_entry')] | //t:body//t:*[matches(@ana, '#bk_total') and not(matches(@ana, '#bk_page'))]"/>
	<xsl:variable name="maxCols">5</xsl:variable>
	<xsl:template match="/">
		<gmr:Workbook>
			<gmr:Sheets>
				<gmr:Sheet>
					<gmr:Name>
						<xsl:text>name</xsl:text>
					</gmr:Name>
					<gmr:MaxCol>
						<xsl:value-of select="$maxCols"/>
					</gmr:MaxCol>
					<gmr:MaxRow>
						<xsl:value-of select="count($rows)"/>
					</gmr:MaxRow>
					<gmr:Styles>
						<gmr:StyleRegion endCol="{$maxCols}" endRow="0" startCol="0" startRow="0">
							<gmr:Style Back="FFFF:FFFF:FFFF" Fore="0:0:0" Format="General" HAlign="1" Hidden="0" Indent="0" Locked="1" Orient="1" PatternColor="0:0:0" Shade="0" VAlign="2" WrapText="0">
								<gmr:Font Bold="1" Italic="0" StrikeThrough="0" Underline="0" Unit="9">Helvetica</gmr:Font>
								<gmr:StyleBorder>
									<gmr:Top Style="0"/>
									<gmr:Bottom Style="1"/>
									<gmr:Left Style="0"/>
									<gmr:Right Style="0"/>
									<gmr:Diagonal Style="0"/>
									<gmr:Rev-Diagonal Style="0"/>
								</gmr:StyleBorder>
							</gmr:Style>
						</gmr:StyleRegion>
					</gmr:Styles>
					<gmr:Cells>
						<gmr:Cell Col="0" Row="0" ValueType="60">
							<gmr:Content>Kategorie</gmr:Content>
						</gmr:Cell>
						<gmr:Cell Col="1" Row="0" ValueType="60">
							<gmr:Content>Typ</gmr:Content>
						</gmr:Cell>
						<gmr:Cell Col="2" Row="0" ValueType="60">
							<gmr:Content>Originaltext</gmr:Content>
						</gmr:Cell>
						<gmr:Cell Col="3" Row="0" ValueType="60">
							<gmr:Content>Betrag in Pfennig</gmr:Content>
						</gmr:Cell>
						<gmr:Cell Col="4" Row="0" ValueType="60">
							<gmr:Content>Errechneter Betrag</gmr:Content>
						</gmr:Cell>
						<gmr:Cell Col="5" Row="0" ValueType="60">
							<gmr:Content>Kontenpfad</gmr:Content>
						</gmr:Cell>
						<xsl:apply-templates select="$rows"/>
					</gmr:Cells>
				</gmr:Sheet>
			</gmr:Sheets>
		</gmr:Workbook>
	</xsl:template>
</xsl:stylesheet>
