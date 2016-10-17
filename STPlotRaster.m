function [hFigure] = STPlotRaster(stTrain, varargin)

% STPlotRaster - FUNCTION Make a raster plot of the spike train
% $Id: STPlotRaster.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: <[hFigure]> = STPlotRaster(stTrain)
%        <[hFigure]> = STPlotRaster(stTrain, strLevel)
%        <[hFigure]> = STPlotRaster(stTrain, <PlotOptions ...>)
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

% -- Check arguments

if (nargin < 1)
   disp('*** STPlotRaster: Would you like help?');
   help STPlotRaster;
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


% -- Handle cell arrays of spike trains

if (iscell(stTrain))
   % - Make a new figure if required
   if (bNewFigure)
      hFigure = figure;
   end
   
   % - Clear figure unless held
   if (~bHold)
      clf;
   end
   
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
   
   % - Should we return the handle?
   if (~bKeepHandle)
      clear hFigure;
   end

   return;
end


% -- Are we making a cell plot?  If so, don't make a new figure or clear it.

if (~strcmp(get(hFigure, 'UserData'), 'CellPlot'))
   if (bNewFigure)
      hFigure = figure;
   end
   
   if (~ishold)
      clf;    % Clear figure unless held
   end
end


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

if (exist('strLevel') == 1)            % The user wants to tell us which to use
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

minNeuron = [];
maxNeuron = [];

for (nChunkIndex = 1:length(spikeList))
   if (size(spikeList{nChunkIndex}, 2) == 1)
      % - Instance
      plot(spikeList{nChunkIndex}(:, 1), ones(length(spikeList{nChunkIndex})), PlotOptions{:});
      
      % - Define min and max neurons
      minNeuron = 1;
      maxNeuron = 1;
   else
      % - Mapping
      plot(spikeList{nChunkIndex}(:, 1) .* node.fTemporalResolution, spikeList{nChunkIndex}(:, 2), PlotOptions{:});
      
      % - Find min and max neurons
      minNeuron = min([minNeuron floor(spikeList{nChunkIndex}(:, 2))']);
      maxNeuron = max([minNeuron ceil(spikeList{nChunkIndex}(:, 2))']);   
   end
end

hold off;

% - Fix axes
vAxes = axis;
axis([0 node.tDuration minNeuron-1 maxNeuron+1]);

return;


% --- END of STPlotRaster.m ---

% $Log: STPlotRaster.m,v $
% Revision 2.14  2005/02/19 17:40:14  dylan
% STPlotRaster now correctly doesn't return the figure handle when trying to plot
% a zero-duration spike train. (nonote)
%
% Revision 2.13  2005/02/18 17:16:15  dylan
% STPlotRaster now maintains the 'hold' property nicely. (nonote)
%
% Revision 2.12  2005/02/18 15:36:47  dylan
% STPlotRaster now ensures that the axis limits are for the full duration of the
% spike train. (nonote)
%
% Revision 2.11  2005/02/17 17:30:11  dylan
% * Modified the behaviour of STPlotRaster when plotting a zero-duration
% spiketrain. (nonote)
%
% Revision 2.10  2005/02/17 13:03:46  dylan
% * STPlotRaster now obeys the 'hold' property, and generally behaves nicely.
%
% Revision 2.9  2005/02/10 09:28:37  dylan
% * Modified figure-creating functionality of spike toolbox plotting functions.
% STPlotRaster, STPlot2DISI, STPlot2DMeanFreq and STPlot2DRaster now clear the
% current figure before plotting, just like a proper matlab plot function.
%
% Revision 2.8  2004/12/07 14:31:40  dylan
% Modified STPlotRaster -- the function is now able to return a handle to the
% figure it creates.  The function also accepts a variable list of plot arguments
% in order to modify marker sizes, line sizes and other plot properties according
% to the matlab 'plot' function syntax.
%
% Revision 2.7  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.6  2004/09/02 09:11:27  dylan
% Typo in STPlotRaster (nonote)
%
% Revision 2.5  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.4  2004/08/30 13:26:24  dylan
% STPlotRaster now always plots from time 0 (nonote)
%
% Revision 2.3  2004/08/28 11:11:33  dylan
% STPlotRaster now displays prettier axis limits (nonote)
%
% Revision 2.2  2004/07/29 14:04:29  dylan
% * Fixed a bug in STAddrLogicalExtract where it would incorrectly handle
% addressing specifications with no minor address fields.
%
% * Updated the help for STOptions, making it more verbose.
%
% * Modified the help for STAddrSpecInfo: Added a reference to STDescribe.
%
% * Modifed readme.txt to point to the welcome HTML file.
%
% * Modified the spike_tb_welcome.html file: Added a reference to STDescribe.
%
% * Modified STAddrSpecSynapse2DNeuron: This function now accepts an argument
% 'bXSecond' which can swap the order of the two neuron address fields.
%
% * Added a more explicit description of 'strPlotOptions' to STPlotRaster.
%
% * Updated STFormats to bring it up to date with the new toolbox variable
% formats.
%
% Revision 2.1  2004/07/19 16:21:03  dylan
% * Major update of the spike toolbox (moving to v0.02)
%
% * Modified the procedure for retrieving and setting toolbox options.  The new
% suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
% STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
% 'factory default' options are defined in STToolboxDefaults.  Options can be
% saved as user defaults using STOptionsSave, and will be loaded automatically
% for each session.
%
% * Removed STAccessDefaults and STCreateDefaults.
%
% * Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
% STPhysicalAddressContstruct and STPhysicalAddressExtract to
% STAddr<type><verb>
%
% * Drastically modified the way synapse addresses are specified for the
% toolbox.  A more generic approach is now taken, where addressing modes are
% defined by structures that outline the meaning of each bit-field in a
% physical address.  Fields can have their bits reversed, can be ignored, can
% have a description attached, and can be marked as major or minor fields.
% Any type of neuron/synapse topology can be addressed in this way, including
% 2D neuron arrays and chips with no separate synapse addresses.
%
% The following functions were created to handle this new addressing mode:
% STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
% STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
% STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
% STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.
%
% This modification required changes to STAddrLogicalConstruct and Extract,
% STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
% STStimulate, STMap, STCrop, STConcat and STMultiplex.
%
% * Removed the channel filter functions.
%
% * Modified STDescribe to handle the majority of toolbox variable types.
% This function will now describe spike trains, addressing specifications and
% spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
% STTrainDescribe.
%
% * Added an STIsValidSpikeTrain function to test the validity of a spike
% train structure.  Modified many spike train manipulation functions to use
% this feature.
%
% * Added features to Todo.txt, updated Readme.txt
%
% * Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
% and associated images (an_spike-big.jpg, an_spike.gif)
%
% Revision 2.0  2004/07/13 12:56:32  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.7  2004/05/14 15:37:19  dylan
% * Created utilities/CellFlatten.m -- CellFlatten coverts a list of items
% into a cell array containing a single cell for each item.  CellFlatten will
% also flatten the heirarchy of a nested cell array, returning all cell
% elements on a single dimension
% * Created utiltites/CellForEach.m -- CellForEach executes a specified
% function for each top-level element of a cell array, and returns a matrix of
% the results.
% * Converted spike_tb/STFindMatchingLevel to natively process cell arrays of trains
% * Converted spike_tb/STMultiplex to natively process cell arrays of trains
% * Created spike_tb/STCrop.m -- STCrop will crop a spike train to a specified
% time extent
% * Created spike_tb/STNormalise.m -- STNormalise will shift a spike train to
% begin at zero (first spike is at zero) and correct the duration
%
% Revision 1.6  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.5  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%
