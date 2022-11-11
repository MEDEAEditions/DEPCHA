<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <taxonomy ana="depcha:index">
            <xsl:comment>Commodities added from //text//@commodity</xsl:comment>
            <xsl:for-each-group select="//t:text//t:measure" group-by="@commodity">
                <xsl:sort select="current-grouping-key()"/>
                <category
                    xml:id="{if (starts-with(current-grouping-key(), '#')) then (substring-after(current-grouping-key(), '#')) else current-grouping-key()}">
                    <catDesc>
                        <xsl:for-each select="current-group()">
                            <gloss>
                                <xsl:value-of select="normalize-space(.)"/>
                            </gloss>
                        </xsl:for-each>
                    </catDesc>
                </category>
            </xsl:for-each-group>
        </taxonomy>
    </xsl:template>

</xsl:stylesheet>
