function [vCorrSmoothed, vCorrRaw, vtCorrTime] = STCrossCorrelation(stTrain1, stTrain2, tWindow, strKernel, tSmoothing)

% STCrossCorrelation - FUNCTION Calcualte cross-correlation for instantiated spike trains
% $Id: STCrossCorrelation.m 3987 2006-05-09 13:38:38Z dylan $
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
% Copyright (c) 2005 Dylan Richard Muir

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

% - Check that we have valid spike trains
if (~STIsValidSpikeTrain(stTrain1) || ~STIsValidSpikeTrain(stTrain2))
   disp('*** STCrossCorrelation: Invalid spike train supplied');
   return;
end

% - Check that we have at least an instance or a mapping
cTrains = {stTrain1, stTrain2};
if (~all(CellForEach(@isfield, cTrains, 'instance') | CellForEach(@isfield, cTrains, 'mapping')))
   disp('*** STCrossCorrelation: Spike trains must contain either an instance or a mapping');
   return;
end


% -- Extract spike times from trains

[vtSpikeTimes1, fSampRate1] = STGetSpikeTimes(stTrain1);
[vtSpikeTimes2, fSampRate2] = STGetSpikeTimes(stTrain2);

% - Check that the correlation window size is reasonable
vtDurations = [max(vtSpikeTimes1)  max(vtSpikeTimes2)];
if (any(vtDurations <= tWindow))
   disp('*** STCrossCorrelation: The correlation window seems unreasonably large.  Try');
   disp('       a window at least shorter than both spike trains');
   return;
end

% - Are we actually doing an autocorrelation?
bAutoCorr = false;
if (  (length(vtSpikeTimes1) == length(vtSpikeTimes2)) && ...
      (all(vtSpikeTimes1 == vtSpikeTimes2)))
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
   vFilteredSpikes = [mDiffSpikes(mDiffSpikes(:, 2) == 1, 1); -mDiffSpikes(mDiffSpikes(:, 2) == -1, 1)];
   
   % - Only keep ISIs inside the time window
   vFilteredSpikes = vFilteredSpikes(abs(vFilteredSpikes) <= nWindowSize);

   % - Should we break?
   if ((size(vFilteredSpikes, 1) == 0) && (rem(nBinDifference, 2) == 0))
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
   STProgress('Smoothing...');
   drawnow;

   % - Make the kernel for smoothing
   if (strcmp(strKernel, 'gaussian'))
      vKern = gauss_pdf(1:nSmoothingSize, nSmoothingSize/2, nSmoothingSize/2);
   
   elseif (strcmp(strKernel, 'square'))
      vKern = ones(1, nSmoothingSize);
   
   else
      % - This error should never occur
      disp('*** STCrossCorrelation: Unexpected error recognising kernel string');
   end
   
   % - Normalise kernel
   vKern = vKern ./ sum(vKern);
   
   % - Zero NaN points for smoothing
   vCorrSmoothed = vCorrRaw;
   vCorrSmoothed(isnan(vCorrSmoothed)) = 0;
   
   % - Perform smoothing with convolution
   vCorrSmoothed = conv2(vCorrSmoothed, vKern, 'same');
   
   % - Tidy up the display
   STProgress('\b\b\b\b\b\b\b\b\b\b\b\b            \b\b\b\b\b\b\b\b\b\b\b\b');

else
   vCorrSmoothed = vCorrRaw;
end

% - Determine the time extents for the correlation bins

vtCorrTime = (-nWindowSize:nWindowSize) ./ fSampRate;


% -- Plot a graph, if necessary

if (nargout == 0)
   % - Clear or make a figure
   newplot;
   bHold = ishold;
   hAxis = gca;

   % - Plot the correlation
   plot(vtCorrTime, vCorrSmoothed);

   % - Determine and fix the axis extents
   vAxis = axis;
   if (bHold)
      tMin = min([vAxis(1) -tWindow]);
      tMax = max([vAxis(2) tWindow]);
   else
      tMin = -tWindow;
      tMax = tWindow;
   end
   axis([tMin tMax vAxis(3) vAxis(4)]);
   
   % - Remove the y axis labels
   if (~bHold)
      set(hAxis, 'YTick', []);
   end
   
   % - Clear the outputs
   clear vCorrSmoothed vCorrRaw;
end

% --- END of STCrossCorrelation.m ---
