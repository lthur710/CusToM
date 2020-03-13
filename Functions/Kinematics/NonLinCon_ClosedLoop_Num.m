function [c,ceq]=NonLinCon_ClosedLoop_Num(Human_model,solid_path1,solid_path2,num_solid,num_markers,q,k)
% Non-linear equation used in the inverse kinematics step for closed loops
%
%   INPUT
%  - Human_model: osteo-articular model (see the Documentation for the
%   structure)
%   - solid_path1 : vector of one of the two paths to close the loop
%   - solid_path2 : vector of the other of the two paths to close the loop
%   - num_solid : vector of the number of solid where the anatomical point must join the
%   origin of another joint to close the loo
%   - num_markers : vector of the position in the list "anat_position" that
%   corresponds to the point to close the loop
%   - q: vector of joint coordinates at a given instant
%   - k: vector of homothety coefficient

%   OUTPUT
%   - c: non-linar inequality
%   - ceq: non-linear equality
%________________________________________________________
%
% Licence
% Toolbox distributed under GPL 3.0 Licence
%________________________________________________________
%
% Authors : Antoine Muller, Charles Pontonnier, Pierre Puchaud and
% Georges Dumont
%________________________________________________________





c=[];
%ceq=sym('fccgd',[9*length(num_solid) 1]);
%ceq=zeros(9*length(num_solid),1);
%ceq=zeros(6*length(num_solid),1);
%ceq=zeros(7*length(num_solid),1);


for pp=1:numel(num_solid)
    if isempty(solid_path2{pp}) % if the beginning coincides with the end of the loop
        s = Human_model(num_solid(pp)).c + Human_model(num_solid(pp)).anat_position{num_markers(pp),2}; % position with respects to the position of the mother solid joint of the closed loop
        [Human_model,p_ClosedLoop,R_ClosedLoop] = ForwardKinematics_ClosedLoop(Human_model,1,s,solid_path1{pp},[0 0 0]',eye(3),q,k);
       Rtemp=R_ClosedLoop;
       %Rtemp=R_ClosedLoop -eye(3);
       ptemp=p_ClosedLoop;
%         
%         ceq(1+9*(pp-1))=Rtemp(1,1);
%         ceq(2+9*(pp-1))=Rtemp(2,2);
%         ceq(3+9*(pp-1))=Rtemp(3,3);
%         ceq(4+9*(pp-1))=Rtemp(1,2);
%         ceq(5+9*(pp-1))=Rtemp(1,3);
%         ceq(6+9*(pp-1))=Rtemp(2,3);
%         ceq(7+9*(pp-1))=ptemp(1);
%         ceq(8+9*(pp-1))=ptemp(2);
%         ceq(9+9*(pp-1))=ptemp(3);
        
        
        % Tait Bryan rotation - Cardan
%         ceq(1+6*(pp-1))=asin(Rtemp(1,3));
%         ceq(2+6*(pp-1))=atan(-Rtemp(2,3)/Rtemp(3,3));
%         ceq(3+6*(pp-1))=atan(-Rtemp(1,2)/Rtemp(1,1));
%         ceq(4+6*(pp-1))=ptemp(1);
%         ceq(5+6*(pp-1))=ptemp(2);
%         ceq(6+6*(pp-1))=ptemp(3);

    
%         % Quaternion
        r=1/2*sqrt(Rtemp(1,1)+Rtemp(2,2)+Rtemp(3,3));
        ceq(1+7*(pp-1))=r-1;
        ceq(2+7*(pp-1))=1/(4*r)*(Rtemp(3,2)-Rtemp(2,3));
        ceq(3+7*(pp-1))=1/(4*r)*(Rtemp(1,3)-Rtemp(3,1));
        ceq(4+7*(pp-1))=1/(4*r)*(Rtemp(2,1)-Rtemp(1,2));
        ceq(5+7*(pp-1))=ptemp(1); 
        ceq(6+7*(pp-1))=ptemp(2);
        ceq(7+7*(pp-1))=ptemp(3);

% %          %Idee du turfu
% 
%         ceq(1+6*(pp-1))=Rtemp(1,1)/norm(Rtemp(1,:))-1;
%         ceq(2+6*(pp-1))=Rtemp(2,2)/norm(Rtemp(2,:))-1;
%         ceq(3+6*(pp-1))=Rtemp(3,3)/norm(Rtemp(3,:))-1;
%         ceq(4+6*(pp-1))=ptemp(1);
%         ceq(5+6*(pp-1))=ptemp(2);
%         ceq(6+6*(pp-1))=ptemp(3);
%         

    else
        if isempty(solid_path1{pp}) % if the beginning coincides with the end of the loop
            s = Human_model(num_solid(pp)).c + Human_model(num_solid(pp)).anat_position{num_markers(pp),2}; % position with respects to the position of the mother solid joint of the closed loop
            [Human_model,p_ClosedLoop,R_ClosedLoop] = ForwardKinematics_ClosedLoop(Human_model,1,s,solid_path2{pp},[0 0 0]',eye(3),q,k);
            Rtemp=R_ClosedLoop;
     %      Rtemp=R_ClosedLoop -eye(3);
       ptemp=p_ClosedLoop;
            
%         ceq(1+9*(pp-1))=Rtemp(1,1);
%         ceq(2+9*(pp-1))=Rtemp(2,2);
%         ceq(3+9*(pp-1))=Rtemp(3,3);
%         ceq(4+9*(pp-1))=Rtemp(1,2);
%         ceq(5+9*(pp-1))=Rtemp(1,3);
%         ceq(6+9*(pp-1))=Rtemp(2,3);
%         ceq(7+9*(pp-1))=ptemp(1);
%         ceq(8+9*(pp-1))=ptemp(2);
%         ceq(9+9*(pp-1))=ptemp(3);
%         
%         
        
        % Tait Bryan rotation - Cardan
%         ceq(1+6*(pp-1))=asin(Rtemp(1,3));
%         ceq(2+6*(pp-1))=atan(-Rtemp(2,3)/Rtemp(3,3));
%         ceq(3+6*(pp-1))=atan(-Rtemp(1,2)/Rtemp(1,1));
%         ceq(4+6*(pp-1))=ptemp(1);
%         ceq(5+6*(pp-1))=ptemp(2);
%         ceq(6+6*(pp-1))=ptemp(3);

    
        % Quaternion
        r=1/2*sqrt(Rtemp(1,1)+Rtemp(2,2)+Rtemp(3,3));
        ceq(1+7*(pp-1))=r-1;
        ceq(2+7*(pp-1))=1/(4*r)*(Rtemp(3,2)-Rtemp(2,3));
        ceq(3+7*(pp-1))=1/(4*r)*(Rtemp(1,3)-Rtemp(3,1));
        ceq(4+7*(pp-1))=1/(4*r)*(Rtemp(2,1)-Rtemp(1,2));
        ceq(5+7*(pp-1))=ptemp(1); 
        ceq(6+7*(pp-1))=ptemp(2);
        ceq(7+7*(pp-1))=ptemp(3);



%          %Idee du turfu
% 
%         ceq(1+6*(pp-1))=Rtemp(1,1)/norm(Rtemp(1,:))-1;
%         ceq(2+6*(pp-1))=Rtemp(2,2)/norm(Rtemp(2,:))-1;
%         ceq(3+6*(pp-1))=Rtemp(3,3)/norm(Rtemp(3,:))-1;
%         ceq(4+6*(pp-1))=ptemp(1);
%         ceq(5+6*(pp-1))=ptemp(2);
%         ceq(6+6*(pp-1))=ptemp(3);
%         
        
        else% if the loop is cut elsewhere in the loop
            [Human_model,p_ClosedLoop1,R_ClosedLoop1] = ForwardKinematics_ClosedLoop(Human_model,1,[0 0 0],solid_path1{pp},[0 0 0]',eye(3),q,k);
            [Human_model,p_ClosedLoop2,R_ClosedLoop2] = ForwardKinematics_ClosedLoop(Human_model,1,[0 0 0],solid_path2{pp},[0 0 0]',eye(3),q,k);
            if ~isempty(intersect(solid_path1{pp},num_solid(pp))) % Finding the solid with the anatomical position to be respected
                p_ClosedLoop1 = p_ClosedLoop1 + R_ClosedLoop1*(Human_model(num_solid(pp)).c+Human_model(num_solid(pp)).anat_position{num_markers(pp),2});
            else
                p_ClosedLoop2= p_ClosedLoop2 + R_ClosedLoop2*(Human_model(num_solid(pp)).c+Human_model(num_solid(pp)).anat_position{num_markers(pp),2});
            end
            
            ptemp=p_ClosedLoop2-p_ClosedLoop1;
            Rtemp=R_ClosedLoop1*R_ClosedLoop2';
        %    Rtemp=R_ClosedLoop1*R_ClosedLoop2' -eye(3);
            
             
%         ceq(1+9*(pp-1))=Rtemp(1,1);
%         ceq(2+9*(pp-1))=Rtemp(2,2);
%         ceq(3+9*(pp-1))=Rtemp(3,3);
%         ceq(4+9*(pp-1))=Rtemp(1,2);
%         ceq(5+9*(pp-1))=Rtemp(1,3);
%         ceq(6+9*(pp-1))=Rtemp(2,3);
%         ceq(7+9*(pp-1))=ptemp(1);
%         ceq(8+9*(pp-1))=ptemp(2);
%         ceq(9+9*(pp-1))=ptemp(3);
        
        
        % Tait Bryan rotation - Cardan
%         ceq(1+6*(pp-1))=asin(Rtemp(1,3));
%         ceq(2+6*(pp-1))=atan(-Rtemp(2,3)/Rtemp(3,3));
%         ceq(3+6*(pp-1))=atan(-Rtemp(1,2)/Rtemp(1,1));
%         ceq(4+6*(pp-1))=ptemp(1);
%         ceq(5+6*(pp-1))=ptemp(2);
%         ceq(6+6*(pp-1))=ptemp(3);

    
        % Quaternion
        r=1/2*sqrt(Rtemp(1,1)+Rtemp(2,2)+Rtemp(3,3));
        ceq(1+7*(pp-1))=r-1;
        ceq(2+7*(pp-1))=1/(4*r)*(Rtemp(3,2)-Rtemp(2,3));
        ceq(3+7*(pp-1))=1/(4*r)*(Rtemp(1,3)-Rtemp(3,1));
        ceq(4+7*(pp-1))=1/(4*r)*(Rtemp(2,1)-Rtemp(1,2));
        ceq(5+7*(pp-1))=ptemp(1); 
        ceq(6+7*(pp-1))=ptemp(2);
        ceq(7+7*(pp-1))=ptemp(3);
        


%          %Idee du turfu

%         ceq(1+6*(pp-1))=Rtemp(1,1)/norm(Rtemp(1,:))-1;
%         ceq(2+6*(pp-1))=Rtemp(2,2)/norm(Rtemp(2,:))-1;
%         ceq(3+6*(pp-1))=Rtemp(3,3)/norm(Rtemp(3,:))-1;
%         ceq(4+6*(pp-1))=ptemp(1);
%         ceq(5+6*(pp-1))=ptemp(2);
%         ceq(6+6*(pp-1))=ptemp(3);
%         

        end
    end
end


end