function STOptionsDescribe(stOptions)

% STOptionsDescribe - FUNCTION Display info about an options structure
% $Id: STOptionsDescribe.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: STOptionsDescribe(stOptions)
%        STOptionsDescribe
%
% This function will print as much info as possible about the toolbox options
% structure 'stOptions'.  For help on obtaining a valid options structure,
% type 'help STOptions'.  If no options structure is provided to
% STOptionsStructDescribe, the current toolbox options will be described.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 1)
   disp('--- STOptionsDescribe: Extra arguments ignored');
end

if (nargin < 1)
   stOptions = STOptions;
end

% -- Describe the structure

if (~STIsValidOptionsStruct(stOptions))
   disp('*** STOptionsDescribe: This is not a toolbox options structure!');
   return;
end

disp('--- Spike toolbox options:');
fprintf(1, '   Toolbox version [%.2f]\n', stOptions.ToolboxVersion);

fprintf(1, '   Operation progress display is ');
if (stOptions.bDisplayProgress)
   fprintf(1, '[on]\n');
else
   fprintf(1, '[off]\n');
end

fprintf(1, '   Default temporal resolution for spike trains:\n');
fprintf(1, '      Instances [%.2f] usec\n', stOptions.InstanceTemporalResolution / 1e-6);
fprintf(1, '      Mappings [%.2f] usec\n', stOptions.MappingTemporalResolution / 1e-6);
fprintf(1, '   Toolbox random number generator [%s]\n', func2str(stOptions.RandomGenerator));
fprintf(1, '   Maximum spike chunk length [%d] spikes\n', stOptions.SpikeChunkLength);
fprintf(1, '   Default spike synchrony matching window [%.2f] msec\n', stOptions.DefaultSynchWindowSize / 1e-3);
fprintf(1, '   Default window size for cross-correlation analysis [%.2f] msec\n', stOptions.DefaultCorrWindow / 1e-3);
fprintf(1, '   Default smoothing kernel for cross-correlation analysis [%s]\n', stOptions.DefaultCorrSmoothingKernel);
fprintf(1, '   Default factor for determining smoothing window for cross-correlation [%.0f]\n', stOptions.DefaultCorrSmoothingWindowFactor);
fprintf(1, '   Default output addressing specification\n      ');
STAddrSpecDescribe(stOptions.stasDefaultOutputSpecification);
fprintf(1, '   Monitor channel ID addressing specification\n      ');
STAddrSpecDescribe(stOptions.stasMonitorChannelID);

fprintf(1, '   Monitor channel address mappings:\n');

for (nChannelIndex = 1:length(stOptions.MonitorChannelsAddressing))
   if (~isempty(stOptions.MonitorChannelsAddressing{nChannelIndex}))
      fprintf(1, '      [%d]: ', nChannelIndex-1);
      STAddrSpecDescribe(stOptions.MonitorChannelsAddressing{nChannelIndex});
   end
end

fprintf(1, '\n');

% --- END of STOptionsDescribe.m ---
