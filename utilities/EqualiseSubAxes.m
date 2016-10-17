function EqualiseSubAxes(hFigure)

% EqualiseSubAxes - FUNCTION Make extents of all sub-plot axes equal
%
% Usage: EqualiseSubAxes
%        EqualiseSubAxes(hFigure)
%
% EqualiseSubAxes will find the maximum extents of all sub-plot axes of a
% figure, and set all axis extents accordingly.  The result will be a figure
% with equal axes for all sub-plots.
%
% If 'hFigure' is not supplied, the current figure will be used.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 30th August, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% $Id: EqualiseSubAxes.m 2411 2005-11-07 16:48:24Z dylan $

% -- Check arguments

if (nargin > 1)
   disp('--- EqualiseSubAxes: Extra arguments ignored');
end

if (nargin < 1)
   hFigure = gcf;
end


% -- Extract handles and axis extents

structFig = handle2struct(hFigure);

xMin = [];
xMax = [];
yMin = [];
yMax = [];

vHandAxes = {};
nNumAxes = 0;

for (nChildIndex = 1:length(structFig.children))
   if (strcmp(structFig.children(nChildIndex).type, 'axes'))
      vHandAxes{nNumAxes+1} = structFig.children(nChildIndex).handle;
      vExtents = axis(vHandAxes{nNumAxes+1});
      
      xMin = min([xMin vExtents(1)]);
      xMax = max([xMax vExtents(2)]);
      yMin = min([yMin vExtents(3)]);
      yMax = max([yMax vExtents(4)]);
      nNumAxes = nNumAxes + 1;
   end
end


% -- Apply axis extents

for (nAxisIndex = 1:nNumAxes)
   axis(vHandAxes{nAxisIndex}, [xMin xMax yMin yMax]);
end


% --- END of EqualiseSubAxes.m ---

% $Log: EqualiseSubAxes.m,v $
% Revision 1.1  2004/08/30 09:28:12  dylan
% EqualiseSubAxes added to repository
%