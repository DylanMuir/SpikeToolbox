function [varargout] = STImport(strFilename, cellstasChannelSpecs, stasChannelID)

% STImport - FUNCTION Import a spike train from a text file
% $Id: STImport.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stTrainOut1, stTrainOut2, ...] = STImport(strFilename <, cellstasChannelSpecs, stasChannelID>)
%
% Where: 'strFileName' is the name of a text file containing a spike train in
% [int_time_sig  address] format.  Time signatures are read in microseconds
% (10e-6 sec).  The resulting spike trains will be normalised to begin at the
% first spike occurring on ANY channel.
%
% The text file can optionally be in [isi  address] format.  ISIs should be in
% microseconds (10e-6 sec).
%
% STImport needs to know two things in order to filter the input spikes:  The
% addressing specification of the monitor channel ID field; and the addressing
% specifications to use for each of the monitor channels.  These
% specifications can be either taken from the toolbox options (by default), or
% supplied in the argument list.
%
% The optional argument 'cellstasChannelSpecs' should be a cell array with one
% entry for each monitor channel to retrieve spikes from.  Empty matrices in
% this cell array indicate monitor channels to ignore (ie. a spike train will
% not be returned for that channel).
%
% The optional argument 'stasChannelID' should be a valid addressing
% specification, with the following restrictions: it must contain two fields
% only, the first of which is marked to ignore, the second of which must
% define the addressing field for the channel ID.  This second field must not
% be marked to ignore.  The descriptions for these fields are not important.
%
% The Spike Toolbox provides a function 'STAddrSpecChannel' which generates
% valid channel ID addressing specifications.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd May, 2004

% -- Constants
fImportTemporalFrequency = 1e-6;    % 1 usec

% -- Get options
stOptions = STOptions;


% -- Check input arguments

if (nargin > 3)
   disp('--- STImport: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STImport: Incorrect usage');
   help STImport;
   return;
end

if (nargin < 3)
   % - The user didn't supply a channel ID address specification
   %   Get the default
   stasChannelID = stOptions.stasMonitorChannelID;
end
   
% - Check the monitor channel ID address specification
if (~STIsValidChannelAddrSpec(stasChannelID))
   disp('*** STImport: Invalid address specification supplied for the channel ID addressing');
   return;
end

if (nargin < 2)
   % - The user didn't supply monitor addressing specifications
   %   Get the default
   cellstasChannelSpecs = stOptions.MonitorChannelsAddressing;
end

% - Check the monitor channel addressing specs
if (~STIsValidMonitorChannelsSpecification(cellstasChannelSpecs))
   disp('*** STImport: Invalid specification supplied for monitor channel addressing');
   return;
end
      
% - Determine which streams to filter
% - Which cells contain function handles?
vbFilterChannel = CellForEach(@STIsValidAddrSpec, cellstasChannelSpecs);


% -- Test if file exists

if (exist(strFilename, 'file') == 0)
   SameLinePrintf('*** STImport: File [%s] does not exist.\n', strFilename);
   return;
end


% -- Import spike train
% - Read spike list as a vector
spikeList = load(strFilename);

% -- Filter spike train channels

% - Create the output cell array
varargout = cell(size(vbFilterChannel));

% - Detect and handle a zero-duration train
if (length(spikeList) == 0)
	mapping.tDuration = 0;
	mapping.fTemporalResolution = fImportTemporalFrequency;
	mapping.stasSpecification = STAddrSpecIgnoreSynapseNeuron(1, 0, 0);
	mapping.spikeList = [];
	mapping.bChunkedMode = false;
	stTrain.mapping = mapping;
	
	[varargout{:}] = deal(stTrain);
	return;
end

% -- Determine whether we're using ISIs or not
vISIs = diff(spikeList(:, 1));

% - If more than some arbitrary number of ISIs are negative, we were probably
% using ISIs anyway
if (sum(vISIs < 0) > 4)
   % - Convert to absolute timestamp mode
   spikeList(:, 1) = fix(cumsum(spikeList(:, 1)));
end

% - Throw away pre-stimulus activity:
%   The PCIAER board timestamp counter may have wrapped around, with spikes
%   still left in the monitor FIFO.
[tMinTime nIndex] = min(spikeList(:, 1));
spikeList = spikeList(nIndex:end, :);

% - Normalise train
spikeList(:, 1) = spikeList(:, 1) - spikeList(1, 1);


% -- Filter each channel

% - Get the channel IDs
vAddresses = spikeList(:, 2);
nIgnoreBits = stasChannelID(1).nWidth;
nChannelIDBits = stasChannelID(2).nWidth;
vShifted = fix(vAddresses .* 2^(-nIgnoreBits));
vMasked = bitshift(vShifted, 0, nChannelIDBits);
vChannelIDs = vMasked;

for (nChannelIndex = 1:length(vbFilterChannel))
   if (vbFilterChannel(nChannelIndex))
      % - Filter the spike list
      filtSpikeList = spikeList(find(vChannelIDs == (nChannelIndex-1)), :);
   
      % - Detect and handle a zero-duration train
      if (length(filtSpikeList) == 0)
	      mapping.tDuration = 0;
      	mapping.fTemporalResolution = fImportTemporalFrequency;
         mapping.stasSpecification = STAddrSpecIgnoreSynapseNeuron(1, 0, 0);
	      mapping.spikeList = [];
	      mapping.bChunkedMode = false;
	      stTrain.mapping = mapping;
	      varargout{nChannelIndex} = stTrain;
         continue;
      end
      
      % - Create a spike train mapping
      clear mapping;
      mapping.tDuration = max(spikeList(:, 1)) * fImportTemporalFrequency;
      mapping.fTemporalResolution = fImportTemporalFrequency;
      mapping.bChunkedMode = false;
      stasSpecification = cellstasChannelSpecs{nChannelIndex};
      mapping.stasSpecification = stasSpecification;
      
      % - Filter spikes through the addressing format
      nRequiredFields = sum(~[stasSpecification.bIgnore]);
      clear addr;
      [addr{1:nRequiredFields}] = STAddrPhysicalExtract(filtSpikeList(:, 2), stasSpecification);
      filtSpikeList(:, 2) = STAddrLogicalConstruct(addr{:}, stasSpecification);
      mapping.spikeList = filtSpikeList;
      
      % - Assign the mapping
      varargout{nChannelIndex}.mapping = mapping;
   end
end


% --- END of STImport.m ---

% $Log: STImport.m,v $
% Revision 2.6  2005/02/17 12:40:02  dylan
% * Modified STImport to be able to import stimulus trains in [ISI addr] format,
% as well as monitored trains in [timestamp addr] format.
%
% Revision 2.5  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.4  2004/08/30 13:04:30  dylan
% Fixed a bug in STImport.  STImport would not create a zero-duration spike train
% when the multiplexed imported spike train contained spikes.  STImport now
% correctly imports and creates zero-duration spike trains.
%
% Revision 2.3  2004/08/02 14:40:49  chiara
% cvs comment:
% Added files:
% STplot2DRaster.m: raster plot for a 2D array, with different colors
% for different rows of the array
% STPlot2DMeanFreq.m: imagesc plot of the mean frequency of each pixel
% in a 2D array
% Modified files:
% STAddrPhysicalExtract.m: fixed a bug for the inversion of the
% addresses in negative logic
% STImport.m: modified the acquisition of he spike train to cut off the
% initial part of spontaneous activity: the monitored spike train starts with the
% beginning of the stimulation
%
% Revision 2.2  2004/07/22 11:39:54  dylan
% Fixed a bug in STImport and STStimulate (nonote)
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
% Revision 1.4  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.3  2004/07/02 13:56:49  dylan
% Fixed how STImport handles a zero-duration spiketrain
%
% Revision 1.2  2004/07/02 12:49:18  dylan
% Fixed a bug in STImport when importing a zero-length spike train
%
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.7  2004/05/19 07:56:50  dylan
% * Modified the syntax of STImport -- STImport now uses an updated version
% of stimmon, which acquires data from all four PCI-AER channels.  STImport
% now imports to a cell array of spike trains, one per channel imported.
% Which channels to import can be specified through the calling syntax.
% * STImport uses channel filter functions to handle different addressing
% formats on the AER bus.  Added two standard filter functions:
% STChannelFilterNeuron and STChannelFilterNeuronSynapse.  Added help files
% for this functionality: STChannelFiltersDescription,
% STChannelFilterDevelop
%
% Revision 1.6  2004/05/09 17:55:15  dylan
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
% Revision 1.5  2004/05/07 13:50:35  dylan
% Merged STImport with new changes
%
% Revision 1.4  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%
