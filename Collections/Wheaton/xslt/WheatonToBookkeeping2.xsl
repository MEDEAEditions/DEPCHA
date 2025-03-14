<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    

    
    <!-- //////////////////////////////////////// -->
    <!-- copy everything -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*:name[@ref='v']/@ref">
       <xsl:attribute name="ref"><xsl:text>huhu</xsl:text></xsl:attribute>
    </xsl:template>
    
   

    
    
</xsl:stylesheet>