function [txtTrain] = STExport(stMappedTrain, strFileName)

% STExport - FUNCTION Export a mapped spike train to a file or to text
% $Id: STExport.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [txtTrain] = STExport(stMappedTrain)
%        [txtTrain] = STExport(stMappedTrain, strFileName)
%
% Where: 'stMappedTrain' is a previously mapped spike train.  'strFileName' is
% an optional argument specifying the name of a text file to export the spike
% train to.  The exported train will be returned as text to 'txtTrain'.  Spike
% trains are converted to [delta  addrPhys] form before export, where 'delta'
% is an inter-spike interval and 'addrPhys' is a physical address as created
% by STAddrPhysicalConstruct.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 23rd April, 2004

% -- Check arguments

if (nargin > 2)
   disp('--- STExport: Extra arguments ignored');
end

bWriteFile = false;
if (nargin > 1)
   bWriteFile = true;
end

if (nargin < 1)
   disp('*** STExport: Incorrect usage');
   help STExport;
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


% -- Export the spike train

% - Extract spike list and convert to delay format
if (stMappedTrain.mapping.bChunkedMode)
   spikeList = stMappedTrain.mapping.spikeList;
else
   spikeList = {stMappedTrain.mapping.spikeList};
end

txtTrain = [];

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
      rawSpikeList(:, 1) = rawSpikeList(:, 1) - [tLastSpike; rawSpikeList(1:length(rawSpikeList)-1, 1)];
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
   
   % - Rearrange columns
   %rawSpikeList = [rawSpikeList(:, 2) rawSpikeList(:, 1)];

   % - Convert to text
   txtTrain = strcat(txtTrain, sprintf('%d\t%d\n', reshape(rawSpikeList', prod(size(rawSpikeList)), 1)));
   txtTrain = strcat(txtTrain, '\n');  % Add some more whitespace to the end of each chunk
end
   
% - Should we write the text to a file?
if (bWriteFile)
   % - Check to see if we're overwriting an existing file
   if (exist(strFileName) == 2)
      disp(sprintf('--- STExport: Warning: The file [%s] already exists.  Overwriting...', strFileName));
   end
   
   [hExpFile, strErr] = fopen(strFileName, 'wt');
   
   if (~hExpFile)
      disp(sprintf('*** STExport: Could not open file [%s] for writing: [%s]', strFileName, strErr));
      return;
   end
   
   fprintf(hExpFile, txtTrain);
   fclose(hExpFile);
   
   % - If we wrote to a file, we don't need to dump the text to the console
   %   unless the user REALLY wants us to!
   if (nargout < 1)
      clear txtTrain;
   end
end

% --- END of STExport.m ---

% $Log: STExport.m,v $
% Revision 2.3  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.2  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
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
% Revision 2.0  2004/07/13 12:56:31  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.3  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.2  2004/07/12 10:10:34  dylan
% Modified STExport to use [isi addr] format.  Added a feature request to Todo.txt
%
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.11  2004/05/10 09:07:18  dylan
% Bug fixes (nonote)
%
% Revision 1.10  2004/05/10 08:37:17  dylan
% Bug fixes
%
% Revision 1.9  2004/05/10 08:26:44  dylan
% Bug fixes
%
% Revision 1.8  2004/05/09 17:55:15  dylan
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
% Revision 1.7  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.6  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%