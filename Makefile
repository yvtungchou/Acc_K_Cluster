CXX=g++ -m64 -march=native
CXXFLAGS=-I./common -Iobjs/ -O3 -Wall
ISPC=ispc
# note: requires AVX2
# disabling AVX2 FMA since it causes a difference in output compared to reference on Mandelbrot 
# ISPCFLAGS=-O3 --target=avx2-i32x8 --arch=x86-64 --opt=disable-fma --pic
ISPCFLAGS=-O3 --target=neon-i32x8 --arch=aarch64 --opt=disable-fma --pic

APP_NAME=kmeans
OBJDIR=objs
COMMONDIR=./common

PPM_CXX=$(COMMONDIR)/ppm.cpp
PPM_OBJ=$(addprefix $(OBJDIR)/, $(subst $(COMMONDIR)/,, $(PPM_CXX:.cpp=.o)))

TASKSYS_CXX=$(COMMONDIR)/tasksys.cpp
TASKSYS_LIB=-lpthread
TASKSYS_OBJ=$(addprefix $(OBJDIR)/, $(subst $(COMMONDIR)/,, $(TASKSYS_CXX:.cpp=.o)))

default: $(APP_NAME)

.PHONY: dirs clean

dirs:
		/bin/mkdir -p $(OBJDIR)/

clean:
		/bin/rm -rf $(OBJDIR) *.ppm *.log *.png *~ $(APP_NAME)

OBJS=$(OBJDIR)/main.o $(OBJDIR)/kmeansThread.o $(OBJDIR)/kmeans_ispc.o $(OBJDIR)/utils.o $(PPM_OBJ) $(TASKSYS_OBJ)

$(APP_NAME): dirs $(OBJS)
		$(CXX) $(CXXFLAGS) -o $@ $(OBJS) -lm $(TASKSYS_LIB)

$(OBJDIR)/%.o: %.cpp
		$(CXX) $< $(CXXFLAGS) -c -o $@

$(OBJDIR)/%.o: $(COMMONDIR)/%.cpp
	$(CXX) $< $(CXXFLAGS) -c -o $@

$(OBJDIR)/main.o: $(OBJDIR)/kmeans_ispc.h $(COMMONDIR)/CycleTimer.h

$(OBJDIR)/%_ispc.h $(OBJDIR)//%_ispc.o: %.ispc
		$(ISPC) $(ISPCFLAGS) $< -o $(OBJDIR)/$*_ispc.o -h $(OBJDIR)/$*_ispc.h