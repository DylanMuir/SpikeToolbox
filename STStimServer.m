function [stStimTrain] = STStimServer(stMappedTrain)

% STStimServer - FUNCTION Send a mapped spike train to the PCI-AER board
% $Id: STStimServer.m 3992 2006-05-09 16:01:11Z chiara $
%
% Usage: [stStimTrain] = STStimServer(stTrain)
%
% 'stTrain' is a spike train mapped to a neuron/synapse address, as created
% by STMap.  STStimServer will repeatedly stimulate with the supplied train
% until interrupted.

% Author: Chiara Bartalozzi <chiara@ini.phys.ethz.ch>
% Created: 30th Novemebr, 2004 (from STStimServer.m)

% -- Check arguments

if (nargin > 1)
   disp('--- STStimServer: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STStimServer: Incorrect usage');
   help STStimServer;
   return;
end

% -- Check for a valid spike train

if (~STIsValidSpikeTrain(stMappedTrain))
   disp('*** STExport: This is not a valid spike train');
   return;
end

% -- Check that the spike train has a mapping

if (~isfield(stMappedTrain, 'mapping'))
   disp('*** STExport: Only mapped spike trains can be exported');
   return;
end
% -- Export spike train to PCI-AER format

mStimEvents = STPciaerExport(stMappedTrain);
% mStimEvents is in the format [isi - addr] (matrix Nx2)

% - Transpose to get the correct format for the server stimulation:
% matrix 2xN
stStimTrain = mStimEvents';
% find synchronous events (ISI=0) and puts a delay (ISI=1)
%stStimTrain(1,find(stStimTrain(1,:)==0)) = 10;

disp('Start Stimulation')
% - Start stimulation: it is a continuous stimulation that loops the
% input till when it is stopped
%stStimTrain
PciaerSeqWrite(uint32(stStimTrain));



% --- END of STStimServer.m ---

