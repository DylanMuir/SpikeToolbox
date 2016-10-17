function [vPSTHist, tBinCentres, vStdErr] = STPSTimeHist(stTrain, vtStimOnset, vtWindow, nNumBins)

% STPSTimeHist - FUNCTION Construct an ISI histogram for a spike train
% $Id: STPSTimeHist.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: <[vPSTHist, tBinCentres, vStdErr]> = ..
%              STPSTimeHist(stTrain, vtStimOnset <, vtWindow, nNumBins>)
%
% STPSTimeHist will calculate a peri-stimulus time histogram for the spike
% train stTrain. A PSTH is formed from one or more spike trains recorded
% from multiple runs of an experiment, for example multiple presentations
% of a particular stimulus. The stimulus onset times (or other
% synchronising signal) are supplied in a vector of timestamps
% 'vtStimOnset'. These time stamps must be supplied in seconds.
%
% The optional argument vtWindow should be a two element vector of the
% format ['tRelStart' 'tRelEnd'], specifying the start and end times (in
% seconds) of a window over which to analyse each stimulus presentation,
% relative to the stimulus onset time. If 'vtWindow' is not supplied, the
% shortest inter-stimulus interval will be used.
%
% The optional argument 'nNumBins' specifies the number of bins to use
% within the analysis time window. If not supplied, 50 bins will be used.
%
% 'vPSTHist' and 'vStdErr' will be vectors containing the binned spike
% counts (and standard error) over the analysis time window. The centre
% points of each time bin in the histogram are given in the vector
% 'tBinCentres', in seconds.
%
% If no output arguments are specified, a plot of the PSTH will be created.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 5th March, 2005
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Constants

% - Default number of histogram bins
nDefaultNumBins = 50;

% - Colour to use for standard deviation fill
vFillColour = [0.9 0.9 0.8];

% - Style to use for plotting mean histogram
strMeanStyle = 'k-';

% - Style to use for plotting zero line
strZeroStyle = 'k:';


% -- Check arguments

if (nargin > 4)
   disp('--- STPSTimeHist: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STPSTimeHist: Incorrect usage');
   help STPSTimeHist;
   return;
end

if ((nargin < 4) || isempty(nNumBins))
   % - Use default number of time bins
   nNumBins = nDefaultNumBins;
end

if ((nargin < 3) || isempty(vtWindow))
   % - We should try to work out the time window ourselves
   bGenWindow = true;
else
   % - The user has supplied the desired time window
   bGenWindow = false;
end

% - Check that a valid spike trains was supplied
if (~STIsValidSpikeTrain(stTrain))
   disp('*** STPSTimeHist: Invalid spike train supplied');
   return;
end

% - Check that we have more than one stimulus time
if (numel(vtStimOnset) < 2)
   disp('*** STPSTimeHist: At least two stimulus onset times required');
   return;
end


% -- Calculate time window

% - Determine inter-stimulus times
vtStimDurations = diff(vtStimOnset);

if (bGenWindow)
   % - Find the smallest inter-stimulus time and use that as the window extent
   vtWindow = min(vtStimDurations) * [-1 1];
end

% - Total window duration
tWindowDuration = diff(vtWindow);

% - Check that the window doesn't overlap other stimuli
if (~bGenWindow && any(vtWindow(2) > vtStimDurations))
   disp('--- STPSTimeHist: Warning: Time window overlaps multiple stimuli');
end

% - Determine time bin duration
tBinDuration = tWindowDuration / nNumBins;

% - Determine where the registration point will be
tRegPoint = -vtWindow(1);


% -- Calculate histogram for each stimulus

% - Turn of 'zero duration' warning for STCount
stateWarn = warning('off', 'SpikeToolbox:ZeroDuration');

% - Preallocate spike bins
nNumStimulations = numel(vtStimOnset);
mCounts = zeros(nNumStimulations, nNumBins);

for (nStimIndex = 1:nNumStimulations)
   % - Determine absolute time window for this stimulus onset
   tWindow = vtStimOnset(nStimIndex) + vtWindow;
   
   % - Warn if we're trying to crop before zero
   if (min(tWindow) < 0)
      disp('--- STPSTimeHist: Warning: Stimulus-aligned time window begins before');
      disp('       the start of the spike train');
   end
   
   % - Crop train to the current window
   stWindowTrain = STCrop(stTrain, tWindow(1), tWindow(2));
   
   % - Shift spike train to the registration point
   stWindowTrain = STShift(stWindowTrain, tRegPoint - vtStimOnset(nStimIndex));
   
   % - Bin spike frequencies
   mStimCounts = STProfileCount(stWindowTrain, tBinDuration);
   nLastBin = min([nNumBins  size(mStimCounts, 1)]);               % Determine last bin to take
   mCounts(nStimIndex, 1:nLastBin) = mStimCounts(1:nLastBin, 2);
end

% - Calcualte the time of each bin centre
tBinCentres = (0:nNumBins-1) .* tBinDuration + (tBinDuration / 2) + vtWindow(1);

% - Calculate mean and standard error of counts
vPSTHist = sum(mCounts);
vMeanHist = mean(mCounts);
vStdErr = std(mCounts) ./ sqrt(nNumStimulations);

% - Restore warning state
warning(stateWarn);


% -- Plot, if no output arguments;

if (nargout == 0)
   % - Set up figure and axes for a plot
   newplot;
   bHold = ishold;
   gca;

   hold on;
   
   % - Make a polygon for the standard error
   polyStdX = [tBinCentres ...
      tBinCentres(end:-1:1)];
   polyStdY = [(vMeanHist - vStdErr) ...
      (vMeanHist(end:-1:1) + vStdErr(end:-1:1))];

   fill(polyStdX, polyStdY, vFillColour, 'LineStyle', 'none');

   % - Plot the (mean) histogram
   plot(tBinCentres, vMeanHist, strMeanStyle);
   
   % - Fix axis extents
   vAxis = axis;
   
   if (bHold)
      tMin = min([vAxis(1)  vtWindow(1)  0]);
      tMax = max([vAxis(2)  vtWindow(2)]);
   else
      tMin = min([vtWindow(1)  0]);
      tMax = vtWindow(2);
   end
   
   axis([tMin tMax vAxis(3) vAxis(4)]);
   
   % - Plot a zero line and a stimulus line
   plot([tMin tMax], [0 0], strZeroStyle);
   plot([0 0], [vAxis(3)  vAxis(4)], strZeroStyle);
   
   % - Print titles and labels
   strTitle = sprintf('Mean peri-stimulus time histogram\nStandard error shown as shading');
   title(strTitle);
   xlabel('Time relative to stimulus onset (sec)');
   ylabel('Spike count');

   % - Fix hold status
   if (~bHold)
      hold off;
   end
   
   clear vPSTHist;
end

% --- END of STISIHist.m ---
