function [fInstFreq] = STInstantaneousFrequencyGamma(stTrainDef, tTimeTrace)

% STInstantaneousFrequencyGamma - FUNCTION Internal frequency profile function
% $Id: STInstantaneousFrequencyGamma.m 3985 2006-05-09 13:03:02Z dylan $
%
% NOT for command-line use

% Usage: [fInstFreq] = STInstantaneousFrequencyGamma(stTrainDef, tTimeTrace)
%
% This function is a cheat.  To be able to slot this type of train into
% STInstantiate, this function must accept a list of time steps and decide
% which should have a spike.  However, we want to pull ISIs from a gamma
% distribution.  Therefore what we'll do is generate a train of the correct
% length, return an infinite frequency for those bins that we decide
% should have spikes, and fill the other bins with zero.  This will force
% there to be spikes only where we chose.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Constants

nISIBlockSize = 100;       % Generate this many ISIs at once


% -- Check arguments

if (nargin < 2)
   disp('*** STInstantaneousFrequencyGamma: Incorrect usage');
   disp('       This is an internal frequency profile function');
   help private/STInstantaneousFrequencyLinear;
   help private/STInstFreqDescription;
   return;
end


% -- Pull ISIs from the gamma distribution

% - Calculate gamma function parameters
fAlpha = stTrainDef.fMeanISI^2 / stTrainDef.fVarISI;
fBeta = fAlpha / stTrainDef.fMeanISI;

% - Fill a duration with ISIs
vISIs = [];
tMinTime = min(tTimeTrace);
tMaxTime = max(tTimeTrace);
tCurrTime = tMinTime;

while (tCurrTime < tMaxTime)
   % - Generate a block of ISIs
   vISIBlock = gamrnd(fAlpha, 1/fBeta, [1 nISIBlockSize]);
   
   % - Append to the current list
   vISIs = [vISIs  vISIBlock];
   
   % - Update total duration
   tCurrTime = tCurrTime + sum(vISIBlock);
end


% -- Select required ISIs, return mock instantaneous frequency vector

% - Get spike times
vTimes = cumsum(vISIs);

% - Find the last spike we should take
%   Should be < not <=, because we add one below to get the index into
%   'fInstFreq'
nLastSpike = max(find(vTimes < (tMaxTime - tMinTime)));

% - Trim ISI array
vTimes= vTimes(1:nLastSpike);

% - Fix to the correct temporal resolution
fTemporalResolution = tTimeTrace(2) - tTimeTrace(1);
vTimes = fix(vTimes ./ fTemporalResolution);

% - Mock up the instantaneous frequency vector
fInstFreq = zeros(1, length(tTimeTrace));
fInstFreq(vTimes+1) = 1 / fTemporalResolution;

% --- END of STInstantaneousFrequencyGamma.m ---
