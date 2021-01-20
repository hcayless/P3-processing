<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:output indent="yes"/>
  
  <xsl:variable name="sectionHeadingTypes" select="('#articleTitle','#articleParagraphs','#articleHeader','#edition','#editionHeader','#metadata','#introduction','#text','#translation','#commentary','#corrections')"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
    
  <xsl:template match="t:body">
    <xsl:variable name="pass1"><xsl:apply-templates select="t:p|t:table|t:list|t:figure" mode="pass1"/></xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="$pass1/*[@type][1]" mode="pass2"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:seg" mode="#all">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:hi" mode="#all">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:p|t:table" mode="pass1">
    <xsl:choose>
      <xsl:when test="normalize-space(string-join(.//text())) = '#edition'"><p type="edition"/></xsl:when>
      <xsl:when test="normalize-space(string-join(.//text())) = $sectionHeadingTypes"/>
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
  
  <xsl:template match="t:p[@type = '#articleTitle']" mode="pass2">
    <div type="article">
      <head><xsl:apply-templates select="node()"/></head>
      <xsl:for-each select="following-sibling::*[not(@type)][preceding-sibling::t:p[@type][1] = current()]">
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:for-each>
      <xsl:apply-templates select="following-sibling::*[@type][1]" mode="pass2"/>
    </div>
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
  
  <xsl:template match="t:p[@type='#editionHeader']" mode="pass2">
    <div type="section">
      <head><xsl:apply-templates select="node()"/></head>
      <xsl:for-each select="following-sibling::*[not(@type)][preceding-sibling::t:p[@type][1] = current()]">
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:for-each>
      <xsl:if test="following-sibling::*[@type][1]/@type = 'edition'">
        <xsl:apply-templates select="following-sibling::*[@type][1]" mode="pass2"/>
      </xsl:if>
    </div>
    <xsl:apply-templates select="following-sibling::t:p[@type='#articleHeader'][1]" mode="pass2"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='edition']" mode="pass2">
    <div type="epidoc">
      <xsl:apply-templates select="following-sibling::*[@type = '#metadata'][1]" mode="epidoc"/>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type = ('edition','#editionHeader')][1]" mode="pass2"/>
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
    <head>
      <xsl:apply-templates select="following-sibling::t:p[string-length(normalize-space(.)) gt 0][1]/node()"/>
      <xsl:apply-templates select="following-sibling::t:table[1]"/>
    </head>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#introduction']" mode="epidoc">
    <div type="introduction">
      <xsl:for-each select="following-sibling::*[preceding-sibling::t:p[@type][1] = current()][not(@type)]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#text']" mode="epidoc">
    <xsl:param name="epidoc"/>
    <div type='edition'>
      <xsl:variable name="content"><xsl:value-of select="normalize-space(.)"/><xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] = current()][not(@type)]"><xsl:text>
</xsl:text><xsl:value-of select="."/></xsl:for-each></xsl:variable>
      <xsl:result-document href="epidoc/{count(preceding-sibling::t:p[@type='#text'])}.lplus" method="text"><xsl:copy-of select="$content"/></xsl:result-document>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#translation']" mode="epidoc">
    <xsl:param name="epidoc"/>
    <div type='translation'>
      <ab><xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] = current()][not(@type)]"><xsl:text>
</xsl:text><xsl:value-of select="."/></xsl:for-each></ab>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#commentary']" mode="epidoc">
    <xsl:param name="epidoc"/>
    <div type='commentary'>
      <xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] = current()][not(@type)]">
        <p><xsl:apply-templates select="node()" mode="comment"/></p>
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <xsl:template match="*[not(@type = ('#metadata','#text','#introduction','#translation','#commentary'))]" mode="epidoc"/>
  
  <xsl:template match="t:p" mode="pass2"/>
  
  <xsl:template match="text()" mode="comment">
    <xsl:choose>
      <xsl:when test="matches(.,'^\d+\t')"><ref><xsl:value-of select="substring-before(.,'&#x09;')"/></ref><xsl:value-of select="substring-after(.,'&#x09;')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="@rend"/>
  
  <!--<xsl:template match="t:body">
    <xsl:for-each select="t:sectionHeadings(.)">
      <xsl:choose>
        <xsl:when test="map:keys(.) = '#articleTitle'">
          <div type="article">
            <head><xsl:apply-templates select="map:get(., '#articleTitle')/following-sibling::t:p[1]/node()"/></head>
            
          </div>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>-->
  
</xsl:stylesheet>