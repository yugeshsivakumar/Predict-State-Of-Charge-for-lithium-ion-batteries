% ---------------------------------
% Load experimental data set
% ---------------------------------

% Simply uncomment the data you want to use (fresh or pre-aged cell).
% Note that the axis scales of the detailed views (Figs. 4-9 below) are
% adjusted to the fresh cell data. The reference SOC plotted in
% Fig. 10 below is manually set to 100 %.

global t_exp I_exp V_exp
data_exp = readmatrix('Experimental_data_fresh_cell.csv'); % fresh cell
% data_exp = readmatrix('Experimental_data_aged_cell.csv'); % pre-aged cell
t_exp = data_exp(:,1);
I_exp = data_exp(:,2);
V_exp = data_exp(:,3);


% ---------------------------------
% Define model parameters
% ---------------------------------
global C_N V0_curve Rs R1a R1b C1 D f_shell  

% Extended model
C_N = 19.96*3600; % Nominal capacity in As.  19.96 Ah = average of first four half-cycles of the fresh cell.
Rs = 1e-3; % Serial resistance [Ohm]
% RC-Resistance calculated as R1 = R1a * abs(I) + R1b 
R1a = 4.667e-05; % [Ohm/A] 
R1b = 0.001767; % [Ohm]
C1 = 10.536; % Capacitance [F]
D = 600; % Diffusion coefficient [A]
f_shell = 0.2; % Fraction of capacity of shell []

% Open-circuit voltage V0(SOC): vector with 1001 entries, SOC=0...1 in
% steps of 0.001.
data = readmatrix('OCV_vs_SOC_curve.csv');
V0_curve = data(:,2); % Open-circuit voltage in V


% ---------------------------------
% Extended Model: Integrate DAE system using MATLAB solver
% ---------------------------------
% Initial values: SOC, I, SOC_shell, V_RC1
y0 = [0.5 0 0.5 0]; 

% Define mass matrix. 
M = zeros(4,4);
M(1,1) = C_N; 
M(3,3) = C_N*f_shell; 
M(4,4) = C1; 

% Call numerical solver
global counter  % only needed for screen output
counter = 0;
options = odeset('Mass',M,'MStateDependence','none','RelTol',1e-3,'AbsTol',1e-3);
[t,y] = ode23t(@odefun,[t_exp(1) t_exp(end-1)],y0,options);

% Interpolate simulated SOC and current back to original experimental time scale
SOC = interp1(t,y(:,1),t_exp);
I_sim = interp1(t,y(:,2),t_exp);
SOC_shell = interp1(t,y(:,3),t_exp);
V_RC1 = interp1(t,y(:,4),t_exp);


% ---------------------------------
% SOH diagnosis
% ---------------------------------
% Initialize SOH diagnosis for "extended" model
C_exp = 0;
C_sim = 0;
SOH = [];
t_SOH = [];

% Loop over all available experimental time steps
for n = 2:length(t_exp)
    % SOH diagnosis extended model 
    % --------------------------
    delta_t = t_exp(n)-t_exp(n-1);  % Time step
    C_exp = C_exp + abs(I_exp(n)) * delta_t; % Charge throughput experiment
    C_sim = C_sim + abs(I_sim(n)) * delta_t; % Charge throughput model
    if(C_exp > 2*C_N) % Calculate SOH whenever experimental charge throughput is larger than 2 C_N
        SOH(end+1) = C_exp / C_sim;
        t_SOH(end+1) = t_exp(n);
        C_exp = 0;
        C_sim = 0;
    end
end

 
% ---------------------------------
% Coulomber Counter for SOC reference (using a capacity of 19.96 Ah)
% ---------------------------------
% Initialize Coulomb counter
SOC_CC = zeros(length(t_exp),1); % Prepare result vector
SOC_CC(1) = 0;

% Loop over all available experimental time steps
for n = 2:length(t_exp)
    delta_t = t_exp(n)-t_exp(n-1);  % Time step
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
hold on;
plot(t_SOH/3600,SOH*100,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0.9],'Marker','s','MarkerFaceColor',[0, 0, 0.9],'MarkerSize',5.5);
hold off; box on;
legend('Reference','"Extended" model','FontSize',20,'Interpreter','none','NumColumns',1,'Position',[0.417,0.7797,0.2859,0.1595]);
set(gca,'FontSize',20);
xlabel('Time / h')
xlim([0 100]); xticks(0:10:100);
ylabel('SOH / %');
ylim([70 115]);

% Simulated SOC_shell vs. time
% ---------------------------------
figure(11);
set(gcf,'units','pixel','Position',[10,50,1900,567*0.85]);
set(gca,'units','pixel','Position', [90,85,1780,454*0.85]);
plot(t_exp/3600,SOC_shell*100,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0.9],'Marker','none','MarkerFaceColor',[0, 0, 0.9],'MarkerSize',3.5);
hold on;
plot(t_exp/3600,SOC*100,   'LineWidth',2.0,'LineStyle','-','color',[0.9, 0, 0],'Marker','none','MarkerFaceColor',[0.9, 0, 0],'MarkerSize',3.5);
hold off; box on;
legend('SOC shell','SOC','FontSize',20,'Interpreter','none','Location','south','NumColumns',2);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('SOC / %');
ylim([-5 105]);

% Simulated V_RC1 vs. time
% ---------------------------------
figure(12);
set(gcf,'units','pixel','Position',[10,50,1900,567*0.85]);
set(gca,'units','pixel','Position', [90,85,1780,454*0.85]);
plot(t_exp/3600,V_RC1*1000,'LineWidth',2.0,'LineStyle','-','color',[0, 0, 0.9],'Marker','none','MarkerFaceColor',[0, 0, 0.9],'MarkerSize',3.5);
legend('V(RC1)','FontSize',20,'Interpreter','none','Location','south','NumColumns',2);
set(gca,'FontSize',20);
xlabel('Time / h')
ylabel('Voltage drop RC element / mV');
ylim([-80 80]);


% -----------------------------------------------------------------
% Right-hand side calculation of "extended" model for Matlab solver
% -----------------------------------------------------------------

function f = odefun(t,y)
global V_exp V0_curve Rs R1a R1b D f_shell 
global counter % Needed only for screen output

% Collect all variables
SOC = y(1);
I = y(2);
SOC_shell = y(3);
V_RC1 = y(4);

% Experimental voltage based on linear interpolation at time t
V = (1-(t-floor(t)))*V_exp(floor(t)+1) + (t-floor(t))*V_exp(floor(t)+2);

% Open-circuit voltage based on linear interpolation at SOC_shell
i = SOC_shell*1000+1;
fi = floor(i);
if(fi > 1000) fi = 1000; elseif(fi < 1) fi = 1; end
V0 = (1-(i-fi))*V0_curve(fi) + (i-fi)*V0_curve(fi+1);

% Resistance
R1 = R1a*abs(I) + R1b;

% Calculate right-hand side. Note f2 is an algebraic equation, the rest are
% differential equations.
f1 = -I;
f2 = V - V0 + Rs*I + V_RC1;
f3 = -I-D*(SOC_shell - (SOC-f_shell*SOC_shell)/(1-f_shell));
f4 = I - V_RC1/R1;
f = [f1 ; f2; f3; f4];

% Screen output to make simulation less boring :-)
counter = counter +1;
if(rem(round(counter),5000) == 0)
    fprintf('t=%.2f h\tV=%.4f V\tSOC=%.1f %%\n',t/3600,V,SOC*100);
end
end

