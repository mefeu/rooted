<?xml version="1.0"?>                
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="node">
<html>
<body>
    <div class="tree">
    <ul>
        <li><xsl:value-of select="@text"/></li>
        <xsl:for-each select="child::node">
            <ul>
                <li>
                    <xsl:value-of select="@text"/>                
                    <xsl:apply-templates select="node()"/>
                </li>
            </ul>
        </xsl:for-each>
    </ul>
</div>
</body>
</html>
</xsl:template>

</xsl:stylesheet>