function STPlot2DRaster(stTrain, bClear)

% STPlot2DRaster - FUNCTION Make a raster plot of the spike train, differentiating between rows
% $Id: STPlot2DRaster.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: STPlot2DRaster(stTrain)
%
% Where: 'stTrain' is either a mapped spike train.  A raster plot will be
% created in the current axes (or a new figure created) showing the spike
% train.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004 (modified from STPlotRaster by Chiara)

% -- Check arguments
warning off MATLAB:divideByZero
if (nargin > 2)
   disp('--- STPlot2DRaster: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STPlot2DRaster: Would you like help?');
   help STPlotRaster;
end


% -- Handle cell arrays of spike trains

if (iscell(stTrain))
   hFig = gcf;
   clf;
   set(hFig, 'UserData', 'CellPlot');
   
   for (nRowIndex = 1:size(stTrain, 1))
      for (nColIndex = 1:size(stTrain, 2))
         subplot(size(stTrain, 1), size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
            STPlot2DRaster(stTrain{nRowIndex, nColIndex}, false);
      end
   end
   return;
end


% - Non-cell array of spike trains; should we clear the figure?
hFig = gcf;
if (~strcmp(get(hFig, 'UserData'), 'CellPlot'))
   clf;
end


% - Detect zero-duration spike trains
if (STIsZeroDuration(stTrain))
   disp('*** STPlot2DRaster: Cannot plot a zero-duration spike train');
   return;
end

% - Check that a mapping exists
if (~FieldExists(stTrain, 'mapping'))        % check for mapping
  disp('*** STPlot2DRaster: Can only plot mapped spike trains');
  return;
end

% - Extract the mapping
stMap = stTrain.mapping;


% -- CHIARA 
% -- find range of Y neurons and X neurons:
nDim = sum([stMap.stasSpecification.bMajorField]);

if nDim ~= 2    %check for 2D spike trains
  disp('***STPlot2DRaster: This function supports only 2D arrays');
  return;
end

nNumAddrFields = sum(~[stMap.stasSpecification.bIgnore]);
nValidFieldIndices = find(~[stMap.stasSpecification.bIgnore]);

stasSpecValid = stMap.stasSpecification(nValidFieldIndices);

nMajorFieldIndices = find([stasSpecValid.bMajorField]);
nYAddrIndex = nMajorFieldIndices(2);
nXAddrIndex = nMajorFieldIndices(1);

nMaxY = 2^stMap.stasSpecification(nMajorFieldIndices(2)).nWidth - 1; % rows
nMaxX = 2^stMap.stasSpecification(nMajorFieldIndices(1)).nWidth - 1; % rows

% -- create the color vector
nSize = ceil((nMaxY+1)/3); % 3 = number of colors
strColor = {'.c','.m','.y'};
strPlotOptions = strColor;
for i = 1:nSize
  strPlotOptions = {strPlotOptions{:},strColor{:}};
end
% -- Are we using chunked mode?
if (stMap.bChunkedMode)
  spikeList = stMap.spikeList;
else
  spikeList = {stMap.spikeList};
end 
mMeanFreq =  zeros((nMaxY+1)*(nMaxX+1),1);
tISI = 0;
% -- Do the plot
figure;
axes('position',[.1 .1 .55 .8]);% Betta
axis([0 spikeList{length(spikeList)}(end,1).* stMap.fTemporalResolution 0 (nMaxX+1)*(nMaxY+1)]);
%axes('position',[.1 .1 .55 .8]);% Betta
hold on;
for (nChunkIndex = 1:length(spikeList))
  % -- convert the address into x and y
  [addr{1:nNumAddrFields}] = STAddrLogicalExtract(spikeList{nChunkIndex}(:, 2));

  nNeuronY = addr{nYAddrIndex};
  nNeuronX = addr{nXAddrIndex};
  for row = 0:nMaxY
    index_row = find(nNeuronY==row);
    % -- Do the plot
    plot(spikeList{nChunkIndex}(index_row, 1) .* stMap.fTemporalResolution, ...
	 spikeList{nChunkIndex}(index_row, 2),strPlotOptions{row+1});
    for col = 0:nMaxX
      index = find(nNeuronX==col & nNeuronY==row);
      if ~isempty(index)
	% if the pixel sent out the address I calculate the delta t
	% between two spikes of the same pixel, then I calculate the
	% mean and the 1/mean is the mean freq.
	tISI = diff(spikeList{nChunkIndex}(index, 1) .* stMap.fTemporalResolution);
	
	mMeanFreq(spikeList{nChunkIndex}(index(1), 2)+1) = ...
	    mMeanFreq(spikeList{nChunkIndex}(index(1), 2)+1) + 1/(mean(tISI));
	infinity = find(isinf(mMeanFreq));
	
	if ~isempty(infinity) 
	  mMeanFreq(infinity) = mMeanFreq(infinity) + 0;
	end
      end
    end
  end
end

xlabel('Time (s)');
ylabel('Neurons');

mMeanFreq = mMeanFreq./length(spikeList);
x = [1 : (nMaxY+1)*(nMaxY+1)];

h = axes('position',[.7 .1 .2 .8]);

%axis(h,[0 max(mMeanFreq) 0 (nMaxX+1)*(nMaxY+1)]);

barh(mMeanFreq,1);

h = findobj(gca,'Type','patch');

set(h,'FaceColor','w','EdgeColor','k','LineWidth',2);
axis([0 max(mMeanFreq) 0 ((nMaxX+1)*(nMaxY+1))]);
xlabel('Mean \it{f} (Hz)');

%axis(h,[0 max(mMeanFreq) 0 (nMaxX+1)*(nMaxY+1)]);
return;




% --- END of STPlot2DRaster.m ---

% $Log: STPlot2DRaster.m,v $
% Revision 2.7  2005/02/22 14:27:54  chiara
% *** empty log message ***
%
% Revision 2.6  2005/02/10 09:28:38  dylan
% * Modified figure-creating functionality of spike toolbox plotting functions.
% STPlotRaster, STPlot2DISI, STPlot2DMeanFreq and STPlot2DRaster now clear the
% current figure before plotting, just like a proper matlab plot function.
%
% Revision 2.5  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.4  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.3  2004/08/20 09:51:20  dylan
% Updated STPlot2DRaster and STPlot2DMeanFreq to have standard help texts (nonote)
%
% Revision 2.2  2004/08/15 10:18:33  chiara
% *** empty log message ***
%
% Revision 2.1  2004/08/02 14:42:08  chiara
% cvs comment:
% Added files:
% STplot2DRaster.m: raster plot for a 2D array, with different colors
% for different rows of the array
% STPlot2DMeanFreq.m: imagesc plot of the mean frequency of each pixel
% in a 2D array
% Modified files:
% STAddrPhysicalExtract.m: fixed a bug for the inversion of the
% addresses in negative logic
% STImport.m: modified the acquisition of he spike train to cut off the
% initial part of spontaneous activity: the monitored spike train starts with the
% beginning of the stimulation
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
