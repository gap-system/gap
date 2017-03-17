
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:fns="http://www.w3.org/2002/Math/preference"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  extension-element-prefixes="msxsl fns"
>

<!--
Copyright David Carlisle 2001, 2002.

Use and distribution of this code are permitted under the terms of the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720"
>W3C Software Notice and License</a>.
-->

<xsl:include href="ctop.xsl"/>
<xsl:include href="pmathml.xsl"/>

<xsl:output/>

<xsl:template match="/">
<xsl:choose>
<xsl:when test="system-property('xsl:vendor')='Transformiix'">
<xsl:apply-templates mode="c2p"/>
</xsl:when>
<!-- not working, currently
<xsl:when test="system-property('xsl:vendor')='Microsoft' and /*/@fns:renderer='css'">
<xsl:variable name="pmml">
<xsl:apply-templates mode="c2p"/>
</xsl:variable>
<xsl:apply-templates select="msxsl:node-set($pmml)/node()"/>
</xsl:when>
-->
<xsl:otherwise>
<xsl:apply-templates/>
</xsl:otherwise>
</xsl:choose>
</xsl:template> 
</xsl:stylesheet>
