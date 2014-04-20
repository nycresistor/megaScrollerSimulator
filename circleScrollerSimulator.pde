import peasy.*;

PShader conway;
PGraphics pg;

PeasyCam cam;

PShape panel;

int ledsPerPanelX = 16;    // Number of LEDs per panel in the x direction
int ledsPerPanelY = 32;    // Number of LEDs per panel in the y direction


float pixelWidth = 1;
float panelWidth = ledsPerPanelX*pixelWidth;
float panelHeight = ledsPerPanelY*pixelWidth;

int panelXSegments = 32;    // Number of panels in a circle
int panelYSegments = 2;    // Number of panel circles

void setup() {
  size(400, 400, P3D);    
  pg = createGraphics(ledsPerPanelX*panelXSegments, ledsPerPanelY*panelYSegments, P2D);
  pg.noSmooth();
  conway = loadShader("led.glsl");
  conway.set("resolution", float(pg.width), float(pg.height));  
  
  panel = createShape();
  panel.beginShape(QUADS);
  panel.texture(pg);
  
  for(int j = 0; j < panelYSegments; j++) {
    for(int i = 0; i < panelXSegments; i++) {
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
      panel.vertex(  xEnd, yStart, zEnd,   texXEnd,   texYStart);
      panel.vertex(  xEnd,   yEnd, zEnd,   texXEnd,   texYEnd);
      panel.vertex(xStart,   yEnd, zStart, texXStart, texYEnd);
    }
  }
  
  panel.endShape(CLOSE);

  cam = new PeasyCam(this, 0, 50, 0, 1000);
  cam.setMinimumDistance(2);
  cam.setMaximumDistance(400);

  pg.beginDraw();
    pg.background(0);

    for(int segY = 0; segY < panelYSegments; segY++) {
      for(int segX = 0; segX < panelXSegments; segX++) {
      
        pg.fill(random(100), random(100), random(100));
        pg.stroke(255);
        pg.noStroke();
//        pg.rect(segX*ledsPerPanelX, segY*ledsPerPanelY, ledsPerPanelX, ledsPerPanelY);
        
        pg.stroke(1);
        pg.fill(255);
        pg.textSize(10);
        pg.text(str(segX*panelYSegments + segY), segX*ledsPerPanelX + 1, segY*ledsPerPanelY + 50);
      }    
    }
    
  pg.endDraw();
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
  

  
  background(0);
//  translate(width / 2, height / 2);
//  rotateY(map(mouseX, 0, width, -PI, PI));
//  rotateZ(map(mouseY, 0, width, -PI, PI));
  scale(2);
  
  shape(panel,0,0);
}
