#version 330 core

uniform vec4 color;

out vec4 FragmentColor;

void main() {
    FragmentColor = color;
}