function [OsteoArticularModel]= Pelvis_TLEM(OsteoArticularModel,k,Mass,AttachmentPoint)
%   Based on:
%	V. Carbone et al., �TLEM 2.0 - A comprehensive musculoskeletal geometry dataset for subject-specific modeling of lower extremity,� J. Biomech., vol. 48, no. 5, pp. 734�741, 2015.
%   INPUT
%   - OsteoArticularModel: osteo-articular model of an already existing
%   model (see the Documentation for the structure)
%   - k: homothety coefficient for the geometrical parameters (defined as
%   the subject size in cm divided by 180)
%   - Signe: side of the thigh model ('R' for right side or 'L' for left side)
%   - Mass: mass of the solids
%   - AttachmentPoint: name of the attachment point of the model on the
%   already existing model (character string)
%   OUTPUT
%   - OsteoArticularModel: new osteo-articular model (see the Documentation
%   for the structure) 
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________

%% Variables de sortie :
% "enrichissement de la structure "Human_model""

list_solid={'PelvisSacrum'};

% %% Incr�mentation du num�ro des groupes
% n_group=0;
% for i=1:numel(OsteoArticularModel)
%     if size(OsteoArticularModel(i).Group) ~= [0 0] %#ok<BDSCA>
%         n_group=max(n_group,OsteoArticularModel(i).Group(1,1));
%     end
% end
% n_group=n_group+1;

%% Incr�mentation de la num�rotation des solides

s=size(OsteoArticularModel,2)+1;  %#ok<NASGU> % num�ro du premier solide
for i=1:size(list_solid,2)      % num�rotation de chaque solide : s_"nom du solide"
    if i==1
        eval(strcat('s_',list_solid{i},'=s;'))
    else
        eval(strcat('s_',list_solid{i},'=s_',list_solid{i-1},'+1;'))
    end
end

% trouver le num�ro de la m�re � partir du nom du point d'attache : 'attachment_pt'
if numel(OsteoArticularModel) == 0
    s_mother=0;
    pos_attachment_pt=[0 0 0]';
else
%     AttachmentPoint=varargin{1};
    test=0;
    for i=1:numel(OsteoArticularModel)
        for j=1:size(OsteoArticularModel(i).anat_position,1)
            if strcmp(AttachmentPoint,OsteoArticularModel(i).anat_position{j,1})
                s_mother=i;
                pos_attachment_pt=OsteoArticularModel(i).anat_position{j,2}+OsteoArticularModel(s_mother).c;
                test=1;
                break
            end
        end
        if i==numel(OsteoArticularModel) && test==0
            error([AttachmentPoint ' is no existent'])
        end
    end
    if OsteoArticularModel(s_mother).child == 0      % si la m�re n'a pas d'enfant
        OsteoArticularModel(s_mother).child = eval(['s_' list_solid{1}]);    % l'enfant de cette m�re est ce solide
    else
        [OsteoArticularModel]=sister_actualize(OsteoArticularModel,OsteoArticularModel(s_mother).child,eval(['s_' list_solid{1}]));   % recherche de la derni�re soeur
    end
end


%%                     D�finition des noeuds
%
% TLEM 2.0 � A COMPREHENSIVE MUSCULOSKELETAL GEOMETRY DATASET FOR SUBJECT-SPECIFIC MODELING OF LOWER EXTREMITY
%
%  V. Carbonea*, R. Fluita*, P. Pellikaana, M.M. van der Krogta,b, D. Janssenc, M. Damsgaardd, L. Vignerone, T. Feilkasf, H.F.J.M. Koopmana, N. Verdonschota,c
%
%  aLaboratory of Biomechanical Engineering, MIRA Institute, University of Twente, Enschede, The Netherlands
%  bDepartment of Rehabilitation Medicine, Research Institute MOVE, VU University Medical Center, Amsterdam, The Netherlands
%  cOrthopaedic Research Laboratory, Radboud University Medical Centre, Nijmegen, The Netherlands
%  dAnyBody Technology A/S, Aalborg, Denmark
%  eMaterialise N.V., Leuven, Belgium
%  fBrainlab AG, Munich, Germany
% *The authors Carbone and Fluit contributed equally.
% Journal of Biomechanics, Available online 8 January 2015, http://dx.doi.org/10.1016/j.jbiomech.2014.12.034
%% Adjustement of k
k=k*1.2063; %to fit 50th percentile person of 1.80m height 
%% ------------------------- Pelvis ----------------------------------------

% Position du CoM par rapport au rep�re de centr� au milieu RASIS-LASIS
CoM_Pelvis = k*[-0.0484;	-0.0355;	0.0];

%milieu de RASIS et ASIS dans le rep�re centr� � la hanche droite
Hip_midRASISASIS = k*[0.0338;0.0807;-0.0843];

% Position des noeuds dans le rep�re centr� au milieu de RASIS et ASIS
Pelvis_HipJointRightNode = k*[-0.0338;-0.0807;0.0843]                           - CoM_Pelvis;
Pelvis_HipJointLeftNode = k*[-0.0338;-0.0807;-0.0843]                           - CoM_Pelvis;
Pelvis_HipJointsCenterNode = (Pelvis_HipJointLeftNode+Pelvis_HipJointRightNode)/2-CoM_Pelvis;

% ------------------------- Sacrum ----------------------------------------

% Position des noeuds
% Sacrum_L5JointNode = k*[-65;30;0]/1000- CoM_Pelvis; % D�fini � la main sur la g�om�trie du Sacrum .STL

Pelvis_L5JointNode = k*[-0.0664;  0.0224; 0]-CoM_Pelvis; %from TLEM to OldPelvis Morphing


%% D�finition des positions anatomiques

Pelvis_position_set= {...
    'RFWT',                     (k*[0;0;0.11770]                 -CoM_Pelvis); ...
    'LFWT',                     (k*[0;0;-0.11770]                -CoM_Pelvis); ...
    'RBWT',                     (k*[-0.1232;-0.000299;0.0373]    -CoM_Pelvis); ...
    'LBWT',                     (k*[-0.1232;-0.000299;-0.0332]   -CoM_Pelvis); ...
    'RightPubicTubercle', ((k*[0.0489;	-0.0032;	-0.0853]-Hip_midRASISASIS)   -CoM_Pelvis); ...
    'LeftPubicTubercle', ([1 0 0;0 1 0;0 0 -1]*(k*[0.0489;	-0.0032;	-0.0853]-Hip_midRASISASIS )  -CoM_Pelvis); ...
    'Pelvis_HipJointRightNode', Pelvis_HipJointRightNode; ...
    'Pelvis_HipJointLeftNode',  Pelvis_HipJointLeftNode; ...
    'Pelvis_LowerTrunkNode',    Pelvis_L5JointNode; ...
        'Pelvis_L5JointNode', Pelvis_L5JointNode; ...
    'Pelvis_HipJointsCenterNode', Pelvis_HipJointsCenterNode; ...
    'CoMPelvis',                [0; 0; 0]...
    };

Side={{'R';[1 0 0;0 1 0;0 0 1]},{'L';[1 0 0;0 1 0;0 0 -1]}};

for i=1:2 % positions anatomiques des 2 c�t�s
    Signe=Side{i}{1}; Mirror=Side{i}{2};
    Pelvis_position_set = [Pelvis_position_set;...
        {...
        ['AdductorBrevisDistal1Origin1' Signe 'Pelvis'],Mirror*(k*[0.023190;-0.030860;-0.074680]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorBrevisDistal2Origin1' Signe 'Pelvis'],Mirror*(k*[0.022120;-0.032640;-0.073820]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorBrevisMid1Origin1' Signe 'Pelvis'],Mirror*(k*[0.028290;-0.02370;-0.074560]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorBrevisMid2Origin1' Signe 'Pelvis'],Mirror*(k*[0.025280;-0.027880;-0.074880]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorBrevisProximal1Origin1' Signe 'Pelvis'],Mirror*(k*[0.036760;-0.011140;-0.072780]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorBrevisProximal2Origin1' Signe 'Pelvis'],Mirror*(k*[0.03220;-0.018210;-0.073770]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorLongus1Origin1' Signe 'Pelvis'],Mirror*(k*[0.043680;-0.006170;-0.07330]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorLongus2Origin1' Signe 'Pelvis'],Mirror*(k*[0.043130;-0.007080;-0.074220]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorLongus3Origin1' Signe 'Pelvis'],Mirror*(k*[0.042660;-0.008010;-0.075160]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorLongus4Origin1' Signe 'Pelvis'],Mirror*(k*[0.042160;-0.009040;-0.0760]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorLongus5Origin1' Signe 'Pelvis'],Mirror*(k*[0.041710;-0.010260;-0.076950]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorLongus6Origin1'	Signe 'Pelvis'],Mirror*(k*[0.04150;-0.011540;-0.077750]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusDistal1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.030790;-0.063870;-0.041590]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusDistal2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.024270;-0.064480;-0.04670]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusDistal3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.011840;-0.062170;-0.055260]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusMid1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.004990;-0.055780;-0.057610]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusMid2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.002910;-0.060260;-0.054620]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusMid3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.010420;-0.061650;-0.050720]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusMid4Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.016430;-0.062980;-0.046230]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusMid5Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.020990;-0.064490;-0.041020]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusMid6Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.025140;-0.063490;-0.035260]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusProximal1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.025230;-0.030140;-0.077450]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusProximal2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.022240;-0.035850;-0.073240]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusProximal3Origin1'	Signe 'Pelvis'],Mirror*(k*[0.019860;-0.041510;-0.069440]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['AdductorMagnusProximal4Origin1'	Signe 'Pelvis'],Mirror*(k*[0.016990;-0.04660;-0.065560]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['BicepsFemorisCaputLongum1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.047380;-0.042470;-0.026110]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GemellusInferior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.035620;-0.016460;-0.015670]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GemellusSuperior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.048280;-0.006420;-0.035040]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusInferior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.088050;0.039450;-0.0590]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusInferior2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.084670;0.035580;-0.048970]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusInferior3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.089480;0.023790;-0.070410]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusInferior4Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.084920;0.018960;-0.057620]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusInferior5Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.082670;0.009140;-0.076550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusInferior6Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.079870;0.008920;-0.072690]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusSuperior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.078110;0.12125000;-0.018150]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusSuperior2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.070180;0.11931000;-0.016550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusSuperior3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.087230;0.10144000;-0.029560]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusSuperior4Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.076690;0.095120;-0.023390]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusSuperior5Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.087660;0.079890;-0.037270]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMaximusSuperior6Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.079930;0.076670;-0.030440]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusAnterior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.024350;0.10368000;0.029590]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusAnterior2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.02270;0.11128000;0.039770]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusAnterior3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.010680;0.094340;0.035870]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusAnterior4Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.008560;0.10307000;0.045590]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusAnterior5Origin1'	Signe 'Pelvis'],Mirror*(k*[0.010040;0.090050;0.037420]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusAnterior6Origin1'	Signe 'Pelvis'],Mirror*(k*[0.011130;0.09560;0.044590]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusPosterior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.050110;0.12595000;0.003490]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusPosterior2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.037220;0.11308000;0.014770]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusPosterior3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.060540;0.11029000;-0.01550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusPosterior4Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.041050;0.096640;-0.002280]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusPosterior5Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.064820;0.083090;-0.019270]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMediusPosterior6Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.04990;0.074540;-0.012470]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMinimusAnterior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.008240;0.084330;0.029170]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMinimusAnterior2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.009410;0.068940;0.025320]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMinimusMid1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.027010;0.074570;0.004480]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMinimusMid2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.010050;0.051860;0.012770]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMinimusPosterior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.037740;0.052150;-0.00660]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['GluteusMinimusPosterior2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.026390;0.033740;0.003450]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Gracilis1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.01360;-0.049190;-0.064660]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Gracilis2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.024570;-0.030540;-0.076140]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusLateralis1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.009310;0.093860;0.030650]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusLateralis1Via2'	Signe 'Pelvis'],Mirror*(k*[0.018490;0.030890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusLateralis2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.001220;0.066240;0.009930]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusLateralis2Via2'	Signe 'Pelvis'],Mirror*(k*[0.018490;0.030890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMedialis1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.041380;0.12323000;0.006770]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMedialis1Via2'	Signe 'Pelvis'],Mirror*(k*[0.018490;0.030890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMedialis2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.044170;0.10243000;-0.016290]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMedialis2Via2'	Signe 'Pelvis'],Mirror*(k*[0.018490;0.030890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMid1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.020440;0.10574000;0.026840]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMid1Via2'	Signe 'Pelvis'],Mirror*(k*[0.018490;0.030890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMid2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.024490;0.076580;-0.002230]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['IliacusMid2Via2'	Signe 'Pelvis'],Mirror*(k*[0.018490;0.030890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorExternusInferior1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.01270;-0.040040;-0.045990]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorExternusInferior2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.001430;-0.041210;-0.0550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorExternusSuperior1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.023380;-0.00470;-0.052410]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorExternusSuperior2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.026410;-0.012390;-0.063550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorExternusSuperior3Origin1'	Signe 'Pelvis'],Mirror*(k*[0.029950;-0.020760;-0.073770]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.00230;0.026970;-0.027560]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus1Via2'	Signe 'Pelvis'],Mirror*(k*[-0.045480;-0.01870;-0.031210]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.025680;0.023610;-0.023740]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus2Via2'	Signe 'Pelvis'],Mirror*(k*[-0.045480;-0.01870;-0.031210]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus3Origin1'	Signe 'Pelvis'],Mirror*(k*[0.016640;0.003530;-0.04450]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus3Via2'	Signe 'Pelvis'],Mirror*(k*[-0.045480;-0.01870;-0.031210]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus4Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.026930;-0.00750;-0.034640]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus4Via2'	Signe 'Pelvis'],Mirror*(k*[-0.045480;-0.01870;-0.031210]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus5Origin1'	Signe 'Pelvis'],Mirror*(k*[0.00540;-0.034140;-0.061070]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus5Via2'	Signe 'Pelvis'],Mirror*(k*[-0.045480;-0.01870;-0.031210]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus6Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.024980;-0.034050;-0.040850]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['ObturatorInternus6Via2'	Signe 'Pelvis'],Mirror*(k*[-0.045480;-0.01870;-0.031210]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Pectineus1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.0160;0.024040;-0.029070]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Pectineus2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.022060;0.015450;-0.035480]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Pectineus3Origin1'	Signe 'Pelvis'],Mirror*(k*[0.028320;0.00760;-0.042720]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Pectineus4Origin1'	Signe 'Pelvis'],Mirror*(k*[0.035890;0.000550;-0.049820]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Piriformis1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.071570;0.05790;-0.056680]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['PsoasMajorT12I_TMVia5' Signe  'Pelvis'],Mirror*k*[-0.0313    0.0050    0.0653]';... %from Krigeage
        ['PsoasMajorL1I_TMVia4' Signe  'Pelvis'],Mirror*k*[-0.0313    0.0050    0.0643]';... %from Krigeage
        ['PsoasMajorL2I_TMVia3' Signe  'Pelvis'],Mirror*k*[-0.0311    0.0049    0.0620]';... %from Krigeage
        ['PsoasMajorL3I_TMVia2' Signe  'Pelvis'],Mirror*k*[   -0.0309    0.0048    0.0584]';... %from Krigeage
        ['PsoasMajorL4I_TMVia1' Signe  'Pelvis'],Mirror*k*[-0.0305    0.0048    0.0517]';... %from Krigeage
        ['PsoasMajorL5_TMVia1' Signe  'Pelvis'],Mirror*k*[ -0.0303    0.0049    0.0480]';... %from Krigeage
        ['PsoasMajor1T_TMVia5' Signe  'Pelvis'],Mirror*k*[-0.0436   -0.0001    0.0673]';... %from Krigeage
        ['PsoasMajor2T_TMVia4' Signe  'Pelvis'],Mirror*k*[-0.0434   -0.0001    0.0653]';... %from Krigeage
        ['PsoasMajor3T_TMVia3' Signe  'Pelvis'],Mirror*k*[-0.0433   -0.0001    0.0640]';... %from Krigeage
        ['PsoasMajor4T_TMVia2' Signe  'Pelvis'],Mirror*k*[-0.0427   -0.0001    0.0555]';... %from Krigeage
        ['PsoasMajor5T_TMVia1' Signe  'Pelvis'],Mirror*k*[-0.0431   -0.0001    0.0607]';... %from Krigeage
        ['PsoasMajor1Via1' Signe  'Pelvis'],Mirror*(k*[0.013490;0.032890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['PsoasMajor2Via1' Signe  'Pelvis'],Mirror*(k*[0.013490;0.032890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['PsoasMajor3Via1' Signe  'Pelvis'],Mirror*(k*[0.013490;0.032890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['PsoasMajor4Via1'	Signe 'Pelvis'],Mirror*(k*[0.013490;0.032890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['PsoasMajor5Via1' Signe  'Pelvis'],Mirror*(k*[0.013490;0.032890;-0.001550]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['QuadratusFemoris1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.024850;-0.036230;-0.017030]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['QuadratusFemoris2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.02230;-0.044280;-0.021040]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['QuadratusFemoris3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.021540;-0.052630;-0.026940]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['QuadratusFemoris4Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.021710;-0.060720;-0.032230]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['RectusFemoris1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.007840;0.034330;0.011270]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['RectusFemoris2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.020730;0.04280;0.016130]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Sartorius1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.031950;0.078610;0.032610]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Semimembranosus1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.038320;-0.027610;-0.015480]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Semimembranosus2Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.034010;-0.042980;-0.01490]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Semimembranosus3Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.02710;-0.056770;-0.024390]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Semitendinosus1Origin1'	Signe 'Pelvis'],Mirror*(k*[-0.043160;-0.057260;-0.034470]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['TensorFasciaeLatae1Origin1'	Signe 'Pelvis'],Mirror*(k*[0.022490;0.091550;0.046770]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['TensorFasciaeLatae2Origin1'	Signe 'Pelvis'],Mirror*(k*[0.029420;0.086140;0.042660]-Hip_midRASISASIS)-CoM_Pelvis;...
        ['Wrap' Signe 'Pelvis' 'GluteusMaximus'],Mirror*(k*[-0.0201;	0.1060;	0.0435]-Hip_midRASISASIS)-CoM_Pelvis;...

        }]; %#ok<AGROW>
end

%%                     Mise � l'�chelle des inerties

    %% ["Adjustments to McConville et al. and Young et al. body segment inertial parameters"] R. Dumas
    % ------------------------- Pelvis ----------------------------------------
    Length_Pelvis = norm(Pelvis_HipJointsCenterNode-Pelvis_L5JointNode);
    [I_Pelvis]=rgyration2inertia([100 107 95 25*1i 12*1i 8*1i], Mass.Pelvis_Mass, [0 0 0], Length_Pelvis);

%% Cr�ation de la structure "Human_model"

num_solid=0;
%% Pelvis
% Pelvis
num_solid=num_solid+1;        % solide num�ro ...
name=list_solid{num_solid}; % nom du solide
eval(['incr_solid=s_' name ';'])  % num�ro du solide dans le mod�le
OsteoArticularModel(incr_solid).name=name;               % nom du solide
OsteoArticularModel(incr_solid).sister=0;                      % sister
OsteoArticularModel(incr_solid).child=0;       % child
OsteoArticularModel(incr_solid).mother=s_mother;                      % mother
OsteoArticularModel(incr_solid).a=[0 0 0]';                    % axe de rotation
OsteoArticularModel(incr_solid).joint=1;                       % type d'articulation : 1:pivot / 2:glissi�re
OsteoArticularModel(incr_solid).calib_k_constraint=[];         % initialisation des contraintes d'optimisation pour la calibration de la longueur des membres
OsteoArticularModel(incr_solid).u=[];                          % rotation fixe selon l'axe u d'un angle theta (apr�s la rotation q)
OsteoArticularModel(incr_solid).theta=[];
OsteoArticularModel(incr_solid).KinematicsCut=[];              % coupure cin�matique
OsteoArticularModel(incr_solid).ClosedLoop=[];                 % si solide de fermeture de boucle : {num�ro du solide i sur lequel est attach� ce solide ; point d'attache (rep�re du solide i)}
OsteoArticularModel(incr_solid).ActiveJoint=1;                 % 1 si articulation active / 0 si articulation passive
OsteoArticularModel(incr_solid).Visual=1;                      % 1 si il y a un visuel associ� / 0 sinon
% OsteoArticularModel(incr_solid).Group=[n_group 1];                   % groupe pour la calibration dynamique
OsteoArticularModel(incr_solid).b=pos_attachment_pt;                    % position du point d'attache par rapport au rep�re parent
OsteoArticularModel(incr_solid).c=[0 0 0]';                    % position du centre de masse dans le rep�re local
OsteoArticularModel(incr_solid).m=Mass.Pelvis_Mass;                 % masse
OsteoArticularModel(incr_solid).I=[I_Pelvis(1) I_Pelvis(4) I_Pelvis(5); I_Pelvis(4) I_Pelvis(2) I_Pelvis(6); I_Pelvis(5) I_Pelvis(6) I_Pelvis(3)];                  % matrice d'inertie de r�f�rence
OsteoArticularModel(incr_solid).anat_position=Pelvis_position_set;
OsteoArticularModel(incr_solid).linear_constraint=[];
OsteoArticularModel(incr_solid).L={'Pelvis_HipJointsCenterNode';'Pelvis_LowerTrunkNode'};
OsteoArticularModel(incr_solid).v= [];
OsteoArticularModel(incr_solid).visual_file = 'TLEM/PelvisSacrum.mat';

% Wrapping
OsteoArticularModel(incr_solid).wrap(1).name=['Wrap' 'R' 'Pelvis' 'GluteusMaximus'];
OsteoArticularModel(incr_solid).wrap(1).anat_position=['Wrap' 'R' 'Pelvis' 'GluteusMaximus'];
OsteoArticularModel(incr_solid).wrap(1).type='C'; % C: Cylinder or S: Sphere
OsteoArticularModel(incr_solid).wrap(1).R=0.0600;
OsteoArticularModel(incr_solid).wrap(1).orientation=[-0.999158540440827,-0.0232314727333666,0.0338000000000000;...
                                                    -0.0410147664159582,0.565940670078522,-0.823400000000000;...
                                                    0,-0.824118593787152,-0.566400000000000];
OsteoArticularModel(incr_solid).wrap(2).location=k*[-0.0201;	0.1060;	0.0435]-Hip_midRASISASIS-CoM_Pelvis;
OsteoArticularModel(incr_solid).wrap(1).h=0.35;

% Wrapping
OsteoArticularModel(incr_solid).wrap(2).name=['Wrap' 'L' 'Pelvis' 'GluteusMaximus'];
OsteoArticularModel(incr_solid).wrap(2).anat_position=['Wrap' 'L' 'Pelvis' 'GluteusMaximus'];
OsteoArticularModel(incr_solid).wrap(2).type='C'; % C: Cylinder or S: Sphere
OsteoArticularModel(incr_solid).wrap(2).R=0.0600;
OsteoArticularModel(incr_solid).wrap(2).orientation=[-0.999158540440827,0.0232314727333666,0.03380000;...
                                                     -0.0410147664159582,-0.565940670078522,-0.82340;...
                                                      0,-0.824118593787152,0.56640];
OsteoArticularModel(incr_solid).wrap(2).location=k*[-0.0201;	0.1060;	-0.0435]-Hip_midRASISASIS-CoM_Pelvis;
OsteoArticularModel(incr_solid).wrap(2).h=0.35;


end
