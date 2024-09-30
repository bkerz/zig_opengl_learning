#version 330 core
#extension GL_ARB_separate_shader_objects : enable

layout (location = 0) in vec3 aPos;
out vec4 FragColor;
void main() {
  FragColor = vec4(0.8f, 0.3f, 0.02f,1.0f);
}
