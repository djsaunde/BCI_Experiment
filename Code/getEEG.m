function inlet = getEEG()
% function to resolve EEG stream

% Get headset input from LSL
disp('Loading the Lab Streaming Layer library...');
lib = lsl_loadlib();

disp('Resolving an EEG stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); 
end

disp('Opening an inlet...');
inlet = lsl_inlet(result{1});