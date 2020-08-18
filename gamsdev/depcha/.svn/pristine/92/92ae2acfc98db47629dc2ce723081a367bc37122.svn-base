<xsl:stylesheet exclude-result-prefixes="xs" version="2.0" xmlns="http://www.tei-c.org/ns/1.0" xmlns:cp="huhu"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output indent="yes"/>
  <xsl:strip-space elements="*"/>
  <!-- //////////////////////////////////////////////////////////// -->
  <!-- ///PARAMS/// -->
  <xsl:param as="xs:string" name="csv-encoding" select="'iso-8859-1'"/>
  <!-- here you have to add the filename of the csv -->
  <xsl:param as="xs:string" name="csv-uri"><xsl:text>http://gams.uni-graz.at/archive/objects/context:depcha/datastreams/CSV_EXAMPLE/content</xsl:text></xsl:param> <!--select="'CSV_EXAMPLE.txt'"-->
  <!-- /////////////////////////////////////////////////////// -->
  <!-- param: string -->
  <!-- check is if contains " and cuts them of -->
  <xsl:function name="cp:normalizeCSVstring">
    <xsl:param name="string"/>
    <xsl:choose>
      <!-- &#34; = "  -->
      <xsl:when test="substring-after($string, '&quot;') and substring-before($string, '&quot;')">
        <xsl:value-of select="normalize-space(substring-before(substring-after($string, '&quot;'), '&quot;'))"/>
      </xsl:when>
      <xsl:when test="substring-after($string, '&quot;')">
        <xsl:value-of select="substring-after($string, '&quot;')"/>
      </xsl:when>
      <xsl:when test="substring-before($string, '&quot;')">
        <xsl:value-of select="substring-before($string, '&quot;')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($string)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  <!-- //////////////////////////////////////////////////////////// -->
  <!-- ///MAIN/// -->
  <xsl:template match="/" name="csv2xml">
    <TEI>
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>This is a Bookkeeping TEI/XML transformed from a CSV File.</title>
          </titleStmt>
          <publicationStmt>
            <publisher>Zentrum für Informationsmodellierung - Universität Graz</publisher>
            <!-- GAMS PID -->
            <idno type="PID">
              <xsl:value-of select="concat('o:depcha.', substring-before(tokenize($csv-uri,'/')[last()], '.'))"/>
            </idno>
          </publicationStmt>
          <sourceDesc>
            <!-- GAMS CONTEXT -->
            <list>
              <item>
                <ref target="info:fedora/context:depcha.example" type="context">Example</ref>
              </item>
            </list>
          </sourceDesc>
        </fileDesc>
      </teiHeader>
      <text>
        <body>
          <table>
            <xsl:choose>
              <!-- check if valid CSV -->
              <xsl:when test="unparsed-text-available($csv-uri, $csv-encoding)">
                <xsl:variable name="CSV" select="unparsed-text($csv-uri, $csv-encoding)"/>
                <!-- get  CSV-Header -->
                <xsl:variable as="xs:string*" name="CSV_Header">
                  <xsl:analyze-string regex="\r\n?|\n" select="$CSV">
                    <xsl:non-matching-substring>
                      <xsl:if test="position()=1">
                        <xsl:copy-of select="tokenize(.,',')"/>
                      </xsl:if>
                    </xsl:non-matching-substring>
                  </xsl:analyze-string>
                </xsl:variable>
                <!-- ////////////////////////////////////////// -->
                <!-- for every CSV line except the header -->
                <xsl:analyze-string regex="\r\n?|\n" select="$CSV">
                  <xsl:non-matching-substring>
                    <xsl:if test="not(position()=1)">
                      <row ana="#bk_entry">
                        <!-- get text in bk_from -->
                        <xsl:variable name="BK_FROM_TEXT_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test="contains(., 'bk:from bk:Account|bk:Party|bk:Group (text)')">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="BK_FROM_TEXT">
                          <xsl:value-of select="tokenize(.,',')[number($BK_FROM_TEXT_POSITION)]"/>
                        </xsl:variable>
                        <!-- get text in bk_to -->
                        <xsl:variable name="BK_TO_TEXT_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test="contains(., 'bk:to bk:Account|bk:Party|bk:Group (text)')">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="BK_TO_TEXT">
                          <xsl:value-of select="tokenize(.,',')[number($BK_TO_TEXT_POSITION)]"/>
                        </xsl:variable>
                        <!-- UNIT -->
                        <xsl:variable as="xs:int" name="UNIT_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test=". ='bk:unit'">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="UNIT">
                          <xsl:value-of select="tokenize(.,',')[$UNIT_POSITION]"/>
                        </xsl:variable>
                        <!-- QUANTITY -->
                        <xsl:variable as="xs:int" name="QUANTITY_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test=". ='bk:quantity'">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="QUANTITY">
                          <xsl:value-of select="tokenize(.,',')[$QUANTITY_POSITION]"/>
                        </xsl:variable>
                        <!-- CLASSIFIED -->
                        <xsl:variable as="xs:int" name="CLASSIFIED_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test=". ='bk:classified' or . ='bk:categorized' or . ='bk:commodity'">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="CLASSIFIED">
                          <xsl:value-of select="tokenize(.,',')[$CLASSIFIED_POSITION]"/>
                        </xsl:variable>
                        <!-- PRICE -->
                        <xsl:variable as="xs:int" name="PRICE_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test=". = 'bk:Price'">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="PRICE">
                          <xsl:value-of select="tokenize(.,',')[$PRICE_POSITION]"/>
                        </xsl:variable>
                        <!-- UNIT_PRICE -->
                        <xsl:variable as="xs:int" name="UNIT_PRICE_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test=". ='bk:unit (bk:Price)'">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="UNIT_PRICE">
                          <xsl:value-of select="tokenize(.,',')[$UNIT_PRICE_POSITION]"/>
                        </xsl:variable>
                        <!-- QUANTITY_PRICE -->
                        <xsl:variable as="xs:int" name="QUANTITY_PRICE_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test=". ='bk:quantity (bk:Price)'">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="QUANTITY_PRICE">
                          <xsl:value-of select="tokenize(.,',')[$QUANTITY_PRICE_POSITION]"/>
                        </xsl:variable>
                        <!-- QUANTITY_PRICE -->
                        <xsl:variable as="xs:int" name="AGENT_POSITION">
                          <xsl:for-each select="$CSV_Header">
                            <xsl:if test="contains(., 'bk:Agent')">
                              <xsl:value-of select="position()"/>
                            </xsl:if>
                          </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="AGENT">
                          <xsl:value-of select="tokenize(.,',')[$AGENT_POSITION]"/>
                        </xsl:variable>
                        <!-- /////////////////////////////////////////////////////// -->
                        <!-- for each token in line -->
                        <!-- here change the CSV delimiter, if needed -->
                        <xsl:for-each select="tokenize(.,',')">
                          <!-- /////////////////////////////////////////////////////// -->
                          <!-- normalize current cell and remove "-->
                          <xsl:variable name="Current" select="cp:normalizeCSVstring(.)"/>
                          <!-- current position -->
                          <xsl:variable name="pos" select="position()"/>
                          <!-- if the CSV data cell ist not empty -->
                          <xsl:if test=".">
                            <!-- create t:cell -->
                            <xsl:element name="cell">
                              <!-- checks the current position with the header, if its a defined bookkeeping term add the @ana-->
                              <!-- load the bk_owl and read this terms generic? -->
                              <xsl:choose>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:Entry')">
                                  <!-- add @ana -->
                                  <xsl:attribute name="ana">
                                    <xsl:text>#text</xsl:text>
                                  </xsl:attribute>
                                  <!-- cell content -->
                                  <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                </xsl:when>
                                <!-- MEASURABLE -->
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:Commodity')">
                                  <xsl:call-template name="getMeasure">
                                    <xsl:with-param name="MeasurableType" select="'bk_commodity'"/>
                                    <xsl:with-param name="UNIT" select="$UNIT"/>
                                    <xsl:with-param name="QUANTITY" select="$QUANTITY"/>
                                    <xsl:with-param name="CLASSIFIED" select="$CLASSIFIED"/>
                                    <xsl:with-param name="PRICE" select="$PRICE"/>
                                    <xsl:with-param name="UNIT_PRICE" select="$UNIT_PRICE"/>
                                    <xsl:with-param name="QUANTITY_PRICE" select="$QUANTITY_PRICE"/>
                                  </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:Service')">
                                  <xsl:call-template name="getMeasure">
                                    <xsl:with-param name="MeasurableType" select="'bk_service'"/>
                                    <xsl:with-param name="UNIT" select="$UNIT"/>
                                    <xsl:with-param name="QUANTITY" select="$QUANTITY"/>
                                    <xsl:with-param name="CLASSIFIED" select="$CLASSIFIED"/>
                                    <xsl:with-param name="PRICE" select="$PRICE"/>
                                    <xsl:with-param name="UNIT_PRICE" select="$UNIT_PRICE"/>
                                    <xsl:with-param name="QUANTITY_PRICE" select="$QUANTITY_PRICE"/>
                                  </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:Money')">
                                  <xsl:call-template name="getMeasure">
                                    <xsl:with-param name="MeasurableType" select="'bk_money'"/>
                                    <xsl:with-param name="UNIT" select="$UNIT"/>
                                    <xsl:with-param name="QUANTITY" select="$QUANTITY"/>
                                  </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:MonetaryValue')">
                                  <xsl:call-template name="getMeasure">
                                    <xsl:with-param name="MeasurableType" select="'bk_money'"/>
                                    <xsl:with-param name="UNIT" select="$UNIT"/>
                                    <xsl:with-param name="QUANTITY" select="$QUANTITY"/>
                                  </xsl:call-template>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:from (id)')">
                                  <name>
                                    <xsl:attribute name="ana">
                                      <xsl:text>#bk_from</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="ref">
                                      <!-- add # to @ref -->
                                      <xsl:choose>
                                        <xsl:when test="contains($Current, '#')">
                                          <xsl:value-of select="$Current"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                          <xsl:value-of select="concat('#',$Current)"/>
                                        </xsl:otherwise>
                                      </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:value-of select="cp:normalizeCSVstring($BK_FROM_TEXT[$BK_FROM_TEXT_POSITION])"/>
                                  </name>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:to (id)')">
                                  <name>
                                    <xsl:attribute name="ana">
                                      <xsl:text>#bk_to</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="ref">
                                      <!-- add # to @ref -->
                                      <xsl:choose>
                                        <xsl:when test="contains($Current, '#')">
                                          <xsl:value-of select="$Current"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                          <xsl:value-of select="concat('#',$Current)"/>
                                        </xsl:otherwise>
                                      </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:value-of select="cp:normalizeCSVstring($BK_TO_TEXT[$BK_TO_TEXT_POSITION])"/>
                                  </name>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos],'bk:when')">
                                  <xsl:attribute name="ana">
                                    <xsl:text>#bk_when</xsl:text>
                                  </xsl:attribute>
                                  <!-- t:date with @when -->
                                  <xsl:element name="date">
                                    <xsl:choose>
                                      <!-- todo: this should be a template -->
                                      <!-- if YYYY-MM-DD -->
                                      <xsl:when test=". castable as xs:date">
                                        <xsl:attribute name="when">
                                          <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                      </xsl:when>
                                      <!-- if M MM/DD/YYYY -->
                                      <xsl:when test="matches(., '\d{2}/\d{2}/\d{4}')">
                                        <xsl:variable name="Month" select="substring-before(.,'/')"/>
                                        <xsl:variable name="Day" select="substring-before(substring-after(.,'/'), '/')"/>
                                        <xsl:variable name="Year" select="substring-after(substring-after(.,'/'), '/')"/>
                                        <xsl:attribute name="when">
                                          <xsl:value-of select="concat($Year,'-', $Month, '-', $Day)"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                      </xsl:when>
                                      <!-- if YYYY-MM -->
                                      <xsl:when test="substring-after(., '-')">
                                        <xsl:attribute name="when">
                                          <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                      </xsl:when>
                                      <!-- if YYYY ToDo: check if year-->
                                      <xsl:when test="string-length(.) = 4">
                                        <xsl:attribute name="when">
                                          <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                                      </xsl:when>
                                      <!-- no valid date -->
                                      <xsl:otherwise>
                                        <xsl:text>not valid: </xsl:text>
                                        <xsl:value-of select="."/>
                                      </xsl:otherwise>
                                    </xsl:choose>
                                  </xsl:element>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:debit')">
                                  <xsl:attribute name="ana">
                                    <xsl:text>#bk_debit</xsl:text>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:where')">
                                  <xsl:attribute name="ana">
                                    <xsl:text>#bk_where</xsl:text>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:status')">
                                  <xsl:attribute name="ana">
                                    <xsl:text>#bk_status</xsl:text>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:assigned')">
                                  <xsl:attribute name="ana">
                                    <xsl:text>#bk_assigned</xsl:text>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:credit')">
                                  <xsl:attribute name="ana">
                                    <xsl:text>#bk_credit</xsl:text>
                                  </xsl:attribute>
                                  <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="contains($CSV_Header[$pos], 'bk:by')">
                                  <xsl:attribute name="ana">
                                    <xsl:text>#bk_credit</xsl:text>
                                  </xsl:attribute>
                                  <xsl:element name="name">
                                    <xsl:attribute name="ana">
                                      <xsl:text>#bk_agent</xsl:text>
                                    </xsl:attribute>
                                    <xsl:attribute name="ref">
                                      <!-- add # to @ref -->
                                      <xsl:choose>
                                        <xsl:when test="contains($Current, '#')">
                                          <xsl:value-of select="$Current"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                          <xsl:value-of select="concat('#',$Current)"/>
                                        </xsl:otherwise>
                                      </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:value-of select="cp:normalizeCSVstring($AGENT)"/>
                                  </xsl:element>
                                </xsl:when>
                                <xsl:otherwise/>
                              </xsl:choose>
                            </xsl:element>
                          </xsl:if>
                        </xsl:for-each>
                      </row>
                    </xsl:if>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </xsl:when>
              <!-- ////////////////////////////////////////////////////// -->
              <!-- ERROR -->
              <xsl:otherwise>
                <xsl:variable name="error">
                  <xsl:text>Error reading "</xsl:text>
                  <xsl:value-of select="$csv-uri"/>
                  <xsl:text>" (encoding "</xsl:text>
                  <xsl:value-of select="$csv-encoding"/>
                  <xsl:text>").</xsl:text>
                </xsl:variable>
                <xsl:message>
                  <xsl:value-of select="$error"/>
                </xsl:message>
                <xsl:value-of select="$error"/>
              </xsl:otherwise>
            </xsl:choose>
          </table>
        </body>
      </text>
    </TEI>
  </xsl:template>
  <xsl:template name="getMeasure">
    <xsl:param name="MeasurableType"/>
    <xsl:param name="UNIT"/>
    <xsl:param name="QUANTITY"/>
    <xsl:param name="CLASSIFIED"/>
    <xsl:param name="PRICE"/>
    <xsl:param name="UNIT_PRICE"/>
    <xsl:param name="QUANTITY_PRICE"/>
    <xsl:choose>
      <xsl:when test="contains(.,'|')">
        <xsl:for-each select="tokenize(.,'\|')">
          <xsl:variable name="ITERATION" select="position()"/>
          <xsl:element name="measure">
            <xsl:attribute name="ana">
              <xsl:value-of select="$MeasurableType"/>
            </xsl:attribute>
            <xsl:if test="not($UNIT='')">
              <xsl:attribute name="unit">
                <xsl:for-each select="tokenize($UNIT, '\|')">
                  <xsl:if test="$ITERATION = position()">
                    <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($QUANTITY='')">
              <xsl:attribute name="quantity">
                <xsl:for-each select="tokenize($QUANTITY, '\|')">
                  <xsl:if test="$ITERATION = position()">
                    <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($CLASSIFIED='')">
              <xsl:attribute name="commodity">
                <xsl:for-each select="tokenize($CLASSIFIED, '\|')">
                  <xsl:if test="$ITERATION = position()">
                    <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="cp:normalizeCSVstring(.)"/>
            <xsl:if test="not($PRICE='')">
              <xsl:text/>
              <xsl:for-each select="tokenize($PRICE, '\|')">
                <xsl:if test="$ITERATION = position()">
                  <xsl:element name="measure">
                    <xsl:attribute name="ana">
                      <xsl:text>#bk_price</xsl:text>
                    </xsl:attribute>
                    <xsl:if test="not($QUANTITY_PRICE='')">
                      <xsl:attribute name="quantity">
                        <xsl:for-each select="tokenize($QUANTITY_PRICE, '\|')">
                          <xsl:if test="$ITERATION = position()">
                            <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="not($UNIT_PRICE='')">
                      <xsl:attribute name="unit">
                        <xsl:for-each select="tokenize($UNIT_PRICE, '\|')">
                          <xsl:if test="$ITERATION = position()">
                            <xsl:value-of select="cp:normalizeCSVstring(.)"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                  </xsl:element>
                </xsl:if>
              </xsl:for-each>
            </xsl:if>
          </xsl:element>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="measure">
          <xsl:attribute name="ana">
            <xsl:value-of select="$MeasurableType"/>
          </xsl:attribute>
          <xsl:if test="not($UNIT='')">
            <xsl:attribute name="unit">
              <xsl:value-of select="cp:normalizeCSVstring($UNIT)"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="not($CLASSIFIED='')">
            <xsl:attribute name="commodity">
              <xsl:value-of select="cp:normalizeCSVstring($CLASSIFIED)"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="not($QUANTITY='')">
            <xsl:attribute name="quantity">
              <xsl:value-of select="cp:normalizeCSVstring($QUANTITY)"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="cp:normalizeCSVstring(.)"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
