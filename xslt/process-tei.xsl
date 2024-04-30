<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs t"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:output indent="no" suppress-indentation="p ref"/>
  
  <xsl:variable name="sectionHeadingTypes" select="t:lc-seq(('#acknowledgement','#affiliation','#articleTitle',
    '#articleHeader','#author','#bibliography','#blockQuote','#commentary','#corrections','#edition',
    '#endBlockQuote','#email','#introduction','#metadata','#text','#translation'))"/>
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
      
  <xsl:template match="t:body">
    <xsl:variable name="pass1"><xsl:apply-templates select="t:p|t:table|t:list|t:figure" mode="pass1"/></xsl:variable>
    <xsl:result-document href="pass1.xml"><xsl:copy-of select="$pass1"/></xsl:result-document>
    <xsl:variable name="pass2"><xsl:apply-templates select="$pass1/*" mode="pass2"/></xsl:variable>
    <xsl:result-document href="pass2.xml"><xsl:copy-of select="$pass2"/></xsl:result-document>
    <front>
      <docTitle>
        <titlePart type="MainTitle"><xsl:apply-templates select="$pass2//t:p[lower-case(@type)='#articletitle']/node()"/></titlePart>
      </docTitle>
    </front>
    <body>
      <div type="article">
        <xsl:apply-templates select="$pass2/*[lower-case(@type) = '#articletitle']" mode="pass3"/>
      </div>
    </body>    
  </xsl:template>
  
  <xsl:template match="t:seg" mode="#all">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:seg[tokenize(@rend, ' ') = ('bold','italic','underline')]" mode="#all">
    <seg rend="{@rend}"><xsl:apply-templates/></seg>
  </xsl:template>
    
  <xsl:template match="t:hi" mode="#all">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="t:hi[tokenize(@rend, ' ') = ('bold','italic','underline')]" mode="#all">
    <hi rend="{@rend}"><xsl:apply-templates/></hi>
  </xsl:template>
    
  <xsl:template match="t:not[@place]">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:p|t:table" mode="pass1">
    <xsl:variable name="text" select="normalize-space(string-join(.//text()))"/>
    <xsl:choose>
      <xsl:when test="starts-with($text,'#edition') and not(ends-with($text, 'Header'))"><p type="edition" subtype="{substring-after($text, '#edition')}"/></xsl:when>
      <xsl:when test="lower-case($text) = $sectionHeadingTypes"/>
      <xsl:when test="preceding-sibling::*[1]/lower-case(normalize-space(string-join(.//text()))) = $sectionHeadingTypes">
        <xsl:variable name="type" select="preceding-sibling::*[1]/normalize-space(string-join(.//text()))"/>
        <xsl:copy>
          <xsl:apply-templates select="@*"/>
          <xsl:choose>
            <xsl:when test="lower-case($type) = ('#blockquote','#endblockquote')">
              <xsl:attribute name="n" select="$type"></xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="type" select="$type"/>
            </xsl:otherwise>
          </xsl:choose>
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
  
  <xsl:template match="t:p[@type='#affiliation']" mode="pass3">
    <affiliation><xsl:apply-templates/></affiliation>
  </xsl:template>
  
  <xsl:template match="t:p[lower-case(@type) = '#articletitle']" mode="pass3">
    <xsl:for-each select="following-sibling::t:p[@type = ('#author','#affiliation','#email')]">
      <xsl:apply-templates select="." mode="pass3"/>
    </xsl:for-each>
    <xsl:for-each select="following-sibling::t:p[not(@type)][following-sibling::*[@type][1] = current()/following-sibling::*[@type][not(@type = ('#author','#affiliation','#email'))][1]]">
      <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
    </xsl:for-each>
    <xsl:apply-templates select="following-sibling::*[@type][not(@type = ('#author','#affiliation','#email'))][1]" mode="pass3"/>
  </xsl:template>
    
  <xsl:template match="t:p[lower-case(@type)='#articleheader']" mode="pass3">
    <xsl:param name="inSubSection" select="false()"/>
    <xsl:choose>
      <xsl:when test="$inSubSection"/>
      <xsl:otherwise>
        <div type="section">
          <head><xsl:apply-templates select="node()"/></head>
          <xsl:for-each select="following-sibling::*[not(@type)][preceding-sibling::t:p[@type][1] = current()]">
            <xsl:copy>
              <xsl:apply-templates select="node()|@*"/>
            </xsl:copy>
          </xsl:for-each>
          <xsl:apply-templates select="following-sibling::t:p[@type][preceding-sibling::t:p[@type='#articleHeader'][1] is current()][not(@type = ('#articleHeader','#bibliography','#corrections'))][1]" mode="pass3">
            <xsl:with-param name="inSubSection" select="true()"/>
          </xsl:apply-templates>
        </div>
        <xsl:apply-templates select="following-sibling::t:*[@type=('#articleHeader','#bibliography','#corrections')][1]" mode="pass3">
          <xsl:with-param name="inSubSection" select="$inSubSection"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#acknowledgement']" mode="pass3">
    <note type="acknowledgement"><xsl:apply-templates/></note>
    <xsl:apply-templates select="following-sibling::*[not(@type)][preceding-sibling::t:p[@type][1] = current()]"/>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="pass3"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#author']" mode="pass3">
    <author><xsl:apply-templates/></author>
  </xsl:template>
  
  <xsl:template match="t:p[@type='edition']" mode="pass3">
    <xsl:param name="inSubSection" select="false()"/>
    <div type="epidoc" subtype="{@subtype}">
      <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
    </div>
    <xsl:apply-templates select="following-sibling::*[lower-case(@type) = ('edition','#articleheader')][1]" mode="pass3">
      <xsl:with-param name="inSubSection" select="$inSubSection"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#email']" mode="pass3">
    <email><xsl:apply-templates/></email>
  </xsl:template>
  
  <xsl:template match="t:table[@type='#corrections']" mode="pass3">
    <xsl:param name="inSubSection" select="false()"/>
    <xsl:choose>
      <xsl:when test="$inSubSection"/>
      <xsl:otherwise>
        <div type="corrections">
          <xsl:copy>
            <xsl:apply-templates select="*|@*"/>
          </xsl:copy>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="t:table[@type='#metadata']" mode="epidoc">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:for-each select="following-sibling::*[preceding-sibling::t:*[@type][1] is current()][not(@type)]">
      <xsl:choose>
        <xsl:when test="self::t:p[string-length(normalize-space(.)) gt 0]">
          <head><xsl:apply-templates/></head>
        </xsl:when>
        <xsl:when test="self::t:table">
          <xsl:copy>
            <xsl:apply-templates/>
          </xsl:copy>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#introduction']" mode="epidoc pass3">
    <div type="introduction">
      <p><xsl:apply-templates/></p>
      <xsl:for-each select="following-sibling::*[preceding-sibling::t:p[@type][1] is current()][not(@type)]">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#text']" mode="epidoc">
    <xsl:variable name="start" select="if (starts-with(normalize-space(.),'&lt;S=')) then . else following-sibling::t:p[starts-with(.,'&lt;S=')][1]"/>
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
      <note>
        <p><xsl:apply-templates select="text()[1]" mode="comment"/><xsl:apply-templates select="text()[1]/following-sibling::node()"/></p>
        <xsl:if test="following-sibling::*[1]/self::t:p[not(@type) and not(matches(., '^(\d|-)'))]">
          <xsl:apply-templates select="following-sibling::*[1]" mode="note"/>
        </xsl:if>
      </note>
      <xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] is current()][not(@type)][matches(., '^(\d|-)')]">
        <note>
          <p><xsl:apply-templates select="text()[1]" mode="comment"/><xsl:apply-templates select="text()[1]/following-sibling::node()"/></p>
          <xsl:if test="following-sibling::*[1]/self::t:p[not(@type) and not(matches(., '^(\d|-)'))]">
            <xsl:apply-templates select="following-sibling::*[1]" mode="note"/>
          </xsl:if>
        </note>
      </xsl:for-each>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="epidoc"/>
  </xsl:template>
  
  <xsl:template match="t:p[not(matches(., '^(\d|-)'))]" mode="note">
    <p><xsl:apply-templates/></p>
    <xsl:if test="following-sibling::*[1]/self::t:p[not(@type) and not(matches(., '^(\d|-)'))]">
      <xsl:apply-templates select="following-sibling::*[1]" mode="note"/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="t:p[@type='#bibliography']" mode="epidoc pass3">
    <xsl:message>In Bibliography</xsl:message>
    <div type='bibliography'>
      <listBibl>
        <bibl><xsl:apply-templates select="node()"/></bibl>
        <xsl:for-each select="following-sibling::t:p[preceding-sibling::t:p[@type][1] is current()][not(@type)]">
          <bibl><xsl:apply-templates select="node()"/></bibl>
        </xsl:for-each>
      </listBibl>
    </div>
    <xsl:apply-templates select="following-sibling::*[@type][1]" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="t:p[lower-case(@n)='#blockquote']" mode="pass2">
    <quote>
      <lb/><xsl:apply-templates mode="pass2"/><xsl:text>
</xsl:text>
      <xsl:apply-templates select="t:p[following-sibling::t:p[lower-case(@n) = '#endblockquote'][1] 
        is current()/following-sibling::t:p[lower-case(@n) = '#endblockquote'][1]]" mode="blockquote"/>
    </quote>
  </xsl:template>
  
  <xsl:template match="*" mode="pass2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="pass2"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:p[lower-case(@n) = '#endblockquote']" priority="2" mode="pass2">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name(.) = 'n')]"/>
      <xsl:apply-templates mode="pass2"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="t:p[count(preceding-sibling::t:p[lower-case(@n)='#blockquote']) gt count(preceding-sibling::t:p[lower-case(@n)='#endblockquote'])]" mode="pass2"/>
  
  <xsl:template match="t:p" mode="blockquote">
    <lb/><xsl:apply-templates mode="pass2"/>
  </xsl:template>
  
  <xsl:template match="*[not(@type = ('#metadata','#text','#introduction','#translation','#commentary','#bibliography'))]" mode="epidoc"/>
  
  <xsl:template match="t:p" mode="pass3"/>
  
  <xsl:template match="text()" mode="comment" xml:space="preserve"><xsl:choose>
      <xsl:when test="matches(.,'^\t?(-|\d+[-–.0-9]*)\s+')"><ref><xsl:value-of select="replace(.,'^\t?((-|\d+[-–.0-9]*))\s.*','$1')"/></ref> <xsl:value-of select="replace(.,'^\t?(-|\d+[-–.0-9]*)\s+(.*)$','$2')"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose></xsl:template>
  
  <xsl:template match="@rend"/>
  
  <xsl:function name="t:lc-seq">
    <xsl:param name="seq"/>
    <xsl:for-each select="$seq">
      <xsl:value-of select="lower-case(.)"/>
    </xsl:for-each>
  </xsl:function>
  
</xsl:stylesheet>