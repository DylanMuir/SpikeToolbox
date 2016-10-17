function [hFigure] = STPlotDefGamma(stDef)

% STPlotDefGamma - FUNCTION [Internal] Plot a linear frequency profile spike train definition
% $Id: STPlotDefGamma.m 2411 2005-11-07 16:48:24Z dylan $
%
% This function is NOT for command line use

% Usage: <[hFigure]> = STPlotDefGamma(stDef)
%
% 'stDef' is a definition node for a gamma isi profile spike train.  A
% plot will be made showing the definition profile.
%
% The optional return argument 'hFigure' will return the handle of the new
% figure created.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Constants

vfProbRange = 0.005:0.01:0.995;


% -- Check arguments

if (nargin < 1)
   disp('*** STPlotDefGamma: Incorrect usage');
   help private/STPlotDefGamma;
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

% - Calculate gamma function parameters
fAlpha = stDef.fMeanISI^2 / stDef.fVarISI;
fBeta = fAlpha / stDef.fMeanISI;

% - Check to see if we'll get a reasonable plot
if (fAlpha < 1)
   disp('*** STPlotDefGamma: The alpha parameter is too small for these distribution');
   disp('       parameters.  I can''t plot the distribution');
   return;
end

% - Make a new figure if required
if (bNewFigure)
   hFigure = figure;
end

% - Get the gamma function extents 
vfISI = gaminv(vfProbRange, fAlpha, 1/fBeta);

% - Plot the frequency profile
vfProb = gampdf(vfISI, fAlpha, 1/fBeta);
vfProb = vfProb ./ sum(vfProb);
plot(vfISI, vfProb);
hold on;

% - Plot the mean frequency
plot(stDef.fMeanISI .* [1 1], [min(vfProb) max(vfProb)], 'k:');

% - Set axis properties
hAxis = gca;

% - Set labels and titles
xlabel('ISI (sec)');
ylabel('Ocurrence probability');
strTitle = sprintf('Gamma ISI profile spike train definition\nISI drawing distribution');
title(strTitle);

% - Get axis extents
vAxis = axis;

% - Plot textual descriptions
fDeltaY = (vAxis(4) - vAxis(3)) / 20;
fX = ((vAxis(2) - vAxis(1)) / 50) + vAxis(1);

text(fX, 2 * fDeltaY + vAxis(3), sprintf('Mean inter-spike interval: %.2g sec', stDef.fMeanISI));
text(fX, 1 * fDeltaY + vAxis(3), sprintf('Inter-spike interval variance: %.2g sec', stDef.fVarISI));


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

% --- END of STPlotDefGamma.m ---
