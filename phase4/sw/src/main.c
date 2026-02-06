
#include "platform.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_types.h"
#include <stdint.h>

void PrintReg128(uint32_t *regaddr);
void PrintReg32(uint32_t *regaddr);

//RSA 1 bit
uint32_t *go_p = (uint32_t *)(XPAR_RSA_APB_0_BASEADDR+48);
volatile uint32_t *ready_p =(uint32_t *)(XPAR_RSA_APB_0_BASEADDR + 52);

// RSA 128bits
uint32_t *rsa_input =(uint32_t *)(XPAR_RSA_APB_0_BASEADDR+0);
uint32_t *exp_in = (uint32_t *)(XPAR_RSA_APB_0_BASEADDR+16);
uint32_t *mod_in = (uint32_t *)(XPAR_RSA_APB_0_BASEADDR+32);
uint32_t *rsa_result = (uint32_t *)(XPAR_RSA_APB_0_BASEADDR+56);

// Booth 32 bits
uint32_t *booth_a = (uint32_t *)(XPAR_BOOTH_MULT_0_BASEADDR + 0);
uint32_t *booth_b = (uint32_t *)(XPAR_BOOTH_MULT_0_BASEADDR + 4);
uint32_t *booth_product = (uint32_t *)(XPAR_BOOTH_MULT_0_BASEADDR + 8);

// Filter 32 Bits
uint32_t *filter_input = (uint32_t *)(XPAR_MEDIANFILTER_0_BASEADDR + 0);
uint32_t *filter_sorted = (uint32_t *)(XPAR_MEDIANFILTER_0_BASEADDR + 4);
uint32_t *filter_median = (uint32_t *)(XPAR_MEDIANFILTER_0_BASEADDR + 8);

int main()
{
    init_platform();

    // Feed Data
    rsa_input[0] = 0x17401028;
    rsa_input[1] = 0x52401028;
	rsa_input[2] = 0x02401028;
	rsa_input[3] = 0x01301228;
	xil_printf("RSA Data In = ");
	PrintReg128(rsa_input);

	exp_in[0] = 0x00000204;
	exp_in[1] = 0x01000119;
	exp_in[2] = 0x03200204;
	exp_in[3] = 0x00001500;
	xil_printf("RSA Exp In = ");
	PrintReg128(exp_in);

	mod_in[0] = 0x00006015;
	mod_in[1] = 0x70108027;
	mod_in[2] = 0x00003023;
	mod_in[3] = 0x00001027;
	xil_printf("RSA Mod In = ");
	PrintReg128(mod_in);

	// Set go and wait for data to be done
	xil_printf("Calculation Start!\n\r");
	*go_p = 1;
	
	while(*ready_p != 1);
	xil_printf("Calculation Done!\n\r");
	xil_printf("RSA Result = ");
	PrintReg128(rsa_result);

	filter_input[0] = 0x4c966f04;
	xil_printf("Filter Input = ");
	PrintReg32(filter_input);
	
	// Expect fc966440
	xil_printf("Filter Sorted = ");
	PrintReg32(filter_sorted);
	
	// Expect 6
	xil_printf("Filter Mid = ");
	PrintReg32(filter_median);

	*booth_a = 0x54;
	xil_printf("Booth a = ");
	PrintReg32(booth_a);
	
	*booth_b = 0x12;
	xil_printf("Booth b = ");
	PrintReg32(booth_b);
	
	// Expect 05e8
	xil_printf("Booth product = ");
	PrintReg32(booth_product);

    cleanup_platform();
    return 0;
}

void PrintReg32(uint32_t *regaddr){
	xil_printf("0x");
	xil_printf("%0x", *(regaddr));
	xil_printf("\n\r");
}

void PrintReg128(uint32_t *regaddr){
	xil_printf("0x");
	for (int i = 3; i >= 0 ; i--){
		xil_printf("%0x", *(regaddr+i));
	}
	xil_printf("\n\r");
}
