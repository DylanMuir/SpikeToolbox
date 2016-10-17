function [vfProb] = STNormCDF(vfValue, fMu, fSigma)

% STNormCDF - FUNCTION (Internal) Evaluate the normal cumulative density function
% $Id: STNormCDF.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command line use.

% Usage: [vfProb] = STNormCDF(vfValue <, fMu, fSigma>)
%
% STNormCDF calculates the normal cumulative probability distibution.
% 'vfValue' is the vector of values to evaluate the CDF at.  'fMu' and
% 'fSigma' are optionally the mean and variance of the distribution,
% respectively.  If 'fMu' or 'fSigma' are not supplied, they will default to 0
% and 1 respectively.
%
% 'vfProb' will be a vector the same size as 'vfValue', containing the
% calculated CDF.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd March, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 3)
   disp('--- STNormCDF: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STNormCDF: Incorrect usage');
   help private/NormCDF;
   return;
end

if (nargin < 3)
   fSigma = 1;
end

if (nargin < 2)
   fMu = 0;
end

% - Check ranges
if (fSigma < 0)
   disp('*** STNormCDF: Invalid sigma parameter');
   return;
end


% -- Calculate CDF

% - A slight speed-up, if we don't need to scale the distribution
if ((fSigma ~= 1) | (fMu ~= 0))
   vfValue = (vfValue - fMu) ./ fSigma;
end

vfProb = 0.5 * erfc(-vfValue ./ sqrt(2));

% --- END of STNormCDF.m ---
