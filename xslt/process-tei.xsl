<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:output indent="yes" suppress-indentation="p ref"/>
  
  <xsl:variable name="sectionHeadingTypes" select="('#acknowledgment','#affiliation','#articleTitle','#articleHeader',
    '#author','#bibliography','#commentary','#corrections','#edition','#email','#introduction','#metadata','#text',
    '#translation')"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
      
  <xsl:template match="t:body">
    <xsl:variable name="pass1"><xsl:apply-templates select="t:p|t:table|t:list|t:figure" mode="pass1"/></xsl:variable>
    <!--<xsl:result-document href="pass1.xml"><xsl:copy-of select="$pass1"/></xsl:result-document>-->
    <front>
      <docTitle>
        <titlePart type="MainTitle"><xsl:apply-templates select="$pass1//t:p[@type='#articleTitle']/node()"/></titlePart>
      </docTitle>
    </front>
    <body>
      <div type="article">
        <xsl:apply-templates select="$pass1/*[@type = '#articleTitle']" mode="pass2"/>
      </div>
    </body>
  </xsl:template>
  
  <xsl:template match="t:seg" mode="#all">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:hi" mode="#all">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:not[@place]">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:p|t:table" mode="pass1">
    <xsl:variable name="text" select="normalize-space(string-join(.//text()))"/>
    <xsl:choose>
      <xsl:when test="starts-with($text,'#edition') and not(ends-with($text, 'Header'))"><p type="edition" subtype="{substring-after($text, 'edition')}"/></xsl:when>
      <xsl:when test="$text = $sectionHeadingTypes"/>
      <xsl:when test="preceding-sibling::*[1]/normalize-space(string-join(.//text())) = $sectionHeadingTypes">
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:attribute name="type" select="preceding-sibling::*[1]/normalize-space(string-join(.//text()))"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
  
  <xsl:template match="t:figure|t:list" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#affiliation']" mode="pass2">
    <affiliation><xsl:apply-templates/></affiliation>
  </xsl:template>
  
  <xsl:template match="t:p[@type = '#articleTitle']" mode="pass2">
    <xsl:for-each select="following-sibling::t:p[@type = ('#author','#affiliation','#email')]">
      <xsl:apply-templates select="." mode="pass2"/>
    </xsl:for-each>
    <xsl:for-each select="following-sibling::t:p[not(@type)][following-sibling::*[@type][1] = current()/following-sibling::*[@type][not(@type = ('#author','#affiliation','#email'))][1]]">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:apply-templates select="following-sibling::*[@type][not(@type = ('#author','#affiliation','#email'))][1]" mode="pass2"/>
  </xsl:template>
    
  <xsl:template match="t:p[@type='#articleHeader']" mode="pass2">
    <div type="section">
      <head><xsl:apply-templates select="node()"/></head>
      <xsl:for-each select="following-sibling::*[not(@type)][preceding-sibling::t:p[@type][1] = current()]">
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:for-each>
    </div>
    <xsl:apply-templates select="following-sibling::t:p[@type='#articleHeader'][1]" mode="pass2"/>
    <xsl:apply-templates select="following-sibling::t:table[@type='#corrections'][1]" mode="pass2"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#acknowledgement']" mode="pass2">
    <note type="acknowledgements"><xsl:apply-templates select="following-sibling::t:p[1]"></xsl:apply-templates>    </note>
    <xsl:apply-templates select="following-sibling::t:p[2]" mode="pass2"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#author']" mode="pass2">
    <author><xsl:apply-templates/></author>
  </xsl:template>
  
  <xsl:template match="t:p[@type='edition']" mode="pass2">
    <div type="epidoc" subtype="{@subtype}">
      <xsl:apply-templates select="following-sibling::*[@type = '#metadata'][1]" mode="epidoc"/>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type = ('edition','#articleHeader')][1]" mode="pass2"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#email']" mode="pass2">
    <email><xsl:apply-templates/></email>
  </xsl:template>
  
  <xsl:template match="t:table[@type='#corrections']" mode="pass2">
    <div type="corrections">
      <xsl:copy>
        <xsl:apply-templates select="*|@*"/>
      </xsl:copy>
    </div>
  </xsl:template>
  
  <xsl:template match="t:table[@type='#metadata']" mode="epidoc">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:for-each select="following-sibling::*[preceding-sibling::t:p[@type][1] is current()][not(@type)]">
      <xsl:choose>
        <xsl:when test="self::t:p[string-length(normalize-space(.)) gt 0]">
          <head><xsl:apply-templates/></head>
        </xsl:when>
        <xsl:when test="self::t:table">
          <head><xsl:apply-templates/></head>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#introduction']" mode="epidoc">
    <div type="introduction">
      <p><xsl:apply-templates/></p>
      <xsl:for-each select="following-sibling::*[preceding-sibling::t:p[@type][1] is current()][not(@type)]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#text']" mode="epidoc">
    <xsl:variable name="start" select="if (starts-with(.,'&lt;S=')) then . else following-sibling::t:p[starts-with(.,'&lt;S=')][1]"/>
    <div type='edition'>
      <xsl:if test=". ne $start">
        <head>
          <xsl:copy-of select="node()"/>
          <xsl:for-each select="following-sibling::t:p[following-sibling::t:p = $start]"><xsl:copy-of select="node()"/></xsl:for-each>
        </head>
      </xsl:if>
      <xsl:variable name="content"><xsl:value-of select="normalize-space($start)"/><xsl:for-each select="$start/following-sibling::t:p[preceding-sibling::t:p[@type][1] is current()][not(@type)]"><xsl:text>
</xsl:text><xsl:value-of select="."/></xsl:for-each></xsl:variable>
      <xsl:result-document href="epidoc/{count(preceding-sibling::t:p[@type='#text'])}.lplus" method="text"><xsl:copy-of select="$content"/></xsl:result-document>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#translation']" mode="epidoc">
    <div type='translation'>
      <xsl:variable name="content"><xsl:value-of select="normalize-space(.)"/><xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] is current()][not(@type)]"><xsl:text>
</xsl:text><xsl:value-of select="."/></xsl:for-each></xsl:variable>
      <xsl:result-document href="translations/{count(preceding-sibling::t:p[@type='#translation'])}.lplus" method="text"><xsl:copy-of select="$content"/></xsl:result-document>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#commentary']" mode="epidoc">
    <div type='commentary'>
      <p><xsl:apply-templates select="text()[1]" mode="comment"/><xsl:apply-templates select="text()[1]/following-sibling::node()"/></p>
      <xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] is current()][not(@type)]">
        <p><xsl:apply-templates select="text()[1]" mode="comment"/><xsl:apply-templates select="text()[1]/following-sibling::node()"/></p>
      </xsl:for-each>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#bibliography']" mode="epidoc">
    <div type='bibliography'>
      <listBibl>
        <bibl><xsl:apply-templates select="node()"/></bibl>
      </listBibl>
      <xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] is current()][not(@type)]">
        <bibl><xsl:apply-templates select="node()"/></bibl>
      </xsl:for-each>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="*[not(@type = ('#metadata','#text','#introduction','#translation','#commentary','#bibliography'))]" mode="epidoc"/>
  
  <xsl:template match="t:p" mode="pass2"/>
  
  <xsl:template match="text()" mode="comment" xml:space="preserve"><xsl:choose>
      <xsl:when test="matches(.,'^\t?\d+[-–.0-9]*\s+')"><ref><xsl:value-of select="replace(.,'^\t?(\d+[-–.0-9]*)\s.*','$1')"/></ref> <xsl:value-of select="replace(.,'^\t?\d+[-–.0-9]*\s+(.*)$','$1')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose></xsl:template>
  
  <xsl:template match="@rend"/>
  
</xsl:stylesheet>