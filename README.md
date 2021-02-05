# gtfs-as-gis
Creating spatial files using GTFS data in R

This R project contains scripts which take Connect Transit GTFS files and produce GIS data from them.
These scripts *may* have been superseded by the `process_transit_gtfs.R` script in the `housing-location-tool` repository. I never got around to officially doing that and the `stop_frequency.R` script contains some analysis code that may be useful in another project. At any rate, you *should* be able to plug in an updated Connect Transit GTFS, run these two scripts, and get GIS data out of them.

HOWEVER, be aware that the adage of "garbage in, garbage out," very much applies here. Connect Transit's GTFS files frequently contain errors and these scripts cannot possibly anticipate all of them. Inspect any outputs thoroughly and be prepared to make tweaks to these scripts or manually edit the output files in ArcGIS. Some common errors I have noticed include: Missing or redundant routes and stops, inaccurate stop coordinates, empty routes, placeholder stops, and much much more. Despite all this, processing their GTFS through this script is still less painful than trying to ask them for GIS data. Trust me.