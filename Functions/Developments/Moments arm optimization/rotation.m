function [Human_model] = rotation(Point1,Bone1,Human_model,q,joint_rotation,theta)
% Rotation of Point 1 of Bone1 around joint_rotation axis
%
%   INPUT
%   - Point1: position of the anatomical position of the first studied
%   point on its solid
%   - Bone1: number of the solid containing the first studied point
%   - Point2: position of the anatomical position of the second studied
%   point on its solid
%   - Bone2: number of the solid containing the second studied point
%   - Human_model: osteo-articular model (see the Documentation for the structure)
%   - q: vector of joint coordinates at a given instant
%   OUTPUT
%   - L: distance between the two studied points
%   - Typ: relative orientation of the two points (-1 ou 1)
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________

% finding the index of common antecedent (ppac:plus proche antecedent commun)

if Bone1>joint_rotation
[solid1,solid2] = find_solid_path(Human_model,Bone1,joint_rotation);
else
    [solid2,solid1] = find_solid_path(Human_model,joint_rotation,Bone1);
end
ppac=solid1(1);


% Direct kinematics initialization (Initialisation de la cin�matique directe)
Human_model(ppac).p = zeros(3,1);
Human_model(ppac).R = eye(3);

% Computation of coordinates of point A (calcul des coordonn�es du point A)
if numel(solid1)==1
    A = Human_model(Bone1).c+Human_model(Bone1).anat_position{Point1,2};
else
    for n=solid1(2:end)
        m = Human_model(n).mother;
        if Human_model(n).joint == 1
            Human_model(n).p = Human_model(m).R * Human_model(n).b + Human_model(m).p;
            Human_model(n).R = Human_model(m).R * Rodrigues(Human_model(n).a,q(n)) * Rodrigues(Human_model(n).u,Human_model(n).theta);
        end
        if Human_model(n).joint == 2
            Human_model(n).p = Human_model(m).R * Human_model(n).b + Human_model(m).p+ q(n)*Human_model(n).a;
            Human_model(n).R = Human_model(m).R  * Rodrigues(Human_model(n).u,Human_model(n).theta);
        end
    end
    l = solid1(end);
    Human_model(l).c_global = Human_model(l).p + Human_model(l).R * Human_model(l).c;
    A = Human_model(l).c_global + Human_model(l).R * Human_model(Bone1).anat_position{Point1,2};
end



for n=solid2(2:end)
    m = Human_model(n).mother;        
        if Human_model(n).joint == 1
            Human_model(n).p = Human_model(m).R * Human_model(n).b + Human_model(m).p;
            Human_model(n).R = Human_model(m).R * Rodrigues(Human_model(n).a,q(n)) * Rodrigues(Human_model(n).u,Human_model(n).theta);
        end
        if Human_model(n).joint == 2
            Human_model(n).p = Human_model(m).R * Human_model(n).b + Human_model(m).p+ q(n)*Human_model(n).a;
            Human_model(n).R = Human_model(m).R * Rodrigues(Human_model(n).u,Human_model(n).theta);
        end
end


u = Human_model(joint_rotation).R*Human_model(joint_rotation).a;


A_rotation_by_u=Rodrigues(u,theta)*(A - Human_model(joint_rotation).p) + Human_model(joint_rotation).p ;  
l = Bone1;
Human_model(l).anat_position{Point1,2}=(Human_model(l).R)'*(A_rotation_by_u -Human_model(l).p)-  Human_model(l).c;

end