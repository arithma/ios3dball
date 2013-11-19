#include <vector>
#include "math.h"

namespace track {

	using glutil::math::vec3;
	using glutil::math::real;
	using std::vector;

	// track control point
	struct CPoint{
		vec3 pos;
		vec3 normal;

		CPoint(vec3 const & p, vec3 const & n) :
		pos(p), normal(n) {}
	};

	typedef vector<CPoint> CPointVec;

	struct Vertex{
		vec3 pos;
		vec3 normal;
		real u, v;
	};

	typedef vector<Vertex> VertexVector;
	typedef vector<unsigned short> IndexVector;

	struct Geometry {
		Geometry(CPointVec const &, int, int);

		VertexVector vertices;
		IndexVector indices;
	};
    
    struct Sphere {
        Sphere(int lng, int lat);
        
        VertexVector vertices;
        IndexVector indices;
    };
}