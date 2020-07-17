<?xml version="1.0" encoding="windows-1250"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:func="http://exslt.org/functions"
                xmlns:exsl="http://exslt.org/common"
                xmlns:my="http://example.com/my"
                extension-element-prefixes="my func exsl"
                exclude-result-prefixes="my func exsl"
                xmlns:svg="http://www.w3.org/2000/svg"
                version="1.0">

<!-- Main template -->
<xsl:template name="hedge2svg">
  <!-- Hedge is passed as parameter -->
  <xsl:param name="hedge"/>

  <!-- Parse text hedge into XML nodes -->
  <xsl:variable name="tree">
    <xsl:call-template name="hedge2xml">
      <xsl:with-param name="hedge" select="$hedge"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- Add layout information to XML nodes -->
  <xsl:variable name="layoutTree">
    <xsl:apply-templates select="exsl:node-set($tree)/node" mode="xml2layout"/>
  </xsl:variable>

  <!-- Turn XML nodes into SVG image -->
  <xsl:call-template name="layout2svg">
    <xsl:with-param name="layout" select="exsl:node-set($layoutTree)"/>
  </xsl:call-template>

</xsl:template>

<!-- Simple text parser generates tree of nodes from compact syntax -->
<xsl:template name="hedge2xml">
  <xsl:param name="hedge"/>
  <!-- Extract first token -->
  <xsl:param name="head" select="substring($hedge, 1, 1)"/>

  <!-- If there is something left to parse then parse it -->
  <xsl:if test="$hedge != ''">
    <xsl:variable name="next" select="substring($hedge, 2, 1)"/>
    <xsl:variable name="tail" select="substring($hedge, 3)"/>

    <xsl:choose>

      <!-- Node name is enclosed between { and }. Grab it into $head and proceed. -->
      <xsl:when test="$head = '{'">
        <xsl:call-template name="hedge2xml">
          <xsl:with-param name="hedge" select="concat(' ', substring-after(concat($next, $tail), '}'))"/>
          <xsl:with-param name="head" select="substring-before(concat($next, $tail), '}')"/>
        </xsl:call-template>
      </xsl:when>

      <!-- End of the sub-level. Proceed with next tokens. -->
      <xsl:when test="$head = ')'">
        <xsl:call-template name="hedge2xml">
          <xsl:with-param name="hedge" select="concat($next, $tail)"/>
        </xsl:call-template>
      </xsl:when>

      <!-- There is no node name. Emit error message. -->
      <xsl:when test="$head = '('">
        <xsl:message>
          <xsl:text>Unexpected ( found in '</xsl:text>
          <xsl:value-of select="concat($head, $next, $tail)"/>
          <xsl:text>'.&#10;</xsl:text>
        </xsl:message>
      </xsl:when>
      
      <!-- Start of the sub-level. -->
      <xsl:when test="$next = '('">
        <!-- Find the end of the sub-level. -->
        <xsl:variable name="endPos" select="my:closingParenPos($tail)"/>
        <!-- Create wrapper node and process content of the sub-level. -->
        <node label="{$head}">
          <xsl:call-template name="hedge2xml">
            <xsl:with-param name="hedge" select="substring($tail, 1, $endPos)"/>
          </xsl:call-template>
        </node>
        <!-- Process content after the sub-level. -->
        <xsl:call-template name="hedge2xml">
          <xsl:with-param name="hedge" select="substring($tail, $endPos)"/>
        </xsl:call-template>
      </xsl:when>

      <!-- Output node and process next nodes. -->
      <xsl:otherwise>
        <node label="{$head}"/>
        <xsl:call-template name="hedge2xml">
          <xsl:with-param name="hedge" select="concat($next, $tail)"/>
        </xsl:call-template>
      </xsl:otherwise>
      
    </xsl:choose>
  </xsl:if>
  
</xsl:template>

<!-- Find position of the matching right paranthesis -->
<func:function name="my:closingParenPos">
  <xsl:param name="text"/>
  <xsl:param name="depth" select="1"/>
  <xsl:param name="pos" select="1"/>
  <xsl:choose>
    <!-- Found closing ) which is not nested. We are done. -->
    <xsl:when test="substring($text, 1, 1) = ')' and $depth = 1">
      <func:result select="$pos"/>
    </xsl:when>
    <!-- Found opening (. Increase nesting depth and continue. -->
    <xsl:when test="substring($text, 1, 1) = '('">
      <func:result select="my:closingParenPos(substring($text, 2), $depth + 1, $pos+1)"/>
    </xsl:when>
    <!-- Found closing ) which is nested. Unwrap and continue on a shallower level. -->
    <xsl:when test="substring($text, 1, 1) = ')'">
      <func:result select="my:closingParenPos(substring($text, 2), $depth - 1, $pos+1)"/>
    </xsl:when>
    <!-- End of text while nested. Something is wrong with input. -->
    <xsl:when test="$text = '' and $depth != 0">
      <xsl:message>
        <xsl:text>Warning. Unbalanced parenthesis.&#10;</xsl:text>
      </xsl:message>
    </xsl:when>
    <!-- In all other cases scan rest of the input for parenthesis. -->
    <xsl:otherwise>
      <func:result select="my:closingParenPos(substring($text, 2), $depth, $pos+1)"/>
    </xsl:otherwise>
  </xsl:choose>
</func:function>


<!-- Turn XML tree into the tree with layout information -->

<!-- Add layout attributes to non-leaf nodes -->
<xsl:template match="node[node]" mode="xml2layout">
  <xsl:param name="depth" select="1"/>
  <xsl:variable name="subTree">
    <xsl:apply-templates select="node" mode="xml2layout">
      <xsl:with-param name="depth" select="$depth+1"/>
    </xsl:apply-templates>
  </xsl:variable>

  <!-- Add layout attributes to the existing node -->
  <node depth="{$depth}" width="{sum(exsl:node-set($subTree)/node/@width)}">
    <!-- Copy original attributes and content -->
    <xsl:copy-of select="@*"/>
    <xsl:copy-of select="$subTree"/>
  </node>

</xsl:template>

<!-- Add layout attributes to leaf nodes -->
<xsl:template match="node" mode="xml2layout">
  <xsl:param name="depth" select="1"/>
  <node depth="{$depth}" width="1">
    <xsl:copy-of select="@*"/>
  </node>
</xsl:template>

<!-- Layout to SVG -->

<!-- Magnifying factor -->
<xsl:param name="hedge.scale" select="10"/>

<!-- Convert layout to SVG -->
<xsl:template name="layout2svg">
  <xsl:param name="layout"/>

  <!-- Find depth of the tree -->
  <xsl:variable name="maxDepth">
    <xsl:for-each select="$layout//node">
      <xsl:sort select="@depth" data-type="number" order="descending"/>
      <xsl:if test="position() = 1">
        <xsl:value-of select="@depth"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- Create SVG wrapper -->
  <svg:svg viewBox="0 0 {sum($layout/node/@width) * 2 * $hedge.scale} {$maxDepth * 2 * $hedge.scale}" 
    >
    <!-- Note that some SVG implementation work better when you set explicit width and height also. 
         In that case add following attributes to svg element:
            width="{sum($layout/node/@width)*5}mm" 
            depth="{$maxDepth*5}mm" 
            preserveAspectRatio="xMidYMid meet" 
    -->
    <svg:g transform="translate(0,-{$hedge.scale div 2}) scale({$hedge.scale})">
      <xsl:apply-templates select="$layout/node" mode="layout2svg"/>
    </svg:g>
  </svg:svg>
</xsl:template>

<!-- Draw one node --> 
<xsl:template match="node" mode="layout2svg">
  <!-- Calculate X coordinate -->
  <xsl:variable name="x" select="(sum(preceding::node[@depth = current()/@depth or (not(node) and @depth &lt;= current()/@depth)]/@width) + (@width div 2)) * 2"/>
  <!-- Calculate Y coordinate -->
  <xsl:variable name="y" select="@depth * 2"/>
  <!-- Draw label of node -->
  <svg:text x="{$x}"
            y="{$y - 0.2}"
            style="text-anchor: middle; font-size: 0.9;">
    <xsl:value-of select="@label"/>
  </svg:text>
  <!-- Draw rounded rectangle around label -->
  <svg:rect x="{$x - 0.9}" y="{$y - 1}" width="1.8" height="1" 
            rx="0.4" ry="0.4"
            style="fill: none; stroke: black; stroke-width: 0.1;"/>
  <!-- Draw connector lines to all sub-nodes -->
  <xsl:for-each select="node">
    <svg:line x1="{$x}" 
              y1="{$y}" 
              x2="{(sum(preceding::node[@depth = current()/@depth or (not(node) and @depth &lt;= current()/@depth)]/@width) + (@width div 2)) * 2}" 
              y2="{@depth * 2 - 1}"
              style="stroke-width: 0.1; stroke: black;"/>
  </xsl:for-each>
  <!-- Draw sub-nodes -->
  <xsl:apply-templates select="node" mode="layout2svg"/>
</xsl:template>


</xsl:stylesheet>