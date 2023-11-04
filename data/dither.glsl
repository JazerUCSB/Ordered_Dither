//#version 150 

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform int windowX;
uniform int windowY;
uniform float blockSize;


varying vec4 vertColor;
varying vec4 vertTexCoord;

float fxaaLuma(vec4 c) {
  return dot(c.rgb, vec3(0.2989, 0.5870, 0.1140));
}
vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
void main(void) {
  // Grouping texcoord variables in order to make it work in the GMA 950. See post #13
  // in this thread:
  // http://www.idevgames.com/forums/thread-3467.html
  vec2 tc0 = vertTexCoord.st + vec2(-texOffset.s, -texOffset.t);
  vec2 tc1 = vertTexCoord.st + vec2(         0.0, -texOffset.t);
  vec2 tc2 = vertTexCoord.st + vec2(+texOffset.s, -texOffset.t);
  vec2 tc3 = vertTexCoord.st + vec2(-texOffset.s,          0.0);
  vec2 tc4 = vertTexCoord.st + vec2(         0.0,          0.0);
  vec2 tc5 = vertTexCoord.st + vec2(+texOffset.s,          0.0);
  vec2 tc6 = vertTexCoord.st + vec2(-texOffset.s, +texOffset.t);
  vec2 tc7 = vertTexCoord.st + vec2(         0.0, +texOffset.t);
  vec2 tc8 = vertTexCoord.st + vec2(+texOffset.s, +texOffset.t);
  
  vec4 col0 = texture2D(texture, tc0);
  vec4 col1 = texture2D(texture, tc1);
  vec4 col2 = texture2D(texture, tc2);
  vec4 col3 = texture2D(texture, tc3);
  vec4 col4 = texture2D(texture, tc4);
  vec4 col5 = texture2D(texture, tc5);
  vec4 col6 = texture2D(texture, tc6);
  vec4 col7 = texture2D(texture, tc7);
  vec4 col8 = texture2D(texture, tc8);

  vec4 outline = 8.0 * col4 - (col0 + col1 + col2 + col3 + col5 + col6 + col7 + col8); 
  vec2 uv = vertTexCoord.st;

  float lum = rgb2hsv(col4.xyz).z;
  float closest = (lum < 0.5) ? 0.0 : 1.0;
  float second = 1.0 - closest;
  float dist = abs(closest - lum);

  //float arr16[16] = float[16](0.0, 12.0, 3.0, 15.0, 8.0, 4.0, 11.0, 7.0, 2.0, 14.0, 1.0, 13.0, 10.0, 6.0, 9.0, 5.0);
  float arr64[64] = float[64](0.0, 48.0, 12.0, 60.0, 3.0, 51.0, 15.0, 63.0, 32.0, 16.0, 44.0, 28.0, 35.0, 19.0, 47.0, 31.0, 8.0, 56.0, 4.0, 52.0, 11.0, 59.0, 7.0, 55.0, 40.0, 24.0, 36.0, 20.0, 43.0, 27.0, 39.0, 23.0, 2.0, 50.0, 14.0, 62.0, 1.0, 49.0, 13.0, 61.0, 34.0, 18.0, 46.0, 30.0, 33.0, 17.0, 45.0, 29.0, 10.0, 58.0, 6.0, 54.0, 9.0, 57.0, 5.0, 53.0, 42.0, 26.0, 38.0, 22.0, 41.0, 25.0, 37.0, 21.0);
  
  vec2 wind = vec2(windowX, windowY);
  vec2 cellsize = (uv*wind)/blockSize;

  // vec2 ind16 = mod(floor(cellsize), 4.0);
  // int nux16 = int((ind16.x) + floor(ind16.y*4.0));
  // float vall16 = arr16[nux16]/16.0;

  vec2 ind64 = mod(floor(cellsize), 8.0);
  int nux64 = int((ind64.x) + floor(ind64.y*8.0));
  float vall64 = arr64[nux64]/64.0;

  
  // float d16 = 1.0 - vall16;  
  // float dith16 = (dist < d16) ? closest : second;

  float d64 = 1.0 - vall64;
  float dith64 =  (dist < d64) ? closest : second;

  vec4 dith = vec4(dith64, dith64, dith64, 1.0)*col4;
  gl_FragColor = dith + outline;
}



  
