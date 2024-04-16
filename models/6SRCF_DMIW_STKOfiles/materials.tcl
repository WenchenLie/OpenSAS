uniaxialMaterial Elastic 1 10000000000.0 
uniaxialMaterial Elastic 2 1e-06 
uniaxialMaterial Concrete02 3 -20.1 -0.00189 -4.02 -0.004 0.1 0.0 0.0
uniaxialMaterial Steel02 4 400.0 200000.0 0.005 18.5 0.925 0.15
uniaxialMaterial MinMax 5 4 -max 0.2
uniaxialMaterial ViscousDamper 57 276.018 86.5369 0.3 
uniaxialMaterial ElasticMultiLinear 58  \
	-strain \
	-50.0 -45.0 -40.0 \
	-35.0 -30.0 -25.0 \
	-20.0 -15.0 -10.0 \
	-5.0 0.0 5.0 \
	10.0 15.0 20.0 \
	25.0 30.0 35.0 \
	40.0 45.0 50.0 \
	-stress \
	-1426.88 -1040.51 -731.1 \
	-490.087 -308.925 -179.063 \
	-91.95 -39.0375 -11.775 \
	-1.6125 0.0 1.6125 \
	11.775 39.0375 91.95 \
	179.063 308.925 490.087 \
	731.1 1040.51 1426.88
uniaxialMaterial BoucWen 59 0.2662 30.2499 0.6584 -0.6225 0.7225 1.0 0.0 0.0 0.0
uniaxialMaterial Parallel 60 57 58 59 -factors 41.77 41.77 41.77
uniaxialMaterial Parallel 61 57 58 59 -factors 41.31 41.31 41.31
uniaxialMaterial Parallel 62 57 58 59 -factors 41.69 41.69 41.69
