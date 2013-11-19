#include "app.h"
#include "glutil.h"
#include <iostream>
#include <assert.h>

using namespace glutil;
using namespace glutil::math;

@implementation AccelerometerHandler
@synthesize app = _app;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    _app->accelerate(acceleration);
}
@end;

namespace track{

	using std::ostream;
	using std::endl;
	using std::cout;

	using glutil::math::PI;
	using glutil::math::real;
	using glutil::math::vec3;
	using glutil::math::vec4;
	using glutil::math::mat3;
	using glutil::math::mat4;
    
    const int VERTEX_POS_INDX = 0;
    const int VERTEX_NORMAL_INDX = 2;
    const int VERTEX_TEXCOORD_INDX = 1;

	ostream & operator << (ostream & o, vec3 const & v){
		return o << "[ " << v.x << ", " << v.y << ", " << v.z << " ]";
	}

	ostream & operator << (ostream & o, vec4 const & v){
		return o << "[ " << v.x << ", " << v.y << ", " << v.z << ", " << v.w << " ]";
	}

	ostream & operator << (ostream & o, mat3 const & m){
		return o << m.x << endl << m.y << endl << m.z << endl;
	}

	ostream & operator << (ostream & o, mat4 const & m){
		return o << m.x << endl << m.y << endl << m.z << endl << m.w << endl;
	}

	inline real random(){
		return rand()%1000/1000.0f;
	}

	inline vec3 random_v(){
		return vec3(random()*2-1, random()*2-1, random()*2-1);
	}

	Application::Application(real width, real height, real c_deriv, real n_deriv) :
        model(1)
    {
        handler = [AccelerometerHandler new];
        handler.app = this;
        
        accelerometer = [UIAccelerometer sharedAccelerometer];
        accelerometer.delegate = handler;
		setupProgramObject();

		light.z = -1;
		light.x = -1;
		up.z = 1;
		up.y = 1;
		up /= up.length();

		CPointVec controls;
		vec3 pt(5.f, 0.f, random() * 2);
		vec3 n = vec3(0.f, 0.f, 1.f);
		vec3 derv;

		for(int i = 1; i < 6; i++){
			real angle = PI * 2 * i / 6;
			vec3 npt(cos(angle) * 5, sin(angle) * 5, random() * 5);

			controls.push_back(CPoint(pt, n));

			n += random_v() * n_deriv;
			n /= n.length();
			controls.push_back(CPoint(pt+derv, n));

			n += random_v() * n_deriv;
			n /= n.length();
			derv = (npt - pt) * c_deriv + random_v() * .3f;
			controls.push_back(CPoint(npt-derv, n));

			n += random_v() * n_deriv;
			n /= n.length();
			controls.push_back(CPoint(npt, n));

			pt = npt;
		}

		{
			vec3 npt = controls[0].pos;
			controls.push_back(CPoint(pt, n));

			n += random_v() * n_deriv;
			n /= n.length();
			controls.push_back(CPoint(pt+derv, n));

			n += random_v() * n_deriv;
			n /= n.length();
			derv = (npt - pt) * c_deriv + random_v() * .3f;
			controls.push_back(CPoint(npt-derv, n));

			n = controls[0].normal;
			controls.push_back(CPoint(npt, n));

			controls[1].pos = npt + derv;
		}

        sphere = new Sphere(50, 50);
        
        const int VERTEX_POS_SIZE = 3;
        const int VERTEX_NORMAL_SIZE = 3;
        const int VERTEX_TEXCOORD_SIZE = 2;
        
		GLuint vbo, ibo;
		glGenBuffers(1, &vbo);
		glBindBuffer(GL_ARRAY_BUFFER, vbo);
		glBufferData(GL_ARRAY_BUFFER, sphere->vertices.size()*sizeof(Vertex), &sphere->vertices[0], GL_STATIC_DRAW);
        
        glGenBuffers(1, &ibo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sphere->indices.size()*sizeof(unsigned short), &sphere->indices[0], GL_STATIC_DRAW);
        
		glEnableVertexAttribArray ( VERTEX_POS_INDX );
		glEnableVertexAttribArray ( VERTEX_NORMAL_INDX );
		glEnableVertexAttribArray ( VERTEX_TEXCOORD_INDX );
        
        int offset = 0;
        Vertex *p = 0;
        
        cout << (long)&p->pos << endl;
        cout << (long)&p->normal << endl;
        cout << (long)&p->u << endl;
        cout << sizeof(Vertex) << endl;
        
		glVertexAttribPointer ( VERTEX_POS_INDX, VERTEX_POS_SIZE, GL_FLOAT, GL_FALSE, sizeof(Vertex), &p->pos );
        offset += VERTEX_POS_SIZE * sizeof(real);
        
		glVertexAttribPointer ( VERTEX_NORMAL_INDX, VERTEX_NORMAL_SIZE, GL_FLOAT, GL_FALSE, sizeof(Vertex), &p->normal );
        offset += VERTEX_NORMAL_SIZE * sizeof(real);
        
		glVertexAttribPointer ( VERTEX_TEXCOORD_INDX, VERTEX_TEXCOORD_SIZE, GL_FLOAT, GL_FALSE, sizeof(Vertex), &p->u );
        offset += VERTEX_TEXCOORD_SIZE * sizeof(real);
        
		proj =
			perspective(
				60.f/180.f*PI,
				(real) width / height,
				.1f,
				100.f
			);

		view =
			::view(
				+vec3(0, 0, 10),
				+vec3(0, 1, 0),
				+vec3(0, 0, -10)
			);

		vec4 up4 = view * vec4(up, 0);
		vec4 light4 = view * vec4(light, 0);

		glUniform3fv(lightLoc, 1, &light4.x);
		glUniform3fv(upLoc, 1, &up4.x);

		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LESS);

		glFrontFace(GL_CCW);
		glCullFace(GL_BACK);
	}
    
    void Application::accelerate(UIAcceleration *accel)
    {
        lastAccel = accel;
    }

	void Application::update(float dt){
        UIAcceleration * accel = lastAccel;
        vec3 acc(accel.y, accel.x, 0);
//        acc = -acc;
        
        vec3 rotAxis = vec3(-acc.y, acc.x, 0);
        if(rotAxis.length()>0){
            vec3 normal = rotAxis / rotAxis.length();
            const real speed = .5;
            rot =  mat4(1) * rotation(speed * rotAxis.length(), normal) * rot;
            tran *= translation(vec3(acc.x, acc.y, 0)*speed);            
            model = tran * rot;
        }
        rotAxis /= rotAxis.length();
        mat4 modelview = view * model;
		mat4 mvp = proj * modelview;
		glUniformMatrix4fv(mvLoc, 1, GL_FALSE, &modelview.x.x);
		glUniformMatrix4fv(mvpLoc, 1, GL_FALSE, &mvp.x.x);
		glDrawElements(GL_TRIANGLE_STRIP, sphere->indices.size(), GL_UNSIGNED_SHORT, 0);
	}

	void Application::setupProgramObject(){
		GLuint vertexShader;
		GLuint fragmentShader;
		GLint linked;

        NSString *vertPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@"vsh"];
        NSString *fragPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@"fsh"];
		vertexShader = compileShaderFromFile (GL_VERTEX_SHADER, vertPath.UTF8String);
		fragmentShader = compileShaderFromFile (GL_FRAGMENT_SHADER, fragPath.UTF8String);

		programObject = glCreateProgram ( );

		assert ( programObject );

		glAttachShader ( programObject, vertexShader );
		glAttachShader ( programObject, fragmentShader );
        
		glBindAttribLocation ( programObject, VERTEX_POS_INDX, "a_position" );
        glBindAttribLocation ( programObject, VERTEX_NORMAL_INDX, "a_normal" );
		glBindAttribLocation ( programObject, VERTEX_TEXCOORD_INDX, "a_coord" );

		glLinkProgram ( programObject );

		glGetProgramiv ( programObject, GL_LINK_STATUS, &linked );

		assert(linked);

		glUseProgram ( programObject );
        
		mvpLoc = glGetUniformLocation( programObject, "u_mvp" );
		mvLoc = glGetUniformLocation( programObject, "u_mv" );
		upLoc = glGetUniformLocation( programObject, "u_up" );
		lightLoc = glGetUniformLocation( programObject, "u_light" );
	}
}