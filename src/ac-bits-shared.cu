#include "project-header-bits.h"

string patterns[]={"ATC","GTG","GTC","ATG","CAA","ATT"};

texture<int, cudaTextureType2D> tex_go_to_function;
texture<unsigned int, cudaTextureType1D> tex_failure_function;
texture<unsigned int, cudaTextureType1D> tex_output_function;

__global__ void shared_kernel1 ( unsigned char *d_text, unsigned int *d_out, int m, int n, int p_size, int alphabet, int numBlocks, int sharedMemSize ) {

	//int idx = blockIdx.x * blockDim.x + threadIdx.x;
	
	int r, s;
	
	int i, j, column;
	
	int charactersPerThread = sharedMemSize / blockDim.x;
	
	int startThread = charactersPerThread * threadIdx.x;
	int stopThread = startThread + charactersPerThread + m - 1;

	//Define space in shared memory
	extern __shared__ unsigned char s_array[];
	
	for ( int globalMemIndex = blockIdx.x * sharedMemSize; globalMemIndex < n; globalMemIndex += numBlocks * sharedMemSize ) {
	
		/*if ( threadIdx.x == 0 )
			for ( i = globalMemIndex, j = 0; ( j < sharedMemSize + m - 1 && i < n ); i++, j++ )
				s_array[j] = d_text[i];
		*/
		
		for ( i = globalMemIndex + threadIdx.x, j = 0 + threadIdx.x; ( j < sharedMemSize + m - 1 && i < n ); i+=blockDim.x, j+=blockDim.x )
			s_array[j] = d_text[i];
			
		__syncthreads();
		
		r = 0;
		
		for ( column = startThread; ( column < stopThread && globalMemIndex + column < n ); column++ ) {
		
			while ( ( s = tex2D ( tex_go_to_function, s_array[column], r ) ) == -1 )
				r = tex1Dfetch ( tex_failure_function, r );
			r = s;
			
			d_out[globalMemIndex + column] += tex1Dfetch ( tex_output_function, r );
		}
		
		__syncthreads();
	}
}


void shared1 ( int m, unsigned char *text, int n, int p_size, int alphabet, int *go_to_function, unsigned int *failure_function, unsigned int *output_function ) {

	//Pointer for device memory
	int *d_go_to_function;
	unsigned int *d_failure_function, *d_output_function, *d_out;
	
	unsigned char *d_text;

	size_t pitch;
	
	int numBlocks = 24, numThreadsPerBlock = 1024, sharedMemSize = 16384;
	dim3 dimGrid ( numBlocks );
	dim3 dimBlock ( numThreadsPerBlock );
	
	if ( n < numBlocks * numThreadsPerBlock * m ) {
		printf("The text size is too small\n");
		exit(1);
	}
	
	//Allocate host memory for results array
	unsigned int *h_out = ( unsigned int * ) malloc ( n * sizeof ( unsigned int ) );
	memset ( h_out, 0, n * sizeof ( unsigned int ) );
	
	//Allocate 1D device memory
	checkCudaErrors ( cudaMalloc ( ( void** ) &d_text, n * sizeof ( unsigned char ) ) );
	checkCudaErrors ( cudaMalloc ( ( void** ) &d_failure_function, ( m * p_size + 1 ) * sizeof ( unsigned int ) ) );
	checkCudaErrors ( cudaMalloc ( ( void** ) &d_output_function, ( m * p_size + 1 ) * sizeof ( unsigned int ) ) );
	checkCudaErrors ( cudaMalloc ( ( void** ) &d_out, n * sizeof ( unsigned int ) ) );
	
	//Allocate 2D device memory
	checkCudaErrors ( cudaMallocPitch ( &d_go_to_function, &pitch, alphabet * sizeof ( int ), ( m * p_size + 1 ) ) );
	
	//Copy 1D host memory to device
	checkCudaErrors ( cudaMemcpy ( d_text, text, n * sizeof ( unsigned char ), cudaMemcpyHostToDevice ) );
	checkCudaErrors ( cudaMemcpy ( d_failure_function, failure_function, ( m * p_size + 1 ) * sizeof ( unsigned int ), cudaMemcpyHostToDevice ) );
	checkCudaErrors ( cudaMemcpy ( d_output_function, output_function, ( m * p_size + 1 ) * sizeof ( unsigned int ), cudaMemcpyHostToDevice ) );
	checkCudaErrors ( cudaMemcpy ( d_out, h_out, n * sizeof ( unsigned int ), cudaMemcpyHostToDevice ) );
	
	//Copy 2D host memory to device
	checkCudaErrors ( cudaMemcpy2D ( d_go_to_function, pitch, go_to_function, alphabet * sizeof ( int ), alphabet * sizeof ( int ), ( m * p_size + 1 ), cudaMemcpyHostToDevice ) );
	
	//Bind the preprocessing tables to the texture cache
	cudaChannelFormatDesc desc = cudaCreateChannelDesc<int>();
	checkCudaErrors ( cudaBindTexture2D ( 0, tex_go_to_function, d_go_to_function, desc, alphabet, m * p_size + 1, pitch ) );
	checkCudaErrors ( cudaBindTexture ( 0, tex_failure_function, d_failure_function, ( m * p_size + 1 ) * sizeof ( unsigned int ) ) );
	checkCudaErrors ( cudaBindTexture ( 0, tex_output_function, d_output_function, ( m * p_size + 1 ) * sizeof ( unsigned int ) ) );
	
	//Create timer
	cudaEvent_t start, stop;

	float time;

	//Create the timer events
	cudaEventCreate ( &start );
	cudaEventCreate ( &stop );
	
	//Start the event clock	
	cudaEventRecord ( start, 0 );
	
	//Executing kernel in the device
	shared_kernel1<<<dimGrid, dimBlock, sharedMemSize + m - 1>>>( d_text, d_out, m, n, p_size, alphabet, numBlocks, sharedMemSize );
	checkCUDAError("kernel invocation");
	
	cudaEventRecord ( stop, 0 );

	cudaEventSynchronize ( stop );
	
	cudaEventElapsedTime ( &time, start, stop );
	
	cudaEventDestroy ( start );
	cudaEventDestroy ( stop );

	//Get back the results from the device
	cudaMemcpy ( h_out, d_out, n * sizeof ( unsigned int ), cudaMemcpyDeviceToHost );
	   
  	//Look at the results
  	int i, matches = 0;
  	vector < vector<int> > indices;
  	for(int i=0; i<D; i++)
  	{
  		vector <int> row;
  		indices.push_back(row);
  	}
  	
  	for ( i = 0; i < n; i++ )
  	{
  		int count = 0;
  		if(h_out[i] == 0) continue;
  		for (int j = 0; j < D; ++j)
                {
                    if (h_out[i] & (1 << j))
                    {
                       // cout << "Word " << arr[j] << " appears from "
                        //    << i - arr[j].size() + 1 << " to " << i << endl;
                        //cout<<h_out[i]<<" ";
                        indices[j].push_back(i - M + 1);
                        count++;
                    }
                }
  		matches += count;
  	}
  	
  	
	printf ("Shared Memory Kernel 1 matches \t%i\t time \t%fms\n", matches, time);

	for(int i=0; i<D; i++){
		ofstream outputfile(patterns[i] + ".txt");
		cout<<indices[i].size()<<" ";
		for(int j=0;j<indices[i].size();j++)
        	outputfile<<indices[i][j]<<"\n";
	}

	printf("Pattern occurences written to individual files.");
	
	cudaUnbindTexture ( tex_go_to_function );
	cudaUnbindTexture ( tex_failure_function );
	cudaUnbindTexture ( tex_output_function );
	
	//Free host and device memory
	free ( h_out );

	cudaFree ( d_text );
	cudaFree ( d_go_to_function );
	cudaFree ( d_failure_function );
	cudaFree ( d_output_function );
	cudaFree ( d_out );
}


int main(){

	int k = sizeof(patterns)/sizeof(patterns[0]);
	string text;

	std::ifstream t("data.txt");
	std::stringstream buffer;
	buffer << t.rdbuf();	
	text = buffer.str();
	unsigned char *charText = (unsigned char*)text.c_str();
	
	buildMatchingMachine(patterns, k);

	int *goToTable = (int*)malloc(sizeof(int)*MAXC*MAXS);
	for(int i=0;i<MAXS;i++)
		for(int j=0;j<MAXC;j++)
			goToTable[i*MAXC+j] = g[i][j];

	shared1(M,charText,text.size(),D,26,goToTable,f,out);
	return 0;
}

