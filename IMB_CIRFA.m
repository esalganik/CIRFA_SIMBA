%% import
clear; close all; clc; load("interfaces.mat"); % import of manual interfaces
% data import and metadata (time range for temperature and heating, initial interfaces, label)
i=1; src{i}="uitjkawi0901td_2023-01-06_16-04-09.csv"; T0(i)=5; T1(i)=50; dT0(i)=2; dT1(i)=13; as0(i)=13; si0(i)=22; hi0(i)=2.07; lbl(i)="AWI 0901"; src_gps{i}="uitjkawi0901gps_2023-01-06_16-03-39.csv"; 
i=2; src{i}="uitjkfmi0501td_2023-01-06_16-04-18.csv"; T0(i)=31; T1(i)=83; dT0(i)=7; dT1(i)=19; as0(i)=NaN; si0(i)=NaN; hi0(i)=NaN; lbl(i)="FMI 0501"; src_gps{i}="uitjkfmi0501gps_2023-01-06_16-04-16.csv"; 
i=3; src{i}="uitjknpol0801td_2023-01-06_16-04-26.csv"; T0(i)=6; T1(i)=166; dT0(i)=2; dT1(i)=35; as0(i)=17; si0(i)=23; hi0(i)=1.74; lbl(i)="NPI 0801"; src_gps{i}="uitjknpol0801gps_2023-01-06_16-04-24.csv"; 
i=4; src{i}="uitjkfmi0705td_2023-01-06_16-04-22.csv"; T0(i)=6; T1(i)=12; dT0(i)=2; dT1(i)=3; as0(i)=NaN; si0(i)=NaN; hi0(i)=NaN; lbl(i)="FMI 0705"; src_gps{i}="uitjkfmi0705gps_2023-01-06_16-04-20.csv"; 
i=5; src{i}="uitjkawi0902td_2023-01-06_16-04-13.csv"; T0(i)=6; T1(i)=15; dT0(i)=2; dT1(i)=4; as0(i)=NaN; si0(i)=NaN; hi0(i)=NaN; lbl(i)="AWI 0902"; src_gps{i}="uitjkawi0902gps_2023-01-06_16-04-11.csv"; 

d_man{1}=d1; d_man{2}=d2; d_man{3}=d3; d_man{4}=d4; d_man{5}=d5;
fb_man{1}=fb1; fb_man{2}=fb2; fb_man{3}=fb3; fb_man{4}=fb4; fb_man{5}=fb5;
sn_man{1}=sn1; sn_man{2}=sn2; sn_man{3}=sn3; sn_man{4}=sn4; sn_man{5}=sn5;

for i = 1:length(src)
    table = readtable(src{i},'NumHeaderLines',1);
    t_raw = table2array(table(:,4)); % time, temperature, all
    T_raw = table2array(table(:,12:251)); % temperature, all
    mode = table2array(table(:,2)); % mode - in situ or heating temperature
    T{i} = T_raw(mode == 10,:); t_T{i} = t_raw(mode == 10); % raw temperature data
    dT{i} = T_raw(mode == 11,:); t_dT{i} = t_raw(mode == 11); % raw heating data
    T{i} = T{i}(T0(i):T1(i),1:240); t_T{i} = t_T{i}(T0(i):T1(i)); % temperature and temperature time
    dT{i} = dT{i}(dT0(i):dT1(i),1:240); t_dT{i} = t_dT{i}(dT0(i):dT1(i)); % heating and heating time
    z{i} = 0:-0.02:-0.02*(size(T_raw,2)-1); % Chain depth
    d_int{i} = interp1(datenum(d_man{i}(:,1)),d_man{i}(:,2),datenum(t_T{i}),'linear','extrap'); % draft, interpolated
    fb_int{i} = interp1(datenum(fb_man{i}(:,1)),fb_man{i}(:,2),datenum(t_T{i}),'linear','extrap'); % freeboard, interpolated
    sn_int{i} = interp1(datenum(sn_man{i}(:,1)),sn_man{i}(:,2),datenum(t_T{i}),'linear','extrap'); % snow surface, interpolated
    table_gps = readtable(src_gps{i},'NumHeaderLines',1); % GPS data import
    t_gps_raw = table2array(table_gps(:,2)); lat_raw = table2array(table_gps(:,3)); lon_raw = table2array(table_gps(:,4)); % time and GPS
    [~,idx] = unique(datenum(t_gps_raw)); % remove repeated time from GPS
    lat{i} = interp1(datenum(t_gps_raw(idx)),lat_raw(idx),datenum(t_T{i}),'linear'); % latitude
    lon{i} = interp1(datenum(t_gps_raw(idx)),lon_raw(idx),datenum(t_T{i}),'linear'); % longitude
end

clearvars table i mode src T0 T1 dT0 dT1 t_raw T_raw src_gps lat_raw lon_raw t_gps_raw idx table_gps
clearvars d1 d2 d3 d4 d5 sn1 sn2 sn3 sn4 sn5 fb1 fb2 fb3 fb4 fb5 d_man fb_man sn_man
save("CIRFA_SIMBA_export.mat","t_T","T","t_dT","dT","z","d_int","fb_int","sn_int","t_dT","lbl","lat","lon","si0","hi0","as0");

%% plots: temperature, temp. gradient, heating
clear; close all; clc; load("CIRFA_SIMBA_export.mat");
figure
tile = tiledlayout(5,3); tile.TileSpacing = 'compact'; tile.Padding = 'none';
for i = 1:5
nexttile
range = min(T{i},[],"all"):0.5:max(T{i},[],"all");
X = datenum(t_T{i}); Y = z{i}; Z = T{i}';
contourf(X,Y,Z,range,'-','ShowText','on','LabelSpacing',400,'LineColor','none'); hold on
plot(datenum(t_T{i}(1)),-0.02*(as0(i)-1),'xr','LineWidth',1); plot(datenum(t_T{i}(1)),-0.02*(si0(i)-1),'xb','LineWidth',1);
plot(datenum(t_T{i}(1)),-0.02*(si0(i)-1)-hi0(i),'xk','LineWidth',1);
plot(datenum(t_T{i}),sn_int{i},'r--','LineWidth',1); plot(datenum(t_T{i}),fb_int{i},'b--','LineWidth',1); plot(datenum(t_T{i}),d_int{i},'k--','LineWidth',1);
load("vik.mat"); colormap((vik)); clim([-20 0]);
t_start = datenum(t_T{i}(1)); t_end = datenum(t_T{i}(end)); xlim([t_start t_end]); xData = linspace(t_start,t_end,4); ax = gca; ax.XTick = xData;
datetick('x','mmm dd','keepticks','keeplimits'); xtickangle(0);
hBar1 = colorbar; ylabel(hBar1,'in situ temperature (°C)','FontSize',8);
hYLabel = ylabel('depth (m)'); set([hYLabel gca],'FontSize',7,'FontWeight','normal'); ylim([0.5*round(-1+2*min(d_int{i})) 0]);

nexttile
range = min(diff(T{i}',1),[],"all"):0.05:max(diff(T{i}',1),[],"all");
X = datenum(t_T{i}); Y = z{i}(1:end-1); Z = diff(T{i}',1);
contourf(X,Y,Z,range,'-','ShowText','on','LabelSpacing',400,'LineColor','none'); hold on
plot(datenum(t_T{i}(1)),-0.02*(as0(i)-1),'xr','LineWidth',1); plot(datenum(t_T{i}(1)),-0.02*(si0(i)-1),'xb','LineWidth',1);
plot(datenum(t_T{i}(1)),-0.02*(si0(i)-1)-hi0(i),'xk','LineWidth',1);
plot(datenum(t_T{i}),sn_int{i},'r--','LineWidth',1); plot(datenum(t_T{i}),fb_int{i},'b--','LineWidth',1); plot(datenum(t_T{i}),d_int{i},'k--','LineWidth',1);
load("vik.mat"); colormap(vik); clim([-1 1.5]);
t_start = datenum(t_T{i}(1)); t_end = datenum(t_T{i}(end)); xlim([t_start t_end]); xData = linspace(t_start,t_end,4); ax = gca; ax.XTick = xData;
datetick('x','mmm dd','keepticks','keeplimits'); xtickangle(0);
hBar1 = colorbar; ylabel(hBar1,'dT/dz (°C/m)','FontSize',8);
set(gca,'FontSize',7,'FontWeight','normal'); ylim([0.5*round(-1+2*min(d_int{i})) 0]);
title(lbl(i),'FontSize',8,'FontWeight','normal');

nexttile
range = -1:0.05:3; % heating range
X = datenum(t_dT{i}); Y = z{i}; Z = dT{i}';
contourf(X,Y,Z,range,'-','ShowText','on','LabelSpacing',400,'LineColor','none'); hold on
plot(datenum(t_T{i}(1)),-0.02*(as0(i)-1),'xr','LineWidth',1); plot(datenum(t_T{i}(1)),-0.02*(si0(i)-1),'xb','LineWidth',1);
plot(datenum(t_T{i}(1)),-0.02*(si0(i)-1)-hi0(i),'xk','LineWidth',1);
plot(datenum(t_T{i}),sn_int{i},'r--','LineWidth',1); plot(datenum(t_T{i}),fb_int{i},'b--','LineWidth',1); plot(datenum(t_T{i}),d_int{i},'k--','LineWidth',1);
load("vik.mat"); colormap((vik));
t_start = datenum(t_T{i}(1)); t_end = datenum(t_T{i}(end)); xlim([t_start t_end]); xData = linspace(t_start,t_end,4); ax = gca; ax.XTick = xData;
datetick('x','mmm dd','keepticks','keeplimits'); xtickangle(0);
hBar1 = colorbar; ylabel(hBar1,'temperature increase (°C)','FontSize',8);
set(gca,'FontSize',7,'FontWeight','normal'); ylim([0.5*round(-1+2*min(d_int{i})) 0]);
end
clearvars i vik X Y Z hBar1 hYLabel xData range tile t_start t_end ax

%% Temperature profiles
figure
i = 3;
% nexttile
for j = 1:10:size(T{i},1)
    plot(T{i}(j,:),z{i}); hold on
end
plot([-25 5],[sn_int{i}(1) sn_int{i}(1)],'g--','LineWidth',1); plot([-25 5],[fb_int{i}(1) fb_int{i}(1)],'g-','LineWidth',1);
plot([-25 5],[sn_int{i}(end) sn_int{i}(end)],'r--','LineWidth',1); plot([-25 5],[fb_int{i}(end) fb_int{i}(end)],'r-','LineWidth',1);
ylim([-1 0]);