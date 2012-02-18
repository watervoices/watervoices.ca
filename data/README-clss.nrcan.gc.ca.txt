# Check the link to the KMZ
open http://clss.nrcan.gc.ca/googledata-donneesgoogle-eng.php

curl -O http://clss.nrcan.gc.ca/data-donnees/kml/Canada%20Lands.kmz
unzip "Canada Lands.kmz"

# "Canada Lands.kml" links to "Link_E_All.kml"
curl -O http://clss-satc.nrcan-rncan.gc.ca/data-donnees/kml/Link_E_All.kml

# "Link_E_All.kml" links to provincial KMZ files and "placemarks-eng.kmz"
curl -O http://clss-satc.nrcan-rncan.gc.ca/data-donnees/kml/placemarks-eng.kmz
unzip placemarks-eng.kmz

# "Link_E_ON.kml" links to reserve KMZ files
curl -O http://clss-satc.nrcan-rncan.gc.ca/data-donnees/kml/Link_E_ON.kmz
unzip Link_E_ON.kmz
