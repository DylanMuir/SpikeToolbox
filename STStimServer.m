function [stStimTrain] = STStimServer(stMappedTrain)

% STStimServer - FUNCTION Send a mapped spike train to the PCI-AER board
% $Id: STStimServer.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stMonTrain] = STStimServer(stTrain)
%
% 'stTrain' is a spike train mapped to a neuron/synapse address, as created
% by STMap.  STStimServer will repeatedly stimulate with the supplied train
% until interrupted.

% Author: Chiara Bartalozzi <chiara@ini.phys.ethz.ch>
% Created: 30th Novemebr, 2004 (from STStimServer.m)

% -- Check arguments

if (nargin > 1)
   disp('--- STStimServer: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STStimServer: Incorrect usage');
   help STStimServer;
   return;
end

% -- Check for a valid spike train

if (~STIsValidSpikeTrain(stMappedTrain))
   disp('*** STExport: This is not a valid spike train');
   return;
end

% -- Check that the spike train has a mapping

if (~isfield(stMappedTrain, 'mapping'))
   disp('*** STExport: Only mapped spike trains can be exported');
   return;
end

% -- Check that the mapping is not of zero duration

if (STIsZeroDuration(stMappedTrain))
   disp('*** STExport: Cannot export a zero-duration spike train');
   return;
end

% - Extract spike list and convert to delay format
if (stMappedTrain.mapping.bChunkedMode)
   spikeList = stMappedTrain.mapping.spikeList;
else
   spikeList = {stMappedTrain.mapping.spikeList};
end

mSpikeList = [];

for (nChunkIndex = 1:length(spikeList))
   % - Extract raw spike list
   rawSpikeList = spikeList{nChunkIndex};
   
   % - Determine the time of the last spike
   if (nChunkIndex == 1)
   	% - The first spike should be delayed by whenever the timestamp says
		tLastSpike = 0;
   else
      tLastSpike = max(spikeList{nChunkIndex-1}(:, 1));
   end
   
   % - Handle a singleton spike
   if  (size(rawSpikeList, 1) == 1)
      rawSpikeList = [tLastSpike - rawSpikeList(1), rawSpikeList(2)];
   else
      % - Calculate the inter-spike intervals
      rawSpikeList(:, 1) = rawSpikeList(:, 1) - [tLastSpike; rawSpikeList(1:end-1, 1)];
   end
   
   % - Get addressing specification
   if (FieldExists(stMappedTrain.mapping, 'stasSpecification'))
      stasSpecification = stMappedTrain.mapping.stasSpecification;
   else
      % - This case should never occur
      stasSpecification = stOptions.stasDefaultOutputSpecification;
   end
   
   % - Convert to physical addresses
   nRequiredAddressFields = sum(~[stasSpecification.bIgnore]);
   [addr{1:nRequiredAddressFields}] = STAddrLogicalExtract(rawSpikeList(:, 2), stasSpecification);
   rawSpikeList(:, 2) = STAddrPhysicalConstruct(stasSpecification, addr{:});
   
   mSpikeList = [mSpikeList ; rawSpikeList];
   % mSpikeList is in the format [isi - addr] (matrix Nx2)
end


% - Transpose to get the correct format for the server stimulation:
% matrix 2xN
stStimTrain = mSpikeList';
% find synchronic events (ISI=0) and puts a delay (ISI=1)
stStimTrain(1,find(stStimTrain(1,:)==0)) = 10;

disp('Sart Stimulation')
% - Start stimulation: it is a continuous stimulation that loops the
% input till when it is stopped
PciaerSeqWrite(uint32(stStimTrain));



% --- END of STStimServer.m ---

