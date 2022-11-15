<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:page="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15"
    xmlns:bk="gams.uni-graz.at/o:depcha.bookkeeping#" exclude-result-prefixes="xs" version="2.0">



    <xsl:template match="/">
        <page>
            <!-- es geht nur, wenn für jede transaktion eine eigene TextRegion angelegt wird, 
                die genau die transaktion abdeckt. es dürfen sonst keine TextRegion verwendet werden (außer mann kann sie irgendwie typisieren)  -->
            <xsl:for-each select="//page:TextRegion[page:TextLine[contains(@custom, 'bk_entry')]]">
                <bk:Transaction>
                    <bk:entry>
                        <xsl:for-each select="page:TextLine">
                            <xsl:value-of select="normalize-space(.)"/>
                            <xsl:if test="not(position() = last())">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </bk:entry>
                    
                    <xsl:variable name="BK_MONEY" select="page:TextLine[contains(@custom, 'bk_money')]"/>
                    
                    <xsl:if test="$BK_MONEY">
                        <bk:money>
                            <xsl:value-of select="substring($BK_MONEY/page:TextEquiv/page:Unicode, 9, 5)"/>
                        </bk:money>
                        <xsl:if test="count(contains($BK_MONEY/@custom, 'bk_money')) &gt; 2">
                            <bk:money>
                                <xsl:value-of select="substring($BK_MONEY/page:TextEquiv/page:Unicode, 15, 5)"/>
                            </bk:money>
                        </xsl:if>
                    </xsl:if>

                </bk:Transaction>
            </xsl:for-each>
        </page>
    </xsl:template>

</xsl:stylesheet>
