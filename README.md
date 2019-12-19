# 简单的试一下使用cuda跑ac的速度

主要部分源码从这里fork的  
kaushiksk/boyer-moore-aho-corasick-in-cuda

CPU: AMD Ryzen 5 1600X  
GPU: Nvidia GTX 1060 3G  
数据: data.cpp生成的随机数据100M

| Core | File | Time |
| --- | --- | ---|
| CPU | ac-serial.cpp | 925ms |
| GPU | ac-global.cpp | 127.33 ms |
| GPU | ac-bits-shared.cpp | 29.36ms |
| GPU | ac-shared-bank-conflict-free.cpp | 8.70ms |

# boyer-moore-aho-corasick-in-cuda
Parallel Implementation of Boyer Moore and Aho-Corasick Algorithms in Cuda


# Reference
 - https://github.com/iassael/cuda-aho-corasick-wu-manber
