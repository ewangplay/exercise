#include "point_handler.h"


PointHandler::PointHandler(): up(new UPoint) {
}

PointHandler::PointHandler(int x, int y): up(new UPoint(x, y)) {
}

PointHandler::PointHandler(const Point & pt): up(new UPoint(pt)) {
}

PointHandler::PointHandler(const PointHandler & ph) {
	ph.up->ref_count++;
	up = ph.up;
}

PointHandler & PointHandler::operator=(const PointHandler & ph) {
	ph.up->ref_count++;
	if(--up->ref_count == 0) {
		delete up;
	}
	up = ph.up;
	return *this;
}

PointHandler::~PointHandler() {
	if(--up->ref_count == 0) {
		delete up;
	}
}

int PointHandler::x() const {
	return up->pt.x();
}

int PointHandler::y() const {
	return up->pt.y();
}

PointHandler & PointHandler::x(int xval) {
	if(up->ref_count != 1) {
		--up->ref_count;
		up = new UPoint(up->pt);
	}
	up->pt.x(xval);
	return *this;
}

PointHandler & PointHandler::y(int yval) {
	if(up->ref_count != 1) {
		--up->ref_count;
		up = new UPoint(up->pt);
	}
	up->pt.y(yval);
	return *this;
}


