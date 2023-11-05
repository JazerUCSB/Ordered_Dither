package orderedDither.library;

import processing.core.PApplet;
import processing.opengl.PShader;

public class Ordered_Dither {
    private PApplet parent;
    private PShader shader;
   

    public Ordered_Dither(PApplet parent) {
        this.parent = parent;
        shader = parent.loadShader("data/dither.glsl");
    }

    public void applyDither(int blockSize) {
    	shader.set("blockSize", blockSize);
        parent.shader(shader);
    }

    public void releaseDither() {
        parent.resetShader();
    }
}
