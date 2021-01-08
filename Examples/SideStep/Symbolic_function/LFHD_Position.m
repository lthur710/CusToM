function out1 = LFHD_Position(in1,in2,in3)
%LFHD_POSITION
%    OUT1 = LFHD_POSITION(IN1,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.4.
%    25-Nov-2020 09:54:23

R4cut1_1 = in3(28);
R4cut1_2 = in3(31);
R4cut1_3 = in3(34);
R4cut2_1 = in3(29);
R4cut2_2 = in3(32);
R4cut2_3 = in3(35);
R4cut3_1 = in3(30);
R4cut3_2 = in3(33);
R4cut3_3 = in3(36);
p4cut1 = in2(10);
p4cut2 = in2(11);
p4cut3 = in2(12);
q7 = in1(7,:);
q20 = in1(20,:);
q21 = in1(21,:);
q22 = in1(22,:);
t2 = cos(q7);
t3 = cos(q20);
t4 = cos(q21);
t5 = cos(q22);
t6 = sin(q7);
t7 = sin(q20);
t8 = sin(q21);
t9 = sin(q22);
t10 = R4cut1_1.*t2;
t11 = R4cut1_3.*t2;
t12 = R4cut2_1.*t2;
t13 = R4cut2_3.*t2;
t14 = R4cut1_2.*t3;
t15 = R4cut3_1.*t2;
t16 = R4cut3_3.*t2;
t17 = R4cut2_2.*t3;
t18 = R4cut3_2.*t3;
t19 = R4cut1_1.*t6;
t20 = R4cut1_3.*t6;
t21 = R4cut2_1.*t6;
t22 = R4cut2_3.*t6;
t23 = R4cut1_2.*t7;
t24 = R4cut3_1.*t6;
t25 = R4cut3_3.*t6;
t26 = R4cut2_2.*t7;
t27 = R4cut3_2.*t7;
t28 = -t20;
t29 = -t22;
t30 = -t25;
t31 = t11+t19;
t32 = t13+t21;
t33 = t16+t24;
t34 = t10+t28;
t35 = t12+t29;
t36 = t15+t30;
t37 = t4.*t31;
t38 = t4.*t32;
t39 = t4.*t33;
t40 = t3.*t34;
t41 = t3.*t35;
t42 = t3.*t36;
t43 = t7.*t34;
t44 = t7.*t35;
t45 = t7.*t36;
t46 = -t43;
t47 = -t44;
t48 = -t45;
t49 = t23+t40;
t50 = t26+t41;
t51 = t27+t42;
t52 = t14+t46;
t53 = t17+t47;
t54 = t18+t48;
t55 = t8.*t52;
t56 = t8.*t53;
t57 = t8.*t54;
t58 = -t55;
t59 = -t56;
t60 = -t57;
t61 = t37+t58;
t62 = t38+t59;
t63 = t39+t60;
out1 = [R4cut1_2.*4.212222222222222e-1+p4cut1+t10.*3.777777777777778e-3-t20.*3.777777777777778e-3+t8.*t31.*8.972222222222222e-2+t5.*t49.*(1.7e+1./2.0e+2)+t4.*t52.*8.972222222222222e-2-t9.*t49.*6.138888888888889e-2-t5.*t61.*6.138888888888889e-2-t9.*t61.*(1.7e+1./2.0e+2);R4cut2_2.*4.212222222222222e-1+p4cut2+t12.*3.777777777777778e-3-t22.*3.777777777777778e-3+t8.*t32.*8.972222222222222e-2+t5.*t50.*(1.7e+1./2.0e+2)+t4.*t53.*8.972222222222222e-2-t9.*t50.*6.138888888888889e-2-t5.*t62.*6.138888888888889e-2-t9.*t62.*(1.7e+1./2.0e+2);R4cut3_2.*4.212222222222222e-1+p4cut3+t15.*3.777777777777778e-3-t25.*3.777777777777778e-3+t8.*t33.*8.972222222222222e-2+t5.*t51.*(1.7e+1./2.0e+2)+t4.*t54.*8.972222222222222e-2-t9.*t51.*6.138888888888889e-2-t5.*t63.*6.138888888888889e-2-t9.*t63.*(1.7e+1./2.0e+2)];
