function [stExtTrain] = STExtract(stTrain, varargin)

% STExtract - FUNCTION Extract a single spike train from a multiplexed mapping
% $Id: STExtract.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stExtTrain] = STExtract(stTrain, nAddr1, nAddr2, ...)
%        [stExtTrain] = STExtract(stTrain, [nAddr1Min  nAddr1Max], [nAddr2Min  nAddr2Max], ...)
%
% 'stTrain' must contain a mapped spike train.  'nAddr...' specify neuron
% and synapse addresses to extract from 'stTrain'.  The spikes from this
% address will be returned in a new mapped spike train 'stExtTrain'.
%
% Under the second usage mode, an address range can be specified.  In this
% case, all spikes with addresses falling within the address range will be
% extracted and returned in 'stExtTrain'.  For each addressing field, a
% minimum and maximum should be supplied.  If these are the same value, only
% one is required.
%
% For example, the command
%    STExtract(stTrain, [0 5], 4)
% will extract spikes from 'stTrain', using {0 4} as the minimum address and
% {5 4} as the maximum address.
%
%    STExtract(stTrain, [0 5], [2 4])
% will extract spikes from 'stTrain', using {0 2} as the minimum address and
% {5 4} as the maximum address.
%
% Note that the addressing range applies to the logical addresses, and the
% range for each field does not apply specifically to that field.  In the
% second example above, the address {7 3} may fall with the addressing range,
% if the second field is major and the first minor.  This becomes clear when
% one considers that the minimum address may translate to '2.0' and the
% maximum to '4.8' in logical addresses.
%
% Note that the addressing specification will be taken from 'stTrain' and can
% not be overridden.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
   disp('*** STExtract: Incorrect usage');
   help STExtract;
end

if (~isfield(stTrain, 'mapping'))
   disp('*** STExtract: The spike train to extract from must contain a mapping');
   return;
end

% - Check for a zero-duration spike train
if (STIsZeroDuration(stTrain))
   disp('--- STExtract: Warning: Zero-duration spike train');
   stExtTrain = stTrain;
   return;
end

% - Check addresses supplied
vAddressLengths = CellForEach(@length, varargin);
vbArrayAddresses = (vAddressLengths > 1);

% - Get addressing specification
stasSpecification = stTrain.mapping.stasSpecification;


% -- Get address range to search for

if (any(vbArrayAddresses))
   % - Use 'min' and 'max' to add a bit of leniency
   cellMinAddresses = CellForEachCell(@min, varargin);
   cellMaxAddresses = CellForEachCell(@max, varargin);
   
   % - Get the address range end points
   addrLogMin = STAddrLogicalConstruct(stasSpecification, cellMinAddresses{:});
   addrLogMax = STAddrLogicalConstruct(stasSpecification, cellMaxAddresses{:});
   
else
   % - We want to extract for a specific synapse
   addrLogMin = STAddrLogicalConstruct(stasSpecification, varargin{:});
   addrLogMax = addrLogMin;
end


% -- Extract address range

% - Copy the mapping
mapping.tDuration = stTrain.mapping.tDuration;
mapping.fTemporalResolution = stTrain.mapping.fTemporalResolution;
mapping.bChunkedMode = stTrain.mapping.bChunkedMode;
if (mapping.bChunkedMode)
   mapping.nNumChunks = stTrain.mapping.nNumChunks;
end

% - Copy the addressing information
mapping.stasSpecification = stasSpecification;

if (~any(vbArrayAddresses))
   % - Assign a specific synapse logical address to the mapping
   mapping.addrFields = varargin;
   mapping.addrSynapse = addrLogMin;
end

% - Extract the spike list
if (mapping.bChunkedMode)
   spikeList = stTrain.mapping.spikeList;
   nNumChunks = mapping.nNumChunks;
else
   spikeList = {stTrain.mapping.spikeList};
   nNumChunks = 1;
end

% - Filter the spike list
for (nChunkIndex = 1:nNumChunks)
   rawSpikeList = spikeList{nChunkIndex};
   vbMatchingSpikes = (rawSpikeList(:, 2) >= addrLogMin) & (rawSpikeList(:, 2) <= addrLogMax);
   spikeList{nChunkIndex} = rawSpikeList(vbMatchingSpikes, :);
end

% - Reassign the spike list
if (mapping.bChunkedMode)
   mapping.spikeList = spikeList;
else
   mapping.spikeList = spikeList{1};
end
   
% - Assign the mapping to a new spike train
stExtTrain.mapping = mapping;

% --- END of STExtract.m ---
