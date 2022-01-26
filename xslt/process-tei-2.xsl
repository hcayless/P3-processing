<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:fn="p3:function"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t fn"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:mode on-no-match="shallow-copy" name="unify"/>
  <xsl:output indent="yes" suppress-indentation="p"/>
  <xsl:param name="cwd"/>
  <xsl:param name="name"/>
  
  <xsl:template match="t:fileDesc/t:titleStmt">
    <xsl:copy>
      <title><xsl:apply-templates select="//t:front/t:docTitle/t:titlePart[@type='MainTitle']//text()"/></title>
      <xsl:for-each select="//t:body//t:author">
        <author>
          <name>
            <forename><xsl:value-of select="normalize-space(substring-after(.,','))"/></forename>
            <surname><xsl:value-of select="substring-before(.,',')"/></surname>
          </name>
          <xsl:for-each select="following-sibling::t:affiliation[preceding-sibling::t:author[1] is current()]">
            <xsl:copy-of select="."/>
          </xsl:for-each>
          <xsl:for-each select="following-sibling::t:email[preceding-sibling::t:author[1] is current()]">
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </author>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:TEI">
    <xsl:processing-instruction name="xml-model">href="https://tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction><xsl:text>
</xsl:text>
    <xsl:processing-instruction name="xml-model">href="https://tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction><xsl:text>
</xsl:text>
    <xsl:variable name="body">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="$body" mode="unify"/>
      <xsl:for-each select="//t:div[@type='epidoc']">
        <xsl:choose>
          <xsl:when test="@subtype='DDB'">
            <xsl:call-template name="HGV"/>
            <xsl:call-template name="DDB"/>
            <xsl:if test="t:div[@type='translation']">
              <xsl:variable name="metadata" select="t:table[1]"/>
              <xsl:for-each select="t:div[@type='translation']">
                <xsl:call-template name="translation">
                  <xsl:with-param name="metadata" select="$metadata"/>
                  <xsl:with-param name="type">DDB</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="DCLP"/>
            <xsl:if test="t:div[@type='translation']">
              <xsl:variable name="metadata" select="t:table[1]"/>
              <xsl:for-each select="t:div[@type='translation']">
                <xsl:call-template name="translation">
                  <xsl:with-param name="metadata" select="$metadata"/>
                  <xsl:with-param name="type">DCLP</xsl:with-param>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:seg[following-sibling::node()[1][self::t:seg[@style = current()/@style]]]" mode="unify">
    <seg><xsl:copy-of select="@*"/><xsl:apply-templates/><xsl:apply-templates select="following-sibling::node()[1][self::t:seg[@style = current()/@style]]" mode="unify-next"/></seg>
  </xsl:template>
  
  <xsl:template match="t:seg[preceding-sibling::node()[1][self::t:seg[@style = current()/@style]]]" mode="unify-next"><xsl:apply-templates/><xsl:apply-templates select="following-sibling::node()[1][self::t:seg[@style = current()/@style]]"/></xsl:template>
  
  <xsl:template match="t:seg[preceding-sibling::node()[1][self::t:seg[@style = current()/@style]]]" mode="unify"/>
  
  <xsl:template match="t:hi[following-sibling::node()[1][self::t:hi[@style = current()/@style]]]" mode="unify">
    <hi><xsl:copy-of select="@*"/><xsl:apply-templates/><xsl:apply-templates select="following-sibling::node()[1][self::t:hi[@style = current()/@style]]" mode="unify-next"/></hi>
  </xsl:template>
  
  <xsl:template match="t:hi[preceding-sibling::node()[1][self::t:hi[@style = current()/@style]]]" mode="unify-next"><xsl:apply-templates/><xsl:apply-templates select="following-sibling::node()[1][self::t:hi[@style = current()/@style]]"/></xsl:template>
  
  <xsl:template match="t:hi[preceding-sibling::node()[1][self::t:hi[@style = current()/@style]]]" mode="unify"/>
  
  <xsl:template match="t:p[not(ancestor::t:note[@place]) and not(ancestor::t:teiHeader) and not(ancestor::t:table)]">
    <xsl:copy>
      <xsl:attribute name="xml:id">p<xsl:value-of select="count(preceding::t:p[not(ancestor::t:note[@place]) and not(ancestor::t:teiHeader)]) + 1"/></xsl:attribute>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template name="DDB">
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="en">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title><xsl:value-of select="fn:get-value(t:table[1],'Descriptive title')"/></title>
          </titleStmt>
          <publicationStmt>
            <authority>Duke Collaboratory for Classics Computing (DC3)</authority>
            <idno type="filename"><xsl:value-of select="fn:get-value(t:table[1],'ddb-filename')"/></idno>
            <idno type="ddb-hybrid"><xsl:value-of select="fn:get-value(t:table[1],'ddb-hybrid')"/></idno>
            <idno type="HGV"><xsl:value-of select="fn:HGV(t:table[1])"/></idno>
            <idno type="TM"><xsl:value-of select="fn:get-value(t:table[1],'TM number')"/></idno>
            <availability>
              <p>© Duke Databank of Documentary Papyri. This work is licensed under a
                <ref type="license" target="http://creativecommons.org/licenses/by/3.0/">Creative 
                  Commons Attribution 3.0 License</ref>.</p>
            </availability>
          </publicationStmt>
          <sourceDesc>
            <p/>
          </sourceDesc>
        </fileDesc>
        <profileDesc>
          <langUsage>
            <language ident="en">English</language>
            <language ident="grc">Greek</language>
            <language ident="la">Latin</language>
          </langUsage>
        </profileDesc>
      </teiHeader>
      <text>
        <body>
          <head xml:lang="en"><xsl:value-of select="fn:get-value(t:table[1],'Descriptive title')"/></head>
          <xsl:copy-of select="t:div[@type='edition']/t:head"/>
          <xsl:apply-templates select="doc(concat($cwd,'/articles/',$name,'/epidoc/',count(preceding::t:div[@type='edition']), '.xml'))" mode="import"><xsl:with-param name="id" select="concat('ed',count(preceding::t:div[@type='edition']) + 1)" tunnel="yes"></xsl:with-param></xsl:apply-templates>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template name="DCLP">
    <TEI xml:lang="en">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title><xsl:value-of select="fn:get-value(t:table[1],'Descriptive title')"/></title>
          </titleStmt>
          <publicationStmt>
            <authority>Digital Corpus of Literary Papyri</authority>
            <idno type="filename"><xsl:value-of select="fn:get-value(t:table[1],'TM number')"/></idno>
            <idno type="dclp"><xsl:value-of select="fn:get-value(t:table[1],'TM number')"/></idno>
            <xsl:if test="fn:has-value(t:table[1],'dclp-hybrid')">
              <idno type="dclp-hybrid"><xsl:value-of select="fn:get-value(t:table[1],'dclp-hybrid')"/></idno>
            </xsl:if>
            <idno type="TM"><xsl:value-of select="fn:get-value(t:table[1],'TM number')"/></idno>
            <availability>
              <p>© Digital Corpus of Literary Papyri. This work is licensed under a
                <ref type="license" target="http://creativecommons.org/licenses/by/3.0/">Creative
                  Commons Attribution 3.0 License</ref>.</p>
            </availability>
          </publicationStmt>
          <sourceDesc>
            <msDesc>
              <msIdentifier>
                <xsl:choose>
                  <xsl:when test="fn:has-value(t:table[1],'Inventory no.')">
                    <idno type="invNo"><xsl:value-of select="fn:get-value(t:table[1],'Inventory no.')"/></idno>
                  </xsl:when>
                  <xsl:otherwise>
                    <placeName>
                      <settlement><xsl:value-of select="fn:get-value(t:table[1],'Provenance')"/></settlement>
                    </placeName>
                  </xsl:otherwise>
                </xsl:choose>
              </msIdentifier>
              <xsl:if test="fn:has-value(t:table[1],'Material')"><physDesc>
                <objectDesc>
                  <supportDesc>
                    <support>
                      <material>Papyrus</material>
                      <xsl:if test="fn:has-value(t:table[1],'Dimensions: height')">
                        <measure type="height" unit="cm"><xsl:value-of select="fn:get-value(.,'Dimensions: height')"/></measure>
                      </xsl:if>
                      <xsl:if test="fn:has-value(t:table[1],'Dimensions: width')">
                        <measure type="width" unit="cm"><xsl:value-of select="fn:get-value(.,'Dimensions: width')"/></measure>
                      </xsl:if>
                    </support>
                  </supportDesc>
                </objectDesc>
              </physDesc></xsl:if>
              <history>
                <origin>
                  <origPlace><xsl:choose>
                    <xsl:when test="fn:has-value(t:table[1],'Provenance')">
                      <xsl:value-of select="fn:get-value(t:table[1],'Provenance')"/>
                    </xsl:when>
                    <xsl:otherwise>unbekannt</xsl:otherwise></xsl:choose></origPlace>
                  <origDate><xsl:choose>
                    <xsl:when test="fn:has-value(t:table[1],'Date of text')">
                      <xsl:value-of select="fn:get-value(t:table[1],'Date of text')"/>
                    </xsl:when>
                    <xsl:otherwise>unbekannt</xsl:otherwise>
                  </xsl:choose></origDate>
                </origin>
                <xsl:if test="fn:has-value(t:table[1],'Provenance')"><provenance type="located">
                  <p>
                    <xsl:for-each select="tokenize(fn:get-value(t:table[1],'Provenance'),', ')">
                      <placeName n="{position()}"><xsl:value-of select="."/></placeName>
                    </xsl:for-each>
                  </p>
                </provenance></xsl:if>
                <xsl:if test="fn:has-value(t:table[1],'Acquisition: Date') or fn:has-value(t:table[1],'Acquisition: Place')">
                  <provenance type="acquired">
                    <p>
                      <xsl:for-each select="tokenize(fn:get-value(t:table[1],'Acquisition: Place'),', ')">
                        <placeName n="{position()}"><xsl:value-of select="."/></placeName><xsl:if test="position() ne last()">, </xsl:if>
                      </xsl:for-each>
                      <xsl:if test="fn:has-value(t:table[1],'Acquisition: Date')">
                        <date><xsl:value-of select="fn:get-value(t:table[1],'Acquisition: Date')"/></date>
                      </xsl:if>
                    </p>
                  </provenance>
                </xsl:if>
              </history>
            </msDesc>
          </sourceDesc>
        </fileDesc>
        <encodingDesc>
          <p>
            This file encoded to comply with EpiDoc Guidelines and Schema version 8
            <ref>http://www.stoa.org/epidoc/gl/5/</ref>
          </p>
        </encodingDesc>
        <profileDesc>
          <langUsage>
            <language ident="en">English</language>
            <language ident="grc">Greek</language>
          </langUsage>
          <xsl:if test="fn:has-value(t:table[1],'Keywords')"><textClass>
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
          <head xml:lang="en"><xsl:value-of select="fn:get-value(t:table[1],'Descriptive title')"/></head>
          <xsl:apply-templates select="doc(concat($cwd,'/articles/',$name,'/epidoc/',count(preceding::t:div[@type='edition']), '.xml'))" mode="import"><xsl:with-param name="id" select="concat('ed',count(preceding::t:div[@type='edition']) + 1)" tunnel="yes"></xsl:with-param></xsl:apply-templates>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template name="HGV">
    <TEI>
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title><xsl:value-of select="fn:get-value(t:table[1],'Descriptive title')"/></title>
          </titleStmt>
          <publicationStmt>
            <authority>Papyri.info</authority>
            <idno type="TM"><xsl:value-of select="fn:get-value(t:table[1],'TM number')"/></idno>
            <idno type="HGV"><xsl:value-of select="fn:HGV(t:table[1])"/></idno>
            <xsl:if test="fn:has-value(t:table[1],'ddb-filename')">
              <idno type="ddb-filename"><xsl:value-of select="fn:get-value(t:table[1],'ddb-filename')"/></idno>
            </xsl:if>
            <xsl:if test="fn:has-value(t:table[1],'ddb-hybrid')">
              <idno type="ddb-hybrid"><xsl:value-of select="fn:get-value(t:table[1],'ddb-hybrid')"/></idno>
            </xsl:if>
          </publicationStmt>
          <sourceDesc>
            <msDesc>
              <msIdentifier>
                <repository/>
                <idno type="invNo"><xsl:value-of select="fn:get-value(t:table[1],'Inventory no.')"/></idno>
              </msIdentifier>
              <xsl:if test="fn:has-value(t:table[1],'Material')"><physDesc>
                <objectDesc>
                  <supportDesc>
                    <support>
                      <material>Papyrus</material>
                      <xsl:if test="fn:has-value(t:table[1],'Dimensions: height')">
                        <measure type="height" unit="cm"><xsl:value-of select="fn:get-value(t:table[1],'Dimensions: height')"/></measure>
                      </xsl:if>
                      <xsl:if test="fn:has-value(t:table[1],'Dimensions: width')">
                        <measure type="width" unit="cm"><xsl:value-of select="fn:get-value(t:table[1],'Dimensions: width')"/></measure>
                      </xsl:if>
                    </support>
                  </supportDesc>
                </objectDesc>
              </physDesc></xsl:if>
              <history>
                <xsl:if test="fn:has-value(t:table[1],'Date of text')"><origin>
                  <origDate><xsl:value-of select="fn:get-value(t:table[1],'Date of text')"/></origDate>
                </origin></xsl:if>
                <xsl:if test="fn:has-value(t:table[1],'Provenance')"><provenance type="located">
                  <p>
                    <xsl:for-each select="tokenize(fn:get-value(t:table[1],'Provenance'),', ')">
                      <placeName n="{position()}"><xsl:value-of select="."/></placeName>
                    </xsl:for-each>
                  </p>
                </provenance></xsl:if>
                <xsl:if test="fn:has-value(t:table[1],'Acquisition: Date') or fn:has-value(t:table[1],'Acquisition: Place')">
                  <provenance type="acquired">
                    <p>
                      <xsl:for-each select="tokenize(fn:get-value(t:table[1],'Acquisition: Place'),', ')">
                        <placeName n="{position()}"><xsl:value-of select="."/></placeName>
                      </xsl:for-each>
                      <xsl:if test="fn:has-value(t:table[1],'Acquisition: Date')">
                        <date><xsl:value-of select="fn:get-value(t:table[1],'Acquisition: Date')"/></date>
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
          <xsl:if test="fn:has-value(t:table[1],'Keywords')"><textClass>
            <keywords scheme="hgv">
              <xsl:for-each select="tokenize(fn:get-value(t:table[1],'Keywords'),', ')">
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
          <xsl:if test="fn:has-value(t:table[1],'Previous editions')"><div type="bibliography" subtype="otherPublications">
            <head>Andere Publikation</head>
            <listBibl>
              <xsl:for-each select="tokenize(fn:get-value(t:table[1],'Previous editions'),'\n')">
                <bibl type="publication" subtype="other"><xsl:value-of select="."/></bibl>
              </xsl:for-each>
            </listBibl>
          </div></xsl:if>
          <xsl:if test="fn:has-value(t:table[1],'Images')"><div type="figure">
            <p>
              <xsl:for-each select="tokenize(fn:get-value(t:table[1],'Images'),'\n')">
                <figure n="{position()}">
                  <graphic url="{.}"/>
                </figure>
              </xsl:for-each>
            </p>
          </div></xsl:if>
        </body>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template name="translation">
    <xsl:param name="metadata"/>
    <xsl:param name="type">DDB</xsl:param>
    <TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="en">
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title type="main"><xsl:value-of select="fn:get-value($metadata,'Descriptive title')"/></title>
          </titleStmt>
          <publicationStmt>
            <authority>Duke Collaboratory for Classics Computing (DC3)</authority>
            <idno type="filename"><xsl:value-of select="fn:HGV($metadata)"/></idno>
            <idno type="TM"><xsl:value-of select="fn:get-value($metadata,'TM number')"/></idno>
            <xsl:if test="$type eq 'DDB'">
              <idno type="HGV"><xsl:value-of select="fn:HGV($metadata)"/></idno>
            </xsl:if>
            <xsl:if test="fn:has-value($metadata,'ddb-hybrid')">
              <idno type="ddb-hybrid"><xsl:value-of select="fn:get-value($metadata,'TM number')"/></idno>
            </xsl:if>
            <availability>
              <p>© Heidelberger Gesamtverzeichnis der griechischen Papyrusurkunden Ägyptens. This work is licensed under 
                a <ref target="http://creativecommons.org/licenses/by/3.0/" type="license">Creative Commons Attribution 3.0 License</ref>.</p>
            </availability>
          </publicationStmt>
          <sourceDesc>
            <p>The contents of this document are generated from SOSOL.</p>
          </sourceDesc>
        </fileDesc>
        <profileDesc>
          <langUsage>
            <language ident="fr">Französisch</language>
            <language ident="en">Englisch</language>
            <language ident="de">Deutsch</language>
            <language ident="it">Italienisch</language>
            <language ident="es">Spanisch</language>
            <language ident="la">Latein</language>
            <language ident="el">Griechisch</language>
            <language ident="ar">Arabisch</language>
          </langUsage>
        </profileDesc>
      </teiHeader>
      <text>
        <xsl:apply-templates select="doc(concat($cwd,'/articles/',$name,'/translations/',count(preceding::t:div[@type='translation']), '.xml'))" mode="import"><xsl:with-param name="id" select="concat('trans',count(preceding::t:div[@type='translation']) + 1)" tunnel="yes"></xsl:with-param></xsl:apply-templates>
      </text>
    </TEI>
  </xsl:template>
  
  <xsl:template match="t:div[@type='edition']">
    <div copyOf="#ed{count(preceding::t:div[@type='edition']) + 1}" type="edition"/>
  </xsl:template>
  
  <xsl:template match="t:div[@type='translation']">
    <div copyOf="#trans{count(preceding::t:div[@type='translation']) + 1}" type="translation"/>
  </xsl:template>
  
  <xsl:template match="t:div[@type='epidoc']/t:table[1]"/>
  
  
  <xsl:template match="t:div[@type='epidoc']/t:table[2]">
    <table type="papyrological_header">
      <xsl:apply-templates/>
    </table>
  </xsl:template>
  
  <!-- Remove any accidentally nested sections -->
  <xsl:template match="t:div[@type='section'][ancestor::t:div[@type='section']]"/>
  <xsl:template match="t:div[@type='corrections'][ancestor::t:div[@type='section']]"/>
  
  
  <!-- Remove author, affiliation, and email from body -->
  <xsl:template match="t:author"/>
  <xsl:template match="t:affiliation"/>
  <xsl:template match="t:email"/>
  
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

  <xsl:template match="div[@type='translation']" mode="import">
    <xsl:param name="id" tunnel="yes"/>
    <xsl:element name="{local-name(.)}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id" select="$id"></xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()" mode="import"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="t:seg[@rend]" mode="#all">
    <xsl:variable name="style" select="fn:rend-style(@rend)"/>
    <xsl:choose>
      <xsl:when test="not(empty($style))">
        <seg style="{$style}"><xsl:apply-templates/></seg>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="t:hi[@rend]" mode="#all">
    <xsl:variable name="style" select="fn:rend-style(@rend)"/>
    <xsl:choose>
      <xsl:when test="not(empty($style))">
        <seg style="{$style}"><xsl:apply-templates/></seg>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="fn:has-value" as="xs:boolean">
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <xsl:sequence select="exists($table/t:row[t:cell[1]/normalize-space() eq $key]) and $table/t:row[t:cell[1]/normalize-space() eq $key]/t:cell[2]/normalize-space() ne ''"/>
  </xsl:function>
  
  <xsl:function name="fn:get-value">
    <xsl:param name="table"/>
    <xsl:param name="key"/>
    <xsl:value-of select="$table/t:row[t:cell[1]/normalize-space() eq $key]/t:cell[2]"/>
  </xsl:function>
  
  <xsl:function name="fn:HGV">
    <xsl:param name="table"/>
    <xsl:choose>
      <xsl:when test="$table/t:row[t:cell[1]/normalize-space() eq 'HGV number']/t:cell">
        <xsl:value-of select="$table/t:row[t:cell[1]/normalize-space() eq 'HGV number']/t:cell[2]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$table/t:row[t:cell[1]/normalize-space() eq 'TM number']/t:cell[2]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="fn:rend-style">
    <xsl:param name="rend"/>
    <xsl:for-each select="tokenize($rend, ' ')">
      <xsl:choose>
        <xsl:when test=". = 'bold'">
          <xsl:text>font-weight: bold;</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'italic'">
          <xsl:text>font-style: italic;</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'underline'">
          <xsl:text>text-decoration: underline;</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>
  
</xsl:stylesheet>