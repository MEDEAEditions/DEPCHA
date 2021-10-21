<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:variable name="SUMS_Excel" select="document('LeuvenSums_5066register.xml')//*:Row"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="*:row[*:cell/*:hi[@rend='underline']]">
        <xsl:copy>
            <xsl:attribute name="ana" select="'bk:entry bk:sum'"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*:row[*:cell/*:hi[@rend='underline']]/*:cell[2]">
        <xsl:variable name="currentFolio" select="preceding::*:pb[1]/@n"/>

        <xsl:variable name="ExcelRow" select="$SUMS_Excel[*:Cell[11] = $currentFolio]"/>
        
       <!-- <xsl:value-of select="$ExcelRow"/>-->
        <xsl:copy>
            <measure>
                <xsl:attribute name="unit">
                    <xsl:value-of select="$ExcelRow/*:Cell[9]"/>
                </xsl:attribute>
                <xsl:attribute name="quantity">
                    <xsl:value-of select="$ExcelRow/*:Cell[8]"/>
                </xsl:attribute>
                <xsl:apply-templates select="node()"/>
            </measure>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*:row/*:cell[1]/*:hi[@rend='bold']">
        <term>
            <xsl:attribute name="rend" select="'bold'"></xsl:attribute>
            <xsl:attribute name="ana" select="'bk:from bk:to'"/>
            <xsl:attribute name="ref" select="'#'"/>
            <xsl:apply-templates select="@*|node()"/>
        </term>
    </xsl:template>
    
    <!-- //*:row[*:cell/*:hi[@rend='underline']]/preceding-sibling::-->
    
    
</xsl:stylesheet>