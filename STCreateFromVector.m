function [stInstTrain] = STCreateFromVector(vSpikes, bUseISI)

% STCreateFromVector - FUNCTION Package a vector of spike data as a spike train instance
% $Id: STCreateFromVector.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [stInstTrain] = STCreateFromVector(vSpikes)
%        [stInstTrain] = STCreateFromVector(vSpikes, bUseISI)
%
% 'vSpikes' should be a vector of spike times, either in absolute time stamp
% format, or as a set of inter-spike intervals (ISIs).  In either case, the
% times should be in seconds.  These spike times will be wrapped nicely into a
% spike train instance.
%
% STCreateFromVector will attempt to determine whether 'vSpikes' is in
% absolute or ISI format.  The user can specify an optional argument 'bUseISI'
% to indicate to STCreateFromVector which format it should use.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 11th August, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options
stO = STOptions;


% -- Check arguments

if (nargin > 2)
   disp('--- STCreateFromVector: Extra arguments ignored');
end

if (nargin <1)
   disp('*** STCreateFromVector: Incorrect usage');
   help STCreateFromVector;
   return;
end

if (sum(size(vSpikes) > 1) > 1)
   disp('*** STCreateFromVector: The input matrix must be a vector');
   help STCreateFromVector;
   return;
end


% -- Should we use ISIs?

if (nargin < 2)
   % - No option provided, so we should try to work it out ourselves
   % - Assume NOT ISIs, and check...
   vISIs = diff(vSpikes);
   
   % - Check for negative ISIs
   %   If there's more than some arbitrary threshold, it's probably ISIs we're
   %   dealing with
   if (sum(vISIs < 0) > 4)
      % - So the original vector was probably in ISI format
      disp('--- STCreateFromVector: Negative spike intervals; using ISI interpretation');
      bUseISI = true;
   else
      bUseISI = false;
   end
end


% -- Convert vector

if (bUseISI)
   vTimes = cumsum(vSpikes);
else
   vTimes = vSpikes;
end

% - Reshape vector
vTimes = reshape(vTimes, length(vTimes), 1);


% -- Create a spike train wrapper

% - Use default temporal resolution
instance.fTemporalResolution = stO.InstanceTemporalResolution;
instance.tDuration = max(vTimes);
instance.bChunkedMode = false;
instance.spikeList = vTimes;

stInstTrain.instance = instance;


% --- END of STCreateFromMatrix ---
