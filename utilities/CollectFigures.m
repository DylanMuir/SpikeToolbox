function [hFigure] = CollectFigures(arrayhFigure, fRatio)

% CollectFigures - FUNCTION Collate a set of figures into an array
%
% Usage: [hFigure] = CollectFigures(arrayhFigure, fRatio)
%
% 'arrayhFigure' is an array of figure handles.  'fRatio' defines the ratio of
% width to height for the new figure array (ie width:height = fRatio:1).  The
% real width and height will be close-ish to this ratio.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 27th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 2)
   disp('--- CollectFigures: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** CollectFigures: Incorrect usage');
   help CollectFigures;
   return;
end

% - Check 'arrayhFigure' arguments
nNumFigures = prod(size(arrayhFigure));

for (nFigureIndex = 1:nNumFigures)
   if (~ishandle(arrayhFigure(nFigureIndex)))
      disp('*** CollectFigures: Each entry in ''arrayhFigure'' should be a figure handle');
      return;
   end
end


% - Determine width and height

nArrayHeight = round(sqrt(nNumFigures / fRatio));
nArrayWidth = ceil(nNumFigures / nArrayHeight);

% - Create a new figure
hFigure = figure;

% - Copy figures
for (nFigureIndex = 1:nNumFigures)
   % - Create a subplot
   hAxis = subplot(nArrayHeight, nArrayWidth, nFigureIndex);
   
   % - Copy data
   DupFigToAxes(arrayhFigure(nFigureIndex), hAxis);
end


% --- END of CollectFigures.m ---
