clc
clear
close all

load coastline.mat    

%% ================= PATH =================
rootDir = 'E:\ISRO Internship\TRMM_LIS\MAT';   
years = 1999:2013;

%% ================= REGION =================
latMin = 0;   latMax = 32;
lonMin = 60;  lonMax = 100;

latEdges = latMin:1:latMax;
lonEdges = lonMin:1:lonMax;

nLat = length(latEdges)-1;
nLon = length(lonEdges)-1;

%% ================= SPELL TABLE =================
spellData = {
1999,'B','01-Jul','05-Jul'; 1999,'B','12-Aug','16-Aug'; 1999,'B','22-Aug','25-Aug';
2000,'A','12-Jul','15-Jul'; 2000,'A','17-Jul','20-Jul'; 2000,'B','01-Aug','09-Aug';
2001,'A','09-Jul','12-Jul'; 2001,'B','31-Jul','02-Aug';
2002,'B','04-Jul','17-Jul'; 2002,'B','21-Jul','31-Jul';
2003,'A','26-Jul','28-Jul';
2004,'A','30-Jul','01-Aug'; 2004,'B','10-Jul','13-Jul'; 2004,'B','19-Jul','21-Jul'; 2004,'B','26-Jul','31-Jul';
2005,'A','01-Jul','04-Jul'; 2005,'A','27-Jul','01-Aug'; 2005,'B','07-Aug','14-Aug'; 2005,'B','24-Aug','31-Aug';
2006,'A','03-Jul','06-Jul'; 2006,'A','28-Jul','02-Aug'; 2006,'A','05-Aug','07-Aug'; 2006,'A','13-Aug','22-Aug';
2007,'A','01-Jul','04-Jul'; 2007,'A','06-Jul','09-Jul'; 2007,'A','06-Aug','09-Aug'; 2007,'B','18-Jul','22-Jul'; 2007,'B','15-Aug','17-Aug';
2008,'A','27-Jul','29-Jul'; 2008,'A','09-Aug','12-Aug'; 2008,'B','18-Jul','22-Jul'; 2008,'B','15-Aug','17-Aug';
2009,'A','12-Jul','16-Jul'; 2009,'A','19-Jul','23-Jul'; 2009,'B','29-Jul','10-Aug'; 2009,'B','16-Aug','19-Aug';
2010,'A','01-Aug','03-Aug'; 2010,'A','05-Aug','07-Aug'; 2010,'B','17-Jul','20-Jul';
2011,'A','09-Aug','12-Aug'; 2011,'A','26-Aug','28-Aug'; 2011,'B','01-Jul','03-Jul';
2012,'A','11-Aug','13-Aug';
2013,'A','19-Aug','22-Aug';
};

%% ================= VARIABLES =================
varList = { ...
    'Lightning_Radiance', ...
    'Delta_time', ...
    'Lightning_Area', ...
    'Lightning_child', ...
    'Lightning_Duration' };

%% ================= STORAGE =================
cntA = zeros(nLat,nLon);
cntB = zeros(nLat,nLon);

for v = 1:length(varList)
    sumA.(varList{v}) = zeros(nLat,nLon);
    sumB.(varList{v}) = zeros(nLat,nLon);
end

%% ================= MAIN LOOP =================
for y = years

    disp(['Processing year ',num2str(y)])
    folder = fullfile(rootDir,['FinalMat_',num2str(y)]);
    files = dir(fullfile(folder,'*.mat'));

    for f = 1:length(files)

        fname = files(f).name;
        tok = regexp(fname,'\.(\d{4})\.(\d{3})\.','tokens');
        if isempty(tok); continue; end

        jday = str2double(tok{1}{2});
        fileDate = datetime(y,1,1) + days(jday-1);

        spellType = '';
        for s = 1:size(spellData,1)
            if spellData{s,1} == y
                d1 = datetime([spellData{s,3} '-' num2str(y)],'InputFormat','dd-MMM-yyyy');
                d2 = datetime([spellData{s,4} '-' num2str(y)],'InputFormat','dd-MMM-yyyy');
                if fileDate >= d1 && fileDate <= d2
                    spellType = spellData{s,2};
                end
            end
        end
        if isempty(spellType); continue; end

        load(fullfile(folder,fname))

        mask = Lightning_Lat>=latMin & Lightning_Lat<=latMax & ...
               Lightning_Lon>=lonMin & Lightning_Lon<=lonMax;

        lat = Lightning_Lat(mask);
        lon = Lightning_Lon(mask);
        if isempty(lat); continue; end

        [~,~,iLat] = histcounts(lat,latEdges);
        [~,~,iLon] = histcounts(lon,lonEdges);

        valid = iLat>0 & iLon>0;
        iLat = iLat(valid);
        iLon = iLon(valid);

        % ---- Lightning counts ----
        for k = 1:length(iLat)
            if spellType=='A'
                cntA(iLat(k),iLon(k)) = cntA(iLat(k),iLon(k)) + 1;
            else
                cntB(iLat(k),iLon(k)) = cntB(iLat(k),iLon(k)) + 1;
            end
        end

        % ---- Variables ----
        for v = 1:length(varList)

            data = eval([varList{v} '(mask)']);
            data = data(valid);

            for k = 1:length(data)
                if spellType=='A'
                    sumA.(varList{v})(iLat(k),iLon(k)) = ...
                        sumA.(varList{v})(iLat(k),iLon(k)) + data(k);
                else
                    sumB.(varList{v})(iLat(k),iLon(k)) = ...
                        sumB.(varList{v})(iLat(k),iLon(k)) + data(k);
                end
            end
        end
    end
end

%% ================= MEAN =================
for v = 1:length(varList)
    meanA.(varList{v}) = sumA.(varList{v}) ./ max(cntA,1);
    meanB.(varList{v}) = sumB.(varList{v}) ./ max(cntB,1);
end

%% ================= GAUSSIAN SMOOTH =================
sigma = 1; ksize = 5;
[x,y] = meshgrid(-floor(ksize/2):floor(ksize/2));
G = exp(-(x.^2+y.^2)/(2*sigma^2));
G = G/sum(G(:));

cntA = conv2(cntA,G,'same');
cntB = conv2(cntB,G,'same');

for v = 1:length(varList)
    meanA.(varList{v}) = conv2(meanA.(varList{v}),G,'same');
    meanB.(varList{v}) = conv2(meanB.(varList{v}),G,'same');
end

%% ================= FIGURE 1: SPATIAL MEAN LIGHTNING ACTIVITY =================

A = cntA;     % lightning activity (Active)
B = cntB;     % lightning activity (Break)

figure
sgtitle('Spatial Mean Lightning Activity')

subplot(1,2,1)
imagesc(lonEdges,latEdges,A)
set(gca,'YDir','normal')
axis([lonMin lonMax latMin latMax])
caxis([0 50])                     % <<< FIXED MAX = 50
colorbar; colormap(jet)
title('Active Spells')
xlabel('Longitude'); ylabel('Latitude')
hold on
plot(coastlon,coastlat,'k','LineWidth',1)
hold off

subplot(1,2,2)
imagesc(lonEdges,latEdges,B)
set(gca,'YDir','normal')
axis([lonMin lonMax latMin latMax])
caxis([0 50])                     % <<< FIXED MAX = 50
colorbar; colormap(jet)
title('Break Spells')
xlabel('Longitude'); ylabel('Latitude')
hold on
plot(coastlon,coastlat,'k','LineWidth',1)
hold off



%% ================= FIGURES 2–6: VARIABLES =================
for v = 1:length(varList)

    figure
    sgtitle(['Spatial Mean of ' strrep(varList{v},'_',' ')])

    subplot(1,2,1)
    imagesc(lonEdges,latEdges,meanA.(varList{v}))
    set(gca,'YDir','normal')
    axis([lonMin lonMax latMin latMax])
    colorbar; colormap(jet)
    title('Active Spells')
    xlabel('Longitude'); ylabel('Latitude')
    hold on
    plot(coastlon, coastlat, 'k', 'LineWidth', 1)
    hold off

    subplot(1,2,2)
    imagesc(lonEdges,latEdges,meanB.(varList{v}))
    set(gca,'YDir','normal')
    axis([lonMin lonMax latMin latMax])
    colorbar; colormap(jet)
    title('Break Spells')
    xlabel('Longitude'); ylabel('Latitude')
    hold on
    plot(coastlon, coastlat, 'k', 'LineWidth', 1)
    hold off

end
