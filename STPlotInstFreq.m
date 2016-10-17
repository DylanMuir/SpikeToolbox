function [hFigure] = STPlotInstFreq(stTrain, varargin)

% STPlotInstFreq - FUNCTION Plot instantaneous spiking frequency of a spike train
% $Id: STPlotInstFreq.m 8603 2008-02-27 17:49:41Z dylan $
%
% Usage: <[hFigure]> = STPlotInstFreq(stTrain),
%                         <'instance' / 'mapping'>,
%                         <'plain' / 'interp' / 'smooth', tWindow>
%                         <PlotOptions...>)
%
% Where: 'stTrain' is a valid spike train, containing either an instance or
% a mapping.  'PlotOptions' are as supplied to the matlab PLOT function.
% This can be used to change the colour of a plot, insert markers, etc.
% See the documentation for PLOT for syntax.
%
% If the optional arguments 'instance' or 'mapping' are provided, then the
% corresponding spike train level from 'stTrain' will be plotted.  If
% neither are provided, then instances will be used in preference to
% mappings.
%
% STPlotInstFreq is capable of constructing three types of graph.
% 'plain' (default) plots a horizontal line connecting two spikes, the
% height of which corresponds to the inter-spike interval (ISI) defined by
% the two spikes.  The precise time of each spike is shown.
%
% 'interp' blends ISIs using a 1/t function.  This method is sampled in
% time, using either the minimum ISI or 10 msec as a sampling rate,
% whichever is greater.  Individual spike times may not be precisely
% identifiable.
%
% 'smooth' provides a temporal moving average of the 1/t sampled graph.
% The optional argument 'tWindow' specified the length of the sliding
% window over which the instantaneous frequency will be averaged.  If
% 'tWindow' is not specified, it will default to five samples.
%
% If required, the figure handle will be returned in 'hFigure'.
%
% STPlotInstFreq will create a graph with time in seconds along the x axis
% and frequency in hertz along the y axis.  Both axes are linear.


% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 21st November, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Define constants

% - Minimum sampling rate
MIN_SAMPLE = 10e-3;     % 10 msec


% -- Check arguments

if (nargin < 1)
   disp('*** STPlotInstFreq: Incorrect usage');
   help STPlotInstFreq;
   return;
end

% - We should keep the figure handle if the user has requested it
bKeepHandle = (nargout > 0);


% -- Handle cell arrays of spike trains

if (iscell(stTrain))
   % - Prepare a figure and axis for plotting
   hFigure = newplot;
   bHold = ishold;

   % - Set "CellPlot" property
   set(hFigure, 'UserData', 'CellPlot');
   
   % - Plot each cell in a subplot
   for (nRowIndex = 1:size(stTrain, 1))
      for (nColIndex = 1:size(stTrain, 2))
         % - Make a subplot, and plot the train
         subplot(size(stTrain, 1), size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
         STPlotInstFreq(stTrain{nRowIndex, nColIndex}, varargin{:});
      end
   end
   
   % - Make the current figure behave sensibly
   if (~bHold)
      hold off;
   end
   
   % - Should we return the handle?
   if (~bKeepHandle)
      clear hFigure;
   end
   
   return;
end


% -- Handle zero-duration spike trains

if (STIsZeroDuration(stTrain))
   disp('*** STPlotInstFreq: Cannot plot a zero-duration spike train');
   return;
end


% -- Set up figure and axis for plotting

% - Get figure and axis information
hFigure = newplot;
%bHold = ishold;


% -- Extract variable arguments

if (length(varargin) > 0)
   % - Check for spike train levels
   vbSpikeLevel = CellForEach(@STIsValidSpikeTrainLevel, varargin);
   
   if any(vbSpikeLevel)
      % - Extract first spike train level, remove from argument list
      vnArgIndex = find(vbSpikeLevel);
      strLevel = varargin{vnArgIndex(1)};
      varargin = {varargin{~vbSpikeLevel}};
   end

   % - Check for graph type specification
   vbPlainSpec = CellForEach(@strcmpi, varargin, 'plain');
   vbInterpSpec = CellForEach(@strcmpi, varargin, 'interp');
   vbSmoothSpec = CellForEach(@strcmpi, varargin, 'smooth');
   vbTypeSpec = vbPlainSpec | vbInterpSpec | vbSmoothSpec;
   
   % - Extract method
   if any(vbPlainSpec)
      strMethod = 'plain';
   elseif any(vbInterpSpec)
      strMethod = 'interp';
   elseif any(vbSmoothSpec)
      strMethod = 'smooth';
   end
   
   % - Remove from argument list
   varargin = {varargin{~vbTypeSpec}};

   % - Check for a numeric argument specifying the smoothing window
   if (strcmp(strMethod, 'smooth'))
      vbWindowSpec = CellForEach(@isnumeric, varargin);
      
      if any(vbWindowSpec)
         % - Extract argument, remove from argument list
         vnArgIndex = find(vbWindowSpec);
         tWindow = varargin{vnArgIndex(1)};
         varargin = {varargin{~vbWindowSpec}};
      end
   end
end

% - 'Plain' is the default method
if (~exist('strMethod', 'var'))
   strMethod = 'plain';
end

% - Anything remaining is taken as plot options
PlotOptions = varargin;

% - Provide default plot options
if (isempty(PlotOptions))
   PlotOptions = {'k-'};
end


% -- Which spike train level should we plot?

if (exist('strLevel', 'var'))            % The user wants to tell us which to use
   switch lower(strLevel)
      case {'instance', 'i'}
         % - Test to see if the train contains an instance
         if (STHasInstance(stTrain))
            % - Get the spike times
            vtSpikeTimes = STGetSpikeTimes(stTrain, 'instance');
            
         else
            % - The train didn't contain an instance, so we can't plot it
            disp('*** STPlotInstFreq: The spike train does not contain an instance to plot');
            return;
         end
         
         
      case {'mapping', 'm'}
         % - Test to see if the train contains a mapping
         if (STHasMapping(stTrain))
            % - Get the spike times
            vtSpikeTimes = STGetSpikeTimes(stTrain, 'mapping');
            
         else
            % - The train didn't contain an mapping, so we can't plot it
            disp('*** STPlotInstFreq: The spike train does not contain an mapping to plot');
            return;
         end

      otherwise
         SameLinePrintf('*** STPlotInstFreq: Unknown spike train level [%s].\n', lower(strLevel));
         disp('       strLevel must be one of {instance, mapping}');
   end
   
else     % Try to work out ourselves which level to plot
   if (~STHasInstance(stTrain) && ~STHasMapping(stTrain))
      % - The spike train doesn't have either an instance or a mapping
      disp('*** STPlotInstFreq: The spike train contains neither an instance nor a mapping.');
      disp('       Plotting spike train definitions is currently not supported');
      return;
   
   else
      % - Get the spike times
      vtSpikeTimes = STGetSpikeTimes(stTrain);
   end
end


% -- Choose which plot function to use

switch strMethod
   case 'plain'
      [vtTime, vfFreq] = InstFreqPlain(vtSpikeTimes);
      
   case {'interp', 'smooth'}
      [vtTime, vfFreq, tSample] = InstFreqInterp(vtSpikeTimes, MIN_SAMPLE);   
end

% - Smooth the graph, if requested
if (strcmp(strMethod, 'smooth'))
   if (~exist('tWindow', 'var'))
      nSmoothSamples = 5;
   else
      nSmoothSamples = max([round(tWindow / tSample) 1]);
   end
   
   % - Smooth data
   vfFreq = smooth(vfFreq, nSmoothSamples);
end


% -- Construct the plot

% - Plot instantaneous frequency
plot(vtTime, vfFreq, PlotOptions{:});

% - Should we return the figure handle?
if (~bKeepHandle)
   clear hFigure;
end

% --- END of STPlotInstFreq FUNCTION ---


% --- InstFreqPlain FUNCTION

function [vtTime, vfFreq] = InstFreqPlain(vtSpikeTimes)

% - Get ISIs
vtISI = diff(vtSpikeTimes);

% - Convert to frequency
vfFreq = 1 ./ vtISI;

% - Construct paired time and frequency vectors
vtTime = reshape(repmat(vtSpikeTimes, 1, 2)', [], 1);
vfFreq = reshape(repmat(vfFreq, 1, 2)', [], 1);
vtTime = vtTime(2:end-1);

% --- END of InstFreqPlain FUNCTION


% --- InstFreqInterp FUNCTION

function [vtTime, vfFreq, tSample] = InstFreqInterp(vtSpikeTimes, tMinSample)

% - Get ISIs
vtISI = diff(vtSpikeTimes);

% - Define sampling rate as min ISI, or minimum defined sampling rate
tSample = min(vtISI(vtISI > 0));
tSample = max([tSample tMinSample]);

% - Make a time sampling vector
vtTime = 0:tSample:max(vtSpikeTimes);

% - Make a mesh of the time samples, for all spike times
vfFreq = repmat(vtTime, numel(vtSpikeTimes)-1, 1);

% - Shift each time sample vector to be zeroed at the correspoding spike
% time
vfFreq = vfFreq - repmat(vtSpikeTimes(2:end), 1, numel(vtTime));

% - Convert each row to a 1/t curve, shifted by the ISI corresponding to
% each row
vfFreq = abs(vfFreq);
vfFreq = vfFreq + repmat(vtISI, 1, numel(vtTime));
vfFreq = 1 ./ vfFreq;

% - Pick the maximum contributing sample for each time point
vfFreq = max(vfFreq);

% --- END of InstFreqInterp FUNCTION

% --- END of STPlotInstFreq.m ---
