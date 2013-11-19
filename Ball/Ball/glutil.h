#ifndef GLUTIL_H
#define GLUTIL_H

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


namespace glutil{
	GLuint compileShaderFromFile( GLenum, const char *filename);
	GLuint compileShader ( GLenum type, const char *shaderSrc );
} //namespace glutil

#endif // GLUTIL_H