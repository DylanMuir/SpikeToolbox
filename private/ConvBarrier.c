/* ConvBarrier - FUNCTION Calculate convolution at the beginning of a sequence
 * $Id: ConvBarrier.c 7055 2007-07-06 04:49:53Z giacomo $
 *
 * Usage: [vfConv] = ConvBarrier(vfData, vfKernel)
 *
 * 'vfData' is a vector of data points to convolve.  'vfKernel' is a vector to use
 * as a convolution kernel.  A convolution will be performed, without using zero
 * padding at the left border.  Instead, only a partial kernel will be used for
 * this section.  The convolution will only be performed for the start of 'vfData'
 * up to the length of 'vfKernel'.  The matlab conv2 function with the 'valid'
 * option can be used to return the rest of the convolution result.  Note that
 * 'vfConv' will be normalised with respect to the area of the partial kernel, 
 * whereas conv will not normalise the result.
 */

/* Author: Dylan Muir <dylan@ini.phys.ethz.ch>
 * Created: 2nd March, 2005
 * Copyright (c) 2005 Dylan Richard Muir
 */

#include <mex.h>

void 
mexFunction(int nlhs, mxArray *plhs[],
				int nrhs, const mxArray *prhs[])
{
	double	*adKernel,			/* Data pointer for kernel array */
				*adData,				/* Data pointer for source data array */
				*adReturn;			/* Data pointer for return data array */
	int		nSmoothingBins,	/* Number of bins to perform convolution over */
				nEndIndex,			/* Index along smoothing section */
				nBinIndex,			/* Index into data and kernel arrays */
				nKernelLength,
				nDataLength;
	double	dPartialMag,		/* Magnitude of partial kernel */
				dKernelElem;		/* Current kernel element */

	/* - Check usage */
	if (nrhs != 2) {
		mexPrintf("*** ConvBarrier: Incorrect usage\n");
		mexPrintf("  .MEX file: %s\n  [MEX BUILD - %s %s]\n", "$Id", __TIME__, __DATE__);
		mexEvalString("help ConvBarrier");
		return;
	}
	
	/* - Get array lengths */
	nDataLength = mxGetN(prhs[0]) * mxGetM(prhs[0]);
	nKernelLength = mxGetN(prhs[1]) * mxGetN(prhs[1]);


   /* - Allocate output array */
	if (!(plhs[0] = mxCreateDoubleMatrix(1, nDataLength, mxREAL))) {
		mexPrintf("*** ConvBarrier: Couldn't allocate return array\n");
		return;
	}
	
	/* - Get data pointers */
	adData = mxGetPr(prhs[0]);
	adKernel = mxGetPr(prhs[1]);
	adReturn = mxGetPr(plhs[0]);
	
	/* - Determine how far to smooth */
	if (nKernelLength < nDataLength) {
		nSmoothingBins = nKernelLength;
	} else {
		nSmoothingBins = nDataLength;
	}
	

   
	/* - Index along data array => point to smooth to */
	for (nEndIndex = 0; nEndIndex < nSmoothingBins; nEndIndex++) {
		/* - Reset partial magnitude count */
		dPartialMag = 0;
		for (nBinIndex = 0; nBinIndex <= nEndIndex; nBinIndex++) {
			dKernelElem = adKernel[nBinIndex];
			adReturn[nEndIndex] += dKernelElem * adData[nEndIndex-nBinIndex];
			dPartialMag += dKernelElem;
		}
		/* - Normalise current point */
		adReturn[nEndIndex] /= dPartialMag;
	}
}

/* --- END of ConvBarrier.c --- */
