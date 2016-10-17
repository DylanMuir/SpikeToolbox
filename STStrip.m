function [stStrippedTrain] = STStrip(stTrain, varargin)

% STStrip - FUNCTION Strip specified spike train levels from spike trains
% $Id: STStrip.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stStrippedTrain] = STStrip(stTrain, strLevel, strLevel, ...)
% Usage: [stCellStrippedTrain] = STStrip(stCellTrain, strLevel, strLevel, ...)
%
% 'stTrain' is a Spike Toolbox spike train object.  Spike train levels listed
% in the function arguments will be stripped from 'stTrain'.  If all levels
% are stripped from a train, an empty object will be returned.
%
% STStrip can accept a cell array of spike trains as its first argument.  In
% this case, each spike train will be stripped and returned in each element of
% 'stCellStrippedTrain'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 27th August, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STStrip: Incorrect usage');
   help STStrip;
   return;
end


% -- Test supplied levels

vbValidLevels = CellForEach(@STIsValidSpikeTrainLevel, varargin);

if (any(~vbValidLevels))
   disp('--- STStrip: Warning: Invalid spike train levels supplied.  These');
   disp('       will be ignored.');
   
   if (any(vbValidLevels))
      % - Keep only valid spike train levels
      varargin = varargin{find(vbValidLevels)};
   end
end


% -- Deal with a cell array of spike trains

if (iscell(stTrain))
   stStrippedTrain = CellForEachCell(@STStrip, stTrain, varargin{:});
   return;
end


% -- Deal with a canonical spike train object

stStrippedTrain = stTrain;

for (nLevelIndex = 1:length(varargin))
   % - Get the canonical name for a spike train level
   [nul, strLevel] = STIsValidSpikeTrainLevel(varargin{nLevelIndex});
   
   % - Does the specified level exist in the source train?
   if (isfield(stTrain, strLevel))
      % - Strip the specified level
      stStrippedTrain = rmfield(stStrippedTrain, strLevel);
   end
end


% - Was there anything left?

if (numel(fieldnames(stStrippedTrain)) == 0)
   % - We're left with an empty object
   stStrippedTrain = [];
   disp('--- STStrip: Warning: All spike train levels were stripped from the train');
end


% --- END of STStripTo.m ---
