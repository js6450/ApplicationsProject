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

    if (diaOffsetAmount > 0 && dia < 75) {
      diaOffsetAmount -= 0.001;
    }

    if (dia > 15) {
      diaOffset = sin(frameCount * diaSpeed) * (dia * 0.2);
    } else {
      diaOffset = 0;
    }

    if (dia > 20) {
      xOffset = random(-5, 5);
      yOffset = random(-5, 5);
    } else {
      xOffset = yOffset = 0;
    }
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
