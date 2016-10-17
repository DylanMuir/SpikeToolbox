function [stTrainOut] = STImport(strFilename, fhCellFilters)

% FUNCTION STImport - Import a spike train from a text file
%
% Usage: [stTrainOut] = STImport(strFilename)
%        [stTrainOut] = STImport(strFilename, fhFilter)
%        [stCellTrainOut] = STImport(strFilename, fhCellFilters)
%
% Where: 'strFileName' is the name of a text file containing a spike train in
% [int_time_sig  address] format.  Time signatures are read in microseconds
% (10e-6 sec).  The resulting spike trains will be normalised to begin at the
% first spike occurring on ANY channel.
%
% In the first usage mode, the default channel filter for the spike toolbox
% will be used.  See STAccessDefaults for information on modifying this
% setting.  This filter will be applied only to channel 0.
%
% In the second usage mode, a single function handle to a channel filter
% function is supplied.  This filter will be applied only to channel 0.
%
% In the third usage mode, a cell array containing one or more function
% handles to channel filter functions must be supplied.  For each handle in
% the cell array, the corresponding spike train channel will be filtered.
% Empty cells can be used to instruct STImport to ignore that channel.
%
% The Spike Toolbox supplies two basic channel filter functions:
% STChannelFilterNeuron and STChannelFilterNeuronSynapse.
%
% STChannelFilterNeuronSynapse assumes the following input address format:
% |CHANNEL_ID (2 bits)|xxx...xxx|NEURON_ID (NEURON_BITS)|SYNAPSE_ID (SYNAPSE_BITS)|
%
% STChannelFilterNeuron assumes the following input address format:
% |CHANNEL_ID (2 bits)|xxx...xxx|NEURON_ID (NEURON_BITS)|
%
% 'NEURON_BITS' and 'SYNAPSE_BITS' are global Spike Toolbax defaults.  See
% STAccessDefaults for information on modifying these setings.
%
% Type 'help STChannelFilterDevelop' for hints on how to construct your own
% channel filter functions.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd May, 2004

% $Id: STImport.m,v 1.3 2004/07/02 13:56:49 dylan Exp $

% -- Declare globals
global	NEURON_BITS DEFAULT_CHANNEL_FILTER;
STCreateDefaults;

% -- Check input arguments

if (nargin > 5)
   disp('--- STImport: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STImport: Incorrect usage');
   help STImport;
   return;
end


% -- Extract filter function handles

if (nargin < 2)
   % - Use default filter, as defined by DEFAULT_CHANNEL_FILTER
   fhCellFilters = {DEFAULT_CHANNEL_FILTER};
   disp('--- STImport: Using default channel filter for a single train:');
   disp(DEFAULT_CHANNEL_FILTER);
end
   
if (~iscell(fhCellFilters))
   if (isa(fhCellFilters, 'function_handle'))
      % - Only filter stream 0
      fhCellFilters = {fhCellFilters};
      vbFilterChannel = {true};
      bSingleTrain = true;
   else
      % - This is an error
      disp('*** STImport: You must supply either a function handle to a filter function,');
      disp('       or a cell array of function handles');
      return;
   end
else
   % - Determine which streams to filter
   % - Which cells contain function handles?
   vbFilterChannel = CellForEach('isa', fhCellFilters, 'function_handle');
   bSingleTrain = (length(vbFilterChannel) == 1);
end


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
stTrainOut = cell(size(vbFilterChannel));

% - Detect and handle a zero-duration train
if (length(spikeList) == 0)
	mapping.tDuration = 0;
	mapping.fTemporalResolution = 1e-6;
	mapping.spikeList = [];
	mapping.bChunkedMode = false;
	stTrain.mapping = mapping;
	
	if (bSingleTrain)
		stTrainOut = stTrain;
	else
		[stTrainOut{:}] = deal(stTrain);
	end
	
	return;
end

% - Normalise train
spikeList(:, 1) = spikeList(:, 1) - spikeList(1, 1);

% - Filter each channel
for (nChannelIndex = 1:length(vbFilterChannel))
   if (vbFilterChannel(nChannelIndex))
      % - Filter the spike list
      filtSpikeList = feval(fhCellFilters{nChannelIndex}, nChannelIndex-1, spikeList);
   
      % - Create a spike train mapping
      mapping.tDuration = max(spikeList(:, 1)) * 1e-6;
      mapping.fTemporalResolution = 1e-6;
      mapping.bChunkedMode = false;
      mapping.spikeList = filtSpikeList;

      % - Assign the mapping
      stTrainOut{nChannelIndex}.mapping = mapping;
   end
end


% -- Return the cell array, or a single train

if (bSingleTrain)
   stTrainOut = stTrainOut{1};
end


% --- END of STImport.m ---

% $Log: STImport.m,v $
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
