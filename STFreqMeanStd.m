function [vFreqMean, vFreqStd, vKey] = STFreqMeanStd(stMappedTrain)

% STFreqMeanStd - FUNCTION Returns the mean frequency and its standard deviation
% $Id: STFreqMeanStd.m 8603 2008-02-27 17:49:41Z dylan $
%
% Usage: [vFreqMean, vFreqStd, vKey] = STFreqMeanStd(stMappedTrain)
%
% Returns the mean frequency and its standard deviation
% (by error propagation) for each address in the spike train:
% error propagation: if y = f(x,z), where x and z are the measures then
% Dy = abs(df/dx)*Dx + abs(df/dz)*Dz (d.. means partial derivative,
% D... is the standard deviation)
% in our case x = ISI and f(x) = 1/x; therefore std of the frequency is std(x)/(mean(x))^2
%
% 'stMappedTrain' is a spike train containing a mapping.
%
% 'vKey' will give the addresses corresponding to each count column in
% 'vFreqMean' and 'vFreqStd'.
%
% In case of sparse spikes, we add fake spikes to include a measure of
% the latency of the first spike, with respect to the start of the
% acquisition and to the end of the acquisition

% Author: ChiaraBartolozzi <chiara@ini.phys.ethz.ch>
% Created: 17th February, 2006 (from STProfileCountAddresses)

% -- Check arguments

if (nargin > 2)
   disp('--- STFreqMeanStd: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STFreqMeanStd: Incorrect usage');
   help STFreqMeanStd;
   return;
end

% - Test that a mapping exists in the spike train
if (~FieldExists(stMappedTrain, 'mapping'))
   disp('*** STFreqMeanStd: The spike train doesn''t contain a mapping');
   return;
end

% - Extract the mapping
mapping = stMappedTrain.mapping;

% - Extract spike lists
if (mapping.bChunkedMode)
   spikeList = mapping.spikeList;
else
   spikeList = {mapping.spikeList};
end

% - Get a list of used addresses
% - Convert spike list to real time signature format
vKey = [];
for (nChunkIndex = 1:length(spikeList))
   vKey = unique([vKey; spikeList{nChunkIndex}(:, 2)]);% used addresses
   spikeList{nChunkIndex}(:, 1) = spikeList{nChunkIndex}(:, 1) .* ...
       mapping.fTemporalResolution;% time
end
% -- CHIARA -- %
sListTime = [];
sListAddr = [];

for (nChunkIndex = 1:length(spikeList))
  % - Get spike list
  sListTime =[sListTime; spikeList{nChunkIndex}(:, 1)]; %time stamps
  sListAddr =[sListAddr; spikeList{nChunkIndex}(:, 2)]; %time stamps
end

% -- Mean Frequencies and their Std, for different addresses
for (nNeuronIndex = 1:length(vKey))
  vISI = diff(sListTime(sListAddr == vKey(nNeuronIndex))); % ISI of one neuron
  % -- when there is only one spike diff returns an empty matrix,
  % the frequency is 1/acquisition_duration with std = measure;
  if isempty(vISI)
      vFreqMean(nNeuronIndex) = 1/mapping.tDuration;
      vFreqStd(nNeuronIndex) =  1/mapping.tDuration;
  else
    % -- Include dummy ISIs for the beginning and end of the spike train
    %       if they are not shorter than the mean of the exsisting ISI
    fMeanISI = mean(vISI);
    if (sListTime(1) >2*fMeanISI)
      vISI = [sListTime(1); vISI];
    end
  
    if (mapping.tDuration - sListTime(end) > 2*fMeanISI)
      vISI = [vISI; mapping.tDuration - sListTime(end)];
    end
    
    % -- Calculate mean and std deviation
    
    fMeanISI = mean(vISI);
    vFreqMean(nNeuronIndex) = 1/fMeanISI;
    vFreqStd(nNeuronIndex) = std(vISI)/((fMeanISI)^2);
  end
end


% -- Extract high-level address indices from vKey,
%       which contains hardware addresses

nNumAddressIndices = sum(~[mapping.stasSpecification.bIgnore]);
cIndices = cell(1, nNumAddressIndices);
[cIndices{:}] = STAddrLogicalExtract(vKey, mapping.stasSpecification);
vKey = [cIndices{:}];


% --- END of STFreqMeanStd.m ---
