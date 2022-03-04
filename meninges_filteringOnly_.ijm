// Meninges analysis macro for filtering four channels 
// this macro will take a folder filled with .tif files that have already had max z-projection and do the following:
// a) allow the user to set the channel name, color, brightness/contrast min and max, and threshold values for up to four channels 
// b) apply these settings to all images in the chosen directory 
// c) apply median filter to sharpen images 
// d) save a merged images in a new folder of "Filtered_TIFs" 

// Start of Settings // -------------------------------------------------------------------------------
//set the name, color, min, max and thresholds here for all the channels 
// Channel 1 
C1name = "DAPI";
C1color = "Blue";
C1min = 10;
C1max = 120;

// Channel 2 
C2name = "CD3";
C2color = "Magenta";
C2min = 30;
C2max = 100;

// Channel 3
C3name = "Lyve-1";
C3color = "Grays";
C3min = 10;
C3max = 170;

// Channel 4 
C4name = "MHC-II";
C4color = "Yellow Hot";
C4min = 40;
C4max = 255;

//set the pixel radius for median filter (1 is generally good for meninges at 10x)
pixelrad = "radius=1"

// End of Settings //	----------------------------------------------------------------------------------------				

// Bring up the directory and set up folders for filtered images and results
path = getDirectory("Choose a Directory"); 
filename = getFileList(path); 
filteredDir = path + "Filtered_TIFs" + File.separator; 

File.makeDirectory(filteredDir); 

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
                saveAs("tiff", filteredDir + getTitle);
      }    			
}
                close("*");	
                