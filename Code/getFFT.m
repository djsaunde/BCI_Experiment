function [x, y] = getFFT(inlet, x)
% updates value of windowed EEG sample from LSL

% pull sample from from LSL inlet at rate of 250Hz
[chunk, ~] = inlet.pull_chunk();

% if we have fewer than 250 samples
if size(x, 1) < 250 % add the current sample to the window
    x = x(1:size(x, 1)-size(chunk, 1), :);
    x = [x; chunk'];
    y = abs(fft(zeros(250, 8)));
else % otherwise, remove the oldest samples and add the newest, and compute the FFT
    x = [x; chunk'];
    x = x(end-249:end,:);
    % w = hamming(8)*hamming(250)';
    % y = x*w;
    X = fft(x);
    y = abs(fftshift(X));
end