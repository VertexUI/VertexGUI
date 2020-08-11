#version 330 core

layout (location = 0) in vec2 vertexCoordinates;
layout (location = 1) in vec2 blobPosition;

uniform vec2 perspectiveMin;
uniform vec2 perspectiveMax;
uniform vec2 scaling;
uniform float radius;

void main() {
    vec2 size = perspectiveMax - perspectiveMin;
    vec2 perspectivePosition = (blobPosition + vertexCoordinates * radius - perspectiveMin) / size;
    gl_Position = vec4(((perspectivePosition - 0.5) * 2) * scaling, 1.0, 1.0);
}