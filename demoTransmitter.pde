// regular color() does things that aren't thread-safe, which results in random color flashes on the screen.
// This was tracked down by Justin after lots of frustration on the original dome simulator...
// Note that this version only handles 0-255 RGB based colors.
int safeColor(int r, int g, int b) {
  r = min(255,max(0,r));
  g = min(255,max(0,g));
  b = min(255,max(0,b));
  
  return (0xFF << 24) + (r << 16) + (g << 8) + (b << 0);
}

class DemoTransmitter extends Thread {

  float animationStep = 0;
  final int spacing = imageHeight; 

  PImage MakeDemoFrame() {

    PImage imageData = createImage(imageWidth, imageHeight, RGB);
    imageData.loadPixels();
    int y = int(animationStep);
    for(int x = 0; x < imageWidth; x++) {
      imageData.pixels[y*imageWidth + x] = safeColor(0,0,255);
    }
    imageData.updatePixels();
    
//    PGraphics pg = createGraphics(ledsPerPanelX*panelXSegments, ledsPerPanelY*panelYSegments, P2D);    
//    pg.beginDraw();
//    for (int segY = 0; segY < panelYSegments; segY++) {
//      for (int segX = 0; segX < panelXSegments; segX++) {
//  
//        pg.fill(random(60), random(60), random(60));
//        pg.stroke(0, 0, 200);
//        pg.strokeWeight(1);
//        pg.rect(segX*ledsPerPanelX, segY*ledsPerPanelY, ledsPerPanelX-2, ledsPerPanelY-2);
//  
//        pg.fill(255);
//        pg.textSize(10);
//        pg.text(str(segY*panelXSegments + segX), segX*ledsPerPanelX + 1, segY*ledsPerPanelY + 20);
//      }
//    }
//    pg.endDraw();
    
    animationStep = (animationStep + .3)%spacing;    

    return imageData;
  }

  DemoTransmitter() {
  }

  void run() {
    while (demoMode) {
      try {
        if (newImageQueue.size() < 1) {
          PImage imageData = MakeDemoFrame();
          newImageQueue.put(imageData);
        }
        Thread.sleep(1);
      } 
      catch( InterruptedException e ) {
        println("Interrupted Exception caught");
      }
    }
  }
}

