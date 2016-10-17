function [bZero] = STIsZeroDuration(stTrain)

% STIsZeroDuration - FUNCTION Tests for a zero duration spike train
% $Id: STIsZeroDuration.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [bZero] = STIsZeroDuration(stTrain)
%
% 'stTrain' is a valid spike train, as defined by STIsValidSpikeTrain.
% STIsZeroDuration test this train to see if it contains any spikes.  'bZero'
% will be true if 'stTrain' contains no spikes (has a zero duration).  'bZero'
% will be false otherwise.  'bZero' will be true for a spike train definition.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd September, 2004

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

% $Log: STIsZeroDuration.m,v $
% Revision 1.3  2005/02/18 16:09:55  dylan
% STIsZeroDuration now does a test for zero spikes as well as zero time duration. (nonote)
%
% Revision 1.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 1.1  2004/09/02 08:36:20  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
