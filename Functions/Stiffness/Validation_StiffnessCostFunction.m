clear all
cmap=colormap(colorcube(33));
set(groot, 'DefaultAxesColorOrder', cmap,'DefaultAxesFontSize',10,'DefaultLineLineWidth',2,'DefaultLegendLocation','northeastoutside');
set(gcf,'PaperUnits', 'inches','PaperSize', [8 2]);
load('BiomechanicalModel');
load('AnalysisParameters')
% filename='THI_trajectoire0008';
% load([filename '/InverseDynamicsResults']);
% torques =InverseDynamicsResults.JointTorques;
% Muscles = BiomechanicalModel.Muscles;
% idm = logical([Muscles.exist]);
% Nb_muscles=numel(Muscles(idm));
alpha_l=0:0.1:1;
% A_avg=zeros(Nb_muscles,numel(alpha_l));
i=1;
extensor=[13, 12, 11, 7];
time=(1:2000)/200;
for alpha=alpha_l
    %     AnalysisParameters.StiffnessPercent=alpha;
    %     MuscleForcesComputationResults=ForcesComputationOptiNum(filename,BiomechanicalModel, AnalysisParameters);
    %     save(['MuscleForcesComputationResults_', num2str(alpha),'.mat'], 'MuscleForcesComputationResults')
    load(['MuscleForcesComputationResults_', num2str(alpha),'.mat']);
    A=MuscleForcesComputationResults.MuscleActivations;
    Muscles_negligeable=[];
    for k=1:33
        if mean(A(k,:))<0.1 || isempty(intersect(extensor,k))
            Muscles_negligeable=[Muscles_negligeable k];
        end
    end
    Muscles_import=setdiff(1:33,Muscles_negligeable);
    Muscles_import=setdiff(Muscles_import,extensor);
figure('units','normalized','outerposition',[0 0 0.7 0.7]);
    plot(time,A(extensor,:),'*');
%     plot(time,A(Muscles_import,:));
    title(['alpha=',num2str(alpha)]);
%     saveas(gcf,['A_ext',num2str(alpha),'.png'])
figure('units','normalized','outerposition',[0 0 0.7 0.7]);
    plot(time,A(Muscles_negligeable,:)');
    title(['alpha=',num2str(alpha)]);
%     saveas(gcf,['A_neg',num2str(alpha),'.png'])
    A_avg(:,i) = mean(A(extensor,:),2);
    A_avg_neg(:,i) = mean(A(Muscles_negligeable,:),2);
    i=i+1;
end
figure('units','normalized','outerposition',[0 0 0.7 0.7])
hold on
grid on
plot(0:0.1:1,A_avg)
xlabel('Pourcentage de raideur','FontSize',16);
ylabel('Moyenne temporelle des activations','FontSize',16);
% saveas(gcf,'A_avg_alpha_ext.png')
figure('units','normalized','outerposition',[0 0 0.7 0.7])
plot(0:0.1:1,A_avg_neg)
xlabel('Pourcentage de raideur','FontSize',16);
ylabel('Moyenne temporelle des activations','FontSize',16);
% saveas(gcf,'A_avg_alpha_neg.png')