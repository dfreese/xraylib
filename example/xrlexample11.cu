#include <stdio.h>
#include "xraylib.h"
#include "xraylib-cuda.h"
#include "xraylib-cuda-private.h"
#include <stdlib.h>
#include <cuda_runtime.h>
#include "xrayglob.h"

//#define CUDA_ERROR_CHECK


__global__ void AugerRates(int *Z, int *auger_trans, double *rates) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	rates[tid] = AugerRate_cu(Z[tid], auger_trans[tid]);
	
	return;
}

__global__ void AugerYields(int *Z, int *shells, double *yields) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	yields[tid] = AugerYield_cu(Z[tid], shells[tid]);
	
	return;
}


__global__ void Yields(int *Z, int *shells, double *yields) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	yields[tid] = FluorYield_cu(Z[tid], shells[tid]);
	
	return;
}

__global__ void Weights(int *Z, double *weights) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	weights[tid] = AtomicWeight_cu(Z[tid]);
	
	return;
}

__global__ void Densities(int *Z, double *densities) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	densities[tid] = ElementDensity_cu(Z[tid]);
	
	return;
}

__global__ void Edges(int *Z, int *shells, double *edges) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	edges[tid] = EdgeEnergy_cu(Z[tid], shells[tid]);
	
	return;
}

__global__ void Jumps(int *Z, int *shells, double *jumps) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	jumps[tid] = JumpFactor_cu(Z[tid], shells[tid]);
	
	return;
}

__global__ void LineEnergies(int *Z, int *lines, double *line_energies) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	line_energies[tid] = LineEnergy_cu(Z[tid], lines[tid]);
	
	return;
}

__global__ void CosKrons(int *Z, int *trans, double *coskrons) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	coskrons[tid] = CosKronTransProb_cu(Z[tid], trans[tid]);
	
	return;
}

__global__ void RadRates(int *Z, int *lines, double *radrates) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	radrates[tid] = RadRate_cu(Z[tid], lines[tid]);
	
	return;
}

__global__ void Widths(int *Z, int *shells, double *widths) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;


	widths[tid] = AtomicLevelWidth_cu(Z[tid], shells[tid]);
	
	return;
}

__global__ void CS(int *Z, double *energies, double *cs) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	cs[tid] = CS_Photo_cu(Z[tid], energies[tid]);
	cs[tid+blockDim.x] = CS_Rayl_cu(Z[tid], energies[tid]);
	cs[tid+2*blockDim.x] = CS_Compt_cu(Z[tid], energies[tid]);
	cs[tid+3*blockDim.x] = CS_Total_cu(Z[tid], energies[tid]);
	cs[tid+4*blockDim.x] = CS_Energy_cu(Z[tid], energies[tid]);
	
	return;
}

__global__ void XRFCS(int *Z, int *lines, double *energies, double *cs) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	cs[tid] = CS_FluorLine_Kissel_Cascade_cu(Z[tid], lines[tid], energies[tid]);
	cs[tid+blockDim.x] = CS_FluorLine_Kissel_Nonradiative_Cascade_cu(Z[tid], lines[tid], energies[tid]);
	cs[tid+2*blockDim.x] = CS_FluorLine_Kissel_Radiative_Cascade_cu(Z[tid], lines[tid], energies[tid]);
	cs[tid+3*blockDim.x] = CS_FluorLine_Kissel_no_Cascade_cu(Z[tid], lines[tid], energies[tid]);
	cs[tid+4*blockDim.x] = CS_FluorLine_cu(Z[tid], lines[tid], energies[tid]);
	
	return;
}

__global__ void CS_Partial(int *Z, int *shells, double *energies, double *cs) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	cs[tid] = CS_Photo_Partial_cu(Z[tid], shells[tid],energies[tid]);
	
	return;
}

__global__ void Anomalous(int *Z, double *energies, double *anom) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	anom[tid] = Fi_cu(Z[tid], energies[tid]);
	anom[tid+blockDim.x] = Fii_cu(Z[tid], energies[tid]);
	
	return;
}

__global__ void DCS(int *Z, double *energies, double *thetas, double *dcs) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	dcs[tid] = DCS_Rayl_cu(Z[tid], energies[tid], thetas[tid]);
	dcs[tid+blockDim.x] = DCS_Compt_cu(Z[tid], energies[tid], thetas[tid]);
	
	return;
}

__global__ void ComptonProfiles(int *Z, double *pz, double *q) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	q[tid] = ComptonProfile_cu(Z[tid], pz[tid]);
	
	return;
}

__global__ void ComptonProfilesPartial(int *Z, int *shell, double *pz, double *q) {
	int tid = blockIdx.x*blockDim.x + threadIdx.x;
	
	q[tid] = ComptonProfile_Partial_cu(Z[tid], shell[tid], pz[tid]);
	
	return;
}



int main (int argc, char *argv[]) {

	fprintf(stdout,"Entering xrlexample11\n");
	
	int Z[5] = {10,15,26,79,82};
	int shells[5] = {K_SHELL, K_SHELL, K_SHELL, L3_SHELL,L1_SHELL};
	int lines[5] = {KL2_LINE, KL3_LINE, KM3_LINE, L3M5_LINE, M5N6_LINE};
	double energies[5] = {2.0, 8.0, 9.275, 93.0, 50.23};
	int Z2[3] = {56, 68, 80};
	int trans[3] = {FL13_TRANS, FL23_TRANS, FM34_TRANS};
	int auger_trans[5] = {K_L1L1_AUGER, K_L3M1_AUGER, K_L3N1_AUGER, L2_M2M4_AUGER, M3_M4N4_AUGER};
	int *Zd, *Z2d;
	int *shellsd, *linesd, *transd, *auger_transd;
	double *energiesd;
	double pz[5] = {5.0, 10.0, 30.0, 60.0, 80.0};
	double *pzd;
	double thetas[5] = {0.01, 0.07, 0.12, 1.0, 1.3};
	double *thetasd;

	double yields[5], *yieldsd;
	double augeryields[5], *augeryieldsd;
	double weights[5], *weightsd;
	double densities[5], *densitiesd;
	double edges[5], *edgesd;
	double lineEnergies[5], *lineEnergiesd;
	double jumps[5], *jumpsd;
	double coskrons[3], *coskronsd;
	double radrates[5], *radratesd;
	double augerrates[5], *augerratesd;
	double widths[5], *widthsd; 
	double cs[25], *csd;
	double compton_profiles[5], *compton_profilesd;
	double partial_compton_profiles[5], *partial_compton_profilesd;
	double anom[10], *anomd;
	double dcs[10], *dcsd;
	double xrfcs[25], *xrfcsd;
	double cs_partial[5], *cs_partiald;
	double line_energies[5], *line_energiesd;


	int i;

	if (CudaXRayInit() == 0) {
		return 1;
	}
	SetErrorMessages(0);

	//input variables
	CudaSafeCall(cudaMalloc((void **) &Zd, 5*sizeof(int)));
	CudaSafeCall(cudaMemcpy(Zd, Z, 5*sizeof(int), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &Z2d, 3*sizeof(int)));
	CudaSafeCall(cudaMemcpy(Z2d, Z2, 3*sizeof(int), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &shellsd, 5*sizeof(int)));
	CudaSafeCall(cudaMemcpy(shellsd, shells, 5*sizeof(int), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &linesd, 5*sizeof(int)));
	CudaSafeCall(cudaMemcpy(linesd, lines, 5*sizeof(int), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &transd, 3*sizeof(int)));
	CudaSafeCall(cudaMemcpy(transd, trans, 3*sizeof(int), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &auger_transd, 5*sizeof(int)));
	CudaSafeCall(cudaMemcpy(auger_transd, auger_trans, 5*sizeof(int), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &energiesd, 5*sizeof(double)));
	CudaSafeCall(cudaMemcpy(energiesd, energies, 5*sizeof(double), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &pzd, 5*sizeof(double)));
	CudaSafeCall(cudaMemcpy(pzd, pz, 5*sizeof(double), cudaMemcpyHostToDevice));
	CudaSafeCall(cudaMalloc((void **) &thetasd, 5*sizeof(double)));
	CudaSafeCall(cudaMemcpy(thetasd, thetas, 5*sizeof(double), cudaMemcpyHostToDevice));


	//output variables
	CudaSafeCall(cudaMalloc((void **) &yieldsd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &augeryieldsd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &weightsd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &densitiesd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &edgesd, 5*sizeof(double)));
//	CudaSafeCall(cudaMalloc((void **) &lineEnergiesd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &jumpsd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &coskronsd, 3*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &radratesd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &augerratesd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &widthsd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &csd, 25*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &compton_profilesd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &partial_compton_profilesd, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &anomd, 10*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &dcsd, 10*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &xrfcsd, 25*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &cs_partiald, 5*sizeof(double)));
	CudaSafeCall(cudaMalloc((void **) &line_energiesd, 5*sizeof(double)));


	Yields<<<1,5>>>(Zd, shellsd,yieldsd);	
	CudaCheckError();

	Weights<<<1,5>>>(Zd, weightsd);	
	CudaCheckError();

	Densities<<<1,5>>>(Zd, densitiesd);	
	CudaCheckError();

	Edges<<<1,5>>>(Zd, shellsd, edgesd);	
	CudaCheckError();

	LineEnergies<<<1,5>>>(Zd, linesd, line_energiesd);	
	CudaCheckError();

	Jumps<<<1,5>>>(Zd, shellsd, jumpsd);	
	CudaCheckError();

	CosKrons<<<1,3>>>(Z2d, transd, coskronsd);	
	CudaCheckError();

	RadRates<<<1,5>>>(Zd, linesd, radratesd);	
	CudaCheckError();

	Widths<<<1,5>>>(Zd, shellsd, widthsd);	
	CudaCheckError();
	
	CS<<<1,5>>>(Zd, energiesd, csd);	
	CudaCheckError();

	AugerRates<<<1,5>>>(Zd, auger_transd, augerratesd);
	CudaCheckError();
	
	AugerYields<<<1,5>>>(Zd, shellsd, augeryieldsd);
	CudaCheckError();

	ComptonProfiles<<<1,5>>>(Zd, pzd, compton_profilesd);
	CudaCheckError();

	ComptonProfilesPartial<<<1,5>>>(Zd, shellsd, pzd, partial_compton_profilesd);
	CudaCheckError();

	Anomalous<<<1,5>>>(Zd, energiesd, anomd);
	CudaCheckError();

	DCS<<<1,5>>>(Zd, energiesd, thetasd, dcsd);
	CudaCheckError();

	XRFCS<<<1,5>>>(Zd, linesd, energiesd, xrfcsd);
	CudaCheckError();

	CS_Partial<<<1,5>>>(Zd, shellsd, energiesd, cs_partiald);
	CudaCheckError();

	CudaSafeCall(cudaMemcpy(yields, yieldsd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(weights, weightsd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(densities, densitiesd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(edges, edgesd, 5*sizeof(double), cudaMemcpyDeviceToHost));
//	CudaSafeCall(cudaMemcpy(lineEnergies, lineEnergiesd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(jumps, jumpsd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(coskrons, coskronsd, 3*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(radrates, radratesd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(widths, widthsd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(cs, csd, 25*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(augerrates, augerratesd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(augeryields, augeryieldsd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(compton_profiles, compton_profilesd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(partial_compton_profiles, partial_compton_profilesd, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(anom, anomd, 10*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(dcs, dcsd, 10*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(xrfcs, xrfcsd, 25*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(cs_partial, cs_partiald, 5*sizeof(double), cudaMemcpyDeviceToHost));
	CudaSafeCall(cudaMemcpy(line_energies, line_energiesd, 5*sizeof(double), cudaMemcpyDeviceToHost));


	fprintf(stdout,"Fluorescence yields\n");
	fprintf(stdout,"Shell   Classic   CUDA\n");
	fprintf(stdout,"Ne-K    %8f %f\n",FluorYield(10,K_SHELL), yields[0]);
	fprintf(stdout,"P-K     %8f %f\n",FluorYield(15,K_SHELL), yields[1]);
	fprintf(stdout,"Fe-K    %8f %f\n",FluorYield(26,K_SHELL), yields[2]);
	fprintf(stdout,"Au-L3   %8f %f\n",FluorYield(79,L3_SHELL), yields[3]);
	fprintf(stdout,"Pb-L1   %8f %f\n",FluorYield(82,L1_SHELL), yields[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Atomic weights\n");
	fprintf(stdout,"Element   Classic   CUDA\n");
	fprintf(stdout,"Ne      %8f %f\n",AtomicWeight(10), weights[0]);
	fprintf(stdout,"P       %8f %f\n",AtomicWeight(15), weights[1]);
	fprintf(stdout,"Fe      %8f %f\n",AtomicWeight(26), weights[2]);
	fprintf(stdout,"Au      %8f %f\n",AtomicWeight(79), weights[3]);
	fprintf(stdout,"Pb      %8f %f\n",AtomicWeight(82), weights[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Edge energies\n");
	fprintf(stdout,"Shell   Classic   CUDA\n");
	fprintf(stdout,"Ne-K    %8f %f\n",EdgeEnergy(10,K_SHELL), edges[0]);
	fprintf(stdout,"P-K     %8f %f\n",EdgeEnergy(15,K_SHELL), edges[1]);
	fprintf(stdout,"Fe-K    %8f %f\n",EdgeEnergy(26,K_SHELL), edges[2]);
	fprintf(stdout,"Au-L3   %8f %f\n",EdgeEnergy(79,L3_SHELL), edges[3]);
	fprintf(stdout,"Pb-L1   %8f %f\n",EdgeEnergy(82,L1_SHELL), edges[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Jump factors\n");
	fprintf(stdout,"Shell   Classic   CUDA\n");
	fprintf(stdout,"Ne-K    %8f %f\n",JumpFactor(10,K_SHELL), jumps[0]);
	fprintf(stdout,"P-K     %8f %f\n",JumpFactor(15,K_SHELL), jumps[1]);
	fprintf(stdout,"Fe-K    %8f %f\n",JumpFactor(26,K_SHELL), jumps[2]);
	fprintf(stdout,"Au-L3   %8f %f\n",JumpFactor(79,L3_SHELL), jumps[3]);
	fprintf(stdout,"Pb-L1   %8f %f\n",JumpFactor(82,L1_SHELL), jumps[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Coster-Kronig transition probabilities\n");
	fprintf(stdout,"Transition   Classic   CUDA\n");
	fprintf(stdout,"Ba L1->L3    %8f %f\n",CosKronTransProb(56,FL13_TRANS), coskrons[0]);
	fprintf(stdout,"Er L3->L2    %8f %f\n",CosKronTransProb(68,FL23_TRANS), coskrons[1]);
	fprintf(stdout,"Hg M3->M4    %8f %f\n",CosKronTransProb(80,FM34_TRANS), coskrons[2]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Radiative rates\n");
	fprintf(stdout,"Line      Classic   CUDA\n");
	fprintf(stdout,"Ne-KL2    %8f %f\n",RadRate(10,lines[0]), radrates[0]);
	fprintf(stdout,"P-KL3     %8f %f\n",RadRate(15,lines[1]), radrates[1]);
	fprintf(stdout,"Fe-KM3    %8f %f\n",RadRate(26,lines[2]), radrates[2]);
	fprintf(stdout,"Au-L3M5   %8f %f\n",RadRate(79,lines[3]), radrates[3]);
	fprintf(stdout,"Pb-M5N6   %8f %f\n",RadRate(82,lines[4]), radrates[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Atomic level widths\n");
	fprintf(stdout,"Shell   Classic   CUDA\n");
	fprintf(stdout,"Ne-K    %8f %f\n",AtomicLevelWidth(10,K_SHELL), widths[0]);
	fprintf(stdout,"P-K     %8f %f\n",AtomicLevelWidth(15,K_SHELL), widths[1]);
	fprintf(stdout,"Fe-K    %8f %f\n",AtomicLevelWidth(26,K_SHELL), widths[2]);
	fprintf(stdout,"Au-L3   %8f %f\n",AtomicLevelWidth(79,L3_SHELL), widths[3]);
	fprintf(stdout,"Pb-L1   %8f %f\n",AtomicLevelWidth(82,L1_SHELL), widths[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Auger yields\n");
	fprintf(stdout,"Shell   Classic   CUDA\n");
	fprintf(stdout,"Ne-K    %8f %f\n",AugerYield(10,K_SHELL), augeryields[0]);
	fprintf(stdout,"P-K     %8f %f\n",AugerYield(15,K_SHELL), augeryields[1]);
	fprintf(stdout,"Fe-K    %8f %f\n",AugerYield(26,K_SHELL), augeryields[2]);
	fprintf(stdout,"Au-L3   %8f %f\n",AugerYield(79,L3_SHELL), augeryields[3]);
	fprintf(stdout,"Pb-L1   %8f %f\n",AugerYield(82,L1_SHELL), augeryields[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Fraction non radiative rates\n");
	fprintf(stdout,"Auger transition   Classic   CUDA\n");
	fprintf(stdout,"Ne-K->L1L1         %8f %f\n",AugerRate(10, auger_trans[0]), augerrates[0]);
	fprintf(stdout,"P-K->L3M1          %8f %f\n",AugerRate(15, auger_trans[1]), augerrates[1]);
	fprintf(stdout,"Fe-K->L3N1         %8f %f\n",AugerRate(26, auger_trans[2]), augerrates[2]);
	fprintf(stdout,"Au-L2->M2M4        %8f %f\n",AugerRate(79, auger_trans[3]), augerrates[3]);
	fprintf(stdout,"Pb-M3->M4N4        %8f %f\n",AugerRate(82, auger_trans[4]), augerrates[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Full Compton profiles\n");
	fprintf(stdout,"Element  pz        Classic   CUDA\n");
	fprintf(stdout,"Ne       %6f  %8f %f\n", pz[0], ComptonProfile(Z[0],pz[0]), compton_profiles[0]);
	fprintf(stdout,"P        %6f %8f %f\n", pz[1], ComptonProfile(Z[1],pz[1]), compton_profiles[1]);
	fprintf(stdout,"Fe       %6f %8f %f\n", pz[2], ComptonProfile(Z[2],pz[2]), compton_profiles[2]);
	fprintf(stdout,"Au       %6f %8f %f\n", pz[3], ComptonProfile(Z[3],pz[3]), compton_profiles[3]);
	fprintf(stdout,"Pb       %6f %8f %f\n", pz[4], ComptonProfile(Z[4],pz[4]), compton_profiles[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Partial Compton profiles\n");
	fprintf(stdout,"Element  pz        Classic   CUDA\n");
	fprintf(stdout,"Ne-K     %6f  %8f %f\n", pz[0], ComptonProfile_Partial(Z[0],shells[0], pz[0]), partial_compton_profiles[0]);
	fprintf(stdout,"P-K      %6f %8f %f\n", pz[1], ComptonProfile_Partial(Z[1],shells[1], pz[1]), partial_compton_profiles[1]);
	fprintf(stdout,"Fe-K     %6f %8f %f\n", pz[2], ComptonProfile_Partial(Z[2],shells[2], pz[2]), partial_compton_profiles[2]);
	fprintf(stdout,"Au-L3    %6f %8f %f\n", pz[3], ComptonProfile_Partial(Z[3],shells[3], pz[3]), partial_compton_profiles[3]);
	fprintf(stdout,"Pb-L1    %6f %8f %f\n", pz[4], ComptonProfile_Partial(Z[4],shells[4], pz[4]), partial_compton_profiles[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Photo ionization cross sections (cm2/g)\n");
	fprintf(stdout,"Element   Energy(keV)     Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], CS_Photo(Z[i], energies[i]), cs[i]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Rayleigh scattering cross sections (cm2/g)\n");
	fprintf(stdout,"Element   Energy(keV)     Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], CS_Rayl(Z[i], energies[i]), cs[i+5]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Compton scattering cross sections (cm2/g)\n");
	fprintf(stdout,"Element   Energy(keV)     Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], CS_Compt(Z[i], energies[i]), cs[i+10]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Total attenuation cross sections (cm2/g)\n");
	fprintf(stdout,"Element   Energy(keV)     Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], CS_Total(Z[i], energies[i]), cs[i+15]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Mass-energy absorption cross sections (cm2/g)\n");
	fprintf(stdout,"Element   Energy(keV)     Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], CS_Energy(Z[i], energies[i]), cs[i+20]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Element density\n");
	fprintf(stdout,"Element   Classic   CUDA\n");
	fprintf(stdout,"Ne      %8f %f\n",ElementDensity(10), densities[0]);
	fprintf(stdout,"P       %8f %f\n",ElementDensity(15), densities[1]);
	fprintf(stdout,"Fe      %8f %f\n",ElementDensity(26), densities[2]);
	fprintf(stdout,"Au      %8f %f\n",ElementDensity(79), densities[3]);
	fprintf(stdout,"Pb      %8f %f\n",ElementDensity(82), densities[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Anomalous scattering factor phi prime\n");
	fprintf(stdout,"Element   Energy(keV)     Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], Fi(Z[i], energies[i]), anom[i]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Anomalous scattering factor phi double prime\n");
	fprintf(stdout,"Element   Energy(keV)     Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], Fii(Z[i], energies[i]), anom[i+5]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Differential Rayleigh cross sections (cm2/g/sterad)\n");
	fprintf(stdout,"Element   Energy(keV)     Theta           Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], thetas[i], DCS_Rayl(Z[i], energies[i], thetas[i]), dcs[i]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Differential Compton cross sections (cm2/g/sterad)\n");
	fprintf(stdout,"Element   Energy(keV)     Theta           Classic       Cuda\n");
	for (i = 0 ; i < 5 ; i++) {
		fprintf(stdout,"%-2s        %-10.4f      %-10.4f      %-10.4f    %-10.4f\n", AtomicNumberToSymbol(Z[i]), energies[i], thetas[i], DCS_Compt(Z[i], energies[i], thetas[i]), dcs[i+5]);
	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"Partial photoionization cross sections (cm2/g)\n");
	fprintf(stdout,"Shell   Energy(keV)     Classic       CUDA\n");
	fprintf(stdout,"Ne-K    %-10.4f      %-10.4f    %-10.4f\n",energies[0], CS_Photo_Partial(Z[0], shells[0], energies[0]), cs_partial[0]);
	fprintf(stdout,"P-K     %-10.4f      %-10.4f    %-10.4f\n",energies[1], CS_Photo_Partial(Z[1], shells[1], energies[1]), cs_partial[1]);
	fprintf(stdout,"Fe-K    %-10.4f      %-10.4f    %-10.4f\n",energies[2], CS_Photo_Partial(Z[2], shells[2], energies[2]), cs_partial[2]);
	fprintf(stdout,"Au-L3   %-10.4f      %-10.4f    %-10.4f\n",energies[3], CS_Photo_Partial(Z[3], shells[3], energies[3]), cs_partial[3]);
	fprintf(stdout,"Pb-L1   %-10.4f      %-10.4f    %-10.4f\n",energies[4], CS_Photo_Partial(Z[4], shells[4], energies[4]), cs_partial[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"XRF production cross sections with full cascade (cm2/g)\n");
	fprintf(stdout,"Line      Energy(keV)     Classic       CUDA\n");
	fprintf(stdout,"Ne-KL2    %-10.4f      %-10.4f    %-10.4f\n",energies[0], CS_FluorLine_Kissel_Cascade(Z[0], lines[0], energies[0]), xrfcs[0]);
	fprintf(stdout,"P-KL3     %-10.4f      %-10.4f    %-10.4f\n",energies[1], CS_FluorLine_Kissel_Cascade(Z[1], lines[1], energies[1]), xrfcs[1]);
	fprintf(stdout,"Fe-KM3    %-10.4f      %-10.4f    %-10.4f\n",energies[2], CS_FluorLine_Kissel_Cascade(Z[2], lines[2], energies[2]), xrfcs[2]);
	fprintf(stdout,"Au-L3M5   %-10.4f      %-10.4f    %-10.4f\n",energies[3], CS_FluorLine_Kissel_Cascade(Z[3], lines[3], energies[3]), xrfcs[3]);
	fprintf(stdout,"Pb-M5N6   %-10.4f      %-10.4f    %-10.4f\n",energies[4], CS_FluorLine_Kissel_Cascade(Z[4], lines[4], energies[4]), xrfcs[4]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"XRF production cross sections with non-radiative cascade (cm2/g)\n");
	fprintf(stdout,"Line      Energy(keV)     Classic       CUDA\n");
	fprintf(stdout,"Ne-KL2    %-10.4f      %-10.4f    %-10.4f\n",energies[0], CS_FluorLine_Kissel_Nonradiative_Cascade(Z[0], lines[0], energies[0]), xrfcs[5]);
	fprintf(stdout,"P-KL3     %-10.4f      %-10.4f    %-10.4f\n",energies[1], CS_FluorLine_Kissel_Nonradiative_Cascade(Z[1], lines[1], energies[1]), xrfcs[6]);
	fprintf(stdout,"Fe-KM3    %-10.4f      %-10.4f    %-10.4f\n",energies[2], CS_FluorLine_Kissel_Nonradiative_Cascade(Z[2], lines[2], energies[2]), xrfcs[7]);
	fprintf(stdout,"Au-L3M5   %-10.4f      %-10.4f    %-10.4f\n",energies[3], CS_FluorLine_Kissel_Nonradiative_Cascade(Z[3], lines[3], energies[3]), xrfcs[8]);
	fprintf(stdout,"Pb-M5N6   %-10.4f      %-10.4f    %-10.4f\n",energies[4], CS_FluorLine_Kissel_Nonradiative_Cascade(Z[4], lines[4], energies[4]), xrfcs[9]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"XRF production cross sections with radiative cascade (cm2/g)\n");
	fprintf(stdout,"Line      Energy(keV)     Classic       CUDA\n");
	fprintf(stdout,"Ne-KL2    %-10.4f      %-10.4f    %-10.4f\n",energies[0], CS_FluorLine_Kissel_Radiative_Cascade(Z[0], lines[0], energies[0]), xrfcs[10]);
	fprintf(stdout,"P-KL3     %-10.4f      %-10.4f    %-10.4f\n",energies[1], CS_FluorLine_Kissel_Radiative_Cascade(Z[1], lines[1], energies[1]), xrfcs[11]);
	fprintf(stdout,"Fe-KM3    %-10.4f      %-10.4f    %-10.4f\n",energies[2], CS_FluorLine_Kissel_Radiative_Cascade(Z[2], lines[2], energies[2]), xrfcs[12]);
	fprintf(stdout,"Au-L3M5   %-10.4f      %-10.4f    %-10.4f\n",energies[3], CS_FluorLine_Kissel_Radiative_Cascade(Z[3], lines[3], energies[3]), xrfcs[13]);
	fprintf(stdout,"Pb-M5N6   %-10.4f      %-10.4f    %-10.4f\n",energies[4], CS_FluorLine_Kissel_Radiative_Cascade(Z[4], lines[4], energies[4]), xrfcs[14]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"XRF production cross sections without cascade (cm2/g)\n");
	fprintf(stdout,"Line      Energy(keV)     Classic       CUDA\n");
	fprintf(stdout,"Ne-KL2    %-10.4f      %-10.4f    %-10.4f\n",energies[0], CS_FluorLine_Kissel_no_Cascade(Z[0], lines[0], energies[0]), xrfcs[15]);
	fprintf(stdout,"P-KL3     %-10.4f      %-10.4f    %-10.4f\n",energies[1], CS_FluorLine_Kissel_no_Cascade(Z[1], lines[1], energies[1]), xrfcs[16]);
	fprintf(stdout,"Fe-KM3    %-10.4f      %-10.4f    %-10.4f\n",energies[2], CS_FluorLine_Kissel_no_Cascade(Z[2], lines[2], energies[2]), xrfcs[17]);
	fprintf(stdout,"Au-L3M5   %-10.4f      %-10.4f    %-10.4f\n",energies[3], CS_FluorLine_Kissel_no_Cascade(Z[3], lines[3], energies[3]), xrfcs[18]);
	fprintf(stdout,"Pb-M5N6   %-10.4f      %-10.4f    %-10.4f\n",energies[4], CS_FluorLine_Kissel_no_Cascade(Z[4], lines[4], energies[4]), xrfcs[19]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"XRF production cross sections using jump approximation(cm2/g)\n");
	fprintf(stdout,"Line      Energy(keV)     Classic       CUDA\n");
	fprintf(stdout,"Ne-KL2    %-10.4f      %-10.4f    %-10.4f\n",energies[0], CS_FluorLine(Z[0], lines[0], energies[0]), xrfcs[20]);
	fprintf(stdout,"P-KL3     %-10.4f      %-10.4f    %-10.4f\n",energies[1], CS_FluorLine(Z[1], lines[1], energies[1]), xrfcs[21]);
	fprintf(stdout,"Fe-KM3    %-10.4f      %-10.4f    %-10.4f\n",energies[2], CS_FluorLine(Z[2], lines[2], energies[2]), xrfcs[22]);
	fprintf(stdout,"Au-L3M5   %-10.4f      %-10.4f    %-10.4f\n",energies[3], CS_FluorLine(Z[3], lines[3], energies[3]), xrfcs[23]);
	fprintf(stdout,"Pb-M5N6   %-10.4f      %-10.4f    %-10.4f\n",energies[4], CS_FluorLine(Z[4], lines[4], energies[4]), xrfcs[24]);

	fprintf(stdout,"\n\n");

	fprintf(stdout,"XRF line energies\n");
	fprintf(stdout,"Line      Classic   CUDA\n");
	fprintf(stdout,"Ne-KL2    %8f %f\n",LineEnergy(10,lines[0]), line_energies[0]);
	fprintf(stdout,"P-KL3     %8f %f\n",LineEnergy(15,lines[1]), line_energies[1]);
	fprintf(stdout,"Fe-KM3    %8f %f\n",LineEnergy(26,lines[2]), line_energies[2]);
	fprintf(stdout,"Au-L3M5   %8f %f\n",LineEnergy(79,lines[3]), line_energies[3]);
	fprintf(stdout,"Pb-M5N6   %8f %f\n",LineEnergy(82,lines[4]), line_energies[4]);

	fprintf(stdout,"\n\n");

}
