void mouseClicked(){ //Checks all buttons if mouse is clicked.
  for(int i = 0;i<buttons.size();i++){
    button b = buttons.get(i);
    b.buttonClick();
  }
}
