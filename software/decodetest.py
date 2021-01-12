#!/usr/bin/python

import sys, getopt
import pyModeS as mds

msg = sys.argv[1]

print mds.adsb.icao(msg);
print mds.adsb.callsign(msg);
print mds.crc(msg);
