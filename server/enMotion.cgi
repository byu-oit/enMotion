#!/bin/bash
echo "Content-type: text/html"
echo
TAG=`echo "$QUERY_STRING" | grep -o "id=[A-Z0-9-]*" | cut -d = -f 2`
BLDG=`echo "$TAG" | grep -o "[A-Z]*"`
ECI="VcJtdJmY3nm1ZWsvKqvARP"
if [ "$BLDG" = "ELWC" ]
then
  ECI="Ff42Ae6BK9cJAq6mkMeMaP"
fi
NPE=`curl localhost:8080/sky/event/$ECI/none/tag/scanned?id=$TAG&tag_domain=enMotion`
MSG="Thank you for reporting a problem with this enMotion dispenser. Expect a repair by start of next business day."
cat <<EOF
<!doctype html>
<html>
<head>
<link rel="shortcut icon" href="/enMotion/favicon.ico">
<title>enMotion</title>
<meta charset="UTF-8">
</head>
<body>
<!-- 
<pre>$NPE</pre>
--> 
<p style="font-size:xx-large">$MSG</p>
</body>
</html>
EOF
