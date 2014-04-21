import peasy.*;
import hypermedia.net.*;
import java.util.concurrent.*;

PShader conway;
PGraphics pg;

PeasyCam cam;

DemoTransmitter demoTransmitter;
Boolean demoMode = true;
BlockingQueue<PImage> newImageQueue;

UDP udp;

PShape panel;

int ledsPerPanelX = 16;    // Number of LEDs per panel in the x direction
int ledsPerPanelY = 32;    // Number of LEDs per panel in the y direction

int panelXSegments = 32;    // Number of panels in a circle
int panelYSegments = 1;     // Number of circle layer


float pixelWidth = 1;
float panelWidth = ledsPerPanelX*pixelWidth;
float panelHeight = ledsPerPanelY*pixelWidth;

int imageWidth = ledsPerPanelX*panelXSegments;
int imageHeight = ledsPerPanelY*panelYSegments;

int packetLength = imageWidth*imageHeight*3;

void setup() {
  size(400, 400, P3D);
  frameRate(60);
  
  newImageQueue = new ArrayBlockingQueue<PImage>(2);
  
  pg = createGraphics(ledsPerPanelX*panelXSegments, ledsPerPanelY*panelYSegments, P2D);
  pg.noSmooth();
  conway = loadShader("led.glsl");
  conway.set("resolution", float(pg.width), float(pg.height));  

  udp = new UDP( this, 9999 );
  udp.listen( true );

  demoTransmitter = new DemoTransmitter();
  demoTransmitter.start();

  panel = createShape();
  panel.beginShape(QUADS);
  panel.texture(pg);

  for (int j = 0; j < panelYSegments; j++) {
    for (int i = 0; i < panelXSegments; i++) {
      float radsPerSide = 2*PI/panelXSegments;
      float xSpacing = (panelWidth/2.0)/sin(radsPerSide/2);

      float xStart = sin((2*PI*i    )/panelXSegments)*xSpacing;
      float xEnd   = sin((2*PI*(i+1))/panelXSegments)*xSpacing;
      float zStart = cos((2*PI*i    )/panelXSegments)*xSpacing;
      float zEnd   = cos((2*PI*(i+1))/panelXSegments)*xSpacing;
      float yStart =     j*panelHeight;
      float yEnd   = (j+1)*panelHeight;

      float texXStart =     i*ledsPerPanelX;
      float texXEnd =   (i+1)*ledsPerPanelX - 1;
      float texYStart =     j*ledsPerPanelY;
      float texYEnd =   (j+1)*ledsPerPanelY - 1;

      panel.vertex(xStart, yStart, zStart, texXStart, texYStart);
      panel.vertex(  xEnd, yStart, zEnd, texXEnd, texYStart);
      panel.vertex(  xEnd, yEnd, zEnd, texXEnd, texYEnd);
      panel.vertex(xStart, yEnd, zStart, texXStart, texYEnd);
    }
  }

  panel.endShape(CLOSE);

  cam = new PeasyCam(this, 0, 50, 0, 1000);
  cam.setMinimumDistance(2);
  cam.setMaximumDistance(400);
}

void draw() {
  //  conway.set("time", millis()/1000.0);
  //  float x = map(mouseX, 0, width, 0, 1);
  //  float y = map(mouseY, 0, height, 1, 0);
  //  conway.set("mouse", x, y);  
  //  pg.beginDraw();
  //  pg.background(0);
  //  pg.shader(conway);
  //  pg.rect(0, 0, pg.width, pg.height);
  //  pg.endDraw();

  background(30);
  
  if (newImageQueue.size() > 0) {
    PImage newImage = newImageQueue.remove();
    pg.beginDraw();
    pg.image(newImage,0,0);
    pg.endDraw();
  }

  scale(2);
  shape(panel, 0, 0);
}

int convertByte(byte b) {
  int c = (b<0) ? 256+b : b;

  return c;
}

void receive(byte[] data, String ip, int port) {  
  //println(" new datas!");
  if (demoMode) {
    println("Started receiving data from " + ip + ". Demo mode disabled.");
    demoMode = false;
  }

  if (data.length != packetLength) {
    println("Packet size mismatch. Expected "+packetLength+", got " + data.length);
    return;
  }

  if (newImageQueue.size() > 0) {
    println("Buffer full, dropping frame!");
    return;
  }

  PImage newImage = createImage(int(imageWidth), int(imageHeight), RGB);
  newImage.loadPixels();
  for(int x = 0; x < imageWidth; x++) {
    for(int y = 0; y < imageHeight; y++) {
      int offset = y*imageWidth+x;
      newImage.pixels[offset] = (int)(0xff<<24
                                   |  convertByte(data[offset*3 + 0])<<16)
                                   | (convertByte(data[offset*3 + 1])<<8)
                                   | (convertByte(data[offset*3 + 2]));
    }
  }
  
  newImage.updatePixels();
  
//  color[] newImage = new color[faces*strips*ledsPerStrip];
//  for (int i=0; i<faces*strips; i++) {
//    for (int j=0; j<ledsPerStrip; j++) {
//      int loc = j*(faces*strips) +i;
//      // Processing doesn't like it when you call the color function while in an event go figure
//      newImage[loc] = (int)(0xff<<24 | convertByte(data[loc*3 + 1])<<16) | (convertByte(data[loc*3 + 2])<<8) | (convertByte(data[loc*3 + 3]));
//    }
//  }

  try { 
    newImageQueue.put(newImage);
  } 
  catch( InterruptedException e ) {
    println("Interrupted Exception caught");
  }
}

