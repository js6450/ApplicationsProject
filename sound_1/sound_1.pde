import processing.video.*;

/**
 * This sketch demonstrates how to use the BandPass effect.<br />
 * Move the mouse left and right to change the frequency of the pass band.<br />
 * Move the mouse up and down to change the band width of the pass band.
 * <p>
 * For more information about Minim and additional features, visit http://code.compartmental.net/minim/
 */

import ddf.minim.*;
import ddf.minim.effects.*;
import ddf.minim.ugens.*;

Movie vid;

Minim minim;
AudioOutput output;
FilePlayer groove;
BandPass   bpf;

void setup()
{
  size(720, 640);
  frameRate(30);

  minim = new Minim(this);
  output = minim.getLineOut();
  output.setVolume(0.0);

  groove = new FilePlayer( minim.loadFileStream("audio.wav") );
  // make a band pass filter with a center frequency of 440 Hz and a bandwidth of 20 Hz
  // the third argument is the sample rate of the audio that will be filtered
  // it is required to correctly compute values used by the filter
  bpf = new BandPass(fq, 10, output.sampleRate());

  groove.patch( bpf ).patch( output );
  // start the file playing
  groove.loop();

  vid = new Movie(this, "video.mp4");

  vid.play();
}

float bw=2.0;
//float fq=440.0;
float fq=200.0;

int x = 0;

float volLevel = 0.0;
void draw()
{
  output.setVolume(volLevel);
  println("volume is at "+output.getVolume());
  if (volLevel<1) {
    audioSweep(volLevel);
  }
  x++;
  vid.volume(0);

  int fr = int(x/frameRate);
  println("Framerate: " + fr);
  if (fr == 10) {
    audioLeft();
  }
  if (fr == 20) {
    audioRight();
  }
  if (fr == 30) {
    audioM();
  }
  image(vid, 0, 0);

  if (fr>40) {
    bWidth();
  }

  if (fr>60) {
    freq();
  }

  //  if ( output.hasControl(Controller.BALANCE) )
  //  {
  //    float val = map(mouseX, 0, width, -1, 1);
  //    // if a balance control is not available, this will do nothing
  //    output.setBalance(val); 
  //    // if a balance control is not available this will report zero
  //    text("The current balance is " + output.getBalance() + ".", 5, 15);
  //  } else
  //  {
  //    text("This output doesn't have a balance control.", 5, 15);
  //  }
  //bw+=0.5; 
  //background(0);
  stroke(255);
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  for (int i = 0; i < output.bufferSize()-1; i++)
  {
    float x1 = map(i, 0, output.bufferSize(), 0, width);
    float x2 = map(i+1, 0, output.bufferSize(), 0, width);
    line(x1, height/4 - output.left.get(i)*50, x2, height/4 - output.left.get(i+1)*50);
    line(x1, 3*height/4 - output.right.get(i)*50, x2, 3*height/4 - output.right.get(i+1)*50);
  }
  // draw a rectangle to represent the pass band
  noStroke();
  fill(255, 0, 0, 60);
  rect(mouseX - bpf.getBandWidth()/20, 0, bpf.getBandWidth()/10, height);

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
}

//void mouseMoved()
//{
//  // map the mouse position to the range [100, 10000], an arbitrary range of passBand frequencies
//  float passBand = map(mouseX, 0, width, 10, 2000);
//  //float passBand = 20;
//  bpf.setFreq(passBand);
//  float bandWidth = map(mouseY, 0, height, 50, 500);
//  //float bandWidth=20;
//  bpf.setBandWidth(bw);
//  // prints the new values of the coefficients in the console
//  //bpf.printCoeff();
//    println("Passband: "+passBand+"\t bandWidth: " + bw);

//}

void mouseClicked() {
  bw+=10;
  bpf.setBandWidth(bw);

  println("BW: "+bw);
}
//void mousePressed(){
//  float passBand = 2400;
//  float bandWidth = 6400;
//  bpf.setFreq(passBand);
//  bpf.setBandWidth(bandWidth);
//}

void keyPressed() {
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

void audioLeft() {
  output.setBalance(-1); 
  println("balance is left");
}

void audioRight() {
  output.setBalance(1);
  println("balance is right");
}

void audioM() {
  output.setBalance(0);
  println("everything is balanced");
}

void audioSweep(float volLevel_) {
  volLevel = volLevel_;
  output.setVolume(volLevel);
  volLevel = volLevel + 0.05;
  println("volume: "+volLevel);
}

void bWidth() {

  if (bw<400) {
    bw+=0.02;
  }
  println("bWidth: "+ bw);
  bpf.setBandWidth(bw);
}

void freq() {
  if (fq<400) {
    fq+=0.1;
  }

  println("fq: "+fq);
}