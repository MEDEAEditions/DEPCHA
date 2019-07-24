<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns="http://www.tei-c.org/ns/1.0" version="2.0">


    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Title</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Publication Information</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>

                    <xsl:for-each select="//*:table">
                        <pb n="{position()}"/>
                        <fw type="pageNum">
                            <xsl:value-of select="position()"/>
                        </fw>
                        <table>
                            <xsl:for-each select="*:head">
                                <head>
                                    <date when="{*:date/@when}">
                                        <xsl:value-of select="concat(text(), ' ', *:date)"/>
                                    </date>
                                </head>
                            </xsl:for-each>
                            <xsl:for-each select="*:row[*:cell/*:name | *:cell[2]/text()][*:cell[1]/text()]">
                                <xsl:if test="preceding-sibling::*:row[1]/*:cell[2]/*:date">
                                    <span type="subheading">
                                        <date when="{preceding-sibling::*:row[1]/*:cell[2]/*:date/@when}" ana="#bk_when">
                                            <xsl:value-of select="preceding-sibling::*:row[1]/*:cell[2]/*:date"/>
                                        </date>
                                    </span>
                                </xsl:if>
                                <row ana="#bk_entry">
                                    <xsl:choose>
                                        <xsl:when test="*:cell[1]/text()">
                                            <cell ana="#bk_status" corresp="{concat('#',normalize-space(*:cell[1]))}">
                                                <xsl:value-of select="*:cell[1]"/>
                                            </cell>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <cell/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:apply-templates select="*:cell[2]">
                                            <xsl:with-param name="a">
                                                <xsl:if test="following-sibling::*:row[1]/*:cell[2]/text()">
                                                    <xsl:apply-templates select="./following-sibling::*:row[1]/*:cell[2]"/>
                                                    <!--<xsl:copy>
                                                        <xsl:value-of select="following-sibling::*:row[1]/*:cell[2]"/>
                                                     <!-\-<xsl:apply-templates select="following-sibling::*:row[1]/*:cell[2]"/>-\->
                                                    </xsl:copy>-->
                                                    <!--<xsl:value-of select="following-sibling::*:row[1]/*:cell[2]/text()"/>-->
                                                </xsl:if>
                                            </xsl:with-param>
                                    </xsl:apply-templates>
                                    <cell>
                                        <xsl:apply-templates select="*:cell[3]/*"/>
                                        <xsl:if test="following-sibling::*:row[1]/*:cell[3]/*">
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates select="following-sibling::*:row[1]/*:cell[3]/*"/>
                                        </xsl:if>
                                    </cell>
                                    <cell>
                                        <xsl:apply-templates select="*:cell[4]/*"/>
                                        <xsl:if test="following-sibling::*:row[1]/*:cell[4]/*">
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates select="following-sibling::*:row[1]/*:cell[4]/*"/>
                                        </xsl:if>
                                    </cell>
                                    <cell>
                                        <xsl:apply-templates select="*:cell[5]/*"/>
                                        <xsl:if test="following-sibling::*:row[1]/*:cell[5]/*">
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates select="following-sibling::*:row[1]/*:cell[5]/*"/>
                                        </xsl:if>
                                    </cell>
                                    <cell>
                                        <xsl:apply-templates select="*:cell[6]/*"/>
                                        <xsl:if test="following-sibling::*:row[1]/*:cell[6]/*">
                                            <xsl:text> </xsl:text>
                                            <xsl:apply-templates select="following-sibling::*:row[1]/*:cell[6]/*"/>
                                        </xsl:if>
                                    </cell>
                                </row>
                                
                                <!-- another row with same person -->
                                <xsl:if test="following-sibling::*:row[2][not(*:cell[1]/text())][.//*:measure]">
                                    <row ana="#bk_entry">
                                        <xsl:apply-templates select="following-sibling::*:row[2][not(*:cell[1]/text())][.//*:measure]/*">
                                            <xsl:with-param name="NAME" select="*:cell[2]/*:name/@ref"/>
                                        </xsl:apply-templates>
                                    </row>
                                </xsl:if>
                            </xsl:for-each>
                        </table>

                    </xsl:for-each>


                </body>
            </text>
        </TEI>

    </xsl:template>
    
    <xsl:template match="*:cell[2]">
        <xsl:param name="NAME"/>
        <xsl:param name="a"/>
        <cell>
            <xsl:if test="not(*:name)">
                <xsl:if test="$NAME">
                    <name ana="#bk_to" type="person" ref="{$NAME}"/><xsl:text> </xsl:text>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="@* | node()"></xsl:apply-templates>
            <lb/>
            <xsl:copy-of select="$a"/>
        </cell>
    </xsl:template>
    
    <xsl:template match="*:measure[@commodity='currency']">
        <measure ana="#bk_money #bk_to" commodity="{@commodity}" unit="{@unit}" quantity="{@quantity}">
            <xsl:apply-templates/>
        </measure>
    </xsl:template>
    
    <xsl:template match="*:name[@type='person']">
        <name ana="#bk_to" type="person" ref="{@ref}">
            <xsl:apply-templates/>
        </name>
    </xsl:template>
    
    <xsl:template match="*:measure[not(@commodity='currency')]">
        <measure ana="#bk_commodity #bk_from" commodity="{@commodity}" unit="{@unit}" quantity="{@quantity}">
            <xsl:apply-templates/>
        </measure>
    </xsl:template>
    
    

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@role"/>
    <xsl:template match="@rows"/>
    <xsl:template match="@cols"/>
    <xsl:template match="@full"/>
    <xsl:template match="@instant"/>



</xsl:stylesheet>
