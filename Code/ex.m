% load lab streaming layer library
lib = lsl_loadlib();

% get EEG stream
inlet = getEEG();

% compute norm, used for spectral analysis. depends on sampling frequency
% (250Hz), and a funny math trick we finagled (see 4th line)
ws = 2*pi/250;
wnorm = -pi:ws:pi;
wnorm = wnorm(1:250);
w = wnorm*250*.1604;

% randomly sample a starting time
rand = randsample(10:50, 1);

% x = 1:10;
% Y = exp(rand(30,numel(x))*8);

x = zeros(250, 8);
y = randn(250, 8);

plot(w, y*.01);
set(gca, 'YScale','log', 'YTick', [0 1 10 100], 'YTickLabel', {0 1 10 100}, ...
        'YLim', [0 100], 'XLim', [0 60]);

for i = 1:3000
    [x, y] = getFFT(inlet, x);
    axes(gca);
    plot(w, y*.01);
    set(gca, 'YScale','log', 'YTick', [0.01 1 10 100], 'YTickLabel', {0 1 10 100}, ...
        'YLim', [0.1 100], 'XLim', [0 60]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (microvolts)');
    
    pause(0.1);
end