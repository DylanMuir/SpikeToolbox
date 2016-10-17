function [mMeanSuppr, mVarSuppr, mMeanAct, mVarAct] =  STPlot2DISI(stTrain, nThreshold)

% STPlot2DISI - FUNCTION Make a raster plot of the spike train,
% differentiating between rows
%
% Usage:  STPlot2DISI(stTrain,nThreshold)
%
% Where: 'stTrain' is a mapped spike train. This function calculates the
% mean and variance of the duration of the inactivation time and of the
% activation time of each pixel in the 2D array. Threshold excludes the
% smaller ISIs so that the ISI dependent on the spike frequency during
% the activation time are not taken in account.
% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004
% modified from STPlotISI by Chiara
% $Id: STPlot2DISI.m 124 2005-02-22 16:34:38Z dylan $

% -- Check arguments
warning off MATLAB:divideByZero
if (nargin > 2)
   disp('--- STPlotISI: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STPlotISI: Would you like help?');
   help STPlot2DISI;
   return;
end

% -- Handle cell arrays of spike trains

if (iscell(stTrain))
   hFig = gcf;
   clf;
   set(hFig, 'UserData', 'CellPlot');
   
   for (nRowIndex = 1:size(stTrain, 1))
      for (nColIndex = 1:size(stTrain, 2))
         clf;
         subplot(size(stTrain, 1), size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
            STPlot2DISI(stTrain{nRowIndex, nColIndex}, nThreshold);
      end
   end
   return;
end

% - Clear the current figure if necessary
hFig = gcf;
if (~strcmp(get(hFig, 'UserData'), 'CellPlot'))
   clf;
end

if (~isfield(stTrain, 'mapping'))        % check for mapping
  disp('This function supports only mapped trains');
  return;
end

stMap = stTrain.mapping;

if (stMap.tDuration == 0)                % check for zero dimension spike
                                         % trains
   disp('*** STPlotISI: Cannot plot a zero-duration spike train');
   return;
end
    if isempty(stMap.spikeList)                % check for zero dimension spike
                                         % trains
   disp('*** STPlotISI: Cannot plot a zero-duration spike train');
   return;
end	 				  
% -- CHIARA 
% -- find range of Y neurons and X neurons:
nDim = sum([stMap.stasSpecification.bMajorField]);

if nDim ~= 2    %check for 2D spike trains
  disp('***STPlot2DISI: This function supports only 2D arrays');
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

% -- Are we using chunked mode?
if (stMap.bChunkedMode)
  spikeList = stMap.spikeList;
else
  spikeList = {stMap.spikeList};
end 

if length(spikeList) < 1
  disp('*** STPlot2DISI: Cannot plot a zero-duration spike train');
   return;
end

Suppression = cell([nMaxY+1, nMaxX+1]);
Activity = cell([nMaxY+1, nMaxX+1]);

for (nChunkIndex = 1:length(spikeList))
  % -- convert the address into x and y
  [addr{1:nNumAddrFields}] = STAddrLogicalExtract(spikeList{nChunkIndex}(:, 2));
  
  nNeuronY = addr{nYAddrIndex};
  nNeuronX = addr{nXAddrIndex};
  for nRows = 0:nMaxY
    for nCols = 0:nMaxX
      index = find(nNeuronX==nCols & nNeuronY==nRows);
      if ~isempty(index)
	tTime{nRows+1,nCols+1} = spikeList{nChunkIndex}(index, 1) .* stMap.fTemporalResolution;
	tISI{nRows+1,nCols+1} = diff(spikeList{nChunkIndex}(index, 1) .* stMap.fTemporalResolution);
	if ~isempty(tISI{nRows+1,nCols+1})
	  index_th{nRows+1,nCols+1} = find(tISI{nRows+1,nCols+1} > nThreshold);
	  n(1)=1;
	  if ~isempty(index_th{nRows+1,nCols+1}) 
	    for tLoop = 1:length(index_th{nRows+1,nCols+1})
	      n(tLoop+1) =  index_th{nRows+1,nCols+1}(tLoop);
	      Suppression{nRows+1,nCols+1}(tLoop) = tTime{nRows+1,nCols+1}(n(tLoop+1)+1) - tTime{nRows+1,nCols+1}(n(tLoop+1));
	      Activity{nRows+1,nCols+1}(tLoop) = tTime{nRows+1,nCols+1}(n(tLoop+1)) - tTime{nRows+1,nCols+1}(n(tLoop));
	    end
	  end
	end
      end
    end
  end
end

for nRows = 0:nMaxY
  for nCols = 0:nMaxX
    if (~isempty(Suppression{nRows+1,nCols+1}) & max(tISI{nRows+1,nCols+1})>0)
      mMeanSuppr(nRows+1,nCols+1) = mean(Suppression{nRows+1,nCols+1});
      mVarSuppr(nRows+1,nCols+1) = var(Suppression{nRows+1,nCols+1});
      mMeanAct(nRows+1,nCols+1) = mean(Activity{nRows+1,nCols+1});
      mVarAct(nRows+1,nCols+1) = var(Activity{nRows+1,nCols+1});
    end
  end
end


return;




% --- END of STPlot2DISI.m ---

% $Log: STPlot2DISI.m,v $
% Revision 1.3  2005/02/22 14:27:54  chiara
% *** empty log message ***
%
% Revision 1.2  2005/02/10 09:28:37  dylan
% * Modified figure-creating functionality of spike toolbox plotting functions.
% STPlotRaster, STPlot2DISI, STPlot2DMeanFreq and STPlot2DRaster now clear the
% current figure before plotting, just like a proper matlab plot function.
%
% Revision 1.1  2004/09/06 14:50:52  chiara
% This function returns mean and variance of the activation and inactivation duration of each pixel in a 2D array
%
% Revision 2.2  2004/08/15 10:18:33  chiara
% *** empty log message ***
%
% Revision 2.1  2004/08/02 14:42:08  chiara
% cvs comment:
% Added files:
% STplot2DISI.m: raster plot for a 2D array, with different colors
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
