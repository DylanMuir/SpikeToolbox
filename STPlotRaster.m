function STPlotRaster(stTrain, strLevel, strPlotOptions)

% FUNCTION STPlotRaster - Make a raster plot of the spike train
%
% Usage: STPlotRaster(stTrain)
%        STPlotRaster(stTrain, strLevel)
%        STPlotRaster(stTrain, strPlotOptions)
%        STPlotRaster(stTrain, strLevel, strPlotOptions)
%
% Where: 'stTrain' is either an instantiated or mapped spike train.  A raster
% plot will be created in the current axes (or a new figure created) showing
% the spike train.  'strLevel' can be used to specify the spike train level to
% plot, and must be one of {'instance', 'mapping'}.  Plotting spike train
% definitions is not yet supported.
%
% If 'strPlotOptions' is supplied, this will be passed as a format string to
% the matlab plot function.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004

% $Id: STPlotRaster.m,v 1.1 2004/06/04 09:35:48 dylan Exp $

% -- Check arguments

if (nargin > 3)
   disp('--- STPlotRaster: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STPlotRaster: Would you like help?');
   help STPlotRaster;
end


% -- Handle cell arrays of spike trains

if (iscell(stTrain))
   clf;
   for (nRowIndex = 1:size(stTrain, 1))
      for (nColIndex = 1:size(stTrain, 2))
         subplot(size(stTrain, 1), size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
         
         if (exist('strLevel') == 1)
            if (exist('strPlotOptions') == 1)
               STPlotRaster(stTrain{nRowIndex, nColIndex}, strLevel, strPlotOptions);
            else
               STPlotRaster(stTrain{nRowIndex, nColIndex}, strLevel);
            end
            
         elseif (exist('strPlotOptions') == 1)
            STPlotRaster(stTrain{nRowIndex, nColIndex}, strPlotOptions);
            
         else
            STPlotRaster(stTrain{nRowIndex, nColIndex});
         end
         
         %axis([0 6 0 2]);
      end
   end
   
   return;
end

% -- Extract arguments
if (nargin > 1 & ~(strcmp(lower(strLevel), 'instance') == 1 | strcmp(lower(strLevel), 'mapping') == 1))
   if (nargin > 2)
      SameLinePrintf('*** STPlotRaster: Unknown spike train level [%s].\n', lower(strLevel));
      disp('       strLevel must be one of {instance, mapping}');
      return;
   else
      strPlotOptions = strLevel;
      clear strLevel;
   end
   
elseif (nargin < 3)
   strPlotOptions = 'k.';
end
   
% -- Which spike train level should we plot?

if (exist('strLevel') == 1)            % The user wants to tell us which to use
   switch lower(strLevel)
      case {'instance', 'i'}
         % - Test to see if the train contains an instance
         if (isfield(stTrain, 'instance'))
            % - Plot the instances
            STPlotRasterNode(stTrain.instance, strPlotOptions);
            return;
            
         else
            % - The train didn't contain an instance, so we can't plot it
            disp('*** STPlotRaster: The spike train does not contain an instance to plot');
            return;
         end
         
         
      case {'mapping', 'm'}
         % - Test to see if the train contains a mapping
         if (isfield(stTrain, 'mapping'))
            % - Plot the napping
            STPlotRasterNode(stTrain.mapping, strPlotOptions);
            return;
            
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
      STPlotRasterNode(stTrain.mapping, strPlotOptions);
      
   elseif (isfield(stTrain, 'instance'))  % Then try instances
      STPlotRasterNode(stTrain.instance, strPlotOptions);

   else
      % - The spike train doesn't have either an instance or a mapping
      disp('*** STPlotRaster: The spike train contains neither an instance nor a mapping.');
      disp('       Plotting spike train definitions is currently not supported');
      return;
   end
end


% --- FUNCTION STPlotRasterNode
function STPlotRasterNode(node, strPlotOptions)

% -- Handle zero-duration spiketrains
if (node.tDuration == 0)
   disp('*** STPlotRaster: Cannot plot a zero-duration spike train');
   return;
end

% -- Are we using chunked mode?
if (node.bChunkedMode)
   spikeList = node.spikeList;
else
   spikeList = {node.spikeList};
end

% -- Do the plot
hold on;

for (nChunkIndex = 1:length(spikeList))
   if (size(spikeList{nChunkIndex}, 2) == 1)
      % - Instance
      plot(spikeList{nChunkIndex}(:, 1), ones(length(spikeList{nChunkIndex})), strPlotOptions);
   else
      % - Mapping
      plot(spikeList{nChunkIndex}(:, 1) .* node.fTemporalResolution, spikeList{nChunkIndex}(:, 2), strPlotOptions);
   end
end

hold off;
return;


% --- END of STPlotRaster.m ---

% $Log: STPlotRaster.m,v $
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