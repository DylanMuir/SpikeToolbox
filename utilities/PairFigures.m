function [vHandles] = PairFigures(vHandlesLeft, vHandlesRight)

% PairFigures - FUNCTION Takes two lists of figure handles and pairs them
%
% Usage: [vHandles] = PairFigures(vHandlesLeft, vHandlesRight)
%
% 'vHandles...' contain the same number of figure handles each. PairFigures
% will create new figures, and take figures from '...Left' to put in the
% left hand half and figures from '...Right' to put in the right hand half.
% PairFigures will return a vector of figure handles to the crated figures.
%
% Use fh = figure(n) to retrieve figure handles.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 30th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% $Id: PairFigures.m 2411 2005-11-07 16:48:24Z dylan $

% -- Check arguments

if (nargin > 2)
   disp('--- PairHandles: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** PairFigures: Incorrect usage');
   help PairFigures;
   return;
end

% - Check that handle lists are the same length
if (prod(size(vHandlesLeft)) ~= prod(size(vHandlesRight)))
   disp('*** PairFigures: The handles lists must have the same number of entries');
   return;
end

% - Check that all entries are handles
cellHandLeft = num2cell(vHandlesLeft);
cellHandRight = num2cell(vHandlesRight);

vbIsHandle = [CellForEach('ishandle', {cellHandLeft{:} cellHandRight{:}})];

if (max(~vbIsHandle))
   disp('*** PairFigures: One or more entries in the handles arrays was not a figure handle');
end


% -- Collect the figures into paired figures

nNumFigures = prod(size(vHandlesLeft));
for (nFigIndex = 1:nNumFigures)
   % - Create a new figure
   vHandles(nFigIndex) = figure;
   hAxesLeft = subplot(1, 2, 1);
   hAxesRight = subplot(1, 2, 2);
   
   % - Move the left and right figure
   DupFigToAxes(vHandlesLeft(nFigIndex), hAxesLeft);
   DupFigToAxes(vHandlesRight(nFigIndex), hAxesRight);
end


% --- END of PairFigures.m --- %

% $Log: PairFigures.m,v $
% Revision 1.1  2004/08/02 08:45:56  dylan
% Added a function 'PairFigures' to group a list of figures into pairs
%
