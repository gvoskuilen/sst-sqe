

all:  stream.c
	gcc -fopenmp -static -DNTIMES=100 -DSTREAM_ARRAY_SIZE=256 -DVERBOSE -L ../pthread/m5threads -lpthread stream.c -o ompstream.x

notall:  stream.c
	gcc -fopenmp -static -DNTIMES=100 -DSTREAM_ARRAY_SIZE=$(ARRAY_SIZE) -DVERBOSE -L ./pthread/m5threads -lpthread stream.c -o stream.$(ARRAY_SIZE)

debug:
	gcc -DDEBUG -fopenmp -static -DNTIMES=100 -DSTREAM_ARRAY_SIZE=16384 -DVERBOSE -L ./pthread/m5threads -lpthread stream.c -o stream.16k

clean:
	rm -f ompstream.x *.o

