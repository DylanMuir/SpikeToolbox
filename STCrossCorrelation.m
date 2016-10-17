function [vCorrSmoothed, vCorrRaw, vtCorrTime] = STCrossCorrelation(stTrain1, stTrain2, tWindow, strKernel, tSmoothing)

% STCrossCorrelation - FUNCTION Calcualte cross-correlation for instantiated spike trains
% $Id: STCrossCorrelation.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [vCorrSmoothed, vCorrRaw, vtCorrTime] = STCrossCorrelation(stTrain1, stTrain2
%                                                   <, tWindow, strKernel, tSmoothing>)
%
% STCrossCorrelation calculates the cross-correlation of two spike trains.
% Any mapping information is ignored; this function is designed to work with
% spike train instances.  STFlatten and STExtract can be used to convert
% mapped trains to spike train instances.  'stTrain<1, 2>' are valid spike
% train objects, which must be at least instantiated.  Spike train definitions
% are not supported by STCrossCorrelation.
% 
% 'tWindow' is an optional argument to specity the time range over which to
% calculate the cross correlation.  The correlation will stretch over
% [-tWindow..tWindow]. 'tSmoothing' is an optional argument that specifies the
% amount of smoothing to perform on the calculated correlation.  A gaussian
% smoothing will be performed with a window width of 'tSmoothing'.  If
% 'tSmoothing' is zero, smoothing will not be performed.  Both time window
% parameters are in seconds.  'strKernel' can optionally be used to specify
% the kernel used for smoothing the correlation function.  Recognised kernels
% are 'gaussian', 'square' and 'none'.  The defaults for these arguments can
% be set using STOptions.
%
% 'vCorrRaw' will be the raw calculated cross correlation.  'vCorrSmoothed' will
% be the (optionally) smoothed correlation trace.  'vtCorrTime' will be a
% vector of the corresponding time bins for each entry in 'vCorr...'.  If no
% output arguments are supplied, the (smoothed) correlation will be plotted in
% the current figure.
%
% To perform an autocorrelation, just supply the same spike train twice.  In
% this case, the zero point will be ignored for smoothing and will be replaced
% by a NaN.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 20th January, 2005

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin > 5)
   disp('--- STCrossCorrelation: Extra arguments ignored');
end

if (nargin < 3)
   % - Set default time window
   tWindow = stOptions.DefaultCorrWindow;
end

if (nargin < 5)
   % - Set default smoothing time window
   tSmoothing = tWindow / stOptions.DefaultCorrSmoothingWindowFactor;
end

if (nargin < 4)
   % - Set default smoothing kernel
   strKernel = stOptions.DefaultCorrSmoothingKernel;
end

% - Check if the supplied kernel is valid
if (  ~strcmp(strKernel, 'gaussian') && ...
      ~strcmp(strKernel, 'square') && ...
      ~strcmp(strKernel, 'none'))
   disp('*** STCrossCorrelation: Invalid kernel specified for smoothing.  ''strKernel''');
   disp('       must be one of {''gaussian'', ''square'', ''none''}.');
   return;
end

% - Default: smoothing on
bSmoothing = true;

if ((tSmoothing == 0) || strcmp(strKernel, 'none'))
   % - Turn off smoothing
   bSmoothing = false;
end

if (nargin < 2)
   disp('*** STCrossCorrelation: Incorrect usage');
   help spike_crosscorr;
   return;
end

if (~STIsValidSpikeTrain(stTrain1) || ~STIsValidSpikeTrain(stTrain2))
   disp('*** STCrossCorrelation: Invalid spike train supplied');
   return;
end

% -- Extract spike times from trains

[vtSpikeTimes1, fSampRate1] = STGetSpikeTimes(stTrain1);
[vtSpikeTimes2, fSampRate2] = STGetSpikeTimes(stTrain2);

% - Are we actually doing an autocorrelation?
bAutoCorr = false;
if (all(vtSpikeTimes1 == vtSpikeTimes2))
   bAutoCorr = true;
end

% - Determine optimal temporal resolution, convert to index format
fSampRate = max([fSampRate1  fSampRate2]);
vSpikeIndex1 = round(vtSpikeTimes1 .* fSampRate);
vSpikeIndex2 = round(vtSpikeTimes2 .* fSampRate);

nWindowSize = round(tWindow * fSampRate);
nSmoothingSize = round(tSmoothing * fSampRate);


% -- Prepare cross-correlation algorithm

% - Make a matrix of both spike trains concatenated, and tagged with the
% source
mSpikes = [ [vSpikeIndex1 zeros(length(vSpikeIndex1), 1)] ; [vSpikeIndex2 ones(length(vSpikeIndex2), 1)] ];

% - Sort the matrix by spike time
mSpikes = sortrows(mSpikes, 1);

vCorrRaw = zeros(1, nWindowSize * 2 + 1);


% -- Calculate cross-correlation

for (nBinDifference = 2:length(mSpikes))
   % - Get ISIs and index differences for the given separation
   mDiffSpikes = mSpikes(nBinDifference:end, :) - mSpikes(1:end+1-nBinDifference, :);
   
   % - Only keep ISIs where we've shifted from one train to the other
   vFilteredSpikes = [mDiffSpikes(find(mDiffSpikes(:, 2) == 1), 1); -mDiffSpikes(find(mDiffSpikes(:, 2) == -1), 1)];
   
   % - Only keep ISIs inside the time window
   vFilteredSpikes = vFilteredSpikes(find(abs(vFilteredSpikes) <= nWindowSize));

   % - Should we break?
   if ((size(vFilteredSpikes, 1) == 0) & (rem(nBinDifference, 2) == 0))
      break;
   end
   
   % - Accumulate correlations
   for (nCorrIndex = vFilteredSpikes' + nWindowSize + 1)
      vCorrRaw(nCorrIndex) = vCorrRaw(nCorrIndex) + 1;
   end
end

% - For autocorrelation, replace zero point with a NaN
if (bAutoCorr)
   vCorrRaw(nWindowSize+1) = NaN;
end


% -- Finalise cross-correlation and smooth

% - Should we do smoothing?
if (bSmoothing)
   % - Display some progress
   fprintf(1, 'Smoothing: %3.0f%%', 0);
      
   % - Make sure the smoothing window length is even
   nHalfWindow = fix((nSmoothingSize+1)/2);
   nSmoothingSize = 2 * nHalfWindow;
   
   % - Make the kernel for smoothing
   if (strcmp(strKernel, 'gaussian'))
      vKern = gauss_pdf(1:nSmoothingSize, nSmoothingSize/2, nSmoothingSize/2);
   
   elseif (strcmp(strKernel, 'square'))
      vKern = ones(1, nSmoothingSize);
   
   else
      % - This error should never occur
      disp('*** STCrossCorrelation: Unexpected error recognising kernel string');
   end
   
   % - Pad vCorr
   vPadCorr = [zeros(1, nHalfWindow) vCorrRaw zeros(1, nHalfWindow)];
   vCorrSmoothed = zeros(1, nHalfWindow*2 + length(vCorrRaw));
   
   % - Find non-zero correlation points and smooth
   vBinIndices = find((vPadCorr ~= 0) & ~isnan(vPadCorr));
   nNumWindows = length(vBinIndices);
   
   for (nBinIndex = 1:nNumWindows)
      % - Find the window extent for this point
      vCorrWindow = vBinIndices(nBinIndex) + (-nHalfWindow+1:nHalfWindow);
      vCorrSmoothed(vCorrWindow) = vCorrSmoothed(vCorrWindow) + vKern * vPadCorr(vBinIndices(nBinIndex));
      
      % - Display some progress
      if (mod(nBinIndex, fix(nNumWindows / 10)) == 0)
         fprintf('\b\b\b\b%3.0f%%', nBinIndex / nNumWindows * 100);
      end
   end
   
   % - Normalise smoothed correlation, crop to proper extents
   vCorrSmoothed = vCorrSmoothed(nHalfWindow:length(vPadCorr)-nHalfWindow-1) ./ sum(vKern);
   
   % - Tidy up the display
   fprintf(1, '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b               \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');

else
   vCorrSmoothed = vCorrRaw;
end

% - Determine the time extents for the correlation bins

vtCorrTime = (-nWindowSize:nWindowSize) ./ fSampRate;


% -- Plot a graph, if necessary

if (nargout == 0)
   % - Clear or make a figure
   clf;
   hAxis = axes;
   
   % - Plot the correlation
   plot(vtCorrTime, vCorrSmoothed);

   % - Fix the axis extents
   vAxis = axis;
   axis([-tWindow tWindow vAxis(3) vAxis(4)]);
   
   % - Remove the y axis labels
   set(hAxis, 'YTick', []);
   
   % - Clear the outputs
   clear vCorrSmoothed vCorrRaw;
end

% --- END of STCrossCorrelation.m ---

% $Log: STCrossCorrelation.m,v $
% Revision 1.2  2005/02/11 15:47:14  dylan
% * STCrossCorrelation now uses a more efficient smoothign algorithm.  It also now
% works properly. (nonote)
%
% Revision 1.1  2005/02/10 13:46:06  dylan
% * Created a new function STCrossCorrelation to perform cross-correlation
% analysis of a spike train.
%
% * Created a new function STGetSpikeTimes to extract spike times from a spike
% train object.
%
