function [stStrippedTrain] = STStripTo(stTrain, varargin)

% STStripTo - FUNCTION Strip undesired spike train levels from spike trains
% $Id: STStripTo.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stStrippedTrain] = STStripTo(stTrain, strLevel, strLevel, ...)
% Usage: [stCellStrippedTrain] = STStripTo(stCellTrain, strLevel, strLevel, ...)
%
% 'stTrain' is a Spike Toolbox spike train object.  Spike train levels will be
% stripped from the train if they don't appear in the list of desired levels.
% Only the levels listed will remain in 'stStrippedTrain'.  If a listed level
% is not present in the train, then a warning will be printed.  If all levels
% are stripped from a train, an empty object will be returned.
%
% STStripTo can accept a cell array of spike trains as its first argument.  In
% this case, each spike train will be stripped and returned in each element of
% 'stCellStrippedTrain'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 27th August, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STStripTo: Incorrect usage');
   help STStripTo;
   return;
end


% -- Test supplied levels

vbValidLevels = CellForEach(@STIsValidSpikeTrainLevel, varargin);

if (any(~vbValidLevels))
   disp('--- STStripTo: Warning: Invalid spike train levels supplied.  These');
   disp('       will be ignored.');
   
   if (any(vbValidLevels))
      % - Keep only valid spike train levels
      varargin = varargin{find(vbValidLevels)};
   end
end


% -- Deal with a cell array of spike trains

if (iscell(stTrain))
   stStrippedTrain = CellForEachCell(@STStripTo, stTrain, varargin{:});
   return;
end


% -- Deal with a canonical spike train object

stStrippedTrain = [];

for (nLevelIndex = 1:length(varargin))
   % - Get the canonical name for a spike train level
   [nul, strLevel] = STIsValidSpikeTrainLevel(varargin{nLevelIndex});
   
   % - Does the specified level exist in the source train?
   if (isfield(stTrain, strLevel))
      % - Copy the specified level
      stStrippedTrain.(strLevel) = stTrain.(strLevel);
   end
end


% --- END of STStripTo.m ---
