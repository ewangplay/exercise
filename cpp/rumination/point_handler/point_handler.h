#ifndef _POINT_HANDLER_H_
#define _POINT_HANDLER_H_

class Point
{
	public:
		Point(): xco(0), yco(0){}
		Point(int xval, int yval): xco(xval), yco(yval){}
		int x() const {return xco;}
		int y() const {return yco;}
		Point & x(int xval) {
			xco = xval;
			return *this;
		}
		Point & y(int yval) {
			yco = yval;
			return *this;
		}

	private:
		int xco;
		int yco;
};

class UPoint
{
	private:
		UPoint(): ref_count(1){}
		UPoint(int xval, int yval): pt(xval, yval), ref_count(1) {}
		UPoint(const Point & p): pt(p), ref_count(1) {}
		Point pt;
		int ref_count;
		friend class PointHandler;
};

class PointHandler
{
	public:
		PointHandler();
		PointHandler(int x, int y);
		PointHandler(const Point & pt);
		PointHandler(const PointHandler & ph);
		PointHandler & operator=(const PointHandler & ph);
		~PointHandler();
		int x() const;
		int y() const;
		PointHandler & x(int xval);
		PointHandler & y(int yval);

	private:
		UPoint * up;
};

#endif

