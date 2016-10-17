function [mHardTrain] = STPciaerExport(stMappedTrain, strFileName)

% STPciaerExport - FUNCTION Export a mapped spike train to a file or to text
% $Id: STPciaerExport.m 11393 2009-04-02 13:48:59Z dylan $
%
% Usage: [mHardTrain] = STPciaerExport(stMappedTrain)
%        [mHardTrain] = STPciaerExport(stMappedTrain, strFileName)
%
% Where: 'stMappedTrain' is a previously mapped spike train.  'strFileName' is
% an optional argument specifying the name of a text file to export the spike
% train to.  The exported train will be returned in 'mHardTrain'.  Spike
% trains are converted to [delta  addrPhys] form before export, where 'delta'
% is an inter-spike interval and 'addrPhys' is a physical address as created
% by STAddrPhysicalConstruct.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 23rd April, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get toolbox options
stO = STOptions;


% -- Check arguments

if (nargin > 2)
   disp('--- STPciaerExport: Extra arguments ignored');
end

bWriteFile = false;
if (nargin > 1)
   bWriteFile = true;
end

if (nargin < 1)
   disp('*** STPciaerExport: Incorrect usage');
   help STPciaerExport;
   return;
end


% -- Check for a valid spike train

if (~STIsValidSpikeTrain(stMappedTrain))
   disp('*** STPciaerExport: Invalid spike train supplied');
   return;
end


% -- Check that the spike train has a mapping

if (~isfield(stMappedTrain, 'mapping'))
   disp('*** STPciaerExport: Only mapped spike trains can be exported');
   return;
end


% -- Check that the mapping is not of zero duration

if (STIsZeroDuration(stMappedTrain))
   disp('*** STPciaerExport: Cannot export a zero-duration spike train');
   return;
end


% -- Export the spike train

% - Extract spike list and convert to delay format
if (stMappedTrain.mapping.bChunkedMode)
   spikeList = stMappedTrain.mapping.spikeList;
else
   spikeList = {stMappedTrain.mapping.spikeList};
end

% - Preallocate export matrix
mHardTrain = [];
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
   
   % -- Convert to physical addresses
   % - Use the specified translation function
   nRequiredAddressFields = sum(~[stasSpecification.bIgnore]);
   [addr{1:nRequiredAddressFields}] = STAddrLogicalExtract(rawSpikeList(:, 2), stasSpecification);
   rawSpikeList(:, 2) = stO.fhHardwareAddressConstruction(stasSpecification, addr{:});
   
   % - Rearrange columns
   %rawSpikeList = [rawSpikeList(:, 2) rawSpikeList(:, 1)];

   % - Convert to text
   txtTrain = strcat(txtTrain, sprintf('%d\t%d\n', reshape(rawSpikeList', numel(rawSpikeList), [])));
   txtTrain = strcat(txtTrain, '\n');  % Add some more whitespace to the end of each chunk
   
   % - Append to spike list
   mHardTrain = vertcat(mHardTrain, rawSpikeList);
end
   
% - Should we write the text to a file?
if (bWriteFile)
   % - Check to see if we're overwriting an existing file
   if (exist(strFileName, 'file') == 2)
      disp(sprintf('--- STExport: Warning: The file [%s] already exists.  Overwriting...', strFileName));
   end
   
   [hExpFile, strErr] = fopen(strFileName, 'wt');
   
   if (~hExpFile)
      disp(sprintf('*** STExport: Could not open file [%s] for writing: [%s]', strFileName, strErr));
      return;
   end
   
   fprintf(hExpFile, txtTrain);
   fclose(hExpFile);
end

% --- END of STPciaerExport.m ---
