clear all; close all; clc;
[test_raw, Fs] = audioread('recorded_strike.wav');
load(['stylus_global_params.mat'], 'globalParams');
load(['stylus_test_data.mat']);
load(['distance.mat']);
distance = distance(:,2); %求距离
sz=12;%一共敲击多少次
cnt = 1;%第一个麦克风

%% Declare Parameter
touchsound = zeros(sz, globalParams.mic.num, globalParams.detect.win.size);
arrivals.high = zeros(sz, globalParams.mic.num, 1);
arrivals.low = zeros(sz, globalParams.mic.num, size(globalParams.pinpoint.low.filter.freq, 2));
TDoA = zeros(sz, globalParams.mic.num, size(arrivals.high, 3) * size(arrivals.low, 3));
mIdx = char(globalParams.mic.idx(cnt));
test_raw=transpose(test_raw(:,5));
touchsound(:,1,:)=func_separateCalibSamp(sz,test_raw, globalParams.detect.filter, globalParams.detect.energy, globalParams.detect.win.size); %将每次敲击的几段音频选取出来,return size=960
for i=1:sz

%% TDoA
arrivals.high(i,cnt, :) = func_pinpointHighFreq(transpose(squeeze(touchsound(i,cnt, :))), globalParams.pinpoint.high.win, globalParams.pinpoint.high.freq, globalParams.pinpoint.high.WVD);    
arrivals.low(i,cnt, :) = func_pinpointLowFreq(transpose(squeeze(touchsound(i,cnt, :))), arrivals.high(i,cnt, end), globalParams.pinpoint.low.filter);
TDoA(i,cnt, :) = func_calcTDoA(squeeze(arrivals.low(i,cnt, :)), squeeze(arrivals.high(i,cnt, :)));
end

TDoA = squeeze(TDoA(:,1,:));
slope = zeros(size(TDoA,3),1);
error = zeros(size(TDoA,3),1);
distance=transpose(distance);
[slope, error] = func_computeSlope(TDoA, distance);