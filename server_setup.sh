#!/usr/bin/env bash

##
# Functions
##

function write_ramp 
{
	cat <<- _EOF_
1738 215 48 39
1000 252 141 89
688 254 224 144
430 224 243 248
172 145 191 219
-86 69 117 180
-32768 255 255 255
_EOF_
}

function write_server 
{
	cat <<- _EOF_
var tilestrata = require('tilestrata');
var disk = require('tilestrata-disk');
var mapnik = require('tilestrata-mapnik');
var strata = tilestrata.createServer();

// define layers
strata.layer('hillshade')
    .route('shade.png')
        .use(disk.cache({dir: './tiles/hillshade/'}))
        .use(mapnik({
            xml: './styles/hillshade.xml',
            tileSize: 256,
            scale: 1
        }));
strata.layer('dem')
    .route('dem.png')
        .use(disk.cache({dir: './tiles/dem/'}))
        .use(mapnik({
            xml: './styles/dem.xml',
            tileSize: 256,
            scale: 1
        }));
strata.layer('slope')
    .route('slope.png')
        .use(disk.cache({dir: './tiles/slope/'}))
        .use(mapnik({
            xml: './styles/slope.xml',
            tileSize: 256,
            scale: 1
        }));
strata.listen(8080);
_EOF_
}

function write_dem_style 
{
	cat <<- _EOF_
<Map srs="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null">
    <Style name="overlay-dem">    
        <Rule>
            <RasterSymbolizer opacity="0.6" scaling="bilinear" mode="normal"/>
        </Rule>
    </Style>
    <Layer name="dem" srs="+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null">
        <StyleName>overlay-dem</StyleName>
        <Datasource>
            <Parameter name="file">../src/color_dem.tif</Parameter>
            <Parameter name="type">gdal</Parameter>
            <Parameter name="band">-1</Parameter>
        </Datasource>
    </Layer>
</Map>
_EOF_
}

function write_slope_style 
{
	cat <<- _EOF_
<Map srs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs">
    <Style name="overlay-slope">    
        <Rule>
            <RasterSymbolizer opacity=".25" scaling="bilinear" mode="normal">
                <RasterColorizer default-mode="linear">
                    <stop color="transparent" value="0"/>
                    <stop color="black" value="42"/>
                </RasterColorizer>
            </RasterSymbolizer>
        </Rule>
    </Style>
     <Layer name="hillshade" srs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs">
        <StyleName>overlay-slope</StyleName>
        <Datasource>
            <Parameter name="file">../src/slope.tif</Parameter>
            <Parameter name="type">gdal</Parameter>
            <Parameter name="band">1</Parameter>
        </Datasource>
    </Layer>
</Map>
_EOF_
}

function write_shade_style 
{
	cat <<- _EOF_
<Map srs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs">
    <Style name="base-shade">    
        <Rule>
            <RasterSymbolizer opacity="1" scaling="bilinear" mode="normal"/>
        </Rule>
    </Style>
     <Layer name="hillshade" srs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +a=6378137 +b=6378137 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs">
        <StyleName>base-shade</StyleName>
        <Datasource>
            <Parameter name="file">../src/shade.tif</Parameter>
            <Parameter name="type">gdal</Parameter>
            <Parameter name="band">-1</Parameter>
        </Datasource>
    </Layer>
</Map>
_EOF_
}

##
# Set up filesystem structure 
##
echo -e "\n\nCreating directories for server setup..."

mkdir ~/server/
# Directories for handling data and preprocessing
mkdir ~/server/raw
mkdir ~/server/raw/zips
mkdir ~/server/intermediate
# Directories for the server
mkdir ~/server/node_modules
mkdir ~/server/src
mkdir ~/server/styles
mkdir ~/server/tiles
mkdir ~/server/tiles/dem
mkdir ~/server/tiles/hillshade
mkdir ~/server/tiles/slope

echo -e "\n\nDONE"

##
# Download data
##
echo -e "\n\nDownloading data..."

sudo wget -A 'zip' -P ~/server/raw/zips http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_20_04.zip
echo -e "\n1 of 7 complete...\n"
sudo wget -A 'zip' -P ~/server/raw/zips http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_21_04.zip
echo -e "\n2 of 7 complete...\n"
sudo wget -A 'zip' -P ~/server/raw/zips http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_22_04.zip
echo -e "\n3 of 7 complete...\n"
sudo wget -A 'zip' -P ~/server/raw/zips http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_20_05.zip
echo -e "\n4 of 7 complete...\n"
sudo wget -A 'zip' -P ~/server/raw/zips http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_21_05.zip
echo -e "\n5 of 7 complete...\n"
sudo wget -A 'zip' -P ~/server/raw/zips http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_22_05.zip
echo -e "\n6 of 7 complete..."
sudo wget -A 'zip' -P ~/server/raw/zips --output-document=sa.zip https://github.com/ronn4031/data/blob/master/sa.zip?raw=true
echo -e "\n7 of 7 complete..."


echo -e "\n\nDONE"

##
# Extract and merge data
##
echo -e "\n\Extracting and merging data..."

sudo unzip '~/server/raw/zips/*.zip'
sudo mv ~/server/raw/zips/*.tif ~/server/raw/*.tif
# Merge rasters with gdal_merge.py
gdal_merge.py -o ~/server/raw/merged_dem.tif -of GTiff ~/server/raw/srtm_*.tif

echo -e "\n\nDONE"

##
# Preprocess DEM data
##
echo -e "\n\nPreprocessing raster data..."

# Change DEM projection to Spherical Mercator
echo -e "\nReproject DEM to EPSG:3857  --->"
gdalwarp -s_srs "EPSG:4326" -t_srs "EPSG:3857" -co COMPRESS=DEFLATE -of GTiff -srcnodata "-32768" -multi -dstnodata "-32768" -te -9314704.367077 4375283.464516 -8225840.114969 5201489.272209 -r bilinear -cutline ~/server/raw/sa_3857.shp ~server/raw/merged_dem.tif ~/server/intermediate/rpf_dem.tif
# Generate color relief map
write_ramp > ~/server/raw/ramp.txt
echo -e "\n\nGenerating color relief  --->"
gdaldem color-relief ~/server/intermediate/rpf_dem.tif ~/server/raw/ramp.txt ~/server/intermediate/rpf_color_relief.tif 
# Set nodata values for color relief
echo -e "\nSet nodata values for color relief  --->"
gdalwarp -co COMPRESS=DEFLATE -of GTiff -srcnodata "255 255 255" -multi -dstnodata "255 255 255" -te -9314704.367077 4375283.464516 -8225840.114969 5201489.272209 -r bilinear -cutline ~/server/raw/sa_3857.shp ~/server/intermediate/rpf_color_relief.tif ~/server/src/color_dem.tif
# Generate slope overlay
echo -e "\nGenerating slope overlay  --->"
gdaldem slope ~/server/intermediate/rpf_dem.tif ~/server/final/slope.tif -of GTiff
# Generate hillshade
echo -e "\nGenerating hillshade  --->"
gdaldem hillshade ~/server/intermediate/rpf_dem.tif ~/server/final/shade.tif -of GTiff -z 2

echo -e "\n\nDONE"

##
# Write server and style files, install node dependencies, clean up.
##
echo -e "\n\nAlmost there! Completing a few last things..."

echo -e "\nWriting the remaining server files..."
write_server > ~/server/server.js
write_dem_style > ~/server/styles/dem.xml
write_slope_style > ~/server/styles/slope.xml
write_shade_style > ~/server/styles/hillshade.xml
echo -e "\nInstall remaining dependencies..."
cd ~/server/node_modules
sudo npm install tilestrata --save
sudo npm install tilestrata-disk --save
sudo npm install tilestrata-mapnik --save
echo -e "\nCleaning up..."
cd
sudo rm -rf ~/server/intermediate
sudo rm -rf ~/server/raw

echo -e "\n\nDONE"
echo -e "\n\nAll tasks complete. Thanks for setting me up! Enjoy!"

