function [txtTrain] = STExport(stMappedTrain, strFileName)

% FUNCTION STExport - Export a mapped spike train to a file or to text
%
% Usage: [txtTrain] = STExport(stMappedTrain)
%        [txtTrain] = STExport(stMappedTrain, strFileName)
%
% Where: 'stMappedTrain' is a previously mapped spike train.  'strFileName' is
% an optional argument specifying the name of a text file to export the spike
% train to.  The exported train will be returned as text to 'txtTrain'.  Spike
% trains are converted to [address  delta] form before export.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 23rd April, 2004

% $Id: STExport.m,v 1.2 2004/07/12 10:10:34 dylan Exp $

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


% -- Check that the spike train has a mapping

if (~isfield(stMappedTrain, 'mapping'))
   disp('*** STExport: Only mapped spike trains can be exported');
   return;
end

% -- Check that the mapping is not of zero duration

if (stMappedTrain.mapping.tDuration == 0)
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
   
   % - Convert to physical addresses
   [nNeuron, nSynapse] = STExtractLogicalAddress(rawSpikeList(:, 2));
   rawSpikeList(:, 2) = STConstructPhysicalAddress(nNeuron, nSynapse);
   
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