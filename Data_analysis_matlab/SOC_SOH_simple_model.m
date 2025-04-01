% ---------------------------------
% Load experimental data set
% ---------------------------------

% Simply uncomment the data you want to use (fresh or pre-aged cell).
% Note that the axis scales of the detailed views (Figs. 4-9 below) are
% adjusted to the fresh cell data. The reference SOC plotted in
% Fig. 10 below is manually set to 100 %.

data_exp = readmatrix('Experimental_data_fresh_cell.csv'); % fresh cell
% data_exp = readmatrix('Experimental_data_aged_cell.csv'); % pre-aged cell
t_exp = data_exp(:,1);
I_exp = data_exp(:,2);
V_exp = data_exp(:,3);


% ---------------------------------
% Define model parameters
% ---------------------------------
C_N = 19.96*3600; % Nominal capacity in As.  19.96 Ah = average of first four half-cycles of the fresh cell.
R = 0.004579; % Internal resistance in Ohm

% Open-circuit voltage V0(SOC): vector with 1001 entries, SOC=0...1 in
% steps of 0.001.
data = readmatrix('OCV_vs_SOC_curve.csv');
V0_curve = data(:,2); % Open-circuit voltage in V


% ---------------------------------
% SOC + SOH diagnosis
% ---------------------------------
% Initialize result vectors
SOC = zeros(length(t_exp),1); % Prepare result vector
SOC(1) = 0.5; % Set start SOC to an arbitrary value of 50 %
I_sim = zeros(length(t_exp),1); % Prepare result vector

% Initialize SOH diagnosis 
C_exp = 0;
C_sim = 0;
SOH = [];
t_SOH = [];

% Initialize Coulomb counter
SOC_CC = zeros(length(t_exp),1); % Prepare result vector
SOC_CC(1) = 0;

% Loop over all available experimental time steps
for n = 2:length(t_exp)

    % SOC diagnosis "simple" model
    % --------------------------
    delta_t = t_exp(n)-t_exp(n-1);  % Time step

    % Open-circuit voltage based on linear interpolation
    i = SOC(n-1)*1000+1;
    fi = floor(i);
    if(fi > 1000) fi = 1000; elseif(fi < 1) fi = 1; end % these checks to avoid errors
    V0 = (1-(i-fi))*V0_curve(fi) + (i-fi)*V0_curve(fi+1);
    
    % Calculate next SOC value
    SOC(n) = SOC(n-1) - delta_t/(R*C_N) * (V0 - V_exp(n));
    
    
    % SOH diagnosis simple model
    % --------------------------
    I_sim(n) = 1/R*(V0 - V_exp(n)); % Calculate current from the model
    C_exp = C_exp + abs(I_exp(n)) * delta_t; % Charge throughput experiment 
    C_sim = C_sim + abs(I_sim(n)) * delta_t; % Charge throughput model
    if(C_exp > 2*C_N) % Calculate SOH whenever experimental charge throughput is larger than 2 C_N
        SOH(end+1) = C_exp / C_sim;
        t_SOH(end+1) = t_exp(n);
        C_exp = 0;
        C_sim = 0;
    end
    
    
    % Coulomb counter (using a capacity of 19.96 Ah)
    % ----------------------------------------------
    SOC_CC(n) = SOC_CC(n-1) - delta_t/(19.96*3600)*I_exp(n); 
    if((V_exp(n) > 4.19 && abs(I_exp(n)) < 4) || SOC_CC(n) > 1) % Calibration at upper voltage
        SOC_CC(n) = 1;
    elseif((V_exp(n) < 3.01 && abs(I_exp(n)) < 4) || SOC_CC(n) < 0) % Calibration at lower voltage
        SOC_CC(n) = 0;
    end
 end



% ---------------------------------
% Figures
% ---------------------------------


% Experimental current vs. time
% ---------------------------------
figure(1);
set(gcf,'units','pixel','Position',[10,50,1900,567*0.85]);
set(gca,'units','pixel','Position', [90,85,1780,454*0.85]);
plot(t_exp/3600, I_exp,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0],'Marker','none','MarkerFaceColor',[0, 0, 0],'MarkerSize',3.5);
box on;
legend('Experiment','FontSize',20,'Interpreter','none','Location','south','NumColumns',1);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('Current / A');
ylim([-35 35]);


% Experimental voltage vs. time
% ---------------------------------
figure(2);
set(gcf,'units','pixel','Position',[10,50,1900,567*0.85]);
set(gca,'units','pixel','Position', [90,85,1780,454*0.85]);
plot(t_exp/3600, V_exp,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0],'Marker','none','MarkerFaceColor',[0, 0, 0],'MarkerSize',3.5);
box on;
legend('Experiment','FontSize',20,'Interpreter','none','Location','south','NumColumns',1);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('Voltage / V');
ylim([2.95 4.25]);


% Estimated SOC vs. time
% ---------------------------------
figure(3);
set(gcf,'units','pixel','Position',[10,50,1900,567*0.85]);
set(gca,'units','pixel','Position', [90,85,1780,454*0.85]);
plot(t_exp/3600,SOC_CC*100,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0.9],'Marker','none','MarkerFaceColor',[0, 0, 0.9],'MarkerSize',3.5);
hold on;
plot(t_exp/3600,SOC*100,   'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
legend('Coulomb counter','Voltage-controlled model','FontSize',20,'Interpreter','none','Location','south','NumColumns',2);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('SOC / %');
ylim([-5 105]);


% Detailed views of SOC
% ---------------------------------
figure(4);
set(gcf,'units','pixel','Position',[50,50,590,418]);
set(gca,'units','pixel','Position', [100,85,460,305]);
plot(t_exp/3600,SOC_CC*100,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0.9],'Marker','none','MarkerFaceColor',[0, 0, 0.9],'MarkerSize',3.5);
hold on;
plot(t_exp/3600,SOC*100,   'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('SOC / %');
ylim([-5 105]);
xlim([0 4]);

figure(5);
set(gcf,'units','pixel','Position',[50,50,590,418]);
set(gca,'units','pixel','Position', [100,85,460,305]);
plot(t_exp/3600,SOC_CC*100,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0.9],'Marker','none','MarkerFaceColor',[0, 0, 0.9],'MarkerSize',3.5);
hold on;
plot(t_exp/3600,SOC*100,   'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
legend('Coulomb counter','Voltage-controlled model','FontSize',17,'Interpreter','none','Location','south','NumColumns',1);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('SOC / %');
ylim([-5 105]);
xlim([78.57-4 78.57]);

figure(6);
set(gcf,'units','pixel','Position',[50,50,590,418]);
set(gca,'units','pixel','Position', [100,85,460,305]);
plot(t_exp/3600,SOC_CC*100,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0.9],'Marker','none','MarkerFaceColor',[0, 0, 0.9],'MarkerSize',3.5);
hold on;
plot(t_exp/3600,SOC*100,   'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('SOC / %');
xlim([80.8 80.9]);
ylim([50.5 54.5]);


% Experimental + simulated current vs. time (detailed views)
% ---------------------------------
figure(7);
set(gcf,'units','pixel','Position',[50,50,590,418]);
set(gca,'units','pixel','Position', [100,85,460,305]);
plot(t_exp/3600, I_exp,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0],  'Marker','none','MarkerFaceColor',[0, 0, 0],  'MarkerSize',3.5);
hold on;
plot(t_exp/3600, I_sim,'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
legend('Experiment','Simulation','FontSize',20,'Interpreter','none','Location','north','NumColumns',2);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('Current / A');
xlim([0 4]);
ylim([-50 50]); yticks(-50:25:50);

figure(8);
set(gcf,'units','pixel','Position',[50,50,590,418]);
set(gca,'units','pixel','Position', [100,85,460,305]);
plot(t_exp/3600, I_exp,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0],  'Marker','none','MarkerFaceColor',[0, 0, 0],  'MarkerSize',3.5);
hold on;
plot(t_exp/3600, I_sim,'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
legend('Experiment','Simulation','FontSize',20,'Interpreter','none','Location','north','NumColumns',2);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('Current / A');
xlim([78.57-4 78.57]);
ylim([-50 50]); yticks(-50:25:50);

figure(9);
set(gcf,'units','pixel','Position',[50,50,590,418]);
set(gca,'units','pixel','Position', [100,85,460,305]);
plot(t_exp/3600, I_exp,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0],  'Marker','none','MarkerFaceColor',[0, 0, 0],  'MarkerSize',3.5);
hold on;
plot(t_exp/3600, I_sim,'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
legend('Experiment','Simulation','FontSize',20,'Interpreter','none','Location','north','NumColumns',2);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('Current / A');
xlim([80.8 80.9]);
ylim([-50 50]); yticks(-50:25:50);


% Estimated SOH vs. time
% ---------------------------------
figure(10);
set(gcf,'units','pixel','Position',[50,50,920,652]);
set(gca,'units','pixel','Position',[95,85,795,539]);
plot([0 100],[100 100],'-k','LineWidth',3.5);
% plot([0 100],[83.2 83.2],'-k','LineWidth',3.5);  % Use this line for reference SOH in case of aged cell
hold on;
plot(t_SOH/3600,SOH*100,        'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','o','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',4.5);
hold off; box on;
legend('Reference','"Simple" model','FontSize',20,'Interpreter','none','NumColumns',1,'Position',[0.417,0.7797,0.2859,0.1595]);
set(gca,'FontSize',20);
xlabel('Time / h')
xlim([0 100]); xticks(0:10:100);
ylabel('SOH / %');
ylim([70 115]);


