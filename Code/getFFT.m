function getFFT(obj, ~, inlet, x)
% updates value of windowed EEG sample from LSL

% pull sample from from LSL inlet at rate of 250Hz
[vec, ~] = inlet.pull_sample();

% load the state of the Fourier-transformed window into this callback
y = get(obj, 'UserData');

% if we have fewer than 250 samples
if size(x, 1) < 250 % add the current sample to the window
    x = [x; vec];
else % otherwise, remove the oldest sample and add the newest, and compute the FFT
    x(1,:) = [];
    x = [x; vec];
    y = fft(x);
    f = (0:length(y)-1)*60/length(y);
    m = abs(y);
    
    plot(f, m);
    
    disp(m);
end

% set the Fourier-transformed window within the GUI workspace
set(obj, 'UserData', y);
