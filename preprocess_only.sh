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

##
# Preprocess DEM data
##
echo -e "\n\nPreprocessing raster data..."

# Change DEM projection to Spherical Mercator
echo -e "\nReproject DEM to EPSG:3857  --->"
gdalwarp -s_srs "EPSG:4326" -t_srs "EPSG:3857" -co COMPRESS=DEFLATE -of GTiff -srcnodata "-32768" -multi -dstnodata "-32768" -te -9314704.367077 4375283.464516 -8225840.114969 5201489.272209 -r bilinear -cutline ~/server/raw/sa_3857.shp ~/server/raw/merged_dem.tif ~/server/intermediate/rpf_dem.tif
# Generate color relief map
write_ramp > ~/server/raw/ramp.txt
echo -e "\n\nGenerating color relief  --->"
gdaldem color-relief ~/server/intermediate/rpf_dem.tif ~/server/raw/ramp.txt ~/server/intermediate/rpf_color_relief.tif 
# Set nodata values for color relief
echo -e "\nSet nodata values for color relief  --->"
gdalwarp -co COMPRESS=DEFLATE -of GTiff -srcnodata "255 255 255" -multi -dstnodata "255 255 255" -te -9314704.367077 4375283.464516 -8225840.114969 5201489.272209 -r bilinear -cutline ~/server/raw/sa_3857.shp ~/server/intermediate/rpf_color_relief.tif ~/server/src/color_dem.tif
# Generate slope overlay
echo -e "\nGenerating slope overlay  --->"
gdaldem slope ~/server/intermediate/rpf_dem.tif ~/server/src/slope.tif -of GTiff
# Generate hillshade
echo -e "\nGenerating hillshade  --->"
gdaldem hillshade ~/server/intermediate/rpf_dem.tif ~/server/src/shade.tif -of GTiff -z 2

echo -e "\n\nDONE"

