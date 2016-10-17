function [hFigure] = STPlotRaster(stTrain, varargin)

% STPlotRaster - FUNCTION Make a raster plot of the spike train
% $Id: STPlotRaster.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: <[hFigure]> = STPlotRaster(stTrain)
%        <[hFigure]> = STPlotRaster(stTrain, <PlotOptions ...>)
%        <[hFigure]> = STPlotRaster(stTrain, strLevel)
%        <[hFigure]> = STPlotRaster(stTrain, strLevel, <PlotOptions ...>)
%
% Where: 'stTrain' is either an instantiated or mapped spike train.  A raster
% plot will be created in the current figure (or a new figure created) showing
% the spike train.  'strLevel' can be used to specify the spike train level to
% plot, and must be one of {'instance', 'mapping'}.  Plotting spike train
% definitions is not yet supported.
%
% The optional return argument 'hFigure' will return the handle of the new
% figure created.
%
% If variable argument list 'PlotOptions' is supplied, these will be passed
% to the matlab plot function.  These arguments take the same format described
% in the documentation for plot.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin < 1)
   disp('*** STPlotRaster: Would you like help?');
   help STPlotRaster;
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
         STPlotRaster(stTrain{nRowIndex, nColIndex}, varargin{:});
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
   disp('*** STPlotRaster: Cannot plot a zero-duration spike train');
   return;
end


% -- Set up figure and axis for plotting

% - Get figure and axis information
hFigure = newplot;
bHold = ishold;


% -- Extract variable arguments

% - Has the user supplied a spike train level?
if ((length(varargin) > 0) && STIsValidSpikeTrainLevel(varargin{1}))
   strLevel = varargin{1};
      
   % - Strip off the first argument
   varargin = varargin(2:end);
end

PlotOptions = varargin;

% - Provide default plot options
if (isempty(PlotOptions))
   PlotOptions = {'k.'};
end


% -- Which spike train level should we plot?

if (exist('strLevel', 'var'))             % The user wants to tell us which to use
   switch lower(strLevel)
      case {'instance', 'i'}
         % - Test to see if the train contains an instance
         if (isfield(stTrain, 'instance'))
            % - Plot the instances
            STPlotRasterNode(stTrain.instance, PlotOptions);
            
         else
            % - The train didn't contain an instance, so we can't plot it
            disp('*** STPlotRaster: The spike train does not contain an instance to plot');
            return;
         end
         
         
      case {'mapping', 'm'}
         % - Test to see if the train contains a mapping
         if (isfield(stTrain, 'mapping'))
            % - Plot the napping
            STPlotRasterNode(stTrain.mapping, PlotOptions);
            
         else
            % - The train didn't contain an mapping, so we can't plot it
            disp('*** STPlotRaster: The spike train does not contain an mapping to plot');
            return;
         end
         
      otherwise
         SameLinePrintf('*** STPlotRaster: Unknown spike train level [%s].\n', lower(strLevel));
         disp('       strLevel must be one of {instance, mapping}');
   end
   
else     % Try to work out ourselves which level to plot
   if (isfield(stTrain, 'mapping'))        % First try mappings
      STPlotRasterNode(stTrain.mapping, PlotOptions);
      
   elseif (isfield(stTrain, 'instance'))  % Then try instances
      STPlotRasterNode(stTrain.instance, PlotOptions);

   else
      % - The spike train doesn't have either an instance or a mapping
      disp('*** STPlotRaster: The spike train contains neither an instance nor a mapping.');
      disp('       Plotting spike train definitions is currently not supported');
      return;
   end
end

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


% --- FUNCTION STPlotRasterNode
function STPlotRasterNode(node, PlotOptions)

% -- Are we using chunked mode?
if (node.bChunkedMode)
   spikeList = node.spikeList;
else
   spikeList = {node.spikeList};
end

% -- Do the plot
hold on;

for (nChunkIndex = 1:length(spikeList))
   tSpikeTimes = spikeList{nChunkIndex}(:, 1);
   
   if (size(spikeList{nChunkIndex}, 2) == 1)
      % - Instance
      plot(tSpikeTimes, 1, PlotOptions{:});
      
      % - Define min and max neurons
      minNeuron = 1;
      maxNeuron = 1;
   else
      % - Mapping
      vfAddresses = spikeList{nChunkIndex}(:, 2);
      
      plot(tSpikeTimes .* node.fTemporalResolution, vfAddresses, PlotOptions{:});
      
      % - Find min and max neurons
      minNeuron = floor(spikeList{nChunkIndex}(:, 2))';
      maxNeuron = ceil(spikeList{nChunkIndex}(:, 2))';   
   end
end

hold off;

% - Fix axes
vAxes = axis;
minRange = min([minNeuron-1  vAxes(3)]);
maxRange = max([maxNeuron+1  vAxes(4)]);
axis([0 node.tDuration minRange maxRange]);

return;


% --- END of STPlotRaster.m ---
