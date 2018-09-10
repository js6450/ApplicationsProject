import processing.video.*;

Movie m;

int thresh = 260;
int threshMax = 127;
int step;
float sat = 0.01;

float a= 50;
float aSpeed;

float imgTint = 0;

boolean stepChanged = false;
boolean isDone = false;

int state = 0;

boolean stepFurther = true;
boolean threshFurther = true;
//boolean reduceDia = false;
boolean satStart = true;
//boolean endRandom = false;

ArrayList<Particle> p = new ArrayList<Particle>();

void setup() {
  //fullScreen();
  size(1280, 720);

  step = int(width / 2);
  aSpeed = random(0.001, 0.005);

  m = new Movie(this, "v1.MP4");
  m.play();

  noStroke();
  colorMode(HSB);

  background(0);
}


void draw() {
  //background(0);

  if (a > 0) {
    fill(0, 0, 0, 30);
    rect(0, 0, width, height);
  }

  if (m.available()) {
    m.read(); 

    m.loadPixels();

    if (thresh > threshMax) {
      changeThresh();
    } else {
      if (threshMax > 0 && threshFurther) {
        threshMax--;
      }
    }

    if (step > 5) {
      changeStep();
    } else {
      if (sat < 1 && satStart) {
        changeSat();
      }
    }

    if (stepChanged) {
      p = new ArrayList<Particle>();

      for (int y = 0; y < m.height; y += step) {
        for (int x = 0; x < m.width; x += step) {
          p.add(new Particle(x + step * 0.5, y + step * 0.5, step));
        }
      }

      stepChanged = false;
    }

    if (p.size() > 0) {
      int arrayIndex = 0;

      for (int y = 0; y < m.height; y += step) {
        for (int x = 0; x < m.width; x += step) {
          int index = (m.width - 1 - x) + y * m.width;
          float h = hue(m.pixels[index]);
          float b = brightness(m.pixels[index]);
          float s = saturation(m.pixels[index]);

          if (step > 5) {
            s = 0;
            if (b < thresh) {
              b = 0;
            }
          } else {
            s = s * sat;
          }

          if (a < 200 && step < 50) {
            a += aSpeed;
          }

          p.get(arrayIndex).updateColor(h, s, b, a);

          arrayIndex++;
        }
      }
    }
  }

  if (p.size() > 0 && a > 0) {
    //println("display with array size " + p.size());

    for (int i = 0; i < p.size(); i++) {
      Particle particle = p.get(i);
      particle.update();
      particle.display();
    }
  }

  if (isDone) {
    if (imgTint < 360) {
      imgTint++;
    }

    if (a > 0) {
      a -= aSpeed;
    }

    tint(255, imgTint);
    image(m, 0, 0);
  }

  // println("state: " + state);
}

int lastStepChange = 7000;
int stepDuration = 3000;

void changeStep() {

  if (millis() - lastStepChange > stepDuration) {
    //clear();

    if (step > 75 && state == 0) {
      step = int(step * 0.85);
    } else if (step <= 75 && step > 5 && stepFurther) {
      step--;
      //step -= 3;
    }

    stepChanged = true;

    lastStepChange = millis();
    stepDuration = int(random(2000, 5000));

    println("step: " + step);
  }
}


int lastThreshChange = 0;
int threshDuration = 500;
void changeThresh() {

  if (millis() - lastThreshChange > threshDuration) {
    //clear();

    thresh--;

    lastThreshChange = millis();
    threshDuration = int(random(500, 1000));

    println(thresh);
  }
}


int lastSatChange = 0;
int satDuration = 1500;
void changeSat() {

  if (millis() - lastSatChange > satDuration) {
    //clear();

    sat += random(0.01, 0.05);

    if (sat > 0.7) {
      isDone = true;
    }

    lastSatChange = millis();
    satDuration = int(random(1500, 2500));

   // println("sat: " + sat);
  }
}

void keyPressed() {
  if (key == '1') {
    stepFurther = true;
  }

  if (key == '2') {
    threshFurther = true;
  }

  if (key == '3') {
    satStart = true;
  }

  //if (key == '4') {
  //  reduceDia = true;
  //}

  //if (key == '5') {
  //  endRandom = true;
  //}
}
