Float stringToFloat(String str){ //extended string to float conversion where a NaN is converted to 0. Prevents some weird behavior. 
  float buffer = 0;
  buffer = float(str);
  if(Float.isNaN(buffer)){
    if(str.equals("true")){
      buffer = 1;
    }
    else{
      buffer = 0;
    }
  }
  return buffer;
}
