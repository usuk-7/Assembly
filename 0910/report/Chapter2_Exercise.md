# 0910 과제 — Chapter 2 Review Questions 풀이

**1.** In 32-bit mode, aside from the stack pointer (ESP), what other register points to variables on the stack?

스택 위 변수를 가리키는 레지스터는 ESP 외에 EBP(extended frame pointer)도 있다. EBP는 함수 매개변수와 지역변수를 참조할 때 사용한다.
→ **EBP**

**2.** Name at least four CPU status flags.

상태 플래그(status flags)는 총 6개: Carry(CF), Zero(ZF), Sign(SF), Overflow(OF), Auxiliary Carry(AF), Parity(PF).
→ **Carry, Zero, Sign, Overflow** (4개 예시)

**3.** Which flag is set when the result of an unsigned arithmetic operation is too large to fit into the destination?

→ **Carry Flag (CF)**

**4.** Which flag is set when the result of a signed arithmetic operation is either too large or too small to fit into the destination?

→ **Overflow Flag (OF)**

**5.** (True/False): When a register operand size is 32 bits and the REX prefix is used, the R8D register is available for programs to use.

REX 프리픽스 사용 시 32비트 모드에서 R8~R15의 32비트 이름인 R8D~R15D를 사용할 수 있다.
→ **True**

**6.** Which flag is set when an arithmetic or logical operation generates a negative result?

→ **Sign Flag (SF)**

**7.** Which part of the CPU performs floating-point arithmetic?

→ **FPU (Floating-Point Unit)**

**8.** On a 32-bit processor, how many bits are contained in each floating-point data register?

FPU의 데이터 레지스터 ST(0)~ST(7)은 각각 80비트이다.
→ **80비트**

**9.** (True/False): The x86-64 instruction set is backward-compatible with the x86 instruction set.

→ **True**

**10.** (True/False): In current 64-bit chip implementations, all 64 bits are used for addressing.

현재 구현에서는 64비트 중 하위 48비트만 주소 지정에 사용된다.
→ **False**

**11.** (True/False): The Itanium instruction set is completely different from the x86 instruction set.

Itanium(IA-64) 명령어 집합은 x86 및 x86-64와 완전히 다르다.
→ **True**

**12.** (True/False): Static RAM is usually less expensive than dynamic RAM.

SRAM은 캐시에 쓰이며 고속이지만 가격이 비싸고, DRAM은 느리지만 저렴하다.
→ **False**

**13.** (True/False): The 64-bit RDI register is available when the REX prefix is used.

REX 프리픽스 사용 시 64비트 레지스터(RAX~R15 포함 RDI)를 사용할 수 있다.
→ **True**

**14.** (True/False): In native 64-bit mode, you can use 16-bit real mode, but not the virtual-8086 mode.

네이티브 64비트 모드에서는 16비트 real mode와 virtual-8086 모드 둘 다 지원하지 않는다.
→ **False**

**15.** (True/False): The x86-64 processors have 4 more general-purpose registers than the x86 processors.

x86-64는 x86보다 범용 레지스터가 8개 더 많다(8개 → 16개).
→ **False**

**16.** (True/False): The 64-bit version of Microsoft Windows does not support virtual-8086 mode.

64비트 Windows는 virtual DOS machine(virtual-8086) 서브시스템을 지원하지 않는다.
→ **True**

**17.** (True/False): DRAM can only be erased using ultraviolet light.

자외선으로 지우는 것은 EPROM이며, DRAM은 계속 refresh(재충전)해야 내용을 유지하는 메모리이다.
→ **False**

**18.** (True/False): In 64-bit mode, you can use up to eight floating-point registers.

64비트 모드에서도 80비트 부동소수점 레지스터는 8개(ST(0)~ST(7))이다.
→ **True**

**19.** (True/False): A bus is a plastic cable that is attached to the motherboard at both ends, but does not sit directly on the motherboard.

버스는 메인보드에 직접 새겨진(etched) 병렬 전선 다발이며, 플라스틱 케이블이 아니다.
→ **False**

**20.** (True/False): CMOS RAM is the same as static RAM, meaning that it holds its value without any extra power or refresh cycles.

CMOS RAM은 배터리로 전원을 공급받아야 내용을 유지하며, 캐시에 쓰이는 SRAM과는 다른 메모리이다.
→ **False**

**21.** (True/False): PCI connectors are used for graphics cards and sound cards.

→ **True**

**22.** (True/False): The 8259A is a controller that handles external interrupts from hardware devices.

→ **True**

**23.** (True/False): The acronym PCI stands for programmable component interface.

PCI는 Peripheral Component Interconnect(주변장치 구성요소 상호연결)의 약자이다.
→ **False**

**24.** (True/False): VRAM stands for virtual random access memory.

VRAM은 Video RAM(비디오 데이터를 저장하는 듀얼 포트 메모리)의 약자이다.
→ **False**

**25.** At which level(s) can an assembly language program manipulate input/output?

어셈블리 프로그램은 4단계 모두에서 I/O를 다룰 수 있다: Level 3(라이브러리 함수), Level 2(운영체제 함수), Level 1(BIOS 함수), Level 0(하드웨어 포트 직접 접근).
→ **모든 레벨 (Level 0 ~ Level 3)**

**26.** Why do game programs often send their sound output directly to the sound card's hardware ports?

게임 프로그램은 메모리와 I/O 사용이 매우 많아 성능을 최대로 끌어내야 한다. OS나 BIOS 계층을 거치면 각 계층을 통과하는 오버헤드 때문에 속도가 느려지므로, 하드웨어를 직접 제어(Level 0)하면 이식성은 떨어지지만 하드웨어가 허용하는 최대 속도로 실행할 수 있기 때문이다.
→ **속도(성능) 최적화를 위해 OS/BIOS 오버헤드를 건너뛰고 하드웨어를 직접 제어하기 위해서**
