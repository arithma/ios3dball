#include "track.h"
#include <assert.h>

namespace track{
	void bezier_interp(vec3 & p, vec3 & tang, vec3 p1, vec3 p2, vec3 p3, vec3 p4, real t){
		real s = 1 - t;

		p =
			p1 * s * s * s * 1 +
			p2 * s * s * t * 3 +
			p3 * s * t * t * 3 +
			p4 * t * t * t * 1;

		tang = 
			- 3 * s * s * p1
			+ 3 * (-2 * s * t + s * s) * p2
			+ 3 * (-1 * t * t + 2 * s * t) * p3
			+ 3 * t * t * p4;
	}

    Sphere::Sphere(int lat, int lng){
        for(int j = 0; j < lng; j++){
            for(int i = 0; i < lat; i++){
                real theta = 2 * M_PI * i / (lat - 1);
                real phi = M_PI * j / (lng - 1);
                
                vec3 pos(cos(theta)*sin(phi), sin(theta)*sin(phi), cos(phi));
                
                vec3 n(pos);
                
                Vertex v;
                v.pos = pos;
                v.normal = n;
                v.normal.x = .25;
                v.u = theta / 2 / M_PI;
                v.v = phi / M_PI;
                
                vertices.push_back(v);
            }
        }
        for(int i = 0; i < lat; i++){
            for(int j = 0; j < lng; j++){
                int i1 = (i+1)%lat;
                int j1 = (j+1)%lng;
                indices.push_back(j+i*lng);
                indices.push_back(j+i1*lng);
                indices.push_back(j1+i*lng);
                
                indices.push_back(j+i1*lng);
                indices.push_back(j1+i*lng);
                indices.push_back(j1+i1*lng);
            }
        }
    }
}
