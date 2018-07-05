<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output omit-xml-declaration="yes"/>
    
    <!-- //////////////////////////////////////// -->
    <!-- copy everything -->
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- //////////////////////////////////////// --> 
    <!-- adding PIF dor GAMS -->
    <xsl:template match="*:teiHeader/*:fileDesc/*:publicationStmt">
        <publicationStmt>
            <publisher>Zentrum für Informationsmodellierung - Universität Graz</publisher>
            <idno type="PID"><xsl:value-of select="concat('o:medea.wheaton.', //*:pb[1]/@n)"/></idno>
        </publicationStmt>
    </xsl:template>
    
    <!-- //////////////////////////////////////// --> 
    <!-- adding CONTEXT to sourceDes-->
    <xsl:template match="*:teiHeader/*:fileDesc/*:sourceDesc">
        <sourceDesc>
            <list>
                <item>
                    <ref target="info:fedora/context:medea.wheaton" type="context">Wheaton Financial Papers</ref>
                </item>
            </list>
            <xsl:apply-templates/>
        </sourceDesc>
    </xsl:template>
    
    
    
    
 
    
    <!-- //////////////////////////////////////// --> 
    <!-- Wheaton is always ana="#bk_from" -->
    <xsl:template match="//*:teiHeader/*:fileDesc/*:titleStmt/*:author">
        <author ana="#bk_from" ref="#pers_MightyWheatonHimself">
            <xsl:apply-templates/>
        </author>
    </xsl:template>
    
    <xsl:template match="*:cell">
        <cell>
            <xsl:apply-templates/>
        </cell>
    </xsl:template>

    <!-- //////////////////////////////////////// -->    
    <!-- for all <row> with text, empty rows can not be a bk_entry -->
    <xsl:template match="*:row[*:cell/*:measure]">
            <row>
                <xsl:if test="@xml:id">
                    <xsl:attribute name="xml:id" select="@xml:id"/>
                </xsl:if>
                <xsl:attribute name="ana" select="'#bk_entry'"/>
                
                <xsl:variable name="Between">
                 <xsl:choose>
                     <!-- name/@ref is in the same entry -->
                     <xsl:when test=".//*:name/@ref">
                         <xsl:value-of select=".//*:name/@ref"/>
                     </xsl:when>
                     <!-- name/@ref is in the first preceding row -->
                     <xsl:when test="preceding-sibling::*:row/*:cell/*:name/@ref">
                         <xsl:value-of select="preceding-sibling::*:row[1]/*:cell/*:name/@ref"/>
                     </xsl:when>
                     <xsl:otherwise/>
                 </xsl:choose>
                </xsl:variable>

                <xsl:apply-templates/>
            </row>
    </xsl:template>
    <!-- empty rows, just for textstructure -->
    <xsl:template match="*:row[not(*:cell//text())]">
        <row xml:id="{@xml:id}">
            <xsl:apply-templates/>
        </row>
    </xsl:template>
    
    
    <!-- //////////////////////////////////////// -->
    <!-- add #bk_money (dollars, cents) or #bk_commodity to <measure> -->
    <xsl:template match="*:measure">
        <measure>
            <xsl:if test="@commodity">
                <xsl:attribute name="commodity" select="@commodity"></xsl:attribute>
            </xsl:if>
            <xsl:if test="@quantity">
                <xsl:attribute name="quantity" select="@quantity"></xsl:attribute>
            </xsl:if>
            <xsl:if test="@unit">
                <xsl:attribute name="unit" select="@unit"></xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <!-- @commodity from Wheaton to xy
                     @money from xy to Wheaton -->
                <!--<xsl:when test="@commodity = 'tax'">
                    <xsl:attribute name="ana"><xsl:text>#bk_money #bk_from</xsl:text></xsl:attribute>
                </xsl:when>-->
                <xsl:when test="@unit = 'dollars' or @unit = 'cents'">
                    <xsl:attribute name="ana"><xsl:text>#bk_money #bk_to</xsl:text></xsl:attribute>
                </xsl:when>
                <!-- work -->
                <xsl:when test="@commodity = 'labor'">
                    <xsl:attribute name="ana"><xsl:text>#bk_service #bk_from</xsl:text></xsl:attribute>
                </xsl:when>
                <xsl:when test="@unit = 'lbs' or contains(@unit,'pecks') or contains(@unit,'load') 
                    or contains(@unit,'bushel') or contains(@unit,'feet') or contains(@unit,'count') 
                    or contains(@unit,'pint') or (@unit = 'ft') or contains(@unit,'barrel')">
                    <xsl:attribute name="ana"><xsl:text>#bk_commodity #bk_from</xsl:text></xsl:attribute>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:apply-templates/>
        </measure>
    </xsl:template>
    
    <!-- //////////////////////////////////////// -->
    <!-- add bk_when to <date> -->
    <xsl:template match="*:cell/*:date">
        <date when="{@when}">
            <xsl:attribute name="ana"><xsl:text>#bk_when</xsl:text></xsl:attribute>
            <xsl:apply-templates/>
        </date>
    </xsl:template>
    <!-- in head, skip bk_when-->
    <xsl:template match="*:head/*:date">
        <date when="{@when}">
            <xsl:apply-templates/>
        </date>
    </xsl:template>
    
    <!-- //////////////////////////////////////// -->
    <!-- add bk_from -->
    <xsl:template match="*:body//*:name">
        <xsl:choose>
            <!-- if LMWcash than MightyWheaton gets Money -->
            <xsl:when test="@ref = 'LMWcash'">
                <name type="{@type}" ref="{@ref}">
                    <xsl:attribute name="ana"><xsl:text>#bk_to</xsl:text></xsl:attribute>
                    <xsl:apply-templates/>
                </name>
            </xsl:when>
            <xsl:otherwise>
                <name type="{@type}" ref="{@ref}">
                    <xsl:attribute name="ana"><xsl:text>#bk_to</xsl:text></xsl:attribute>
                    <xsl:apply-templates/>
                </name>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- //////////////////////////////////////// -->
    <!-- add bk_to -->

    
    
</xsl:stylesheet>