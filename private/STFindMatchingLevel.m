function [strLevel, bError, bInvalidLevel] = STFindMatchingLevel(varargin)

% STFindMatchingLevel - FUNCTION (Internal) Find a matching spike train level
% $Id: STFindMatchingLevel.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [strLevel, bNoMatching] = STFindMatchingLevel(stTrain1, stTrain2, ...)
%        [strLevel, bNoMatching] = STFindMatchingLevel(stCellArray, ...)
%        [strLevel, bNotExisting, bInvalidLevel] = STFindMatchingLevel(strLevel, stTrain1, stTrain2, ...)
%        [strLevel, bNotExisting, bInvalidLevel] = STFindMatchingLevel(strLevel, stCellArray, ...)
%
% STFindMatchingLevel is an internal spike toolbox function.  For the first
% usage mode, STFindMatchingLevel will accept a set of spike trains 'stTrain1',
% 'stTrain2', etc. and find a spike train level (one of {'definition',
% 'instance', 'mapping'}) that exists in each train.  Levels will be searched
% from the lowest level of abstraction, ie in the order mapping, instance,
% definition.  If a matching level is found, the level name will be returned
% in 'strLevel' and 'bNoMatching' will be false.  If a level cannot be found,
% 'bNoMatching' will be true, and 'strLevel' is undefined.
%
% For the second usage mode, 'strLevel' (input) specifies a spike train level
% to attempt to match, and must be one of {'definition', 'instance', 'mapping'}.
% If this level exists in each supplied spike train, it will be returned in
% 'strLevel' and both error flags 'bNotExisting' and 'bInvalidLevel' will be
% false.  If the specified spike train level does not exist in each spike train,
% 'bNotExisting' will be true, 'bInvalidLevel' will be false and
% 'strLevel' (output) is undefined.  If 'strLevel' (input) specifies an
% unrecognised spike train level, 'bInvalidLevel' will be true, 'bNotExisting'
% will be false and 'strLevel' (output) is undefined.
% 
% STFindMatchingLevel can also accept cell arrays of spike trains in
% conjunction with both usage modes.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th April, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('--- STFindMatchingLevel: Incorrect usage.  This is an internal spike toolbox');
   disp('       function, and should not be called from the command line.');
   help private/STFindMatchingLevel;
   return;
end

if (ischar(varargin{1}))
   if (nargin < 2)
      disp('--- STFindMatchingLevel: Incorrect usage.  This is an internal spike toolbox');
      disp('       function, and should not be called from the command line.');
      help private/STFindMatchingLevel;
      return;
   end
   
   strLevel = varargin{1};
   varargin = {varargin{2:length(varargin)}};
end


% -- Convert cell array arguments

stTrain = CellFlatten(varargin{:});


% -- Check for the existence of different spike levels

vbHasDefinition = CellForEach('isfield', stTrain, 'definition');
vbHasInstance = CellForEach('isfield', stTrain, 'instance');
vbHasMapping = CellForEach('isfield', stTrain, 'mapping');


% -- Are we checking a supplied spike level, or trying to find one?

if (exist('strLevel') == 1)
   % - The user has supplied a spike level, so we should check it
   if (~STIsValidSpikeTrainLevel(strLevel))
      % - The user supplied an invalid spike train level
      bInvalidLevel = true;
      bNotExisting = false;
   else
      % - We've been supplied with a valid spike train level
      bInvalidLevel = false;
      
      % - Which level was it?
      switch lower(strLevel)
         case {'mapping', 'm'}
            if (~vbHasMapping)
               % - A mapping doesn't exist in every spike train
               bNotExisting = true;
            
            else
               bNotExisting = false;
               strLevel = 'mapping';
            end
         
         case {'instance', 'i'}
            if (~vbHasInstance)
               % - An instance doesn't exist in every spike train
               bNotExisting = true;

            else   
               bNotExisting = false;
               strLevel = 'instance';
            end
         
         case {'definition', 'd'}
            if (~vbHasDefinition)
               % - A definition doesn't exist in every spike train
               bNotExisting = true;
            
            else   
               bNotExisting = false;
               strLevel = 'definition';
            end
      end
   end

else     % - We need to work out which level to use ourselves
   if (vbHasMapping)        % First try mappings
      strLevel = 'mapping';
      bNoMatching = false;
      
   elseif (vbHasInstance)  % Then try instances
      strLevel = 'instance';
      bNoMatching = false;
      
   elseif (vbHasDefinition)  % Then try definitions
      strLevel = 'definition';
      bNoMatching = false;
      
   else  % The spike trains are incompatible
      % - We can't multiplex anything
      strLevel = '_incompatible_';
      bNoMatching = true;
   end
end


% -- Return errors

if (exist('bNotExisting') == 1)
   bError = bNotExisting;
end

if (exist('bNoMatching') == 1)
   bError = bNoMatching;
end
   
% --- END of STFindMatchingLevel.m ---
