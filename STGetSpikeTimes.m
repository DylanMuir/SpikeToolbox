function [vtSpikeTimes, fSamplingRate] = STGetSpikeTimes(stTrain, strLevel)

% STGetSpikeTimes - FUNCTION Extract spike times from a spike train
% $Id: STGetSpikeTimes.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [vtSpikeTimes, fSamplingRate] = STGetSpikeTimes(stTrain <, strLevel>)
%
% Where: 'stTrain' is either an instantiated or a mapped spike train.  Spike
% train definitions are not supported (obviously, as they have no spikes).
% 'strLevel' is an optional argument specifying what spike train level to get
% spike times from.  If 'strLevel' is not supplied, spike train instances will
% be used in preference to spike train mappings.
%
% 'vtSpikeTimes' will be a column vector containing the times of all spikes in
% seconds.  'fSamplingRate' will be the sampling rate used to generate the
% spike train.  'vtSpikeTimes' can be converted into index format by
% multiplying by 'fSamplingRate' and rounding.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 10th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- STGetSpikeTimes: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STGetSpikeTimes: Incorrect usage');
   help STGetSpikeTimes;
   return;
end

% - Did the user supply a spike train level?
if (exist('strLevel', 'var'))
   % - Yes, so is it valid?
   [bValidLevel, strLevel] = STIsValidSpikeTrainLevel(strLevel);
   
   if (~bValidLevel || strcmp(strLevel, 'definition'))
      % - The user supplied an invalid level for this function, so throw an
      % error
      disp('*** STGetSpikeTimes: Invalid spike train level supplied.');
      disp('       Must be one of {''instance'', ''mapping''}');
      return;
   end
end

% - Did the user even supply a valid spike train?
if (~STIsValidSpikeTrain(stTrain))
   disp('*** STGetSpikeTimes: Invalid spike train supplied');
   return;
end


% -- Extract desired node, convert to an instance if required

% - The user hasn't supplied a spike train level to use, so we need to work it
% out ourselves
if (~exist('strLevel', 'var'))
   % - Try an instance first
   [nodeInstance, bValid] = GetNodeAsInstance(stTrain, 'instance');
   
   if (~bValid)
      % - There was no instance, so try a mapping
      [nodeInstance, bValid] = GetNodeAsInstance(stTrain, 'mapping');
      
      if (~bValid)
         % - There was no mapping either.  This is an error.
         disp('*** STGetSpikeTimes: The supplied train must contain either an instantiated');
         disp('       or a mapped spike train.');
         return;
      end
   end

else
   % - The user supplied a spike train level to try
   [nodeInstance, bValid] = GetNodeAsInstance(stTrain, strLevel);
   
   if (~bValid)
      % - The requested level didn't exist in the spike train
      fprintf(1, '*** STGetSpikeTimes: The supplied train does not contain a %s', strLevel);
      return;
   end
end

% - 'nodeInstance' now contains an instance to extract from

% -- Extract the spike times and sampling rate

if (nodeInstance.bChunkedMode)
   % - Spike times are in chunked mode format
   % - Concatenate all the chunks
   vtSpikeTimes = vertcat(nodeInstance.spikeList{:});

else
   % - Just extract the spike times
   vtSpikeTimes = nodeInstance.spikeList;
end

% - Extract sampling rate
fSamplingRate = 1 / nodeInstance.fTemporalResolution;

% - Return results
return;


% --- END of STGetSpikeTimes FUNCTION ---


function [nodeInstance, bExists] = GetNodeAsInstance(stTrain, strLevel)

if (~isfield(stTrain, strLevel))
   nodeInstance = [];
   bExists = false;
   return;
end

bExists = true;

if (strcmp(strLevel, 'instance'))
   nodeInstance = stTrain.instance;

elseif (strcmp(strLevel, 'mapping'))
   stStrippedTrain = STStripTo(stTrain, 'mapping');
   stFlatTrain = STFlatten(stStrippedTrain);
   nodeInstance = stFlatTrain.instance;
end

% --- END of GetNodeAsInstance FUNCTION ---
