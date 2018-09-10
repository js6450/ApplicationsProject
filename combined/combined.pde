import processing.video.*;

import ddf.minim.*;
import ddf.minim.effects.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput output;
FilePlayer groove;
BandPass bpf;

float bw=2.0;
//float fq=440.0;
float fq=200.0;
int x = 0;

float volLevel = 0.0;

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
boolean satStart = false;
//boolean endRandom = false;

ArrayList<Particle> p = new ArrayList<Particle>();

int videoAlpha = 255;
int titleAlpha = 0;

boolean startTitle = false;
boolean videoDone = false;

String title = "t h e   b i r t h i n g";

PGraphics titleLayer;

PFont font;

void setup() {
  //fullScreen();
  size(1280, 720);

  minim = new Minim(this);
  output = minim.getLineOut();
  //output.setVolume(0.0);

  groove = new FilePlayer( minim.loadFileStream("audio_edited.wav") );
  bpf = new BandPass(fq, 10, output.sampleRate());

  groove.patch( bpf ).patch( output );
  groove.play();

  step = int(width / 2);
  aSpeed = random(0.001, 0.005);

  m = new Movie(this, "v5.mp4");
  m.play();
  m.volume(0);

  titleLayer = createGraphics(width, height); 
  font = createFont("Futura", 50);

  noStroke();
  colorMode(HSB);

  background(0);
  noCursor();

  frameRate(30);

  audioLeft();
  
  //m.jump(450);
}


void draw() {
  //background(0);

  //output.setVolume(volLevel);
  //println("volume is at "+output.getVolume());
  //if (volLevel<1) {
  //  audioSweep(volLevel);
  //}
 // x++;

  //int fr = int(x/frameRate);
  //println("Framerate: " + fr);

  int fr = int(millis() / 1000);

  if (fr == 0) {
    audioLeft();
  }
  if (fr == 20) {
    audioRight();
  }
  if (fr == 40) {
    audioM();
  }

  if (fr > 60) {
    bWidth();
  }

  if (fr > 80) {
    freq();
  }

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

    if (step > 5 && !isDone) {
      changeStep();
    } else {
      satStart = true;
    }

    //change satStart to true at time stamp
    if (sat < 1 && satStart) {
      changeSat();
    }

    if (sat >= 1) {
      for (int i = p.size() - 1; i >= 0; i--) {
        p.remove(i);
      }
    }

    if (stepChanged) {
      p = new ArrayList<Particle>();

      for (int y = 0; y < m.height; y += step) {
        for (int x = 0; x < m.width; x += step) {
          float tempX = map(x + step * 0.5, 0, m.width, 0, width);
          float tempY = map(y + step * 0.5, 0, m.height, 0, height);
          p.add(new Particle(tempX, tempY, step));
        }
      }

      stepChanged = false;
    }

    if (p.size() > 0) {
      int arrayIndex = 0;

      for (int y = 0; y < m.height; y += step) {
        for (int x = 0; x < m.width; x += step) {
          int index = x + y * m.width;
          //int index = (m.width - 1 - x) + y * m.width;
          float h = hue(m.pixels[index]);
          float b = brightness(m.pixels[index]);
          float s = saturation(m.pixels[index]);

          if (step > 5 && !isDone) {
            s = 0;
            if (b < thresh) {
              b = 0;
            }
          } else {
            s = s * sat;
          }

          if (a < 150 && step < 50) {
            a += aSpeed;
          }

          p.get(arrayIndex).updateColor(h, s, b, a);

          arrayIndex++;
        }
      }
    }
  }

  if (m.time() >= m.duration() - 8) {
    if (!startTitle) {
      startTitle = true;
    }
    println("videoAlpha: " + videoAlpha);
    videoAlpha = int(map(m.time(), m.duration() - 8, m.duration(), 255, 0));
  }

  if (int(m.time()) >= int(m.duration())) {
    //println("video done");
    videoDone = true;
  }

  if (p.size() > 0 && a > 0) {
    //println("display with array size " + p.size());

    for (int i = 0; i < p.size(); i++) {
      Particle particle = p.get(i);
      particle.update();
      particle.display();
    }
  } else {
    //  println("no particles");
  }

  if (isDone) {
    if (!startTitle) {
      //if (imgTint < 360) {
      //  imgTint++;
      //}
      
      imgTint = int(map(sat, 0.5, 1.0, 0, 360));
      a = int(map(sat, 0.5, 1.0, 150, 0));
      
      //println("imgTint: " + imgTint + ", a: " + a);

      //if (a > 0) {
      //  a -= aSpeed;
      //}

      tint(255, imgTint);
    } else {
      tint(255, videoAlpha);
    }

    image(m, 0, 0, width, height);
  }

  // println(videoAlpha);

  titleLayer.beginDraw();
  titleLayer.background(0);
  titleLayer.fill(255, 255 - videoAlpha);
  titleLayer.textSize(50);
  titleLayer.textFont(font);
  titleLayer.text(title, titleLayer.width / 2 + textWidth(title) / 2, titleLayer.height / 2 + 17);
  titleLayer.endDraw();

  titleLayer.loadPixels();

  for (int i = 0; i < 300; i++) {
    //println("in loop");
    int randX = int(random(titleLayer.width / 2 + textWidth(title) / 2, titleLayer.width / 2 + textWidth(title) * 4.5 + 50));
    int randY = int(random(titleLayer.height / 2 - 50, titleLayer.height / 2 + 50));

    int index = randX + randY * titleLayer.width;

    if (brightness(titleLayer.pixels[index]) > 200) {
      // println("here");
      if (titleAlpha < 125) {
        fill(255, 255 - videoAlpha);
      } else {
        fill(255, 255 - titleAlpha);
      }
      float xOffset = random(-3, 3);
      float yOffset = random(-3, 3);
      ellipse(randX + xOffset, randY + yOffset, 10, 10);
    }
  }

  if (videoAlpha < 50 && videoDone) {
    if (titleAlpha < 255) {
      titleAlpha++;
    }

    tint(255, titleAlpha);
    image(titleLayer, 0, 0);
  }

  // println("state: " + state);

  if (keyPressed) {
    if (key=='l') {
      println("left");
      audioLeft();
    }
    if (key=='r') {
      println("right");
      audioRight();
    }
    if (key=='m') {
      audioM();
    }
  }

  pushStyle();
  fill(255);
  text(frameRate, width - 100, 50);
  text(m.time(), width - 100, 100);
  popStyle();
}

int lastStepChange = 5000;
int stepDuration = 2500;
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
    stepDuration = int(random(2500, 4000));

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

    //println(thresh);
  }
}

int lastSatChange = 0;
int satDuration = 2000;
void changeSat() {

  if (millis() - lastSatChange > satDuration) {
    //clear();

    sat += random(0.01, 0.05);

    if (sat > 0.5) {
      isDone = true;
      
      if(step < width / 2){
        step *= 2;
        
        stepChanged = true;
      }
    }

    lastSatChange = millis();
    satDuration = int(random(2000, 4000));

    println("sat: " + sat + ", step: " + step);
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

  if (key == CODED) {
    if (keyCode == UP) {
      fq+=5.0;
      println("fq: "+fq);
    } 
    if (keyCode == DOWN) {
      fq-=5.0;
      println("fq: "+fq);
    }
  } 

  bpf.setFreq(fq);
}
