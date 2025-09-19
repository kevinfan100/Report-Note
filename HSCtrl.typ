

#set document(
  title: "HallSensor_VoltCtrl Controller Implementation Analysis",
  author: "FPGA Code Analysis",
  date: datetime.today()
)

#set text(
  font: ("Times New Roman"),
  size: 15pt,
  weight: "bold",
  lang: "en"
)

#set page(
  paper: "a4",
  margin: (left: 20mm, right: 20mm, top: 25mm, bottom: 25mm),
  numbering: "1",
  number-align: center
)

#set par(justify: true, leading: 1em)

// Simple custom styles
#let code-box = block.with(
  fill: luma(94.9%, 18.5%),
  inset: 12pt,
  radius: 3pt,
  width: 100%
)

#let math-box = block.with(
  fill: rgb(250, 250, 250),
  inset: 12pt,
  radius: 4pt,
  stroke: (left: 1pt + gray)
)

#let highlight-box = block.with(
  fill: rgb(255, 251, 230),
  inset: 8pt,
  radius: 3pt,
  stroke: (left: 3pt + orange)
)









Clock 0-5:
```
S_k1[i] = HsVd2_VECT6[i] - iHsVm_VECT6[i]  
a1_m_Vd_d1[i] = iAnew[0] × HsVd1_VECT6[i]  
a2_m_Vd_d2[i] = iAnew[1] × HsVd2_VECT6[i]  
lamc_M_S1_k1_esti[i] = S1_k1_esti[i] × ilambda  
```

Clock 9-14: 
```
Output_diff[i] = S_k1[i] - S1_k1_esti[i] 
```

Clock 15-23:
```
Vd_s_a1Vd1[i] = iHsVd_VECT6[i] - a1_m_Vd_d1[i]
Vd_s_a1Vd1_s_a2Vd2[i] = Vd_s_a1Vd1[i] - a2_m_Vd_d2[i]

mVolt_6x1_3 = Output_diff           
mTransf_MAT6x6_3 = i_A1matrix_s_lambda  

mVolt_6x1_2 = Output_diff            
mTransf_MAT6x6_2 = i_L2_esti        
```

Clock 18-23:

```
S1_esti_correct[i] = L1 × Output_diff[i]  // L1 = iAnew[2]
```

Clock 24-32:
```
S2_esti_correct[i] = L2 × Output_diff[i]  // L2 = iAnew[3]
```

Clock 25-30:
```
S1_esti[i] = lamc_M_S1_k1_esti[i] + S1_esti_correct[i]
```

Clock 34-39:
```
S2_esti[i] = S1_k1_esti[i] + S2_esti_correct[i]
a1lamc_m_S1_esti[i] = a1_s_lamc × S1_esti[i]  // a1_s_lamc = iAnew[4]
```

Clock 41-46:
```
Vd_s_a1Vd_s_a2Vd2_p_a1lamc_m_S1_esti[i] = 
    Vd_s_a1Vd1_s_a2Vd2[i] + a1lamc_m_S1_esti[i]
a2_m_S2_esti[i] = iAnew[1] × S2_esti[i]
```



Clock 49-54:
```
u_before_Binv[i] = Vd_s_a1Vd_s_a2Vd2_p_a1lamc_m_S1_esti[i] + a2_m_S2_esti[i]
```

Clock 56-67:
```
one_p_Betam_m_westi_d1[i] = one_p_Betam × westi_d1[i]

Betam_m_w2esti_d1[i] = iBeta_m × w2esti_d1[i]

w1_before_correct[i] = westi_d1[i] + w2esti_d1[i]
```



Clock 64:
```
mVolt_6x1_4 = u_before_Binv      
mTransf_MAT6x6_4 = i_inv_B       // B⁻¹

```

Clock 92-93
```
w_correct = Rst_6x6_6x1_3        
w2_correct = Rst_6x6_6x1_2       
```

Clock 101-118:
```
westi[i] = w1_before_correct[i] + w_correct[i]
 
w2esti[i] = w2esti_d1[i] + w2_correct[i]
```

Clock 133:
```
u_before_w = Rst_6x6_6x1_4  
```

Clock 134-147:
```

  u_total_new[i] = u_before_w[i] - westi[i]  

```

#pagebreak()
```

westi_d1[i] ≤= westi[i]           
w2esti_d1[i] ≤= w2esti[i]         
S1_k1_esti[i] ≤= S1_esti[i]       
S2_k1_esti[i] ≤= S2_esti[i]        
HsVd2_VECT6[i] ≤= HsVd1_VECT6[i]  
HsVd1_VECT6[i] ≤= iHsVd_VECT6[i]  
```
#pagebreak()

= FPGA控制器核心數學運算表達式

== 1. 基本控制變數定義

*狀態變數:*
- $S_k$: 追蹤誤差 (tracking error)
- $S_1^"esti"$: 狀態估測器輸出
- $S_2^"esti"$: 延遲狀態估測器
- $w^"esti"$: 擾動估測
- $w_2^"esti"$: 二階擾動估測

== 2. 主要控制律運算

*Step 1: 追蹤誤差計算*
$ S_k = V_d - V_m $

*Step 2: 前饋控制*
$ V_"ff" = V_d - a_1 × V_(d-1) - a_2 × V_(d-2) $

*Step 3: 狀態估測誤差*
$ e = S_k - S_1^("esti"_(k-1)) $

*Step 4: 估測器更新*
$ S_1^"esti" = lambda_c × S_1^("esti"_(k-1)) + L_1 × e $

$ S_2^"esti" = S_1^("esti"_(k-1)) + L_2 × e $

*Step 5: 回饋控制*
$ u_"fb" = (a_1 - lambda_c) × S_1^"esti" + a_2 × S_2^"esti" $

*Step 6: 控制輸入(未解耦)*
$ u_"before" = V_"ff" + u_"fb" $

*Step 7: 矩陣解耦*
$ u_"decoupled" = B^(-1) × u_"before" $

*Step 8: 擾動補償*
$ u_"final" = u_"decoupled" - w^"esti" $

== 3. 擾動估測器運算

*擾動估測更新:*
$ w_1^"before" = w^("esti"_(k-1)) + w_2^("esti"_(k-1)) $

$ w^"correct" = ("A1matrix_s_lambda") × e $

$ w_2^"correct" = ("L2_esti") × e $

$ w^"esti" = w_1^"before" + w^"correct" $

$ w_2^"esti" = w_2^("esti"_(k-1)) + w_2^"correct" $

*增強版本 (with β_m):*
$ w_1^"before" = (1 + beta_m) × w^("esti"_(k-1)) + beta_m × w_2^("esti"_(k-1)) $

== 4. 關鍵系統參數

*固定參數:*
- $a_1 = 1.595052025060797$ (來自系統極點 $p_1$)
- $a_2 = -0.599079946700523$ (來自系統極點 $p_2$)
- $lambda_c = 0.9391$ (控制頻寬 1000 Hz)
- $lambda_w = 0.7304$ (估測器頻寬 5000 Hz)
- $beta_m$: 模型參數 (可調)

== 5. 估測器增益計算

*Augmented Version (當前活躍版本):*

$ L_1 = -(-beta + (1 + beta)^2 - 4(1 + beta)lambda_w + 6lambda_w^2 - lambda_w^4/beta) $

$ L_2 = -(1 + beta - 4lambda_w - (1 + beta)lambda_w^4/beta^2 + 4lambda_w^3/beta) $

$ L_3 = "tune_L3" $ (來自 ThreeD_sine_theta)

*iAnew參數映射:*
- `iAnew[0]` = $a_1$ = 1.595052025060797
- `iAnew[1]` = $a_2$ = -0.599079946700523
- `iAnew[2]` = $L_1$ (單一增益值)
- `iAnew[3]` = $L_2$ (單一增益值)
- `iAnew[4]` = $a_1 - lambda_c$

== 6. 矩陣運算

*解耦矩陣 B^(-1):*
$ B^(-1) = mat(
  1254.4, 365.9, 362.7, 509.3, 510.7, 478.1;
  354.7, 1162.4, 387.9, 669.9, 692.5, 448.6;
  427.5, 453.9, 1258.9, 439.3, 488.0, 520.8;
  442.5, 654.6, 353.8, 1460.7, 800.5, 448.8;
  414.2, 572.5, 337.4, 687.5, 1274.4, 374.7;
  412.2, 400.9, 368.5, 474.4, 407.4, 1371.6
) × L_3 $

*擾動估測矩陣:*
$ "A1matrix_s_lambda" = B^(-1) × L_1 $

$ "L2_esti" = B^(-1) × L_2 $

== 7. 完整控制輸入計算流程 (Control Effort Computation)

*Step 1: 追蹤誤差計算*
$ delta bold(v) lr([k]) = bold(v)_d lr([k]) - bold(v)_m lr([k]) $

*Step 2: 前饋控制項 (Feedforward)*
$ bold(v)_"ff" lr([k]) = bold(v)_d lr([k+1]) - a_1 bold(v)_d lr([k]) - a_2 bold(v)_d lr([k-1]) $

*Step 3: 估測追蹤誤差 (使用增強狀態估測器)*
$ hat(delta bold(v)) lr([k]) = hat(bold(s))_1 lr([k]) $

*Step 4: 回饋控制項 (Feedback)*
$ delta bold(v)_"fb" lr([k]) = (a_1 - lambda_c)hat(delta bold(v)) lr([k]) + a_2 hat(delta bold(v)) lr([k-1]) $

*Step 5: 總控制輸入 (未解耦)*
$ bold(v)_"total" lr([k]) = bold(v)_"ff" lr([k]) + delta bold(v)_"fb" lr([k]) $

*Step 6: 矩陣解耦與擾動補償*
$ bold(u) lr([k]) = bold(B)^(-1) bold(v)_"total" lr([k]) - hat(bold(w)) lr([k]) $

其中 $bold(B)^(-1)$ 為預先計算的解耦矩陣，$hat(bold(w)) lr([k])$ 來自擾動估測器

*Step 7: 最終控制輸出 (Control Effort)*
$ bold(u)_"final" lr([k]) = bold(B)^(-1) lr([bold(v)_d lr([k+1]) - a_1 bold(v)_d lr([k]) - a_2 bold(v)_d lr([k-1]) + (a_1 - lambda_c)hat(delta bold(v)) lr([k]) + a_2 hat(delta bold(v)) lr([k-1])]) - hat(bold(w)) lr([k]) $

此控制輸入將產生磁通：
$ bold(phi) lr([k]) = bold(B) bold(u)_"final" lr([k]) $

進而產生磁力：
$ bold(f)_m = g_phi bold(phi)^T bold(L)(bold(p)) bold(phi) $

#pagebreak()


=== **iAnew**
#code-box[
```c
Anew[0][0] = A1matrix[0][0] = 1.595052025060797
Anew[0][1] = A2matrix[0][0]=-0.599079946700523;
Anew[0][2] = 1 + beta_model + A1matrix[0][0] - 4 * lambda_w;
Anew[0][3] = lambda_w*lambda_w*lambda_w*lambda_w / (A2matrix[0][0] * beta_model) + 1;
Anew[0][4] = A1matrix[0][0] - lambda_inner;
```
]

#code-box[
```c
// Augmented version (currently active in PT3DView.cpp line 3330-3331)
tune_L1 = -(-beta_model + (1 + beta_model)*(1 + beta_model) 
          - 4 * (1 + beta_model)*lambda_w + 6 * lambda_w*lambda_w 
          - lambda_w*lambda_w*lambda_w*lambda_w / beta_model); 

tune_L2 = -( 1 + beta_model - 4 * lambda_w 
          - (1 + beta_model)*lambda_w*lambda_w*lambda_w*lambda_w 
            / (beta_model*beta_model) 
          + 4 * lambda_w*lambda_w*lambda_w / beta_model); 

tune_L3 = pdlg6->ThreeD_sine_theta;
```
]

#math-box[
*Augmented Version (活躍版本):*

$ "tune"_"L1" = -(-beta + (1 + beta)^2 - 4(1 + beta)lambda + 6lambda^2 - lambda^4/beta) $


$ "tune"_"L2" = -(1 + beta - 4lambda - (1 + beta)lambda^4/beta^2 + 4lambda^3/beta) $


$ "tune"_"L3" = "ThreeD_sine_theta" $

其中：$beta = "beta_model"$, $lambda = "lambda_w"$
]
#pagebreak()
#highlight-box[
*其他版本 (已註解):*
```c
// Simple version (PT3DView.cpp line 3321-3322, 3324-3325)
tune_L1 = 2 * lambda_w - 1 - beta_model;
tune_L2 = lambda_w*lambda_w / beta_model - 1;

// Polynomial version (PT3DView.cpp line 3332-3333)  
tune_L1 = (lambda_w - 1)*(lambda_w - 1)*(lambda_w - 1)*(lambda_w + 3);
tune_L2 = -(lambda_w - 1)*(lambda_w - 1)*(lambda_w - 1)*(lambda_w - 1);

// M-delay version (PT3DView.cpp line 3326-3327)
tune_L1 = ((2*lambda_w - (1+beta_model))*((1+beta_model)*(A1matrix[0][0]-lambda_inner) + beta_model) 
          - (lambda_w*lambda_w - beta_model)*(A1matrix[0][0]-lambda_inner)) 
          / ((1+beta_model)*(A1matrix[0][0]-lambda_inner) + beta_model 
          + (A1matrix[0][0]-lambda_inner)*(A1matrix[0][0]-lambda_inner));
          
tune_L2 = ((2*lambda_w - (1+beta_model))*(A1matrix[0][0]-lambda_inner) 
          + (lambda_w*lambda_w - beta_model)) 
          / ((1+beta_model)*(A1matrix[0][0]-lambda_inner) + beta_model 
          + (A1matrix[0][0]-lambda_inner)*(A1matrix[0][0]-lambda_inner));
```
]


#pagebreak()

=== **inv_B**

#code-box[
```c

inv_B = [
  [1254.4,  365.9,  362.7,  509.3,  510.7,  478.1],
  [ 354.7, 1162.4,  387.9,  669.9,  692.5,  448.6],
  [ 427.5,  453.9, 1258.9,  439.3,  488.0,  520.8],
  [ 442.5,  654.6,  353.8, 1460.7,  800.5,  448.8],
  [ 414.2,  572.5,  337.4,  687.5, 1274.4,  374.7],
  [ 412.2,  400.9,  368.5,  474.4,  407.4, 1371.6]
 * tune_L3;


```
]



=== **A1matrix_s_lambda **

#code-box[
```c
A1matrix_s_lambda = [
  [1254.4,  365.9,  362.7,  509.3,  510.7,  478.1],
  [ 354.7, 1162.4,  387.9,  669.9,  692.5,  448.6],
  [ 427.5,  453.9, 1258.9,  439.3,  488.0,  520.8],
  [ 442.5,  654.6,  353.8, 1460.7,  800.5,  448.8],
  [ 414.2,  572.5,  337.4,  687.5, 1274.4,  374.7],
  [ 412.2,  400.9,  368.5,  474.4,  407.4, 1371.6]
] * tune_L1 * tune_L3;
```
]

=== **L2_esti **

#code-box[
```c
L2_esti = [
  [1254.4,  365.9,  362.7,  509.3,  510.7,  478.1],
  [ 354.7, 1162.4,  387.9,  669.9,  692.5,  448.6],
  [ 427.5,  453.9, 1258.9,  439.3,  488.0,  520.8],
  [ 442.5,  654.6,  353.8, 1460.7,  800.5,  448.8],
  [ 414.2,  572.5,  337.4,  687.5, 1274.4,  374.7],
  [ 412.2,  400.9,  368.5,  474.4,  407.4, 1371.6]
] * tune_L2 * tune_L3;
```
]

#pagebreak()

= 論文理論算法數學表達式總結

== 1. 六輸入六輸出磁通控制系統 (Six-Input-Six-Output Magnetic Flux Control)

*系統離散模型 (方程式6):*
$ bold(v)_m lr([k+1]) = a_1 bold(v)_m lr([k]) + a_2 bold(v)_m lr([k-1]) + bold(B){bold(u) lr([k]) + bold(w) lr([k])} $

其中：
- $bold(v)_m$: 6×1 Hall sensor電壓向量
- $bold(u)$: 6×1 控制輸入向量  
- $bold(w)$: 6×1 擾動向量
- $a_1 = 0.9898$, $a_2 = 0.6053$ (系統極點)
- $bold(B)$: 6×6 輸入矩陣

== 2. 控制律設計 (方程式7)

*控制目標:* $delta bold(v) lr([k+1]) = lambda_c delta bold(v) lr([k])$, 其中 $0 ≤ lambda_c < 1$

*控制律:*
$ bold(u) lr([k]) = bold(B)^(-1) lr({bold(v)_"ff" lr([k]) + delta bold(v)_"fb" lr([k])}) - hat(bold(w)) lr([k]) $

*前饋控制:*
$ bold(v)_"ff" lr([k]) = bold(v)_d lr([k+1]) - a_1 bold(v)_d lr([k]) - a_2 bold(v)_d lr([k-1]) $

*回饋控制:*  
$ delta bold(v)_"fb" lr([k]) = (a_1 - lambda_c)hat(delta bold(v)) lr([k]) + a_2 hat(delta bold(v)) lr([k-1]) $

== 3. 追蹤誤差動態 (方程式8)

$ delta bold(v) lr([k+1]) = lambda_c delta bold(v) lr([k]) - bold(B)bold(e)_w lr([k]) + (a_1 - lambda_c)bold(e)_("delta v") lr([k]) + a_2 bold(e)_("delta v") lr([k-1]) $

其中：
- $bold(e)_w = bold(w) - hat(bold(w))$: 擾動估測誤差
- $bold(e)_("delta v") = delta bold(v) - hat(delta bold(v))$: 狀態估測誤差

== 4. 增強狀態估測器 (方程式9)

$ hat(bold(s))_1 lr([k+1]) = lambda_c hat(bold(s))_1 lr([k]) + bold(L)_1{delta bold(v) lr([k]) - hat(bold(s))_1 lr([k])} $

$ hat(bold(s))_2 lr([k+1]) = hat(bold(s))_1 lr([k]) + bold(L)_2{delta bold(v) lr([k]) - hat(bold(s))_1 lr([k])} $

$ hat(bold(w)) lr([k+1]) = hat(bold(w)) lr([k]) + delta hat(bold(w)) lr([k]) + bold(L)_3{delta bold(v) lr([k]) - hat(bold(s))_1 lr([k])} $

$ delta hat(bold(w)) lr([k+1]) = delta hat(bold(w)) lr([k]) + bold(L)_4{delta bold(v) lr([k]) - hat(bold(s))_1 lr([k])} $

== 5. 估測器回饋矩陣 (方程式11)

$ bold(L)_1 = (2 + a_1 - 4lambda_e)bold(I) $

$ bold(L)_2 = (1 + lambda_e^4/a_2)bold(I) $

$ bold(L)_3 = -(1 - lambda_e)^3(3 + lambda_e)bold(B)^(-1) $

$ bold(L)_4 = -(1 - lambda_e)^4 bold(B)^(-1) $

== 6. 最優磁通分配 (Optimal Flux Allocation)

*Hall sensor磁力模型 (方程式3):*
$ bold(f)_m(bold(p), bold(v)_H) = g_H bold(v)_H^T hat(bold(D))_H^T bold(L)(bold(p)/ell)hat(bold(D))_H bold(v)_H $

*最優電壓分配 (方程式5):*
$ bold(v)_("opt")(bold(f)_d, bold(p)) = sqrt(f_d/g_H) hat(bold(D))_H^(-1) hat(bold(phi))_("opt")(phi, theta, bold(p)) $

== 7. 關鍵系統參數

*控制器參數:*
- $lambda_c = 0.9391$ → 控制頻寬 1000 Hz
- $lambda_e = 0.7304$ → 估測器頻寬 5000 Hz  
- 採樣頻率: 100 kHz (採樣週期 10 μs)

*系統極點 (z-domain):*
- $p_1 = 0.9898$ → 主導極點
- $p_2 = 0.6053$ → 次要極點
- 開迴路頻寬: ~160 Hz
- 閉迴路頻寬: 1000 Hz



#pagebreak()
//control effor
$ bold(u) lr([k]) = bold(B_"tune")^(-1) lr({bold(v)_"ff" lr([k]) + delta bold(v)_"fb" lr([k])}) - hat(bold(w)) lr([k]) $

#v(2em)

//v ff
$ bold(v)_"ff" lr([k-1]) = bold(v)_d lr([k]) - a_1 bold(v)_d lr([k-1]) - a_2 bold(v)_d lr([k-2]) $
#v(2em)
//v fb
$ delta bold(v)_"fb" lr([k]) = (a_1 - lambda_c)hat(delta bold(v)) lr([k]) + a_2 hat(delta bold(v)) lr([k-1]) $

#v(2em)
//w esti

$ hat(bold(s))_1 lr([k]) = lambda_c hat(bold(s))_1 lr([k-1]) + bold(L)_1{delta bold(v) lr([k-1]) - hat(bold(s))_1 lr([k-1])} $

$ hat(bold(s))_2 lr([k]) = hat(bold(s))_1 lr([k-1]) + bold(L)_2{delta bold(v) lr([k-1]) - hat(bold(s))_1 lr([k-1])} $

$ hat(bold(w)) lr([k]) = hat(bold(w)) lr([k-1]) + delta hat(bold(w)) lr([k-1]) + bold(L)_3{delta bold(v) lr([k-1]) - hat(bold(s))_1 lr([k-1])} $

$ delta hat(bold(w)) lr([k]) = delta hat(bold(w)) lr([k-1]) + bold(L)_4{delta bold(v) lr([k-1]) - hat(bold(s))_1 lr([k-1])} $

#v(2em)
$ L_1 = 1 + beta + a_1 + 4lambda_e $

$ L_2 = 1 + frac(lambda_e^4, a_2 beta) $

$ L_3 = -(-beta + (1 + beta)^2 - 4(1 + beta)lambda_e + 6lambda_e^2 - lambda_e^4/beta) bold(B_"tune"^(-1)) $

$ L_4 = -(1 + beta - 4lambda_e - (1 + beta)lambda_e^4/beta^2 + 4lambda_e^3/beta) bold(B_"tune"^(-1)) $

$ * beta = lambda_e^2 $

#pagebreak()

= HallSensor_VoltCtrl Module Implementation (inew_control_en Mode)

== Part 1: Variable Calculation Timeline [Channel 0]

=== Case 0: Start
```
MultA1 <= a1; MultB1 <= HsVd1_VECT6[0]
MultA2 <= a2; MultB2 <= HsVd2_VECT6[0]
MultA3 <= S1_d1_esti[0]; MultB3 <= lambda_c
SubA1 <= HsVd2_VECT6[0]; SubB1 <= HsVm1_VECT6[0]
```

=== Case 6: Result
```
a1_m_Vd_d1[0] <= MultRst1
a2_m_Vd_d2[0] <= MultRst2
lamc_M_S1_d1_esti[0] <= MultRst3
```

=== Case 8: Result
```
S1_d1[0] <= SubRst1
```

=== Case 9: Start
```
SubA1 <= S1_d1[0]; SubB1 <= S1_d1_esti[0]
```

=== Case 17: Result
```
Output_diff[0] <= SubRst1
```

=== Case 18: Start
```
MultA3 <= L1; MultB3 <= Output_diff[0]
```

=== Case 21: Start
```
MultA1 <= iHsVd_VECT6[0]; MultB1 <= HsVd_Coeff
MultA2 <= HsVd1_VECT6[0]; MultB2 <= HsVd_Coeff
SubA1 <= iHsVd_VECT6[0]; SubB1 <= a1_m_Vd_d1[0]
```

=== Case 22: Start
```
MultA1 <= HsVd1_LPF_VECT6[0]; MultB1 <= HsVd_LPF_Coeff1
```

=== Case 24: Result
```
S1_esti_correct[0] <= MultRst3
SubA1 <= Vd_s_a1Vd1[0]; SubB1 <= a2_m_Vd_d2[0]
```

=== Case 25: Start
```
AddA2 <= lamc_M_S1_d1_esti[0]; AddB2 <= S1_esti_correct[0]
```

=== Case 27: Result
```
HsVd_Coeff_M_HsVd_VECT6[0] <= MultRst1
HsVd_Coeff_M_HsVd1_VECT6[0] <= MultRst2
AddA1 <= MultRst1; AddB1 <= MultRst2
MultA3 <= L2; MultB3 <= Output_diff[0]
```

=== Case 28: Result
```
HsVd_LPF_Coeff1_M_HsVd1_LPF_VECT6[0] <= MultRst1
```

=== Case 32: Result
```
Vd_s_a1Vd1_s_a2Vd2[0] <= SubRst1
S1_esti[0] <= AddRst2
```

=== Case 33: Start
```
AddA2 <= S1_d1_esti[0]; AddB2 <= S2_esti_correct[0]
MultA2 <= a1_s_lamc; MultB2 <= S1_esti[0]
```

=== Case 35: Result
```
HsVd_ForLPF_Sum_VECT6[0] <= AddRst1
AddA1 <= AddRst1; AddB1 <= HsVd_LPF_Coeff1_M_HsVd1_LPF_VECT6[0]
```

=== Case 41: Result
```
a1lamc_m_S1_esti[0] <= MultRst2
AddA2 <= Vd_s_a1Vd1_s_a2Vd2[0]; AddB2 <= a1lamc_m_S1_esti[0]
S2_esti[0] <= AddRst2
```

=== Case 43: Result
```
HsVd_LPF_VECT6[0] <= AddRst1
MultA2 <= a2; MultB2 <= S2_esti[0]
```

=== Case 49: Result
```
Vd_s_a1Vd_s_a2Vd2_p_a1lamc_m_S1_esti[0] <= AddRst2
a2_m_S2_esti[0] <= MultRst2
```

=== Case 50: Start
```
AddA2 <= Vd_s_a1Vd_s_a2Vd2_p_a1lamc_m_S1_esti[0]; AddB2 <= a2_m_S2_esti[0]
```

=== Case 58: Result
```
u_before_Btuneinv[0] <= AddRst2
```

=== Case 64: Start
```
mVolt_6x1_3 <= u_before_Btuneinv
mTransf_MAT6x6_3 <= i_inv_B_tune
```

=== Case 68: Start
```
MultA4 <= L3; MultB4 <= Output_diff[0]
```

=== Case 71: Start
```
westi_before_correct[0] <= AddRst2
```

=== Case 74: Result
```
westi_correct[0] <= MultRst4
```

=== Case 80: Start
```
MultA4 <= L4; MultB4 <= Output_diff[0]
```

=== Case 86: Result
```
delta_westi_correct[0] <= MultRst4
```

=== Case 93: Start
```
AddA2 <= westi_before_correct[0]; AddB2 <= westi_correct[0]
```

=== Case 101: Result
```
westi[0] <= AddRst2
```

=== Case 107: Start
```
mVolt_6x1_4 <= westi
mTransf_MAT6x6_4 <= i_inv_B
```

=== Case 110: Start
```
AddA2 <= delta_westi_d1[0]; AddB2 <= delta_westi_correct[0]
```

=== Case 116: Result
```
delta_westi[0] <= AddRst2
```

=== Case 133: Result
```
u_before_w <= Rst_6x6_6x1_3
```

=== Case 176: Result
```
westi_after_Binv <= Rst_6x6_6x1_4
```

=== Case 177: Start
```
SubA5 <= u_before_w[0]; SubB5 <= westi_after_Binv[0]
```

=== Case 185: Result
```
u_total_new[0] <= SubRst5
```

=== Case 191: Result
```
ou_new[0] <= u_total_new[0]
```

=== Case 207: Start
```
MultA3 <= ou_new[0]; MultB3 <= iDA_Scale1V_fp
```

=== Case 213: Result
```
u_new_DAscale[0] <= MultRst3
```

=== Case 217: Start
```
FP2INT_data <= u_new_DAscale[0]
```

=== Case 224: Result
```
u_new_DAscale_int[0] <= FP2INT_Rst
ou_new_DAscale_int_offset[0] <= FP2INT_Rst + 32768
```

== Part 2: Mathematical Equations

```
S1_d1 = HsVd2_VECT6 - HsVm1_VECT6
Output_diff = S1_d1 - S1_d1_esti

a1_m_Vd_d1 = a1 * HsVd1_VECT6
a2_m_Vd_d2 = a2 * HsVd2_VECT6
lamc_M_S1_d1_esti = lambda_c * S1_d1_esti

Vd_s_a1Vd1 = iHsVd_VECT6 - a1_m_Vd_d1
Vd_s_a1Vd1_s_a2Vd2 = Vd_s_a1Vd1 - a2_m_Vd_d2

S1_esti_correct = L1 * Output_diff
S2_esti_correct = L2 * Output_diff
S1_esti = lamc_M_S1_d1_esti + S1_esti_correct
S2_esti = S1_d1_esti + S2_esti_correct

a1lamc_m_S1_esti = a1_s_lamc * S1_esti
a2_m_S2_esti = a2 * S2_esti

Vd_s_a1Vd_s_a2Vd2_p_a1lamc_m_S1_esti = Vd_s_a1Vd1_s_a2Vd2 + a1lamc_m_S1_esti
u_before_Btuneinv = Vd_s_a1Vd_s_a2Vd2_p_a1lamc_m_S1_esti + a2_m_S2_esti

westi_correct = L3 * Output_diff
delta_westi_correct = L4 * Output_diff
westi_before_correct = westi_d1 + delta_westi_d1
westi = westi_before_correct + westi_correct
delta_westi = delta_westi_d1 + delta_westi_correct

u_before_w = i_inv_B_tune * u_before_Btuneinv
westi_after_Binv = i_inv_B * westi
u_total_new = u_before_w - westi_after_Binv
ou_new = u_total_new

u_new_DAscale = ou_new * iDA_Scale1V_fp
ou_new_DAscale_int_offset = FP2INT(u_new_DAscale) + 32768
```

== Part 3: Low-Pass Filter Variables (For Completeness)

```
HsVd_Coeff = iHsCtrl_SplIntv / (2*iHsVd_LPF_tau + iHsCtrl_SplIntv)
HsVd_LPF_Coeff1 = (2*iHsVd_LPF_tau - iHsCtrl_SplIntv) / (2*iHsVd_LPF_tau + iHsCtrl_SplIntv)

HsVd_Coeff_M_HsVd_VECT6 = iHsVd_VECT6 * HsVd_Coeff
HsVd_Coeff_M_HsVd1_VECT6 = HsVd1_VECT6 * HsVd_Coeff
HsVd_LPF_Coeff1_M_HsVd1_LPF_VECT6 = HsVd1_LPF_VECT6 * HsVd_LPF_Coeff1
HsVd_ForLPF_Sum_VECT6 = HsVd_Coeff_M_HsVd_VECT6 + HsVd_Coeff_M_HsVd1_VECT6
HsVd_LPF_VECT6 = HsVd_ForLPF_Sum_VECT6 + HsVd_LPF_Coeff1_M_HsVd1_LPF_VECT6
```