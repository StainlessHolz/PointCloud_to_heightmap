int buttonBorder = 2; //distance of text size to border of the button. Only used if the Button is called without the size

class button{
  int pX = 0;               //Button position
  int pY = 0;
  int sX = 0;               //Button scale
  int sY = 20;
  String label = "";        //button label
  
  int function = 0;         //sets wich function the button has
  
  boolean enabled = true;   //stores if the button is enabled
  boolean hovering = false; //stores if the mouse hovers over the button
  boolean clicked = false;  //stores if the button is clicked to the next frame
  
  button(int px, int py, int sx, int sy, String lbl, int fn, boolean en){ //creating a button with size
    pX = px;
    pY = py;
    sX = sx;
    sY = sy;
    label = lbl;
    function = fn;
    enabled = en;
  }
  
  button(int px, int py, String lbl, int fn, boolean en){ //creating a button with automated size
    pX = px;
    pY = py;
    function = fn;
    sY = int(g.textSize)+2*buttonBorder;
    sX = int(textWidth(lbl))+2*buttonBorder;
    label = lbl;
    enabled = en;
  }
  
  void displayButton(){
    if(mouseX>pX && mouseX<pX+sX && mouseY>pY && mouseY<pY+sY){ //check if mouse is hovering
      hovering = true;
    }
    else{
      hovering = false;
    }
    if(enabled){ // different colors depending on enabled, hovering or clicked.
      if(clicked){
        fill(0,255,0,200);
        stroke(0,255,0,200);
      }
      else if(hovering){
        fill(0,255,0,150);
        stroke(0,255,0,150);
      }
      else{
        fill(0,255,0,120);
        stroke(0,255,0,120);
      }
    }
    else{
      fill(255,0,0,120);
      stroke(255,0,0,120);
    }
    strokeWeight(2);
    textAlign(CENTER,CENTER);
    text(label,pX+sX/2,pY+sY/2); //displaying the button
    noFill();
    rect(pX+g.strokeWeight,pY+g.strokeWeight,sX-g.strokeWeight,sY-g.strokeWeight,sY/3);
    clicked = false;
  }
  
  void buttonClick(){
    if(hovering && enabled){ // check if the button is clickable and clicked
      clicked = true;
      if(function == 1){ // different functions for different function numbers
        loadingFile();
      }
      else if(function == 2){
        savingFile();
      }
      else if(function == 3){ 
        thread("drawHeightmapSimple"); //old unused
        setButtonState(3,false);
        setButtonState(4,false);
        setButtonState(5,true);
        setButtonState(6,false);
      }
      else if(function == 4){
        thread("drawHeightmapFilled"); //old unused
        setButtonState(3,false);
        setButtonState(4,false);
        setButtonState(5,true);
        setButtonState(6,false);
      }
      else if(function == 5){ //needs to be implemented
        stopRender=true;
        setButtonState(3,true);
        setButtonState(4,true);
        setButtonState(5,false);
        setButtonState(6,true);
      }
      else if(function == 6){
        thread("drawHeightmapNormalizedFillOptimized");
        setButtonState(3,false);
        setButtonState(4,false);
        setButtonState(5,true);
        setButtonState(6,false);
      }
    }
  }
}

void setButtonState(int fn, boolean en){ //sets all buttons with the corresponding function number to enabled or not enabled
  for(int i = 0;i<buttons.size();i++){
    button b = buttons.get(i);
    if(b.function==fn){
      b.enabled = en;
      break;
    }
  }
}
