C:
cd C:\Program Files\FlightGear

SET FG_ROOT=C:\Program Files\FlightGear\\data
.\\bin\\win32\\fgfs --aircraft=QUADLSE --fdm=network,localhost,5501,5502,5503 --fog-fastest --disable-clouds --start-date-lat=2004:06:01:09:00:00 --disable-sound --in-air --enable-freeze --airport=LAX --runway=1 --altitude=200 --heading=0 --offset-distance=0 --offset-azimuth=0
