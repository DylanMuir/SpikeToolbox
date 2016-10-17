function [stTrain] = STMap(stTrain, nNeuron, nSynapse)

% FUNCTION STMap - Map a spike train to a specific neuron and synapse
%
% Usage: [stTrain] = STMap(stInstantiatedTrain, nNeuron, nSynapse)
% Where: 'stInstantiatedTrain' is an instantiated spike train, as created by
% STInstantiate.  'nNeuron' is the index of the neuron to map the train to.
% 'nSynapse' is the index of the synapse to map the train to.  'stTrain' will
% have a field 'mapping' added to it, containing the mapped train.
%
% STMap can accept arrays for any of its arguments.  In this case, the
% output will be a cell array of the same size as the cellular input.  This
% form of the function can be used to map different spike trains
% simultaneously, or map a single spike train to multiple addresses.  The
% address arguments should be in matrix form.  All arrays supplied as
% arguments must be of the same size.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th March, 2004

% $Id: STMap.m,v 1.1 2004/06/04 09:35:48 dylan Exp $

% -- Define globals

global MAPPING_TEMPORAL_RESOLUTION;


% -- Check arguments

if (nargin > 3)
   disp('--- STMap: Extra arguments ignored');
end

if (nargin < 3)
   disp('*** STMap: Incorrect number of argumnets');
   help STMap;
   return;
end


% -- Handle cell arrays of spike trains

bArrayTrain = iscell(stTrain);
bArrayNeuron = (max(size(nNeuron)) > 1);
bArraySynapse = (max(size(nSynapse)) > 1);

if (bArrayTrain | bArrayNeuron | bArraySynapse)
   % - At least one of these arguments is an array so we should 'cellify'
   % - the output
   
   % -- Determine what size the output array should be
   if (bArrayTrain)
      % - If the spike train was supplied as a cell array, this should define
      % - the size of the output array
      vOutputSize = size(stTrain);
      
   elseif (bArrayNeuron)
      vOutputSize = size(nNeuron);
      
   else % nSynapse must be an array
      vOutputSize = size(nSynapse);
   end
   
   % -- Convert non-array arguments to array format
   if (~bArrayTrain)
      stTrainCell = cell(vOutputSize);
      stTrainCell(:) = deal({stTrain});
      stTrain = stTrainCell;
   end
   
   if (~bArrayNeuron)
      nNeuron = ones(vOutputSize) .* nNeuron;
   end
   
   if (~bArraySynapse)
      nSynapse = ones(vOutputSize) .* nSynapse;
   end
   
   % -- Check that all arguments are the same size
   if ((prod(size(stTrain)) ~= prod(size(nNeuron))) | ...
         (prod(size(stTrain)) ~= prod(size(nSynapse))))
      disp('*** STMap: All cell array inputs must be of the same size');
      return;
   end
   
   fprintf(1, 'Spike train [%02d/%02d]', 0, prod(size(stTrain)));
   
   % -- Map the cell array spike trains
   % - Call STMap for each spike train
   for (nCellIndex = 1:prod(size(stTrain)))
      stTrain{nCellIndex} = STMap(stTrain{nCellIndex}, nNeuron(nCellIndex), nSynapse(nCellIndex));
      fprintf(1, '\b\b\b\b\b\b%02d/%02d]', nCellIndex, prod(size(stTrain)));
   end
   
   fprintf(1, '\n');
   
   % - Finished!
   return;
end


% --- Handle simple (non-cell) arguments

% -- Check that the spike train has been instantiated
if (~isfield(stTrain, 'instance'))
   disp('*** STMap: The spike train must be instantiated with STInstantiate before');
   disp('       calling STMap');
   help STMap;
   return;
end

% -- Check that the spike train is not of zero duration
if (stTrain.instance.tDuration == 0)
   disp('*** STMap: Cannot map a zero-duration spike train');
   return;
end


% -- Check that defaults exist
STCreateDefaults;


% -- Map the train

% - Check if the train has already been mapped
if (isfield(stTrain, 'mapping'))
   disp('--- STMap: Warning: re-mapping a previously mapped train');
end

% - Create the mapping
mapping = [];
mapping.tDuration = stTrain.instance.tDuration;
mapping.fTemporalResolution = MAPPING_TEMPORAL_RESOLUTION;
mapping.bChunkedMode = stTrain.instance.bChunkedMode;
mapping.nNeuron = nNeuron;
mapping.nSynapse = nSynapse;
mapping.addrSynapse = STConstructLogicalAddress(nNeuron, nSynapse);

% - Are we using chunked mode?
if (stTrain.instance.bChunkedMode)
   % - Extract the spike list from the instance
   spikeList = stTrain.instance.spikeList;
   nNumChunks = stTrain.instance.nNumChunks;
   mapping.nNumChunks = nNumChunks;
else
   % - Create a cell array from the spike list
   spikeList = {stTrain.instance.spikeList};
   nNumChunks = 1;
end

% - Map the spike lists
for (nChunkIndex = 1:nNumChunks)
   mappedSpikeList{nChunkIndex}(:, 1) = floor(spikeList{nChunkIndex} ./ MAPPING_TEMPORAL_RESOLUTION);
   mappedSpikeList{nChunkIndex}(:, 2) = ones(length(spikeList{nChunkIndex}), 1) .* mapping.addrSynapse;
end

% - Assign mapped spike lists
if (mapping.bChunkedMode)
   mapping.spikeList = mappedSpikeList;
else
   mapping.spikeList = mappedSpikeList{1};
end

% - Assign mapping to spike train
stTrain.mapping = mapping;

% --- END of STMap.m ---

% $Log: STMap.m,v $
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.12  2004/05/09 17:55:15  dylan
% * Created STFlatten function to convert a spike train mapping back into an
% instance.
% * Created STExtract function to extract a train(s) from a multiplexed
% mapped spike train
% * Renamed STConstructAddress to STConstructPhysicalAddress
% * Modified the address format for spike train mappings such that the
% integer component of an address specifies the neuron.  This makes raster
% plots much easier to read.  The format is now
% |NEURON_BITS|.|SYNAPSE_BITS|  This is now referred to as a logical
% address.  The format required by the PCIAER board is referred to as a
% physical address.
% * Created STConstructLogicalAddress and STExtractLogicalAddress to
% convert neuron and synapse IDs to and from logical addresses
% * Created STExtractPhysicalAddress to convert a physical address back to
% neuron and synapse IDs
% * Modified STConstructPhysicalAddress so that it accepts vectorised input
% * Modified STConcat so that it accepts cell arrays of spike trains to
% concatenate
% * Modified STExport, STImport so that they handle logical / physical
% addresses
% * Fixed a bug in STMultiplex and STConcat where spike event addresses were
% modified when temporal resolutions were different across spike trains
% * Modified STFormats to reflect addresss format changes
%
% Revision 1.11  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.10  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%