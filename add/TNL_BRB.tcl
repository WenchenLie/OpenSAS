proc TNL_BRB {SpringID NodeI NodeJ K Fy alpha} {

uniaxialMaterial Steel01 $SpringID $Fy $K $alpha

element twoNodeLink $SpringID $NodeI $NodeJ -mat $SpringID -dir 1;


}