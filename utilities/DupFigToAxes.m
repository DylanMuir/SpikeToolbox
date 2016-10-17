function DupFigToAxes(hFigure, hAxis)

% DupFigToAxes - FUNCTION Duplicate an existing figure to a new set of axes
%
% Usage: DupFigToAxes(hFigure, hAxis)
%
% 'hFigure' is a handle to a figure.  'hAxis' is a handle to a
% previously-created set of axes, for example axes created using subplot.
% DupFigToAxes will recreate the figure 'hFigure' inside axes 'hAxis',
% including all view properties.
%
% This function is useful for moving a figure into an array of figures.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 27th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- DupFigToAxes: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** DupFigToAxes: Incorrect number of arguments');
   help DupFigToAxes;
   return;
end

if (~ishandle(hFigure) | ~ishandle(hAxis))
   disp('*** DupFigToAxes: Supplied arguments must be graphics handles');
   return;
end


% -- Duplicate figure

% - Get graphics structure from 'hFigure'
structFigure = handle2struct(hFigure);

% - Recreate the figure in 'hAxis'
%   'end:-1:1' is needed because struct2handle reverses the order of the
%   children
struct2handle(structFigure.children.children(end:-1:1), hAxis);

% - Copy old axis properties
propAxis = structFigure.children.properties;
propAxis = rmfield(propAxis, 'ApplicationData');

% - Copy old figure properties
propFigure = structFigure.properties;
propFigure = rmfield(propFigure, 'ApplicationData');


% - Set new axis and figure properties
set(get(hAxis, 'Parent'), propFigure);
set(hAxis, propAxis);


% - Done!

% --- END of DupFigToAxes.m ---
