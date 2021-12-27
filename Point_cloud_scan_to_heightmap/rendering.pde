void parseFile(String filePath) {                //importing a point cloud. Currently set to a livox .csv file. change to your needs. In this case input XYZ are processing ZXY.
  BufferedReader reader = createReader(filePath);
  String line = null;
  Boolean abortParsing = false;
  int discardedPointCounter = 0;
  scanPoints = new ArrayList<scanPoint>();       //if anything was imported beforehand it will be deleted now.
  try {
    while ((line = reader.readLine()) != null) {
      String[] coord = split(line, ",");         //splitting a csv line. These are the important lines for any import
      float X = stringToFloat(coord[9]);
      float Y = stringToFloat(coord[10]);
      float Z = stringToFloat(coord[8]);
      if(!Float.isNaN(X) && !Float.isNaN(Y) && !Float.isNaN(Z)){ //double checking that the floats are not NaN. Probably useless since its already done in the conversion function.
        if(overrideMaxZ){                         //check if max Z value is used.
          if(Z<overrideMaxZValue){                //discard all unused points.
            scanPoints.add(new scanPoint(X,Y,Z)); //add point if maxZ range
          }
          else{
            discardedPointCounter ++;
          }
        }
        else{
          scanPoints.add(new scanPoint(X,Y,Z));
        }
      }
    }
    reader.close();
  } catch (Exception e) {                          // if the file does not fit to the parsing method it gets aborted
    abortParsing = true;
    println("This file doesnt work!");
  }
  if(!abortParsing){                               // if the file is ok commence with the parsing
    for(int i = 0;i<scanPoints.size();i++){
      scanPoint sp = scanPoints.get(i);
      float Z = sp.pZ;
      float X = sp.pX;
      float Y = sp.pY;
      if(X>maxX)maxX = X; else if(X<minX) minX = X;// used to get the maximum XYZ values
      if(Y>maxY)maxY = Y; else if(Y<minY) minY = Y; 
      if(Z>maxZ)maxZ = Z; else if(Z<minZ) minZ = Z; 
      if(i == 1){                                  // used to set the first XYZ values, otherwise the max or min values may be falsely 0.
        minX = X;
        maxX = X;
        minY = Y;
        maxY = Y;
        minZ = Z;
        maxZ = Z;
      }
    }
    if(maxX>maxY)maxY=maxX;else maxX=maxY;          // needed to get a square and non distorted heightmap
    if(minX<minY)minY=minX;else minX=minY;
    setButtonState(2,true);
    setButtonState(3,true);
    setButtonState(4,true);
    setButtonState(6,true);
    if(overrideMaxZ) maxZ = overrideMaxZValue;       // Probably obsolete since all other points are discarded.
    println("maxX: "+maxX+" ||minX: "+minX);         // printing some point cloud stats
    println("maxY: "+maxY+" ||minY: "+minY);
    println("maxZ: "+maxZ+" ||minZ: "+minZ);
    println("number of points: "+scanPoints.size());
    println("discarded points: "+discardedPointCounter);
  }
}

class scanPoint{
  float pX = 0;
  float pY = 0;
  float pZ = 0;
  
  scanPoint(float x, float y, float z){
    pX = x;
    pY = y;
    pZ = z;
  }
}

void drawHeightmapNormalizedFillOptimized(){ // werid name because of old different functions to calculate the heighmap. Previous ones are crap and deleted.
  println("start drawing heightmap");  
  renderDone = false;
  renderStarted = true;
  calculatedPixels = 0;
  
  calculationStarted = millis();                       //creating and zeroing value and counter fields
  pixelsToCalculate = HMwidth*HMheight;
  calculationAction = "Zeroing buffer fields";  
  float HMvalue[][] = new float[HMwidth][HMheight];    //stores all z values as floats
  int HMcount[][] = new int[HMwidth][HMheight];        //stores how many values are added in the value fields
  for(int X = 0;X<HMwidth;X++){
    for(int Y = 0;Y<HMheight;Y++){
      HMvalue[X][Y]=0;
      HMcount[X][Y]=0;
      calculatedPixels++;
    }
  }
  calculatedPixels = 0;
  
  calculationStarted = millis();
  calculationAction = "Adding points to pixels";        //if a point is inside of a pixel its value gets added to it and count is incremented
  pixelsToCalculate = scanPoints.size();
  for(int i = 0; i<pixelsToCalculate;i++){
    scanPoint sp = scanPoints.get(i);
    int X = int(map(sp.pX,minX,maxX,0,HMwidth)-0.5);
    int Y = int(map(sp.pY,minY,maxY,0,HMheight)-0.5);
    HMvalue[X][Y]+=sp.pZ-minZ;
    HMcount[X][Y]++;
    calculatedPixels ++;
  }
  calculatedPixels = 0;
  
  calculationStarted = millis();
  calculationAction = "Averaging pixels";                //getting the average Z height of each pixel. This way each detail from a point cloud is used. Also nice to smooth noisy point clouds
  pixelsToCalculate = scanPoints.size();
  for(int X = 0;X<HMwidth;X++){
    for(int Y = 0;Y<HMheight;Y++){
      if(HMcount[X][Y]!=0){
        HMvalue[X][Y]/=HMcount[X][Y];
        calculatedPixels ++;
      }
    }
  }
  calculatedPixels = 0;
  
  calculationStarted = millis();
  calculationAction = "Fill empty pixels";                // now calculating all the empty pixels by scanning to their neighbours
  pixelsToCalculate = 0;                                  // counting how many pixels need to be calculated. used by the progress monitor
  for(int X = 0;X<HMwidth;X++){
    for(int Y = 0;Y<HMheight;Y++){
      if(HMcount[X][Y]==0){
        pixelsToCalculate ++;
      }
    }
  }
  for(int X = 0;X<HMwidth;X++){          //Distance is squared as following:
    for(int Y = 0;Y<HMheight;Y++){       //22222
      if(HMcount[X][Y]==0){              //21112
        int searchDistance = 1;          //21012
        float foundValues = 0;           //21112
        int foundPixels =0;              //22222
        while(foundPixels<smoothEmptyPixels){  // if found enough pixels to commence to next pixel, do it
          if(searchDistance>maxSearchDistance){ //if max distance is reached commence to next pixel
            foundValues = maxZ-minZ;
            foundPixels = 1;
            break;
          }
          for(int X1 = -searchDistance;X1<=searchDistance;X1++){ //searching on a square line for non empty pixels. 
            if(X1 == -searchDistance || X1 == searchDistance){
              for(int Y1 = -searchDistance;Y1<=searchDistance;Y1++){
                int X2 = X+X1;
                int Y2 = Y+Y1;
                if(X2 >= 0 && X2 <HMwidth && Y2 >= 0 && Y2 <HMheight){
                  if(HMcount[X2][Y2]!=0){
                    foundValues += HMvalue[X2][Y2];
                    foundPixels ++;
                  }
                }
              }
            }
            else{
              for(int Y1 = -searchDistance;Y1<=searchDistance;Y1++){
                int X2 = X+X1;
                int Y2 = Y+Y1;
                if(X2 >= 0 && X2 <HMwidth && Y2 >= 0 && Y2 <HMheight){
                  if(HMcount[X2][Y2]!=0){
                    foundValues += HMvalue[X2][Y2];
                    foundPixels ++;
                  }
                }
              }
            }
          }
          searchDistance++;
        }
        HMvalue[X][Y]=foundValues/foundPixels; //fill the empty pixel with the average of all neighbor pixels. This prevents linear color gradients a little bit
        calculatedPixels ++;
      }
    }
  }
  calculatedPixels = 0;
  
  calculationStarted = millis();
  calculationAction = "Draw to heightmap";  //convert the float heightmap to a b/w heightmap
  pixelsToCalculate = HMwidth*HMheight;
  for(int X = 0;X<HMwidth;X++){
    for(int Y = 0;Y<HMheight;Y++){
      int heightValue = bitdepth-int(map(HMvalue[X][Y],0,maxZ-minZ,0,bitdepth));
      color bufferColor = color(heightValue,heightValue,heightValue);
      heightmap.set(HMwidth-X,HMheight-Y,bufferColor);
      calculatedPixels ++;
    }
  }
  calculatedPixels = 0;
  
  stopRender = false;
  println("done drawing heightmap");
  renderDone = true;
  renderStarted = false;
  setButtonState(3,true);
  setButtonState(4,true);
  setButtonState(5,false);
}
