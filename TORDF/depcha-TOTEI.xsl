<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!--Identity template, 
        provides default behavior that copies all content into the output -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--More specific template for Node766 that provides custom behavior -->
    <xsl:template match="//*:text//*[tokenize(@ana, ' ') = '#bk_entry']">
        <!-- same like in TORDF.xsl, as it is a xsl:template: position must be calculated -->
        <xsl:variable name="Position" select="count(preceding::node()[tokenize(@ana, ' ') = '#bk_entry'])"/>
        <xsl:variable name="Transaction-ID" select="concat('T',  $Position)"/>
       
        <!-- add @xml-id, same like bk:Transaction @rdf:about-->
        <xsl:copy>
            <xsl:attribute name="xml:id" select="$Transaction-ID"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- this template delets all existing @xml:id -->
    <xsl:template match="@xml:id[parent::*[tokenize(@ana, ' ') = '#bk_entry']]">
        
    </xsl:template>
    
    <!-- here could be further TEI-processing -->
    
</xsl:stylesheet>