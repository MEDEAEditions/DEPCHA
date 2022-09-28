<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
            <listPlace ana="depcha:index">
                <xsl:comment>Places added from //text//placeName[@bk:when]/@ref</xsl:comment>
                <xsl:for-each-group select="//t:text//t:placeName[@ref][contains(@ana, 'bk:where')][not(substring-after(@ref, '#') = //t:listPlace//t:place/@xml:id)]" group-by="@ref">
                    <xsl:sort select="current-grouping-key()"/>
                    <place xml:id="{substring-after(current-grouping-key(), '#')}">
                        <xsl:for-each select="distinct-values(current-group())">
                            <placeName>
                                <xsl:value-of select="normalize-space(.)"/>
                            </placeName>
                        </xsl:for-each>
                    </place>
                </xsl:for-each-group>
            </listPlace>
    </xsl:template>

</xsl:stylesheet>
