function [stTrain] = STMap(stTrain, varargin)

% STMap - FUNCTION Map a spike train to a specific neuron and synapse
% $Id: STMap.m 8204 2008-01-09 14:29:44Z giacomo $
%
% Usage: [stTrain] = STMap(stInstantiatedTrain, nAddr1, nAddr2, ...)
%        [stTrain] = STMap(stInstantiatedTrain, stasAddressingSpecifcation, nAddr1, nAddr2, ...)
%
% Where: 'stInstantiatedTrain' is an instantiated spike train, as created by
% STInstantiate.  'nAddr1', 'nAddr2', etc. are addresses corresponding to
% the (used) fields in the current addressing specification.  
%
% STMap can accept arrays for any of its arguments.  In this case, the
% output will be a cell array of the same size as the cellular input.  This
% form of the function can be used to map different spike trains
% simultaneously, or map a single spike train to multiple addresses.  The
% address arguments should be in matrix form.  All arrays supplied as
% arguments must be of the same size.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;
MappingTemporalResolution = stOptions.MappingTemporalResolution;


% -- Check arguments

if (nargin < 2)
   disp('*** STMap: Incorrect number of argumnets');
   help STMap;
   return;
end

% -- Extract addressing information
[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Is it a valid addressing specification?
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STMap: Invalid addressing specification supplied');
   return;
end

% - Determine whether address fields are arrays or not
vAddressArraySizes = CellForEach(@numel, varargin);
vbIsArrayAddress = vAddressArraySizes > 1;

% - Should we 'cellify' the output?
bArrayTrain = iscell(stTrain);
bArrayOutput = any(vbIsArrayAddress) | bArrayTrain;


% -- Handle cell arrays of spike trains

if (bArrayOutput)
   % - What size should the output be?
   if (bArrayTrain)
      % - If the spike train was supplied as a cell array, this should define
      % - the size of the output array
      vOutputSize = size(stTrain);
      
   else
      % - The first array addressing field will specify the size of the output
      % array
      nFirstArrayIndex = find(vAddressArraySizes > 1, 1 );
      vOutputSize = size(varargin{nFirstArrayIndex});
   end
   
   % - Convert non-array elements to arrays
   if (~bArrayTrain)
      % - Convert spike train to cell
      stTrainCell = cell(vOutputSize);
      stTrainCell(:) = deal({stTrain});
      stTrain = stTrainCell;
   end
  
   for nAddressIndex = find(~vbIsArrayAddress)         % Only iterate over non-array fields
      % - Convert address fields to arrays
      varargin{nAddressIndex} = ones(vOutputSize) .* varargin{nAddressIndex};
   end

   % - Check that all arrays are the same size
   % - NOTE: We never need to check the spike train size
   for nAddressIndex = 1:length(varargin)
      if (numel(varargin{nAddressIndex}) ~= prod(vOutputSize))
         disp('*** STMap: When arrays are supplied for input, they must all be');
         disp('       the same size');
         return;
      end
   end
   
   % - Display some progress
   % STProgress('Mapping: Spike train [%04d/%04d]', 0, numel(stTrain));
   
   % -- Map the cell array spike trains
   % - Call STMap for each spike train
   for nCellIndex = 1:prod(vOutputSize)
      % - Get the current address
      cAddress = num2cell(CellForEach(@Index, varargin, nCellIndex));
      
      % - Map the individually addressed train
      stTrain{nCellIndex} = STMap(stTrain{nCellIndex}, stasSpecification, cAddress{:});
      %STProgress('\b\b\b\b\b\b\b\b\b\b%04d/%04d]', nCellIndex, numel(stTrain));
   end
   %STProgress('\n');
   
   % - Finished!
   return;
end



% --- Handle simple (non-cell) arguments

% - Check that the spike train has been instantiated
if (~isfield(stTrain, 'instance'))
   disp('*** STMap: The spike train must be instantiated with STInstantiate before');
   disp('       calling STMap');
   help STMap;
   return;
end

% - Check if the address is valid
if (~STIsValidAddress(stasSpecification, varargin{:}))
   disp('*** STMap: Invalid address supplied');
   return;
end
   
% -- Map the train

% - Check if the train has already been mapped
if (isfield(stTrain, 'mapping'))
   disp('--- STMap: Warning: re-mapping a previously mapped train');
end

% - Create the mapping
mapping = [];
mapping.tDuration = stTrain.instance.tDuration;
mapping.fTemporalResolution = MappingTemporalResolution;
mapping.bChunkedMode = stTrain.instance.bChunkedMode;
mapping.stasSpecification = stasSpecification;
mapping.addrFields = varargin;
mapping.addrSynapse = STAddrLogicalConstruct(stasSpecification, varargin{:});

% - Check that the spike train is not of zero duration
if (STIsZeroDuration(stTrain))
   warning('SpikeToolbox:ZeroDuration', 'STMap: Zero-duration spike train');
   mapping.spikeList = [];
   stTrain.mapping = mapping;
   return;
end

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
for nChunkIndex = 1:nNumChunks
   mappedSpikeList{nChunkIndex}(:, 1) = floor(spikeList{nChunkIndex} ./ MappingTemporalResolution);
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

% --- END of STMap FUNCTION ---


% Index - FUNCTION Index into a matrix argument

function [nElement] = Index(matrix, nIndex)

nElement = matrix(nIndex);

% --- END of Index FUNCTION ---

% --- END of STMap.m ---
