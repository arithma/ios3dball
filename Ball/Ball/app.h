#include "track.h"

@class AccelerometerHandler;

namespace track {
	using glutil::math::real;
	using glutil::math::vec3;
	using glutil::math::mat3;
	using glutil::math::mat4;

	class Application {
	public:
		GLuint programObject;
		GLuint mvpLoc;
		GLuint mvLoc;
		GLuint lightLoc;
		GLuint upLoc;
        
        mat4 rot;
        mat4 tran;
        mat4 model;
        mat4 view;
		mat4 proj;
		vec3 light;
		vec3 up;

		Geometry *geom;
        Sphere *sphere;
        
        
		Application(real width, real height, real c_deriv, real n_deriv);
        
        void accelerate(UIAcceleration* accel);

		void update(float dt);
		void setupProgramObject();
        
        AccelerometerHandler *handler;
        UIAccelerometer *accelerometer;
        UIAcceleration *lastAccel;
	};
}

@interface AccelerometerHandler : NSObject <UIAccelerometerDelegate>

@property (nonatomic, assign) track::Application* app;
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end
