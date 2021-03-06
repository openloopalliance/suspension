% Simulates a pair of long, rectangular airskates

% Skate parameters
% These first two parameters define some kind of effective air permeance
% through the perforated layer. They're completely a function of the
% skates' construction.
k = 4e-6*(2.54e-2)^2;  % Air permeability [m^2]
D = 0.250*2.54e-2;      % Thickness of porous layer [m]

n = 2;                  % Number of skates
W = 0.3048;             % Skate width [m]
L = 12*0.3048;          % Skate length [m]

% Independent variable - Gap height
H = linspace(0,4e-3,1e3); % Gap height [m]
% Target gap height [m]
H0 = 3e-3;

% Other system parameters
P_tank = 20684.27e3;   % Pressure of air in tanks [Pa]
T_supp = 300;          % Temperature of supply air to skate compressor [K]
P_tube = 137.8951;     % Tube pressure [Pa]
m_pod = 1000;          % Pod mass [kg]

% Physical constants
M_air = 28.97e-3;     % Molecular weight of air [kg/mol]
R = 8.3144598;        % Molar gas constant [J/K*mol]
g = 9.81;             % Acceleration of gravity [m/s^2]
c = 343;              % Speed of sound [m/s]

% Skate internal pressure
A = n*L*W;             % Total skate area [m^2]
P0 = 2*m_pod*g/A;      % Skate pressure [Pa]
                       % Currently set to 2*m_pod*g/A such that it can
                       % handle a max load of twice the pod weight.

% Intermediate calculations
% Determine temperature of the air based on isentropic expansion
gamma = 1.4;          % Heat capacity ratio (1.4 for ideal gas)
T_out = 258.5;
% Viscosity of air via Sutherland's relation [Pa*s]
mu = 18.27e-6*(T_out/291.15)^(3/2)*(291.15+120)/(T_out+120);
alpha =  sqrt(12*k./(H.^3*D));          % Dimensionless parameter "alpha"

% Pressure profile
x = 0:0.01:W;
alpha0 = sqrt(12*k/(H0^3*D));
P = P0*(1-cosh(alpha0*(x-W/2))/cosh(alpha0*W/2));

% Force as a function of gap height [N]
F = n*L*P0*(W-2./alpha.*tanh(alpha.*W/2));

% Flow rate as a function of gap height [kg/s]
m_flow = (P_tube*M_air/(R*T_out))*...
  W*P0*alpha./(2*mu).*tanh(alpha*W/2).*H.^3.*(1/2-1/3).*(2*(W+L));

% Derivative of force as a function of gap height [N/m]
F_H = n*L*P0*(2./alpha.^2.*tanh(alpha.*W/2) ...
        - W./alpha.*sech(alpha.*W/2).^2) ...
    .*alpha.*(-3/2).*(1./sqrt(H));

% Calculate frequency of oscillation
m_pod_H = F/g;    % Mass as a function of equilibrium ride height [kg]
freq_H = 1/(2*pi).*sqrt(-(1./m_pod_H).*F_H);  % Frequency of oscillation as
                                              % a function of height [Hz]

%% Make plots

% Plot carrying force vs gap height
figure(1)
subplot(2,1,1)
plot(H*1e3,F/g)
ylabel('Force [kg_F]')
xlabel('Gap Height [mm]')

% Plot airflow as a function of gap height
subplot(2,1,2)
plot(H*1e3,m_flow)
ylabel('Flow Rate [kg/s]')
xlabel('Gap Height [mm]')

% Plot vibration frequency as a function of equilibrium gap height
figure(2)
subplot(3,1,1)
plot(H*1e3,freq_H)
ylabel('Vibration Freq. [Hz]')
xlabel('Equilibrium Gap Height [mm]')

% Plot stiffness as a function of gap height
subplot(3,1,2)
plot(H*1e3,-F_H./H/1e9)
ylabel('Stiffness [GPa]')
xlabel('Gap Height [mm]')

% Plot vibration frequency as a function of pod mass
subplot(3,1,3)
plot(m_pod_H,freq_H)
ylabel('Vibration Freq. [Hz]')
xlabel('Pod Mass [kg]')

figure(3)
plot(x,P)

fprintf('\n%i skates at %g m^2 per skate\n',n,W*L)
fprintf('Total skate area: %g m^2\n',A)
fprintf('Air temperature: %g K\n',T_out)