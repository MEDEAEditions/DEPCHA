<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://gams.uni-graz.at/rem/bookkeeping/"
    xml:base="http://gams.uni-graz.at/rem/bookkeeping/"
    xmlns:bookkeeping="http://gams.uni-graz.at/rem/bookkeeping/#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:ns="http://www.tei-c.org/ns/1.0/"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">

    
    <!-- 
        
     <bookkeeping:hasDate rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">1650-05-30T00:00:00</bookkeeping:hasDate>
     
    <bookkeeping:quantity rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">20</bookkeeping:quantity>
    <bookkeeping:unit rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">https://glossa.uni-graz.at/#dollar</bookkeeping:unit>
    
    <bookkeeping:hasText rdf:datatype="http://www.w3.org/2001/XMLSchema#string">4. July 1750 : Christoper gives Sepp 20 $ .</bookkeeping:hasText>
    <bookkeeping:hasName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">Weinungeld</bookkeeping:hasName>
    
    -->
        

    <xsl:variable name="TORDF_RESULT">
        <xsl:copy-of select="document('file:///Y:/data/projekte/medea/data/rdf/rdf.xml')"/>
    </xsl:variable>
    
    
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates/>
            
            
            
            <xsl:for-each-group select="$TORDF_RESULT//*:RDF/node()" group-by="@rdf:about">
                <owl:NamedIndividual rdf:about="{current-grouping-key()}">
                    <rdf:type rdf:resource="{concat('http://gams.uni-graz.at/rem/bookkeeping/#', local-name())}"/>
                    
                    
                    <!-- DATA PROPERTIES -->
                    <xsl:variable name="DataProperties" select="node()[text()]"></xsl:variable>
                   
                    <xsl:for-each select="$DataProperties">
                        <xsl:choose>
                            <xsl:when test="local-name() = 'hasDate'">
                                <xsl:element name="{local-name()}">
                                   <xsl:attribute name="rdf:datatype">
                                       <xsl:value-of select="'http://www.w3.org/2001/XMLSchema#dateTime'"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="concat(., 'T00:00:00')"/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="local-name() = 'quantity'">
                                <xsl:element name="{local-name()}">
                                    <xsl:attribute name="rdf:datatype">
                                        <xsl:value-of select="'http://www.w3.org/2001/XMLSchema#decimal'"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="local-name() = 'unit'">
                                <xsl:element name="{local-name()}">
                                    <xsl:attribute name="rdf:datatype">
                                        <xsl:value-of select="'http://www.w3.org/2001/XMLSchema#anyURI'"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:element name="{local-name()}">
                                    <xsl:attribute name="rdf:datatype">
                                        <xsl:value-of select="'http://www.w3.org/2001/XMLSchema#string'"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="."/>
                                </xsl:element> 
                            </xsl:otherwise>
                        </xsl:choose>
   
                    </xsl:for-each>
                    
                    
                    <!-- OBJECT PROPERTIES -->
                    <xsl:variable name="ObjectProperties" select="node()[@rdf:resource]"/>
                    
                    <xsl:for-each select="$ObjectProperties">
                        <xsl:element name="{local-name()}" namespace="http://gams.uni-graz.at/rem/bookkeeping/#">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="@rdf:resource"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:for-each>
                </owl:NamedIndividual>
            </xsl:for-each-group>
            

            
        </rdf:RDF>
    </xsl:template>
    
    
    <xsl:template match="*:RDF//node()|@*">
        <!-- copy the whole .owl -->
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
        
 
    </xsl:template>

    
</xsl:stylesheet>