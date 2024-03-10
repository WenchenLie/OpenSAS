proc Spring_TSTD {SpringID NodeI NodeJ My K} {

# default parameters
set alpha 0.011;
set R0 18.5;
set cR1 0.8;
set cR2 0.15;
set a1 0.05;
set a2 1;
set a3 0.05;
set a4 1;


uniaxialMaterial SteelMPF $SpringID $My $My $K $alpha $alpha $R0 $cR1 $cR2 $a1 $a2 $a3 $a4;

element zeroLength $SpringID  $NodeI $NodeJ -mat 99 99 $SpringID -dir 1 2 6;

}