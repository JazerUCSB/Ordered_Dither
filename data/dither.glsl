#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 texOffset;
uniform int blockSize;


varying vec4 vertColor;
varying vec4 vertTexCoord;


vec3 rgb2hsv(vec3 c) {
  vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
  vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
  vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

  float d = q.x - min(q.w, q.y);
  float e = 1.0e-10;
  return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
void main(void) {

  vec2 uv = vertTexCoord.st;
 
  vec4 col = texture2D(texture, uv);
  
  ivec2 pix = textureSize(texture, 0);

  float lum = rgb2hsv(col.xyz).z;
  float closest = (lum < 0.5) ? 0.0 : 1.0;
  float second = 1.0 - closest;
  float dist = abs(closest - lum);

 
  float arr64[64] = float[64](0.0, 48.0, 12.0, 60.0, 3.0, 51.0, 15.0, 63.0, 32.0, 16.0, 44.0, 28.0, 35.0, 19.0, 47.0, 31.0, 8.0, 56.0, 4.0, 52.0, 11.0, 59.0, 7.0, 55.0, 40.0, 24.0, 36.0, 20.0, 43.0, 27.0, 39.0, 23.0, 2.0, 50.0, 14.0, 62.0, 1.0, 49.0, 13.0, 61.0, 34.0, 18.0, 46.0, 30.0, 33.0, 17.0, 45.0, 29.0, 10.0, 58.0, 6.0, 54.0, 9.0, 57.0, 5.0, 53.0, 42.0, 26.0, 38.0, 22.0, 41.0, 25.0, 37.0, 21.0);
  
  vec2 cellsize = (uv*pix)/float(blockSize);

  
  vec2 ind64 = mod(floor(cellsize), 8.0);
  int nux64 = int((ind64.x) + floor(ind64.y*8.0));
  float vall64 = arr64[nux64]/64.0;

  
  float d64 = 1.0 - vall64;
  float dith64 =  (dist < d64) ? closest : second;

  vec4 dith = vec4(dith64, dith64, dith64, 1.0)*col;
  gl_FragColor = dith ;
}



  
