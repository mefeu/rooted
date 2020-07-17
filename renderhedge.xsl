<?xml version="1.0" encoding="windows-1250"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:import href="hedge2svg.xsl"/>

  <xsl:output indent="yes"/>

  <xsl:param name="hedge"/>

  <xsl:template match="/">
    <xsl:call-template name="hedge2svg">
      <xsl:with-param name="hedge" select="$hedge"/>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>