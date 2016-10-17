function [stFiltTrain, stRejectTrain] = STSieve(stTrain, fMinISI, fMaxISI)

% STSieve - FUNCTION Filter a spike train by Inter-spike interval
%
% Usage: [stFiltTrain, stRejectTrain] = STSieve(stTrain, fMinISI, fMaxISI)
%
% STSieve will only pass spikes that fall between 'fMinISI' and 'fMaxISI'
% (inclusive).  If either argument is supplied as an empty matrix, that
% argument will default to zero and infinity respectively.  'stTrain'
% should be either an instantiated or mapped spike train.
%
% 'stFiltTrain' will be a new spike train containing all spikes matching
% the ISI criteria.  'stRejectTrain' will be a new spike train containing
% the non-matching spikes.
%
% Note: When an ISI falls outside the sieve criteria, BOTH spikes that
% caused the failing ISI will be removed.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 7th November, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 3)
   disp('--- STSieve: Extra arguments ignored');
end

if (nargin < 3)
   fMaxISI = [];
end

if (nargin < 2)
   disp('*** STSieve: Incorrect usage');
   help STSieve;
   return;
end

if (~STIsValidSpikeTrain(stTrain))
   disp('*** STSieve: Invalid spike train supplied');
   return;
end


% -- Determine what spike train levels to use

if (STHasMapping(stTrain))
   bUseMapping = true;
else
   bUseMapping = false;
end

if (STHasInstance(stTrain))
   bUseInstance = true;
else
   bUseInstance = false;
end

% - Check that we at least have one of the two...
if (~(bUseMapping || bUseInstance))
   disp('*** STSieve: The supplied train must contain either a mapping or an instance');
   return;
end


% -- Process nodes

if (bUseInstance)
   % - Make new instance nodes
   stFiltTrain.instance = stTrain.instance;
   stRejectTrain.instance = stTrain.instance;
end

if (bUseMapping)
   % - Make new mapping nodes
   stFiltTrain.mapping = stTrain.mapping;
   stRejectTrain.mapping = stTrain.mapping;

   if (stTrain.mapping.bChunkedMode)
      spikeListMapping = stTrain.mapping.spikeList;
   else
      spikeListMapping = {stTrain.mapping.spikeList};
   end
end

% - Get a standard set of spike list chunks
if (bUseInstance)
   % - Use the instance set, preferably
   if (stTrain.instance.bChunkedMode)
      spikeList = stTrain.instance.spikeList;
   else
      spikeList = {stTrain.instance.spikeList};
   end

else
   spikeList = spikeListMapping;
   
   % - Convert the spike list to seconds
   for (nChunkIndex = 1:numel(spikeList))
      spikeList{nChunkIndex} = spikeList{nChunkIndex} .* stTrain.mapping.fTemporalResolution;
   end
end


% -- What should we filter?

if (isempty(fMinISI))
   bFilterMin = false;
else
   bFilterMin = true;
end

if (isempty(fMaxISI))
   bFilterMax = false;
else
   bFilterMax = true;
end


% -- Perform the filtering

nLastSpike = NaN;
for (nChunkIndex = 1:numel(spikeList))
   % - Get spike times and ISIs, including the last spike from the previous
   %   chunk
   vTimes = [nLastSpike; spikeList{nChunkIndex}(:, 1)];
   nLastSpike = vTimes(end);
   vISIs = diff(vTimes);
   
   % - Apply and merge criteria
   if (bFilterMin)
      vbThrow = (vISIs < fMinISI);
   else
      vbThrow = false(size(vISIs));
   end

   if (bFilterMax)
      vbThrow = vbThrow & (vISIs > fMaxISI);
   end

   % - Include both spikes corresponding to an ISI
   vbThrow(2:end) = (vbThrow(2:end) + vbThrow(1:end-1)) > 0;
   
   % - Are we filtering out the last spike from the previous chunk?
   if (vbThrow(1))
      % - Throw away the last spike
      if (bUseInstance)
         stRejectTrain.instance.spikeList{nChunkIndex-1} = stRejectTrain.instance.spikeList{nChunkIndex-1}(1:end-1);
      end
      
      if (bUseMapping)
         stRejectTrain.mapping.spikeList{nChunkIndex-1} = stRejectTrain.mapping.spikeList{nChunkIndex-1}(1:end-1, :);
      end
   end

   % - Filter the spike lists
   if (bUseInstance)
      KeepInstanceSpikeList{nChunkIndex} = spikeList{nChunkIndex}(~vbThrow(2:end));
      ThrowInstanceSpikeList{nChunkIndex} = spikeList{nChunkIndex}(vbThrow(2:end));
   end
   
   if (bUseMapping)
      KeepMappingSpikeList{nChunkIndex} = spikeListMapping{nChunkIndex}(~vbThrow(2:end), :);
      ThrowMappingSpikeList{nChunkIndex} = spikeListMapping{nChunkIndex}(vbThrow(2:end), :);
   end
end


% -- Restore spike lists to chunked / flat mode

if (bUseInstance)
   if (stTrain.instance.bChunkedMode)
      stFiltTrain.instance.spikeList = KeepInstanceSpikeList;
      stRejectTrain.instance.spikeList = ThrowInstanceSpikeList;
   else
      stFiltTrain.instance.spikeList = KeepInstanceSpikeList{1};
      stRejectTrain.instance.spikeList = ThrowInstanceSpikeList{1};
   end
end

if (bUseMapping)
   if (stTrain.mapping.bChunkedMode)
      stFiltTrain.mapping.spikeList = KeepMappingSpikeList;
      stRejectTrain.mapping.spikeList = ThrowMappingSpikeList;
   else
      stFiltTrain.mapping.spikeList = KeepMappingSpikeList{1};
      stRejectTrain.mapping.spikeList = ThrowMappingSpikeList{1};
   end
end


% --- END of STSieve.m ---
