#set page(paper: "a4", margin: 2cm)
#set text(font: "New Computer Modern", size: 11pt)
#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")

#align(center)[
  #text(20pt, weight: "bold")[二階系統曲線擬合推導分析]

  #text(12pt)[PDF 方法錯誤分析與正確推導]
]

= 問題設定

考慮二階傳遞函數：
$ H(s) = b/(s^2 + a_1 s + a_2) $

在頻率 $omega_k$ 處，令 $s = j omega_k$：
$ H(j omega_k) = b/(( j omega_k)^2 + a_1(j omega_k) + a_2) = b/(-omega_k^2 + j a_1 omega_k + a_2) $

實測資料給出：
$ H(j omega_k) = h_k e^(j phi_k) = h_k (cos phi_k + j sin phi_k) $

= 建立方程式

== 步驟 1：建立等式

從理論和實測資料，我們有：
$ h_k e^(j phi_k) = b/(-omega_k^2 + j a_1 omega_k + a_2) $

== 步驟 2：交叉相乘

兩邊同乘以分母：
$ h_k e^(j phi_k) times (-omega_k^2 + j a_1 omega_k + a_2) = b $

== 步驟 3：展開複數

將左邊展開：
$ h_k (cos phi_k + j sin phi_k) times ((a_2 - omega_k^2) + j a_1 omega_k) = b $

== 步驟 4：複數乘法

執行複數乘法 $(a + j b)(c + j d) = (a c - b d) + j(a d + b c)$：

*實部*：
$ h_k cos phi_k (a_2 - omega_k^2) - h_k sin phi_k times a_1 omega_k = b $

*虛部*：
$ h_k sin phi_k (a_2 - omega_k^2) + h_k cos phi_k times a_1 omega_k = 0 $

== 步驟 5：重新整理

將方程式按照未知數 $(a_1, a_2, b)$ 重新排列：

*實部方程*：
$ -h_k sin phi_k omega_k times a_1 + h_k cos phi_k times a_2 - 1 times b = h_k cos phi_k omega_k^2 $

*虛部方程*：
$ h_k cos phi_k omega_k times a_1 + h_k sin phi_k times a_2 + 0 times b = h_k sin phi_k omega_k^2 $

= 矩陣形式

對於 $n$ 個頻率點，我們有 $2n$ 個方程式，3 個未知數。寫成矩陣形式：

$ mat(
  -h_1 sin phi_1 omega_1, h_1 cos phi_1, -1;
  h_1 cos phi_1 omega_1, h_1 sin phi_1, 0;
  -h_2 sin phi_2 omega_2, h_2 cos phi_2, -1;
  h_2 cos phi_2 omega_2, h_2 sin phi_2, 0;
  dots.v, dots.v, dots.v;
  -h_n sin phi_n omega_n, h_n cos phi_n, -1;
  h_n cos phi_n omega_n, h_n sin phi_n, 0;
) mat(a_1; a_2; b) = mat(
  h_1 cos phi_1 omega_1^2;
  h_1 sin phi_1 omega_1^2;
  h_2 cos phi_2 omega_2^2;
  h_2 sin phi_2 omega_2^2;
  dots.v;
  h_n cos phi_n omega_n^2;
  h_n sin phi_n omega_n^2;
) $

簡寫為：$bold(A) bold(x) = bold(b)$，其中 $bold(A)$ 是 $2n times 3$ 矩陣。

= 最小二乘法求解

由於方程數 $(2n)$ 通常大於未知數 $(3)$，使用最小二乘法：

$ bold(A)^T bold(A) bold(x) = bold(A)^T bold(b) $

== 計算 $bold(A)^T bold(A)$（3×3 矩陣）

#text(red, weight: "bold")[關鍵步驟：這裡需要仔細計算每個元素]

$(bold(A)^T bold(A))_(11) = sum_(k=1)^n [(-h_k sin phi_k omega_k)^2 + (h_k cos phi_k omega_k)^2]$

$= sum_(k=1)^n h_k^2 omega_k^2 (sin^2 phi_k + cos^2 phi_k) = sum_(k=1)^n h_k^2 omega_k^2$

$(bold(A)^T bold(A))_(12) = sum_(k=1)^n [(-h_k sin phi_k omega_k)(h_k cos phi_k) + (h_k cos phi_k omega_k)(h_k sin phi_k)]$

$= sum_(k=1)^n h_k^2 [-sin phi_k cos phi_k omega_k + cos phi_k sin phi_k omega_k] = 0$

$(bold(A)^T bold(A))_(13) = sum_(k=1)^n [(-h_k sin phi_k omega_k)(-1) + (h_k cos phi_k omega_k)(0)]$

$= sum_(k=1)^n h_k sin phi_k omega_k$

$(bold(A)^T bold(A))_(22) = sum_(k=1)^n [(h_k cos phi_k)^2 + (h_k sin phi_k)^2]$

$= sum_(k=1)^n h_k^2 (cos^2 phi_k + sin^2 phi_k) = sum_(k=1)^n h_k^2$

$(bold(A)^T bold(A))_(23) = sum_(k=1)^n [(h_k cos phi_k)(-1) + (h_k sin phi_k)(0)]$

$= -sum_(k=1)^n h_k cos phi_k$

$(bold(A)^T bold(A))_(33) = sum_(k=1)^n [(-1)^2 + 0^2] = n$

== 計算 $bold(A)^T bold(b)$（3×1 向量）

$(bold(A)^T bold(b))_1 = sum_(k=1)^n [(-h_k sin phi_k omega_k)(h_k cos phi_k omega_k^2) + (h_k cos phi_k omega_k)(h_k sin phi_k omega_k^2)]$

$= sum_(k=1)^n h_k^2 omega_k^3 [-sin phi_k cos phi_k + cos phi_k sin phi_k] = 0$

$(bold(A)^T bold(b))_2 = sum_(k=1)^n [(h_k cos phi_k)(h_k cos phi_k omega_k^2) + (h_k sin phi_k)(h_k sin phi_k omega_k^2)]$

$= sum_(k=1)^n h_k^2 omega_k^2 (cos^2 phi_k + sin^2 phi_k) = sum_(k=1)^n h_k^2 omega_k^2$

$(bold(A)^T bold(b))_3 = sum_(k=1)^n [(-1)(h_k cos phi_k omega_k^2) + (0)(h_k sin phi_k omega_k^2)]$

$= -sum_(k=1)^n h_k cos phi_k omega_k^2$

= 正確的正規方程

#align(center)[
#box(stroke: 2pt + blue, inset: 10pt)[
#text(blue, weight: "bold")[正確的矩陣形式：]

$ mat(
  sum h_k^2 omega_k^2, 0, sum h_k sin phi_k omega_k;
  0, sum h_k^2, -sum h_k cos phi_k;
  sum h_k sin phi_k omega_k, -sum h_k cos phi_k, n;
) mat(a_1; a_2; b) = mat(
  0;
  sum h_k^2 omega_k^2;
  -sum h_k cos phi_k omega_k^2;
) $
]
]

= PDF 的錯誤

#align(center)[
#box(stroke: 2pt + red, inset: 10pt)[
#text(red, weight: "bold")[PDF 中的錯誤矩陣：]

$ mat(
  sum h_k^2 omega_k^2, 0, sum h_k sin phi_k omega_k;
  0, #text(red, weight: "bold")[sum h_k sin phi_k omega_k], -sum h_k cos phi_k;
  sum h_k sin phi_k omega_k, -sum h_k cos phi_k, n;
) mat(a_1; a_2; b) = mat(
  0;
  sum h_k^2 omega_k^2;
  -sum h_k cos phi_k omega_k^2;
) $
]
]

== 錯誤分析

PDF 的錯誤在於：
1. #text(red, weight: "bold")[矩陣位置 (2,2) 應該是 $sum h_k^2$，而不是 $sum h_k sin phi_k omega_k$]
2. 這違反了正規方程 $bold(A)^T bold(A)$ 必須是對稱矩陣的性質
3. PDF 中 $(2,1) = 0$ 但 $(1,2) = sum h_k sin phi_k omega_k$，不對稱

== 為什麼會錯？

推測 PDF 作者可能：
- 直接從方程式組試圖歸納出模式
- 沒有嚴格執行矩陣乘法 $bold(A)^T bold(A)$
- 混淆了不同項的總和

= 結論

#box(stroke: 2pt + green, inset: 10pt, width: 100%)[
#text(green, weight: "bold")[正確做法：]

1. 建立 $2n times 3$ 的完整矩陣 $bold(A)$
2. 計算 $bold(A)^T bold(A)$ 和 $bold(A)^T bold(b)$
3. 求解 $(bold(A)^T bold(A)) bold(x) = bold(A)^T bold(b)$

或直接用 MATLAB：`x = A \ b`（自動使用最小二乘法）
]

= 數值驗證

正確的矩陣 $(2,2)$ 元素：
$ (bold(A)^T bold(A))_(22) = sum_(k=1)^n h_k^2 $

PDF 錯誤的 $(2,2)$ 元素：
$ text("PDF")_(22) = sum_(k=1)^n h_k sin phi_k omega_k $

這兩者完全不同！前者是幅值的平方和，後者涉及相位和頻率，物理意義完全不同。