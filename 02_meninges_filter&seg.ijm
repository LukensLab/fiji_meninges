// Meninges analysis macro created by Katherine Bruch

//Part I Filtering 
// this macro will take a folder filled with .tif files already at max z-projection and do the following:
// a) allow the user to set the channel name, color, brightness/contrast min and max, and threshold values for up to four channels 
// b) apply these settings to all images in the chosen directory 
// c) apply median filter to sharpen images 
// d) save a merged images in a new folder of "Filtered_TIFs" 

//Part II Segmenting 
// a) apply thresholding values to each "Filtered_TIF"
// b) calculate the % area and / or cell counts in each channel
// c) create a "Results" folder with the output in a .csv file 

// Start of Settings // -------------------------------------------------------------------------------
//set the name, color, min, max and thresholds here for all the channels 
// Channel 1 
C1name = "DAPI";
C1color = "Blue";
C1min = 10;
C1max = 120;
//threshold values - commented out for DAPI since we don't need to segment and quantify this 
//c1Tmin = 0 ;
//c1Tmax = 255;
// chose the analysis you want to do for this channel  "percentArea" OR "cellCount" 
//c1Analysis = "percentArea"

// Channel 2 
C2name = "CD3";
C2color = "Magenta";
C2min = 40;
C2max = 80;
// threshold values 
c2Tmin = 55;
c2Tmax = 255;
// chose the analysis you want to do for this channel  "percentArea" OR "cellCount" 
c2Analysis = "percentArea" 
c22Analysis = "cellCount"

// Channel 3
C3name = "Lyve-1";
C3color = "Grays";
C3min = 0;
C3max = 170;
// threshold values 
c3Tmin = 60;
c3Tmax = 255;
c3Analysis = "percentArea" 

// Channel 4 
C4name = "MHC-II";
C4color = "Yellow Hot";
C4min = 90;
C4max = 255;
// threshold values 
c4Tmin = 70;
c4Tmax = 255;
c4Analysis = "percentArea" 
c44Analysis = "cellCount"

//set the pixel radius for median filter (1 is generally good for meninges at 10x)
pixelrad = "radius=1"

//Edit analyze particles parameters below 
analyzeParticleParameters = "size=80-160 circularity=0.0-1.00 show=Outlines display exclude include summarize add"
// End of Settings //	----------------------------------------------------------------------------------------				


// Bring up the directory and set up folders for filtered images and results
path = getDirectory("Choose a Directory"); 
filename = getFileList(path); 
newDir = path + "Filtered_TIFs" + File.separator; 
newDir2 = path + "Results" + File.separator; 

if (File.exists(newDir)) 
   exit("Destination directory already exists; remove it and then run this macro again"); 
File.makeDirectory(newDir); 
File.makeDirectory(newDir2); 

// Part I Filtering // ----------------------------------------------------------------------------------------
for (i=0; i<filename.length; i++) { 
        if(endsWith(filename[i], ".tif")) { 
                open(path+filename[i]); 
                run("Channels Tool...");
                Stack.setDisplayMode("color");
                run("Brightness/Contrast...");
                
                Stack.setChannel(1);
                setMinAndMax(C1min, C1max); 
                run(C1color); 
                 
                Stack.setChannel(2);
                setMinAndMax(C2min, C2max);
                run(C2color); 
                
                Stack.setChannel(3);
                setMinAndMax(C3min, C3max); 
                run(C3color); 
                
                Stack.setChannel(4);
                setMinAndMax(C4min, C4max);  
                run(C4color); 

                //Median image-sharpening filter 
                Stack.setDisplayMode("composite");
                run("Median...", pixelrad);
                rename(filename[i]);
                saveAs("tiff", newDir + getTitle);
      }    			
}
                close("*");	
                
 // Part II Segmenting // ----------------------------------------------------------------------------------------
path = getDirectory("Choose a Directory"); /// edit this to automatically get files from the "Filtered_Tif" folder 
filename = getFileList(path); 

// Function for calculating %area
function percentArea(channelID, channelName, channelMin, channelMax) { 
	for (i=0; i<filename.length; i++) { 
	        if(endsWith(filename[i], ".tif")) { 
	                open(path+filename[i]); 
	                run("Split Channels"); 
					selectWindow(channelID + "-" +filename[i]);
	                setThreshold(channelMin, channelMax);  
					setOption("BlackBackground", false);
					run("Convert to Mask");
					run("Set Measurements...", "area area_fraction limit display redirect=None decimal=3");
					run("Measure");
	        }    
		}				
		close("*");		 
		selectWindow("Results");
		saveAs("Results", newDir2 + channelName + "_area" + ".csv");
		selectWindow("Results");
		run("Close");
}

// Function for calculating cell counts
function cellCount(channelID, channelName, channelMin, channelMax) { 
	for (i=0; i<filename.length; i++) { 
	        if(endsWith(filename[i], ".tif")) { 
	                open(path+filename[i]); 
	                run("Split Channels"); 
					selectWindow(channelID + "-" +filename[i]);
	                setThreshold(channelMin, channelMax);  
					setOption("BlackBackground", false);
					run("Convert to Mask");
					run("Analyze Particles...", analyzeParticleParameters);
	        }    
		}				
		close("*");		 
		selectWindow("Summary");
		saveAs("Results", newDir2 + channelName + "_counts" + ".csv");
		selectWindow("Results");
		run("Close");
}

//if (c1Analysis == "percentArea") {
//	percentArea("C1", C1name, c1Tmin, c1Tmax) 
//} else if (c1Analysis == "cellCount") { 
//	cellCount("C1", C1name, c1Tmin, c1Tmax) 
//	}
	
if (c2Analysis == "percentArea") {
	percentArea("C2", C2name, c2Tmin, c2Tmax); 
} else if (c2Analysis == "cellCount") { 
	cellCount("C2", C2name, c2Tmin, c2Tmax); 
	}

if (c3Analysis == "percentArea") {
	percentArea("C3", C3name, c3Tmin, c3Tmax); 
} else if (c3Analysis == "cellCount") { 
	cellCount("C3", C3name, c3Tmin, c3Tmax); 
	}

if (c4Analysis == "percentArea") {
	percentArea("C4", C4name, c4Tmin, c4Tmax); 
} else if (c4Analysis == "cellCount") { 
	cellCount("C4", C4name, c4Tmin, c4Tmax); 
	}

if (c22Analysis == "percentArea") {
	percentArea("C2", C2name, c2Tmin, c2Tmax); 
} else if (c22Analysis == "cellCount") { 
	cellCount("C2", C2name, c2Tmin, c2Tmax); 
	}

if (c44Analysis == "percentArea") {
	percentArea("C4", C4name, c4Tmin, c4Tmax); 
} else if (c44Analysis == "cellCount") { 
	cellCount("C4", C4name, c4Tmin, c4Tmax); 
	}

close("*");