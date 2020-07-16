<?xml version="1.0"?>                
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="top">
<html>
<head>
    <title>Rooted</title>
    <link rel="stylesheet" type="text/css" href="style.css" />
</head>
<body>
<div class="bar navbar">
    <span class="title">
 			<a href="https://rooted.ddnss.de/tree.xml"><img src="assets/icon.svg" alt="rooted" width="200" class="logo"/></a>
    </span>
    <span class="search">
        <input autocomplete="off" placeholder="Suche"/>
        
    </span>
</div>
    <div class="tree">
    <xsl:apply-templates/>
    </div>
</body>
</html>
</xsl:template>
<xsl:template match="node">

    <ul>
	    <li><xsl:value-of select="@text"/></li>
	    <li><xsl:value-of select="@name"/></li>
        <xsl:for-each select="child::node">
            <ul>
                <li>
                    <xsl:value-of select="@text"/>                
                    <xsl:apply-templates select="node()"/>
                </li>
            </ul>
        </xsl:for-each>
    </ul>

</xsl:template>
</xsl:stylesheet>
