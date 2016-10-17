function [vfConv] = ConvBarrier(vfData, vfKernel)

% ConvBarrier - FUNCTION Calculate convolution at the beginning of a sequence
% .M file: $Id: ConvBarrier.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [vfConv] = ConvBarrier(vfData, vfKernel)
%
% 'vfData' is a vector of data points to convolve.  'vfKernel' is a vector to use
% as a convolution kernel.  A convolution will be performed, without using zero
% padding at the left border.  Instead, only a partial kernel will be used for
% this section.  The convolution will only be performed for the start of 'vfData'
% up to the length of 'vfKernel'.  The matlab conv2 function with the 'valid'
% option can be used to return the rest of the convolution result.  Note that
% 'vfConv' will be normalised with respect to the area of the partial kernel, 
% whereas conv will not normalise the result.

% NOTE: THIS IS A DUMMY FUNCTION, AND WILL ONLY BE EXECUTED IF
% ConvBarrier.mex___ HAS NOT BEEN COMPILED

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd March, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Display some help

disp('***ConvBarrier: MEX function has not been compiled');
disp('    This low-level toolbox function is not yet available to the');
disp('    MATLAB workspace.  Please run STWelcome.');

% --- END of ConvBarrier.m ---
