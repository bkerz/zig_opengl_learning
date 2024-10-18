#version 330 core
#extension GL_ARB_separate_shader_objects : enable

layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 texCoord;

out vec2 v_TexCoord;

void main() {
  gl_Position = vec4(aPos.x, aPos.y, 0, 1.0);
	v_TexCoord = texCoord;
}


