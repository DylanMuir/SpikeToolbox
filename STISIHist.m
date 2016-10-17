function [mISIHist, tTimeBins] = STISIHist(stTrain, bUseLog, nNumBins)

% STISIHist - FUNCTION Construct an ISI histogram for a spike train
% $Id: STISIHist.m 8297 2008-01-30 10:22:56Z chicca $
%
% Usage: [vISIHist, tTimeBins] = STISIHist(stTrain <, bUseLog, nNumBins>)
%        [vISIHist, tTimeBins] = STISIHist(stTrain <, bUseLog, tTimeBins>)
%        [mISIHist, tTimeBins] = STISIHist(cellstTrain, ...)
%
% STISIHist will calculate an inter-spike interval histogram for the spike
% train 'stTrain'.  'vISIHist' will be the count in each histogram bin, for
% the bin centres specified in 'tTimeBins'.  'vISIHist' and 'tTimeBins' will
% be vectors of the same length.
%
% The optional argument 'bUseLog' can be used to specify a log time scale for
% calcualting the histogram.  The default is to use a linear time scale.  The
% optional argument 'nNumBins' can be used to specify the number of histogram
% bins to use.  The default is 50 bins.
%
% If a vector is supplied for 'tTimeBins', the specified time bins will be
% used instead.  'tTimeBins' should be a vector of bin centres.
%
% If a cell array is supplied for 'cellstTrain', then histogramming will be
% performed for each of the supplied trains.  In this case, the identical time
% bins will be used for each histogram.  'mISIHist' will be a matrix, with the
% histogram for each train along the rows of the matrix.
%
% If no output arguments are supplied, STISIHist will construct a plot of the
% ISI histogram.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 4th March, 2005
% Copyright (c) 2005 Dylan Richard Muir

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

if (nargin > 3)
   disp('--- STISIHist: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STISIHist: Incorrect usage');
   help STISIHist;
   return;
end

if ((nargin < 2) || isempty(bUseLog))
   % - Default to linear scale
   bUseLog = false;
end

if ((nargin < 3) || isempty(nNumBins))
   % - Use default number of time bins
   nNumBins = nDefaultNumBins;
end

% - Check for a cell array of spike trains
bCellMode = iscell(stTrain);
if (~bCellMode)
   stTrain = {stTrain};
end

% - Check that valid spike trains were supplied
if (~all(CellForEach(@STIsValidSpikeTrain, stTrain)))
   disp('*** STISIHist: Invalid spike train supplied');
   return;
end

% - Check if a vector of time bins was supplied
bGenerateBins = numel(nNumBins) == 1;


% -- Extract ISIs

ctSpikeTimes = CellForEachCell(@STGetSpikeTimes, stTrain);
cISIs = CellForEachCell(@diff, ctSpikeTimes);

fMinISI = min(CellForEach(@min, cISIs));
fMaxISI = max(CellForEach(@max, cISIs));


% -- Create binning structure

if (bGenerateBins)
   if (bUseLog)
      tTimeBins = logspace(log10(fMinISI), log10(fMaxISI), nNumBins);
   else
      fDeltaBin = (fMaxISI - fMinISI) / (nNumBins-1);
      tTimeBins = fMinISI:fDeltaBin:fMaxISI;
   end
else
    tTimeBins = nNumBins;
end


% -- Calculate histogram

% - Get the histogram for each spike train
cmISIHist = CellForEachCell(@hist, cISIs, tTimeBins);
mISIHist = vertcat(cmISIHist{:});

% -- Plot, if no output arguments;

if (nargout == 0)
   % - Set up figure and axes for a plot
   newplot;
   bHold = ishold;
   hAxis = gca;

   hold on;
   
   % - Get the mean and stddev of the histograms, make a fill if necessary
   if (bCellMode)
      vMeanHist = mean(mISIHist);
      vStdHist = std(mISIHist);
      
      % - Make a polygon for the standard deviation
      polyStdX = [tTimeBins ...
                  tTimeBins(end:-1:1)];
      polyStdY = [(vMeanHist - vStdHist) ...
                  (vMeanHist(end:-1:1) + vStdHist(end:-1:1))];

      fill(polyStdX, polyStdY, vFillColour, 'LineStyle', 'none');
   else
      vMeanHist = mISIHist;
   end
   
   % - Plot the (mean) histogram
   plot(tTimeBins, vMeanHist, strMeanStyle);
   
   % - Fix axis extents
   vAxis = axis;
   
   if (bHold)
      tMin = min([vAxis(1)  fMinISI]);
      tMax = max([vAxis(2)  fMaxISI]);
   else
      tMin = fMinISI;
      tMax = fMaxISI;
   end
   
   axis([tMin tMax vAxis(3) vAxis(4)]);
   
   % - Plot a zero line
   plot([tMin tMax], [0 0], strZeroStyle);
   
   % - Set log scale if required
   if (bUseLog)
      set(hAxis, 'XScale', 'log');
   end
   
   % - Print titles and labels
   if (bCellMode)
      strTitle = sprintf('Mean inter-spike interval histogram\nStandard deviation shown as shading');
   else
      strTitle ='Inter-spike interval histogram';
   end

   title(strTitle);
   xlabel('ISI duration (sec)');
   ylabel('Count');

   % - Fix hold status
   if (~bHold)
      hold off;
   end

   clear vTimeBins mISIHist;
end

% --- END of STISIHist.m ---
