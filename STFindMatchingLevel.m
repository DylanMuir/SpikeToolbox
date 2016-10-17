function [strLevel, bError, bInvalidLevel] = STFindMatchingLevel(varargin)

% FUNCTION STFindMatchingLevel - (Internal) Find a matching spike train level
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

% $Id: STFindMatchingLevel.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Check arguments

if (nargin < 1)
   disp('--- STFindMatchingLevel: Incorrect usage.  This is an internal spike toolbox');
   disp('       function, and should not be called from the command line.');
   help STFindMatchingLevel;
   return;
end

if (ischar(varargin{1}))
   if (nargin < 2)
      disp('--- STFindMatchingLevel: Incorrect usage.  This is an internal spike toolbox');
      disp('       function, and should not be called from the command line.');
      help STFindMatchingLevel;
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
   switch lower(strLevel)
      case {'mapping', 'm'}
         if (~vbHasMapping)
            % - A mapping doesn't exist in every spike train
            bInvalidLevel = false;
            bNotExisting = true;
            
         else   
            bInvalidLevel = false;
            bNotExisting = false;
            strLevel = 'mapping';
         end
         
      case {'instance', 'i'}
         if (~vbHasInstance)
            % - An instance doesn't exist in every spike train
            bInvalidLevel = false;
            bNotExisting = true;
            
         else   
            bInvalidLevel = false;
            bNotExisting = false;
            strLevel = 'instance';
         end
         
      case {'definition', 'd'}
         if (~vbHasDefinition)
            % - A definition doesn't exist in every spike train
            bInvalidLevel = false;
            bNotExisting = true;
            
         else   
            bInvalidLevel = false;
            bNotExisting = false;
            strLevel = 'definition';
         end
         
      otherwise
         % - The user supplied an invalid spike train level
         bInvalidLevel = true;
         bNotExisting = false;
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

% $Log: STFindMatchingLevel.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.4  2004/05/14 15:37:19  dylan
% * Created utilities/CellFlatten.m -- CellFlatten coverts a list of items
% into a cell array containing a single cell for each item.  CellFlatten will
% also flatten the heirarchy of a nested cell array, returning all cell
% elements on a single dimension
% * Created utiltites/CellForEach.m -- CellForEach executes a specified
% function for each top-level element of a cell array, and returns a matrix of
% the results.
% * Converted spike_tb/STFindMatchingLevel to natively process cell arrays of trains
% * Converted spike_tb/STMultiplex to natively process cell arrays of trains
% * Created spike_tb/STCrop.m -- STCrop will crop a spike train to a specified
% time extent
% * Created spike_tb/STNormalise.m -- STNormalise will shift a spike train to
% begin at zero (first spike is at zero) and correct the duration
%
% Revision 1.3  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%