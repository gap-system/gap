<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:fns="http://www.w3.org/2002/Math/preference"
  xmlns:doc="http://www.dcarlisle.demon.co.uk/xsldoc"
  xmlns:ie5="http://www.w3.org/TR/WD-xsl"
  exclude-result-prefixes="h ie5 fns msxsl fns doc"
  extension-element-prefixes="msxsl fns doc"
>

<!--

Copyright David Carlisle 2001, 2002.

Use and distribution of this code are permitted under the terms of the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720"
>W3C Software Notice and License</a>.
-->

<!-- MathPlayer mpdialog code for contributed by
     Jack Dignan and Robert Miner, both of Design Science.
-->

<xsl:output method="xml" omit-xml-declaration="yes"  />

<ie5:if doc:id="iehack" test=".">
    <ie5:eval no-entities="t">'&lt;!--'</ie5:eval>
</ie5:if>


<fns:x name="mathplayer" o="MathPlayer.Factory.1">
<object id="mmlFactory" 
        classid="clsid:32F66A20-7614-11D4-BD11-00104BD3F987">
</object>
<?import namespace="mml" implementation="#mmlFactory"?>
</fns:x>

<fns:x name="techexplorer" o="techexplorer.AxTchExpCtrl.1">
<object id="mmlFactory" classid="clsid:0E76D59A-C088-11D4-9920-002035EFB1A4">
</object>
<?import namespace="mml" implementation="#mmlFactory"?>
</fns:x>


<fns:x name="css" o="Microsoft.FreeThreadedXMLDOM">
<script for="window" event="onload">
var xsl = new ActiveXObject("Microsoft.FreeThreadedXMLDOM");
xsl.async = false;
xsl.validateOnParse = false;
xsl.load("pmathmlcss.xsl");
var xslTemplate = new ActiveXObject("MSXML2.XSLTemplate.3.0");
xslTemplate.stylesheet=xsl.documentElement;
var xslProc = xslTemplate.createProcessor();
xslProc.input = document.XMLDocument;
xslProc.transform();
var str = xslProc.output;
var newDoc = document.open("text/html", "replace");
newDoc.write(str);
</script>
</fns:x>


<h:p>
in mpdialog mode, we just write out some JavaScript to display 
dialog to the reader asking whether they want to install MathPlayer 
Depending on the response we get, we then instantiate an XSL processor
and reprocess the doc, passing $secondpass according to the
reader response.
</h:p>
<h:p>Using d-o-e is fairly horrible, but this code is only for IE
anyway, and we need to force HTML semantics in this case.</h:p>

<xsl:variable name="mpdialog">
var cookieName = "MathPlayerInstall=";
function MPInstall(){
 var showDialog=true;
 var c = document.cookie;
 var i = c.indexOf(cookieName);
 if (i >= 0) {
  if ( c.substr(i + cookieName.length, 1) >= 2) { showDialog=false; }
 }
 if (showDialog) {
  MPDialog();
  c = document.cookie;
  i = c.indexOf(cookieName);
 }
 if (i >= 0) return c.substr(i + cookieName.length, 1);
 else return null;
}

function MPDialog() {
 var vArgs="";
 var sFeatures="dialogWidth:410px;dialogHeight:190px;help:off;status:no";
 var text = "";
 text += "javascript:document.write('"
 text += '&lt;script>'
 text += 'function fnClose(v) { '
 text += 'var exp = new Date();'
 text += 'var thirtyDays = exp.getTime() + (30 * 24 * 60 * 60 * 1000);'
 text += 'exp.setTime(thirtyDays);'
 text += 'var cookieProps = ";expires=" + exp.toGMTString();'
 text += 'if (document.forms[0].dontask.checked) v+=2;'
 text += 'document.cookie="' + cookieName + '"+v+cookieProps;'
 text += 'window.close();'
 text += '}'
 text += '&lt;/' + 'script>'
 text += '&lt;head>&lt;title>Install MathPlayer?&lt;/title>&lt;/head>'
 text += '&lt;body bgcolor="#D4D0C8">&lt;form>'
 text += '&lt;table cellpadding=10 style="font-family:Arial;font-size:10pt" border=0 width=100%>'
 text += '&lt;tr>&lt;td align=left>This page requires Design Science\\\'s MathPlayer&amp;trade;.&lt;br>'
 text += 'Do you want to download and install MathPlayer?&lt;/td>&lt;/tr>';
 text += '&lt;tr>&lt;td align=center>&lt;input type="checkbox" name="dontask">'
 text += 'Don\\\'t ask me again&lt;/td>&lt;/tr>'
 text += '&lt;tr>&lt;td align=center>&lt;input id=yes type="button" value=" Yes "'
 text += ' onClick="fnClose(1)">&amp;nbsp;&amp;nbsp;&amp;nbsp;'
 text += '&lt;input type="button" value="  No  " onClick="fnClose(0)">&lt;/td>&lt;/tr>'
 text += '&lt;/table>&lt;/form>';
 text += '&lt;/body>'
 text += "')"
 window.showModalDialog( text , vArgs, sFeatures );
}

function WaitDialog() {
 var vArgs="";
 var sFeatures="dialogWidth:510px;dialogHeight:150px;help:off;status:no";
 var text = "";
 text += "javascript:document.write('"
 text += '&lt;script>'
 text += 'window.onload=fnLoad;'
 text += 'function fnLoad() {document.forms[0].yes.focus();}'
 text += 'function fnClose(v) { '
 text += 'window.returnValue=v;'
 text += 'window.close();'
 text += '}'
 text += '&lt;/' + 'script>'
 text += '&lt;head>&lt;title>Wait for Installation?&lt;/title>&lt;/head>'
 text += '&lt;body bgcolor="#D4D0C8" onload="fnLoad()">&lt;form>&lt;'
 text += 'table cellpadding=10 style="font-family:Arial;font-size:10pt" border=0 width=100%>'
 text += '&lt;tr>&lt;td align=left>Click OK once MathPlayer is installed '
 text += 'to refresh the page.&lt;br>'
 text += 'Click Cancel to view the page immediately without MathPlayer.&lt;/td>&lt;/tr>';
 text += '&lt;tr>&lt;td align=center>&lt;input id=yes type="button" '
 text += 'value="   OK   " onClick="fnClose(1)">&amp;nbsp;&amp;nbsp;&amp;nbsp;'
 text += '&lt;input type="button" value="Cancel" onClick="fnClose(0)">&lt;/td>&lt;/tr>'
 text += '&lt;/table>&lt;/form>';
 text += '&lt;/body>'
 text += "')"
 return window.showModalDialog( text , vArgs, sFeatures );
}

var result = MPInstall();

var action = "fallthrough";
if (result == 1 || result == 3) {
 window.open("http://www.dessci.com/webmath/mathplayer");
 var wait = WaitDialog();
 if ( wait == 1) {
  action =  "install";
  document.location.reload();

 }
}
if (action == "fallthrough") {
var xsl = new ActiveXObject("Microsoft.FreeThreadedXMLDOM");
xsl.async = false;
xsl.validateOnParse = false;
xsl.load("pmathmlcss.xsl");
var xslTemplate = new ActiveXObject("MSXML2.XSLTemplate.3.0");
xslTemplate.stylesheet=xsl.documentElement;
var xslProc = xslTemplate.createProcessor();
xslProc.input = document.XMLDocument;

xslProc.transform();
var str = xslProc.output;
var newDoc = document.open("text/html", "replace");
newDoc.write(str);
document.close();
}
</xsl:variable>

<fns:x name="mathplayer-dl" >mathplayer-dl</fns:x>

<fns:x name="techexplorer-plugin" >techexplorer-plugin</fns:x>

<xsl:variable name="docpref" select="document('')/*/fns:x[@name=current()/*/@fns:renderer][1]"/>

<xsl:param name="activex">
   <xsl:choose>
     <xsl:when test="$docpref='techexplorer-plugin'">techexplorer-plugin</xsl:when>
     <xsl:when test="system-property('xsl:vendor')!='Microsoft'"/>
     <xsl:when test="$docpref='mathplayer-dl'">mathplayer-dl</xsl:when>
     <xsl:when test="$docpref and fns:isinstalled(string($docpref/@o))='true'">
           <xsl:copy-of select="$docpref/node()"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:copy-of select="(document('')/*/fns:x[fns:isinstalled(string(@o))='true'])[1]/node()"/>
     </xsl:otherwise>
  </xsl:choose>
</xsl:param>

<h:div doc:ref="iehack">
<h:h3>IE5 hacks</h:h3>
<h:p>This code will be ignored by an XSLT engine as a top level
element in a foreign namespace. It will be executed by an IE5XSL
engine and insert &lt;!-- into the output stream, ie the start of a
comment. This will comment out all the XSLT code which will be copied
to the output. A similar clause below will close this comment, it is
then followed by the IE5XSL templates to be executed.</h:p>
<h:p>This trick is due to Jonathan Marsh of Microsoft, and used in
<h:a href="http://www.w3.org/TR/2001/WD-query-datamodel-20010607/xmlspec-ie-dm.xsl">the stylesheet for
the XPath 2 data model draft</h:a>.</h:p>
</h:div>

<h:h2>XSLT stylesheet</h:h2>
<h:h3>MSXSL script block</h:h3>

<h:p>The following script block implements an extension function that
tests whether a specified ActiveX component is known to the client.
This is used below to test for the existence of MathML rendering
components.</h:p>
<msxsl:script language="JScript" implements-prefix="fns">
    function isinstalled(ax) 
    {
    try {
        var ActiveX = new ActiveXObject(ax);
        return "true";
    } catch (e) {
        return "false";
    }
}
</msxsl:script>

<h:p>The main bulk of this stylesheet is an identity transformation so...</h:p>
<xsl:template match="*">
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:apply-templates/>
</xsl:copy>
</xsl:template>



<h:p>XHTML elements are copied sans prefix (XHTML is default namespace
here, so these elements will still be in XHTML namespace</h:p>
<xsl:template match="h:*">
<xsl:element name="{local-name(.)}">
 <xsl:copy-of select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>

<h:p>This just ensures the mathml prefix declaration isn't copied from
the source at this stage, so that the system will use the mml prefix
coming from this stylesheet</h:p>
<xsl:template match="h:html|html">
<html>
<xsl:copy-of select="@*[not(namespace-uri(.)='http://www.w3.org/2002/Math/preference')]"/>
<xsl:apply-templates/>
</html>
</xsl:template>

<h:p>We modify the head element to add code to specify a Microsoft
"Behaviour" if the behaviour component is known to the system.</h:p>
<h:span doc:ref="mp">Test for MathPlayer (Design Science)</h:span>
<h:span doc:ref="te">Test for Techexplorer (IBM)</h:span>
<h:span doc:ref="ms"><h:div>Test for Microsoft. In this case we just
output a small HTML file that executes a script that will re-process
the source docuument with a different stylesheet. Doing things this
way avoids the need to xsl:import the second stylesheet, which would
very much increase the processing overhead of running this
stylesheet.</h:div></h:span>
<h:span doc:ref="other">Further tests (eg for netscape/mozilla) could
be added here if necessary</h:span>
<xsl:template match="h:head|head">
<head>
<xsl:choose>
<xsl:when doc:id="mp" test="$activex='mathplayer-dl'">
    <xsl:if test="fns:isinstalled('MathPlayer.Factory.1')='false'">
     <script for="window" event="onload">
       <xsl:value-of select="$mpdialog" disable-output-escaping="yes"/>
     </script>
    </xsl:if>
   <xsl:copy-of select="document('')/*/fns:x[@name='mathplayer']"/>
</xsl:when>
<xsl:when doc:id="mp" test="not($activex='techexplorer-plugin') and system-property('xsl:vendor')='Microsoft'">
  <xsl:copy-of select="$activex"/>
</xsl:when>
<xsl:otherwise doc:id="other">
</xsl:otherwise>
</xsl:choose>
  <xsl:apply-templates/>
</head>
</xsl:template>


<xsl:template match="mml:math" priority="22">
<xsl:choose>
<xsl:when test="$activex='techexplorer-plugin'">
<embed  type="text/mathml" height="75" width="300">
<xsl:attribute name="mmldata">
<xsl:apply-templates mode="verb" select="."/>
</xsl:attribute>
</embed>
</xsl:when>
<xsl:otherwise>
<xsl:element name="mml:{local-name(.)}">
 <xsl:copy-of select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<h:p>Somewhat bizarrely in an otherwise namespace aware system,
Microsoft behaviours are defined to trigger off the
<h:em>prefix</h:em> not the <h:em>Namespace</h:em>. In the code above
we associated a MathML rendering behaviour (if one was found) with the
prefix <h:code>mml:</h:code> so here we ensure that this is the prefix
that actually gets used in the output.</h:p>
<xsl:template match="mml:*">
<xsl:element name="mml:{local-name(.)}">
 <xsl:copy-of select="@*"/>
<xsl:apply-templates/>
</xsl:element>
</xsl:template>


<!-- a version of my old verb.xsl -->

<!-- non empty elements and other nodes. -->
<xsl:template mode="verb" match="*[*]|*[text()]|*[comment()]|*[processing-instruction()]">
  <xsl:value-of select="concat('&lt;',local-name(.))"/>
  <xsl:apply-templates mode="verb" select="@*"/>
  <xsl:text>&gt;</xsl:text>
  <xsl:apply-templates mode="verb"/>
  <xsl:value-of select="concat('&lt;/',local-name(.),'&gt;')"/>
</xsl:template>

<!-- empty elements -->
<xsl:template mode="verb" match="*">
  <xsl:value-of select="concat('&lt;',local-name(.))"/>
  <xsl:apply-templates mode="verb" select="@*"/>
  <xsl:text>/&gt;</xsl:text>
</xsl:template>

<!-- attributes
     Output always surrounds attribute value by "
     so we need to make sure no literal " appear in the value  -->
<xsl:template mode="verb" match="@*">
  <xsl:value-of select="concat(' ',local-name(.),'=')"/>
  <xsl:text>"</xsl:text>
  <xsl:call-template name="string-replace">
    <xsl:with-param name="from" select="'&quot;'"/>
    <xsl:with-param name="to" select="'&amp;quot;'"/> 
    <xsl:with-param name="string" select="."/>
  </xsl:call-template>
  <xsl:text>"</xsl:text>
</xsl:template>

<!-- pis -->
<xsl:template mode="verb" match="processing-instruction()"/>

<!-- only works if parser passes on comment nodes -->
<xsl:template mode="verb" match="comment()"/>


<!-- text elements
     need to replace & and < by entity references-->
<xsl:template mode="verb" match="text()">
  <a name="{generate-id(.)}"/>
  <xsl:call-template name="string-replace">
    <xsl:with-param name="to" select="'&amp;gt;'"/>
    <xsl:with-param name="from" select="'&gt;'"/> 
    <xsl:with-param name="string">
      <xsl:call-template name="string-replace">
        <xsl:with-param name="to" select="'&amp;lt;'"/>
        <xsl:with-param name="from" select="'&lt;'"/> 
        <xsl:with-param name="string">
          <xsl:call-template name="string-replace">
            <xsl:with-param name="to" select="'&amp;amp;'"/>
            <xsl:with-param name="from" select="'&amp;'"/> 
            <xsl:with-param name="string" select="."/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>


<!-- end  verb mode -->

<!-- replace all occurences of the character(s) `from'
     by the string `to' in the string `string'.-->
<xsl:template name="string-replace" >
  <xsl:param name="string"/>
  <xsl:param name="from"/>
  <xsl:param name="to"/>
  <xsl:choose>
    <xsl:when test="contains($string,$from)">
      <xsl:value-of select="substring-before($string,$from)"/>
      <xsl:value-of select="$to"/>
      <xsl:call-template name="string-replace">
      <xsl:with-param name="string" select="substring-after($string,$from)"/>
      <xsl:with-param name="from" select="$from"/>
      <xsl:with-param name="to" select="$to"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$string"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- end of verb.xsl -->



<h:h2>IE5XSL stylesheet</h:h2>
<h:p>In a rare fit of sympathy for users of
<h:em>the-language-known-as-XSL-in-IE5</h:em> this file incorporates a
version of the above code designed to work in the Microsoft dialect.
This is needed otherwise users of a MathML rendering behaviour would
have to make a choice whether they wanted to use this stylesheet
(keeping their source documents conforming XHTML+MathML) or to use
the explicit Microsoft Object code, which is less portable, but would
work in at least IE5.5.</h:p>

<h:p>This entire section of code, down to the end of the stylesheet is
contained within this ie5:if. Thus XSLT sees it as a top level element
from a foreign namespace and silently ignores it. IE5XSL sees it as
"if true" and so executes the code.</h:p>


<h:p doc:ref="closecomment">First close the comment started at the beginning. This ensures
that the bulk of the XSLT code, while being copied to the result tree
by the IE5XSL engine, will not be rendered in the browser.</h:p>

<h:span doc:ref="eval">Lacking attribute value templates in
xsl:element, and the local-name() function, we resort to constructing
the start and end tags in strings in javascript, then using
no-entities attribute which is the IE5XSL equivalent of disable-output-encoding</h:span>
<ie5:if test=".">

<ie5:eval doc:id="closecomment" no-entities="t">'--&gt;'</ie5:eval>

<ie5:apply-templates select=".">


<ie5:script>
    function mpisinstalled() 
    {
    try {
        var ActiveX = new ActiveXObject("MathPlayer.Factory.1");
        return "true";
    } catch (e) {
        return "false";
    }
}
</ie5:script>

<ie5:template match="/">
<ie5:apply-templates/>
</ie5:template>

<ie5:template match="head|h:head"/>

<ie5:template match="text()">
<ie5:value-of select="."/>
</ie5:template>

<ie5:template match="*|@*">
<ie5:copy>
<ie5:apply-templates select="*|text()|@*"/>
</ie5:copy>
</ie5:template>


<ie5:template match="mml:*">
<ie5:eval  no-entities="t" doc:id="eval">'&lt;mml:' + this.nodeName.substring(this.nodeName.indexOf(":")+1)</ie5:eval>
<ie5:for-each select="@*">
<ie5:eval no-entities="t">' ' + this.nodeName</ie5:eval>="<ie5:value-of select="."/>"
</ie5:for-each>
<ie5:eval no-entities="t">'&gt;'</ie5:eval>
<ie5:apply-templates select="*|text()"/>
<ie5:eval no-entities="t">'&lt;/mml:' +  this.nodeName.substring(this.nodeName.indexOf(":")+1) + '&gt;'</ie5:eval>
</ie5:template>


<ie5:template match="mml:math">
<ie5:if expr="mpisinstalled()=='false'">
<embed  type="text/mathml" height="75" width="300">
<ie5:attribute name="mmldata">
<ie5:eval  doc:id="eval"  no-entities="t">'&lt;math&gt;'</ie5:eval>
<ie5:apply-templates/>
<ie5:eval  doc:id="eval"  no-entities="t">'&lt;/math&gt;'</ie5:eval>
</ie5:attribute>
</embed>
</ie5:if>
<ie5:if expr="mpisinstalled()=='true'">
<ie5:eval  doc:id="eval"  no-entities="t">'&lt;mml:' + this.nodeName.substring(this.nodeName.indexOf(":")+1)</ie5:eval>
<ie5:for-each select="@*">
<ie5:eval no-entities="t">' ' + this.nodeName</ie5:eval>="<ie5:value-of select="."/>"
</ie5:for-each>
<ie5:eval no-entities="t">'&gt;'</ie5:eval>
<ie5:apply-templates select="*|text()"/>
<ie5:eval no-entities="t">'&lt;/mml:' +  this.nodeName.substring(this.nodeName.indexOf(":")+1) + '&gt;'</ie5:eval>
</ie5:if>
</ie5:template>

<ie5:template match="html|h:html">
<html   xmlns:mml="http://www.w3.org/1998/Math/MathML">
<head>
<ie5:if expr="mpisinstalled()=='true'">
<object id="mmlFactory"
        classid="clsid:32F66A20-7614-11D4-BD11-00104BD3F987">
</object>
<ie5:pi name="IMPORT">
 namespace="mml" implementation="#mmlFactory"
</ie5:pi>
</ie5:if>
<ie5:apply-templates select="h:head/*|head/*"/>
</head>
<body>
<ie5:apply-templates select="body|h:body"/>
</body>
</html>
</ie5:template>

</ie5:apply-templates>


</ie5:if>


</xsl:stylesheet>
