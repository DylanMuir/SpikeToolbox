function [hFigure] = STPlotDefSinusoid(stDef)

% STPlotDefSinusoid - FUNCTION [Internal] Plot a sinusoidal frequency profile spike train definition
% $Id: STPlotDefSinusoid.m 2411 2005-11-07 16:48:24Z dylan $
%
% This function is NOT for command line use

% Usage: <[hFigure]> = STPlotDefSinusoid(stDef)
%
% 'stDef' is a definition node for a sinusoid frequency profile spike train.  A
% plot will be  made showing one cycle of the definition profile.
%
% The optional return argument 'hFigure' will return the handle of the new
% figure created.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 28th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Constants

nSamplePoints = 100;


% -- Check arguments

if (nargin < 1)
   disp('*** STPlotDefSinusoid: Incorrect usage');
   help private/STPlotDefSinusoid;
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

% - Make a sampling vector
tDelta = stDef.tPeriod / nSamplePoints;
vtTime = 0:tDelta:stDef.tPeriod;
fAmplitude = (stDef.fMaxFreq - stDef.fMinFreq) / 2;
vfProfile = fAmplitude .* (sin(2 * pi / stDef.tPeriod * vtTime) + 1) + stDef.fMinFreq;
fMeanFreq = (stDef.fMaxFreq + stDef.fMinFreq) / 2;

% - Plot the frequency profile
plot(vtTime, vfProfile);
hold on;

% - Plot the average frequency
plot([0 stDef.tPeriod], fMeanFreq .* [1 1], 'k:');

% - Set axis properties
hAxis = gca;

% - Set labels and titles
xlabel('Frequency profile cycle time (sec)');
ylabel('Spiking frequency (Hz)');
strTitle = sprintf('Sinusoid frequency profile spike train definition\nSpike frequency profile shown for one cycle');
title(strTitle);

% - Get axis extents
axis tight;
vAxis = axis;

% - Plot textual descriptions
fDeltaY = (vAxis(4) - vAxis(3)) / 20;
fX = stDef.tPeriod / 50;

text(fX, 4 * fDeltaY + vAxis(3), sprintf('Min frequency: %.2f Hz', stDef.fMinFreq));
text(fX, 3 * fDeltaY + vAxis(3), sprintf('Max frequency: %.2f Hz', stDef.fMaxFreq));
text(fX, 2 * fDeltaY + vAxis(3), sprintf('Mean frequency: %.2f sec', fMeanFreq));
text(fX, 1 * fDeltaY + vAxis(3), sprintf('Cycle period: %.2f sec', stDef.tPeriod));


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

% --- END of STPlotDefSinusoid.m ---
