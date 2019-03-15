<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

    <xsl:template match="@*|node()" >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>




    <!-- matching on all <measure> having not a number in @quantity -->
    <xsl:template match="t:measure[not(number(@quantity))]">
        <!-- here we have the @quantity="-" case, which means 
            that a precceding <measure> not containing '-' and with the same @unit  contains the correct value-->
        <xsl:choose>
            <xsl:when test="@quantity = '-'">
                <xsl:comment>quantity = '-'</xsl:comment>
                <xsl:variable name="currentUnit" select="@unit"/>
                <xsl:variable name="Quantity" select="./preceding::t:measure[@unit = $currentUnit][not(text() = '-')][1]/@quantity"/>
                <measure ana="bk_money #bk_to" commodity="currency" quantity="{$Quantity}" unit="{$currentUnit}">
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
                <measure ana="bk_money #bk_to" commodity="currency" quantity="{$Quantity}" unit="{@unit}">
                    <xsl:apply-templates/>
                </measure>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>ups</xsl:comment>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- adding <date> with @when, @when in <cell> not allowed -->
    <xsl:template match="t:cell[@ana='#bk_when'][@when]">  
        <cell>
            <date ana="#bk_when" when="{@when}">
                <xsl:value-of select="."/>
            </date>
        </cell>
    </xsl:template>
    
    <!-- for every head in a p, replace the head with a span -->
    <xsl:template match="t:p/t:head">  
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
    <xsl:template match="t:cell[@ana = '#bk_what']">
        <cell>
            <xsl:apply-templates/>
        </cell>
    </xsl:template>
    
    <!-- adds @ana to measure | commodity -->
    <xsl:template match="t:cell[@ana = '#bk_what']/t:measure">
        <measure ana="#bk_commodity #bk_from" commodity="{@commodity}">
            <xsl:if test="@unit">
                <xsl:attribute name="unit">
                    <xsl:value-of select="@unit"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="number(@quantity)">
                <xsl:attribute name="quantity">
                    <xsl:value-of select="@quantity"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates></xsl:apply-templates>
            <!-- and in the matching of this template there is the price -->
        </measure>
    </xsl:template>
    
    
    <!-- removes @ana='bk_what' -->
    <xsl:template match="t:cell[@ana = '#bk_amount']">
        <cell>
            <xsl:apply-templates/>
        </cell>
    </xsl:template>
    
    <xsl:template match="t:cell[@ana = '#bk_amount']/t:measure[number(@quantity)]">
        <measure ana="#bk_money #bk_to" commodity="{@commodity}">
            <xsl:if test="@unit">
                <xsl:attribute name="unit">
                    <xsl:value-of select="@unit"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="number(@quantity)">
                <xsl:attribute name="quantity">
                    <xsl:value-of select="@quantity"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </measure>
    </xsl:template>

    
</xsl:stylesheet>

