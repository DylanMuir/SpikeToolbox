function [vfInv] = STNormInvCDF(vfProb, fMu, fSigma)

% STNormInvCDF - FUNCTION (Internal) Evaluate the inverse of the normal CDF
% $Id: STNormInvCDF.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command line use.

% Usage: [vfInv] = STNormInvCDF(vfProb <, fMu, fSigma>)
%
% STNormInvCDF calculates the inverse of the normal cumulative probability
% distibution.  'vfProb' is the vector of probabilities at which to evaluate
% the inverse CDF.  'fMu' and 'fSigma' are optionally the mean and variance of
% the distribution, respectively.  If 'fMu' or 'fSigma' are not supplied, they
% will default to 0 and 1 respectively.
%
% 'vfInv' will be a vector the same size as 'vfProb', containing the
% calculated inverse values.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd March, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 3)
   disp('--- STNormInvCDF: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STNormInvCDF: Incorrect usage');
   help private/NormInvCDF;
   return;
end

if (nargin < 3)
   fSigma = 1;
end

if (nargin < 2)
   fMu = 0;
end

% - Check ranges
if ((fSigma < 0) || (any(any((vfProb < 0) | (vfProb > 1)))))
   disp('*** STNormInvCDF: Invalid parameters or probabilities');
   return;
end


% -- Calculate inverse CDF

vfInv = -sqrt(2) .* erfcinv(2 * vfProb);

% - A slight speed-up, if we don't need to scale the distribution
if ((fSigma ~= 1) | (fMu ~= 0))
   vfInv = sigma .* vfInv + fMu;
end

% --- END of STNormInvCDF.m ---
