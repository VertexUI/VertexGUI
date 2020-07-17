#version 330 core

layout (location = 0) in vec3 inVertexPos;

uniform vec2 translation;

out vec2 inTexCoords;
out vec3 inColor;

void main() {
    gl_Position = vec4(inVertexPos + vec3(translation, 0), 1.0);
    inTexCoords = vec2((inVertexPos.x + 1) / 2, (inVertexPos.y + 1) / 2);
    inColor = inVertexPos;
}