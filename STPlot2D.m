function [mMeanFreq, tISI] = STPlot2D(stTrain,bRaster,bBar,bPlot,bHist,tBin_0,tBin_f)

% STPlot2D - FUNCTION Make a 2D plot of the mean frequency over a time interval of each pixel in a 2D array.
% $Id: STPlot2D.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [mMeanFreq, tISI] = STPlot2D(stTrain)
%        [mMeanFreq, tISI] = STPlot2D(stTrain,bRaster,bBar,bPlot,bHist)
%        [mMeanFreq, tISI] = STPlot2D(stTrain,bRaster,bBar,bPlot,bHist,tBin_0,tBin_f)
%
% Where: 'stTrain' is a mapped spike train. 
% If bRaster = 1 a raster plot is created, with a bar with the mean freq
% for each neuron on the right side
% If bPlot = 1 a imagesc type of plot will be created in the current axes (or
% a new figure created) showing the mean frequency of each pixel over the
% entire spike train duration.
% If bPlot  = 0, the figure is not created and the function will return
% the mean frequency of each pixel and the ISI vector for each pixel;
% If bHist = 1 the histogram of the ISI distribution is plotted.
% If not specified all the plots and the histogram are created

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004 (modified from STPlotRaster by Chiara)

% -- Check arguments
  
warning off MATLAB:divideByZero
mMeanFreq = [];
tISI = [];

if (nargin > 7)
  disp('--- STPlot2D: Extra arguments ignored');
end

if (nargin < 1)
  disp('*** STPlot2D: Would you like help?');
  help STPlot2D; 
  return;
end

% -- Default

if (nargin == 1)
  bRaster = 1;
  bBar = 1;
  bPlot = 1;
  bHist = 1;
end

if (~isfield(stTrain, 'mapping'))        % check for mapping
  disp('*** STPlot2D: The spike train is not mapped');
  return;
end

stMap = stTrain.mapping;

if (stMap.tDuration == 0)                % check for zero dimension spike trains
   disp('*** STPlot2D: Cannot plot a zero-duration spike train');
   return;
end
    	 				  
% -- CHIARA 
% -- find range of Y neurons and X neurons:
nDim = sum([stMap.stasSpecification.bMajorField]);

if nDim ~= 2    %check for 2D spike trains
  disp('*** STPlot2D: This function supports only 2D arrays');
  return;
end

nNumAddrFields = sum(~[stMap.stasSpecification.bIgnore]);
nValidFieldIndices = find(~[stMap.stasSpecification.bIgnore]);

stasSpecValid = stMap.stasSpecification(nValidFieldIndices);

nMajorFieldIndices = find([stasSpecValid.bMajorField]);

nYAddrIndex = nMajorFieldIndices(2);
nXAddrIndex = nMajorFieldIndices(1);

nMaxY = 2^stMap.stasSpecification(nMajorFieldIndices(2)).nWidth - 1; % row
nMaxX = 2^stMap.stasSpecification(nMajorFieldIndices(1)).nWidth - 1; % col
% initialization for the matrix of the Frequencies 
mMeanFreq = NaN*ones(nMaxY+1,nMaxX+1); % frequency of each pixel

% -- Are we using chunked mode?
if (stMap.bChunkedMode)
  spikeList = stMap.spikeList;
else
  spikeList = {stMap.spikeList};
end
%mMeanFreq =  zeros((nMaxY+1),(nMaxX+1));
%^tISI = 0;

tISI = cell([nMaxY+1 nMaxX+1]);
tLastSpike = cell([nMaxY+1 nMaxX+1]); 
nActiveNeurons = 0;
% initial point
for nRows = 0:nMaxY
  for nCols = 0:nMaxX
    tLastSpike{nRows+1,nCols+1} = 0;
  end
end

% -- if raster plot is enabled
% bar plot of the mean freq. for each pixel, near to the raster plot
if bRaster == 1
  % -- create the color vector
  nSize = ceil((nMaxY+1)/3); % 3 = number of colors
  strColor = {'.c','.m','.y'};
  strPlotOptions = strColor;
  for i = 1:nSize
    strPlotOptions = {strPlotOptions{:},strColor{:}};
  end
  if bBar == 1
    axes('position',[.1 .1 .55 .8]);
  end
  axis([0 spikeList{length(spikeList)}(end,1).* stMap.fTemporalResolution 0 (nMaxX+1)*(nMaxY+1)]);
  hold on;
end
% --
for (nChunkIndex = 1:length(spikeList))
    
  if (nargin == 3) % bin mode
    % -- check time interval
    if tBin_0 < (spikeList{nChunkIndex}(1,1)* stMap.fTemporalResolution)
      disp('***STPlot2DMeanFreq: invalid intial time')
      return;
    end
    if tBin_f > (spikeList{nChunkIndex}(length(spikeList),1) * stMap.fTemporalResolution)
      disp('***STPlot2DMeanFreq: invalid final time')
      return;
    end
    
    [addr{1:nNumAddrFields}] = STAddrLogicalExtract(spikeList{nChunkIndex}(tBin_0:tBin_f, ...
						  2));
  else % mean over the entire acquisition
    
    % -- convert the address into x and y
      [addr{1:nNumAddrFields}] = STAddrLogicalExtract(spikeList{nChunkIndex}(:, 2));
        
  end
  
  nNeuronY = addr{nYAddrIndex};
  nNeuronX = addr{nXAddrIndex};
  
  for nRows = 0:nMaxY
    if bRaster == 1
      index_row = find(nNeuronY==nRows);
      % -- Do the plot
      plot(spikeList{nChunkIndex}(index_row, 1) .* stMap.fTemporalResolution, ...
	   spikeList{nChunkIndex}(index_row, 2),strPlotOptions{nRows + ...
		    1});
    end
    for nCols = 0:nMaxX
      
      index = find(nNeuronY==nRows & nNeuronX==nCols);
      
      if ~isempty(index)
	% if the pixel sent out the address I calculate the delta t
        % between two spikes of the same pixel, then I calculate the
        % mean and the 1/mean is the mean freq.

	tFirstSpike = spikeList{nChunkIndex}(index(1), 1);
	tISIStart = (tFirstSpike - tLastSpike{nRows+1,nCols+1}) .* ...
	    stMap.fTemporalResolution;
	if tISIStart == 0 
	  tISIStart = [];
	end
	tISIChunk = (diff(spikeList{nChunkIndex}(index, 1) .* stMap.fTemporalResolution))';
	tLastSpike{nRows+1,nCols+1} = spikeList{nChunkIndex}(index(length(index)), 1);
	
	tISI{nRows+1,nCols+1} = [tISI{nRows+1, nCols+1} tISIStart tISIChunk];

	nActiveNeurons = nActiveNeurons + 1;
	if nChunkIndex == length(spikeList)
	  tISIStop = (spikeList{nChunkIndex}(length(spikeList{nChunkIndex}), ...
					     1) - tLastSpike{nRows+1,nCols+1}) .* stMap.fTemporalResolution;
	  if tISIStop ~= 0
	    tISI{nRows+1,nCols+1}(length(tISI{nRows+1,nCols+1}) + 1) = tISIStop;
	  end
	  mMeanFreq(nRows+1,nCols+1) = 1/(mean(tISI{nRows+1,nCols+1}));
	  [infx infy] = find(isinf(mMeanFreq));
	  
	  if ~isempty(infx) 
	    mMeanFreq(infx,infy) = 0;
	  end
	  
	  if bRaster == 1
	  vMeanFreq(spikeList{nChunkIndex}(index(1), 2)) = ...
	      mMeanFreq(nRows+1,nCols+1);
	  end
	end
      end
    end
  end  
end

% -- Raster plot
if bRaster == 1
  xlabel('Time (s)');
  ylabel('Neurons');
  x = [1 : (nMaxY+1)*(nMaxY+1)];
  if bBar == 1
    h = axes('position',[.7 .1 .2 .8]);
    barh(vMeanFreq,1);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','w','EdgeColor','k','LineWidth',2);
    axis([0 max(vMeanFreq) 0 ((nMaxX+1)*(nMaxY+1))]);
    xlabel('Mean \it{f} (Hz)');
  end
end

% -- 2D Mean Frequency
if bPlot == 1
  figure
  imagesc(mMeanFreq);
  
  colormap(cool);
  xlabel('Neuron X');
  ylabel('Neuron Y');

  colorbar;
  title('Mean {\it f} Hz')
end

% -- ISI distribution histogram
if bHist == 1
  figure
  nSubPlot = 0;
  dim = ceil(sqrt(length(nActiveNeurons)));
  for nRows= 0:nMaxY
    for nCols = 0:nMaxX
      if ~isempty(tISI{nRows+1,nCols+1})
	nSubPlot = nSubPlot + 1;
	subplot(dim,dim,nSubPlot)
	hist(tISI{nRows+1,nCols+1})
	xlabel('ISI (s)')
	title(strcat('X = ',num2str(nCols),'Y = ',num2str(nRows)))
      end
    end
  end
end


return;

% --- END of STPlot2D.m ---

% $Log: STPlot2D.m,v $
% Revision 1.3  2005/02/10 09:29:20  dylan
% * STPlot2D no longer supports cell arrays of spike trains.
%
% Revision 1.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 1.1  2004/09/06 14:22:28  chiara
% This function now returns the mean frequency  and the ISI of each pixel, and creates the raster plot, the mean activity matrix and the ISI distribution
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
