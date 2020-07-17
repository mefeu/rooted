<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="1.0">

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/fo/docbook.xsl"/>
<xsl:include href="hedge2svg.xsl"/>

<xsl:template match="phrase[@role='hedge']">
  <fo:instream-foreign-object alignment-baseline="middle">
    <xsl:call-template name="hedge2svg">
      <xsl:with-param name="hedge" select="."/>
    </xsl:call-template>
  </fo:instream-foreign-object>
</xsl:template>

<xsl:param name="draft.watermark.image" select="''"/>

</xsl:stylesheet>