/* 
@pjs preload="material/me.jpg";
*/

PImage a;

void setup()
{
  a = loadImage("material/me.jpg");

  size(433,203);

  noStroke();

  background(255, 0);
  frameRate(60);

  smooth();

}



void draw()

{ 

  float pointillize = map(mouseX, 0, width, 10, 18);

  int draw_x_times = 10; 
  
  while ( draw_x_times > 0 ) {
  int x = int(random(a.width));

  int y = int(random(a.height));

  color pix = a.get(x, y);

  fill(pix, 126);

  ellipse(x, y, pointillize, pointillize);
  draw_x_times = draw_x_times -1;
  }
  
}
