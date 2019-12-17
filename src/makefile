CC = g++
NVCC = nvcc
CFLAGS = 

cppfile = ac-serial boyer-moore-serial data index-simulator
cufile = ac-bits-global ac-bits-texture ac-shared-bank-conflict-free ac-texture boyer-moore-shared-memory randac-bits-shared ac-global ac-shared boyer-moore-global-memory device-spec

all : clean do_cppfile do_cufile
do_cppfile :ac-serial boyer-moore-serial data index-simulator
do_cufile :ac-bits-global ac-bits-texture ac-shared-bank-conflict-free ac-texture boyer-moore-shared-memory randac-bits-shared ac-global ac-shared boyer-moore-global-memory device-spec

ac-serial :
	$(CC) -o ac-serial ac-serial.cpp
boyer-moore-serial :
	$(CC) -o boyer-moore-serial boyer-moore-serial.cpp 
data :
	$(CC) -o data data.cpp 

ac-bits-global :
	$(NVCC) -o ac-bits-global ac-bits-global.cpp
ac-bits-texture :
	$(NVCC) -o ac-bits-texture ac-bits-texture.cpp
ac-shared-bank-conflict-free :
	$(NVCC) -o ac-shared-bank-conflict-free ac-shared-bank-conflict-free.cpp
ac-texture :
	$(NVCC) -o ac-texture ac-texture.cpp
boyer-moore-shared-memory :
	$(NVCC) -o boyer-moore-shared-memory boyer-moore-shared-memory.cpp
randac-bits-shared :
	$(NVCC) -o randac-bits-shared randac-bits-shared.cpp
ac-global :
	$(NVCC) -o ac-global ac-global.cpp
ac-shared :
	$(NVCC) -o ac-shared ac-shared.cpp
boyer-moore-global-memory :
	$(NVCC) -o boyer-moore-global-memory boyer-moore-global-memory.cpp
device-spec :
	$(NVCC) -o device-spec device-spec.cpp

.PHONY : clean
clean :
	rm -rf $(cppfile) $(cufile)
	rm -rf data.txt
