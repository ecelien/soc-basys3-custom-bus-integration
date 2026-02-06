
#include "platform.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xil_types.h"

void PrintReg128(uint32_t *regaddr);

#define INDATA_OFFSET 0
#define INEXP_OFFSET 4
#define INMOD_OFFSET 8
#define DS_OFFSET 12
#define READY_OFFSET 13
#define CYPHER_OFFSET 14

//1 bit
uint32_t *go_p = (uint32_t *)XPAR_RSA_APB_0_BASEADDR+DS_OFFSET;
uint32_t *ready_p =(uint32_t *)XPAR_RSA_APB_0_BASEADDR + READY_OFFSET;

//128 bytes
uint32_t *data_in =(uint32_t *)XPAR_RSA_APB_0_BASEADDR+INDATA_OFFSET;
uint32_t *exp_in = (uint32_t *)XPAR_RSA_APB_0_BASEADDR+INEXP_OFFSET;
uint32_t *mod_in = (uint32_t *)XPAR_RSA_APB_0_BASEADDR+INMOD_OFFSET;
uint32_t *cipher = (uint32_t *)XPAR_RSA_APB_0_BASEADDR+CYPHER_OFFSET;



int main()
{
    init_platform();

    // Feed Data
    data_in[0] = 0x17401028;
    data_in[1] = 0x52401028;
	data_in[2] = 0x02401028;
	data_in[3] = 0x01301228;
	xil_printf("Data In = ");
	PrintReg128(data_in);

	exp_in[0] = 0x00000204;
	exp_in[1] = 0x01000119;
	exp_in[2] = 0x03200204;
	exp_in[3] = 0x00001500;
	xil_printf("Exp In = ");
	PrintReg128(exp_in);

	mod_in[0] = 0x00006015;
	mod_in[1] = 0x70108027;
	mod_in[2] = 0x00003023;
	mod_in[3] = 0x00001027;
	xil_printf("Mod In = ");
	PrintReg128(mod_in);

	// Set go and wait for data to be done
	xil_printf("Calculation Start!\n\r");
	*go_p = 1;

	//while(*ready_p != 1);
	xil_printf("Calculation Done!\n\r");
	xil_printf("Cypher = ");
	PrintReg128(cipher);

    cleanup_platform();
    return 0;
}

void PrintReg128(uint32_t *regaddr){
	xil_printf("0x");
	for (int i = 3; i >= 0 ; i--){
		xil_printf("%0x", *(regaddr+i));
	}
	xil_printf("\n\r");
}

