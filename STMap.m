function [stTrain] = STMap(stTrain, varargin)

% STMap - FUNCTION Map a spike train to a specific neuron and synapse
% $Id: STMap.m 124 2005-02-22 16:34:38Z dylan $
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
vAddressArraySizes = CellForEach(@ProdSize, varargin);
vbIsArrayAddress = vAddressArraySizes > 1;

% - Should we 'cellify' the output?
bArrayTrain = iscell(stTrain);
bArrayOutput = max(vbIsArrayAddress) | bArrayTrain;


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
      nFirstArrayIndex = min(find(vAddressArraySizes > 1));
      vOutputSize = size(varargin{nFirstArrayIndex});
   end
   
   % - Convert non-array elements to arrays
   if (~bArrayTrain)
      % - Convert spike train to cell
      stTrainCell = cell(vOutputSize);
      stTrainCell(:) = deal({stTrain});
      stTrain = stTrainCell;
   end
  
   for (nAddressIndex = find(~vbIsArrayAddress))         % Only iterate over non-array fields
      % - Convert address fields to arrays
      varargin{nAddressIndex} = ones(vOutputSize) .* varargin{nAddressIndex};
   end

   % - Check that all arrays are the same size
   % - NOTE: We never need to check the spike train size
   for (nAddressIndex = 1:length(varargin))
      if (prod(size(varargin{nAddressIndex})) ~= prod(vOutputSize))
         disp('*** STMap: When arrays are supplied for input, they must all be');
         disp('       the same size');
         return;
      end
   end
   
   fprintf(1, 'Mapping: Spike train [%04d/%04d]', 0, prod(size(stTrain)));
   
   % -- Map the cell array spike trains
   % - Call STMap for each spike train
   for (nCellIndex = 1:prod(vOutputSize))
      % - Get the current address
      cAddress = num2cell(CellForEach(@Index, varargin, nCellIndex));
      
      % - Map the individually addressed train
      stTrain{nCellIndex} = STMap(stTrain{nCellIndex}, stasSpecification, cAddress{:});
      fprintf(1, '\b\b\b\b\b\b\b\b\b\b%04d/%04d]', nCellIndex, prod(size(stTrain)));
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
for (nChunkIndex = 1:nNumChunks)
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


% ProdSize - FUNCTION Find the number of elements in a matrix

function [nSize] = ProdSize(matrix)

nSize = prod(size(matrix));

% --- END of ProdSize FUNCTION ---


% Index - FUNCTION Index into a matrix argument

function [nElement] = Index(matrix, nIndex)

nElement = matrix(nIndex);

% --- END of Index FUNCTION ---

% --- END of STMap.m ---

% $Log: STMap.m,v $
% Revision 2.11  2005/02/20 13:15:08  dylan
% Modified STMap, STMultiplex, STProfileFrequency and STProfileCount to use the
% MATLAB warning system when warning about zero-duration spike trains.  These
% warnings can now be turned off using the built-in WARNING function.  The message
% ID for these warnings (and for the rest of the toolbox as well) will be
% 'SpikeToolbox:ZeroDuration'.
%
% Revision 2.10  2005/02/17 13:12:19  dylan
% * STMap now displays nice progress when mapping more than 99 spike trains.  It
% will still look horrible for more than 9999, but hopefully we won't be there
% for a while... (nonote)
%
% Revision 2.9  2004/10/28 13:53:12  dylan
% STMap now correctly handles addressing schemes with a sinlge address field (nonote)
%
% Revision 2.8  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.7  2004/09/02 08:46:47  dylan
% Bug in STMap (nonote)
%
% Revision 2.6  2004/09/02 08:44:00  dylan
% STMap now maps zero-duration spike trains with a warning.
%
% Revision 2.5  2004/09/02 08:28:22  dylan
% Type in STMap (nonote)
%
% Revision 2.4  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.3  2004/08/27 12:49:15  dylan
% Added more descriptive progress indicators to STMap and STInstantiate (nonote)
%
% Revision 2.2  2004/08/27 12:35:57  dylan
% * STMap is now forgiving of arrays of addresses that have the same number of
% elements, but a different shape.
%
% * Created a new function STIsValidSpiketrainLevel.  This function tests the
% validity of a spike train level description.
%
% * STFindMatchingLevel now uses STIsValidSpiketrainLevel.
%
% * Created a new function STStripTo.  This function strips off undesired
% spiketrain levels, leaving only the specified levels remaining.
%
% * Created a new function STStrip.  This function strips off specified
% spiketrain levels from a train.
%
% * Modified an error message within STMap.
%
% Revision 2.1  2004/07/19 16:21:02  dylan
% * Major update of the spike toolbox (moving to v0.02)
%
% * Modified the procedure for retrieving and setting toolbox options.  The new
% suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
% STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
% 'factory default' options are defined in STToolboxDefaults.  Options can be
% saved as user defaults using STOptionsSave, and will be loaded automatically
% for each session.
%
% * Removed STAccessDefaults and STCreateDefaults.
%
% * Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
% STPhysicalAddressContstruct and STPhysicalAddressExtract to
% STAddr<type><verb>
%
% * Drastically modified the way synapse addresses are specified for the
% toolbox.  A more generic approach is now taken, where addressing modes are
% defined by structures that outline the meaning of each bit-field in a
% physical address.  Fields can have their bits reversed, can be ignored, can
% have a description attached, and can be marked as major or minor fields.
% Any type of neuron/synapse topology can be addressed in this way, including
% 2D neuron arrays and chips with no separate synapse addresses.
%
% The following functions were created to handle this new addressing mode:
% STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
% STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
% STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
% STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.
%
% This modification required changes to STAddrLogicalConstruct and Extract,
% STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
% STStimulate, STMap, STCrop, STConcat and STMultiplex.
%
% * Removed the channel filter functions.
%
% * Modified STDescribe to handle the majority of toolbox variable types.
% This function will now describe spike trains, addressing specifications and
% spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
% STTrainDescribe.
%
% * Added an STIsValidSpikeTrain function to test the validity of a spike
% train structure.  Modified many spike train manipulation functions to use
% this feature.
%
% * Added features to Todo.txt, updated Readme.txt
%
% * Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
% and associated images (an_spike-big.jpg, an_spike.gif)
%
% Revision 2.0  2004/07/13 12:56:32  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
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
