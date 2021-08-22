// Show that with a reserved ticket and uniform distribution the total number of infected people is reduced. //<>//
import java.util.Iterator;
import java.util.ArrayList;


int fps = 30;
ArrayList<Person> commuters;
ArrayList<PVector> sneezeSpot;

int nTargets = 4;
float offsetDoor_x;
PVector[] targets; 

int initialInfected = 0;
int newInfected = 0;

float probInitialInfected = 0.2;
float probMask = 0.2;
float probInfectionMask = 0.05;
float probInfectionNoMask = 0.2;
float probInfectionSneeze = 0.1;
float probSneeze = 0.01;

boolean isInitialInfected;    // If the person is initially infected 
boolean isNewInfected;    // If the person is new infected 
boolean mask;  // If the person is initially infected 

// Initial distribution of people on the platform: 0 for uniform, 1 for Gaussian 
boolean Gaussian = true;  
float sd = 70;

// Define location of boundary and of generation of commuters
float d;
float x_loc;
float y_loc;
float y_entrance;

boolean debug = true;

void setup() {

  size(800, 600);
  frameRate(fps); 

  d = height/40;
  y_entrance = height - d;
  // Initialisation with random assignment of masks and infected commuters
  sneezeSpot = new ArrayList<PVector>();
  commuters = new ArrayList<Person>(); 
  for (int i = 1; i <= 50; i++) {
    if (Gaussian) {
      x_loc = width/2 + randomGaussian()*110;
      y_loc = randomGaussian()*sd + (height/2);
      commuterGeneration(x_loc, y_loc);
    } else
      x_loc = random(-(width - 30*d), width - 30*d) + width/2;
    y_loc = randomGaussian()*sd + (height/2);
    commuterGeneration(x_loc, y_loc);
  }

  targets = new PVector[nTargets];
  offsetDoor_x =  width/(nTargets) - 100; 
  float distDoors = width/nTargets; 
  for (int i = 0; i < targets.length; i++) {
    targets[i] = new PVector(offsetDoor_x + i*distDoors, 1.5*d);
  }
}


void draw() {

  background(0);
  stroke(175);
  fill(255);
  rectMode(CENTER);
  rect(width/2, height/2, width-d*2, height-d*2);
  // display entrance doors
  if (frameCount/fps > 3.0) {
    displayDoors();
  }

  //display statistics
  statistics();

  // loop of people
  Iterator<Person> it = commuters.iterator();

  while (it.hasNext()) {
    Person p = it.next();
    p.behaviours();
    p.update();
    p.display();
    if (p.hasEntered()) {
      it.remove();
    }
  }


  // draw sneezeSpot
  for (int i=0; i < sneezeSpot.size(); i++) {
    fill(250, 0, 0);
    ellipse(sneezeSpot.get(i).x, sneezeSpot.get(i).y, 7, 7);
  }


  // generate new commuters every second from the middle at the bottom platform
  if (frameCount % fps == 0) {
    x_loc = width/2 + randomGaussian()*sd;
    commuterGeneration(x_loc, y_entrance);
  }


  saveFrame("Video_1/crowdGauss_####.png");
}


void commuterGeneration(float x_loc, float y_loc) {

  isNewInfected = false;
  mask = false;
  if (random(1) < probInitialInfected) {
    isNewInfected = true;
    initialInfected += 1;
  }
  if (random(1) < probMask) {
    mask = true;
  }

  if (isNewInfected) {
    commuters.add(new Infected(x_loc, y_loc, mask));
  } else {
    commuters.add(new Person(x_loc, y_loc, mask));
  }
}

void displayDoors() {
  stroke(255);
  rectMode(CENTER);
  for (int i = 0; i < targets.length; i++) {
    fill(255);
    rect(targets[i].x, targets[i].y, 40, 20);
    fill(0, 0, 255);
    ellipse(targets[i].x, targets[i].y, 5, 5);
  }
}

void statistics() {
  fill(0);
  String str_dist = Gaussian ? "Gaussian" : "Uniform";
  text("Distribution: " + str_dist, 30, height - 90);
  text("Time elapsed [s]: " + str(frameCount/fps), 30, height - 70);
  text("Initial infected commuters: " + str(initialInfected), 30, height - 50);
  text("Infected commuters: " + str(newInfected), 30, height - 30);
  rectMode(CENTER);
  stroke(255);
  strokeWeight(0);
  fill(100);
  rect(width/2, height-d/2, 500, d);
}
