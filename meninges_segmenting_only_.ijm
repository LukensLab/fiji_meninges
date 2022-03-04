// Meninges analysis macro for segmenting four channels 
// a) apply thresholding values to .tif files 
// b) option to calculate the % area and / or cell counts in each channel
// c) create a "Results" folder with the output in a .csv file 

// Helper shorthand variables for the available types of analysis.
var PercentArea = "percentArea"
var CellCount = "cellCount"

// Start of Settings // -------------------------------------------------------------------------------
//set the name, color, min, max and thresholds here for all the channels 
// Channel 1 
C1name = "DAPI";
C1color = "Blue";
// threshold values 
c1Tmin = 0 ;
c1Tmax = 255;
// Choose the analysis you want to do for this channel (PercentArea, CellCount, list both, or leave blank)
c1Analysis = newArray();

// Channel 2 
C2name = "CD3";
C2color = "Magenta";
c2Tmin = 34;
c2Tmax = 44;
c2Analysis = newArray();

// Channel 3
C3name = "Lyve-1";
C3color = "Grays";
c3Tmin = 33;
c3Tmax = 70;
c3Analysis = newArray() 

// Channel 4 
C4name = "MHC-II";
C4color = "Yellow Hot";
c4Tmin = 40;
c4Tmax = 128;
c4Analysis = newArray(CellCount)

//set the pixel radius for median filter (1 is generally good for meninges at 10x)
pixelrad = "radius=1"

//Edit analyze particles parameters below 
// Tcells
// analyzeParticleParameters = "size=80-160 circularity=0.0-1.00 show=Outlines display exclude include summarize add"
// MHCII cells 
analyzeParticleParameters = "size=200-400 circularity=0.0-1.00 show=Outlines display exclude include summarize add"

// End of Settings //	----------------------------------------------------------------------------------------				


// Bring up the directory and set up folders for filtered images and results
path = getDirectory("Choose a Directory"); 
filename = getFileList(path); 
resultsDir = path + "Results" + File.separator; 

File.makeDirectory(resultsDir); 

 // Segmenting // ----------------------------------------------------------------------------------------

// Function for calculating %area
function percentArea(channelID, channelName, channelMin, channelMax) { 
	for (i=0; i<filename.length; i++) { 
	        if(endsWith(filename[i], ".tif")) { 
	                open(path+filename[i]); 
	                roiManager("Add");
					roiManager("Select", 0);
					run("Split Channels");
					selectWindow(channelID + "-" +filename[i]);
	                setThreshold(channelMin, channelMax);  
					setOption("BlackBackground", false);
					run("Convert to Mask");
					run("Set Measurements...", "area area_fraction limit display redirect=None decimal=3");run("Set Measurements...", "area area_fraction limit display redirect=None decimal=3");
					roiManager("Select", 0);
					run("Measure");
					selectWindow("ROI Manager");
					run("Close");
	        }    
		}				
		close("*");		 
		selectWindow("Results");
		saveAs("Results", resultsDir + channelName + "_area" + ".csv");
		selectWindow("Results");
		run("Close");
}

// Function for calculating cell counts
function cellCount(channelID, channelName, channelMin, channelMax) { 
	for (i=0; i<filename.length; i++) { 
	        if(endsWith(filename[i], ".tif")) { 
	                open(path+filename[i]); 
	                roiManager("Add");
					roiManager("Select", 0);
	                run("Split Channels"); 
					selectWindow(channelID + "-" +filename[i]);
	                setThreshold(channelMin, channelMax);  
					setOption("BlackBackground", false);
					run("Convert to Mask");
					roiManager("Select", 0);
					run("Analyze Particles...", analyzeParticleParameters);
					selectWindow("ROI Manager");
					run("Close");
	        }    
		}				
		close("*");		 
		selectWindow("Summary");
		saveAs("Results", resultsDir + channelName + "_counts" + ".csv");
		selectWindow("Results");
		run("Close");
}


for (i = 0; i < c1Analysis.length; i++) {
	if (c1Analysis[i] == PercentArea) {
		percentArea("C1", C1name, c1Tmin, c1Tmax);
	} else if (c1Analysis[i] == CellCount) { 
		cellCount("C1", C1name, c1Tmin, c1Tmax);
	}
}

for (i = 0; i < c2Analysis.length; i++) {
	if (c2Analysis[i] == PercentArea) {
		percentArea("C2", C2name, c2Tmin, c2Tmax);
	} else if (c2Analysis[i] == CellCount) { 
		cellCount("C2", C2name, c2Tmin, c2Tmax);
	}
}

for (i = 0; i < c3Analysis.length; i++) {
	if (c3Analysis[i] == PercentArea) {
		percentArea("C3", C3name, c3Tmin, c3Tmax);
	} else if (c3Analysis[i] == CellCount) { 
		cellCount("C3", C3name, c3Tmin, c3Tmax);
	}
}

for (i = 0; i < c4Analysis.length; i++) {
	if (c4Analysis[i] == PercentArea) {
		percentArea("C4", C4name, c4Tmin, c4Tmax);
	} else if (c4Analysis[i] == CellCount) { 
		cellCount("C4", C4name, c4Tmin, c4Tmax);
	}
}

close("*");