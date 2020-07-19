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
<div class="tree">
<form action="/tree.xml">
<label for="name">Name:</label><br/>
<input type="text" id="name" name="name" value="" required="true"/><br/>
<lable for="ref">Reference:</lable><br/>
<select id="ref" name="ref">
 
    <xsl:apply-templates select="node"/>

</select><br/>
    
      <label for="addAs">add as:</label><br/>
  <select id="addAs" name="addAs">
  <option>child</option>
  <option>parent</option>
  </select><br/><br/>
  <input type="submit" value="Submit"/>
	</form> 
    </div>
    <object data="tree.svg" type="image/svg+xml" width="100%">
    <img src="tree.svg" alt="rooted" width="100%"/>
    </object></div>
</body>
</html>
</xsl:template>

<xsl:template match="node">

  
	<option><xsl:value-of select="@text"/></option>
	<xsl:for-each select="child::node">
	<option>
	<xsl:value-of select="@text"/>                
	<xsl:apply-templates select="node()"/>
</option>
</xsl:for-each>
  
 


</xsl:template>


</xsl:stylesheet> 
