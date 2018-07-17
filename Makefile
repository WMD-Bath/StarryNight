SRCs= src/mt19937ar-cok.c src/starrynight-config.c src/starrynight-main.c \
	  src/xorshift1024star.c src/starrynight-analysis.c \
	  src/starrynight-lattice.c src/starrynight-montecarlo-core.c  src/xorshift128plus.c

# default
all: starrynight

# Code compilation
starrynight: $(SRCs) 
	gcc -O4 -o starrynight src/starrynight-main.c -lm -lconfig

starrynight-openmp: ${SRCs} 
	gcc -O4 -lm -lconfig -fopenmp -o starrynight src/starrynight-main.c

starrynight-mac-openmp: ${SRCs}
	/usr/local/bin/gcc-4.8 -O4 -lm -lconfig -fopenmp -lgomp -o starrynight src/starrynight-main.c

profile: ${SRCs} 
	gcc -lm -lconfig -o starrynight src/starrynight-main.c -pg

debug: $(SRCs)
	gcc -g -O4 -lm -lconfig -o starrynight src/starrynight-main.c

test: # basic test for Travis
	./starrynight

# clean up run data
clean:
	rm starrynight *.pnm *.jpg *.gif *.avi *.svg 
	rm *.png 
	rm *.log 
	rm *.dat 
	rm *.xyz

# Imperial's CX1 cluster
cx1:
	    # Local version of libconfig, within starrynight directory
	    gcc -Llibconfig-1.5/lib -Ilibconfig-1.5/lib \
			-O4 -lm -o starrynight src/starrynight-main.c libconfig-1.5/lib/.libs/libconfig.a

# Intelsuite requires this in the shell for compile:
# module load intel-suite
cx1-icc: 
	icc -Llibconfig-1.5/lib -Ilibconfig-1.5/lib \
	-O4 -o starrynight src/starrynight-main.c libconfig-1.5/lib/.libs/libconfig.a -lm

# Make file magics to assist running jobs 
parallel: starrynight
	seq 0 10 1000 | parallel  ./starrynight {}  

superparallel: starrynight
	awk 'BEGIN{for (T=0;T<1000;T=T+20) { for (CageStrain=0.0;CageStrain<=5.0;CageStrain=CageStrain+1.0) printf ("%f %f\n",T,CageStrain); }}' \
		| parallel --colsep ' ' ./starrynight {1} {2}  > aggregate.dat

parallel-annamaria: starrynight
	seq 0.9 0.02 1.0 | caffeinate parallel ./starrynight {} | sort -k2 -g > variance.dat

parallel-CageStrain: starrynight
	seq 0 0.5 3.0 | caffeinate parallel ./starrynight {} > landau.dat

parallel-T: starrynight
	seq 75 75 600 | parallel ./starrynight {} > starrynight-parallel-T.log

