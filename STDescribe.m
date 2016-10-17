function STDescribe(stTrain)

% FUNCTION STDescribe - Print a description of a spike train
%
% Usage: STDescribe(stTrain)
% STDescribe will print as much information as is available about 'stTrain'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 29th March, 2004

% $Id: STDescribe.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Declare globals

global SPIKE_TOOLBOX_VERSION;


% -- Check arguments

if (nargin > 1)
   disp('--- STDescribe: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STDescribe: Incorrect number of arguments');
   help STDescribe;
   return;
end


% -- Check that defaults exist
STCreateDefaults;


% -- Describe spike train


SameLinePrintf('--- Spike toolbox version [%.2f]\n', SPIKE_TOOLBOX_VERSION);
SameLinePrintf('This is ');

if (isfield(stTrain, 'mapping'))
   if (isfield(stTrain.mapping, 'nNeuron'))
      SameLinePrintf('a mapped spike train:\n');
      SameLinePrintf('   Neuron [%d] Synapse [%d] (Address [%x])\n', ...
                     stTrain.mapping.nNeuron, stTrain.mapping.nSynapse, stTrain.mapping.addrSynapse);
   
   else     % must be a multiplexed spike train
      SameLinePrintf('a multiplexed mapped spike train:\n');
   end
                  
   PrintChunkedMode(stTrain.mapping);  
   PrintDuration(stTrain);
   PrintDefinition(stTrain);

elseif (isfield(stTrain, 'instance'))
   SameLinePrintf('an instantiated spike train:\n')
   PrintChunkedMode(stTrain.instance);
   PrintDuration(stTrain);
   PrintDefinition(stTrain);

elseif (isfield(stTrain, 'definition'))
   SameLinePrintf('a simple spike train definition:\n');
   PrintDefinition(stTrain);
   
else
   SameLinePrintf('a variable of unknown type\n');
end

SameLinePrintf('\n');

return;


% --- FUNCTION PrintChunkedMode
function PrintChunkedMode(stNode)
if (stNode.bChunkedMode)
   SameLinePrintf('   Using chunked mode encoding\n');
end

return;



% --- FUNCTION PrintDuration
function PrintDuration(stTrain)
if (isfield(stTrain, 'instance'))
   tDuration = stTrain.instance.tDuration;
else
   tDuration = stTrain.mapping.tDuration;
end

SameLinePrintf('   Duration [%.2f] seconds\n', tDuration);

return;


% --- FUNCTION PrintDefintion
function PrintDefinition(stTrain)
if (isfield(stTrain, 'definition'))
   SameLinePrintf('   This train contains a definition:\n');
   
   switch (stTrain.definition.strType)
      case {'constant'}
         SameLinePrintf('      Constant frequency spike train\n');
         SameLinePrintf('      Frequency [%.2f] Hz\n', stTrain.definition.fFreq);
         
      case {'linear'}
         SameLinePrintf('      Linear frequency change spike train\n');
         SameLinePrintf('      Start freq [%.2f] Hz ==> End freq [%.2f] Hz\n', ...
                        stTrain.definition.fStartFreq, stTrain.definition.fEndFreq);
         
      case {'sinusoid'}
         SameLinePrintf('      Sinusoidal frequency change spike train\n');
         SameLinePrintf('      Min freq [%.2f] Hz | Max freq [%.2f] Hz\n', ...
                        stTrain.definition.fMinFreq, stTrain.definition.fMaxFreq);
         SameLinePrintf('      Sinusoid period [%.2f] seconds\n', stTrain.definition.tPeriod);
         
      otherwise
         SameLinePrintf('      (Unknown definition type)\n');
   end
end

return;



% --- END of STDescribe.m ---

% $Log: STDescribe.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.4  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%