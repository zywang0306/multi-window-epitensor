#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define max(a,b) \
({ __typeof__ (a) _a = (a); \
__typeof__ (b) _b = (b); \
_a > _b ? _a : _b; })

#define min(a,b) \
({ __typeof__ (a) _a = (a); \
__typeof__ (b) _b = (b); \
_a < _b ? _a : _b; })

void sort(double* y, int n);

void est_bkgd_lambda(double* x, double* lambda, int* n, int* l, int* s, double* q)
{
	// x - signal values from bedgraph file, column 4
	// lambda - return value, the lambda paramter for background
	// n - the length of x
	// l - sliding window size
	// s - sliding window step size
	// q - quantile, signal values below this quantile are used to estimate lambda

	int i,j,k,low,high,num,id,N,L,S;
	double *x_win1=NULL,*x_win2=NULL,sum,Q;

	N = n[0];
	L = l[0];
	S = s[0];
	Q = q[0];

	memset(lambda,0,N*sizeof(double));

	for (i=0; i<N; i++)
	{
	    if (i%S ==0)
        {
           low = max(0,i-L);
           high = min(N,i+L);
           x_win1 = (double *)malloc((high-low)*sizeof(double));

           num = 0;
           for (j=low; j<high; j++)
           {
               if (x[j] > 0)
               {
                   x_win1[num] = x[j];
                   num++;
               }
           }

           if (num > 0)
           {
               x_win2 = (double *)malloc(num*sizeof(double));
               memcpy(x_win2,x_win1,num*sizeof(double));
               free(x_win1);

               sort(x_win2,num);
               id = (int) min(num*Q+0.5, (double)num);

               sum = 0.0;
               for (k=0; k<id; k++)
               {
                   sum += x_win2[k];
               }
               lambda[i] = sum / id;
               lambda[i] = max(lambda[i],2);

               free(x_win2);
           }
           else if (num == 0)
           {
               free(x_win1);
               lambda[i] = 2;
           }
        }
        else if (i%S != 0)
        {
            lambda[i] = lambda[i-1];
        }
	}
}

void sort(double* y, int n)
{
	/*Sort the given array y of length n in increading order*/
	int temp,i,j;

	for(i=0; i<(n-1); i++)
	{
		for(j=0;j<n-i-1;j++)
		{
			if(y[j] > y[j+1])
			{
				temp = y[j];
				y[j] = y[j+1];
				y[j+1] = temp;
			}
		}
	}
}
