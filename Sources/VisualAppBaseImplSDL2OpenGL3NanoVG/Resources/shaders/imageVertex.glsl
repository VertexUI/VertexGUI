#version 330 core

layout (location = 0) in vec2 inPosition;
layout (location = 1) in vec2 inTexCoords;

out vec2 texCoords;

void main() {
  gl_Position = vec4(inPosition, 0, 1);
  texCoords = inTexCoords;
}