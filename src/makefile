CC = g++
NVCC = nvcc
CFLAGS = 

cppfile = ac-serial boyer-moore-serial data index-simulator
cufile = ac-bits-global ac-bits-shared ac-bits-texture ac-shared-bank-conflict-free ac-texture boyer-moore-shared-memoryac-global ac-shared boyer-moore-global-memory device-spec

all : do_cppfile do_cufile
do_cppfile :ac-serial boyer-moore-serial data index-simulator
do_cufile :ac-bits-global ac-bits-shared ac-bits-texture ac-shared-bank-conflict-free ac-texture boyer-moore-shared-memory ac-global ac-shared boyer-moore-global-memory device-spec

ac-serial :
	$(CC) -o ac-serial ac-serial.cpp
boyer-moore-serial :
	$(CC) -o boyer-moore-serial boyer-moore-serial.cpp 
data :
	$(CC) -o data data.cpp 
 index-simulator:
	$(CC) -o index-simulator index-simulator.cpp 

ac-bits-global :
	$(NVCC) -o ac-bits-global ac-bits-global.cu
ac-bits-shared:
	$(NVCC) -o ac-bits-shared ac-bits-shared.cu
ac-bits-texture :
	$(NVCC) -o ac-bits-texture ac-bits-texture.cu
ac-shared-bank-conflict-free :
	$(NVCC) -o ac-shared-bank-conflict-free ac-shared-bank-conflict-free.cu
ac-texture :
	$(NVCC) -o ac-texture ac-texture.cu
boyer-moore-shared-memory :
	$(NVCC) -o boyer-moore-shared-memory boyer-moore-shared-memory.cu
ac-global :
	$(NVCC) -o ac-global ac-global.cu
ac-shared :
	$(NVCC) -o ac-shared ac-shared.cu
boyer-moore-global-memory :
	$(NVCC) -o boyer-moore-global-memory boyer-moore-global-memory.cu
device-spec :
	$(NVCC) -o device-spec device-spec.cu

.PHONY : clean
clean :
	rm -rf $(cppfile) $(cufile)
	rm -rf data.txt
