#include <iostream.h>
#include "point_handler.h"

int main(int argc, char * argv[]) {
	PointHandler ph1(100, 200);
	PointHandler ph2(ph1);
	char c;
	
	ph2.x(200);

	cout << "The first point is: " << ph1.x() << "," << ph1.y() << endl;
	cout << "The second point is: " << ph2.x() << "," << ph2.y() << endl;
	
	cin >> c;
	
	return 0;
}
