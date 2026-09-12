#include "src/Prediction.h"
#include <cmath>
#include <iostream>
int main() {
  Ball a{{0.0, 0.0}, {0.28, 0.0}, 0.18};
  Ball b{{0.95, 0.0}, {0.0, 0.0}, 0.0};
  Prediction::run(a, b, 1);
  const double separation = std::hypot(a.pos.x - b.pos.x, a.pos.y - b.pos.y);
  if (separation <= 1.0) return 2;
  if (std::abs(a.spin) > 1e-9 || std::abs(b.spin - 0.1782) > 1e-9) return 3;
  std::cout << "CPP_PREDICTION_PROBE_OK\n";
  return 0;
}
