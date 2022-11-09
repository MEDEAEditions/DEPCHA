<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <taxonomy ana="bk:account">
            <xsl:comment>Accounts added from //text//*[@ana = "bk:account"]/@corresp</xsl:comment>
            <xsl:for-each-group
                select="//t:text//t:*[@ana='bk:account']/@corresp"
                group-by=".">
                <xsl:sort select="current-grouping-key()"/>
                <xsl:variable name="id" select="substring-after(current-grouping-key(), '#')"/>
                <category xml:id="{$id}">
                    <gloss>
                        <xsl:value-of select="$id"/>
                    </gloss>
                </category>
            </xsl:for-each-group>
        </taxonomy>
    </xsl:template>

</xsl:stylesheet>
