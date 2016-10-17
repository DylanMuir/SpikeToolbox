function [varargout] = STPciaerImport(strFilename, cellstasChannelSpecs, stasChannelID)

% STPciaerImport - FUNCTION Import a spike train observed from the PCI-AER monitor
% $Id: STPciaerImport.m 3985 2006-05-09 13:03:02Z dylan $
%
% Usage: [stTrainOut1, stTrainOut2, ...] = STPciaerImport(strFilename ...
%           <, cellstasChannelSpecs, stasChannelID>)
%        [...] = STPciaerImport(mSpikes <, cellstasChannelSpecs, stasChannelID>)
%
% Where: 'strFileName' is the name of a text file containing a spike train in
% [int_time_sig  address] format.  Time signatures are read in microseconds
% (10e-6 sec).  The resulting spike trains will be normalised to begin at the
% first spike occurring on ANY channel.
%
% Alternatively, a matrix of spike times and addresses can be supplied in
% 'mSpikes'.  Each row of this matrix should be in [int_time_sig  address]
% format.
%
% The text file or matrix can optionally be in [isi  address] format.  ISIs
% should be in microseconds (10e-6 sec).
%
% STPciaerImport needs to know two things in order to filter the input spikes:  The
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
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Constants
fImportTemporalFrequency = 1e-6;    % 1 usec

% -- Get options
stOptions = STOptions;


% -- Check input arguments

if (nargin > 3)
   disp('--- STPciaerImport: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STPciaerImport: Incorrect usage');
   help STPciaerImport;
   return;
end

if (nargin < 3)
   % - The user didn't supply a channel ID address specification
   %   Get the default
   stasChannelID = stOptions.stasMonitorChannelID;
end
   
% - Check the monitor channel ID address specification
if (~STIsValidChannelAddrSpec(stasChannelID))
   disp('*** STPciaerImport: Invalid address specification supplied for the channel ID addressing');
   return;
end

if (nargin < 2)
   % - The user didn't supply monitor addressing specifications
   %   Get the default
   cellstasChannelSpecs = stOptions.MonitorChannelsAddressing;
end

% - Check the monitor channel addressing specs
if (~STIsValidMonitorChannelsSpecification(cellstasChannelSpecs))
   disp('*** STPciaerImport: Invalid specification supplied for monitor channel addressing');
   return;
end
      
% - Determine which streams to filter
vbFilterChannel = CellForEach(@STIsValidAddrSpec, cellstasChannelSpecs);


% -- Test if we should load a file, and if the file exists, load it

if (isa(strFilename, 'char'))
   if (~exist(strFilename, 'file'))
      SameLinePrintf('*** STPciaerImport: File [%s] does not exist.\n', strFilename);
      return;
   else
      % - Read spike list as a vector
      spikeList = load(strFilename);
   end
else
   % - Use the supplied matrix
   spikeList = strFilename;
end


% -- Filter spike train channels

% - Create the output cell array
varargout = cell(size(vbFilterChannel));

% - Detect and handle a zero-duration train
if (isempty(spikeList))
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
[nul nIndex] = min(spikeList(:, 1));
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

nReturnIndex = 1;
for (nChannelIndex = 1:length(vbFilterChannel))
   if (vbFilterChannel(nChannelIndex))
      % - Filter the spike list
      filtSpikeList = spikeList(vChannelIDs == (nChannelIndex-1), :);
   
      % - Detect and handle a zero-duration train
      if (isempty(filtSpikeList))
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
      varargout{nReturnIndex}.mapping = mapping;
      
      % - Move to the next output argument
      nReturnIndex = nReturnIndex + 1;
   end
end


% --- END of STPciaerImport.m ---
