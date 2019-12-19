#include<bits/stdc++.h>
using namespace std;
#include<ctime>


int main(){
	
	double n;
	char c;
	cin>>n;
	
	ofstream output_file("data.txt");

	srand(time(NULL));
	for(long long int i=0; i<(int) 1024*1024*n; i++) {
		c = rand();
		output_file<<c;
	}
	

}