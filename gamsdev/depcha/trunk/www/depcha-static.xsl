<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    Project: GAMS Projekttemplate
    Company: ZIM-ACDH (Zentrum für Informationsmodellierung - Austrian Centre for Digital Humanities)
    Author: Hans Clausen, Maximilian Müller, Gerlinde Schneider, Martina Scholger, Christian Steiner, Elisabeth Steiner
    Last update: 2020
 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:lido="http://www.lido-schema.org" xmlns:bibtex="http://bibtexml.sf.net/" exclude-result-prefixes="#all">

	<xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>

	<xsl:param name="mode"/>
	<xsl:param name="search"/>

	<!-- VARIABLES -->   
	<!-- //////////////////////////////// -->
	<!-- global Variables are defined in depcha-templates.xsl -->
	<xsl:variable name="TEI_HEADER" select="t:TEI/t:teiHeader"/>
	<!-- //////////////////////////////// -->
	<!-- INDICIES -->
	<xsl:variable name="PERSONS" select="$TEI_HEADER//t:listPerson[@ana='bk:Between']"/>
	<xsl:variable name="ORGANISATIONS" select="$TEI_HEADER//t:listOrg[@ana='bk:Between']"/>
	<xsl:variable name="PLACES" select="$TEI_HEADER//t:listPlace[@ana='bk:Between']"/>
	<xsl:variable name="TAXONOMIES" select="$TEI_HEADER//t:taxonomy[@ana='bk:Taxonomy']"/>
	<xsl:variable name="UNITS" select="$TEI_HEADER//t:unitDecl[@ana='bk:Taxonomy']"/>
	<!-- //////////////////////////////// -->
	<!-- Helpers -->
	<xsl:variable name="vLower" select= "'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	
	<!-- //////////////////////////////// -->
	<xsl:variable name="model"
		select="substring-after(/s:sparql/s:results/s:result/s:model/@uri, '/')"/>

	<xsl:variable name="cid">
		<!-- das ist der pid des contextes, kommt aus dem sparql (ggfs. query anpassen) - wenn keine objekte zugeordnet sind, gibt es ihn nicht! -->
		<xsl:value-of select="/s:sparql/s:results/s:result[1]/s:cid"/>
	</xsl:variable>

	<xsl:variable name="teipid">
		<xsl:value-of select="//t:idno[@type = 'PID']"/>
	</xsl:variable>

	<xsl:variable name="lidopid">
		<xsl:value-of select="//lido:lidoRecID"/>
	</xsl:variable>

	<!--variablen für Suchergebnisse-->
	<xsl:variable name="query" select="sparql/head/query"/>
	<xsl:variable name="hitTotal" select="/sparql/head/hitTotal"/>
	<xsl:variable name="hitPageStart" select="/sparql/head/hitPageStart"/>
	<xsl:variable name="hitPageSize" select="/sparql/head/hitPageSize"/>
	<xsl:variable name="hitsFrom" select="sparql/navigation/hits/from"/>
	<xsl:variable name="hitsTo" select="sparql/navigation/hits/to"/>


	<!-- GAMS global variables -->
	<xsl:variable name="zim">Zentrum für Informationsmodellierung - Austrian Centre for Digital
		Humanities</xsl:variable>
	<xsl:variable name="zim-acdh">ZIM-ACDH</xsl:variable>
	<xsl:variable name="gams">Geisteswissenschaftliches Asset Management System</xsl:variable>
	<xsl:variable name="uniGraz">Universität Graz</xsl:variable>
	
	
	
	<!-- project-specific variables -->
	<!-- glossa -->
	<xsl:variable name="gamsdev">/gamsdev/pollin/depcha/trunk/www</xsl:variable>
	<!-- GAMS -->
	<!--<xsl:variable name="gamsdev">/depcha/www</xsl:variable>-->

	<xsl:variable name="projectTitle">
		<xsl:text>DEPCHA - Digital Edition Publishing Cooperative for Historical Accounts</xsl:text>
	</xsl:variable>
	<xsl:variable name="subTitle">
		<xsl:text>Alpha-Version</xsl:text> 
	</xsl:variable>

	<!-- gesamtes css ist in dieser Datei zusammengefasst mit Ausnahme der Navigation -->
	<xsl:variable name="projectCss">
		<xsl:value-of select="concat($gamsdev, '/css/depcha.css')"/>
	</xsl:variable>
	<!--css für die navigation-->
	<xsl:variable name="projectNav">
		<xsl:value-of select="concat($gamsdev, '/css/navbar.css')"/>
	</xsl:variable>


	<xsl:template match="/">

		<html lang="de">
			<head>
				<meta charset="utf-8"/>
				<meta  content="IE=edge"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

				<meta name="keywords"
					content="DEPCHA, digital editions, historical accounts, Historical Financial Records, GAMS, Digital Edition, Publishing Cooperative, 
					  Historical Accounts, Bookkeeping Ontology, Linked Open Data, Web of Data, Digital History"/>
				<meta name="description"
					content="The Project ”Digital Edition Publishing Cooperative for Historical Accounts”, a Andrew W. Mellon funded cooperation of five US partners and the Centre for Information Modelling 
					at Graz University, aims to link the knowledge domain of economic activities to historical accounting records. For this purpose the so-called Bookkeeping Ontology is developed. 
					DEPCHA creates a publication hub for digital editions on the web. It converts multiple formats into RDF and publishes these incombination with the associated transcriptions. 
					DEPCHA also allows the usage of retrieval and visualization functionalities, as well as interoperability and reuse of information in the sense of Linked Open Data."/>

				<meta name="publisher"
					content="Zentrum für Informationsmodellierung - Austrian Centre for Digital Humanities"/>
				<meta name="content-language" content="en"/>
				<meta name="author" content="Christopher Pollin"/>
				<meta name="author" content="Georg Vogeler"/>


				<!--Projekttitel-->
				<title>
					<xsl:value-of select="$projectTitle"/>
				</title>

				<!-- Bootstrap 4 core CSS -->
				<link href="/lib/2.0/bootstrap-4.5.0-dist/css/bootstrap.min.css" rel="stylesheet"/>
				
				<!-- Custom styles for this template -->
				<link href="{concat($gamsdev,'/css/depcha.css')}" rel="stylesheet" type="text/css"/>
				<link href="{concat($gamsdev,'/css/navbar.css')}" rel="stylesheet" type="text/css"/>
				<!-- sidebar -->
				<link href="{concat($gamsdev,'/css/sidebar.css')}" rel="stylesheet" type="text/css" />
				<!-- icons -->
				<link rel="stylesheet" href="/lib/2.0/fa/css/all.css"/>
				<link rel="stylesheet" type="text/css" href="{concat($gamsdev,'/css/datatable.css')}"/>
				<!-- TODO: source code highlighter -->
				<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.13.1/styles/default.min.css"/>
					
				<!--<link href="{concat($gamsdev,'/react-d3-dashboard/css/2.ea9b1cc9.chunk.css')}" rel="stylesheet"/>
				<link href="{concat($gamsdev,'/react-d3-dashboard/css/main.450bfb41.chunk.css')}" rel="stylesheet"/>-->
				
				<!-- jQuery core JavaScript ================================================== -->
				<script src="/lib/2.0/jquery-3.5.1.min.js"><xsl:text> </xsl:text></script>
				<!-- Bootstrap core JavaScript ================================================== -->
				<script src="/lib/2.0/bootstrap-4.5.0-dist/js/bootstrap.bundle.js"><xsl:text> </xsl:text></script>
				<!-- GAMS JS ================================================== -->
				<script src="/lib/3.0/gamsJS/1.x/gams.js"><xsl:text> </xsl:text></script>
				<!-- Projectspecific JavaScript ================================================== -->
				<script src="{concat($gamsdev,'/js/depcha.js')}"><xsl:text> </xsl:text></script>
				
				
				
				
				<!--<script src="{concat($gamsdev,'/js/scrolldown.js')}"><xsl:text> </xsl:text></script>-->
				<!--<script src="/backbone/js/buildquery.js"><xsl:text> </xsl:text></script>-->
				<!-- https://d3js.org/ -->
				<!--<script src="{concat($gamsdev,'/js/d3.v6.js')}"><xsl:text> </xsl:text></script>-->
				<!-- TODO source code highlighter -->
				<!--<script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.13.1/highlight.min.js"><xsl:text> </xsl:text></script>-->
				
			
				
				<!-- GAMS JS -->
				<!-- https://zimlab.uni-graz.at/gams/frontend/gamsjs -->
				
				
				
				<!--<script>
					gamsJs.build("https://gams.uni-graz.at",{"$1":"home", "$2":"something else"})
				</script>
				-->
			
				
			</head>

			<!-- datatables.js -->
			<script src="/lib/2.0/plugins/bootstrap-datatable/jquery.dataTables.min.js"><xsl:text> </xsl:text></script>
			<!-- databasket -->
			<!--<script  src="{concat($gamsdev,'/js/databasket.js')}"><xsl:text> </xsl:text></script>-->
			<!-- dataview -->
			<!--<script src="{concat($gamsdev,'/js/dataView.js')}"><xsl:text> </xsl:text></script>-->
			<!--  -->
			<script src="{concat($gamsdev,'/js/depcha-InfoVis-Library.js')}"><xsl:text> </xsl:text></script>
			<!--  -->
			<script src="{concat($gamsdev,'/js/d3.v6.min.js')}"><xsl:text> </xsl:text></script>
			
			<!-- fancybox -->
			<!--<script  src="/lib/1.0/plugins/fancybox_v2.1.5/source/jquery.fancybox.js?v=2.1.5"><xsl:text> </xsl:text></script>-->
		

			<body>
				<header>
					<div class="container">
						<h1>
							<xsl:value-of select="$projectTitle"/>
						</h1>
						<h2 class="d-none d-sm-block">
							<xsl:value-of select="$subTitle"/>
						</h2>						
					</div>
				</header>
				
				<nav class="navbar navbar-expand-md navbar-light sticky-top">
					<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#nav" aria-controls="nav" aria-expanded="false" aria-label="Toggle navigation">
						<span class="navbar-toggler-icon"><xsl:text> </xsl:text></span>
					</button>
					<div class="container">
						<div class="collapse navbar-collapse" id="nav">
							<ul class="navbar-nav mr-auto">
								<li class="nav-item">
									<a class="nav-link" href="/context:depcha"><xsl:text>Home</xsl:text></a>
								</li>
								<li  class="nav-item">
									<a class="nav-link" href="/archive/objects/context:depcha/methods/sdef:Context/get?mode=datasets"><xsl:text>Datasets</xsl:text></a>
								</li>
								<li class="nav-item dropdown">
									<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
										<xsl:text>Indicies</xsl:text>
									</a>
									<div class="dropdown-menu" aria-labelledby="navbarDropdown">
										<a class="dropdown-item" href="/query:depcha.commodity"><xsl:text>Commodities</xsl:text></a>
										<a class="dropdown-item" href="/query:depcha.accounts"><xsl:text>Accounts</xsl:text></a>
									</div>
								</li>
								<li class="nav-item">
									<a class="nav-link" href="/o:depcha.bookkeeping">Ontology</a>
								</li>
								<li class="nav-item">
									<a class="nav-link" href="/archive/objects/context:depcha/methods/sdef:Context/get?mode=databasket" >
										<xsl:text>Databasket</xsl:text>
										<span id="databasket_static">
											<xsl:text> </xsl:text>
										</span>
									</a>
								</li>
								<li class="nav-item dropdown">
									<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
										<xsl:text>Project</xsl:text>
									</a>
									<div class="dropdown-menu" aria-labelledby="navbarDropdown">
										<a class="dropdown-item" href="/archive/objects/context:depcha/methods/sdef:Context/get?mode=about"><xsl:text>About</xsl:text></a>
										<a class="dropdown-item" href="/archive/objects/context:depcha/methods/sdef:Context/get?mode=howto"><xsl:text>How To Semantic Bookkeep</xsl:text></a>
									</div>
								</li>	
							</ul>
							<!--<form class="form-inline ml-auto" action="/archive/objects/query:depcha.fulltext/methods/sdef:Query/get" id="suche" method="get">
								<div class="form-row">
									<div class="input-group">
										<input class="form-control border" id="n$1" name="$1" type="text"  placeholder="Fulltext-Search" />
										<!-\-<input type="text" class="form-control" id="validationDefaultUsername" placeholder="Username" aria-describedby="inputGroupPrepend2"/>-\->
										<div class="input-group-prepend">
											<button class="btn border-left-0 border" type="button">
												<i class="fas fa-search"><xsl:text> </xsl:text></i>
											</button>
											<!-\-<span class="input-group-text" id="inputGroupPrepend2">@</span>-\->
										</div>
									</div>
								</div>
							</form>-->
							<!--<form action="" id="suche" method="get"><p><label for="n$1">$1</label>: <input id="n$1" name="$1" type="text" /></p><p><input type="submit" /></p></form>-->
							
					</div>
				</div>
			</nav>
				<!-- /////////////////////////////////// -->
				<main role="main">
					<div class="container card">
							<xsl:call-template name="content"/>
					</div>
				</main>

				<footer class="footer">
					<div class="container">
						<div class="row">
							<div class="col-md-6">
								<h6>Further Information</h6>
								<p>
									<a href="/archive/objects/context:depcha/methods/sdef:Context/get?mode=imprint"
										>Impressum</a><br/>
									<a href="/archive/objects/context:gams/methods/sdef:Context/get?mode=dataprotection&amp;locale=en" target="_blank"
										>Data protection declaration</a>
								</p>
								<div class="icons">
									<a href="/" target="_blank">
										<img class="footer_icons"
											src="/templates/img/gamslogo_weiss.gif"
											height="48" title="{$gams}" alt="{$gams}"/>
									</a>
									<a href="//informationsmodellierung.uni-graz.at/"
										target="_blank">
										<img class="footer_icons"
										    src="/templates/img/ZIM_weiss.png"
											height="48" title="{$zim-acdh}" alt="{$zim-acdh}"/>
									</a>
									<a href="//creativecommons.org/licenses/by/4.0/"
										target="_blank">
										<img class="footer_icons"
										    src="/templates/img/by.png"
											height="45" title="Lizenz" alt="Lizenz"/>
									</a>
								</div>
							</div>

							<div class="col-md-6">
								<h6>Contact</h6>
								<p><xsl:text>Prof. Dr. Georg Vogeler</xsl:text><br/>
									<xsl:text>University of Graz</xsl:text>
									<br/></p>
								<p>
									<a href="mailto:christopher.pollin@uni-graz.at">christopher.pollin@uni-graz.at</a>
								</p>
							</div>
						</div>
					</div>
					
				
					
				</footer>
			</body>
			<!-- //////////////////////////////////////////////////////////// -->
			<!-- //////////////////////////////////////////////////////////// -->
			<!-- SCRIPTS at the end -->
			<script>
				$(function () {
				$('[data-toggle="tooltip"]').tooltip()
				})
			</script>
			
			<!-- needed for datatable excel export -->
			
			
			<script src="{concat($gamsdev, '/js/dataTables.buttons.min.js')}"><xsl:text> </xsl:text></script>
			<script src="{concat($gamsdev, '/js/buttons.html5.min.js')}"><xsl:text> </xsl:text></script>
			<script src="{concat($gamsdev, '/js/jszip.js')}"><xsl:text> </xsl:text></script>
			
		</html>
	</xsl:template>
	
	
	 <xsl:template name="info_box_tei">
        <div id="info_box_tei">
	        <ul class="list-group">
	       		<li class="list-group-item"><xsl:text>Title: </xsl:text>
	       			<xsl:value-of select="//t:fileDesc/t:titleStmt/t:title"/>
	       		</li>
	        	<xsl:if test="//t:fileDesc/t:titleStmt/t:author">
				  <li class="list-group-item"><xsl:text>Author: </xsl:text>
				  	<xsl:for-each select="//t:fileDesc/t:titleStmt/t:author">
	        			<xsl:value-of select="."/>
	        			<xsl:if test="not(position()=last())">
	        				<xsl:text>,</xsl:text>
	        			</xsl:if>
	        		</xsl:for-each>
				  </li>
	        	</xsl:if>
	        	<xsl:if test="//t:fileDesc/t:titleStmt/t:editor">
	        	<li class="list-group-item"><xsl:text>Editor: </xsl:text>
				  	<xsl:for-each select="//t:fileDesc/t:titleStmt/t:editor">
	        			<xsl:value-of select="."/>
	        			<xsl:if test="not(position()=last())">
	        				<xsl:text>,</xsl:text>
	        			</xsl:if>
	        		</xsl:for-each>
				  </li>
	        	</xsl:if>
	        	<li class="list-group-item">
	        		<xsl:text>Permalink: </xsl:text><xsl:text>https://gams.uni-graz.at/</xsl:text><xsl:value-of select="//t:publicationStmt/t:idno[@type='PID']"/>
	        	</li>
			</ul>
        </div>
    </xsl:template>
	
	
	<xsl:template match="t:figure[@type='web']">
		<!-- <a class="fancybox" data-fancybox-group="group" href="{@source}" title="{@ana}">-->
		<img src="{@source}" class="rounded" alt="GAMS Workflow" style="display:block;margin-left:auto;margin-right:auto;margin-bottom:10px;margin-top:10px;max-width:50%"/>
		<!--</a>-->
	</xsl:template>
	
	<xsl:template match="t:div/t:head">
		<xsl:choose>
			<xsl:when test="parent::t:div[@type='main']">
				<div class="col main pt-3 mt-2">
					<h1 class="d-none d-sm-block font-weight-bold">
						<xsl:apply-templates/>
					</h1>
					<p class="d-none d-sm-block">
						<small class="font-weight-light">
							<xsl:text> </xsl:text>
							<xsl:for-each select="//t:teiHeader/t:fileDesc/t:titleStmt/t:author">
								<xsl:value-of select="."/><xsl:value-of select="if(not(position()=last())) then ', ' else ()"/>
							</xsl:for-each>
							<xsl:text>: </xsl:text>
							<xsl:value-of select="//t:teiHeader/t:fileDesc/t:titleStmt/t:title"/>
							<xsl:text>. In: DEPCHA. </xsl:text>
							<xsl:value-of select="//t:teiHeader/t:fileDesc/t:publicationStmt/t:date[1]"/>
							<xsl:text>. </xsl:text>
							<i class="fas fa-quote-right"><xsl:text> </xsl:text></i>
						</small>
					</p>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<h3 class="pt-3">
					<xsl:if test="@xml:id"><xsl:attribute name="xml:id" select="@xml:id"/></xsl:if>
					<xsl:apply-templates/>
				</h3>
			</xsl:otherwise>
			
			
				
		</xsl:choose>
	</xsl:template>
	
	
	<!-- //////////////////////////////////////////////////////////// -->
	<!-- hi --> 
	<!-- //////////////////////////////////////////////////////////// -->
	<!-- //////////////////////////////////////////////////////////// -->
	<!--<xsl:template match="t:hi">
		<mark title="missing styling">
			<xsl:apply-templates/>
		</mark>
	</xsl:template>-->
	
	<!-- all hi qith multiple @style and @rend -->
	<xsl:template match="*[contains(@rend,  ' ')]">
		<span>
			<xsl:attribute name="class">
				<xsl:for-each select="tokenize(@rend, ' ')">
					<xsl:choose>
						<xsl:when test=". = 'bold'">
							<xsl:text>font-weight-bold</xsl:text>
						</xsl:when>
						<xsl:when test=". = 'underline'">
							<xsl:text>underline</xsl:text>
						</xsl:when>
					</xsl:choose>
					<xsl:if test="not(position()=last())">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:attribute>
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="t:hi">
		<mark title="missing styling">
			<xsl:apply-templates/>
		</mark>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="t:hi[@style|@rend='code']">
		<code>
			<xsl:apply-templates/>
		</code>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="*[@style|@rend='bold']">
		<strong>
			<xsl:apply-templates></xsl:apply-templates>
		</strong>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="*[@style|@rend='italic']">
		<em>
			<xsl:apply-templates/>
		</em>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="*[@style|@rend='underline']">
		<u>
			<xsl:apply-templates/>
		</u>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="t:hi[@style|@rend='element']">
		<span class="text-info">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="t:hi[@style='attribute']">
		<span class="text-warning">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<!-- creates example table in "how to bookkeep" -->
	<xsl:template match="t:table[@type='example']">
		<table class="table font-italic">
			<thead>
				<tr>
					<th>
						<xsl:apply-templates select="t:head"/>
					</th>
				</tr>
			</thead>
			<tbody>
				<xsl:for-each select="t:row">
					<tr>
						<xsl:for-each select="t:cell">
							<td>
								<xsl:value-of select="."/>
							</td>
						</xsl:for-each>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="t:p[@style='XML']">
		<code class="XML">
			<pre>
				<xsl:value-of select="."/>
			</pre>
		</code>
	</xsl:template>
	
	<xsl:template match="t:list">
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>
	

	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="t:item">
		<li>
			<xsl:if test="@xml:id">
				<xsl:attribute name="id" select="@xml:id"/>
			</xsl:if>
			<xsl:apply-templates/>
		</li>
	</xsl:template>

	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="t:div[@type='body']">
		<div class="card-body">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="t:p">
		<p><xsl:apply-templates/></p>
	</xsl:template>
	
	<!-- //////////////////////////////////////////////////////////// -->
	<xsl:template match="t:lb">
		<br/>
	</xsl:template>
	
	<xsl:template match="t:ref">
		<a target="_blank">
			<xsl:attribute name="href">
				<xsl:value-of select="./@target"/>
			</xsl:attribute>
			<xsl:value-of select="."/>
		</a>
	</xsl:template>
	
	<!-- /////////////////////////////////////// -->
	<!-- /////////////////////////////////////// -->
	<!-- CALLED TEMPLATES - HELPERS -->
	
	<xsl:template name="capitalizeFirstCharacter">
		<xsl:param name="String"/>
		<xsl:value-of select="concat(translate(substring($String,1,1), $vLower, $vUpper),substring($String, 2))"/>
	</xsl:template>
	
</xsl:stylesheet>
