function [vfNESeq] = MakeNonErgodic(vfRandSeq, fMemTau, fTemporalRes)

% MakeNonErgodic - FUNCTION (Internal) Give memory to a random sequence
% $Id: MakeNonErgodic.m 2411 2005-11-07 16:48:24Z dylan $
%
% NOT for command-line use.

% Usage: [vfNESeq] = MakeNonErgodic(vfRandSeq, fMemTau, fTemporalRes)
%
% MakeNonErgodic will take an (ergodic, or memoryless) sequence of random
% numbers and force non-ergodicity with an exponential memory trace.  This
% will be done by performing a moving average over the sequence with an
% exponential kernel.
%
% 'vfRandSeq' is the UNIFORM random sequence to make non-ergodic.  'fMemTau'
% is the time constant for the exponential filtering, in seconds.  After
% 'fMemTau' seconds, the memory effect will be reduced to about 35%.  The
% kernel will extend to around 5 * 'fMemTau' seconds, which corresponds to a
% memory effect of 0.67%.  'fTemporalRes' is the time step between elements in
% the random sequence, for both 'vfRandSeq' and 'vfNESeq'.
%
% 'vfNESeq' will be a non-ergodic sequence, the same length as 'vfRandSeq',
% with the memory effect as described above.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd March, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Constants

% - Number of multiples of 'fMemTau' to use to generate the kernel duration
fKernelDurationFactor = 5;

% - Threshold for warning about smoothing time
nSmoothWarnThresh = 5000;


% -- Check arguments

if (nargin > 3)
   disp('--- MakeNonErgodic: Extra arguments ignored');
end

if (nargin < 3)
   disp('*** MakeNonErgodic: Incorrect usage');
   help private/MakeNonErgodic;
   return;
end


% -- Create exponential kernel for filtering

tKernelDuration = fKernelDurationFactor * fMemTau;
nNumKernelBins = fix(tKernelDuration / fTemporalRes) + 1;

% - Construct kernel
tKern = 0:fTemporalRes:tKernelDuration;
vfKern = exp(-1/fMemTau * tKern);

% -- Note: pure convolution is no good, since we specifically DON'T want
%    zero-padding at the start of the random sequence.  We'll have to fix the
%    start ourselves, up to the length of the kernel.

% - The smoothing must be done in normal-space, so convert the input sequence
vfRandSeq = STNormInvCDF(vfRandSeq);

% - Smooth the first part of the array
nSmoothingEnd = min([nNumKernelBins  length(vfRandSeq)]);

% - Display a warning if the smoothing will take a long time
if (nSmoothingEnd > nSmoothWarnThresh)
   disp('--- MakeNonErgodic: Warning: Smoothing is going to take a long time...');
end

vfPart = ConvBarrier(vfRandSeq, vfKern);

% - Normlise the kernel
vfKern = vfKern ./ sum(vfKern);

% - Convolve the rest of the array and append
vfValid = conv2(vfRandSeq, vfKern, 'valid');
vfNESeq = [vfPart(1:nSmoothingEnd)  vfValid(2:end)];

% -- Renormalise non-ergodic sequence to fix probability extents

% - Get original function extents
fOrigMin = min(vfRandSeq);
fOrigMax = max(vfRandSeq);
fOrigAmp = fOrigMax - fOrigMin;

% - Ignore the only partially smoothed section of the output sequence
nStartAvg = nSmoothingEnd;
fNEAmp = max(vfNESeq(nStartAvg+1:end)) - min(vfNESeq(nStartAvg+1:end));
vfNESeq = vfNESeq ./ fNEAmp .* fOrigAmp;

% - Make sure nothing sticks out
%vfNESeq(find(vfNESeq > fOrigMax)) = fOrigMax;
%vfNESeq(find(vfNESeq < fOrigMin)) = fOrigMin;

% - Convert back to uniform space
vfNESeq = STNormCDF(vfNESeq);

% --- END of MakeNonErgodic.m ---
