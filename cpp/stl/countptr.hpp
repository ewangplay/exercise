#ifndef _COUNT_PTR_HPP_
#define _COUNT_PTR_HPP_

template <typename T>
class CountedPtr {
    private:
        T* ptr;         //pointer to the shared object
        long * p_count; //pointer to the reference counted

    public:
        //constructor
        explicit CountedPtr(T* p = 0) : ptr(p), p_count(new long(1)) {}

        //copy constructor
        CountedPtr(const CountedPtr<T>& v) throw() : ptr(v.ptr), p_count(v.p_count) {
            ++*p_count;
        }

        //assignment
        CountedPtr<T>& operator=(const CountedPtr<T>& v) throw() {
            if (this != &v) {
                despose();
                ptr = v.ptr;
                p_count = v.p_count;
                ++*p_count;
            }
            return *this;
        }

        //destructor
        ~CountedPtr() throw() {
            despose();
        }

        //access the value to which the pointer refers
        T& operator*() const throw() {
            return *ptr;
        }

        T* operator->() const throw() {
            return ptr;
        }

    private:
        void despose() {
            if (--*p_count == 0) {
                delete ptr;
                delete p_count;
            }
        }
};

#endif  //_COUNT_PTR_HPP_
