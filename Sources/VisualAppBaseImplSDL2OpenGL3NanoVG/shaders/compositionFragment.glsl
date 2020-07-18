#version 330 core

in vec2 inTexCoords;
in vec3 inColor;

uniform sampler2D compositionTexture;

out vec4 FragColor;

void main() {
    //FragColor = vec4((gl_FragCoord.x + 1) / 2, (gl_FragCoord.y + 1) / 2, 0, 1.0);
    FragColor = texture(compositionTexture, inTexCoords).rgba;// +*/ vec4(gl_FragCoord.xy, 0, 1.0);
}