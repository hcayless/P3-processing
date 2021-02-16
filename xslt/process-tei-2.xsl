<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:fn="p3:function"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t fn"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:output indent="yes"/>
  <xsl:param name="cwd"/>
  
  <xsl:template match="t:fileDesc/t:titleStmt/t:title">
    <xsl:copy>
      <xsl:apply-templates select="//t:front/t:docTitle/t:titlePart[@type='MainTitle']/text()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:TEI">
    <xsl:processing-instruction name="xml-model">href="https://tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction><xsl:text>
</xsl:text>
    <xsl:processing-instruction name="xml-model">href="https://tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction><xsl:text>
</xsl:text>
    <xsl:copy>
      <xsl:apply-templates/>
      <xsl:for-each select="//t:div[@type='edition']">
        <TEI>
          <teiHeader>
            <fileDesc>
              <titleStmt>
                <title/>
              </titleStmt>
              <publicationStmt>
                <ab/>
              </publicationStmt>
              <sourceDesc>
                <ab/>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
          <text>
            <body>
              <xsl:apply-templates select="doc(concat($cwd,'/articles/epidoc/',count(preceding::t:div[@type='edition']), '.xml'))" mode="import"><xsl:with-param name="id" select="concat('ed',count(preceding::t:div[@type='edition']) + 1)" tunnel="yes"></xsl:with-param></xsl:apply-templates>
            </body>
          </text>
        </TEI>
      </xsl:for-each>
      <xsl:for-each select="//t:div[@type='epidoc']/t:table[1]">
        <TEI type="HGV">
          <teiHeader>
            <fileDesc>
              <titleStmt>
                <title><xsl:value-of select="fn:get-value(.,'Descriptive title')"/></title>
              </titleStmt>
              <publicationStmt>
                <authority>Papyri.info</authority>
                <idno type="TM"><xsl:value-of select="fn:get-value(.,'TM number')"/></idno>
              </publicationStmt>
              <sourceDesc>
                <msDesc>
                  <msIdentifier>
                    <repository/>
                    <idno type="invNo"><xsl:value-of select="fn:get-value(.,'Inventory no.')"/></idno>
                  </msIdentifier>
                  <xsl:if test="fn:has-value(.,'Material')"><physDesc>
                    <objectDesc>
                      <supportDesc>
                        <support>
                          <material>Papyrus</material>
                          <xsl:if test="fn:has-value(.,'Dimensions: height')">
                            <measure type="height" unit="cm"><xsl:value-of select="fn:get-value(.,'Dimensions: height')"/></measure>
                          </xsl:if>
                          <xsl:if test="fn:has-value(.,'Dimensions: width')">
                            <measure type="width" unit="cm"><xsl:value-of select="fn:get-value(.,'Dimensions: width')"/></measure>
                          </xsl:if>
                        </support>
                      </supportDesc>
                    </objectDesc>
                  </physDesc></xsl:if>
                  <history>
                    <xsl:if test="fn:has-value(.,'Date of text')"><origin>
                      <origDate><xsl:value-of select="fn:get-value(.,'Date of text')"/></origDate>
                    </origin></xsl:if>
                    <xsl:if test="fn:has-value(.,'Provenance')"><provenance type="located">
                      <p>
                        <xsl:for-each select="tokenize(fn:get-value(.,'Provenance'),', ')">
                          <placeName n="{position()}"><xsl:value-of select="."/></placeName>
                        </xsl:for-each>
                      </p>
                    </provenance></xsl:if>
                    <xsl:if test="fn:has-value(.,'Acquisition: Date') or fn:has-value(.,'Acquisition: Place')">
                      <provenance type="acquired">
                        <p>
                          <xsl:for-each select="tokenize(fn:get-value(.,'Acquisition: Place'),', ')">
                            <placeName n="{position()}"><xsl:value-of select="."/></placeName>
                          </xsl:for-each>
                          <xsl:if test="fn:has-value(.,'Acquisition: Date')">
                            <date><xsl:value-of select="fn:get-value(.,'Acquisition: Date')"/></date>
                          </xsl:if>
                        </p>
                      </provenance>
                    </xsl:if>
                  </history>
                </msDesc>
              </sourceDesc>
            </fileDesc>
            <encodingDesc>
              <p>This file encoded to comply with EpiDoc Guidelines and Schema version 8</p>
            </encodingDesc>
            <profileDesc>
              <langUsage>
                <language ident="fr">Französisch</language>
                <language ident="en">Englisch</language>
                <language ident="de">Deutsch</language>
                <language ident="it">Italienisch</language>
                <language ident="es">Spanisch</language>
                <language ident="la">Latein</language>
                <language ident="el">Griechisch</language>
              </langUsage>
              <xsl:if test="fn:has-value(.,'Keywords')"><textClass>
                <keywords scheme="hgv">
                  <xsl:for-each select="tokenize(fn:get-value(.,'Keywords'),', ')">
                    <term n="{position()}"><xsl:value-of select="."/></term>
                  </xsl:for-each>
                </keywords>
              </textClass></xsl:if>
            </profileDesc>
          </teiHeader>
          <text>
            <body>
              <div type="bibliography" subtype="principalEdition">
                
              </div>
              <xsl:if test="fn:has-value(.,'Previous editions')"><div type="bibliography" subtype="otherPublications">
                <head>Andere Publikation</head>
                <listBibl>
                  <xsl:for-each select="tokenize(fn:get-value(.,'Previous editions'),'\n')">
                    <bibl type="publication" subtype="other"><xsl:value-of select="."/></bibl>
                  </xsl:for-each>
                </listBibl>
              </div></xsl:if>
              <xsl:if test="fn:has-value(.,'Images')"><div type="figure">
                <p>
                  <xsl:for-each select="tokenize(fn:get-value(.,'Images'),'\n')">
                    <figure n="{position()}">
                      <graphic url="{.}"/>
                    </figure>
                  </xsl:for-each>
                </p>
              </div></xsl:if>
            </body>
          </text>
          
        </TEI>
      </xsl:for-each>
    </xsl:copy>
        
  </xsl:template>
  
  <xsl:template match="t:div[@type='edition']">
    <div copyOf="#ed{count(preceding::t:div[@type='edition']) + 1}"/>
  </xsl:template>
  
  <xsl:template match="t:div[@type='epidoc']/t:table[1]"/>
  
  <xsl:template match="*" mode="import">
    <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="import"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="div[@type='edition']" mode="import">
    <xsl:param name="id" tunnel="yes"/>
    <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id" select="$id"></xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="import"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="fn:has-value" as="xs:boolean">
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <xsl:sequence select="$table/t:row[t:cell[1]/normalize-space() eq $key]/t:cell[2]/normalize-space() ne ''"/>
  </xsl:function>
  
  <xsl:function name="fn:get-value">
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <xsl:value-of select="$table/t:row[t:cell[1]/normalize-space() eq $key]/t:cell[2]"/>
  </xsl:function>
  
</xsl:stylesheet>