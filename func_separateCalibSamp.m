function [result] = func_separateCalibSamp(sz,data, fParams, eParams, returnSize)
%��ȡsz�������û���Ƶ
result=zeros(sz,returnSize);
if ~isempty(fParams)
    filtered = filtfilt(fParams.b, fParams.a, data);
    energy = func_calcEnergy(filtered, eParams.size);    
else
    energy = func_calcEnergy(data, eParams.size);    
end

nData = size(energy, 2);
threshold = eParams.threshold * max(energy);

cnt1 = 0;  %cnt of the totalData
cnt2 = 0;  %cnt of strike
while cnt1<nData
    cnt1 = cnt1+1;
    if energy(cnt1) >= threshold
        cnt2 = cnt2+1;%��ȡsz��������Ƶ
        if(cnt2<sz+1)
            result(cnt2,:) = data(max(cnt1 - eParams.guard, 1) + (1:returnSize));
        end
        cnt1 = cnt1 + returnSize -1;%��cnt����return����һ�κ�������û���Ƶ��λ��
    end
end

end

