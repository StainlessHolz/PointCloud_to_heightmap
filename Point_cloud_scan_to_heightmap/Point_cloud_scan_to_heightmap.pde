/*
Ive made some progress.
Meshlab can make 3D models out of point clouds, but either the mesh is really big (face count) or i loose details with point redistribution, also it takes a long time with each try. 
With the way my LiDar works i do have a high point density in the middle axis of the scan and it decreases the further it moves out of the middle.

I decided to go on with the heightmap/displacement method.
*/
ArrayList<scanPoint>scanPoints = new ArrayList<scanPoint>(); //stores scan points
ArrayList<button>buttons = new ArrayList<button>(); //stores buttons

float minX = 0;                // min / max values used for scaling the point cloud to the heightmap. They are gathered while parsing a point cloud. 
float maxX = 0;
float minY = 0;
float maxY = 0;
float minZ = 0;
float maxZ = 0;

//float lidarAngle = 38.4;

float overrideMaxZValue = 3;   // used to limit the Z depth of a scan. This value uses the scaling of the input data.
boolean overrideMaxZ = true;   // use it to switch the limit on/off.

int calculatedPixels = 0;      //used to communicate the progress of the thread which is calculating the heightmap
int pixelsToCalculate = 0;     //used to communicate the progress of the thread which is calculating the heightmap
String calculationAction = ""; //used to communicate the action of the thread which is calculating the heightmap
int calculationStarted = 0;    //used to communicate the start time of the action of the thread which is calculating the heightmap
boolean renderDone = false;    //used to communicate the end of the thread which is calculating the heightmap
boolean renderStarted = false; //used to communicate the start of the thread which is calculating the heightmap

int bitdepth = 255;            // max value of the RGB channels of the saved png file. (maybe updating to 16 bit for way higher resolution)
int HMwidth = 1000;            // good 1000 (heightmap width)
int HMheight = 1000;           // good 1000 (heightmap height)
int smoothEmptyPixels = 10;    //how much nearby pixels should be sampled for an empty pixel. good:10 (ratio to resolution is squared)
int maxSearchDistance = 8;     //maximal distance to nearby pixels before end of search, highly impacts performance. good:8 (ratio to resolution is squared)
PImage heightmap;

String standardFilePath = "";  //Stores the filepath of an opened file
String standardFileName = "";  //Stores the filename of an opened file. Used to save the heightmap with another ending. Does not replace the data but adds numbers to the end if its existing.
String fileAction = "";        //Internally used to tell if the file is being opened or saved. The callback function does not seem to differentiate that.

boolean stopRender = false;    //used to stop the rendering thread. Needs to be integrated.

void setup(){
  size(1000,1000,P2D);
  frameRate(20); //reducing the frameRate improves the rendering speed somehow?! Weird because its a different thread.
  textSize(20);
  surface.setTitle("PointCloud Heightmap Converter");
  buttons.add(new button(0,0,250,25,"Load Scan",1, true));               // Adding buttons
  buttons.add(new button(width-250,0,250,25,"Save Heightmap",2, false));
  buttons.add(new button(0,35,250,25,"Calculate Heightmap",6, false));
  buttons.add(new button(0,70,250,25,"Stop calculation",5, false));
  heightmap = new PImage(HMwidth,HMheight);
}

void draw(){
  if(renderDone){
    image(heightmap,0,0,width,height);
  }
  else{ // if render started, draw its progress. Percentage, Estimated time, elapsed time, current action
    background(0);
    if(renderStarted){
      textAlign(LEFT,BOTTOM);
      text("Calculated pixels: " + calculatedPixels + " of: "+ pixelsToCalculate,10,height-10);
      float percentage = (float(calculatedPixels)/float(pixelsToCalculate))*100;
      text(nf(percentage,0,3) + "%",10,height-30);
      float seconds = (millis()-calculationStarted)/1000;
      float minutes = seconds/60;
      float hours = minutes/60;
      text("Time since calculation start: "+int(hours) + ":"+int(minutes%60)+ ":"+int(seconds)%60,10,height-50);
      float eSeconds = (100/percentage)*(millis()-calculationStarted)/1000;
      float eMinutes = eSeconds/60;
      float eHours = eMinutes/60;
      text("Estimation: "+int(eHours) + ":"+int(eMinutes%60)+ ":"+int(eSeconds)%60,10,height-70);
      text("Calculation Action: "+calculationAction,10,height-90);
    }
  }
  for(int i = 0;i<buttons.size();i++){ //drawing all buttons
    button b = buttons.get(i);
    b.displayButton();
  }
}
