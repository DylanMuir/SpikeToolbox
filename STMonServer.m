function [varargout] = STMonServer(tDuration)
% STMonServer - FUNCTION Monitors the channels specified in the
% addressing specifications for a duration set by tDuration and returns
% them into the SpikeToolbox format
% usage [stMonTrain_ch1 stMonTrain_ch2 ...] = STMonServer(tDuration)
  
% Author: Chiara Bartalozzi <chiara@ini.phys.ethz.ch>
% Created: 30th Novemebr, 2004 (from STStimServer.m)
  
if nargin < 1
  tDuration = 1;
end

if nargin > 1
  disp('--- STMonServer: Extra arguments ignored');
end
st = STOptions;
nMonChannels = sum(CellForEach(@STIsValidAddrSpec, st.MonitorChannelsAddressing));
% -- AER -- %
stServTrain = PciaerMonGetEvents(tDuration);	
data = fliplr(stServTrain');
stServTrain = double(data);
[varargout{1:nMonChannels}] = STPciaerImport(stServTrain);
