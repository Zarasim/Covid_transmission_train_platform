class Person {

  PVector location;
  PVector velocity;
  PVector acceleration;
  PVector desired_target;

  float r; 
  float maxspeed;
  float maxforce;
  float desiredseparation;
  // default color
  color c; 

  boolean mask;
  boolean isInfected;
  boolean isInitialInfected = false;

  Person(float x, float y, boolean _mask) {
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);
    location = new PVector(x, y);
    r = 15.0;
    c = color(255, 255, 0);
    maxspeed = 1.3;
    maxforce = 0.5;

    mask = _mask;
  }


  void behaviours() {

    PVector seek  = seek();
    PVector avoidBoundary = avoidBoundary();
    PVector separate = separate();

    sneezeDetect();

    // apply all weighted forces here
    separate.mult(1.5);
    seek.mult(1.0);
    avoidBoundary.mult(3.0);

    // Train doors open after 3 seconds
    if (frameCount/fps > 3.0) {
      applyForce(seek);
    }
    applyForce(avoidBoundary);
    applyForce(separate);
  }


  PVector seek() {

    PVector desired = new PVector(0, 0);
    PVector desired_local;
    float d = 1000;
    float d_local;

    for (int i = 0; i < targets.length; i++) {
      desired_local = PVector.sub(targets[i], location);
      d_local = desired_local.mag();
      if (d_local < d) {
        desired = desired_local;
        d = d_local;
        desired_target = targets[i];
      }
    }

    desired.normalize();

    if (d < 100) {
      float m = map(d, 0, 100, 0, maxspeed);
      desired.mult(m);
    } else {

      desired.mult(maxspeed);
    }

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);   // limit also max force
    //applyForce(steer);
    return steer;
  }


  PVector avoidBoundary() {

    PVector desired =  new PVector();

    if (location.x < d) 
    {
      desired = new PVector(maxspeed, velocity.y);
    } else if (location.x > width -d) 
    {
      desired = new PVector(-maxspeed, velocity.y);
    }

    if (location.y > height - d) {
      desired = new PVector(velocity.x, - maxspeed);
    } else if ((location.y < d*1.3) && (location.x < 280)) {
      desired = new PVector(-abs(velocity.x), maxspeed/10);
    } else if ((location.y < d*1.3) && (location.x > 520)) {
      desired = new PVector(abs(velocity.x), maxspeed/10);
    } else if (location.y < d*1.3) {
      desired = new PVector(velocity.x, maxspeed);
    }

    if ((location.y < d*1.3) && (location.x < 80)) {
      desired = new PVector(abs(velocity.x), maxspeed/10);
    } else if ((location.y < d*1.3) && (location.x > 720)) {
      desired = new PVector(-abs(velocity.x), maxspeed/10);
    }

    if (desired.mag() != 0) {
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      //applyForce(steer);
    }

    return desired;
  }

  PVector separate() {

    desiredseparation = 3*r;
    float d = 0;
    PVector steer = new PVector(); 
    PVector sum = new PVector();
    int count = 0;

    //We have to keep track of how many people are too close.
    for (Person other : commuters) {

      d = PVector.dist(location, other.location);
      if ((d > 0) && (d < desiredseparation)) {
        
        // check every second but allow the commuters to separate if they are too close in the first 2 seconds
        if ((other.isInitialInfected) && (!isInfected) && (frameCount %fps == 0) && (frameCount/fps > 2)) {
          if (other.mask) {
            if (random(1) < probInfectionMask) {
              isInfected = true;
              newInfected += 1;
              c = color(255, 165, 0);
            } else {
              if (random(1) < probInfectionNoMask) {
                isInfected = true;
                newInfected += 1;
                c = color(255, 165, 0);
              }
            }
          }
        }
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);
        // //Add all the vectors together and increment the count.
        sum.add(diff);
        count++;
      }
    }
    if (count > 0) {
      sum.normalize();
      sum.mult(maxspeed);
      //Reynolds’s steering formula
      steer = PVector.sub(sum, velocity);
      steer.limit(maxforce*1.3);
    }

    return steer;
  }

  void applyForce(PVector force) {
    acceleration.add(force);
  }

  void sneezeDetect() {

    for (int i=0; i < sneezeSpot.size(); i++) {
      float d = PVector.dist(location, sneezeSpot.get(i));
      if ((d > 0) && (d < desiredseparation) && (!isInfected) && (!mask) && (frameCount %fps == 0) && (random(1) < probInfectionSneeze)) {
        isInfected = true;
        newInfected += 1;
        c = color(255, 165, 0);
      }
    }
  }



  // we need first to compute steering force 
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);    // limit the max speed
    location.add(velocity);
    acceleration.mult(0);
  }


  void display() {

    //Vehicle is a triangle pointing in the direction of velocity; 
    //since it is drawn pointing up, we rotate it an additional 90 degrees.
    float endline;
    endline = map(velocity.mag(), 0, maxspeed, 0, 2*r);

    float theta = velocity.heading(); 

    fill(c);
    // Mask color stroke 
    strokeWeight(6);
    if (mask) {
      stroke(0, 0, 255);
    } else {
      stroke(0, 0, 0);
    }
    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    //beginShape();
    //vertex(0, -r);
    //vertex(0, r);
    //vertex(r*4, 0);
    //endShape(CLOSE);
    ellipse(0, 0, r, r);

    if (debug) {
      stroke(0);
      strokeWeight(0.8);
      noFill();
      ellipse(0, 0, desiredseparation, desiredseparation);
    }

    // draw velocity vector
    stroke(0, 255, 0);
    strokeWeight(2);
    line(0, 0, endline, 0);
    popMatrix();
  }


  //Is the Particle alive or dead?
  boolean hasEntered() {
    float dist = PVector.dist(desired_target, location);
    if (dist < desired_target.y*1.2) {
      return true;
    } else {
      return false;
    }
  }
}
