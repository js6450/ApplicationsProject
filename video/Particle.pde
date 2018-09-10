class Particle {

  float x, y;
  float dia;
  float diaSpeed;
  float diaOffsetAmount;
  float h, s, b;
  float a;

  float xOffset, yOffset;
  float diaOffset;

  Particle(float _x, float _y, float _dia) {
    x = _x;
    y = _y;
    dia = _dia;
    diaSpeed = random(0.01, 0.05);
    diaOffsetAmount = random(0.1, 0.3);
  }

  void update() {

    if (diaOffsetAmount > 0 && dia < 50) {
      diaOffsetAmount -= 0.01;
    }

    //diaOffset = sin(frameCount * diaSpeed) * (dia * 0.2) + dia * 0.2;

    //xOffset = random(-dia * 0.5, dia * 0.5);
    //yOffset = random(-dia * 0.5, dia * 0.5);

    //xOffset = random(-8, 8);
    //yOffset = random(-8, 8);

    if (dia > 5) {
      diaOffset = sin(frameCount * diaSpeed) * (dia * 0.2) + dia * 0.2;
    } else {
      diaOffset = 0;
    }

    if (dia > 50) {
      xOffset = random(-25, 25);
      yOffset = random(-25, 25);
    } else {
      xOffset = random(-dia * 0.5, dia * 0.5);
      yOffset = random(-dia * 0.5, dia * 0.5);
    } 
    //else {
    //  xOffset = yOffset = 0;
    //}
  }

  void updateColor(float _h, float _s, float _b, float _a) {
    h = _h;
    s = _s;
    b = _b;
    a = _a;
  }

  void display() {
    if (b > 0) {
      fill(h, s, b, a);
      ellipse(x + xOffset, y + yOffset, dia + diaOffset, dia +diaOffset);
    }
  }
}
