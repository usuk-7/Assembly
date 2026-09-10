# Chapter 2. x86 Processor Architecture

## 2.1 General Concepts

### 2.1.1 Basic Microcomputer Design
- **CPU** = Registers + Clock + Control Unit(CU) + Arithmetic Logic Unit(ALU)
  - Clock: 내부 동작 동기화
  - CU: 명령어 실행 순서 조정
  - ALU: 산술(+,-)·논리(AND,OR,NOT) 연산
- **Memory storage unit**: 실행 중인 프로그램의 명령어/데이터 저장. 실행 전 프로그램은 반드시 메모리로 복사되어야 함
- **Bus 종류**

  | Bus | 역할 |
  |---|---|
  | Data bus | CPU ↔ 메모리 명령어/데이터 전송 |
  | I/O bus | CPU ↔ 입출력 장치 데이터 전송 |
  | Control bus | 모든 장치의 동작을 이진 신호로 동기화 |
  | Address bus | 전송할 명령어/데이터의 주소 저장 |

- **Clock cycle**: 클럭 펄스 1회의 시간(클럭 속도의 역수). 예) 1GHz → 1클럭 = 1ns. 명령어 1개 실행에 최소 1클럭 필요(일부는 50클럭 이상)
- **Wait states**: CPU·버스·메모리 속도 차이로 생기는 대기용 빈 클럭

### 2.1.2 Instruction Execution Cycle
5단계 → 단순화하면 **Fetch → Decode → Execute**

| 단계 | 내용 |
|---|---|
| 1. Fetch | instruction queue에서 명령어를 가져오고, instruction pointer 증가 |
| 2. Decode | 이진 비트 패턴을 분석해 operand 존재 여부 파악 |
| 3. Fetch operands | 레지스터/메모리에서 operand 값을 가져옴 |
| 4. Execute | operand로 명령어 실행, 상태 플래그(Zero/Carry/Overflow 등) 갱신 |
| 5. Store | 출력 operand에 결과 저장 |

예시(`MOV AX,1234h` = `B8 34 12`, IP=1000부터 시작)
```
1000: B8         → opcode fetch, MOV AX,imm16으로 해독, 2바이트 operand 필요 확인, IP→1001
1001: 34         → operand 하위 바이트 fetch, IP→1002
1002: 12         → operand 상위 바이트 fetch, IP→1003
Execute          → AX ← 1234h
```

### 2.1.3 Reading from Memory
메모리 읽기는 레지스터 접근보다 훨씬 느림. 값 1개 읽기 = 4단계(보통 각 1클럭)
1. 읽을 주소를 address bus에 올림
2. RD(read) 핀 assert
3. 메모리 칩 응답까지 1클럭 대기
4. data bus의 값을 destination operand로 복사

**Cache**: 최근/향후 자주 쓸 명령어·데이터를 저장하는 고속 메모리
- Cache hit / cache miss
- Level-1(CPU 내장) / Level-2(고속 버스로 연결, L1보다 느림)
- Cache = SRAM(고가, refresh 불필요) / 일반 메모리 = DRAM(저가, 지속 refresh 필요)

### 2.1.4 Loading and Executing a Program
프로그램 실행 = OS의 program loader가 담당

파일 검색 → 파일 정보(크기/위치) 확인 → 메모리에 적재(descriptor table 기록) → entry point부터 실행 시작(= **process**, process ID 부여) → 실행 중 자원 요청 관리 → 종료 시 메모리에서 제거

---

## 2.2 32-Bit x86 Processors

### 2.2.1 Modes of Operation

| 모드 | 메모리 한계 | 특징 | 대표 OS/사례 |
|---|---|---|---|
| **Real-Address Mode** | 1MB | 하드웨어 직접 접근 가능, 프로그램 1개만 실행 | MS-DOS, Windows 95/98 부팅 |
| **Protected Mode** | 4GB/process | 프로그램별 segment로 메모리 보호, 다중 실행 | MS-Windows, Linux |
| **Virtual-8086 Mode** | 1MB(가상) | protected mode 안에서 real-mode 소프트웨어를 안전하게 실행 | Windows NT/2000/XP의 Command 창 |
| **System Management Mode(SMM)** | - | 전원 관리·보안 기능, OS 몰래 SMI로 진입해 처리 후 복귀 | 제조사가 커스터마이징 |

### 2.2.2 Basic Execution Environment
- **Address space**: protected mode 4GB linear(=주소 지정 가능 범위), P6부터 extended physical addressing으로 시스템 전체 최대 64GB 물리 메모리 지원(process 개별 한도는 여전히 4GB)

**레지스터 구성(Figure 2-3)**
- General-purpose(32bit) 8개: EAX, EBX, ECX, EDX, EBP, ESP, ESI, EDI
- Segment(16bit) 6개: CS, SS, DS, ES, FS, GS
- EFLAGS(상태 플래그), EIP(instruction pointer)

**레지스터 겹침 구조**: EAX(32) ⊃ AX(16) ⊃ AH/AL(8+8) — EBX/ECX/EDX도 동일. ESI/EDI/EBP/ESP는 32/16bit 이름만 존재(8bit 없음)

**특수 용도**

| 레지스터 | 용도 |
|---|---|
| EAX | 곱셈/나눗셈 자동 사용 (extended accumulator) |
| ECX | loop counter로 자동 사용 |
| ESP | 스택 주소 지정 (extended stack pointer) |
| ESI, EDI | 고속 메모리 전송 (source/destination index) |
| EBP | 함수 매개변수·지역변수 참조용 (frame pointer) |

**Segment registers**: CS(코드)·DS(데이터)·SS(스택)·ES/FS/GS(추가 데이터) — real mode에선 base address, protected mode에선 descriptor table 포인터

**EIP**: 다음 실행할 명령어 주소. JMP/CALL/RET/조건분기 명령어가 값을 바꿔 분기(branch) 발생시킴

**EFLAGS**
- Control flags: CPU 동작 제어 (예: Direction flag, Interrupt flag)
- Status flags

  | Flag | Set 조건 |
  |---|---|
  | Carry(CF) | unsigned 결과가 destination에 담기지 못할 만큼 큼 |
  | Overflow(OF) | signed 결과가 너무 크거나 작음 |
  | Sign(SF) | 결과가 음수 |
  | Zero(ZF) | 결과가 0 |
  | Auxiliary Carry(AC) | bit3→bit4 자리올림 발생 |
  | Parity(PF) | 결과 최하위 바이트의 1비트 개수가 짝수 |

**MMX / XMM / FPU**
- MMX: 64bit 레지스터 8개, SIMD 지원, 실제로는 FPU 레지스터의 alias
- XMM: 128bit 레지스터 8개, streaming SIMD extension용
- FPU: 80bit 데이터 레지스터 ST(0)~ST(7) 8개 + 48bit 포인터 레지스터 2개 + 16bit 제어 레지스터 3종 + Opcode register. Intel486부터 메인 프로세서에 통합

### 2.2.3 x86 Memory Management
- **Real-address mode**: 00000~FFFFF(1MB), 한 번에 1개 프로그램만, interrupt로 순간 중단 가능, 하드웨어 직접 접근 허용
- **Protected mode**: process마다 최대 4GB 할당, 프로그램 간 메모리 침범 방지
- **Virtual-8086 mode**: protected mode 안에서 1MB짜리 가상 8086 machine을 여러 개 동시 생성(서로 격리)

---

## 2.3 64-Bit x86-64 Processors

### 핵심 특징
1. x86 명령어 집합과 하위 호환
2. 주소 64bit → 2^64 byte 가상 주소 공간(현재는 하위 48bit만 사용)
3. 64bit general-purpose register 사용 가능
4. x86보다 8개 더 많은 범용 레지스터
5. 48bit 물리 주소 공간 → 최대 256TB RAM
- native 64bit 모드에서는 16bit real mode / virtual-8086 mode 미지원
- 대표 프로세서: Intel Xeon, Core i5/i7 / AMD Opteron, Athlon 64 (참고: IA-64/Itanium은 x86과 명령어 집합이 완전히 다름)

### 2.3.1 64-Bit Operation Modes (IA-32e)
| Mode | 설명 |
|---|---|
| Compatibility Mode | 기존 16/32bit 앱을 재컴파일 없이 실행(단, Win16·DOS 앱은 64bit Windows에서 불가) |
| 64-Bit Mode | 64bit linear address space 사용, 64bit Windows의 native mode |

### 2.3.2 Basic 64-Bit Execution Environment

| 항목 | 32-bit | 64-bit |
|---|---|---|
| 주소 크기 | 32bit | 48bit(실제)/64bit(이론) |
| General-purpose 레지스터 | 8개 | 16개 |
| Floating-point 레지스터 | 80bit × 8 | 80bit × 8(동일) |
| 상태 플래그 레지스터 | EFLAGS(32bit) | RFLAGS(64bit, 하위32bit만 사용) |
| Instruction pointer | EIP(32bit) | RIP(64bit) |
| MMX 레지스터 | 64bit × 8 | 64bit × 8(동일) |
| XMM 레지스터 | 128bit × 8 | 128bit × 16 |

- 기본 operand 크기는 32bit(레지스터 8개)이며, **REX prefix**를 붙이면 64bit로 확장 + R8~R15 추가되어 총 16개 사용 가능

  | Operand 크기 | 사용 가능 레지스터 |
  |---|---|
  | 8bit | AL,BL,CL,DL,DIL,SIL,BPL,SPL,R8L~R15L |
  | 16bit | AX,BX,CX,DX,DI,SI,BP,SP,R8W~R15W |
  | 32bit | EAX,EBX,ECX,EDX,EDI,ESI,EBP,ESP,R8D~R15D |
  | 64bit | RAX,RBX,RCX,RDX,RDI,RSI,RBP,RSP,R8~R15 |

- 64bit 모드에서는 한 명령어가 high-byte 레지스터(AH,BH,CH,DH)와 새 byte 레지스터(DIL 등)의 low byte를 동시에 접근 불가
- status flag는 32bit/64bit 모드에서 동일

---

## 2.4 Components of a Typical x86 Computer

### 2.4.1 Motherboard
**필수 구성요소**: CPU 소켓, 메모리 슬롯(SIMM/DIMM), BIOS 칩, CMOS RAM(배터리), 저장장치 커넥터, USB, 키보드/마우스 포트, PCI bus 커넥터
**선택 구성요소**: 사운드 프로세서, 병렬/직렬 포트, 네트워크 어댑터, AGP bus(고속 비디오카드)

**지원 프로세서(Support processors)**

| 칩 | 역할 |
|---|---|
| FPU | 부동소수점/확장 정수 연산 |
| Clock Generator(8284/82C284) | CPU-시스템 동기화 |
| PIC(8259A) | 하드웨어 장치 external interrupt 처리 |
| Interval Timer(8253) | 초당 18.2회 인터럽트, 날짜/시계 갱신, 메모리 refresh |
| Parallel Port(8255) | 프린터 등과 데이터 송수신 |

**Bus**: PCI(장치↔CPU 연결) → PCI Express(양방향 serial, lane 단위, 고속)

**Chipset 예시 — Intel P965 Express**
- Fast Memory Access(MCH, 800MHz dual-channel DDR2)
- I/O Controller Hub(ICH8/R/DH) — Matrix Storage Technology로 다중 SATA 지원
- 다중 USB/PCIe 슬롯, 네트워킹, Quiet System Technology
- HD 오디오 칩

### 2.4.2 Memory 종류

| 종류 | 특징 |
|---|---|
| ROM | 영구 기록, 지울 수 없음 |
| EPROM | 자외선으로 지우고 재프로그래밍 가능 |
| DRAM | main memory, 저렴, 매 ms마다 refresh 필요 |
| SRAM | 비쌈, refresh 불필요, CPU cache에 사용 |
| VRAM | dual-ported, 비디오 데이터 저장 |
| CMOS RAM | 배터리로 시스템 설정 정보 유지 |

---

## 2.5 Input–Output System

### 2.5.1 Levels of I/O Access
3가지 접근 레벨: **High-level language functions**(portable) → **Operating system**(API 통해 호출) → **BIOS**(하드웨어와 직접 통신하는 저수준 서브루틴)

**Device drivers**: OS-하드웨어 간 직접 통신 담당. 장치 연결 전/후 설치 가능

**화면에 문자열 출력 예시(Figure 2-7, 5단계)**
```
Application program(Lv3) → HLL 라이브러리 함수 호출
        ↓
OS function(Lv2) → 문자 ASCII코드/색상 전달하며 BIOS 서브루틴 호출
        ↓
BIOS function(Lv1) → 문자→폰트 매핑, 비디오 컨트롤러 하드웨어 포트로 전송
        ↓
Hardware(Lv0) → 타이밍 신호로 raster scanning, 화면 표시
```

**Programming at Multiple Levels(Figure 2-8)**

| Level | 내용 | Trade-off |
|---|---|---|
| Lv3 Library | 일반 텍스트/파일 I/O | 이식성 최고 |
| Lv2 OS | API로 텍스트/그래픽 I/O | 이식성 높음, 여러 계층 거쳐 느림 |
| Lv1 BIOS | 색상/그래픽/사운드/키보드/디스크 제어 | 시스템마다 결과 다를 수 있음, Lv2보다 빠름 |
| Lv0 Hardware | 하드웨어 포트 직접 송수신 | not portable, 하드웨어 최대 속도 |

핵심 trade-off: **제어(control) vs 이식성(portability)**. 예) WAV 재생 시 OS레벨은 장치 종류 몰라도 됨 / BIOS레벨은 카드 종류 조회 / 하드웨어레벨은 카드별로 세밀 튜닝

---
