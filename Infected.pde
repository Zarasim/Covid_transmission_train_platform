class Infected extends Person {


  Infected(float x, float y, boolean _mask) {
    super(x, y, _mask);
    isInitialInfected = true;
    c = color(255, 0, 0);
  }

  void behaviours() {

    PVector seek  = super.seek();
    PVector avoidBoundary = super.avoidBoundary();
    PVector separate = separate();

    // apply all weighted forces here
    separate.mult(1.5);
    seek.mult(1.0);
    avoidBoundary.mult(3.0);
    
    sneeze();

    super.applyForce(seek);
    super.applyForce(avoidBoundary);
    super.applyForce(separate);
  }

  void sneeze() {

    if (random(1) < probSneeze) {
      PVector vec = new PVector(location.x,location.y);
      sneezeSpot.add(vec);
    };
    
    if(sneezeSpot.size() > 30){
      sneezeSpot.remove(1);
    }
  }


  PVector separate() {

    desiredseparation = r*3;
    float d = 0;
    PVector steer = new PVector(); 
    PVector sum = new PVector();
    int count = 0;

    //We have to keep track of how many people are too close.
    for (Person other : commuters) {

      d = PVector.dist(location, other.location);
      if ((d > 0) && (d < desiredseparation)) {

        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);
        // //Add all the vectors together and increment the count.
        sum.add(diff);
        count++;
      }
    }
    //We have to make sure we found at least one close vehicle. We don't want to bother doing anything 
    //if nothing is too close (not to mention we can't divide by zero!)
    if (count > 0) {
      sum.normalize();
      sum.mult(maxspeed);
      //Reynolds’s steering formula
      steer = PVector.sub(sum, velocity);
      steer.limit(maxforce*1.3);
    }
    return steer;
  }
}
