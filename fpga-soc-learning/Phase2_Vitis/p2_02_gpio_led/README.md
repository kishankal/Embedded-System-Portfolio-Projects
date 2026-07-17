// Step 1: LookupConfig — find hardware
Config = XPeripheral_LookupConfig(BASEADDR);

// Step 2: CfgInitialize — connect driver to hardware
XPeripheral_CfgInitialize(&instance, Config, Config->BaseAddress);

// Step 3: Configure — set options specific to peripheral
XPeripheral_SetOptions(&instance, OPTIONS);

// Step 4: Enable — turn it on
XPeripheral_Enable(&instance);

// Step 5: If interrupt needed — register ISR with GIC
XScuGic_Connect(&gic, IRQ_ID, isr_function, &instance);
XScuGic_Enable(&gic, IRQ_ID);