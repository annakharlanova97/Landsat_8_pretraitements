# Instalation des bibliothéques 
library(RStoolbox)
library(raster)
library(ggplot2)

#espace de travail
setwd("~/Documents/M2_Nice/Hydrographie/land")

# Lecture des images à partir des métadonnées
MD <- readMeta("LC08_L1TP_195030_20180211_20180222_01_T1/LC08_L1TP_195030_20180211_20180222_01_T1_MTL.txt")
lsat     <- stackMeta(MD) 
plotRGB(lsat, r = 5, g = 4, b = 3, stretch ='lin', axes=TRUE)
proj4string(lsat) <- CRS("+init=epsg:2154") 

#Découpage avec l'emprise du MNT
MNT <- raster("resample/Cogolin_mnt_c.tif")
proj4string(MNT) <- CRS("+init=epsg:2154") 
# Tout d'abord, on projette le SRTM au même crs que l'image landsat
MNTrp <- projectRaster(MNT, crs = crs(lsat), method='ngb')
plot(MNTrp)
#découpage en fonction de l'emprise
extent(lsat) <- MNTrp
lsat_e <- setExtent(lsat, MNTrp, keepres=FALSE)
plotRGB(lsat_e, r = 5, g = 4, b = 3, stretch ='lin', axes=TRUE)

#Pansharpering à 15m comme B8
pan <- raster("LC08_L1TP_195030_20180211_20180222_01_T1/LC08_L1TP_195030_20180211_20180222_01_T1_B8.TIF")
pan_d <- setExtent(pan, MNTrp, keepres=FALSE)
Img_pan <- panSharpen(lsat_e, pan_d, r = 4, g = 3, b = 2, method = "brovey")

#Conversion en réflectance haut de l’atmosphère avec la fonction radCor 
#(L’argument apref. a été utilisé, il correspond à la “réflectance apparente” )
lsat_refTOA <- radCor(Img_pan, metaData = MD, method = "apref")
proj4string(lsat_refTOA) <- CRS("+init=epsg:2154") 
plot(lsat_refTOA)
plot(lsat_refTOA$B1_tre)

#Resampling à 25m
# ne fonctionne pas pour l'instant à faire sur QGIS///
res<-extend(lsat_refTOA, MNTrp, method='bilinear')

#Correction des effets de topographie
lsat_C <- topCor(res, dem = MNTrp, metaData = MD, method = "C")
plotRGB(lsat_C, r = 4, g = 2, b = 1, stretch ='lin', axes=TRUE)








