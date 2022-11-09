<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"
    version="2.0">
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- skip -->
    <xsl:template match="*:lb/@n"/>
    <xsl:template match="*:lb/@facs | *:ab/@facs"/>
    <xsl:template match="*:ab[not(text())]"/>
    <xsl:template match="*:table[.//*[not(text())]]"/>
    
    <!-- select textnodes that contain "Item" -> bk:entry -->
    <xsl:template match="//text()[contains(., 'Item')]">
        <seg ana="bk:entry">
            <xsl:call-template name="weird_analyzeString_for_measure_money"/>
        </seg>
    </xsl:template>
    
    <!-- select textnodes that contain "Summa" -> bk:subtotal -->
    <xsl:template match="//text()[contains(., 'Summa')]">
        <xsl:choose>
            <xsl:when test="contains(., 'Summa summarum')">
                <seg ana="bk:total">
                    <xsl:call-template name="weird_analyzeString_for_measure_money"/>
                </seg>
            </xsl:when>
            <xsl:otherwise>
                <seg ana="bk:subtotal">
                    <xsl:call-template name="weird_analyzeString_for_measure_money"/>
                </seg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- add info for ingest in GAMS -->
    <xsl:template match="//*:publicationStmt">
        <xsl:copy>
            <publisher>Zentrum für Informationsmodellierung - Universität Graz</publisher>
            <ref target="context:depcha.krems" type="context">Stadbaumeisteramt Krems</ref>
            <idno type="PID">o:depcha.krems.1457</idno>
        </xsl:copy>
    </xsl:template>
    
    <!-- add listPrefixDef -->
    <xsl:template match="//*:fileDesc">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
        <encodingDesc>
            <listPrefixDef>
                <prefixDef ident="bk" matchPattern="([(a-z)|(A-Z)]+)" replacementPattern="https://gams.uni-graz.at/o:depcha.bookkeeping#$1">
                    <p>Analytical descriptors are considered to represent concepts from the DEPCHA bookkeeping ontology and can be extended to respective URIs.</p>
                </prefixDef>
                <prefixDef ident="depcha" matchPattern="([(a-z)|(A-Z)]+)" replacementPattern="https://gams.uni-graz.at/o:depcha.ontology#$1">
                    <p>Analytical descriptors are considered to represent concepts from the project-specific DEPCHA ontology and can be extended to respective URIs.</p>
                </prefixDef>
                <prefixDef ident="wd" matchPattern="([(a-z)|(A-Z)]+)" replacementPattern="http://www.wikidata.org/entity/$1">
                    <p>
                        <ref target="https://www.wikidata.org/wiki/Help:Namespaces"/>
                    </p>
                </prefixDef>
            </listPrefixDef>
            <unitDecl>
                <unitDef type="currency" xml:id="tl">
                    <label>tl</label>
                </unitDef>
                <unitDef type="currency" xml:id="ß">
                    <label>ß</label>
                    <country>France</country>
                </unitDef>
                <unitDef type="currency" xml:id="d">
                    <label>d</label>
                </unitDef>
            </unitDecl>
        </encodingDesc>
    </xsl:template>
    
    <xsl:template name="weird_analyzeString_for_measure_money">
        <xsl:analyze-string select="." regex="(\d+) ß.">
            <xsl:matching-substring>
                <measure ana="bk:money" unitRef="#ß" quantity="{regex-group(1)}">
                    <xsl:value-of select="."/>
                </measure>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!-- d. -->
                <xsl:analyze-string select="." regex="(\d+) d.">
                    <xsl:matching-substring>
                        <measure ana="bk:money" unitRef="#ß" quantity="{regex-group(1)}">
                            <xsl:value-of select="."/>
                        </measure>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <!-- tl. -->
                        <xsl:analyze-string select="." regex="(\d+) tl.">
                            <xsl:matching-substring>
                                <measure ana="bk:money" unitRef="#ß" quantity="{regex-group(1)}">
                                    <xsl:value-of select="."/>
                                </measure>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:value-of select="normalize-space(.)"/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
</xsl:stylesheet>