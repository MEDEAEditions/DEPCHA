<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:template match="/">
        <TEI>
         <teiHeader>
             <fileDesc>
                 <titleStmt>
                     <title>Rekening 5066</title>
                     <author>Marika Ceunen</author>
                 </titleStmt>
                 <editionStmt>
                     <edition><date>2019-12-09</date></edition>
                 </editionStmt>
                 <publicationStmt>
                     <publisher>Zentrum für Informationsmodellierung - Universität Graz</publisher>
                     <idno type="PID">o:depcha.leuven.1</idno>
                     <ref target="info:fedora/context:depcha.leuven" type="context">Leuven City Accounts</ref></publicationStmt>
                 <sourceDesc>
                     <p>Converted from a Word document</p>
                 </sourceDesc>
             </fileDesc>
             <encodingDesc>
                 <appInfo>
                     <application xml:id="docxtotei" ident="TEI_fromDOCX" version="2.15.0">
                         <label>DOCX to TEI</label>
                     </application>
                 </appInfo>
             </encodingDesc>
         </teiHeader>
         <text>
             <body>
                 <div>
                    <xsl:apply-templates select="//*:body"/>
                 </div>
             </body>
         </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="*:div">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="*:hi[@rend='Heading_2_Char']">
        <div>
        <head type="subcategory">
            <xsl:apply-templates/>
        </head>
        </div>
    </xsl:template>
    
    <xsl:template match="*:head">
        <head type="maincategory">
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    
    <xsl:template match="*:list">
            <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="*:item">
        <p ana="bk:entry">
            <xsl:variable name="Person" select="substring-before(., ' –')"/>
            <xsl:variable name="Measurable" select="substring-after(., '– ')"/>
            <xsl:choose>
                <xsl:when test="contains(., '–') or contains(., '–')">
                    <name ana="bk:from" ref="{concat('#', substring(replace($Person, ' ', ''), 0, 20))}">
                        <xsl:value-of select="$Person"/>
                    </name>
                    <measure>
                        <xsl:choose>
                            <xsl:when test="contains($Measurable, 'guld(en)')">
                                <xsl:attribute name="ana">
                                    <xsl:text>bk:money</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="unit">
                                    <xsl:text>guilders</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="quantity">
                                    <xsl:text>0</xsl:text>
                                    <!--<xsl:call-template name="for-each-character">  
                                                <xsl:with-param name="sum" select="0"/>
                                                <xsl:with-param name="data" select="substring-before($Measurable, ' guld(en)')"/>
                                            </xsl:call-template>-->
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="ana">
                                    <xsl:text>bk:commodity</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="unit">
                                    <xsl:text>_</xsl:text>
                                </xsl:attribute>
                                <xsl:attribute name="quantity">
                                    <xsl:text>1</xsl:text>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="$Measurable"/>
                    </measure>
                </xsl:when>
                <xsl:otherwise>
                    <span ana="bk:from">
                        <xsl:apply-templates/>
                    </span>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>
    
    <xsl:template match="*:p[@rend='Zitat']">
        <p ana="bk:sum">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    

    <xsl:template match="*:p">
        <p>
           <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="*:note">
        <note>
            <xsl:apply-templates/>
        </note>
    </xsl:template>
    
    <xsl:template match="*:note/*:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <!--  <p><hi rend="bold">folio 9v°</hi></p> -->
    <xsl:template match="*:p[*:hi]">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="*:hi[@rend][contains(text(), 'folio')]">
        <xsl:variable name="number" select="normalize-space(upper-case((substring-after(., 'folio '))))"/>
        <pb n="{$number}" facs="{concat('https://www.itineranova.be/in/SAL5066/', $number, '/folio-account-book')}"/>
    </xsl:template>
    
    <!-- roman to normalized number -->
    <!--<xsl:template name="for-each-character">
        <xsl:param name="sum"/>
        <xsl:param name="data"/>
        <xsl:if test="string-length($data) &gt; 0">
            <xsl:variable name="calc">
                <xsl:choose>
                    <xsl:when test="substring($data,1,1) = 'i'">
                        <xsl:value-of select="number($sum) + 1"/>
                    </xsl:when>
                    <xsl:when test="substring($data,1,1) = 'x'">
                        <xsl:value-of select="number($sum) + 10"/>
                    </xsl:when>
                    <xsl:when test="substring($data,1,1) = 'v'">
                        <xsl:value-of select="number($sum) + 5"/>
                    </xsl:when>
                    <xsl:when test="substring($data,1,1) = 'l'">
                        <xsl:value-of select="number($sum) + 50"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="for-each-character">
                <xsl:with-param name="sum" select="$calc"/>
                <xsl:with-param name="data" select="substring($data,2)"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>-->

    
    
</xsl:stylesheet>