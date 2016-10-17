function [bZero] = STIsZeroDuration(stTrain)

% STIsZeroDuration - FUNCTION Tests for a zero duration spike train
% $Id: STIsZeroDuration.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [bZero] = STIsZeroDuration(stTrain)
%
% 'stTrain' is a valid spike train, as defined by STIsValidSpikeTrain.
% STIsZeroDuration test this train to see if it contains any spikes.  'bZero'
% will be true if 'stTrain' contains no spikes (has a zero duration).  'bZero'
% will be false otherwise.  'bZero' will be true for a spike train definition.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd September, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STIsZeroDuration: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsZeroDuration: Incorrect usage');
   help STIsZeroDuration;
   return;
end


% -- Check the spike train

% - Check for a valid spike train object
if (~STIsValidSpikeTrain(stTrain))
   disp('*** STIsZeroDuration: Invalid spike train supplied');
   return;
end

% - Determine which spike train level to test
if (FieldExists(stTrain, 'mapping'))
   % - Use the mapping level
   node = stTrain.mapping;
   
elseif (FieldExists(stTrain, 'instance'))
   % - Use the instance level
   node = stTrain.instance;
   
else
   % - No mapping or instance, so it can't be zero duration
   bZero = false;
   return;
end

% - Test the train
bZero = (node.tDuration == 0) | (isempty(node.spikeList));


% --- END of STIsZeroDuration.m ---
