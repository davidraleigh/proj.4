#!/usr/bin/env bash

wget -qO- -O tmp.zip http://download.osgeo.org/proj/proj-datumgrid-1.6.zip
unzip -o tmp.zip
rm tmp.zip
wget http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx
echo $1
if [ $1 -eq 1 ]
then
    mkdir /vdatum
    cd /vdatum
    wget http://download.osgeo.org/proj/vdatum/usa_geoid2012.zip && unzip -j -u usa_geoid2012.zip -d /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/usa_geoid2009.zip && unzip -j -u usa_geoid2009.zip -d /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/usa_geoid2003.zip && unzip -j -u usa_geoid2003.zip -d /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/usa_geoid1999.zip && unzip -j -u usa_geoid1999.zip -d /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/vertcon/vertconc.gtx && mv vertconc.gtx /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/vertcon/vertcone.gtx && mv vertcone.gtx /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/vertcon/vertconw.gtx && mv vertconw.gtx /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/egm96_15/egm96_15.gtx && mv egm96_15.gtx /usr/local/share/proj
    wget http://download.osgeo.org/proj/vdatum/egm08_25/egm08_25.gtx && mv egm08_25.gtx /usr/local/share/proj
    rm -rf /vdatum
fi
