function [hFigure] = STPlotDefLinear(stDef)

% STPlotDefLinear - FUNCTION [Internal] Plot a linear frequency profile spike train definition
% $Id: STPlotDefLinear.m 2411 2005-11-07 16:48:24Z dylan $
%
% This function is NOT for command line use

% Usage: <[hFigure]> = STPlotDefLinear(stDef)
%
% 'stDef' is a definition node for a linear frequency profile spike train.  A
% plot will be made showing the definition profile.
%
% The optional return argument 'hFigure' will return the handle of the new
% figure created.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STPlotDefLinear: Incorrect usage');
   help private/STPlotDefLinear;
   return;
end

% - We should keep the figure handle if the user has requested it
bKeepHandle = (nargout > 0);


% -- Get the current figure information

hFigure = get(0, 'CurrentFigure');

% - Is there a figure at all?  Do we need to make a new one?
bNewFigure = isempty(hFigure);

% - Save previous hold state
if (bNewFigure)
   bHold = false;
else
   bHold = ishold;
end


% -- Construct the plot

% - Make a new figure if required
if (bNewFigure)
   hFigure = figure;
end

% - Plot the frequency profile
plot([0 1], [stDef.fStartFreq stDef.fEndFreq]);

% - Set axis properties
hAxis = gca;
set(hAxis, 'XTick', []);

% - Set labels and titles
xlabel('Spike train duration');
ylabel('Spiking frequency (Hz)');
strTitle = sprintf('Linear frequency profile spike train definition\nSpike frequency profile');
title(strTitle);


% -- Clean up figure properties

% - Make sure the 'hold' property is set properly
if (bHold)
   hold on;
else
   hold off;
end

% - Should we return the figure handle?
if (~bKeepHandle)
   clear hFigure;
end

% --- END of STPlotDefLinear.m ---
