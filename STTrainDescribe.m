function STTrainDescribe(stTrain)

% STTrainDescribe - FUNCTION Print a description of a spike train
% $Id: STTrainDescribe.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: STTrainDescribe(stTrain)
%
% STDescribe will print as much information as is available about 'stTrain'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options
% stOptions = STOptions;


% -- Check arguments

if (nargin > 1)
   disp('--- STTrainDescribe: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STTrainDescribe: Incorrect number of arguments');
   help STDescribe;
   return;
end


% -- Describe spike train

SameLinePrintf('This is ');

if (isfield(stTrain, 'mapping'))
   if (isfield(stTrain.mapping, 'addrSynapse'))
      SameLinePrintf('a mapped spike train:\n');
      SameLinePrintf('   Addressing format: ');
      STAddrSpecDescribe(stTrain.mapping.stasSpecification);
      SameLinePrintf('   Address indices: ');
      SameLinePrintf('[%d] ', stTrain.mapping.addrFields{:});
      SameLinePrintf('(Logical address [%.4f])\n', stTrain.mapping.addrSynapse);
      
   else     % must be a multiplexed spike train
      SameLinePrintf('a multiplexed mapped spike train:\n');
      SameLinePrintf('   Addressing format: ');
      STAddrSpecDescribe(stTrain.mapping.stasSpecification);      
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
   SameLinePrintf('not a spike train!\n');
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
         
      case {'gamma'}
         SameLinePrintf('      Gamma ISI distribution spike train\n');
         SameLinePrintf('      Mean ISI [%.4f] msec | Var ISI [%.4f] msec\n', ...
                        stTrain.definition.fMeanISI / 1e-3, stTrain.definition.fVarISI / 1e-3);
      otherwise
         SameLinePrintf('      (Unknown definition type)\n');
   end
end

return;

% --- END of STTrainDescribe.m ---
