function [bValid] = STIsValidSpikeTrain(stTrain)

% STIsValidSpikeTrain - FUNCTION Test for a valid spike train
% $Id: STIsValidSpikeTrain.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [bValid] = STIsValidSpikeTrain(stTrain)
%
% STIsValidSpikeTrain will test whether an object is a valid spike toolbox
% spike train.  'bValid' will indicate the result of this test.
%
% 'bValid' will be true for zero-duration spike trains.  See STIsZeroDuration
% to test for this condition.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidSpikeTrain: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidSpikeTrain: Incorrect number of arguments');
   help STIsValidSpikeTrain;
   return
end


% -- Test the spike train

bValid = false;

% - Does any spike train level structure exist?
if (~FieldExists(stTrain, 'mapping') && ...
    ~FieldExists(stTrain, 'instance') && ...
    ~FieldExists(stTrain, 'definition'))
   disp('--- STIsValidSpikeTrain: No spike train level exists');
   return;
end

if (FieldExists(stTrain, 'mapping'))
   mapping = stTrain.mapping;
   if (~FieldExists(mapping, 'tDuration') || ...
       ~FieldExists(mapping, 'fTemporalResolution') || ...
       ~FieldExists(mapping, 'bChunkedMode') || ...
       ~isfield(mapping, 'spikeList'))
      disp('--- STIsValidSpikeTrain: Invalid spike train mapping structure');
      return;
   end
end

if (FieldExists(stTrain, 'instance'))
   instance = stTrain.instance;
   if (~FieldExists(instance, 'fTemporalResolution') || ...
       ~FieldExists(instance, 'tDuration') || ...
       ~FieldExists(instance, 'bChunkedMode') || ...
       ~isfield(instance, 'spikeList'))
      disp('--- STIsValidSpikeTrain: Invalid spiketrain instance structure');
      return;
   end
end

if (FieldExists(stTrain, 'definition'))
   definition = stTrain.definition;
   if (~FieldExists(definition, 'strType'))
      disp('--- STIsValidSpikeTrain: Invalid spike train definition');
      return;
   end
end


% -- The tests were passed

bValid = true;

% --- END of STIsValidSpikeTrain.m ---
