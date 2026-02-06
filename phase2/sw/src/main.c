
#include "platform.h"
#include "xparameters.h"
#include "xil_printf.h"
#include "xbasic_types.h"

void PrintReg128(Xuint32 *regaddr);

Xuint32 *baseaddr_p = (Xuint32 *)XPAR_RSA_AXI_LITE_0_BASEADDR;

//1 bit
Xuint32 *go_p = (Xuint32 *)XPAR_RSA_AXI_LITE_0_BASEADDR;
volatile Xuint32 *ready_p =(Xuint32 *)XPAR_RSA_AXI_LITE_0_BASEADDR + 1;

//128 bytes
Xuint32 *data_in =(Xuint32 *)XPAR_RSA_AXI_LITE_0_BASEADDR+2;
Xuint32 *exp_in = (Xuint32 *)XPAR_RSA_AXI_LITE_0_BASEADDR+6;
Xuint32 *mod_in = (Xuint32 *)XPAR_RSA_AXI_LITE_0_BASEADDR+10;
Xuint32 *cipher = (Xuint32 *)XPAR_RSA_AXI_LITE_0_BASEADDR+14;


int main()
{
    init_platform();

    xil_printf("Data In = 0x01301228024010285240102817401028\n\r");
    // Feed Data
    data_in[0] = 0x17401028;
    data_in[1] = 0x52401028;
	data_in[2] = 0x02401028;
	data_in[3] = 0x01301228;

	xil_printf("Exp In = 0x00001500032002040100011900000204\n\r");
	exp_in[0] = 0x00000204;
	exp_in[1] = 0x01000119;
	exp_in[2] = 0x03200204;
	exp_in[3] = 0x00001500;

	xil_printf("Mod In = 0x00001027000030237010802700006015\n\r");
	mod_in[0] = 0x00006015;
	mod_in[1] = 0x70108027;
	mod_in[2] = 0x00003023;
	mod_in[3] = 0x00001027;

	// Set go and wait for data to be done
	xil_printf("Calculation Start!\n\r");
	*go_p = 1;
	while(*ready_p != 1);
	xil_printf("Calculation Done!\n\r");
	xil_printf("Cypher = ");
	PrintReg128(cipher);

    cleanup_platform();
    return 0;
}

void PrintReg128(Xuint32 *regaddr){
	xil_printf("0x");
	for (int i = 3; i >= 0 ; i--){
		xil_printf("%0x", *(regaddr+i));
	}
	xil_printf("\n\r");
}

