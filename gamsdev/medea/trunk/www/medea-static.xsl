<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    Project: GAMS Projekttemplate
    Company: ZIM-ACDH (Zentrum für Informationsmodellierung - Austrian Centre for Digital Humanities)
    Author: Hans Clausen, Maximilian Müller, Gerlinde Schneider, Martina Scholger, Christian Steiner, Elisabeth Steiner
    Last update: 2015
 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:s="http://www.w3.org/2001/sw/DataAccess/rf1/result" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:lido="http://www.lido-schema.org" xmlns:bibtex="http://bibtexml.sf.net/" exclude-result-prefixes="#all">

	<xsl:output method="xml" doctype-system="about:legacy-compat" encoding="UTF-8" indent="no"/>

	<!-- häufig verwendete variablen... -->

	<xsl:param name="mode"/>
	<xsl:param name="search"/>

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
	<xsl:variable name="server">https://glossa.uni-graz.at</xsl:variable>
	<xsl:variable name="gamsdev">/gamsdev/pollin</xsl:variable>

	<xsl:variable name="projectTitle">
		<xsl:text>DEPCHA - Digital Edition Publishing Cooperative for Historical Accounts</xsl:text>
	</xsl:variable>
	<xsl:variable name="subTitle">
		<xsl:text>Alpha-Version</xsl:text> 
	</xsl:variable>

	<!-- gesamtes css ist in dieser Datei zusammengefasst mit Ausnahme der Navigation -->
	<xsl:variable name="projectCss">
		<xsl:value-of select="concat($gamsdev, '/medea/trunk/www/css/medea.css')"/>
	</xsl:variable>
	<!--css für die navigation-->
	<xsl:variable name="projectNav">
		<xsl:value-of select="concat($gamsdev, '/medea/trunk/www/css/navbar.css')"/>
	</xsl:variable>


	<xsl:template match="/">

		<html lang="de">
			<head>
				<meta charset="utf-8"/>
				<meta  content="IE=edge"/>
				<meta name="viewport" content="width=device-width, initial-scale=1"/>
				<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->

				<meta name="keywords"
					content="template, GAMS, repository, digital, archive, edition"/>
				<meta name="description"
					content="Template for projects in GAMS - Geisteswissenschaftliches Asset Management System"/>

				<meta name="publisher"
					content="Zentrum für Informationsmodellierung - Austrian Centre for Digital Humanities"/>
				<meta name="content-language" content="de"/>

				<!--Projekttitel-->
				<title>
					<xsl:value-of select="$projectTitle"/>
				</title>

				<!-- Bootstrap 4 core CSS -->
				<link href="/lib/2.0/bootstrap-4.1.0-dist/css/bootstrap.min.css" rel="stylesheet"/>
				
				<!-- Custom styles for this template -->
				<link href="/gamsdev/pollin/medea/trunk/www/css/medea.css" rel="stylesheet" type="text/css"/>
				<link href="/gamsdev/pollin/medea/trunk/www/css/navbar.css" rel="stylesheet" type="text/css"/>
				<!-- sidebar -->
				<link href="/gamsdev/pollin/medea/trunk/www/css/sidebar.css" rel="stylesheet" type="text/css" />
				<!-- icons -->
				<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css"/>
				<link rel="stylesheet" type="text/css" href="/gamsdev/pollin/medea/trunk/www/css/datatable.css"/>
				
				

				<!-- jQuery core JavaScript ================================================== -->
				<script type="text/javascript" src="/lib/1.0/jquery-1.11.3.min.js"><xsl:text> </xsl:text></script>
			
				<!-- Bootstrap core JavaScript ================================================== -->
				<script type="text/javascript" src="/lib/2.0/bootstrap-4.1.0-dist/js/bootstrap.min.js"><xsl:text> </xsl:text></script>
				<!-- jQuery Plugin für Responsive Equal Height bei Columns: https://github.com/liabru/jquery-match-height -->
				<script type="text/javascript" src="/lib/1.0/plugins/matchHeight/jquery.matchHeight.js"><xsl:text> </xsl:text></script>
				<script type="text/javascript" src="/lib/1.0/plugins/matchHeight/matchHeight.js"><xsl:text> </xsl:text></script>
			    
				<!-- Projectspecific JavaScript ================================================== -->
			    <script type="text/javascript" src="/gamsdev/pollin/medea/trunk/www/js/scrolldown.js"><xsl:text> </xsl:text></script>
				<script src="/backbone/js/buildquery.js" type="application/javascript"><xsl:text> </xsl:text></script>
				<!-- ToDo lokal speichern -->
				<script type="text/javascript" src="/gamsdev/pollin/medea/trunk/www/js/d3.v4.min.js"><xsl:text> </xsl:text></script>
				<!-- d3.tip.v0.6.3.js must be after d3.v4.min.js as it uses functions there -->
				<script type="text/javascript" src="/gamsdev/pollin/medea/trunk/www/js/d3.tip.v0.6.3.js"><xsl:text> </xsl:text></script>
			</head>
			
			<!-- jQuery -->
			<script type="text/javascript" src="/lib/2.0/jquery-3.3.1.min.js"><xsl:text> </xsl:text></script>
			<!-- bootstrap 4 -->
			<script type="text/javascript" src="/lib/2.0/bootstrap-4.1.0-dist/js/bootstrap.min.js"><xsl:text> </xsl:text></script>
			<!-- matchHeight -->
			<script type="text/javascript" src="/lib/1.0/plugins/matchHeight/jquery.matchHeight.js"><xsl:text> </xsl:text></script>
			<script type="text/javascript" src="/lib/1.0/plugins/matchHeight/matchHeight.js"><xsl:text> </xsl:text></script>
			<!-- datatables.js -->
			<script type="text/javascript" charset="utf8" src="/gamsdev/pollin/medea/trunk/www/js/datatable.js"><xsl:text> </xsl:text></script>

			<body>
				<header>
					<div class="container">
						<div class="row flex">
							<div class="col-md-12">
								<h1>
									<xsl:value-of select="$projectTitle"/>
								</h1>
								<h2>
									<xsl:value-of select="$subTitle"/>
								</h2>
							</div>
							
						</div>
					</div>
				</header>
				
				<nav class="navbar navbar-expand-lg navbar-light sticky-top"><!-- fixed/sticky nav benötigt; muss noch nach rechts angepasst werden (margin) -->
					<!--<a class="navbar-brand" href="#">Navbar</a>
					<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
						<span class="navbar-toggler-icon"></span>
					</button>-->
					<div class="container">
						<div class="collapse navbar-collapse" id="nav">
							<ul class="navbar-nav mr-auto">
								<li class="nav-item">
									<a class="nav-link" href="/context:medea">Home</a>
								</li>
								<li  class="nav-item">
									<a class="nav-link" href="/archive/objects/context:medea/methods/sdef:Context/get?mode=collection">Collection</a>
								</li>
								<!--<li>
									<xsl:if test="$cid = 'context:medea'">
										<xsl:attribute name="class">active</xsl:attribute>
									</xsl:if>
									<a href="/archive/objects/query:medea-visualization/methods/sdef:Query/get">Visualization</a>
								</li>-->
								<li class="nav-item dropdown">
									<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
										Indices
									</a>
									<div class="dropdown-menu" aria-labelledby="navbarDropdown">
										<a class="dropdown-item" href="/query:medea.commodity">Commodity</a>
									</div>
								</li>
								<li class="nav-item">
									<a class="nav-link" href="/o:medea.bookkeeping">Ontology</a>
								</li>
								<li class="nav-item dropdown">
									<a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
										Project
									</a>
									<div class="dropdown-menu" aria-labelledby="navbarDropdown">
										<a class="dropdown-item" href="https://medea.hypotheses.org">About MEDEA</a>
										<a class="dropdown-item" href="#">Description</a>
									</div>
								</li>
							</ul>
							<!--<form action="" id="suche" method="get"><p><label for="n$1">$1</label>: <input id="n$1" name="$1" type="text" /></p><p><input type="submit" /></p></form>-->
							<form action="/archive/objects/query:medea.fulltext/methods/sdef:Query/get" id="suche" method="get">
								<div class="form-row">
									<div class="input-group">
										<input class="form-control border" id="n$1" name="$1" type="text"  placeholder="Fulltextsearch" />
										<!--<input type="text" class="form-control" id="validationDefaultUsername" placeholder="Username" aria-describedby="inputGroupPrepend2"/>-->
										<div class="input-group-prepend">
											<button class="btn border-left-0 border" type="button">
												<i class="fa fa-search"><xsl:text> </xsl:text></i>
											</button>
											<!--<span class="input-group-text" id="inputGroupPrepend2">@</span>-->
										</div>
									</div>
								</div>
								</form>
					</div>
				</div>
			</nav>
				<main class="container">
					<xsl:choose>
						<!-- HOME -->
						<xsl:when test="$mode = '' and $cid = 'context:medea'">
							<!-- einstiegsseite für projektkontext -->
							<section class="row">
								<article class="col-md-12">
									<div class="card" data-mh="group1">
										<h3>Lorem Ipsum</h3>
									    <p>
									        medea-static.xsl
									    </p>
									</div>
								</article>
							</section>

							<section class="row">
								<article class="col-md-10">
									<div class="card" data-mh="group2">
										<h3>Lorem Ipsum</h3>
										<p>Testi</p>
									</div>
								</article>
								<article class="col-md-2">
									<div class="card" data-mh="group2">
										<h3>Lorem Ipsum</h3>
										<p>dolores et ea rebum. Stet clita kasd gubergren, no sea
										</p>
									</div>
								</article>
							</section>
						</xsl:when>
					    
					    <!-- IMPRINT -->
						<xsl:when test="$mode = 'imprint'">
							<section class="row">
								<article class="col-md-12">
									<div class="card">
									    <xsl:apply-templates select="document(concat('/context:medea/', 'IMPRINT'))/t:TEI/t:text/t:body/t:div"/>
									</div>
								</article>
							</section>
						</xsl:when>
					    
					    <!-- ABOUT -->
					    <xsl:when test="$mode = 'about'">
					        <section class="row">
					            <article class="col-md-12">
					                <div class="card">
					                    <xsl:apply-templates select="document(concat('/context:medea/', 'ABOUT'))/t:TEI/t:text/t:body/t:div"/>
					                </div>
					            </article>
					        </section>
					    </xsl:when>


						<xsl:otherwise>
							<xsl:call-template name="content"/>
						</xsl:otherwise>
					</xsl:choose>


				</main>

				<footer class="footer">
					<div class="container">
						<div class="row">
							<div class="col-md-6">
								<h6>Further Information</h6>
								<p>
									<a href="/archive/objects/context:medea/methods/sdef:Context/get?mode=imprint"
										>Impressum</a><br/>
									<a href="/archive/objects/context:gams/methods/sdef:Context/get?mode=dataprotection&amp;locale=en" target="_blank"
										>Data protection declaration</a>
								</p>

								<div class="icons">
									<a href="" target="_blank">
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


									<a href="//creativecommons.org/licenses/by-nc/4.0/"
										target="_blank">
										<img class="footer_icons"
										    src="/templates/img/by-nc.png"
											height="45" title="Lizenz" alt="Lizenz"/>
									</a>
								</div>
							</div>

							<div class="col-md-6">
								<h6>Contact</h6>
								<p>
									Prof. Dr. Georg Vogeler <br/>Karl-Franzens-Universität
									Graz <br/></p>
								<p>
									<a href="mailto:christopher.pollin@uni-graz.at"
									    >christopher.pollin@uni-graz.at</a>
								</p>
							</div>
						</div>
					</div>
				</footer>
			</body>
			<!--<script>
				// This file is required by the index.html file and will
				// be executed in the renderer process for that window.
				// All of the Node.js APIs are available in this process.
				window.$ = window.jquery = require('./node_modules/jquery');
				window.dt = require('./node_modules/datatables.net')();
				window.$('#table_id').DataTable();
			</script>-->
		</html>
	</xsl:template>

<!--Ab hier je nach Bedarf ändern-->
	<!--<xsl:template match="t:head">
		<xsl:choose>
			<xsl:when test="following-sibling::t:p">
				<h4>
					<xsl:value-of select="."/>
				</h4>
			</xsl:when>
			<xsl:otherwise>
				<h3>
					<xsl:value-of select="."/>
				</h3>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="t:bibl">
		<p>
			<xsl:value-of select="./t:title"/>
		</p>
	</xsl:template>

	<xsl:template match="t:div">
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match="t:p">
		<p>
		    <xsl:apply-templates/>
		</p>
	</xsl:template>

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
	</xsl:template>-->

</xsl:stylesheet>