<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs tei #default" version="3.0">

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Changing #bk_amount to bk:money -->

    <xsl:template match="*[@ana = '#bk_amount']">
        <xsl:copy>
            <xsl:attribute name="ana" select="'bk:money'"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Changing #bk_entry to bk:entry -->

    <xsl:template match="*[@ana = '#bk_entry']">
        <xsl:copy>
            <xsl:attribute name="ana" select="'bk:entry'"/>
            <xsl:apply-templates select="@* | node()"/>

            <!-- installing bk:from -->
            <xsl:element name="name">
                <xsl:attribute name="ana" select="'bk:from'"/>
                <xsl:attribute name="ref">
                    <xsl:choose>
                        <xsl:when test="ancestor::*[tokenize(@ana, ' ') = '#bs_Einnahmen']">
                            <xsl:value-of select="concat('#', @xml:id)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'#stadtbasel'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>

            <!-- installing bk:to -->
            <xsl:element name="name">
                <xsl:attribute name="ana" select="'bk:to'"/>
                <xsl:attribute name="ref">
                    <xsl:choose>
                        <xsl:when test="ancestor::*[tokenize(@ana, ' ') = '#bs_Einnahmen']">
                            <xsl:value-of select="'#stadtbasel'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('#', @xml:id)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:element>
        </xsl:copy>
    </xsl:template>

    <!-- Adding bk:money attribute to measure elements !-->

    <xsl:template match="*:measure[..[@ana = '#bk_amount']]">
        <xsl:copy>
            <xsl:attribute name="ana" select="'bk:money'"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- changing #bk_total to bk:total  -->

    <xsl:template match="*[@ana = '#bk_total']">
        <xsl:copy>
            <xsl:attribute name="ana" select="'bk:total'"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@ana"/>

    <!-- Adding <ref> after <idno> -->

    <xsl:template match="*:publicationStmt/*:idno">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:value-of select="concat('o:depcha.', substring-after(., 'o:'))"/>
        </xsl:copy>
        <ref target="context:depcha.srbas" type="context">Jahrrechnungen der Stadt Basel 1535 bis
            1610 – digital</ref>
    </xsl:template>


    <xsl:template match="*:encodingDesc">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <!-- adding listPrefixDef -->
            <listPrefixDef>
                <prefixDef ident="bk" matchPattern="([(a-z)|(A-Z)]+)"
                    replacementPattern="https://gams.uni-graz.at/o:depcha.bookkeeping#$1">
                    <p> Analytical descriptors are considered to represent concepts from the DEPCHA
                        bookkeeping ontology and can be extended to respective URIs. </p>
                </prefixDef>
                <prefixDef ident="depcha" matchPattern="([(a-z)|(A-Z)]+)"
                    replacementPattern="https://gams.uni-graz.at/o:depcha.ontology#$1">
                    <p> Analytical descriptors are considered to represent concepts from the
                        project-specific DEPCHA ontology and can be extended to respective URIs.
                    </p>
                </prefixDef>
                <prefixDef ident="wd" matchPattern="([(a-z)|(A-Z)]+)"
                    replacementPattern="http://www.wikidata.org/entity/$1">
                    <p>
                        <ref target="https://www.wikidata.org/wiki/Help:Namespaces"/>
                    </p>
                </prefixDef>
            </listPrefixDef>
            <!-- Adding unitDecl and currencies -->
            <unitDecl>
                <unitDef type="currency" xml:id="lb" ana="depcha:mainCurrency">
                    <label xml:lang="de">Pfund</label>
                    <label type="abbreviation">lb</label>
                    <country>Schweiz</country>
                    <conversion fromUnit="#lb" toUnit="#ß-w" formula="$fromUnit div 20"/>
                    <conversion fromUnit="#lb" toUnit="#d" formula="$fromUnit div 240"/>
                </unitDef>
                <unitDef type="currency" xml:id="ß-w">
                    <label xml:lang="de">Schilling</label>
                    <label type="abbreviation">ß</label>
                    <country>Schweiz</country>
                </unitDef>
                <unitDef type="currency" xml:id="d">
                    <label xml:lang="de">Pfennig</label>
                    <label type="abbreviation">d</label>
                    <country>Schweiz</country>
                </unitDef>
            </unitDecl>
            <!-- Adding classDecl and  taxonomy with incomes and expenses -->
            <classDecl>
                <taxonomy ana="bk:account">
                    <category ana="depcha:accountHolder" xml:id="stadtbasel">
                        <catDesc>
                            <gloss>Stadt Basel</gloss>
                        </catDesc>
                    </category>
                    <category ana="bk:from" xml:id="income">
                        <catDesc>
                            <gloss>Income</gloss>
                        </catDesc>
                        <xsl:for-each-group group-by="@ana"
                            select="//*:div[..[@ana = '#bs_StadtEinnahmen']]">
                            <xsl:if test="current-grouping-key()">
                                <category xml:id="{substring-after(current-grouping-key(),'#')}">
                                    <catDesc>
                                        <gloss>
                                            <xsl:value-of
                                                select="replace(substring-after(current-grouping-key(), '#bs_'), '(.+?)([A-Z].*?)', '$1 $2')"
                                            />
                                        </gloss>
                                    </catDesc>
                                </category>
                            </xsl:if>
                        </xsl:for-each-group>
                    </category>
                    <category ana="bk:to" xml:id="expense">
                        <catDesc>
                            <gloss>Expense</gloss>
                        </catDesc>
                        <xsl:for-each-group group-by="@ana"
                            select="//*:div[..[@ana = '#bs_StadtAusgaben']]">
                            <xsl:if test="current-grouping-key()">
                                <category xml:id="{substring-after(current-grouping-key(), '#')}">
                                    <catDesc>
                                        <gloss>
                                            <xsl:value-of
                                                select="replace(substring-after(current-grouping-key(), '#bs_'), '(.+?)([A-Z].*?)', '$1  $2')"
                                            />
                                        </gloss>
                                    </catDesc>
                                </category>
                            </xsl:if>
                        </xsl:for-each-group>
                    </category>
                </taxonomy>
            </classDecl>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Changing the ana attribute to corresp and adding new ana attribute with the value of bk:account   -->

    <xsl:template match="//*:div[..[@ana = '#bs_StadtEinnahmen']]">
        <xsl:copy>
            <xsl:if test="@ana">
                <xsl:attribute name="corresp">
                    <xsl:value-of select="@ana"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="ana" select="'bk:account'"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Changing the ana attribute to corresp and adding new ana attribute with the value of bk:account   -->

    <xsl:template match="//*:div[..[@ana = '#bs_StadtAusgaben']]">
        <xsl:copy>
            <xsl:if test="@ana">
                <xsl:attribute name="corresp">
                    <xsl:value-of select="@ana"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="ana" select="'bk:account'"/>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- removing facsimiles and child nodes -->

    <xsl:template match="*:facsimile"/>

    <!-- removeing segs -->

    <xsl:template match="//*:seg" priority="1">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
