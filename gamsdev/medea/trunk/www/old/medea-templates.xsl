<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:functx="http://www.functx.com"
    xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="#all">
    
    <!--  -->
    <xsl:variable name="TEI_HEADER" select="t:TEI/t:teiHeader"/>
    
    <!-- FROM used in TEIobject and TORDF -->
    <xsl:variable name="FromInHeader">
        <xsl:choose>
            <xsl:when test="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_from']">
                <xsl:value-of select="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_from']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
  
    <!-- TO used in TEIobject and TORDF-->
    <xsl:variable name="ToInHeader">
        <xsl:choose>
            <xsl:when test="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_to']">
                <xsl:value-of select="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_to']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <!-- DATE used in TEIobject and TORDF-->
    <xsl:variable name="DateInHeader">
        <xsl:choose>
            <xsl:when test="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_when']">
                <xsl:choose>
                    <xsl:when test="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_when']/@when">
                        <xsl:value-of select="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_when']/@when"/>
                    </xsl:when>
                    <xsl:when test="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_when']/@from">
                        <xsl:value-of select="$TEI_HEADER//*[tokenize(@ana, ' ') = '#bk_when']/@from"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>@?</xsl:text>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>false</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!-- ////////////////////////// -->
    <!-- ////////////  -->
    
    <!-- get_bk_from -->
    <xsl:template name="get_bk_">
        <xsl:param name="actualTerm"/>
        <!--<xsl:param name="actualEntry"/>-->

        <xsl:choose>
            <!-- bk_ in entry -->
            <xsl:when test=".//*[tokenize(@ana, ' ') = $actualTerm]">
                <xsl:call-template name="getCorrespRefWhen">
                    <xsl:with-param name="actualPath" select=".//*[tokenize(@ana, ' ') = $actualTerm]"/>
                </xsl:call-template>
            </xsl:when>
            <!-- bk_ before entry -->
            <xsl:when test="../child::*/*[tokenize(@ana, ' ') = $actualTerm]">
                <xsl:call-template name="getCorrespRefWhen">
                    <xsl:with-param name="actualPath" select="../child::*/*[tokenize(@ana, ' ') = $actualTerm]"/>
                </xsl:call-template>
            </xsl:when>
        	<!-- parent element -->
        	<xsl:when test="./..[tokenize(@ana, ' ') = $actualTerm]">
                <xsl:call-template name="getCorrespRefWhen">
                    <xsl:with-param name="actualPath" select="./..[tokenize(@ana, ' ') = $actualTerm]"/>
                </xsl:call-template>
            </xsl:when>
            <!--ToDo: this solution is just for the srbas-data 
                eine vorfahr-sturktur ist ein bk_from, also ist dieser Eintrag auch einer-->
            <xsl:when test="./ancestor::*[tokenize(@ana, ' ') = $actualTerm]">
                <xsl:value-of select="substring-before(@xml:id, '-')"/>
            </xsl:when>
        	<!-- ancestor/children -->
        	<xsl:when test=".//ancestor::*//*[tokenize(@ana, ' ') = $actualTerm]">
        		<xsl:call-template name="getCorrespRefWhen">
                    <xsl:with-param name="actualPath" select=".//ancestor::*//*[tokenize(@ana, ' ') = $actualTerm]"/>
                </xsl:call-template>
        	</xsl:when>
            <!-- bk_from in header -->
            <xsl:when test="not($FromInHeader = 'false') and $actualTerm = '#bk_from'">
                <xsl:value-of select="$FromInHeader"/>
            </xsl:when>
            <!-- bk_to in header -->
            <xsl:when test="not($ToInHeader = 'false') and $actualTerm = '#bk_to'">
                <xsl:value-of select="$ToInHeader"/>
            </xsl:when>
            <!-- bk_when in header -->
            <xsl:when test="not($DateInHeader = 'false') and $actualTerm = '#bk_when'">
                <xsl:value-of select="$DateInHeader"/>
            </xsl:when>
            <!-- ToDo: t:front -->
            <xsl:when test="//t:front//*[tokenize(@ana, ' ') = $actualTerm]">
                <xsl:value-of select="//t:front//*[tokenize(@ana, ' ') = $actualTerm]"/>
            </xsl:when>
            <!-- no bk_ -->
            <xsl:otherwise>
                <xsl:text>unknown</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="getCorrespRefWhen">
        <xsl:param name="actualPath"/>
        <xsl:choose>
            <xsl:when test="$actualPath/@when">
                <xsl:value-of select="$actualPath/@when"/>
            </xsl:when>
            <xsl:when test="$actualPath/@corresp">
                <xsl:value-of select="$actualPath/@corresp"/>
            </xsl:when>
            <xsl:when test="$actualPath/@ref">
                <xsl:value-of select="$actualPath/@ref"/>
            </xsl:when>
        	<xsl:when test="$actualPath/@from">
                <xsl:value-of select="$actualPath/@from"/>
            </xsl:when>
        	<xsl:when test="$actualPath/@xml:id">
                <xsl:value-of select="$actualPath/@xml:id"/>
            </xsl:when>
        	<xsl:otherwise>missing @</xsl:otherwise>
          <!--  <xsl:otherwise>
                <xsl:choose>
                	<xsl:when test="$actualPath/@xml:id">
                		<xsl:value-of select="$actualPath/@xml:id"/>
                	</xsl:when>
                	<xsl:otherwise>missing @</xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>-->
        </xsl:choose>
    </xsl:template>
    

    
</xsl:stylesheet>