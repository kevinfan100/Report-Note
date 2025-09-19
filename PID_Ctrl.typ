= PID Control Implementation Record

== 1. Variable Operations Record 

=== Low-Pass Filter Coefficient Calculation

*case 5'd21:*

  `TwoTau = 2 * iHsVd_LPF_tau`

  `TwoTau_A_T = TwoTau + iHsCtrl_SplIntv`

  `TwoTau_S_T = TwoTau - iHsCtrl_SplIntv`

  `HsVd_Coeff = iHsCtrl_SplIntv / TwoTau_A_T`

*case 5'd29:*

  `HsVd_LPF_Coeff1 = TwoTau_S_T / TwoTau_A_T`

=== Low-Pass Filter Operations

*case 9'd21:*

  `HsVd_Coeff_M_HsVd_VECT6_0 = iHsVd_VECT6[0] * HsVd_Coeff`

  `HsVd_Coeff_M_HsVd1_VECT6_0 = HsVd1_VECT6[0] * HsVd_Coeff`

*case 9'd22:*

  `HsVd_LPF_Coeff1_M_HsVd1_LPF_VECT6_0 = HsVd1_LPF_VECT6[0] * HsVd_LPF_Coeff1`

*case 9'd35:*

  `HsVd_ForLPF_Sum_VECT6_0 = HsVd_Coeff_M_HsVd_VECT6_0 + HsVd_Coeff_M_HsVd1_VECT6_0`

  `HsVd_LPF_VECT6_0 = HsVd_ForLPF_Sum_VECT6_0 + HsVd_LPF_Coeff1_M_HsVd1_LPF_VECT6_0`

=== PID Coefficient Calculation

*case 5'd0:*

  `HsIgain_M_SplIntvO2_VECT6[0] = iHsIgain_VECT6[0] * iHsCtrl_SplIntvO2`

  `HsDgain_D_SplIntvO2_VECT6[0] = iHsDgain_VECT6[0] / iHsCtrl_SplIntvO2`

  `HsIgain_M_SplIntv_VECT6[0] = iHsIgain_VECT6[0] * iHsCtrl_SplIntv`

*case 5'd7:*

  `Intm_Coeff_VECT6[0] = HsDgain_D_SplIntvO2_VECT6[0] + HsIgain_M_SplIntvO2_VECT6[0]`

*case 5'd13:*

  `FourHsDgain_D_SplIntv_VECT6[0] = 2 * HsDgain_D_SplIntvO2_VECT6[0]`

*case 5'd15:*

  `oHsCoeff_VECT6[0] = Intm_Coeff_VECT6[0] + iHsPgain_VECT6[0]`

  `oHsCoeff1_VECT6[0] = Intm_Coeff_VECT6[0] - iHsPgain_VECT6[0]`

*case 5'd27:*

  `oHsCoeff2_VECT6[0] = HsIgain_M_SplIntv_VECT6[0] - FourHsDgain_D_SplIntv_VECT6[0]`

=== Error Calculation

*case 9'd56:*

  `oHsVerr_VECT6[0] = HsVd_LPF_VECT6[0] - iHsVm_VECT6[0]`

*case 9'd63:*

  `oHsVctrlFF_VECT6[0] = HsVd_LPF_VECT6[0] / iHsFFgain_VECT6[0]`

=== PID Control Calculation

*case 9'd64:*

  `HsVerr_M_HsCoeff_VECT6[0] = oHsVerr_VECT6[0] * oHsCoeff_VECT6[0]`

*case 9'd70:*

  `HsVerrHsCoeff_A_HsVctrl2_VECT6[0] = HsVerr_M_HsCoeff_VECT6[0] + HsVctrlCompl_2_VECT6[0]`

*case 9'd76:*

  `HsVerr1_M_HsCoeff1_VECT6[0] = HsVerr1_VECT6[0] * oHsCoeff1_VECT6[0]`

*case 9'd82:*

  `HsVerr2_M_HsCoeff2_VECT6[0] = HsVerr2_VECT6[0] * oHsCoeff2_VECT6[0]`

*case 9'd90:*

  `HsVerr1HsCoeff1_A_HsVerr2HsCoeff2_VECT6[0] = HsVerr2_M_HsCoeff2_VECT6[0] + HsVerr1_M_HsCoeff1_VECT6[0]`

*case 9'd98:*

  `oHsVctrlCompl_VECT6[0] = HsVerr1HsCoeff1_A_HsVerr2HsCoeff2_VECT6[0] + HsVerrHsCoeff_A_HsVctrl2_VECT6[0]`

  `oHsVctrlTot_VECT6[0] = oHsVctrlCompl_VECT6[0] + oHsVctrlFF_VECT6[0]`

== 2. Difference Equation Derivation

=== Low-Pass Filter Difference Equation

$V d_(L P F)[n] = (T) / (2 tau + T) dot (V d[n] + V d[n - 1]) + (2 tau - T) / (2 tau + T) dot V d_(L P F)[n - 1]$

Where:
- $T$ = iHsCtrl_SplIntv (Sampling period)
- $tau$ = iHsVd_LPF_tau (Filter time constant)
- HsVd_Coeff = $T \/ (2 tau + T)$
- HsVd_LPF_Coeff1 = $(2 tau - T) \/ (2 tau + T)$

=== PID Control Difference Equation

$e[n] = V d_(L P F)[n] - V m[n]$

$u_(P I D)[n] = (K_p + K_i dot T \/ 2 + K_d \/ (T \/ 2)) dot e[n]$
$space space space space space space space space space + (K_i dot T \/ 2 + K_d \/ (T \/ 2) - K_p) dot e[n - 1]$
$space space space space space space space space space + (K_i dot T - 4 dot K_d \/ T) dot e[n - 2]$
$space space space space space space space space space + u[n - 2]$

Where:
- $K_p$ = iHsPgain_VECT6[0] (Proportional gain)
- $K_i$ = iHsIgain_VECT6[0] (Integral gain)
- $K_d$ = iHsDgain_VECT6[0] (Derivative gain)
- $T$ = iHsCtrl_SplIntv (Sampling period)

Coefficient Mapping:
- oHsCoeff_VECT6[0] = $K_p + K_i dot T \/ 2 + K_d \/ (T \/ 2)$
- oHsCoeff1_VECT6[0] = $K_i dot T \/ 2 + K_d \/ (T \/ 2) - K_p$
- oHsCoeff2_VECT6[0] = $K_i dot T - 4 dot K_d \/ T$

=== Total Control Output

$u_(t o t a l)[n] = u_(P I D)[n] + u_(F F)[n]$

Where:
- $u_(F F)[n] = V d_(L P F)[n] \/ F F g a i n$ (Feedforward control)
- FFgain = iHsFFgain_VECT6[0]

=== Timing Marks

*case 5'd0 → case 5'd10:* PID coefficient calculation completed

*case 5'd21 → case 5'd29:* Low-Pass Filter coefficient calculation completed

*case 9'd56 → case 9'd98:* PID control operation completed, output oHsVctrlTot_VECT6[0]