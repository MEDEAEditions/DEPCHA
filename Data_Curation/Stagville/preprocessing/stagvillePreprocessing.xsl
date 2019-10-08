<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   version="2.0">

    <xsl:output encoding="UTF-8" indent="yes" method="xml"></xsl:output>
    
    <xsl:template match="@*|node()" >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="*:publicationStmt" >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <idno type="PID">o:depcha.stagville.1</idno>
            <ref target="context:depcha.stagville" type="context">Stagville
                Plantation Store</ref>
        </xsl:copy>
    </xsl:template>

   

    <!-- matching on all <measure> having not a number in @quantity -->
    <xsl:template match="*:measure[@quantity]">
        <!-- here we have the @quantity="-" case, which means 
            that a precceding <measure> not containing '-' and with the same @unit  contains the correct value-->
        <xsl:choose>
            <xsl:when test="@quantity = '-'">
                <xsl:comment>quantity = '-'</xsl:comment>
                <xsl:variable name="currentUnit" select="@unit"/>
                <xsl:variable name="Quantity" select="./preceding::*:measure[@unit = $currentUnit][not(text() = '-')][1]/@quantity"/>
                <measure commodity="{@commodity}" quantity="{$Quantity}" unit="{$currentUnit}">
                    <xsl:call-template name="moneyOrCommodity"/>
                    <xsl:apply-templates/>
                </measure>
            </xsl:when>
            <!-- containing '/' -->
            <xsl:when test="contains(@quantity, '/')">
                <xsl:comment>'/'</xsl:comment>
                <xsl:variable name="Quantity">
                    <xsl:choose>
                        <xsl:when test="@quantity = '1/2'">
                            <xsl:text>0.5</xsl:text>
                        </xsl:when>
                        <xsl:when test="@quantity = '1/4'">
                            <xsl:text>0.25</xsl:text>
                        </xsl:when>
                        <xsl:when test="@quantity = '1/5'">
                            <xsl:text>0.20</xsl:text>
                        </xsl:when>
                        <xsl:when test="@quantity = '1/8'">
                            <xsl:text>0.125</xsl:text>
                        </xsl:when>
                        <xsl:when test="@quantity = '3/4'">
                            <xsl:text>0.75</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>0</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <measure commodity="{@commodity}" quantity="{$Quantity}">
                    <xsl:if test="@unit">
                        <xsl:attribute name="unit">
                            <xsl:value-of select="@unit"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="moneyOrCommodity"/>
                    <xsl:apply-templates/>
                </measure>
            </xsl:when>
            <xsl:when test="number(@quantity)">
                <measure commodity="{@commodity}" quantity="{@quantity}">
                    <xsl:if test="@unit">
                        <xsl:attribute name="unit">
                            <xsl:value-of select="@unit"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="moneyOrCommodity"/>
                    <xsl:apply-templates/>
                </measure>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>empty:</xsl:comment><xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- adding <date> with @when, @when in <cell> not allowed -->
    <xsl:template match="*:cell[@ana='#bk_when']">  
        <cell>
            <xsl:if test="@when">
                <date ana="#bk_when" when="{@when}">
                    <xsl:value-of select="."/>
                </date>
            </xsl:if>
        </cell>
    </xsl:template>
    
    <!-- for every head in a p, replace the head with a span -->
    <xsl:template match="*:p/*:head">  
        <span n="{@n}">
            <xsl:if test="@ana">
                <xsl:attribute name="ana">
                    <xsl:value-of select="@ana"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <!-- removes @ana='bk_what' -->
    <xsl:template match="*:cell[@ana = '#bk_what']">
        <cell>
            <xsl:apply-templates/>
        </cell>
    </xsl:template>

    <!-- removes @ana='bk_amount' -->
    <xsl:template match="*:cell[@ana = '#bk_amount']">
        <cell>
            <xsl:apply-templates/>
        </cell>
    </xsl:template>

    <xsl:template name="moneyOrCommodity">
        <xsl:choose>
            <xsl:when test="..[@ana='#bk_amount']">
                <xsl:attribute name="ana">
                    <xsl:text>#bk_money #bk_from</xsl:text>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="ana">
                    <xsl:text>#bk_commodity #bk_to</xsl:text>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>

