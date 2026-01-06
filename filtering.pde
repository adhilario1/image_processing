boolean loaded=false;
PImage porco;
PImage orig;
PImage curr;

float lCoef=0.0; //lighting coefficient
float deltaB = 0.0; //delta brightness
float aCoef=0.0; //opacity coefficient
float deltaA = 0.0; //delta opacity
                     
void setup(){
  size(1200, 613);
  porco = loadImage("Porco-Rosso.jpg");
  orig = porco;
  curr = porco;
}

void draw() {
  background(0,0,0,100);
  image(porco, 0, 0, 993, 613);
  image(curr, 0, 0, 993, 613);
  textSize(16);
  fill(255);
  text("LEGEND\n"+
  "Key '+' - Brighten\n"+
  "Key '-' - Darken\n"+
  "Key 'B' - Blur\n"+
  "Key 'D' - Dilate\n"+
  "Key 'E' - Erode\n"+
  "Key 'G' - Grey Scale\n"+
  "Key 'H' - Contrast\n"+
  "Key 'I' - Invert\n"+
  "Key 'S' - Smooth\n"+
  "Key 'C' - Clear", 1000, 20);
}

void keyPressed(){
  noLoop();
   if (key=='C' || key=='c') {
     curr = orig;
   }
  if (key=='I' || key=='i') {
    
    curr = invert(curr);
  }
  if (key=='G' || key=='g'){
    curr = grayScale(curr);
  }
  if (key=='A' || key=='a'){
    curr = detectEdge(curr);
  }
  if (key=='B' || key=='b'){
    curr = blur(curr);
  }
  if (key=='H' || key=='h'){
    curr = highContrast(curr);
  }
  if (key=='E' || key=='e'){
    curr = erode(curr);
  }
  if (key=='D' || key=='d'){
    curr = dilate(curr);
  }
  if (key=='P' || key=='p') {
    curr = paint(curr);
  }
  if (key=='S' || key=='s'){
    curr = edgeSmooth(curr);
  }
  if(key=='+'){
    curr = darken(false, orig);
  }
  if (key=='-'){
    curr = darken(true, orig);
  }
  image(curr, 0,0,525, 710);
  loop();
}

PImage greyScale(PImage orig) {
  PImage temp = orig.copy();
  return temp;
}

PImage invert(PImage orig){
  PImage temp = orig.copy();
  //loadPixels();
  temp.loadPixels();
  for (int x=0; x<temp.width;x++){
    for(int y=0; y<temp.height;y++){
      int loc = x + y*temp.width;
      
      //get rgb
      float r = red(temp.pixels[loc]);
      float g = green(temp.pixels[loc]);
      float b = blue(temp.pixels[loc]);
      //invert
      r=255-r;
      g=255-g;
      b=255-b;
      color c = color(r,g,b);
      temp.pixels[loc]=c;
    }
  }
  return temp;
}
PImage darken(boolean dir, PImage orig) {
  
  if (dir == true) {
    if (deltaB>0.0) deltaB=0.0; //reset lighting coefficient
    deltaB-=5.0;
  } else {
    if (deltaB<0.0) deltaB=0.0;
    deltaB+=5.0;
  }
  deltaB = constrain(deltaB, -255, 255);
  lCoef += deltaB;
  lCoef = constrain(lCoef, -255, 255);
  //println(lCoef);
  
  PImage temp = orig.copy();
  //loadPixels();
  temp.loadPixels();
  orig.loadPixels();
  for (int x=0; x<orig.width;x++){
    for(int y=0; y<orig.height;y++){
      int loc = x + y*orig.width;
      
      //get rgb
      float r = red(orig.pixels[loc]);
      float g = green(orig.pixels[loc]);
      float b = blue(orig.pixels[loc]);
      
      r += lCoef;
      g += lCoef;
      b += lCoef;
      
      r = constrain(r,0,255);
      g = constrain(g,0,255);
      b = constrain(b,0,255);
    
      color c = color(r,g,b);
      temp.pixels[loc]=c;
    }
  }
  return temp;
}

PImage grayScale(PImage orig){
  PImage temp = orig.copy();
  
  //loadPixels();
  temp.loadPixels();
  for (int x=0; x<temp.width;x++){
    for(int y=0; y<temp.height;y++){
      int loc = x + y*temp.width;
      
      //get rgb
      float r = red(temp.pixels[loc]);
      float g = green(temp.pixels[loc]);
      float b = blue(temp.pixels[loc]);
      
      float intensity = 0.21f*r+0.71f*g+0.07f*b;
      
      color c = color(intensity);
      temp.pixels[loc]=c;
    }
  }
  return temp;
}

PImage edgeSmooth(PImage img){
  PImage tmp = img.copy();
  PImage smooth = createImage(img.width, img.height, RGB);
  tmp.loadPixels();
  //iterates pixel by pixel of whole image
  for (int x=0; x<tmp.width;x++){
    for(int y=0; y <tmp.height;y++){
      float minVar = 255; //minimum variance of each quadrant
      //cetral pixel of each 3x3 subsquare
      int min_i=0; 
      int min_j=0;
      //iterates through the central pixels of each 3x3 sub matrix
      for(int i=x-1; i<=x+1; i+=2) {
        //if (i<0||i>=tmp.width) continue; 
        for (int j=y-1;j<=y+1;j+=2) {
          //if (j<0 || j>=tmp.height) continue;
          
          float submin = 255;
          float submax = 0;
           
          for (int ki = -1; ki <= 1; ki++) {
            if (i+ki <0 || i+ki>=tmp.width) continue;
            //println(ki);
            for (int kj = -1; kj <= 1; kj++) {
              if (j+kj <0 || j+kj >= tmp.height) continue;
              
              int subPos=(i+ki)+tmp.width*(j+kj); //position in 3x3 array
              //println(subPos);
              float r = red(tmp.pixels[subPos]);
              float g = green(tmp.pixels[subPos]);
              float b = blue(tmp.pixels[subPos]);
              float intensity = 0.21f*r+0.71f*g+0.07f*b;
              if (intensity < submin) submin = intensity;
              if (intensity > submax) submax = intensity;
            }
          }
           
          float variance = submax-submin;
          if (variance <= minVar) {
             min_i = i;
             min_j = j;
             minVar=variance;
          }
        }
      }
      float ravg = 0;
      float gavg = 0;
      float bavg = 0;
      for (int ki = -1; ki <= 1; ki++) {
        if (min_i + ki<0 || min_i+ki>=tmp.width) continue;
        
        for (int kj = -1; kj <= 1; kj++) {
          if (min_j+kj < 0 || min_j+kj >= tmp.height) continue;
          
          int subPos=(min_i+ki)+tmp.width*(min_j+kj);
          float r = red(tmp.pixels[subPos]);
          float g = green(tmp.pixels[subPos]);
          float b = blue(tmp.pixels[subPos]);
             
          ravg +=r;
          gavg +=g;
          bavg +=b;
        }
      }
      smooth.pixels[x+smooth.width*y] = color(ravg/9, gavg/9, bavg/9);
    }
  }
  smooth.updatePixels();
  return smooth;
}

PImage erode(PImage img) {
  PImage tmp = createImage(img.width, img.height, RGB);
  for (int x = 0; x < img.width;x++){
    for(int y = 0; y < img.height;y++){
      float lowest_r = 255;
      float lowest_g = 255;
      float lowest_b = 255;
      
      for (int kx = -1; kx <= 1; kx++) {
        if (x+kx <0 || x+kx>=img.width) continue;
        for (int ky = -1; ky <= 1; ky++) {
          if (y+ky <0 || y+ky >= img.height) continue;
          int subPos = (x+kx)+(y+ky)*img.width;
          float r = red(img.pixels[subPos]);
          //println(r);
          float g = green(img.pixels[subPos]);
          float b = blue(img.pixels[subPos]);
          
          if (r<lowest_r) lowest_r = r;
          if (g<lowest_g) lowest_g = g;
          if (b<lowest_b) lowest_b = b;
        }
      }
      //println("--------");
      tmp.pixels[x+y*tmp.width] = color(lowest_r, lowest_g, lowest_b);
    }
  }
  tmp.updatePixels();
  return tmp;
}

PImage dilate(PImage img){
  PImage tmp = createImage(img.width, img.height, RGB);
  for (int x = 0; x < img.width;x++){
    for(int y = 0; y < img.height;y++){
      float highest_r = 0;
      float highest_g = 0;
      float highest_b = 0;
      
      for (int kx = -1; kx <= 1; kx++) {
        if (x+kx <0 || x+kx>=img.width) continue;
        for (int ky = -1; ky <= 1; ky++) {
          if (y+ky <0 || y+ky >= img.height) continue;
          int subPos = (x+kx)+(y+ky)*img.width;
          float r = red(img.pixels[subPos]);
          //println(r);
          float g = green(img.pixels[subPos]);
          float b = blue(img.pixels[subPos]);
          
          if (r>highest_r) highest_r = r;
          if (g>highest_g) highest_g = g;
          if (b>highest_b) highest_b = b;
        }
      }
      //println("--------");
      tmp.pixels[x+y*tmp.width] = color(highest_r, highest_g, highest_b);
    }
  }
  tmp.updatePixels();
  return tmp;
}

PImage paint(PImage img){
  PImage tmp = img.copy();
  PImage outline = detectEdge(tmp);
  outline = erode(erode(outline));
  //tmp=outline;
  
  PImage filler = edgeSmooth(edgeSmooth(edgeSmooth(tmp)));
  
  for (int x = 0; x < outline.width;x++){
    for(int y = 0; y < outline.height;y++){
      int loc = x+y*outline.width;
      
      float r = red(outline.pixels[loc]);
      float g = green(outline.pixels[loc]);
      float b = blue(outline.pixels[loc]);
      
      if ((r+g+b)/3 == 255) {
        
        float pr = red(filler.pixels[loc]);
        float pg = green(filler.pixels[loc]);
        float pb = blue(filler.pixels[loc]);
        //println(pb);
        outline.pixels[loc] = color(pr, pg, pb);
      }
    }
  }
  outline.updatePixels();
  return outline;
}

PImage highContrast(PImage img){
  PImage tmp = img.copy();
  //float threshold = 100.0;
  
  for (int x = 0; x < tmp.width;x++){
    for(int y = 0; y < tmp.height;y++){
      int loc = x+tmp.width*y;
      
      float r = red(tmp.pixels[loc]);
      float g = green(tmp.pixels[loc]);
      float b = blue(tmp.pixels[loc]);
      
      float intensity = 0.21f*r+0.71f*g+0.07f*b;
      //println(intensity);
      if (intensity > 255 - 255/4) {
        r+=5;
        g+=5;
        b+=5;
      } else if (intensity <= 255/4){
        r-=5;
        g-=5;
        b-=5;
      } else if(intensity > 255/4 && intensity <= 255/2) {
        r-=2.5;
        g-=2.5;
        b-=2.5;
      } else if (intensity > 255/2 && intensity <= (255 - 255/4)) {
        r+=2.5;
        g+=2.5;
        b+=2.5;
      }
      
      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);
      
      color c = color(r, g, b);
      tmp.pixels[loc] = c;
    }
  }
  tmp.updatePixels();
  return tmp;
}

PImage blur(PImage img) {
  PImage tmp = img.copy();
  
  for (int x=0; x<tmp.width;x++){
    for(int y=0; y <tmp.height;y++){
      
      float r_avg = 0;
      float g_avg = 0;
      float b_avg = 0;
      
      float count = 0;
      
      for(int kx=-1; kx<=1; kx++) {
        if (x+kx <0 || x+kx>=tmp.width) continue;
        for (int ky=-1;ky<=1;ky++) {
          if (y+ky <0 || y+ky>=tmp.height) continue;
          int loc = (x+kx)+(y+ky)*tmp.width;
          
          float r = red(tmp.pixels[loc]);
          float g = green(tmp.pixels[loc]);
          float b = blue(tmp.pixels[loc]);
          
          r_avg += r;
          g_avg += g;
          b_avg += b;
          
          count+=1;
        }
      }
      tmp.pixels[x+y*tmp.width] = color(r_avg/count, g_avg/count, b_avg/count);
    }
  }
  
  tmp.updatePixels();
  return tmp;
}

PImage enhance(PImage img) {
  PImage tmp = img.copy();
  
  for (int x=0; x<tmp.width;x++){
    for(int y=0; y <tmp.height;y++){
      
      float r_avg = 0;
      float g_avg = 0;
      float b_avg = 0;
      
      float count = 0;
      
      for(int kx=-1; kx<=1; kx++) {
        if (x+kx <0 || x+kx>=tmp.width) continue;
        for (int ky=-1;ky<=1;ky++) {
          if (y+ky <0 || y+ky>=tmp.height) continue;
          int loc = (x+kx)+(y+ky)*tmp.width;
          
          float r = red(tmp.pixels[loc]);
          float g = green(tmp.pixels[loc]);
          float b = blue(tmp.pixels[loc]);
          
          r_avg += r;
          g_avg += g;
          b_avg += b;
          
          count+=1;
        }
      }
      tmp.pixels[x+y*tmp.width] = color(r_avg/count, g_avg/count, b_avg/count);
    }
  }
  
  tmp.updatePixels();
  return tmp;
}
//other
PImage detectEdge(PImage img){
  
   float[][] matrix = { { -1/8, -1/8, -1/8 },
                     { -1/8,  1, -1/8 },
                     { -1/8, -1/8, -1/8 } };
                     
   PImage tmp = grayScale(img);
   tmp = edgeSmooth(tmp);
   tmp.loadPixels();
   PImage edgeImg = createImage(tmp.width, tmp.height, RGB);
   
   for (int y = 1; y<tmp.height-1;y++){
     for (int x = 1; x < tmp.width-1; x++){
       float sum = 0;
       
       for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            // Calculate the adjacent pixel for this kernel point
            int pos = (y + ky)*tmp.width + (x + kx);

            // Image is grayscale, red/green/blue are identical
            float val = blue(tmp.pixels[pos]);
            // Multiply adjacent pixels based on the kernel values
            sum += matrix[ky+1][kx+1] * val;
            
          }
       }
       
       if (sum < 100) {
         sum = 255;
       } else {
         sum = 0;
       }
       //println(sum);
       tmp.pixels[y*tmp.width + x] = color(sum);
     }
   }
   
   // Since we are looking at left neighbors
    // We skip the first column
    for (int x = 1; x < tmp.width; x++) {
      for (int y = 0; y < tmp.height; y++ ) {
        // Pixel location and color
        int loc = x + y*tmp.width;
        color pix = tmp.pixels[loc];
    
        // Pixel to the left location and color
        int leftLoc = (x-1) + y*tmp.width;
        color leftPix = tmp.pixels[leftLoc];
    
        // New color is difference between pixel and left neighbor
        float diff = abs(brightness(pix) - brightness(leftPix));
        if (diff!=0) edgeImg.pixels[loc] = color(0);
        if (diff==0)edgeImg.pixels[loc] = color(255);
      }
    }
   edgeImg.updatePixels();
   return edgeImg;
}
