void savingFile(){
  fileAction="saving";
  if(!standardFilePath.equals("") && !standardFileName.equals("")){
    saveHeightmap(standardFilePath+standardFileName); //saves the heightmap to the location where the file was opened from
  }
  else{
    selectOutput("Select a file to save to", "fileSelected"); //if no path is available the user has to select one. Useless since you cant save without loading a file beforehand.
  }
}

void loadingFile(){
  fileAction="loading";
  selectInput("Select a file to open", "fileSelected");
}

void fileSelected(File selection){
  if (selection == null){
    println("File selection window was closed or the user hit cancel.");
  } 
  else{
    if(fileAction.equals("loading")){ // parsing the filepath and name
      String path = selection.getAbsolutePath();
      int index = path.lastIndexOf("\\");
      standardFilePath = path.substring(0,index+1);
      path = path.substring(index+1);
      index = path.lastIndexOf(".");
      standardFileName = path.substring(0, index);
      parseFile(selection.getAbsolutePath());
    }
    else if(fileAction.equals("saving")){
      heightmap.save(selection.getAbsolutePath());
    }
  }
}

void saveHeightmap(String filePath){
  File f = dataFile(filePath+".png");
  int counter = 1;
  while(f.isFile()){ //check if the file already exists and iterate a counter until a filename is found which does not exist
    f = dataFile(filePath+str(counter)+".png");
    counter ++;
  }
  heightmap.save(f.getPath());
  println("Heightmap saved: "+f.getPath());
}
