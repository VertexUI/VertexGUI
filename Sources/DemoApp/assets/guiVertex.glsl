#version 330 core

layout (location = 0) in vec3 inVertexPos;

out vec2 inTexCoords;

void main() {
    gl_Position = vec4(inVertexPos, 1.0);
    inTexCoords = vec2((inVertexPos.x + 1) / 2, (inVertexPos.y + 1) / 2);
}