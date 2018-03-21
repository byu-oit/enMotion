#!/bin/bash
echo "Content-type: text/html"
echo
TAG=`echo "$QUERY_STRING" | grep -o "id=[A-Z0-9-]*" | cut -d = -f 2`
MSG="Thank you for reporting a problem with this enMotion dispenser ($TAG). Expect a repair by start of next business day."
BLDG=`echo "$TAG" | grep -o "^[A-Z]*"`
SITE_ECI="DME49grtAihjo9aZLiXzVw"
BLDG_ECI=`curl localhost:8080/sky/cloud/$SITE_ECI/edu.byu.enMotion.site/buildingECI?bldg=$BLDG | tr -d '"'`
NPE=`curl localhost:8080/sky/event/$BLDG_ECI/none/tag/scanned?id=$TAG&tag_domain=enMotion`
ORD=`echo "$NPE" | grep -o 'ordinal":"[^"]*"' | cut -d '"' -f 3`
ORD_MSG="We are not tracking this dispenser ($TAG)."
if [ -n "$ORD" ]
then
  ORD_MSG="Yours is the $ORD report today."
fi
cat <<EOF
<!doctype html>
<html>
<head>
<link rel="shortcut icon" href="/enMotion/favicon.ico">
<link type="text/css" rel="stylesheet" href="//cloud.typography.com/75214/6517752/css/fonts.css" media="all" />
<link rel="stylesheet" href="https://cdn.byu.edu/byu-theme-components/latest/byu-theme-components.min.css" />
<script async src="https://cdn.byu.edu/byu-theme-components/latest/byu-theme-components.min.js"></script>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
html, body { height: 100%; }
.containing-element {
  display: flex;
  flex-direction: column;
  height: 100%;
}
.page-content { flex-grow: 1; }
</style>
<title>enMotion</title>
<meta charset="UTF-8">
</head>
<body>
<div class="containing-element">
<byu-header>
  <h1 slot="site-title">enMotion problem report</h1>
</byu-header>
<div class="page-content">
<p>$MSG</p>
<p>$ORD_MSG</p>
<pre>$BLDG_ECI</pre>
<pre>$NPE</pre>
</div>
<byu-footer></byu-footer>
</div>
</body>
</html>
EOF
