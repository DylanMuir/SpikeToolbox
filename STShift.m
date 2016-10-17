function [stShiftedTrain] = STShift(stTrain, tOffset)

% FUNCTION STShift - Offset a spike train in time
%
% Usage: [stShiftedTrain] = STShift(stTrain, tOffset)
%
% 'stTrain' is an either instantiated or mapped spike train.  'tOffset' is a
% time in seconds to offset the spike train by.  'stShiftedTrain' will have an
% instance or mapping or both, depending on the input in 'stTrain'.
%
% Note that shifting a spike train definition has no effect.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 3rd May, 2004

% $Id: STShift.m,v 1.1 2004/06/04 09:35:48 dylan Exp $

% -- Check arguments

if (nargin > 2)
   disp('--- STShift: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STShift: Incorrect usage');
   help STShift;
   return;
end


% -- Shift train

if (isfield(stTrain, 'instance'))
   stShiftedTrain.instance = STShiftNode(stTrain.instance, tOffset);
end

if (isfield(stTrain, 'mapping'))
   stShiftedTrain.mapping = STShiftNode(stTrain.mapping, tOffset / stTrain.mapping.fTemporalResolution);
end

if (isfield(stTrain, 'definition'))
   disp('--- STShift: Warning: A spike train definition was stripped from the shifted train');
end

% --- FUNCTION STShiftNode

function [nodeShifted] = STShiftNode(node, tOffset)

nodeShifted = node;

% -- Handle zero-duration ndoes

if (node.tDuration == 0)
   nodeShifted = node;
   return;
end

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

% $Log: STShift.m,v $
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.3  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.2  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%