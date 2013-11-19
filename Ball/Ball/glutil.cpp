#include "glutil.h"
#include <iostream>
#include <fstream>
#include <assert.h>
using std::cout;
using std::endl;

namespace glutil{
	GLuint compileShaderFromFile( GLenum type, const char *filename){
		char * source;
		{
			// Use file io to load the code of the shader.
			std::ifstream fp( filename , std::ios_base::binary );
			assert(!fp.fail());

			fp.seekg( 0, std::ios_base::end );
			long const len = fp.tellg();
			fp.seekg( 0, std::ios_base::beg );

			source = new char[len+1];
			fp.read(source, sizeof(char)*len);
			source[len] = NULL;
		}
		return compileShader(type, source);
	}

	GLuint compileShader ( GLenum type, const char *shaderSrc ){
		GLuint shader;
		GLint compiled;

		// Create the shader object
		shader = glCreateShader ( type );

		assert(shader != 0);

		// Load the shader source
		glShaderSource ( shader, 1, &shaderSrc, NULL );

		// Compile the shader
		glCompileShader ( shader );

		// Check the compile status
		glGetShaderiv ( shader, GL_COMPILE_STATUS, &compiled );

		if ( !compiled ) 
		{
			GLint infoLen = 0;

			glGetShaderiv ( shader, GL_INFO_LOG_LENGTH, &infoLen );

			if ( infoLen > 1 )
			{
				char* infoLog = new char[infoLen];

				glGetShaderInfoLog ( shader, infoLen, NULL, infoLog );
				cout <<"Error compiling shader:\n" << infoLog << endl;

				delete [] infoLog;
			}
		}
		assert(compiled);

		return shader;
	}
}