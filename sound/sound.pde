import processing.sound.*;
import processing.video.*;

Movie vid;

FFT fft;
AudioIn in;
int bands = 512;
float[] spectrum = new float[bands];


void setup(){
  size(1280,720);
  vid = new Movie(this,"video.mp4");
  vid.play();
  
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  in.start();
  
  fft.input(in);
}

void draw(){
  image(vid,0,0,1280,720);
  
  fft.analyze(spectrum);

  for(int i = 0; i < bands; i++){
   line( i, height, i, height - spectrum[i]*height*5 );
  } 
}

void movieEvent(Movie m){
  m.read();
}

// Using sound example boilerplate 