<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <xsl:if test="//t:sourceDesc/t:listPlace">
            <xsl:message>
                A listPlace element already exists within the sourceDesc!!!
            </xsl:message>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@* | text()" priority="-1">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="*" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | text() | *"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="t:sourceDesc[not(t:listPlace)]">
        <xsl:copy>
            <xsl:apply-templates/>
            <listPlace xmlns="http://www.tei-c.org/ns/1.0" ana="depcha:index">
                <xsl:for-each-group select="//t:text//t:placeName[@ref][contains(@ana, 'bk:where')]" group-by="@ref">
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
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
