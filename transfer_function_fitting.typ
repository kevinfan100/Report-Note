#set page(margin: 2cm)
#set text(font: "New Computer Modern", size: 16pt)
// #set math.equation(numbering: "(1)")


= Transfer Function

#v( 2em)

$ H(s) = (2.0934 times 10^7)/(s^2 + 9.1644 times 10^3 s + 2.0934 times 10^7) bold(B) $

#v( 1em)
where $bold(B)$ is:
#v( 1em)
$ bold(B) = mat(
  0.2360, -0.0051, -0.0401, -0.0218, -0.0208, -0.0394;
  -0.0135, 0.2333, -0.0321, -0.0536, -0.0595, -0.0259;
  -0.0404, -0.0187, 0.2295, -0.0053, -0.0146, -0.0370;
  -0.0201, -0.0633, -0.0154, 0.1931, -0.0570, -0.0208;
  -0.0270, -0.0628, -0.0203, -0.0575, 0.1956, -0.0135;
  -0.0285, -0.0188, -0.0301, -0.0152, -0.0010, 0.1928
) $
#v( 2em)

-  $omega_n = sqrt(2.0934 times 10^7) approx 4575.0$ rad/s
-  $zeta approx 1.0015$