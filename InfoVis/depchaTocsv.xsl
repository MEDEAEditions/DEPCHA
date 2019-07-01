<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <xsl:text>&#xa;</xsl:text>
        <xsl:text>"ENTRY";"DATE";"FROM";"TO";"MONEY";"QUANT";"UNIT";"COMMODITY";"CATEGORY";"SIZE";"CATEGORY";</xsl:text>
        <xsl:text>&#xa;</xsl:text>

        <xsl:for-each-group select="//*:result" group-by="*:Transaction/@uri">
            
            <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(replace(*:Entry[1], '&quot;', '-'))"/><xsl:text>"</xsl:text>
            <xsl:text>;</xsl:text>
            
            <xsl:variable name="Years" select="year-from-date(*:When[1])"/>
            <xsl:variable name="Months" select="month-from-date(*:When[1])"/>
            
            <xsl:value-of select="concat($Years, '-', $Months)"/>
            <xsl:text>;</xsl:text>
            
            <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(*:From_name)"/><xsl:text>"</xsl:text>
            <xsl:text>;</xsl:text>
            
            <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(*:To_name)"/><xsl:text>"</xsl:text>
            <xsl:text>;</xsl:text>
            
            <xsl:variable name="Sum">
                <xsl:variable name="Dollar" select="sum(current-group()[*:Unit = 'dollars']/*:Quantity)"/>
                <xsl:variable name="Cents" select="sum(current-group()[*:Unit = 'cents']/*:Quantity) div 100"/>
                <xsl:value-of select="number($Dollar) + number($Cents)"/>
            </xsl:variable>
            <xsl:value-of select="replace(string($Sum), '\.', ',')"/>
            <xsl:text>;</xsl:text>
                   
            <xsl:if test="*:Measurable_type/@uri = 'https://gams.uni-graz.at/o:depcha.bookkeeping#Commodity'">
                <xsl:value-of select="replace(string(*:Quantity), '\.', ',')"/>
            </xsl:if>
            <xsl:text>;</xsl:text>
            
            <xsl:if test="*:Measurable_type/@uri = 'https://gams.uni-graz.at/o:depcha.bookkeeping#Commodity'">
                <!-- UNIT -->
                <xsl:text>"</xsl:text><xsl:value-of select="*:Unit"/><xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:if test="*:Measurable_type/@uri = 'https://gams.uni-graz.at/o:depcha.bookkeeping#Service'">
                <xsl:text>"</xsl:text><xsl:value-of select="*:Unit"/><xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:text>;</xsl:text>
            <!-- COMMODITY -->
            <xsl:if test="*:Measurable_type/@uri = 'https://gams.uni-graz.at/o:depcha.bookkeeping#Commodity'">
                <xsl:text>"</xsl:text><xsl:value-of select="*:Commodity"/><xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:if test="*:Measurable_type/@uri = 'https://gams.uni-graz.at/o:depcha.bookkeeping#Service'">
                <xsl:text>"</xsl:text><xsl:value-of select="*:Commodity"/><xsl:text>"</xsl:text>
            </xsl:if>
            <!-- CATEGORY -->
            <xsl:text>;</xsl:text>
            <xsl:choose>
                <xsl:when test="*:Measurable_type/@uri = 'https://gams.uni-graz.at/o:depcha.bookkeeping#Service'">
                    <xsl:text>"</xsl:text>
                        <xsl:text>service</xsl:text>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:when test="*:Measurable_type/@uri = 'https://gams.uni-graz.at/o:depcha.bookkeeping#Money'">
                    <xsl:text>"</xsl:text>
                    <xsl:text>money</xsl:text>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:when test="contains(*:Commodity, 'potatoes') or contains(*:Commodity, 'meat') or *:Commodity = 'corn' or *:Commodity = 'milk' or *:Commodity = 'rye' or *:Commodity = 'Cranberries' or
                    *:Commodity = 'flour' or *:Commodity = 'apples' or *:Commodity = 'butter'  or contains(*:Commodity, 'meat')
                    or *:Commodity = 'cranberries' or contains(*:Commodity, 'bean') or *:Commodity = 'cider' or *:Commodity = 'meal' or *:Commodity = 'wine' or contains(*:Commodity,'beef')  or contains(*:Commodity,'cheese') or *:Commodity = 'flour' or *:Commodity = 'fish' or *:Commodity = 'ham' or *:Commodity = 'bacon'  or *:Commodity = 'grain' or *:Commodity = 'tea' or *:Commodity = 'rhubarb' or *:Commodity = 'cow' or *:Commodity = 'Alpaca' or *:Commodity = 'turkey' or contains(*:Commodity,'pork')">
                    <xsl:text>"</xsl:text>
                        <xsl:text>food</xsl:text>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:when test="*:Commodity = 'iron' or *:Commodity = 'wood' or *:Commodity = 'hard wood' or *:Commodity = 'brick wood' or *:Commodity = 'lumber'">
                    <xsl:text>"</xsl:text>
                    <xsl:text>resource</xsl:text>
                    <xsl:text>"</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>"</xsl:text>
                        <xsl:text>commodity</xsl:text>
                    <xsl:text>"</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <xsl:variable name="currentCommodity" select="*:Commodity"/>
            
            <xsl:choose>
                <xsl:when test="$currentCommodity">
                    <xsl:value-of select="count(//*:Commodity[text() = $currentCommodity])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>0</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <!-- <xsl:value-of select="count(//*:Commodity[text() = $currentCommodity][]/../*:Unit)"/>
            <xsl:text>;</xsl:text>-->
            <xsl:text>&#xa;</xsl:text>
        </xsl:for-each-group>
    </xsl:template>
</xsl:stylesheet>