//EXPERIMENTAL STUFF FROM HEREON DOWN

float spring = 0.01;
float gravity = 0.01;
float friction = -0.9;


void drawBalls() {
  for (Ball ball : balls) {
    fill(ball.c);
    ball.collide();
    ball.move();
    ball.display();  
  }
}

void setupBalls() {
  int counter = 0;
   for(int j = 0; j < states.size(); j++) {    
   for(int i= 0; i < states.get(j).districts.size(); i++) {   
     if(states.get(j).districts.get(i).district != null) {
       Float currentWinnerVotes = states.get(j).districts.get(i).candidates.get(states.get(j).districts.get(i).getTop2().get(0));
       color c = states.get(j).districts.get(i).districtColor;
       balls[counter] = new Ball(random(width),random(height), currentWinnerVotes/3000,i+j,c,balls);
       if(counter < 234) counter += 1;
     }
   }
  }
}

class Ball {
  
  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  int id;
  color c;
  Ball[] others;
 
  Ball(float xin, float yin, float din, int idin, color ballcolor, Ball[] oin) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    c = ballcolor;
    others = oin;
  } 
  
  void collide() {
    for (int i = id + 1; i < 235; i++) {
      float dx = others[i].x - x;
      float dy = others[i].y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].diameter/2 + diameter/2;
      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - others[i].x) * spring;
        float ay = (targetY - others[i].y) * spring;
        vx -= ax;
        vy -= ay;
        others[i].vx += ax;
        others[i].vy += ay;
      }
    }   
  }
  
  void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > width) {
      x = width - diameter/2;
      vx *= friction; 
    }
    else if (x - diameter/2 < 0) {
      x = diameter/2;
      vx *= friction;
    }
    if (y + diameter/2 > height) {
      y = height - diameter/2;
      vy *= friction; 
    } 
    else if (y - diameter/2 < 0) {
      y = diameter/2;
      vy *= friction;
    }
  }
  
  void display() {
    ellipse(x, y, diameter, diameter);
  }
}