function out1 = GLASS1_Position(in1,in2,in3)
%GLASS1_POSITION
%    OUT1 = GLASS1_POSITION(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.1.
%    25-Oct-2018 19:15:56

R2cut1_1 = in3(10);
R2cut1_2 = in3(13);
R2cut1_3 = in3(16);
R2cut2_1 = in3(11);
R2cut2_2 = in3(14);
R2cut2_3 = in3(17);
R2cut3_1 = in3(12);
R2cut3_2 = in3(15);
R2cut3_3 = in3(18);
p2cut1 = in2(4);
p2cut2 = in2(5);
p2cut3 = in2(6);
q7 = in1(7,:);
q14 = in1(14,:);
q15 = in1(15,:);
q16 = in1(16,:);
t2 = cos(q7);
t3 = sin(q7);
t4 = cos(q15);
t5 = R2cut1_3.*t2;
t6 = R2cut1_1.*t3;
t7 = t5+t6;
t8 = sin(q15);
t9 = cos(q14);
t10 = R2cut1_2.*t9;
t11 = sin(q14);
t12 = R2cut1_1.*t2;
t16 = R2cut1_3.*t3;
t13 = t12-t16;
t17 = t11.*t13;
t14 = t10-t17;
t15 = t4.*t7-t8.*t14;
t18 = cos(q16);
t19 = sin(q16);
t20 = R2cut1_2.*t11;
t21 = t9.*t13;
t22 = t20+t21;
t23 = R2cut2_3.*t2;
t24 = R2cut2_1.*t3;
t25 = t23+t24;
t26 = t4.*t25;
t27 = R2cut2_2.*t9;
t28 = R2cut2_1.*t2;
t32 = R2cut2_3.*t3;
t29 = t28-t32;
t33 = t11.*t29;
t30 = t27-t33;
t31 = t26-t8.*t30;
t34 = R2cut2_2.*t11;
t35 = t9.*t29;
t36 = t34+t35;
t37 = R2cut3_3.*t2;
t38 = R2cut3_1.*t3;
t39 = t37+t38;
t40 = t4.*t39;
t41 = R2cut3_2.*t9;
t42 = R2cut3_1.*t2;
t46 = R2cut3_3.*t3;
t43 = t42-t46;
t47 = t11.*t43;
t44 = t41-t47;
t45 = t40-t8.*t44;
t48 = R2cut3_2.*t11;
t49 = t9.*t43;
t50 = t48+t49;
out1 = [R2cut1_2.*4.333799983468666e-1+p2cut1+R2cut1_1.*t2.*3.886816128671453e-3-R2cut1_3.*t3.*3.886816128671453e-3+t7.*t8.*8.413300590218077e-2+t4.*t14.*8.413300590218077e-2+t15.*t18.*9.201373121439876e-2-t15.*t19.*1.41094832636411e-1+t18.*t22.*1.41094832636411e-1+t19.*t22.*9.201373121439876e-2;R2cut2_2.*4.333799983468666e-1+p2cut2+R2cut2_1.*t2.*3.886816128671453e-3-R2cut2_3.*t3.*3.886816128671453e-3+t8.*t25.*8.413300590218077e-2+t4.*t30.*8.413300590218077e-2+t18.*t31.*9.201373121439876e-2-t19.*t31.*1.41094832636411e-1+t18.*t36.*1.41094832636411e-1+t19.*t36.*9.201373121439876e-2;R2cut3_2.*4.333799983468666e-1+p2cut3+R2cut3_1.*t2.*3.886816128671453e-3-R2cut3_3.*t3.*3.886816128671453e-3+t8.*t39.*8.413300590218077e-2+t4.*t44.*8.413300590218077e-2+t18.*t45.*9.201373121439876e-2-t19.*t45.*1.41094832636411e-1+t18.*t50.*1.41094832636411e-1+t19.*t50.*9.201373121439876e-2];
