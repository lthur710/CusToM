function [ExperimentalData, InverseKinematicResults] = InverseKinematicsOpti(filename,AnalysisParameters,BiomechanicalModel)
% Computation of the inverse kinematics step thanks to a sqp optimization method
%   
%   INPUT
%   - filename: name of the file to process (character string)
%   - AnalysisParameters: parameters of the musculoskeletal analysis,
%   automatically generated by the graphic interface 'Analysis' 
%   - BiomechanicalModel: musculoskeletal model
%   OUTPUT
%   - ExperimentalData: motion capture data(see the Documentation for the structure)
%   - InverseKinematicResults: results of the inverse kinematics step (see
%   the Documentation for the structure) 
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________

%% Loading useful files
if ~exist(filename,'dir')
    mkdir(filename)
end
disp(['Inverse kinematics (' filename ') ...'])
Human_model = BiomechanicalModel.OsteoArticularModel;
Markers_set = BiomechanicalModel.Markers;

%% Symbolic function generation
% Markers position with respects to joint coordinates
nbClosedLoop = sum(~cellfun('isempty',{Human_model.ClosedLoop}));

%% List of markers from the model
list_markers={};
for ii=1:numel(Markers_set)
    if Markers_set(ii).exist
        list_markers=[list_markers;Markers_set(ii).name]; %#ok<AGROW>
    end
end
%% Number of solids considered in the Inverse Kinematics
if isfield(BiomechanicalModel,'Generalized_Coordinates')
    nb_solid=length(BiomechanicalModel.Generalized_Coordinates.q_red);
else
    nb_solid=size(Human_model,2);  % Number of solids
end

%% Getting real markers position from the c3d file
[real_markers, nb_frame, Firstframe, Lastframe,f_mocap] = Get_real_markers(filename,list_markers, AnalysisParameters); %#ok<ASGLU>

%% Root position
Base_position=cell(nb_frame,1);
Base_rotation=cell(nb_frame,1);
for ii=1:nb_frame
    Base_position{ii}=zeros(3,1);
    Base_rotation{ii}=eye(3,3);
end

%% Initializations

% Linear constraints for the inverse kinematics
% Aeq_ik=zeros(nb_solid);  % initialization
% beq_ik=zeros(nb_solid,1);
% for ii=1:nb_solid
%    if size(Human_model(ii).linear_constraint) ~= [0 0] %#ok<BDSCA>
%        Aeq_ik(ii,ii)=-1;
%        Aeq_ik(ii,Human_model(ii).linear_constraint(1,1))=Human_model(i).linear_constraint(2,1);
%    end    
% end
% linear constraints for inverse kinemeatics, same joint angles for two
% joints
Aeq_ik=zeros(nb_solid);  
beq_ik=zeros(nb_solid,1);
if isfield(BiomechanicalModel,'Generalized_Coordinates')
    solid_red = (BiomechanicalModel.Generalized_Coordinates.q_map'*(1:size(Human_model,2))')';
else
    solid_red=1:size(Human_model,2);  % Number of solids
end
for i=1:length(solid_red)
    jj=solid_red(i);
    if size(Human_model(jj).linear_constraint) ~= [0 0] %#ok<BDSCA>
        Aeq_ik(i,i)=-1;
        ind_col = Human_model(jj).linear_constraint(1,1);
        [~,c]=find(GC.q_map(ind_col,:));
        
        ind_val = Human_model(jj).linear_constraint(2,1);
        [~,cc]=find(GC.q_map(ind_val,:));
        Aeq_ik(i,c)=cc;
    end
end

%% Inverse kinematics frame per frame

options1 = optimoptions(@fmincon,'Display','off','TolFun',1e-3,'MaxFunEvals',20000,'GradObj','off','GradConstr','off');
options2 = optimoptions(@fmincon,'Algorithm','sqp','Display','off','TolFun',1e-2,'MaxFunEvals',20000,'GradObj','off','GradConstr','off');

q=zeros(nb_solid,nb_frame);

addpath('Symbolic_function')

nb_cut=max([Human_model.KinematicsCut]);

Rcut=zeros(3,3,nb_cut);   % initialization of the cut coordinates frames position and orientation
pcut=zeros(3,1,nb_cut);

% Generation of the functions list used in the cost function computation
list_function=cell(nb_cut,1);
for c=1:max([Human_model.KinematicsCut])
    list_function{c}=str2func(sprintf('f%dcut',c));
end
list_function_markers=cell(numel(list_markers),1);
for m=1:numel(list_markers)
    list_function_markers{m}=str2func(sprintf([list_markers{m} '_Position']));
end

% Joint limits
if isfield(BiomechanicalModel,'Generalized_Coordinates')
    q_map=BiomechanicalModel.Generalized_Coordinates.q_map;
    l_inf1=[Human_model.limit_inf]';
    l_sup1=[Human_model.limit_sup]';
    % to handle infinity
    ind_infinf=not(isfinite(l_inf1));
    ind_infsup=not(isfinite(l_sup1));
    % tip to handle inflinity with a complex number.
    l_inf1(ind_infinf)=1i;
    l_sup1(ind_infsup)=1i;
    % new indexing
    l_inf1=q_map'*l_inf1;
    l_sup1=q_map'*l_sup1;
    %find 1i to replay by inf
    l_inf1(l_inf1==1i)=-inf;
    l_sup1(l_sup1==1i)=+inf;
else
    l_inf1=[Human_model.limit_inf]';
    l_sup1=[Human_model.limit_sup]';
end

% Inverse kinematics
h = waitbar(0,['Inverse Kinematics (' filename ')']);
if nbClosedLoop == 0 % if there is no closed loo^p
    for f=1:nb_frame    
        if f == 1      % initial value
            q0=zeros(nb_solid,1);   
            ik_function_objective=@(qvar)CostFunctionSymbolicIK(qvar,nb_cut,real_markers,f,list_function,list_function_markers,Rcut,pcut);
            [q(:,f)] = fmincon(ik_function_objective,q0,[],[],Aeq_ik,beq_ik,l_inf1,l_sup1,[],options1);
        else
            if f > 2
                delta=q(:,f-1)-q(:,f-2);
                q0=q(:,f-1)+delta;
            else            
                q0=q(:,f-1);
            end
        l_inf=max(q(:,f-1)-0.2,l_inf1);
        l_sup=min(q(:,f-1)+0.2,l_sup1); 
        ik_function_objective=@(qvar)CostFunctionSymbolicIK(qvar,nb_cut,real_markers,f,list_function,list_function_markers,Rcut,pcut);
        [q(:,f)] = fmincon(ik_function_objective,q0,[],[],Aeq_ik,beq_ik,l_inf,l_sup,[],options2); 
        end
        waitbar(f/nb_frame)
    end
else
    for f=1:nb_frame    
        if f == 1      % initial value
            q0=zeros(nb_solid,1);   
            ik_function_objective=@(qvar)CostFunctionSymbolicIK(qvar,nb_cut,real_markers,f,list_function,list_function_markers,Rcut,pcut);
            nonlcon=@(qvar)ClosedLoop(qvar,nbClosedLoop);
            [q{1}(:,f)] = fmincon(ik_function_objective,q0,[],[],Aeq_ik,beq_ik,l_inf1,l_sup1,nonlcon,options1);
        else
            if f > 2
                delta=q(:,f-1)-q(:,f-2);
                q0=q(:,f-1)+delta;
            else            
                q0=q(:,f-1);
            end
        l_inf=max(q(:,f-1)-0.2,l_inf1);
        l_sup=min(q(:,f-1)+0.2,l_sup1); 
        ik_function_objective=@(qvar)CostFunctionSymbolicIK(qvar,nb_cut,real_markers,f,list_function,list_function_markers,Rcut,pcut);
        nonlcon=@(qvar)ClosedLoop(qvar,nbClosedLoop);
        [q(:,f)] = fmincon(ik_function_objective,q0,[],[],Aeq_ik,beq_ik,l_inf,l_sup,nonlcon,options2);
        end
        waitbar(f/nb_frame)
    end
end
close(h)

%% Data processing
if AnalysisParameters.IK.FilterActive
    % Data filtering
    q=filt_data(q',AnalysisParameters.IK.FilterCutOff,f_mocap)';
end

% Error computation
KinematicsError=zeros(numel(list_markers),nb_frame);
nb_cut=max([Human_model.KinematicsCut]);
for f=1:nb_frame
    [KinematicsError(:,f)] = ErrorMarkersIK(q(:,f),nb_cut,real_markers,f,list_markers,Rcut,pcut);
end

% Reaffect coordinates
if isfield(BiomechanicalModel,'Generalized_Coordinates')
    q_complet=q_map*q; % real_coordinates
    fq_dep=BiomechanicalModel.Generalized_Coordinates.fq_dep;
    q_dep_map=BiomechanicalModel.Generalized_Coordinates.q_dep_map;
    for ii=1:size(q,2)
    q_complet(:,ii)=q_complet(:,ii)+q_dep_map*fq_dep(q(:,ii)); % add dependancies
    end
    
    q6dof=[q_complet(end-4:end,:);q_complet(1,:)];% joint coordinates of the 6-dof
    q=q_complet(1:end-6,:);% joint coordinates
    q(1,:)=0;% position of the pelvis
else
    q6dof=[q(end-4:end,:);q(1,:)]; % joint coordinates of the 6-dof
    q=q(1:end-6,:);  % joint coordinates
    q(1,:)=0;        % position of the pelvis
end


time=real_markers(1).time';

%% Save data
ExperimentalData.FirstFrame = Firstframe;
ExperimentalData.LastFrame = Lastframe;
ExperimentalData.MarkerPositions = real_markers;
ExperimentalData.Time = time;

InverseKinematicResults.JointCoordinates = q;
InverseKinematicResults.FreeJointCoordinates = q6dof;
InverseKinematicResults.ReconstructionError = KinematicsError;
    
disp(['... Inverse kinematics (' filename ') done'])


%% We delete the folder to the path
rmpath('Symbolic_function')
end
