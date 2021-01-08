function [ExternalForcesComputationResults] = ExternalForcesPrediction(filename, AnalysisParameters, BiomechanicalModel, ModelParameters)
% Prediction of ground reaction forces
%   Ground reaction forces are predicted from motion data.
%
%	Based on :
%	- Fluit, R., Andersen, M. S., Kolk, S., Verdonschot, N., & Koopman, H. F., 2014.
%	Prediction of ground reaction forces and moments during various activities of daily living. Journal of biomechanics, 47(10), 2321-2329.
%	- Skals, S., Jung, M. K., Damsgaard, M., & Andersen, M. S., 2017. 
%	Prediction of ground reaction forces and moments during sports-related movements. Multibody system dynamics, 39(3), 175-195.
%
%   INPUT
%   - filename: name of the file to process (character string)
%   - AnalysisParameters: parameters of the musculoskeletal analysis,
%   automatically generated by the graphic interface 'Analysis' 
%   - BiomechanicalModel: musculoskeletal model
%   - ModelParameters: parameters of the musculoskeletal model, automatically
%   generated by the graphic interface 'GenerateParameters' 
%   OUTPUT
%   - ExternalForcesComputationResults: results of the external forces
%   computation (see the Documentation for the structure)
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________

disp(['External Forces Prediction (' filename ') ...'])

%% Loading data
Human_model = BiomechanicalModel.OsteoArticularModel;
load([filename '/InverseKinematicsResults.mat']); %#ok<LOAD>
q = InverseKinematicsResults.JointCoordinates';
if isfield(InverseKinematicsResults,'FreeJointCoordinates')
    q6dof = InverseKinematicsResults.FreeJointCoordinates';
else
    PelvisPosition = InverseKinematicsResults.PelvisPosition;
    PelvisOrientation = InverseKinematicsResults.PelvisOrientation;
end        
load([filename '/ExperimentalData.mat']); %#ok<LOAD>
time = ExperimentalData.Time;

freq=1/time(2);

%% Creation of a structure to add contact points
for i=1:numel(AnalysisParameters.Prediction.ContactPoint)
    Prediction(i).points_prediction_efforts = AnalysisParameters.Prediction.ContactPoint{i}; %#ok<AGROW>
end
Prediction=verif_Prediction_Humanmodel(Human_model,Prediction);
NbPointsPrediction = numel(Prediction);

%% Gravity
g=[0 0 -9.81]';

%% get rid of the 6DOF joint
if isfield(InverseKinematicsResults,'FreeJointCoordinates')
    Human_model(Human_model(end).child).mother = 0;
    Human_model=Human_model(1:(numel(Human_model)-6));
end


dt=1/freq;
dq=derivee2(dt,q);  % vitesses
ddq=derivee2(dt,dq);  % acc�l�rations

nbframe=size(q,1);

%% D�finition des donn�es cin�matiques du pelvis
% (position / vitesse / acc�l�ration / orientation / vitesse angulaire / acc�l�ration angulaire)
% Kinematical data for Pelvis (Position/speed/acceleration/angles/angular speed/angular acceleration)

if isfield(InverseKinematicsResults,'FreeJointCoordinates')
    p_pelvis=q6dof(:,1:3);  % frame i : p_pelvis(i,:)
    r_pelvis=cell(size(q6dof,1),1);
    for i=1:size(q6dof,1)
        r_pelvis{i}=Rodrigues([1 0 0]',q6dof(i,4))*Rodrigues([0 1 0]',q6dof(i,5))*Rodrigues([0 0 1]',q6dof(i,6)); % matrice de rotation en fonction des rotations successives (x,y,z) : frame i : r_pelvis{i}
    end
else
    p_pelvis = cell2mat(PelvisPosition)';
    r_pelvis  = PelvisOrientation';
end

%dR
dR=zeros(3,3,nbframe);
for ligne=1:3
    for colonne=1:3
        dR(ligne,colonne,:)=derivee2(dt,cell2mat(cellfun(@(b) b(ligne,colonne),r_pelvis,'UniformOutput',false)));
    end
end
w=zeros(nbframe,3);
for i=1:nbframe
    wmat=dR(:,:,i)*r_pelvis{i}';
    w(i,:)=[wmat(3,2),wmat(1,3),wmat(2,1)];
end

% v0
v=derivee2(dt,p_pelvis);
vw=zeros(nbframe,3);
for i=1:nbframe
    vw(i,:)=cross(p_pelvis(i,:),w(i,:));
end
v0=v+vw;

% dv0
dv0=derivee2(dt,v0);

% dw
dw=derivee2(dt,w);

%% Initialisations des diff�rents efforts et leur stockage
for f=1:nbframe
    for n=1:numel(Human_model)
        external_forces_pred(f).fext(n).fext=zeros(3,2); %#ok<AGROW>
    end
end

for pred = 1:NbPointsPrediction
    Prediction(pred).efforts_max=zeros(nbframe,3);
    Prediction(pred).efforts = zeros(nbframe,1);
end
Fx=zeros(NbPointsPrediction,nbframe);
Fy=zeros(NbPointsPrediction,nbframe);
Fz=zeros(NbPointsPrediction,nbframe);

%% Param�tres de l'optimisation fmincon pour probleme lineaire
X0= 1*zeros(3*NbPointsPrediction,1);
lb=-ones(3*NbPointsPrediction,1);
lb(2*NbPointsPrediction+1:3*NbPointsPrediction)=0;
ub=ones(3*NbPointsPrediction,1);
lb_init=lb; ub_init=ub;

options = optimoptions(@fmincon,'Algorithm','sqp','Display','off','GradObj','off','GradConstr','off','TolFun',1e-6,'TolX',1e-6);

%% Calcul frame par frame
h = waitbar(0,['External Forces Prediction (' filename ')']);
Mass = ModelParameters.Mass;
PositionThreshold = AnalysisParameters.Prediction.PositionThreshold;
VelocityThreshold = AnalysisParameters.Prediction.VelocityThreshold;
for i=1:nbframe
    %attribution � chaque articulation de la position/vitesse/acc�l�ration (position/speed/acceleration for each joint)
    Human_model(1).p=p_pelvis(i,:)';
    Human_model(1).R=r_pelvis{i};
    Human_model(1).v0=v0(i,:)';
    Human_model(1).w=w(i,:)';
    Human_model(1).dv0=dv0(i,:)';
    Human_model(1).dw=dw(i,:)';
    for j=2:numel(Human_model)
        Human_model(j).q=q(i,j); %#ok<*SAGROW>
        Human_model(j).dq=dq(i,j);
        Human_model(j).ddq=ddq(i,j);
    end
    % Calcul positions / vitesses / acc�l�ration de chaque solide (computation of position/speed/acceleration for each solid)
    [Human_model,Prediction] = ForwardAllKinematicsPrediction(Human_model,Prediction,1); 
    %% Calcul des efforts maximaux disponibles (computation of maximum available effort)
    for pred = 1:numel(Prediction)
        Prediction(pred).px(i)=Prediction(pred).pos_anim(1);
        Prediction(pred).py(i)=Prediction(pred).pos_anim(2);
        Prediction(pred).pz(i)=Prediction(pred).pos_anim(3);
        Prediction(pred).vitesse_temps(i)=sqrt(Prediction(pred).vitesse(1,:)^2+Prediction(pred).vitesse(2,:)^2+Prediction(pred).vitesse(3,:)^2); % Recuperation de la norme de la vitesse (rep�re monde)
            Cpi = Force_max_TOR(Prediction(pred).pz(i),Prediction(pred).vitesse_temps(i),Mass,PositionThreshold,VelocityThreshold);
            Fx(pred,i)=Cpi;
            Fy(pred,i)=Cpi;
            Fz(pred,i)=Cpi;
            Prediction(pred).efforts_max(i,1)=Cpi; %Fx
            Prediction(pred).efforts_max(i,2)=Cpi; %Fy
            Prediction(pred).efforts_max(i,3)=Cpi; %Fz
    end
    Fmax=[Fx(:,i)' Fy(:,i)' Fz(:,i)'];
    
    %% Direct optimisation by linearization of the dynamical condition.
    A=zeros(6,3*numel(Prediction));
    b1=[0 0 0]';
    b2=[0 0 0]';
    
    [~,b1,b2]=InverseDynamicsSolid_lin(Human_model,g,1,b1,b2);
    bf=b1;
    bt=b2+cross(-p_pelvis(i,:)',b1); %on ramene les couples au niveau du pelvis (torques are expressed at pelvis point)
    b=[bf' bt']';
    
    for k = 1:numel(Prediction)
        % calcul des efforts
        A(1,k)=Prediction(k).efforts_max(i,1);
        A(2,k+numel(Prediction))=Prediction(k).efforts_max(i,2);
        A(3,k+2*numel(Prediction))=Prediction(k).efforts_max(i,3);
        % calcul des moments
        A(4,k+numel(Prediction))=-(Prediction(k).pz(i)-p_pelvis(i,3))*Prediction(k).efforts_max(i,2); %-pz*beta
        A(4,k+2*numel(Prediction))=(Prediction(k).py(i)-p_pelvis(i,2))*Prediction(k).efforts_max(i,3); %py*gamma
        A(5,k)=(Prediction(k).pz(i)-p_pelvis(i,3))*Prediction(k).efforts_max(i,1); %pz*alpha
        A(5,k+2*numel(Prediction))=-(Prediction(k).px(i)-p_pelvis(i,1))*Prediction(k).efforts_max(i,3); %-px*gamma
        A(6,k)=-(Prediction(k).py(i)-p_pelvis(i,2))*Prediction(k).efforts_max(i,1); %-py*alpha
        A(6,k+numel(Prediction))=(Prediction(k).px(i)-p_pelvis(i,1))*Prediction(k).efforts_max(i,2); %px*beta
    end
    
    
    %% Taking friction into account for every point to point link, |Fx|<0.5|Fz| et |Fy|<0.5|Fz|
    Afric=zeros(4*numel(Prediction),3*numel(Prediction));
    bfric=zeros(4*numel(Prediction),1);
    
    coef_friction = AnalysisParameters.Prediction.FrictionCoef;

    for k = 1:(numel(Prediction))
        Afric(k,k)=1*Prediction(k).efforts_max(i,1);
        Afric(k+numel(Prediction),k+numel(Prediction))=1*Prediction(k).efforts_max(i,2);
        Afric(k,k+2*numel(Prediction))=-coef_friction*Prediction(k).efforts_max(i,3);
        Afric(k+numel(Prediction),k+2*numel(Prediction))=-coef_friction*Prediction(k).efforts_max(i,2);
        Afric(k+2*numel(Prediction),k)=-1*Prediction(k).efforts_max(i,1);
        Afric(k+3*numel(Prediction),k+numel(Prediction))=-1*Prediction(k).efforts_max(i,2);
        Afric(k+2*numel(Prediction),k+2*numel(Prediction))=-coef_friction*Prediction(k).efforts_max(i,3);
        Afric(k+3*numel(Prediction),k+2*numel(Prediction))=-coef_friction*Prediction(k).efforts_max(i,3);
    end
    
    %% Minimizing sum of normalized efforts for each punctual joint while respecting dynamical equations and friction
    X = fmincon(@(X) sum(X.^2),X0,Afric,bfric,A,b,lb,ub,[],options);
    
    %% Optimisation de la prochaine minimisation
    lb=max(X-0.45,lb_init); %exp�rimentalement, les bornes ne varient pas de plus ou moins 0.45 (experimentaly, boundaries vary not more than 0.45)
    ub=min(X+0.45,ub_init);

    X0=X; %d'une frame � l'autre, on change tr�s peu de position, donc de valeur d'effort (
    
    %% R�cup�ration des forces finales, stock�es d'abord dans Prediction (Final forces storage without prediction)
    for k = 1:numel(Prediction)
        Prediction(k).efforts(i,1)=X(k)*Prediction(k).efforts_max(i,1);
        Prediction(k).efforts(i,2)=X(k+numel(Prediction))*Prediction(k).efforts_max(i,2);
        Prediction(k).efforts(i,3)=X(k+2*numel(Prediction))*Prediction(k).efforts_max(i,3);
    end
    
    %% Calcul des efforts ext�rieurs tels qu�utilis�s par la suite pour la dynamique
    %% Computation of external forces for use with dynamics
    external_forces_pred=addForces_Prediction_frame_par_frame(X,external_forces_pred,Prediction,Fmax,i);
    
    waitbar(i/nbframe)
end

close(h)
disp(['... External Forces Prediction (' filename ') done'])

%% Filtrage des donn�es

if AnalysisParameters.Prediction.FilterActive
    f_cut = AnalysisParameters.Prediction.FilterCutOff;
    % Conversion sous la forme d'une matrice (conversion into a matrix)
    for i=1:numel(external_forces_pred)
        for j=1:numel(external_forces_pred(i).fext)
            PredictionFx(i,j) = external_forces_pred(i).fext(j).fext(1,1); %#ok<AGROW>
            PredictionFy(i,j) = external_forces_pred(i).fext(j).fext(2,1); %#ok<AGROW>
            PredictionFz(i,j) = external_forces_pred(i).fext(j).fext(3,1); %#ok<AGROW>
            PredictionMx(i,j) = external_forces_pred(i).fext(j).fext(1,2); %#ok<AGROW>
            PredictionMy(i,j) = external_forces_pred(i).fext(j).fext(2,2); %#ok<AGROW> 
            PredictionMz(i,j) = external_forces_pred(i).fext(j).fext(3,2); %#ok<AGROW>
        end
    end
    % Filtrage
    PredictionFiltFx = filt_data(PredictionFx,f_cut,freq);
    PredictionFiltFy = filt_data(PredictionFy,f_cut,freq);
    PredictionFiltFz = filt_data(PredictionFz,f_cut,freq);
    PredictionFiltMx = filt_data(PredictionMx,f_cut,freq);
    PredictionFiltMy = filt_data(PredictionMy,f_cut,freq);
    PredictionFiltMz = filt_data(PredictionMz,f_cut,freq);
    % Remise sous la forme d'une structure (utilis�e pour la dynamique inverse) (definition of a structure used for inverse dynamics)
    for i=1:numel(external_forces_pred)
        for j=1:numel(external_forces_pred(i).fext)
            external_forces_pred(i).fext(j).fext(1,1)=PredictionFiltFx(i,j);
            external_forces_pred(i).fext(j).fext(2,1)=PredictionFiltFy(i,j);
            external_forces_pred(i).fext(j).fext(3,1)=PredictionFiltFz(i,j);
            external_forces_pred(i).fext(j).fext(1,2)=PredictionFiltMx(i,j);
            external_forces_pred(i).fext(j).fext(2,2)=PredictionFiltMy(i,j);
            external_forces_pred(i).fext(j).fext(3,2)=PredictionFiltMz(i,j);
        end
    end
end

%% Pour animation (for animation purpose)

if ~any(strcmp('Visual',fieldnames(external_forces_pred)))
    external_forces_pred(1).Visual=[];
end
if ~isequal(AnalysisParameters.General.InputData, @MVNX_V3)
    for f=1:numel(external_forces_pred) % for every frame
%         % One global force
%             T = zeros(3,2);
%             for i=unique([Prediction.num_solid]) % for every solid
%                 T = T + external_forces_pred(f).fext(i).fext;
%             end
%             % CoP position
%             CoP = cross(T(:,1),T(:,2))/(norm(T(:,1))^2);
%             CoP = CoP - (CoP(3)/T(3,1))*T(:,1); % point on z=0
%             % external_forces structure
%             external_forces_pred(f).Visual = [external_forces_pred(f).Visual [CoP;T(:,1)]];
        % One force for each solid
            for i=unique([Prediction.num_solid]) % for every solid
                T = external_forces_pred(f).fext(i).fext;
                % CoP position
                CoP = cross(T(:,1),T(:,2))/(norm(T(:,1))^2);
                CoP = CoP - (CoP(3)/T(3,1))*T(:,1); % point on z=0
                % external_forces structure
                external_forces_pred(f).Visual = [external_forces_pred(f).Visual [CoP;T(:,1)]];
            end
    end
else
    for f=1:numel(external_forces_pred) % for every frame
    % One force for each solid
        for i=unique([Prediction.num_solid]) % for every solid
            T = external_forces_pred(f).fext(i).fext;
            % CoP position
            CoP = cross(T(:,1),T(:,2))/(norm(T(:,1))^2);
            CoP = CoP - (CoP(3)/T(3,1))*T(:,1); % point on z=0
            % external_forces structure
            external_forces_pred(f).Visual = [external_forces_pred(f).Visual [CoP;T(:,1)]];
        end
%     % One force for each foot
%         % Right foot (solids 52 and 55)
%             T = external_forces_pred(f).fext(52).fext + external_forces_pred(f).fext(55).fext;
%             CoP = cross(T(:,1),T(:,2))/(norm(T(:,1))^2);
%             CoP = CoP - (CoP(3)/T(3,1))*T(:,1); 
%             external_forces_pred(f).Visual = [external_forces_pred(f).Visual [CoP;T(:,1)]];
%         % Left foot (solids 64 and 67)
%             T = external_forces_pred(f).fext(64).fext + external_forces_pred(f).fext(67).fext;
%             CoP = cross(T(:,1),T(:,2))/(norm(T(:,1))^2);
%             CoP = CoP - (CoP(3)/T(3,1))*T(:,1); 
%             external_forces_pred(f).Visual = [external_forces_pred(f).Visual [CoP;T(:,1)]];
%     % One global force
%             T = external_forces_pred(f).fext(52).fext + external_forces_pred(f).fext(55).fext + ...
%                 external_forces_pred(f).fext(64).fext + external_forces_pred(f).fext(67).fext;
%             CoP = cross(T(:,1),T(:,2))/(norm(T(:,1))^2);
%             CoP = CoP - (CoP(3)/T(3,1))*T(:,1); 
%             external_forces_pred(f).Visual = [external_forces_pred(f).Visual [CoP;T(:,1)]];
    end
end

%% Sauvegarde des donn�es (data saving)

if exist([filename '/ExternalForcesComputationResults.mat'],'file')
    load([filename '/ExternalForcesComputationResults.mat']); %#ok<LOAD>
end
ExternalForcesComputationResults.ExternalForcesPrediction = external_forces_pred;

end