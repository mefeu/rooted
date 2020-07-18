<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg" xmlns="http://www.w3.org/2000/svg" version="2.0">
  <xsl:output method="xml" omit-xml-declaration="yes" encoding="UTF-8" indent="yes" />

  <xsl:template match="/graphml/graph">

    <!-- Find the root ID -->
    <xsl:variable name="rootId">
      <xsl:for-each select="node">
        <xsl:variable name="nodeId" select="@id"/>
        <xsl:if test="not(../edge[@target=$nodeId])">
          <xsl:value-of select="$nodeId"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Turn flat list into a tree -->
    <xsl:variable name="tree">
      <xsl:apply-templates select="node[@id=$rootId]"/>
    </xsl:variable>

    <!-- Turn tree into a flat list of svg elements -->
    <svg>
      <g transform="translate(50 50)">
        <xsl:apply-templates select="$tree"/>
      </g>
    </svg>
  </xsl:template>

  <xsl:template match="node">
    <xsl:variable name="nodeId" select="@id"/>
    <xsl:variable name="childIds" select="//edge[@source=$nodeId]/@target"/>
    <treeNode id="{@id}">
      <xsl:apply-templates select="//node[@id=$childIds]"/>
    </treeNode>
  </xsl:template>

  <xsl:template match="svg:treeNode">
    <xsl:variable name="level" select="count(ancestor::*)"/>
    <xsl:variable name="leafChildren" select="count(descendant::*[not(descendant::*)])"/>
    <xsl:variable name="earlierChildren" select="count(preceding::*[not(descendant::*)])"/>
    <xsl:variable name="x" select="100 * $level"/>
    <xsl:variable name="y" select="50 * $earlierChildren + 25 * max((0, $leafChildren - 1))"/>
    <g class="node">
      <circle cx="{$x}" cy="{$y}" r="10"/>
      <text x="{$x - 10}" y="{$y + 25}"><xsl:value-of select="@id"/></text>

      <!-- Draw line to parent -->
      <xsl:if test="$level != 0">
        <xsl:variable name="parentLevel" select="$level - 1"/>
        <xsl:variable name="parentLeafChildren" select="count(../descendant::*[not(descendant::*)])"/>
        <xsl:variable name="parentEarlierChildren" select="count(../preceding::*[not(descendant::*)])"/>
        <xsl:variable name="parentX" select="100 * $parentLevel"/>
        <xsl:variable name="parentY" select="50 * $parentEarlierChildren + 25 * max((0, $parentLeafChildren - 1))"/>
        <path d="M {$parentX} {$parentY} C {$parentX + 50} {$parentY}, {$x - 50} {$y}, {$x} {$y}" stroke="black" fill="transparent" stroke-width="2"/>
      </xsl:if>
    </g>
    <xsl:apply-templates select="child::*"/>
  </xsl:template>

</xsl:stylesheet>