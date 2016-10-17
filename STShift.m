function [stShiftedTrain] = STShift(stTrain, tOffset)

% STShift - FUNCTION Offset a spike train in time
% $Id: STShift.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stShiftedTrain] = STShift(stTrain, tOffset)
%
% 'stTrain' is an either instantiated or mapped spike train.  'tOffset' is a
% time in seconds to offset the spike train by.  'stShiftedTrain' will have an
% instance or mapping or both, depending on the input in 'stTrain'.
%
% Note that shifting a spike train with a definition will strip the definition
% from the train.  Shifting a spike train with only a definition will erase
% the train and STShift will return an empty matrix.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 3rd May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- STShift: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STShift: Incorrect usage');
   help STShift;
   return;
end

% - Test for zero-duration spike trains
if (STIsZeroDuration(stTrain))
   stShiftedTrain = stTrain;
   return;
end


% -- Shift train

if (FieldExists(stTrain, 'instance'))
   stShiftedTrain.instance = STShiftNode(stTrain.instance, tOffset);
   stShiftedTrain.instance.tDuration = stShiftedTrain.instance.tDuration + tOffset;
end

if (FieldExists(stTrain, 'mapping'))
	% - How many time bins should we shift?
	nBinOffset = round(tOffset / stTrain.mapping.fTemporalResolution);
	
	% - Are we shifting at all?
	if (abs(nBinOffset) < 1)
		disp('--- STShift: The time offset was negligible for shifting the mapped train');
		stShiftedTrain.mapping = stTrain.mapping;
	else
		stShiftedTrain.mapping = STShiftNode(stTrain.mapping, nBinOffset);
	end
   
   % - Shift duration
   stShiftedTrain.mapping.tDuration = stShiftedTrain.mapping.tDuration + tOffset;
end

if (isfield(stTrain, 'definition'))
   disp('--- STShift: Warning: A spike train definition was stripped from the shifted train');
end

if (~exist('stShiftedTrain', 'var'))
   disp('--- STShift: There''s nothing left!');
   stShiftedTrain = [];
end

% --- FUNCTION STShiftNode

function [nodeShifted] = STShiftNode(node, tOffset)

nodeShifted = node;

% - Extract the spike train

if (node.bChunkedMode)
   spikeList = node.spikeList;
else
   spikeList = {node.spikeList};
end

% - Shift the spike train

for (nChunkIndex = 1:length(spikeList))
   spikeList{nChunkIndex}(:, 1) = spikeList{nChunkIndex}(:, 1) + tOffset;
end

% - Reassign the shifted spike list

if (node.bChunkedMode)
   nodeShifted.spikeList = spikeList;
else
   nodeShifted.spikeList = spikeList{1};
end

% --- END of STShift.m ---
