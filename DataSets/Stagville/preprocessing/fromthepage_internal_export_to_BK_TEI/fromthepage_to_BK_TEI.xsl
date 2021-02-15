<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" exclude-result-prefixes="#all">


    <xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>

    <!-- ~ -->
    <xsl:variable name="DATE" select="'1808-08'"/>
    <xsl:variable name="quot">"</xsl:variable>

    <xsl:variable name="Persons"
        select="//*:category[ancestor-or-self::*:category[*:catDesc/text() = 'persons']]"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- /// -->
    <!-- fix t:taxonomy:  
        * t:note contains superclasses; hiearchy exists in tree structurer of t:category 
        * t:gloss > t:term 
        * persons to persList-->
    <xsl:template match="*:taxonomy">
        <taxonomy ana="bk:Taxonomy">
            <xsl:apply-templates/>
        </taxonomy>
    </xsl:template>
    <!-- *:category -->
    <xsl:template
        match="*:category[not(ancestor-or-self::*:category[*:catDesc/text() = 'persons'])]">
        <category xml:id="{@xml:id}">
            <gloss>
                <xsl:choose>
                    <xsl:when test="*:catDesc/*:term">
                        <xsl:value-of select="*:catDesc/*:term"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="*:catDesc"/>
                    </xsl:otherwise>
                </xsl:choose>
            </gloss>
            <xsl:apply-templates/>
        </category>
    </xsl:template>

    <!-- /// -->
    <!-- persons -->
    <!-- all all *:category with *:catDesc/text() = 'persons' as its ancestor to the listPerson; put 'enslaved', creditor into @role  -->
    <xsl:template match="*:profileDesc">
        <profileDesc>
            <particDesc>
                <listPerson ana="bk:Between">
                    <head>Prosopography</head>
                    <xsl:for-each
                        select="//*:category[ancestor-or-self::*:category[*:catDesc/text() = 'persons']][*:catDesc/*:term]">
                        <person xml:id="{@xml:id}">
                            <xsl:if test="../*:catDesc">
                                <xsl:attribute name="role">
                                    <xsl:value-of select="../*:catDesc"/>
                                </xsl:attribute>
                            </xsl:if>
                            <name>
                                <xsl:value-of select="*:catDesc/*:term"/>
                            </name>
                        </person>
                    </xsl:for-each>
                </listPerson>
            </particDesc>
        </profileDesc>
    </xsl:template>

    <!-- /// -->
    <!-- transform html table to tei table; remove thead - Date|Item and price|L|s|d -->
    <xsl:template match="*:thead"/>
    <!-- /// -->
    <xsl:template match="*:tbody">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    <!-- /// -->
    <xsl:template match="*:tr">
        <row>
            <xsl:attribute name="ana">
                <xsl:choose>
                    <xsl:when test="*:td[2]/text()">
                        <xsl:text>bk:entry</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>bk:sum</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>
        </row>
    </xsl:template>
    <!-- /// -->
    <!-- Date -->
    <xsl:template match="*:td[1]">
        <xsl:choose>
            <xsl:when test="text()">
                <cell>
                    <xsl:choose>
                        <xsl:when test="normalize-space(text()) = $quot">
                            <xsl:variable name="DateInRowBefore"
                                select="normalize-space(../preceding-sibling::*:tr[1]/*:td[1]/text())"/>
                            <xsl:choose>
                                <xsl:when test="number($DateInRowBefore)">
                                    <date ana="bk:when">
                                        <xsl:attribute name="when">
                                            <xsl:value-of
                                                select="
                                                    if (number($DateInRowBefore) &lt; 10) then
                                                        concat($DATE, '-0', $DateInRowBefore)
                                                    else
                                                        concat($DATE, '-', $DateInRowBefore)"
                                            />
                                        </xsl:attribute>
                                    </date>
                                </xsl:when>
                                <!-- this code is bad :/ -->
                                <xsl:when
                                    test="$DateInRowBefore = $quot and normalize-space(../preceding-sibling::*:tr[2]/*:td[1]/text()) = $quot and number(normalize-space(../preceding-sibling::*:tr[3]/*:td[1]/text()))">
                                    <date ana="bk:when">
                                        <xsl:variable name="DateInRowBefore"
                                            select="normalize-space(../preceding-sibling::*:tr[3]/*:td[1]/text())"/>
                                        <xsl:attribute name="when">
                                            <xsl:value-of
                                                select="
                                                    if (number($DateInRowBefore) &lt; 10) then
                                                        concat($DATE, '-0', $DateInRowBefore)
                                                    else
                                                        concat($DATE, '-', $DateInRowBefore)"
                                            />
                                        </xsl:attribute>
                                    </date>
                                </xsl:when>
                                <!-- this code is bad :/ -->
                                <xsl:when
                                    test="$DateInRowBefore = $quot and number(normalize-space(../preceding-sibling::*:tr[2]/*:td[1]/text()))">
                                    <date ana="bk:when">
                                        <xsl:variable name="DateInRowBefore"
                                            select="normalize-space(../preceding-sibling::*:tr[2]/*:td[1]/text())"/>
                                        <xsl:attribute name="when">
                                            <xsl:value-of
                                                select="
                                                    if (number($DateInRowBefore) &lt; 10) then
                                                        concat($DATE, '-0', $DateInRowBefore)
                                                    else
                                                        concat($DATE, '-', $DateInRowBefore)"
                                            />
                                        </xsl:attribute>
                                    </date>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="number(normalize-space(text()))">
                            <date ana="bk:when">
                                <xsl:attribute name="when">
                                    <xsl:value-of
                                        select="
                                            if (number(normalize-space(.)) &lt; 10) then
                                                concat($DATE, '-0', normalize-space(.))
                                            else
                                                concat($DATE, '-', normalize-space(.))"
                                    />
                                </xsl:attribute>
                            </date>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </cell>
            </xsl:when>
            <xsl:otherwise>
                <cell/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- Item and price -->
    <xsl:template match="*:td[2]">
        <xsl:choose>
            <xsl:when test="text()">
                <cell>
                    <!-- grabs the string before the *:rs, which is bk:unit and bk:quantity -->
                    <xsl:for-each select="*:rs">
                        <xsl:variable name="textBefore" select="parent::*:td/text()[1]"/>
                        <!-- todo normalizing quantity and unit is hard  -->
                        <measure ana="bk:commodity" commodity="{@ref}">
                            <xsl:choose>
                                <xsl:when test="contains($textBefore, 'lb')">
                                    <xsl:attribute name="unit" select="'lb'"/>
                                    <xsl:attribute name="quantity">
                                        <xsl:choose>
                                            <xsl:when test="number(normalize-space(substring-before($textBefore, 'lb')))">
                                                <xsl:value-of select="normalize-space(substring-before($textBefore, 'lb'))"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="0"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise/>
                            </xsl:choose>
                            <xsl:value-of select="concat(parent::*:td/text()[1], .)"/>
                        </measure>
                    </xsl:for-each>
                </cell>
            </xsl:when>
            <xsl:otherwise>
                <cell/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- L -->
    <xsl:template match="*:td[3]">
        <xsl:call-template name="getCellwithMoney">
            <xsl:with-param name="Unit" select="'pound'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- s -->
    <xsl:template match="*:td[4]">
        <xsl:call-template name="getCellwithMoney">
            <xsl:with-param name="Unit" select="'shilling'"/>
        </xsl:call-template>
    </xsl:template>
    <!-- d -->
    <xsl:template match="*:td[5]">
        <xsl:call-template name="getCellwithMoney">
            <xsl:with-param name="Unit" select="'pence'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- //// -->
    <xsl:template name="getCellwithMoney">
        <xsl:param name="Unit"/>
        <xsl:choose>
            <xsl:when test="text()">
                <cell>
                    <measure ana="bk:money" unit="{$Unit}">
                        <xsl:choose>
                            <xsl:when test="text() = '-'">
                                <xsl:attribute name="quantity">
                                    <xsl:text>0</xsl:text>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="text()">
                                <xsl:attribute name="quantity">
                                    <xsl:value-of select="normalize-space(text()[1])"/>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                        <xsl:value-of select="normalize-space(.)"/>
                    </measure>
                </cell>
            </xsl:when>
            <xsl:otherwise>
                <cell/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--  -->
    <xsl:template match="*:table[preceding-sibling::*:head[1]]">
        <xsl:variable name="currentPrecedingHead" select="preceding-sibling::*:head[1]"/>
        <xsl:variable name="currentPerson">
            <xsl:for-each select="$Persons//*:term">
                <xsl:if test="contains(normalize-space($currentPrecedingHead), normalize-space(.))">
                    <xsl:value-of select="./ancestor::*:category[1]/@xml:id"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <div>
            <head>
                <name>
                    <xsl:if test="$currentPerson != ''">

                        <xsl:attribute name="ref" select="$currentPerson"/>
                        <xsl:attribute name="ana" select="'bk:from'"/>
                    </xsl:if>
                    <xsl:value-of select="$currentPrecedingHead"/>
                </name>
            </head>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <!--  -->
    <xsl:template match="*:table">
        <xsl:apply-templates/>
    </xsl:template>
    <!--  -->
    <!--<xsl:template match="*:p[*:table]">
        <!-\-<div>
            <xsl:apply-templates select="@* | node()"/>
        </div>-\->
    </xsl:template>-->

    <!-- fix: t::head not allowed in t:p -->
    <xsl:template match="*:p[*:head]">
        <div>
            <xsl:apply-templates select="@* | node()"/>
        </div>
    </xsl:template>

    <xsl:template match="*:body//*:p[not(*:head)]">
        <div>
            <p>
                <xsl:apply-templates select="@* | node()"/>
            </p>
        </div>
    </xsl:template>


    <xsl:template match="*:p/*:head[following-sibling::*:table][position() > 1]"/>

    <xsl:template match="*:p/*:head[not(following-sibling::*:table)]">
        <xsl:variable name="currentPrecedingHead" select="."/>
        <xsl:variable name="currentPerson">
            <xsl:for-each select="$Persons//*:term">
                <xsl:if test="contains(normalize-space($currentPrecedingHead), normalize-space(.))">
                    <xsl:value-of select="./ancestor::*:category[1]/@xml:id"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <div>
            <head>
                <name>
                    <xsl:if test="$currentPerson != ''">

                        <xsl:attribute name="ref" select="$currentPerson"/>
                        <xsl:attribute name="ana" select="'bk:from'"/>

                    </xsl:if>
                </name>
                <xsl:apply-templates/>
            </head>
            <!--<xsl:apply-templates select="../following-sibling::*:p[1]/*:table//*:tbody"/>-->
        </div>
    </xsl:template>

    <!-- skip -->
    <xsl:template match="*:category[ancestor-or-self::*:category[*:catDesc/text() = 'persons']]"/>
    <xsl:template match="@class"/>
    <xsl:template match="@title"/>
    <xsl:template match="@depth"/>
    <xsl:template match="*:catDesc"/>
    <xsl:template match="*:lb"/>
    <xsl:template match="*:catDesc/*:term"/>
    <xsl:template match="*:catDesc/*:note"/>
    <!-- revisionDesc -->
    <xsl:template match="*:revisionDesc"/>
    <xsl:template match="*:body//*:p[not(text())]"/>

</xsl:stylesheet>
