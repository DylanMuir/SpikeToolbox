function [mSeq] = CorrUniRand(mCovariance, nSeqLength)

% CorrUniRand - FUNCTION Generate uniformly-distributed random sequences with specified covariance
% $Id: CorrUniRand.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [mSeq] = CorrUniRand(mCovariance, nSeqLength)
%
% Where: 'mCovariance' is an upper-triangular N x N matrix with unit digonal
% specifying the correlation structure to generate.  In this matrix, -1
% represents the minimum possible correlation and 1 represents the maximum
% possible correlation.  'nSeqLength' is the desired length of each sequence.
%
% 'mSeq' will contain the correlated sequences.  Each column in 'mSeq'
% contains a single sequence, of length 'nSeqLength'.  The columns in 'mSeq'
% correspond to the rows of 'mCovariance'; the cross-sequence correlations
% will be given by 'mCovariance'.
%
% This function uses the NORTA method described in
% [1] Cario and Nelson 1997, "Modeling and Generating Random Vectors with
% Arbitrary Marginal Distibutions and Correlation Matrix", Northwestern
% University Technical Report.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 27th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Get toolbox options

stO = STOptions;
RandomGenerator = stO.RandomGenerator;


% -- Check arguments

if (nargin > 2)
   disp('--- CorrUniRand: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** CorrUniRand: Incorrect usage');
   help CorrUniRand;
   return;
end

% - Check for a square matrix
if (size(mCovariance, 1) ~= size(mCovariance, 2))
   disp('*** CorrUniRand: ''mCovariance'' must be a square matrix');
   return;
end

% - Check for a unit diagonal
if any(diag(mCovariance, 0) ~= ones(size(mCovariance, 1), 1))
   disp('--- CorrUniRand: Warning: The principal diagonal of ''mCovariance'' should be');
   disp('       all ones.  This will be corrected');
   
   % - Form a new matrix with unit diagonal
   mCovariance = eye(size(mCovariance, 1)) + triu(mCovariance, 1);
end


% - Check number of sequences to generate
nNumSeq = size(mCovariance, 1);
if (nNumSeq < 2)
   disp('--- CorrUniRand: Warning: Only generating a single sequence');
   varargout{1} = feval(RandomGenerator, nSeqLength, 1);
end


% -- Construct the NORTA covariance matrix

% - Convert form 'mCovariance' according to transformation described in [1]
mCovZ = 2 * sin((pi * mCovariance) / 6);

% - Perform a Cholesky decomposition of mCovZ
try
   mDecomp = chol(mCovZ);

catch
   [strMsg, idMsg] = lasterr;
   
   if (strcmp(idMsg, 'MATLAB:posdef'))
      disp('*** CorrUniRand: ''mCovariance'' is not positive definite.  I can''t continue');
      disp('       under this condition.  Sorry!');
      return;
   end
end


% -- Generate some random sequences

% - Generate 'nNumSeq' uniform random sequences
mUniSeq = feval(RandomGenerator, nSeqLength, nNumSeq);

% - Convert to normal distribution ~N(0, 1)
mZ = -sqrt(2) .* erfcinv(2 * mUniSeq);

% - Convert via NORTA matrix to correlated sequences
mC = mZ * mDecomp;

% - Convert to uniform distribution and return
mSeq = normcdf(mC);

% --- END of CorrUniRand.m ---
