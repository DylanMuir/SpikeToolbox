function [mMeanFreq, tISI] = STPlot2D(stTrain,bRaster,bBar,bPlot,bHist,tBin_0,tBin_f)

% STPlot2D - FUNCTION Make a 2D plot of the mean frequency over a time interval of each pixel in a 2D array.
% $Id: STPlot2D.m 3987 2006-05-09 13:38:38Z dylan $
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
% Copyright (c) 2004, 2005 Chiara Bartolozzi

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

stasSpecValid = stMap.stasSpecification(~[stMap.stasSpecification.bIgnore]);

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
  %x = [1 : (nMaxY+1)*(nMaxY+1)];
  if bBar == 1
    axes('position',[.7 .1 .2 .8]);
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
