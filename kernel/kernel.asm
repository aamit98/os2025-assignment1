
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	8be70713          	addi	a4,a4,-1858 # 80008910 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	0dc78793          	addi	a5,a5,220 # 80006140 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc27f>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dca78793          	addi	a5,a5,-566 # 80000e78 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d8:	57fd                	li	a5,-1
    800000da:	83a9                	srli	a5,a5,0xa
    800000dc:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000e0:	47bd                	li	a5,15
    800000e2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e6:	00000097          	auipc	ra,0x0
    800000ea:	f36080e7          	jalr	-202(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ee:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f2:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f6:	30200073          	mret
}
    800000fa:	60a2                	ld	ra,8(sp)
    800000fc:	6402                	ld	s0,0(sp)
    800000fe:	0141                	addi	sp,sp,16
    80000100:	8082                	ret

0000000080000102 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000102:	715d                	addi	sp,sp,-80
    80000104:	e486                	sd	ra,72(sp)
    80000106:	e0a2                	sd	s0,64(sp)
    80000108:	fc26                	sd	s1,56(sp)
    8000010a:	f84a                	sd	s2,48(sp)
    8000010c:	f44e                	sd	s3,40(sp)
    8000010e:	f052                	sd	s4,32(sp)
    80000110:	ec56                	sd	s5,24(sp)
    80000112:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000114:	04c05663          	blez	a2,80000160 <consolewrite+0x5e>
    80000118:	8a2a                	mv	s4,a0
    8000011a:	84ae                	mv	s1,a1
    8000011c:	89b2                	mv	s3,a2
    8000011e:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000120:	5afd                	li	s5,-1
    80000122:	4685                	li	a3,1
    80000124:	8626                	mv	a2,s1
    80000126:	85d2                	mv	a1,s4
    80000128:	fbf40513          	addi	a0,s0,-65
    8000012c:	00002097          	auipc	ra,0x2
    80000130:	3ca080e7          	jalr	970(ra) # 800024f6 <either_copyin>
    80000134:	01550c63          	beq	a0,s5,8000014c <consolewrite+0x4a>
      break;
    uartputc(c);
    80000138:	fbf44503          	lbu	a0,-65(s0)
    8000013c:	00000097          	auipc	ra,0x0
    80000140:	780080e7          	jalr	1920(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000144:	2905                	addiw	s2,s2,1
    80000146:	0485                	addi	s1,s1,1
    80000148:	fd299de3          	bne	s3,s2,80000122 <consolewrite+0x20>
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4a>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8c650513          	addi	a0,a0,-1850 # 80010a50 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8b648493          	addi	s1,s1,-1866 # 80010a50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	94690913          	addi	s2,s2,-1722 # 80010ae8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	14a080e7          	jalr	330(ra) # 80002312 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	e7e080e7          	jalr	-386(ra) # 80002054 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	28e080e7          	jalr	654(ra) # 800024a0 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	82a50513          	addi	a0,a0,-2006 # 80010a50 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	81450513          	addi	a0,a0,-2028 # 80010a50 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72b23          	sw	a5,-1930(a4) # 80010ae8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	55e080e7          	jalr	1374(ra) # 800007ea <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54c080e7          	jalr	1356(ra) # 800007ea <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	540080e7          	jalr	1344(ra) # 800007ea <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	536080e7          	jalr	1334(ra) # 800007ea <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	78450513          	addi	a0,a0,1924 # 80010a50 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	25a080e7          	jalr	602(ra) # 8000254c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	75650513          	addi	a0,a0,1878 # 80010a50 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	73270713          	addi	a4,a4,1842 # 80010a50 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	70878793          	addi	a5,a5,1800 # 80010a50 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7727a783          	lw	a5,1906(a5) # 80010ae8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6c670713          	addi	a4,a4,1734 # 80010a50 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6b648493          	addi	s1,s1,1718 # 80010a50 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	67a70713          	addi	a4,a4,1658 # 80010a50 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	70f72223          	sw	a5,1796(a4) # 80010af0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	63e78793          	addi	a5,a5,1598 # 80010a50 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7ab23          	sw	a2,1718(a5) # 80010aec <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	6aa50513          	addi	a0,a0,1706 # 80010ae8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	c72080e7          	jalr	-910(ra) # 800020b8 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5f050513          	addi	a0,a0,1520 # 80010a50 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	f7078793          	addi	a5,a5,-144 # 800213e8 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7870713          	addi	a4,a4,-904 # 80000102 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054663          	bltz	a0,80000536 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088b63          	beqz	a7,800004fc <printint+0x60>
    buf[i++] = '-';
    800004ea:	fe040793          	addi	a5,s0,-32
    800004ee:	973e                	add	a4,a4,a5
    800004f0:	02d00793          	li	a5,45
    800004f4:	fef70823          	sb	a5,-16(a4)
    800004f8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fc:	02e05763          	blez	a4,8000052a <printint+0x8e>
    80000500:	fd040793          	addi	a5,s0,-48
    80000504:	00e784b3          	add	s1,a5,a4
    80000508:	fff78913          	addi	s2,a5,-1
    8000050c:	993a                	add	s2,s2,a4
    8000050e:	377d                	addiw	a4,a4,-1
    80000510:	1702                	slli	a4,a4,0x20
    80000512:	9301                	srli	a4,a4,0x20
    80000514:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000518:	fff4c503          	lbu	a0,-1(s1)
    8000051c:	00000097          	auipc	ra,0x0
    80000520:	d60080e7          	jalr	-672(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000524:	14fd                	addi	s1,s1,-1
    80000526:	ff2499e3          	bne	s1,s2,80000518 <printint+0x7c>
}
    8000052a:	70a2                	ld	ra,40(sp)
    8000052c:	7402                	ld	s0,32(sp)
    8000052e:	64e2                	ld	s1,24(sp)
    80000530:	6942                	ld	s2,16(sp)
    80000532:	6145                	addi	sp,sp,48
    80000534:	8082                	ret
    x = -xx;
    80000536:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053a:	4885                	li	a7,1
    x = -xx;
    8000053c:	bf9d                	j	800004b2 <printint+0x16>

000000008000053e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053e:	1101                	addi	sp,sp,-32
    80000540:	ec06                	sd	ra,24(sp)
    80000542:	e822                	sd	s0,16(sp)
    80000544:	e426                	sd	s1,8(sp)
    80000546:	1000                	addi	s0,sp,32
    80000548:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054a:	00010797          	auipc	a5,0x10
    8000054e:	5c07a323          	sw	zero,1478(a5) # 80010b10 <pr+0x18>
  printf("panic: ");
    80000552:	00008517          	auipc	a0,0x8
    80000556:	ac650513          	addi	a0,a0,-1338 # 80008018 <etext+0x18>
    8000055a:	00000097          	auipc	ra,0x0
    8000055e:	02e080e7          	jalr	46(ra) # 80000588 <printf>
  printf(s);
    80000562:	8526                	mv	a0,s1
    80000564:	00000097          	auipc	ra,0x0
    80000568:	024080e7          	jalr	36(ra) # 80000588 <printf>
  printf("\n");
    8000056c:	00008517          	auipc	a0,0x8
    80000570:	b5c50513          	addi	a0,a0,-1188 # 800080c8 <digits+0x88>
    80000574:	00000097          	auipc	ra,0x0
    80000578:	014080e7          	jalr	20(ra) # 80000588 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057c:	4785                	li	a5,1
    8000057e:	00008717          	auipc	a4,0x8
    80000582:	34f72923          	sw	a5,850(a4) # 800088d0 <panicked>
  for(;;)
    80000586:	a001                	j	80000586 <panic+0x48>

0000000080000588 <printf>:
{
    80000588:	7131                	addi	sp,sp,-192
    8000058a:	fc86                	sd	ra,120(sp)
    8000058c:	f8a2                	sd	s0,112(sp)
    8000058e:	f4a6                	sd	s1,104(sp)
    80000590:	f0ca                	sd	s2,96(sp)
    80000592:	ecce                	sd	s3,88(sp)
    80000594:	e8d2                	sd	s4,80(sp)
    80000596:	e4d6                	sd	s5,72(sp)
    80000598:	e0da                	sd	s6,64(sp)
    8000059a:	fc5e                	sd	s7,56(sp)
    8000059c:	f862                	sd	s8,48(sp)
    8000059e:	f466                	sd	s9,40(sp)
    800005a0:	f06a                	sd	s10,32(sp)
    800005a2:	ec6e                	sd	s11,24(sp)
    800005a4:	0100                	addi	s0,sp,128
    800005a6:	8a2a                	mv	s4,a0
    800005a8:	e40c                	sd	a1,8(s0)
    800005aa:	e810                	sd	a2,16(s0)
    800005ac:	ec14                	sd	a3,24(s0)
    800005ae:	f018                	sd	a4,32(s0)
    800005b0:	f41c                	sd	a5,40(s0)
    800005b2:	03043823          	sd	a6,48(s0)
    800005b6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ba:	00010d97          	auipc	s11,0x10
    800005be:	556dad83          	lw	s11,1366(s11) # 80010b10 <pr+0x18>
  if(locking)
    800005c2:	020d9b63          	bnez	s11,800005f8 <printf+0x70>
  if (fmt == 0)
    800005c6:	040a0263          	beqz	s4,8000060a <printf+0x82>
  va_start(ap, fmt);
    800005ca:	00840793          	addi	a5,s0,8
    800005ce:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d2:	000a4503          	lbu	a0,0(s4)
    800005d6:	14050f63          	beqz	a0,80000734 <printf+0x1ac>
    800005da:	4981                	li	s3,0
    if(c != '%'){
    800005dc:	02500a93          	li	s5,37
    switch(c){
    800005e0:	07000b93          	li	s7,112
  consputc('x');
    800005e4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e6:	00008b17          	auipc	s6,0x8
    800005ea:	a5ab0b13          	addi	s6,s6,-1446 # 80008040 <digits>
    switch(c){
    800005ee:	07300c93          	li	s9,115
    800005f2:	06400c13          	li	s8,100
    800005f6:	a82d                	j	80000630 <printf+0xa8>
    acquire(&pr.lock);
    800005f8:	00010517          	auipc	a0,0x10
    800005fc:	50050513          	addi	a0,a0,1280 # 80010af8 <pr>
    80000600:	00000097          	auipc	ra,0x0
    80000604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
    80000608:	bf7d                	j	800005c6 <printf+0x3e>
    panic("null fmt");
    8000060a:	00008517          	auipc	a0,0x8
    8000060e:	a1e50513          	addi	a0,a0,-1506 # 80008028 <etext+0x28>
    80000612:	00000097          	auipc	ra,0x0
    80000616:	f2c080e7          	jalr	-212(ra) # 8000053e <panic>
      consputc(c);
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	c62080e7          	jalr	-926(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000622:	2985                	addiw	s3,s3,1
    80000624:	013a07b3          	add	a5,s4,s3
    80000628:	0007c503          	lbu	a0,0(a5)
    8000062c:	10050463          	beqz	a0,80000734 <printf+0x1ac>
    if(c != '%'){
    80000630:	ff5515e3          	bne	a0,s5,8000061a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000634:	2985                	addiw	s3,s3,1
    80000636:	013a07b3          	add	a5,s4,s3
    8000063a:	0007c783          	lbu	a5,0(a5)
    8000063e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000642:	cbed                	beqz	a5,80000734 <printf+0x1ac>
    switch(c){
    80000644:	05778a63          	beq	a5,s7,80000698 <printf+0x110>
    80000648:	02fbf663          	bgeu	s7,a5,80000674 <printf+0xec>
    8000064c:	09978863          	beq	a5,s9,800006dc <printf+0x154>
    80000650:	07800713          	li	a4,120
    80000654:	0ce79563          	bne	a5,a4,8000071e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4605                	li	a2,1
    80000666:	85ea                	mv	a1,s10
    80000668:	4388                	lw	a0,0(a5)
    8000066a:	00000097          	auipc	ra,0x0
    8000066e:	e32080e7          	jalr	-462(ra) # 8000049c <printint>
      break;
    80000672:	bf45                	j	80000622 <printf+0x9a>
    switch(c){
    80000674:	09578f63          	beq	a5,s5,80000712 <printf+0x18a>
    80000678:	0b879363          	bne	a5,s8,8000071e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4605                	li	a2,1
    8000068a:	45a9                	li	a1,10
    8000068c:	4388                	lw	a0,0(a5)
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	e0e080e7          	jalr	-498(ra) # 8000049c <printint>
      break;
    80000696:	b771                	j	80000622 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000698:	f8843783          	ld	a5,-120(s0)
    8000069c:	00878713          	addi	a4,a5,8
    800006a0:	f8e43423          	sd	a4,-120(s0)
    800006a4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a8:	03000513          	li	a0,48
    800006ac:	00000097          	auipc	ra,0x0
    800006b0:	bd0080e7          	jalr	-1072(ra) # 8000027c <consputc>
  consputc('x');
    800006b4:	07800513          	li	a0,120
    800006b8:	00000097          	auipc	ra,0x0
    800006bc:	bc4080e7          	jalr	-1084(ra) # 8000027c <consputc>
    800006c0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c2:	03c95793          	srli	a5,s2,0x3c
    800006c6:	97da                	add	a5,a5,s6
    800006c8:	0007c503          	lbu	a0,0(a5)
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d4:	0912                	slli	s2,s2,0x4
    800006d6:	34fd                	addiw	s1,s1,-1
    800006d8:	f4ed                	bnez	s1,800006c2 <printf+0x13a>
    800006da:	b7a1                	j	80000622 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006dc:	f8843783          	ld	a5,-120(s0)
    800006e0:	00878713          	addi	a4,a5,8
    800006e4:	f8e43423          	sd	a4,-120(s0)
    800006e8:	6384                	ld	s1,0(a5)
    800006ea:	cc89                	beqz	s1,80000704 <printf+0x17c>
      for(; *s; s++)
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	d90d                	beqz	a0,80000622 <printf+0x9a>
        consputc(*s);
    800006f2:	00000097          	auipc	ra,0x0
    800006f6:	b8a080e7          	jalr	-1142(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fa:	0485                	addi	s1,s1,1
    800006fc:	0004c503          	lbu	a0,0(s1)
    80000700:	f96d                	bnez	a0,800006f2 <printf+0x16a>
    80000702:	b705                	j	80000622 <printf+0x9a>
        s = "(null)";
    80000704:	00008497          	auipc	s1,0x8
    80000708:	91c48493          	addi	s1,s1,-1764 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070c:	02800513          	li	a0,40
    80000710:	b7cd                	j	800006f2 <printf+0x16a>
      consputc('%');
    80000712:	8556                	mv	a0,s5
    80000714:	00000097          	auipc	ra,0x0
    80000718:	b68080e7          	jalr	-1176(ra) # 8000027c <consputc>
      break;
    8000071c:	b719                	j	80000622 <printf+0x9a>
      consputc('%');
    8000071e:	8556                	mv	a0,s5
    80000720:	00000097          	auipc	ra,0x0
    80000724:	b5c080e7          	jalr	-1188(ra) # 8000027c <consputc>
      consputc(c);
    80000728:	8526                	mv	a0,s1
    8000072a:	00000097          	auipc	ra,0x0
    8000072e:	b52080e7          	jalr	-1198(ra) # 8000027c <consputc>
      break;
    80000732:	bdc5                	j	80000622 <printf+0x9a>
  if(locking)
    80000734:	020d9163          	bnez	s11,80000756 <printf+0x1ce>
}
    80000738:	70e6                	ld	ra,120(sp)
    8000073a:	7446                	ld	s0,112(sp)
    8000073c:	74a6                	ld	s1,104(sp)
    8000073e:	7906                	ld	s2,96(sp)
    80000740:	69e6                	ld	s3,88(sp)
    80000742:	6a46                	ld	s4,80(sp)
    80000744:	6aa6                	ld	s5,72(sp)
    80000746:	6b06                	ld	s6,64(sp)
    80000748:	7be2                	ld	s7,56(sp)
    8000074a:	7c42                	ld	s8,48(sp)
    8000074c:	7ca2                	ld	s9,40(sp)
    8000074e:	7d02                	ld	s10,32(sp)
    80000750:	6de2                	ld	s11,24(sp)
    80000752:	6129                	addi	sp,sp,192
    80000754:	8082                	ret
    release(&pr.lock);
    80000756:	00010517          	auipc	a0,0x10
    8000075a:	3a250513          	addi	a0,a0,930 # 80010af8 <pr>
    8000075e:	00000097          	auipc	ra,0x0
    80000762:	52c080e7          	jalr	1324(ra) # 80000c8a <release>
}
    80000766:	bfc9                	j	80000738 <printf+0x1b0>

0000000080000768 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000768:	1101                	addi	sp,sp,-32
    8000076a:	ec06                	sd	ra,24(sp)
    8000076c:	e822                	sd	s0,16(sp)
    8000076e:	e426                	sd	s1,8(sp)
    80000770:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000772:	00010497          	auipc	s1,0x10
    80000776:	38648493          	addi	s1,s1,902 # 80010af8 <pr>
    8000077a:	00008597          	auipc	a1,0x8
    8000077e:	8be58593          	addi	a1,a1,-1858 # 80008038 <etext+0x38>
    80000782:	8526                	mv	a0,s1
    80000784:	00000097          	auipc	ra,0x0
    80000788:	3c2080e7          	jalr	962(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078c:	4785                	li	a5,1
    8000078e:	cc9c                	sw	a5,24(s1)
}
    80000790:	60e2                	ld	ra,24(sp)
    80000792:	6442                	ld	s0,16(sp)
    80000794:	64a2                	ld	s1,8(sp)
    80000796:	6105                	addi	sp,sp,32
    80000798:	8082                	ret

000000008000079a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007bc:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	34650513          	addi	a0,a0,838 # 80010b18 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
}
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
  push_off();
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>

  if(panicked){
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0d27a783          	lw	a5,210(a5) # 800088d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    for(;;)
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
}
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0a27b783          	ld	a5,162(a5) # 800088d8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	0a273703          	ld	a4,162(a4) # 800088e0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
{
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2b8a0a13          	addi	s4,s4,696 # 80010b18 <uart_tx_lock>
    uart_tx_r += 1;
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	07048493          	addi	s1,s1,112 # 800088d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000870:	00008997          	auipc	s3,0x8
    80000874:	07098993          	addi	s3,s3,112 # 800088e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	826080e7          	jalr	-2010(ra) # 800020b8 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	24a50513          	addi	a0,a0,586 # 80010b18 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	ff27a783          	lw	a5,-14(a5) # 800088d0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	ff873703          	ld	a4,-8(a4) # 800088e0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fe87b783          	ld	a5,-24(a5) # 800088d8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	21c98993          	addi	s3,s3,540 # 80010b18 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fd448493          	addi	s1,s1,-44 # 800088d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fd490913          	addi	s2,s2,-44 # 800088e0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	738080e7          	jalr	1848(ra) # 80002054 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1e648493          	addi	s1,s1,486 # 80010b18 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7bd23          	sd	a4,-102(a5) # 800088e0 <uart_tx_w>
  uartstart();
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
}
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    for(;;)
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    return -1;
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	15c48493          	addi	s1,s1,348 # 80010b18 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
  uartstart();
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
  release(&uart_tx_lock);
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
}
    800009e0:	60e2                	ld	ra,24(sp)
    800009e2:	6442                	ld	s0,16(sp)
    800009e4:	64a2                	ld	s1,8(sp)
    800009e6:	6105                	addi	sp,sp,32
    800009e8:	8082                	ret

00000000800009ea <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009ea:	1101                	addi	sp,sp,-32
    800009ec:	ec06                	sd	ra,24(sp)
    800009ee:	e822                	sd	s0,16(sp)
    800009f0:	e426                	sd	s1,8(sp)
    800009f2:	e04a                	sd	s2,0(sp)
    800009f4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f6:	03451793          	slli	a5,a0,0x34
    800009fa:	ebb9                	bnez	a5,80000a50 <kfree+0x66>
    800009fc:	84aa                	mv	s1,a0
    800009fe:	00022797          	auipc	a5,0x22
    80000a02:	b8278793          	addi	a5,a5,-1150 # 80022580 <end>
    80000a06:	04f56563          	bltu	a0,a5,80000a50 <kfree+0x66>
    80000a0a:	47c5                	li	a5,17
    80000a0c:	07ee                	slli	a5,a5,0x1b
    80000a0e:	04f57163          	bgeu	a0,a5,80000a50 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a12:	6605                	lui	a2,0x1
    80000a14:	4585                	li	a1,1
    80000a16:	00000097          	auipc	ra,0x0
    80000a1a:	2bc080e7          	jalr	700(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1e:	00010917          	auipc	s2,0x10
    80000a22:	13290913          	addi	s2,s2,306 # 80010b50 <kmem>
    80000a26:	854a                	mv	a0,s2
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	1ae080e7          	jalr	430(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a30:	01893783          	ld	a5,24(s2)
    80000a34:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a36:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a3a:	854a                	mv	a0,s2
    80000a3c:	00000097          	auipc	ra,0x0
    80000a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6902                	ld	s2,0(sp)
    80000a4c:	6105                	addi	sp,sp,32
    80000a4e:	8082                	ret
    panic("kfree");
    80000a50:	00007517          	auipc	a0,0x7
    80000a54:	61050513          	addi	a0,a0,1552 # 80008060 <digits+0x20>
    80000a58:	00000097          	auipc	ra,0x0
    80000a5c:	ae6080e7          	jalr	-1306(ra) # 8000053e <panic>

0000000080000a60 <freerange>:
{
    80000a60:	7179                	addi	sp,sp,-48
    80000a62:	f406                	sd	ra,40(sp)
    80000a64:	f022                	sd	s0,32(sp)
    80000a66:	ec26                	sd	s1,24(sp)
    80000a68:	e84a                	sd	s2,16(sp)
    80000a6a:	e44e                	sd	s3,8(sp)
    80000a6c:	e052                	sd	s4,0(sp)
    80000a6e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a70:	6785                	lui	a5,0x1
    80000a72:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a76:	94aa                	add	s1,s1,a0
    80000a78:	757d                	lui	a0,0xfffff
    80000a7a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3a>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5e080e7          	jalr	-162(ra) # 800009ea <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x28>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	09650513          	addi	a0,a0,150 # 80010b50 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00022517          	auipc	a0,0x22
    80000ad2:	ab250513          	addi	a0,a0,-1358 # 80022580 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f8a080e7          	jalr	-118(ra) # 80000a60 <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	06048493          	addi	s1,s1,96 # 80010b50 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	04850513          	addi	a0,a0,72 # 80010b50 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	01c50513          	addi	a0,a0,28 # 80010b50 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91c080e7          	jalr	-1764(ra) # 8000053e <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8cc080e7          	jalr	-1844(ra) # 8000053e <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8bc080e7          	jalr	-1860(ra) # 8000053e <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	874080e7          	jalr	-1932(ra) # 8000053e <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	fff6c793          	not	a5,a3
    80000e0c:	9fb9                	addw	a5,a5,a4
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a6070713          	addi	a4,a4,-1440 # 800088e8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6da080e7          	jalr	1754(ra) # 80000588 <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	c4e080e7          	jalr	-946(ra) # 80002b0c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	2ba080e7          	jalr	698(ra) # 80006180 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	fd4080e7          	jalr	-44(ra) # 80001ea2 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88a080e7          	jalr	-1910(ra) # 80000768 <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69a080e7          	jalr	1690(ra) # 80000588 <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68a080e7          	jalr	1674(ra) # 80000588 <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67a080e7          	jalr	1658(ra) # 80000588 <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	bae080e7          	jalr	-1106(ra) # 80002ae4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	bce080e7          	jalr	-1074(ra) # 80002b0c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	224080e7          	jalr	548(ra) # 8000616a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	232080e7          	jalr	562(ra) # 80006180 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	3dc080e7          	jalr	988(ra) # 80003332 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	a80080e7          	jalr	-1408(ra) # 800039de <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	a1e080e7          	jalr	-1506(ra) # 80004984 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	31a080e7          	jalr	794(ra) # 80006288 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d0e080e7          	jalr	-754(ra) # 80001c84 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	96f72223          	sw	a5,-1692(a4) # 800088e8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9587b783          	ld	a5,-1704(a5) # 800088f0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7be23          	sd	a0,1692(a5) # 800088f0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ea:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
      panic("freewalk: leaf");
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    }
  }
  kfree((void*)pagetable);
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
}
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
  if(sz > 0)
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
}
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154e:	6605                	lui	a2,0x1
    80001550:	167d                	addi	a2,a2,-1
    80001552:	962e                	add	a2,a2,a1
    80001554:	4685                	li	a3,1
    80001556:	8231                	srli	a2,a2,0xc
    80001558:	4581                	li	a1,0
    8000155a:	00000097          	auipc	ra,0x0
    8000155e:	d0a080e7          	jalr	-758(ra) # 80001264 <uvmunmap>
    80001562:	bfe1                	j	8000153a <uvmfree+0xe>

0000000080001564 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
{
    80001566:	715d                	addi	sp,sp,-80
    80001568:	e486                	sd	ra,72(sp)
    8000156a:	e0a2                	sd	s0,64(sp)
    8000156c:	fc26                	sd	s1,56(sp)
    8000156e:	f84a                	sd	s2,48(sp)
    80001570:	f44e                	sd	s3,40(sp)
    80001572:	f052                	sd	s4,32(sp)
    80001574:	ec56                	sd	s5,24(sp)
    80001576:	e85a                	sd	s6,16(sp)
    80001578:	e45e                	sd	s7,8(sp)
    8000157a:	0880                	addi	s0,sp,80
    8000157c:	8b2a                	mv	s6,a0
    8000157e:	8aae                	mv	s5,a1
    80001580:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001582:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
      panic("uvmcopy: page not present");
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
      kfree(mem);
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
  return -1;
    8000161a:	557d                	li	a0,-1
}
    8000161c:	60a6                	ld	ra,72(sp)
    8000161e:	6406                	ld	s0,64(sp)
    80001620:	74e2                	ld	s1,56(sp)
    80001622:	7942                	ld	s2,48(sp)
    80001624:	79a2                	ld	s3,40(sp)
    80001626:	7a02                	ld	s4,32(sp)
    80001628:	6ae2                	ld	s5,24(sp)
    8000162a:	6b42                	ld	s6,16(sp)
    8000162c:	6ba2                	ld	s7,8(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret
  return 0;
    80001632:	4501                	li	a0,0
}
    80001634:	8082                	ret

0000000080001636 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
  if(pte == 0)
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
}
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    panic("uvmclear");
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
{
    8000166a:	715d                	addi	sp,sp,-80
    8000166c:	e486                	sd	ra,72(sp)
    8000166e:	e0a2                	sd	s0,64(sp)
    80001670:	fc26                	sd	s1,56(sp)
    80001672:	f84a                	sd	s2,48(sp)
    80001674:	f44e                	sd	s3,40(sp)
    80001676:	f052                	sd	s4,32(sp)
    80001678:	ec56                	sd	s5,24(sp)
    8000167a:	e85a                	sd	s6,16(sp)
    8000167c:	e45e                	sd	s7,8(sp)
    8000167e:	e062                	sd	s8,0(sp)
    80001680:	0880                	addi	s0,sp,80
    80001682:	8b2a                	mv	s6,a0
    80001684:	8c2e                	mv	s8,a1
    80001686:	8a32                	mv	s4,a2
    80001688:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>

    len -= n;
    800016a4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016aa:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
  }
  return 0;
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret
      return -1;
    800016da:	557d                	li	a0,-1
}
    800016dc:	60a6                	ld	ra,72(sp)
    800016de:	6406                	ld	s0,64(sp)
    800016e0:	74e2                	ld	s1,56(sp)
    800016e2:	7942                	ld	s2,48(sp)
    800016e4:	79a2                	ld	s3,40(sp)
    800016e6:	7a02                	ld	s4,32(sp)
    800016e8:	6ae2                	ld	s5,24(sp)
    800016ea:	6b42                	ld	s6,16(sp)
    800016ec:	6ba2                	ld	s7,8(sp)
    800016ee:	6c02                	ld	s8,0(sp)
    800016f0:	6161                	addi	sp,sp,80
    800016f2:	8082                	ret

00000000800016f4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
{
    800016f6:	715d                	addi	sp,sp,-80
    800016f8:	e486                	sd	ra,72(sp)
    800016fa:	e0a2                	sd	s0,64(sp)
    800016fc:	fc26                	sd	s1,56(sp)
    800016fe:	f84a                	sd	s2,48(sp)
    80001700:	f44e                	sd	s3,40(sp)
    80001702:	f052                	sd	s4,32(sp)
    80001704:	ec56                	sd	s5,24(sp)
    80001706:	e85a                	sd	s6,16(sp)
    80001708:	e45e                	sd	s7,8(sp)
    8000170a:	e062                	sd	s8,0(sp)
    8000170c:	0880                	addi	s0,sp,80
    8000170e:	8b2a                	mv	s6,a0
    80001710:	8a2e                	mv	s4,a1
    80001712:	8c32                	mv	s8,a2
    80001714:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001716:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>

    len -= n;
    80001732:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001736:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001738:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001740:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    if(n > len)
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
  }
  return 0;
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
}
    80001766:	8082                	ret
      return -1;
    80001768:	557d                	li	a0,-1
}
    8000176a:	60a6                	ld	ra,72(sp)
    8000176c:	6406                	ld	s0,64(sp)
    8000176e:	74e2                	ld	s1,56(sp)
    80001770:	7942                	ld	s2,48(sp)
    80001772:	79a2                	ld	s3,40(sp)
    80001774:	7a02                	ld	s4,32(sp)
    80001776:	6ae2                	ld	s5,24(sp)
    80001778:	6b42                	ld	s6,16(sp)
    8000177a:	6ba2                	ld	s7,8(sp)
    8000177c:	6c02                	ld	s8,0(sp)
    8000177e:	6161                	addi	sp,sp,80
    80001780:	8082                	ret

0000000080001782 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
{
    80001784:	715d                	addi	sp,sp,-80
    80001786:	e486                	sd	ra,72(sp)
    80001788:	e0a2                	sd	s0,64(sp)
    8000178a:	fc26                	sd	s1,56(sp)
    8000178c:	f84a                	sd	s2,48(sp)
    8000178e:	f44e                	sd	s3,40(sp)
    80001790:	f052                	sd	s4,32(sp)
    80001792:	ec56                	sd	s5,24(sp)
    80001794:	e85a                	sd	s6,16(sp)
    80001796:	e45e                	sd	s7,8(sp)
    80001798:	0880                	addi	s0,sp,80
    8000179a:	8a2a                	mv	s4,a0
    8000179c:	8b2e                	mv	s6,a1
    8000179e:	8bb2                	mv	s7,a2
    800017a0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b6:	60a6                	ld	ra,72(sp)
    800017b8:	6406                	ld	s0,64(sp)
    800017ba:	74e2                	ld	s1,56(sp)
    800017bc:	7942                	ld	s2,48(sp)
    800017be:	79a2                	ld	s3,40(sp)
    800017c0:	7a02                	ld	s4,32(sp)
    800017c2:	6ae2                	ld	s5,24(sp)
    800017c4:	6b42                	ld	s6,16(sp)
    800017c6:	6ba2                	ld	s7,8(sp)
    800017c8:	6161                	addi	sp,sp,80
    800017ca:	8082                	ret
    srcva = va0 + PGSIZE;
    800017cc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017d2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    if(n > max)
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
        *dst = *p;
    80001810:	00e78023          	sb	a4,0(a5)
      --max;
    80001814:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001818:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
      dst++;
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
      return -1;
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
  int got_null = 0;
    8000182a:	4781                	li	a5,0
  if(got_null){
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	75448493          	addi	s1,s1,1876 # 80010fa0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00016a17          	auipc	s4,0x16
    8000186a:	93aa0a13          	addi	s4,s4,-1734 # 800171a0 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	18848493          	addi	s1,s1,392
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7a080e7          	jalr	-902(ra) # 8000053e <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	28850513          	addi	a0,a0,648 # 80010b70 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	28850513          	addi	a0,a0,648 # 80010b88 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	69048493          	addi	s1,s1,1680 # 80010fa0 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00016997          	auipc	s3,0x16
    80001936:	86e98993          	addi	s3,s3,-1938 # 800171a0 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	878d                	srai	a5,a5,0x3
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	18848493          	addi	s1,s1,392
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	20450513          	addi	a0,a0,516 # 80010ba0 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	1ac70713          	addi	a4,a4,428 # 80010b70 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first) {
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e647a783          	lw	a5,-412(a5) # 80008860 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	11e080e7          	jalr	286(ra) # 80002b24 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e407a523          	sw	zero,-438(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	f3e080e7          	jalr	-194(ra) # 8000395e <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	13a90913          	addi	s2,s2,314 # 80010b70 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e1c78793          	addi	a5,a5,-484 # 80008864 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <proc_pagetable>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
    80001a7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7e:	00000097          	auipc	ra,0x0
    80001a82:	8aa080e7          	jalr	-1878(ra) # 80001328 <uvmcreate>
    80001a86:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a88:	c121                	beqz	a0,80001ac8 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a8a:	4729                	li	a4,10
    80001a8c:	00005697          	auipc	a3,0x5
    80001a90:	57468693          	addi	a3,a3,1396 # 80007000 <_trampoline>
    80001a94:	6605                	lui	a2,0x1
    80001a96:	040005b7          	lui	a1,0x4000
    80001a9a:	15fd                	addi	a1,a1,-1
    80001a9c:	05b2                	slli	a1,a1,0xc
    80001a9e:	fffff097          	auipc	ra,0xfffff
    80001aa2:	600080e7          	jalr	1536(ra) # 8000109e <mappages>
    80001aa6:	02054863          	bltz	a0,80001ad6 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aaa:	4719                	li	a4,6
    80001aac:	05893683          	ld	a3,88(s2)
    80001ab0:	6605                	lui	a2,0x1
    80001ab2:	020005b7          	lui	a1,0x2000
    80001ab6:	15fd                	addi	a1,a1,-1
    80001ab8:	05b6                	slli	a1,a1,0xd
    80001aba:	8526                	mv	a0,s1
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	5e2080e7          	jalr	1506(ra) # 8000109e <mappages>
    80001ac4:	02054163          	bltz	a0,80001ae6 <proc_pagetable+0x76>
}
    80001ac8:	8526                	mv	a0,s1
    80001aca:	60e2                	ld	ra,24(sp)
    80001acc:	6442                	ld	s0,16(sp)
    80001ace:	64a2                	ld	s1,8(sp)
    80001ad0:	6902                	ld	s2,0(sp)
    80001ad2:	6105                	addi	sp,sp,32
    80001ad4:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad6:	4581                	li	a1,0
    80001ad8:	8526                	mv	a0,s1
    80001ada:	00000097          	auipc	ra,0x0
    80001ade:	a52080e7          	jalr	-1454(ra) # 8000152c <uvmfree>
    return 0;
    80001ae2:	4481                	li	s1,0
    80001ae4:	b7d5                	j	80001ac8 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae6:	4681                	li	a3,0
    80001ae8:	4605                	li	a2,1
    80001aea:	040005b7          	lui	a1,0x4000
    80001aee:	15fd                	addi	a1,a1,-1
    80001af0:	05b2                	slli	a1,a1,0xc
    80001af2:	8526                	mv	a0,s1
    80001af4:	fffff097          	auipc	ra,0xfffff
    80001af8:	770080e7          	jalr	1904(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afc:	4581                	li	a1,0
    80001afe:	8526                	mv	a0,s1
    80001b00:	00000097          	auipc	ra,0x0
    80001b04:	a2c080e7          	jalr	-1492(ra) # 8000152c <uvmfree>
    return 0;
    80001b08:	4481                	li	s1,0
    80001b0a:	bf7d                	j	80001ac8 <proc_pagetable+0x58>

0000000080001b0c <proc_freepagetable>:
{
    80001b0c:	1101                	addi	sp,sp,-32
    80001b0e:	ec06                	sd	ra,24(sp)
    80001b10:	e822                	sd	s0,16(sp)
    80001b12:	e426                	sd	s1,8(sp)
    80001b14:	e04a                	sd	s2,0(sp)
    80001b16:	1000                	addi	s0,sp,32
    80001b18:	84aa                	mv	s1,a0
    80001b1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	addi	a1,a1,-1
    80001b26:	05b2                	slli	a1,a1,0xc
    80001b28:	fffff097          	auipc	ra,0xfffff
    80001b2c:	73c080e7          	jalr	1852(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	020005b7          	lui	a1,0x2000
    80001b38:	15fd                	addi	a1,a1,-1
    80001b3a:	05b6                	slli	a1,a1,0xd
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	726080e7          	jalr	1830(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b46:	85ca                	mv	a1,s2
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9e2080e7          	jalr	-1566(ra) # 8000152c <uvmfree>
}
    80001b52:	60e2                	ld	ra,24(sp)
    80001b54:	6442                	ld	s0,16(sp)
    80001b56:	64a2                	ld	s1,8(sp)
    80001b58:	6902                	ld	s2,0(sp)
    80001b5a:	6105                	addi	sp,sp,32
    80001b5c:	8082                	ret

0000000080001b5e <freeproc>:
{
    80001b5e:	1101                	addi	sp,sp,-32
    80001b60:	ec06                	sd	ra,24(sp)
    80001b62:	e822                	sd	s0,16(sp)
    80001b64:	e426                	sd	s1,8(sp)
    80001b66:	1000                	addi	s0,sp,32
    80001b68:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b6a:	6d28                	ld	a0,88(a0)
    80001b6c:	c509                	beqz	a0,80001b76 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	e7c080e7          	jalr	-388(ra) # 800009ea <kfree>
  p->trapframe = 0;
    80001b76:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b7a:	68a8                	ld	a0,80(s1)
    80001b7c:	c511                	beqz	a0,80001b88 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7e:	64ac                	ld	a1,72(s1)
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	f8c080e7          	jalr	-116(ra) # 80001b0c <proc_freepagetable>
  p->pagetable = 0;
    80001b88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ba0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ba4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba8:	0004ac23          	sw	zero,24(s1)
}
    80001bac:	60e2                	ld	ra,24(sp)
    80001bae:	6442                	ld	s0,16(sp)
    80001bb0:	64a2                	ld	s1,8(sp)
    80001bb2:	6105                	addi	sp,sp,32
    80001bb4:	8082                	ret

0000000080001bb6 <allocproc>:
{
    80001bb6:	1101                	addi	sp,sp,-32
    80001bb8:	ec06                	sd	ra,24(sp)
    80001bba:	e822                	sd	s0,16(sp)
    80001bbc:	e426                	sd	s1,8(sp)
    80001bbe:	e04a                	sd	s2,0(sp)
    80001bc0:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bc2:	0000f497          	auipc	s1,0xf
    80001bc6:	3de48493          	addi	s1,s1,990 # 80010fa0 <proc>
    80001bca:	00015917          	auipc	s2,0x15
    80001bce:	5d690913          	addi	s2,s2,1494 # 800171a0 <tickslock>
    acquire(&p->lock);
    80001bd2:	8526                	mv	a0,s1
    80001bd4:	fffff097          	auipc	ra,0xfffff
    80001bd8:	002080e7          	jalr	2(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001bdc:	4c9c                	lw	a5,24(s1)
    80001bde:	cf81                	beqz	a5,80001bf6 <allocproc+0x40>
      release(&p->lock);
    80001be0:	8526                	mv	a0,s1
    80001be2:	fffff097          	auipc	ra,0xfffff
    80001be6:	0a8080e7          	jalr	168(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bea:	18848493          	addi	s1,s1,392
    80001bee:	ff2492e3          	bne	s1,s2,80001bd2 <allocproc+0x1c>
  return 0;
    80001bf2:	4481                	li	s1,0
    80001bf4:	a889                	j	80001c46 <allocproc+0x90>
  p->pid = allocpid();
    80001bf6:	00000097          	auipc	ra,0x0
    80001bfa:	e34080e7          	jalr	-460(ra) # 80001a2a <allocpid>
    80001bfe:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c00:	4785                	li	a5,1
    80001c02:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c04:	fffff097          	auipc	ra,0xfffff
    80001c08:	ee2080e7          	jalr	-286(ra) # 80000ae6 <kalloc>
    80001c0c:	892a                	mv	s2,a0
    80001c0e:	eca8                	sd	a0,88(s1)
    80001c10:	c131                	beqz	a0,80001c54 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	00000097          	auipc	ra,0x0
    80001c18:	e5c080e7          	jalr	-420(ra) # 80001a70 <proc_pagetable>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c20:	c531                	beqz	a0,80001c6c <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c22:	07000613          	li	a2,112
    80001c26:	4581                	li	a1,0
    80001c28:	06048513          	addi	a0,s1,96
    80001c2c:	fffff097          	auipc	ra,0xfffff
    80001c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001c34:	00000797          	auipc	a5,0x0
    80001c38:	db078793          	addi	a5,a5,-592 # 800019e4 <forkret>
    80001c3c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c3e:	60bc                	ld	a5,64(s1)
    80001c40:	6705                	lui	a4,0x1
    80001c42:	97ba                	add	a5,a5,a4
    80001c44:	f4bc                	sd	a5,104(s1)
}
    80001c46:	8526                	mv	a0,s1
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6902                	ld	s2,0(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret
    freeproc(p);
    80001c54:	8526                	mv	a0,s1
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	f08080e7          	jalr	-248(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	fffff097          	auipc	ra,0xfffff
    80001c64:	02a080e7          	jalr	42(ra) # 80000c8a <release>
    return 0;
    80001c68:	84ca                	mv	s1,s2
    80001c6a:	bff1                	j	80001c46 <allocproc+0x90>
    freeproc(p);
    80001c6c:	8526                	mv	a0,s1
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	ef0080e7          	jalr	-272(ra) # 80001b5e <freeproc>
    release(&p->lock);
    80001c76:	8526                	mv	a0,s1
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	012080e7          	jalr	18(ra) # 80000c8a <release>
    return 0;
    80001c80:	84ca                	mv	s1,s2
    80001c82:	b7d1                	j	80001c46 <allocproc+0x90>

0000000080001c84 <userinit>:
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c8e:	00000097          	auipc	ra,0x0
    80001c92:	f28080e7          	jalr	-216(ra) # 80001bb6 <allocproc>
    80001c96:	84aa                	mv	s1,a0
  initproc = p;
    80001c98:	00007797          	auipc	a5,0x7
    80001c9c:	c6a7b023          	sd	a0,-928(a5) # 800088f8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca0:	03400613          	li	a2,52
    80001ca4:	00007597          	auipc	a1,0x7
    80001ca8:	bcc58593          	addi	a1,a1,-1076 # 80008870 <initcode>
    80001cac:	6928                	ld	a0,80(a0)
    80001cae:	fffff097          	auipc	ra,0xfffff
    80001cb2:	6a8080e7          	jalr	1704(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001cb6:	6785                	lui	a5,0x1
    80001cb8:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cba:	6cb8                	ld	a4,88(s1)
    80001cbc:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cc0:	6cb8                	ld	a4,88(s1)
    80001cc2:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cc4:	4641                	li	a2,16
    80001cc6:	00006597          	auipc	a1,0x6
    80001cca:	53a58593          	addi	a1,a1,1338 # 80008200 <digits+0x1c0>
    80001cce:	15848513          	addi	a0,s1,344
    80001cd2:	fffff097          	auipc	ra,0xfffff
    80001cd6:	14a080e7          	jalr	330(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001cda:	00006517          	auipc	a0,0x6
    80001cde:	53650513          	addi	a0,a0,1334 # 80008210 <digits+0x1d0>
    80001ce2:	00002097          	auipc	ra,0x2
    80001ce6:	69e080e7          	jalr	1694(ra) # 80004380 <namei>
    80001cea:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001cee:	478d                	li	a5,3
    80001cf0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cf2:	8526                	mv	a0,s1
    80001cf4:	fffff097          	auipc	ra,0xfffff
    80001cf8:	f96080e7          	jalr	-106(ra) # 80000c8a <release>
}
    80001cfc:	60e2                	ld	ra,24(sp)
    80001cfe:	6442                	ld	s0,16(sp)
    80001d00:	64a2                	ld	s1,8(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret

0000000080001d06 <growproc>:
{
    80001d06:	1101                	addi	sp,sp,-32
    80001d08:	ec06                	sd	ra,24(sp)
    80001d0a:	e822                	sd	s0,16(sp)
    80001d0c:	e426                	sd	s1,8(sp)
    80001d0e:	e04a                	sd	s2,0(sp)
    80001d10:	1000                	addi	s0,sp,32
    80001d12:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d14:	00000097          	auipc	ra,0x0
    80001d18:	c98080e7          	jalr	-872(ra) # 800019ac <myproc>
    80001d1c:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d1e:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d20:	01204c63          	bgtz	s2,80001d38 <growproc+0x32>
  } else if(n < 0){
    80001d24:	02094663          	bltz	s2,80001d50 <growproc+0x4a>
  p->sz = sz;
    80001d28:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d2a:	4501                	li	a0,0
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d38:	4691                	li	a3,4
    80001d3a:	00b90633          	add	a2,s2,a1
    80001d3e:	6928                	ld	a0,80(a0)
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	6d0080e7          	jalr	1744(ra) # 80001410 <uvmalloc>
    80001d48:	85aa                	mv	a1,a0
    80001d4a:	fd79                	bnez	a0,80001d28 <growproc+0x22>
      return -1;
    80001d4c:	557d                	li	a0,-1
    80001d4e:	bff9                	j	80001d2c <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d50:	00b90633          	add	a2,s2,a1
    80001d54:	6928                	ld	a0,80(a0)
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	672080e7          	jalr	1650(ra) # 800013c8 <uvmdealloc>
    80001d5e:	85aa                	mv	a1,a0
    80001d60:	b7e1                	j	80001d28 <growproc+0x22>

0000000080001d62 <fork>:
{
    80001d62:	7139                	addi	sp,sp,-64
    80001d64:	fc06                	sd	ra,56(sp)
    80001d66:	f822                	sd	s0,48(sp)
    80001d68:	f426                	sd	s1,40(sp)
    80001d6a:	f04a                	sd	s2,32(sp)
    80001d6c:	ec4e                	sd	s3,24(sp)
    80001d6e:	e852                	sd	s4,16(sp)
    80001d70:	e456                	sd	s5,8(sp)
    80001d72:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	c38080e7          	jalr	-968(ra) # 800019ac <myproc>
    80001d7c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d7e:	00000097          	auipc	ra,0x0
    80001d82:	e38080e7          	jalr	-456(ra) # 80001bb6 <allocproc>
    80001d86:	10050c63          	beqz	a0,80001e9e <fork+0x13c>
    80001d8a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d8c:	048ab603          	ld	a2,72(s5)
    80001d90:	692c                	ld	a1,80(a0)
    80001d92:	050ab503          	ld	a0,80(s5)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	7ce080e7          	jalr	1998(ra) # 80001564 <uvmcopy>
    80001d9e:	04054863          	bltz	a0,80001dee <fork+0x8c>
  np->sz = p->sz;
    80001da2:	048ab783          	ld	a5,72(s5)
    80001da6:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001daa:	058ab683          	ld	a3,88(s5)
    80001dae:	87b6                	mv	a5,a3
    80001db0:	058a3703          	ld	a4,88(s4)
    80001db4:	12068693          	addi	a3,a3,288
    80001db8:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001dbc:	6788                	ld	a0,8(a5)
    80001dbe:	6b8c                	ld	a1,16(a5)
    80001dc0:	6f90                	ld	a2,24(a5)
    80001dc2:	01073023          	sd	a6,0(a4)
    80001dc6:	e708                	sd	a0,8(a4)
    80001dc8:	eb0c                	sd	a1,16(a4)
    80001dca:	ef10                	sd	a2,24(a4)
    80001dcc:	02078793          	addi	a5,a5,32
    80001dd0:	02070713          	addi	a4,a4,32
    80001dd4:	fed792e3          	bne	a5,a3,80001db8 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd8:	058a3783          	ld	a5,88(s4)
    80001ddc:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001de0:	0d0a8493          	addi	s1,s5,208
    80001de4:	0d0a0913          	addi	s2,s4,208
    80001de8:	150a8993          	addi	s3,s5,336
    80001dec:	a00d                	j	80001e0e <fork+0xac>
    freeproc(np);
    80001dee:	8552                	mv	a0,s4
    80001df0:	00000097          	auipc	ra,0x0
    80001df4:	d6e080e7          	jalr	-658(ra) # 80001b5e <freeproc>
    release(&np->lock);
    80001df8:	8552                	mv	a0,s4
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	e90080e7          	jalr	-368(ra) # 80000c8a <release>
    return -1;
    80001e02:	597d                	li	s2,-1
    80001e04:	a059                	j	80001e8a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e06:	04a1                	addi	s1,s1,8
    80001e08:	0921                	addi	s2,s2,8
    80001e0a:	01348b63          	beq	s1,s3,80001e20 <fork+0xbe>
    if(p->ofile[i])
    80001e0e:	6088                	ld	a0,0(s1)
    80001e10:	d97d                	beqz	a0,80001e06 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e12:	00003097          	auipc	ra,0x3
    80001e16:	c04080e7          	jalr	-1020(ra) # 80004a16 <filedup>
    80001e1a:	00a93023          	sd	a0,0(s2)
    80001e1e:	b7e5                	j	80001e06 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e20:	150ab503          	ld	a0,336(s5)
    80001e24:	00002097          	auipc	ra,0x2
    80001e28:	d78080e7          	jalr	-648(ra) # 80003b9c <idup>
    80001e2c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e30:	4641                	li	a2,16
    80001e32:	158a8593          	addi	a1,s5,344
    80001e36:	158a0513          	addi	a0,s4,344
    80001e3a:	fffff097          	auipc	ra,0xfffff
    80001e3e:	fe2080e7          	jalr	-30(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001e42:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e46:	8552                	mv	a0,s4
    80001e48:	fffff097          	auipc	ra,0xfffff
    80001e4c:	e42080e7          	jalr	-446(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001e50:	0000f497          	auipc	s1,0xf
    80001e54:	d3848493          	addi	s1,s1,-712 # 80010b88 <wait_lock>
    80001e58:	8526                	mv	a0,s1
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	d7c080e7          	jalr	-644(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001e62:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e66:	8526                	mv	a0,s1
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001e70:	8552                	mv	a0,s4
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	d64080e7          	jalr	-668(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001e7a:	478d                	li	a5,3
    80001e7c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e80:	8552                	mv	a0,s4
    80001e82:	fffff097          	auipc	ra,0xfffff
    80001e86:	e08080e7          	jalr	-504(ra) # 80000c8a <release>
}
    80001e8a:	854a                	mv	a0,s2
    80001e8c:	70e2                	ld	ra,56(sp)
    80001e8e:	7442                	ld	s0,48(sp)
    80001e90:	74a2                	ld	s1,40(sp)
    80001e92:	7902                	ld	s2,32(sp)
    80001e94:	69e2                	ld	s3,24(sp)
    80001e96:	6a42                	ld	s4,16(sp)
    80001e98:	6aa2                	ld	s5,8(sp)
    80001e9a:	6121                	addi	sp,sp,64
    80001e9c:	8082                	ret
    return -1;
    80001e9e:	597d                	li	s2,-1
    80001ea0:	b7ed                	j	80001e8a <fork+0x128>

0000000080001ea2 <scheduler>:
{
    80001ea2:	7139                	addi	sp,sp,-64
    80001ea4:	fc06                	sd	ra,56(sp)
    80001ea6:	f822                	sd	s0,48(sp)
    80001ea8:	f426                	sd	s1,40(sp)
    80001eaa:	f04a                	sd	s2,32(sp)
    80001eac:	ec4e                	sd	s3,24(sp)
    80001eae:	e852                	sd	s4,16(sp)
    80001eb0:	e456                	sd	s5,8(sp)
    80001eb2:	e05a                	sd	s6,0(sp)
    80001eb4:	0080                	addi	s0,sp,64
    80001eb6:	8792                	mv	a5,tp
  int id = r_tp();
    80001eb8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eba:	00779a93          	slli	s5,a5,0x7
    80001ebe:	0000f717          	auipc	a4,0xf
    80001ec2:	cb270713          	addi	a4,a4,-846 # 80010b70 <pid_lock>
    80001ec6:	9756                	add	a4,a4,s5
    80001ec8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ecc:	0000f717          	auipc	a4,0xf
    80001ed0:	cdc70713          	addi	a4,a4,-804 # 80010ba8 <cpus+0x8>
    80001ed4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed6:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed8:	4b11                	li	s6,4
        c->proc = p;
    80001eda:	079e                	slli	a5,a5,0x7
    80001edc:	0000fa17          	auipc	s4,0xf
    80001ee0:	c94a0a13          	addi	s4,s4,-876 # 80010b70 <pid_lock>
    80001ee4:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee6:	00015917          	auipc	s2,0x15
    80001eea:	2ba90913          	addi	s2,s2,698 # 800171a0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef6:	10079073          	csrw	sstatus,a5
    80001efa:	0000f497          	auipc	s1,0xf
    80001efe:	0a648493          	addi	s1,s1,166 # 80010fa0 <proc>
    80001f02:	a811                	j	80001f16 <scheduler+0x74>
      release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	18848493          	addi	s1,s1,392
    80001f12:	fd248ee3          	beq	s1,s2,80001eee <scheduler+0x4c>
      acquire(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	cbe080e7          	jalr	-834(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f20:	4c9c                	lw	a5,24(s1)
    80001f22:	ff3791e3          	bne	a5,s3,80001f04 <scheduler+0x62>
        p->state = RUNNING;
    80001f26:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f2a:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f2e:	06048593          	addi	a1,s1,96
    80001f32:	8556                	mv	a0,s5
    80001f34:	00001097          	auipc	ra,0x1
    80001f38:	b46080e7          	jalr	-1210(ra) # 80002a7a <swtch>
        c->proc = 0;
    80001f3c:	020a3823          	sd	zero,48(s4)
    80001f40:	b7d1                	j	80001f04 <scheduler+0x62>

0000000080001f42 <sched>:
{
    80001f42:	7179                	addi	sp,sp,-48
    80001f44:	f406                	sd	ra,40(sp)
    80001f46:	f022                	sd	s0,32(sp)
    80001f48:	ec26                	sd	s1,24(sp)
    80001f4a:	e84a                	sd	s2,16(sp)
    80001f4c:	e44e                	sd	s3,8(sp)
    80001f4e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f50:	00000097          	auipc	ra,0x0
    80001f54:	a5c080e7          	jalr	-1444(ra) # 800019ac <myproc>
    80001f58:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	c02080e7          	jalr	-1022(ra) # 80000b5c <holding>
    80001f62:	c93d                	beqz	a0,80001fd8 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f64:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f66:	2781                	sext.w	a5,a5
    80001f68:	079e                	slli	a5,a5,0x7
    80001f6a:	0000f717          	auipc	a4,0xf
    80001f6e:	c0670713          	addi	a4,a4,-1018 # 80010b70 <pid_lock>
    80001f72:	97ba                	add	a5,a5,a4
    80001f74:	0a87a703          	lw	a4,168(a5)
    80001f78:	4785                	li	a5,1
    80001f7a:	06f71763          	bne	a4,a5,80001fe8 <sched+0xa6>
  if(p->state == RUNNING)
    80001f7e:	4c98                	lw	a4,24(s1)
    80001f80:	4791                	li	a5,4
    80001f82:	06f70b63          	beq	a4,a5,80001ff8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f86:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f8a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f8c:	efb5                	bnez	a5,80002008 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f8e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f90:	0000f917          	auipc	s2,0xf
    80001f94:	be090913          	addi	s2,s2,-1056 # 80010b70 <pid_lock>
    80001f98:	2781                	sext.w	a5,a5
    80001f9a:	079e                	slli	a5,a5,0x7
    80001f9c:	97ca                	add	a5,a5,s2
    80001f9e:	0ac7a983          	lw	s3,172(a5)
    80001fa2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fa4:	2781                	sext.w	a5,a5
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	0000f597          	auipc	a1,0xf
    80001fac:	c0058593          	addi	a1,a1,-1024 # 80010ba8 <cpus+0x8>
    80001fb0:	95be                	add	a1,a1,a5
    80001fb2:	06048513          	addi	a0,s1,96
    80001fb6:	00001097          	auipc	ra,0x1
    80001fba:	ac4080e7          	jalr	-1340(ra) # 80002a7a <swtch>
    80001fbe:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fc0:	2781                	sext.w	a5,a5
    80001fc2:	079e                	slli	a5,a5,0x7
    80001fc4:	97ca                	add	a5,a5,s2
    80001fc6:	0b37a623          	sw	s3,172(a5)
}
    80001fca:	70a2                	ld	ra,40(sp)
    80001fcc:	7402                	ld	s0,32(sp)
    80001fce:	64e2                	ld	s1,24(sp)
    80001fd0:	6942                	ld	s2,16(sp)
    80001fd2:	69a2                	ld	s3,8(sp)
    80001fd4:	6145                	addi	sp,sp,48
    80001fd6:	8082                	ret
    panic("sched p->lock");
    80001fd8:	00006517          	auipc	a0,0x6
    80001fdc:	24050513          	addi	a0,a0,576 # 80008218 <digits+0x1d8>
    80001fe0:	ffffe097          	auipc	ra,0xffffe
    80001fe4:	55e080e7          	jalr	1374(ra) # 8000053e <panic>
    panic("sched locks");
    80001fe8:	00006517          	auipc	a0,0x6
    80001fec:	24050513          	addi	a0,a0,576 # 80008228 <digits+0x1e8>
    80001ff0:	ffffe097          	auipc	ra,0xffffe
    80001ff4:	54e080e7          	jalr	1358(ra) # 8000053e <panic>
    panic("sched running");
    80001ff8:	00006517          	auipc	a0,0x6
    80001ffc:	24050513          	addi	a0,a0,576 # 80008238 <digits+0x1f8>
    80002000:	ffffe097          	auipc	ra,0xffffe
    80002004:	53e080e7          	jalr	1342(ra) # 8000053e <panic>
    panic("sched interruptible");
    80002008:	00006517          	auipc	a0,0x6
    8000200c:	24050513          	addi	a0,a0,576 # 80008248 <digits+0x208>
    80002010:	ffffe097          	auipc	ra,0xffffe
    80002014:	52e080e7          	jalr	1326(ra) # 8000053e <panic>

0000000080002018 <yield>:
{
    80002018:	1101                	addi	sp,sp,-32
    8000201a:	ec06                	sd	ra,24(sp)
    8000201c:	e822                	sd	s0,16(sp)
    8000201e:	e426                	sd	s1,8(sp)
    80002020:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002022:	00000097          	auipc	ra,0x0
    80002026:	98a080e7          	jalr	-1654(ra) # 800019ac <myproc>
    8000202a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	baa080e7          	jalr	-1110(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002034:	478d                	li	a5,3
    80002036:	cc9c                	sw	a5,24(s1)
  sched();
    80002038:	00000097          	auipc	ra,0x0
    8000203c:	f0a080e7          	jalr	-246(ra) # 80001f42 <sched>
  release(&p->lock);
    80002040:	8526                	mv	a0,s1
    80002042:	fffff097          	auipc	ra,0xfffff
    80002046:	c48080e7          	jalr	-952(ra) # 80000c8a <release>
}
    8000204a:	60e2                	ld	ra,24(sp)
    8000204c:	6442                	ld	s0,16(sp)
    8000204e:	64a2                	ld	s1,8(sp)
    80002050:	6105                	addi	sp,sp,32
    80002052:	8082                	ret

0000000080002054 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002054:	7179                	addi	sp,sp,-48
    80002056:	f406                	sd	ra,40(sp)
    80002058:	f022                	sd	s0,32(sp)
    8000205a:	ec26                	sd	s1,24(sp)
    8000205c:	e84a                	sd	s2,16(sp)
    8000205e:	e44e                	sd	s3,8(sp)
    80002060:	1800                	addi	s0,sp,48
    80002062:	89aa                	mv	s3,a0
    80002064:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002066:	00000097          	auipc	ra,0x0
    8000206a:	946080e7          	jalr	-1722(ra) # 800019ac <myproc>
    8000206e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002070:	fffff097          	auipc	ra,0xfffff
    80002074:	b66080e7          	jalr	-1178(ra) # 80000bd6 <acquire>
  release(lk);
    80002078:	854a                	mv	a0,s2
    8000207a:	fffff097          	auipc	ra,0xfffff
    8000207e:	c10080e7          	jalr	-1008(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    80002082:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002086:	4789                	li	a5,2
    80002088:	cc9c                	sw	a5,24(s1)

  sched();
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	eb8080e7          	jalr	-328(ra) # 80001f42 <sched>

  // Tidy up.
  p->chan = 0;
    80002092:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bf2080e7          	jalr	-1038(ra) # 80000c8a <release>
  acquire(lk);
    800020a0:	854a                	mv	a0,s2
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	b34080e7          	jalr	-1228(ra) # 80000bd6 <acquire>
}
    800020aa:	70a2                	ld	ra,40(sp)
    800020ac:	7402                	ld	s0,32(sp)
    800020ae:	64e2                	ld	s1,24(sp)
    800020b0:	6942                	ld	s2,16(sp)
    800020b2:	69a2                	ld	s3,8(sp)
    800020b4:	6145                	addi	sp,sp,48
    800020b6:	8082                	ret

00000000800020b8 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020b8:	7139                	addi	sp,sp,-64
    800020ba:	fc06                	sd	ra,56(sp)
    800020bc:	f822                	sd	s0,48(sp)
    800020be:	f426                	sd	s1,40(sp)
    800020c0:	f04a                	sd	s2,32(sp)
    800020c2:	ec4e                	sd	s3,24(sp)
    800020c4:	e852                	sd	s4,16(sp)
    800020c6:	e456                	sd	s5,8(sp)
    800020c8:	0080                	addi	s0,sp,64
    800020ca:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020cc:	0000f497          	auipc	s1,0xf
    800020d0:	ed448493          	addi	s1,s1,-300 # 80010fa0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020d4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d8:	00015917          	auipc	s2,0x15
    800020dc:	0c890913          	addi	s2,s2,200 # 800171a0 <tickslock>
    800020e0:	a811                	j	800020f4 <wakeup+0x3c>
      }
      release(&p->lock);
    800020e2:	8526                	mv	a0,s1
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	ba6080e7          	jalr	-1114(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ec:	18848493          	addi	s1,s1,392
    800020f0:	03248663          	beq	s1,s2,8000211c <wakeup+0x64>
    if(p != myproc()){
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	8b8080e7          	jalr	-1864(ra) # 800019ac <myproc>
    800020fc:	fea488e3          	beq	s1,a0,800020ec <wakeup+0x34>
      acquire(&p->lock);
    80002100:	8526                	mv	a0,s1
    80002102:	fffff097          	auipc	ra,0xfffff
    80002106:	ad4080e7          	jalr	-1324(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    8000210a:	4c9c                	lw	a5,24(s1)
    8000210c:	fd379be3          	bne	a5,s3,800020e2 <wakeup+0x2a>
    80002110:	709c                	ld	a5,32(s1)
    80002112:	fd4798e3          	bne	a5,s4,800020e2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002116:	0154ac23          	sw	s5,24(s1)
    8000211a:	b7e1                	j	800020e2 <wakeup+0x2a>
    }
  }
}
    8000211c:	70e2                	ld	ra,56(sp)
    8000211e:	7442                	ld	s0,48(sp)
    80002120:	74a2                	ld	s1,40(sp)
    80002122:	7902                	ld	s2,32(sp)
    80002124:	69e2                	ld	s3,24(sp)
    80002126:	6a42                	ld	s4,16(sp)
    80002128:	6aa2                	ld	s5,8(sp)
    8000212a:	6121                	addi	sp,sp,64
    8000212c:	8082                	ret

000000008000212e <reparent>:
{
    8000212e:	7179                	addi	sp,sp,-48
    80002130:	f406                	sd	ra,40(sp)
    80002132:	f022                	sd	s0,32(sp)
    80002134:	ec26                	sd	s1,24(sp)
    80002136:	e84a                	sd	s2,16(sp)
    80002138:	e44e                	sd	s3,8(sp)
    8000213a:	e052                	sd	s4,0(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002140:	0000f497          	auipc	s1,0xf
    80002144:	e6048493          	addi	s1,s1,-416 # 80010fa0 <proc>
      pp->parent = initproc;
    80002148:	00006a17          	auipc	s4,0x6
    8000214c:	7b0a0a13          	addi	s4,s4,1968 # 800088f8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002150:	00015997          	auipc	s3,0x15
    80002154:	05098993          	addi	s3,s3,80 # 800171a0 <tickslock>
    80002158:	a029                	j	80002162 <reparent+0x34>
    8000215a:	18848493          	addi	s1,s1,392
    8000215e:	01348d63          	beq	s1,s3,80002178 <reparent+0x4a>
    if(pp->parent == p){
    80002162:	7c9c                	ld	a5,56(s1)
    80002164:	ff279be3          	bne	a5,s2,8000215a <reparent+0x2c>
      pp->parent = initproc;
    80002168:	000a3503          	ld	a0,0(s4)
    8000216c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000216e:	00000097          	auipc	ra,0x0
    80002172:	f4a080e7          	jalr	-182(ra) # 800020b8 <wakeup>
    80002176:	b7d5                	j	8000215a <reparent+0x2c>
}
    80002178:	70a2                	ld	ra,40(sp)
    8000217a:	7402                	ld	s0,32(sp)
    8000217c:	64e2                	ld	s1,24(sp)
    8000217e:	6942                	ld	s2,16(sp)
    80002180:	69a2                	ld	s3,8(sp)
    80002182:	6a02                	ld	s4,0(sp)
    80002184:	6145                	addi	sp,sp,48
    80002186:	8082                	ret

0000000080002188 <exit>:
{
    80002188:	7139                	addi	sp,sp,-64
    8000218a:	fc06                	sd	ra,56(sp)
    8000218c:	f822                	sd	s0,48(sp)
    8000218e:	f426                	sd	s1,40(sp)
    80002190:	f04a                	sd	s2,32(sp)
    80002192:	ec4e                	sd	s3,24(sp)
    80002194:	e852                	sd	s4,16(sp)
    80002196:	e456                	sd	s5,8(sp)
    80002198:	0080                	addi	s0,sp,64
    8000219a:	8a2a                	mv	s4,a0
    8000219c:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	80e080e7          	jalr	-2034(ra) # 800019ac <myproc>
    800021a6:	89aa                	mv	s3,a0
  if(p == initproc)
    800021a8:	00006797          	auipc	a5,0x6
    800021ac:	7507b783          	ld	a5,1872(a5) # 800088f8 <initproc>
    800021b0:	0d050493          	addi	s1,a0,208
    800021b4:	15050913          	addi	s2,a0,336
    800021b8:	02a79363          	bne	a5,a0,800021de <exit+0x56>
    panic("init exiting");
    800021bc:	00006517          	auipc	a0,0x6
    800021c0:	0a450513          	addi	a0,a0,164 # 80008260 <digits+0x220>
    800021c4:	ffffe097          	auipc	ra,0xffffe
    800021c8:	37a080e7          	jalr	890(ra) # 8000053e <panic>
      fileclose(f);
    800021cc:	00003097          	auipc	ra,0x3
    800021d0:	89c080e7          	jalr	-1892(ra) # 80004a68 <fileclose>
      p->ofile[fd] = 0;
    800021d4:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021d8:	04a1                	addi	s1,s1,8
    800021da:	01248563          	beq	s1,s2,800021e4 <exit+0x5c>
    if(p->ofile[fd]){
    800021de:	6088                	ld	a0,0(s1)
    800021e0:	f575                	bnez	a0,800021cc <exit+0x44>
    800021e2:	bfdd                	j	800021d8 <exit+0x50>
  begin_op();
    800021e4:	00002097          	auipc	ra,0x2
    800021e8:	3b8080e7          	jalr	952(ra) # 8000459c <begin_op>
  iput(p->cwd);
    800021ec:	1509b503          	ld	a0,336(s3)
    800021f0:	00002097          	auipc	ra,0x2
    800021f4:	ba4080e7          	jalr	-1116(ra) # 80003d94 <iput>
  end_op();
    800021f8:	00002097          	auipc	ra,0x2
    800021fc:	424080e7          	jalr	1060(ra) # 8000461c <end_op>
  p->cwd = 0;
    80002200:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002204:	0000f497          	auipc	s1,0xf
    80002208:	98448493          	addi	s1,s1,-1660 # 80010b88 <wait_lock>
    8000220c:	8526                	mv	a0,s1
    8000220e:	fffff097          	auipc	ra,0xfffff
    80002212:	9c8080e7          	jalr	-1592(ra) # 80000bd6 <acquire>
  safestrcpy(p->exit_msg, msg, sizeof(p->exit_msg));
    80002216:	02000613          	li	a2,32
    8000221a:	85d6                	mv	a1,s5
    8000221c:	16898513          	addi	a0,s3,360
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	bfc080e7          	jalr	-1028(ra) # 80000e1c <safestrcpy>
  reparent(p);
    80002228:	854e                	mv	a0,s3
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	f04080e7          	jalr	-252(ra) # 8000212e <reparent>
  wakeup(p->parent);
    80002232:	0389b503          	ld	a0,56(s3)
    80002236:	00000097          	auipc	ra,0x0
    8000223a:	e82080e7          	jalr	-382(ra) # 800020b8 <wakeup>
  acquire(&p->lock);
    8000223e:	854e                	mv	a0,s3
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	996080e7          	jalr	-1642(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002248:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000224c:	4795                	li	a5,5
    8000224e:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002252:	8526                	mv	a0,s1
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	a36080e7          	jalr	-1482(ra) # 80000c8a <release>
  sched();
    8000225c:	00000097          	auipc	ra,0x0
    80002260:	ce6080e7          	jalr	-794(ra) # 80001f42 <sched>
  panic("zombie exit");
    80002264:	00006517          	auipc	a0,0x6
    80002268:	00c50513          	addi	a0,a0,12 # 80008270 <digits+0x230>
    8000226c:	ffffe097          	auipc	ra,0xffffe
    80002270:	2d2080e7          	jalr	722(ra) # 8000053e <panic>

0000000080002274 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002274:	7179                	addi	sp,sp,-48
    80002276:	f406                	sd	ra,40(sp)
    80002278:	f022                	sd	s0,32(sp)
    8000227a:	ec26                	sd	s1,24(sp)
    8000227c:	e84a                	sd	s2,16(sp)
    8000227e:	e44e                	sd	s3,8(sp)
    80002280:	1800                	addi	s0,sp,48
    80002282:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002284:	0000f497          	auipc	s1,0xf
    80002288:	d1c48493          	addi	s1,s1,-740 # 80010fa0 <proc>
    8000228c:	00015997          	auipc	s3,0x15
    80002290:	f1498993          	addi	s3,s3,-236 # 800171a0 <tickslock>
    acquire(&p->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	940080e7          	jalr	-1728(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    8000229e:	589c                	lw	a5,48(s1)
    800022a0:	01278d63          	beq	a5,s2,800022ba <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800022a4:	8526                	mv	a0,s1
    800022a6:	fffff097          	auipc	ra,0xfffff
    800022aa:	9e4080e7          	jalr	-1564(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800022ae:	18848493          	addi	s1,s1,392
    800022b2:	ff3491e3          	bne	s1,s3,80002294 <kill+0x20>
  }
  return -1;
    800022b6:	557d                	li	a0,-1
    800022b8:	a829                	j	800022d2 <kill+0x5e>
      p->killed = 1;
    800022ba:	4785                	li	a5,1
    800022bc:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022be:	4c98                	lw	a4,24(s1)
    800022c0:	4789                	li	a5,2
    800022c2:	00f70f63          	beq	a4,a5,800022e0 <kill+0x6c>
      release(&p->lock);
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	9c2080e7          	jalr	-1598(ra) # 80000c8a <release>
      return 0;
    800022d0:	4501                	li	a0,0
}
    800022d2:	70a2                	ld	ra,40(sp)
    800022d4:	7402                	ld	s0,32(sp)
    800022d6:	64e2                	ld	s1,24(sp)
    800022d8:	6942                	ld	s2,16(sp)
    800022da:	69a2                	ld	s3,8(sp)
    800022dc:	6145                	addi	sp,sp,48
    800022de:	8082                	ret
        p->state = RUNNABLE;
    800022e0:	478d                	li	a5,3
    800022e2:	cc9c                	sw	a5,24(s1)
    800022e4:	b7cd                	j	800022c6 <kill+0x52>

00000000800022e6 <setkilled>:

void
setkilled(struct proc *p)
{
    800022e6:	1101                	addi	sp,sp,-32
    800022e8:	ec06                	sd	ra,24(sp)
    800022ea:	e822                	sd	s0,16(sp)
    800022ec:	e426                	sd	s1,8(sp)
    800022ee:	1000                	addi	s0,sp,32
    800022f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	8e4080e7          	jalr	-1820(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022fa:	4785                	li	a5,1
    800022fc:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022fe:	8526                	mv	a0,s1
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	98a080e7          	jalr	-1654(ra) # 80000c8a <release>
}
    80002308:	60e2                	ld	ra,24(sp)
    8000230a:	6442                	ld	s0,16(sp)
    8000230c:	64a2                	ld	s1,8(sp)
    8000230e:	6105                	addi	sp,sp,32
    80002310:	8082                	ret

0000000080002312 <killed>:

int
killed(struct proc *p)
{
    80002312:	1101                	addi	sp,sp,-32
    80002314:	ec06                	sd	ra,24(sp)
    80002316:	e822                	sd	s0,16(sp)
    80002318:	e426                	sd	s1,8(sp)
    8000231a:	e04a                	sd	s2,0(sp)
    8000231c:	1000                	addi	s0,sp,32
    8000231e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	8b6080e7          	jalr	-1866(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002328:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000232c:	8526                	mv	a0,s1
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	95c080e7          	jalr	-1700(ra) # 80000c8a <release>
  return k;
}
    80002336:	854a                	mv	a0,s2
    80002338:	60e2                	ld	ra,24(sp)
    8000233a:	6442                	ld	s0,16(sp)
    8000233c:	64a2                	ld	s1,8(sp)
    8000233e:	6902                	ld	s2,0(sp)
    80002340:	6105                	addi	sp,sp,32
    80002342:	8082                	ret

0000000080002344 <wait>:
{
    80002344:	711d                	addi	sp,sp,-96
    80002346:	ec86                	sd	ra,88(sp)
    80002348:	e8a2                	sd	s0,80(sp)
    8000234a:	e4a6                	sd	s1,72(sp)
    8000234c:	e0ca                	sd	s2,64(sp)
    8000234e:	fc4e                	sd	s3,56(sp)
    80002350:	f852                	sd	s4,48(sp)
    80002352:	f456                	sd	s5,40(sp)
    80002354:	f05a                	sd	s6,32(sp)
    80002356:	ec5e                	sd	s7,24(sp)
    80002358:	e862                	sd	s8,16(sp)
    8000235a:	e466                	sd	s9,8(sp)
    8000235c:	1080                	addi	s0,sp,96
    8000235e:	8b2a                	mv	s6,a0
    80002360:	8bae                	mv	s7,a1
  struct proc *p = myproc();
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	64a080e7          	jalr	1610(ra) # 800019ac <myproc>
    8000236a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000236c:	0000f517          	auipc	a0,0xf
    80002370:	81c50513          	addi	a0,a0,-2020 # 80010b88 <wait_lock>
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	862080e7          	jalr	-1950(ra) # 80000bd6 <acquire>
    havekids = 0;
    8000237c:	4c01                	li	s8,0
        if(pp->state == ZOMBIE){
    8000237e:	4a15                	li	s4,5
        havekids = 1;
    80002380:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002382:	00015997          	auipc	s3,0x15
    80002386:	e1e98993          	addi	s3,s3,-482 # 800171a0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000238a:	0000ec97          	auipc	s9,0xe
    8000238e:	7fec8c93          	addi	s9,s9,2046 # 80010b88 <wait_lock>
    havekids = 0;
    80002392:	8762                	mv	a4,s8
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002394:	0000f497          	auipc	s1,0xf
    80002398:	c0c48493          	addi	s1,s1,-1012 # 80010fa0 <proc>
    8000239c:	a859                	j	80002432 <wait+0xee>
          if(msg != 0){
    8000239e:	020b8463          	beqz	s7,800023c6 <wait+0x82>
            copyout(p->pagetable, (uint64)msg,
    800023a2:	05093a03          	ld	s4,80(s2)
                    pp->exit_msg, strlen(pp->exit_msg) + 1);
    800023a6:	16848993          	addi	s3,s1,360
    800023aa:	854e                	mv	a0,s3
    800023ac:	fffff097          	auipc	ra,0xfffff
    800023b0:	aa2080e7          	jalr	-1374(ra) # 80000e4e <strlen>
            copyout(p->pagetable, (uint64)msg,
    800023b4:	0015069b          	addiw	a3,a0,1
    800023b8:	864e                	mv	a2,s3
    800023ba:	85de                	mv	a1,s7
    800023bc:	8552                	mv	a0,s4
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	2aa080e7          	jalr	682(ra) # 80001668 <copyout>
          pid = pp->pid;
    800023c6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023ca:	000b0e63          	beqz	s6,800023e6 <wait+0xa2>
    800023ce:	4691                	li	a3,4
    800023d0:	02c48613          	addi	a2,s1,44
    800023d4:	85da                	mv	a1,s6
    800023d6:	05093503          	ld	a0,80(s2)
    800023da:	fffff097          	auipc	ra,0xfffff
    800023de:	28e080e7          	jalr	654(ra) # 80001668 <copyout>
    800023e2:	02054563          	bltz	a0,8000240c <wait+0xc8>
          freeproc(pp);
    800023e6:	8526                	mv	a0,s1
    800023e8:	fffff097          	auipc	ra,0xfffff
    800023ec:	776080e7          	jalr	1910(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800023f0:	8526                	mv	a0,s1
    800023f2:	fffff097          	auipc	ra,0xfffff
    800023f6:	898080e7          	jalr	-1896(ra) # 80000c8a <release>
          release(&wait_lock);
    800023fa:	0000e517          	auipc	a0,0xe
    800023fe:	78e50513          	addi	a0,a0,1934 # 80010b88 <wait_lock>
    80002402:	fffff097          	auipc	ra,0xfffff
    80002406:	888080e7          	jalr	-1912(ra) # 80000c8a <release>
          return pid;
    8000240a:	a0b5                	j	80002476 <wait+0x132>
            release(&pp->lock);
    8000240c:	8526                	mv	a0,s1
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	87c080e7          	jalr	-1924(ra) # 80000c8a <release>
            release(&wait_lock);
    80002416:	0000e517          	auipc	a0,0xe
    8000241a:	77250513          	addi	a0,a0,1906 # 80010b88 <wait_lock>
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	86c080e7          	jalr	-1940(ra) # 80000c8a <release>
            return -1;
    80002426:	59fd                	li	s3,-1
    80002428:	a0b9                	j	80002476 <wait+0x132>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000242a:	18848493          	addi	s1,s1,392
    8000242e:	03348463          	beq	s1,s3,80002456 <wait+0x112>
      if(pp->parent == p){
    80002432:	7c9c                	ld	a5,56(s1)
    80002434:	ff279be3          	bne	a5,s2,8000242a <wait+0xe6>
        acquire(&pp->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	ffffe097          	auipc	ra,0xffffe
    8000243e:	79c080e7          	jalr	1948(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002442:	4c9c                	lw	a5,24(s1)
    80002444:	f5478de3          	beq	a5,s4,8000239e <wait+0x5a>
        release(&pp->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	840080e7          	jalr	-1984(ra) # 80000c8a <release>
        havekids = 1;
    80002452:	8756                	mv	a4,s5
    80002454:	bfd9                	j	8000242a <wait+0xe6>
    if(!havekids || killed(p)){
    80002456:	c719                	beqz	a4,80002464 <wait+0x120>
    80002458:	854a                	mv	a0,s2
    8000245a:	00000097          	auipc	ra,0x0
    8000245e:	eb8080e7          	jalr	-328(ra) # 80002312 <killed>
    80002462:	c905                	beqz	a0,80002492 <wait+0x14e>
      release(&wait_lock);
    80002464:	0000e517          	auipc	a0,0xe
    80002468:	72450513          	addi	a0,a0,1828 # 80010b88 <wait_lock>
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	81e080e7          	jalr	-2018(ra) # 80000c8a <release>
      return -1;
    80002474:	59fd                	li	s3,-1
}
    80002476:	854e                	mv	a0,s3
    80002478:	60e6                	ld	ra,88(sp)
    8000247a:	6446                	ld	s0,80(sp)
    8000247c:	64a6                	ld	s1,72(sp)
    8000247e:	6906                	ld	s2,64(sp)
    80002480:	79e2                	ld	s3,56(sp)
    80002482:	7a42                	ld	s4,48(sp)
    80002484:	7aa2                	ld	s5,40(sp)
    80002486:	7b02                	ld	s6,32(sp)
    80002488:	6be2                	ld	s7,24(sp)
    8000248a:	6c42                	ld	s8,16(sp)
    8000248c:	6ca2                	ld	s9,8(sp)
    8000248e:	6125                	addi	sp,sp,96
    80002490:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002492:	85e6                	mv	a1,s9
    80002494:	854a                	mv	a0,s2
    80002496:	00000097          	auipc	ra,0x0
    8000249a:	bbe080e7          	jalr	-1090(ra) # 80002054 <sleep>
    havekids = 0;
    8000249e:	bdd5                	j	80002392 <wait+0x4e>

00000000800024a0 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024a0:	7179                	addi	sp,sp,-48
    800024a2:	f406                	sd	ra,40(sp)
    800024a4:	f022                	sd	s0,32(sp)
    800024a6:	ec26                	sd	s1,24(sp)
    800024a8:	e84a                	sd	s2,16(sp)
    800024aa:	e44e                	sd	s3,8(sp)
    800024ac:	e052                	sd	s4,0(sp)
    800024ae:	1800                	addi	s0,sp,48
    800024b0:	84aa                	mv	s1,a0
    800024b2:	892e                	mv	s2,a1
    800024b4:	89b2                	mv	s3,a2
    800024b6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024b8:	fffff097          	auipc	ra,0xfffff
    800024bc:	4f4080e7          	jalr	1268(ra) # 800019ac <myproc>
  if(user_dst){
    800024c0:	c08d                	beqz	s1,800024e2 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024c2:	86d2                	mv	a3,s4
    800024c4:	864e                	mv	a2,s3
    800024c6:	85ca                	mv	a1,s2
    800024c8:	6928                	ld	a0,80(a0)
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	19e080e7          	jalr	414(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024d2:	70a2                	ld	ra,40(sp)
    800024d4:	7402                	ld	s0,32(sp)
    800024d6:	64e2                	ld	s1,24(sp)
    800024d8:	6942                	ld	s2,16(sp)
    800024da:	69a2                	ld	s3,8(sp)
    800024dc:	6a02                	ld	s4,0(sp)
    800024de:	6145                	addi	sp,sp,48
    800024e0:	8082                	ret
    memmove((char *)dst, src, len);
    800024e2:	000a061b          	sext.w	a2,s4
    800024e6:	85ce                	mv	a1,s3
    800024e8:	854a                	mv	a0,s2
    800024ea:	fffff097          	auipc	ra,0xfffff
    800024ee:	844080e7          	jalr	-1980(ra) # 80000d2e <memmove>
    return 0;
    800024f2:	8526                	mv	a0,s1
    800024f4:	bff9                	j	800024d2 <either_copyout+0x32>

00000000800024f6 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024f6:	7179                	addi	sp,sp,-48
    800024f8:	f406                	sd	ra,40(sp)
    800024fa:	f022                	sd	s0,32(sp)
    800024fc:	ec26                	sd	s1,24(sp)
    800024fe:	e84a                	sd	s2,16(sp)
    80002500:	e44e                	sd	s3,8(sp)
    80002502:	e052                	sd	s4,0(sp)
    80002504:	1800                	addi	s0,sp,48
    80002506:	892a                	mv	s2,a0
    80002508:	84ae                	mv	s1,a1
    8000250a:	89b2                	mv	s3,a2
    8000250c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	49e080e7          	jalr	1182(ra) # 800019ac <myproc>
  if(user_src){
    80002516:	c08d                	beqz	s1,80002538 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002518:	86d2                	mv	a3,s4
    8000251a:	864e                	mv	a2,s3
    8000251c:	85ca                	mv	a1,s2
    8000251e:	6928                	ld	a0,80(a0)
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	1d4080e7          	jalr	468(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002528:	70a2                	ld	ra,40(sp)
    8000252a:	7402                	ld	s0,32(sp)
    8000252c:	64e2                	ld	s1,24(sp)
    8000252e:	6942                	ld	s2,16(sp)
    80002530:	69a2                	ld	s3,8(sp)
    80002532:	6a02                	ld	s4,0(sp)
    80002534:	6145                	addi	sp,sp,48
    80002536:	8082                	ret
    memmove(dst, (char*)src, len);
    80002538:	000a061b          	sext.w	a2,s4
    8000253c:	85ce                	mv	a1,s3
    8000253e:	854a                	mv	a0,s2
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	7ee080e7          	jalr	2030(ra) # 80000d2e <memmove>
    return 0;
    80002548:	8526                	mv	a0,s1
    8000254a:	bff9                	j	80002528 <either_copyin+0x32>

000000008000254c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000254c:	715d                	addi	sp,sp,-80
    8000254e:	e486                	sd	ra,72(sp)
    80002550:	e0a2                	sd	s0,64(sp)
    80002552:	fc26                	sd	s1,56(sp)
    80002554:	f84a                	sd	s2,48(sp)
    80002556:	f44e                	sd	s3,40(sp)
    80002558:	f052                	sd	s4,32(sp)
    8000255a:	ec56                	sd	s5,24(sp)
    8000255c:	e85a                	sd	s6,16(sp)
    8000255e:	e45e                	sd	s7,8(sp)
    80002560:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002562:	00006517          	auipc	a0,0x6
    80002566:	b6650513          	addi	a0,a0,-1178 # 800080c8 <digits+0x88>
    8000256a:	ffffe097          	auipc	ra,0xffffe
    8000256e:	01e080e7          	jalr	30(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002572:	0000f497          	auipc	s1,0xf
    80002576:	b8648493          	addi	s1,s1,-1146 # 800110f8 <proc+0x158>
    8000257a:	00015917          	auipc	s2,0x15
    8000257e:	d7e90913          	addi	s2,s2,-642 # 800172f8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002582:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002584:	00006997          	auipc	s3,0x6
    80002588:	cfc98993          	addi	s3,s3,-772 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000258c:	00006a97          	auipc	s5,0x6
    80002590:	cfca8a93          	addi	s5,s5,-772 # 80008288 <digits+0x248>
    printf("\n");
    80002594:	00006a17          	auipc	s4,0x6
    80002598:	b34a0a13          	addi	s4,s4,-1228 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000259c:	00006b97          	auipc	s7,0x6
    800025a0:	d2cb8b93          	addi	s7,s7,-724 # 800082c8 <states.0>
    800025a4:	a00d                	j	800025c6 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025a6:	ed86a583          	lw	a1,-296(a3)
    800025aa:	8556                	mv	a0,s5
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	fdc080e7          	jalr	-36(ra) # 80000588 <printf>
    printf("\n");
    800025b4:	8552                	mv	a0,s4
    800025b6:	ffffe097          	auipc	ra,0xffffe
    800025ba:	fd2080e7          	jalr	-46(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025be:	18848493          	addi	s1,s1,392
    800025c2:	03248163          	beq	s1,s2,800025e4 <procdump+0x98>
    if(p->state == UNUSED)
    800025c6:	86a6                	mv	a3,s1
    800025c8:	ec04a783          	lw	a5,-320(s1)
    800025cc:	dbed                	beqz	a5,800025be <procdump+0x72>
      state = "???";
    800025ce:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025d0:	fcfb6be3          	bltu	s6,a5,800025a6 <procdump+0x5a>
    800025d4:	1782                	slli	a5,a5,0x20
    800025d6:	9381                	srli	a5,a5,0x20
    800025d8:	078e                	slli	a5,a5,0x3
    800025da:	97de                	add	a5,a5,s7
    800025dc:	6390                	ld	a2,0(a5)
    800025de:	f661                	bnez	a2,800025a6 <procdump+0x5a>
      state = "???";
    800025e0:	864e                	mv	a2,s3
    800025e2:	b7d1                	j	800025a6 <procdump+0x5a>
  }
}
    800025e4:	60a6                	ld	ra,72(sp)
    800025e6:	6406                	ld	s0,64(sp)
    800025e8:	74e2                	ld	s1,56(sp)
    800025ea:	7942                	ld	s2,48(sp)
    800025ec:	79a2                	ld	s3,40(sp)
    800025ee:	7a02                	ld	s4,32(sp)
    800025f0:	6ae2                	ld	s5,24(sp)
    800025f2:	6b42                	ld	s6,16(sp)
    800025f4:	6ba2                	ld	s7,8(sp)
    800025f6:	6161                	addi	sp,sp,80
    800025f8:	8082                	ret

00000000800025fa <forkn>:

int forkn(int n, int *pids) {
    800025fa:	714d                	addi	sp,sp,-336
    800025fc:	e686                	sd	ra,328(sp)
    800025fe:	e2a2                	sd	s0,320(sp)
    80002600:	fe26                	sd	s1,312(sp)
    80002602:	fa4a                	sd	s2,304(sp)
    80002604:	f64e                	sd	s3,296(sp)
    80002606:	f252                	sd	s4,288(sp)
    80002608:	ee56                	sd	s5,280(sp)
    8000260a:	ea5a                	sd	s6,272(sp)
    8000260c:	e65e                	sd	s7,264(sp)
    8000260e:	e262                	sd	s8,256(sp)
    80002610:	fde6                	sd	s9,248(sp)
    80002612:	f9ea                	sd	s10,240(sp)
    80002614:	f5ee                	sd	s11,232(sp)
    80002616:	0a80                	addi	s0,sp,336
    80002618:	84aa                	mv	s1,a0
    8000261a:	eaa43c23          	sd	a0,-328(s0)
    8000261e:	ecb43023          	sd	a1,-320(s0)
  struct proc *p = myproc();
    80002622:	fffff097          	auipc	ra,0xfffff
    80002626:	38a080e7          	jalr	906(ra) # 800019ac <myproc>
  struct proc *kids[16];
  int pids_local[16];
  int i, created = 0;

  if(n < 1 || n > 16)
    8000262a:	fff4879b          	addiw	a5,s1,-1
    8000262e:	0007869b          	sext.w	a3,a5
    80002632:	473d                	li	a4,15
    80002634:	20d76f63          	bltu	a4,a3,80002852 <forkn+0x258>
    80002638:	8aaa                	mv	s5,a0
    8000263a:	f1040b93          	addi	s7,s0,-240
    8000263e:	ed040c13          	addi	s8,s0,-304
    80002642:	1782                	slli	a5,a5,0x20
    80002644:	9381                	srli	a5,a5,0x20
    80002646:	ecf43423          	sd	a5,-312(s0)
    8000264a:	00278d93          	addi	s11,a5,2
    8000264e:	8cde                	mv	s9,s7
    80002650:	4b05                	li	s6,1
    80002652:	15050993          	addi	s3,a0,336
    for(int fd = 0; fd < NOFILE; fd++){
      if(p->ofile[fd])
        np->ofile[fd] = filedup(p->ofile[fd]);
    }
    np->cwd = idup(p->cwd);
    safestrcpy(np->name, p->name, sizeof(np->name));
    80002656:	15850d13          	addi	s10,a0,344
    8000265a:	a209                	j	8000275c <forkn+0x162>
      for(int j = 0; j < created; j++){
    8000265c:	1f205d63          	blez	s2,80002856 <forkn+0x25c>
    80002660:	ffe4891b          	addiw	s2,s1,-2
    80002664:	1902                	slli	s2,s2,0x20
    80002666:	02095913          	srli	s2,s2,0x20
    8000266a:	090e                	slli	s2,s2,0x3
    8000266c:	008b8793          	addi	a5,s7,8
    80002670:	993e                	add	s2,s2,a5
        struct proc *child = kids[j];
    80002672:	000bb483          	ld	s1,0(s7)
        acquire(&child->lock);
    80002676:	8526                	mv	a0,s1
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	55e080e7          	jalr	1374(ra) # 80000bd6 <acquire>
        child->state = UNUSED;
    80002680:	0004ac23          	sw	zero,24(s1)
        freeproc(child);
    80002684:	8526                	mv	a0,s1
    80002686:	fffff097          	auipc	ra,0xfffff
    8000268a:	4d8080e7          	jalr	1240(ra) # 80001b5e <freeproc>
        release(&child->lock);
    8000268e:	8526                	mv	a0,s1
    80002690:	ffffe097          	auipc	ra,0xffffe
    80002694:	5fa080e7          	jalr	1530(ra) # 80000c8a <release>
      for(int j = 0; j < created; j++){
    80002698:	0ba1                	addi	s7,s7,8
    8000269a:	fd2b9ce3          	bne	s7,s2,80002672 <forkn+0x78>
      return -1;
    8000269e:	557d                	li	a0,-1
  if(pids){
    if(copyout(p->pagetable, (uint64)pids, (char*)pids_local, n * sizeof(int)) < 0)
      return -1;
  }
  return 0;
}
    800026a0:	60b6                	ld	ra,328(sp)
    800026a2:	6416                	ld	s0,320(sp)
    800026a4:	74f2                	ld	s1,312(sp)
    800026a6:	7952                	ld	s2,304(sp)
    800026a8:	79b2                	ld	s3,296(sp)
    800026aa:	7a12                	ld	s4,288(sp)
    800026ac:	6af2                	ld	s5,280(sp)
    800026ae:	6b52                	ld	s6,272(sp)
    800026b0:	6bb2                	ld	s7,264(sp)
    800026b2:	6c12                	ld	s8,256(sp)
    800026b4:	7cee                	ld	s9,248(sp)
    800026b6:	7d4e                	ld	s10,240(sp)
    800026b8:	7dae                	ld	s11,232(sp)
    800026ba:	6171                	addi	sp,sp,336
    800026bc:	8082                	ret
      freeproc(np);
    800026be:	8552                	mv	a0,s4
    800026c0:	fffff097          	auipc	ra,0xfffff
    800026c4:	49e080e7          	jalr	1182(ra) # 80001b5e <freeproc>
      for(int j = 0; j < created; j++){
    800026c8:	19205963          	blez	s2,8000285a <forkn+0x260>
    800026cc:	34f9                	addiw	s1,s1,-2
    800026ce:	1482                	slli	s1,s1,0x20
    800026d0:	9081                	srli	s1,s1,0x20
    800026d2:	048e                	slli	s1,s1,0x3
    800026d4:	008b8793          	addi	a5,s7,8
    800026d8:	94be                	add	s1,s1,a5
        struct proc *child = kids[j];
    800026da:	000bb903          	ld	s2,0(s7)
        acquire(&child->lock);
    800026de:	854a                	mv	a0,s2
    800026e0:	ffffe097          	auipc	ra,0xffffe
    800026e4:	4f6080e7          	jalr	1270(ra) # 80000bd6 <acquire>
        child->state = UNUSED;
    800026e8:	00092c23          	sw	zero,24(s2)
        freeproc(child);
    800026ec:	854a                	mv	a0,s2
    800026ee:	fffff097          	auipc	ra,0xfffff
    800026f2:	470080e7          	jalr	1136(ra) # 80001b5e <freeproc>
        release(&child->lock);
    800026f6:	854a                	mv	a0,s2
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	592080e7          	jalr	1426(ra) # 80000c8a <release>
      for(int j = 0; j < created; j++){
    80002700:	0ba1                	addi	s7,s7,8
    80002702:	fc9b9ce3          	bne	s7,s1,800026da <forkn+0xe0>
      return -1;
    80002706:	557d                	li	a0,-1
    80002708:	bf61                	j	800026a0 <forkn+0xa6>
        np->ofile[fd] = filedup(p->ofile[fd]);
    8000270a:	00002097          	auipc	ra,0x2
    8000270e:	30c080e7          	jalr	780(ra) # 80004a16 <filedup>
    80002712:	00a93023          	sd	a0,0(s2)
    for(int fd = 0; fd < NOFILE; fd++){
    80002716:	04a1                	addi	s1,s1,8
    80002718:	0921                	addi	s2,s2,8
    8000271a:	01348563          	beq	s1,s3,80002724 <forkn+0x12a>
      if(p->ofile[fd])
    8000271e:	6088                	ld	a0,0(s1)
    80002720:	f56d                	bnez	a0,8000270a <forkn+0x110>
    80002722:	bfd5                	j	80002716 <forkn+0x11c>
    np->cwd = idup(p->cwd);
    80002724:	150ab503          	ld	a0,336(s5)
    80002728:	00001097          	auipc	ra,0x1
    8000272c:	474080e7          	jalr	1140(ra) # 80003b9c <idup>
    80002730:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(np->name));
    80002734:	4641                	li	a2,16
    80002736:	85ea                	mv	a1,s10
    80002738:	158a0513          	addi	a0,s4,344
    8000273c:	ffffe097          	auipc	ra,0xffffe
    80002740:	6e0080e7          	jalr	1760(ra) # 80000e1c <safestrcpy>
    release(&np->lock);
    80002744:	8552                	mv	a0,s4
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	544080e7          	jalr	1348(ra) # 80000c8a <release>
    kids[i] = np;
    8000274e:	014cb023          	sd	s4,0(s9)
  for(i = 0; i < n; i++){
    80002752:	0b05                	addi	s6,s6,1
    80002754:	0ca1                	addi	s9,s9,8
    80002756:	0c11                	addi	s8,s8,4
    80002758:	07bb0f63          	beq	s6,s11,800027d6 <forkn+0x1dc>
    8000275c:	000b049b          	sext.w	s1,s6
    80002760:	fffb091b          	addiw	s2,s6,-1
    struct proc *np = allocproc();
    80002764:	fffff097          	auipc	ra,0xfffff
    80002768:	452080e7          	jalr	1106(ra) # 80001bb6 <allocproc>
    8000276c:	8a2a                	mv	s4,a0
    if(!np){
    8000276e:	ee0507e3          	beqz	a0,8000265c <forkn+0x62>
    pids_local[i] = np->pid;
    80002772:	591c                	lw	a5,48(a0)
    80002774:	00fc2023          	sw	a5,0(s8)
    if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002778:	048ab603          	ld	a2,72(s5)
    8000277c:	692c                	ld	a1,80(a0)
    8000277e:	050ab503          	ld	a0,80(s5)
    80002782:	fffff097          	auipc	ra,0xfffff
    80002786:	de2080e7          	jalr	-542(ra) # 80001564 <uvmcopy>
    8000278a:	f2054ae3          	bltz	a0,800026be <forkn+0xc4>
    np->sz = p->sz;
    8000278e:	048ab783          	ld	a5,72(s5)
    80002792:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002796:	058ab683          	ld	a3,88(s5)
    8000279a:	87b6                	mv	a5,a3
    8000279c:	058a3703          	ld	a4,88(s4)
    800027a0:	12068693          	addi	a3,a3,288
    800027a4:	0007b803          	ld	a6,0(a5)
    800027a8:	6788                	ld	a0,8(a5)
    800027aa:	6b8c                	ld	a1,16(a5)
    800027ac:	6f90                	ld	a2,24(a5)
    800027ae:	01073023          	sd	a6,0(a4)
    800027b2:	e708                	sd	a0,8(a4)
    800027b4:	eb0c                	sd	a1,16(a4)
    800027b6:	ef10                	sd	a2,24(a4)
    800027b8:	02078793          	addi	a5,a5,32
    800027bc:	02070713          	addi	a4,a4,32
    800027c0:	fed792e3          	bne	a5,a3,800027a4 <forkn+0x1aa>
    np->trapframe->a0 = i + 1;
    800027c4:	058a3783          	ld	a5,88(s4)
    800027c8:	0767b823          	sd	s6,112(a5)
    for(int fd = 0; fd < NOFILE; fd++){
    800027cc:	0d0a8493          	addi	s1,s5,208
    800027d0:	0d0a0913          	addi	s2,s4,208
    800027d4:	b7a9                	j	8000271e <forkn+0x124>
  acquire(&wait_lock);
    800027d6:	0000e517          	auipc	a0,0xe
    800027da:	3b250513          	addi	a0,a0,946 # 80010b88 <wait_lock>
    800027de:	ffffe097          	auipc	ra,0xffffe
    800027e2:	3f8080e7          	jalr	1016(ra) # 80000bd6 <acquire>
  for(i = 0; i < n; i++){
    800027e6:	008b8913          	addi	s2,s7,8
    800027ea:	ec843783          	ld	a5,-312(s0)
    800027ee:	078e                	slli	a5,a5,0x3
    800027f0:	993e                	add	s2,s2,a5
    child->state = RUNNABLE;
    800027f2:	498d                	li	s3,3
    struct proc *child = kids[i];
    800027f4:	000bb483          	ld	s1,0(s7)
    child->parent = p;
    800027f8:	0354bc23          	sd	s5,56(s1)
    acquire(&child->lock);
    800027fc:	8526                	mv	a0,s1
    800027fe:	ffffe097          	auipc	ra,0xffffe
    80002802:	3d8080e7          	jalr	984(ra) # 80000bd6 <acquire>
    child->state = RUNNABLE;
    80002806:	0134ac23          	sw	s3,24(s1)
    release(&child->lock);
    8000280a:	8526                	mv	a0,s1
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	47e080e7          	jalr	1150(ra) # 80000c8a <release>
  for(i = 0; i < n; i++){
    80002814:	0ba1                	addi	s7,s7,8
    80002816:	fd2b9fe3          	bne	s7,s2,800027f4 <forkn+0x1fa>
  release(&wait_lock);
    8000281a:	0000e517          	auipc	a0,0xe
    8000281e:	36e50513          	addi	a0,a0,878 # 80010b88 <wait_lock>
    80002822:	ffffe097          	auipc	ra,0xffffe
    80002826:	468080e7          	jalr	1128(ra) # 80000c8a <release>
  return 0;
    8000282a:	4501                	li	a0,0
  if(pids){
    8000282c:	ec043583          	ld	a1,-320(s0)
    80002830:	e60588e3          	beqz	a1,800026a0 <forkn+0xa6>
    if(copyout(p->pagetable, (uint64)pids, (char*)pids_local, n * sizeof(int)) < 0)
    80002834:	eb843783          	ld	a5,-328(s0)
    80002838:	00279693          	slli	a3,a5,0x2
    8000283c:	ed040613          	addi	a2,s0,-304
    80002840:	050ab503          	ld	a0,80(s5)
    80002844:	fffff097          	auipc	ra,0xfffff
    80002848:	e24080e7          	jalr	-476(ra) # 80001668 <copyout>
    8000284c:	41f5551b          	sraiw	a0,a0,0x1f
    80002850:	bd81                	j	800026a0 <forkn+0xa6>
    return -1;
    80002852:	557d                	li	a0,-1
    80002854:	b5b1                	j	800026a0 <forkn+0xa6>
      return -1;
    80002856:	557d                	li	a0,-1
    80002858:	b5a1                	j	800026a0 <forkn+0xa6>
      return -1;
    8000285a:	557d                	li	a0,-1
    8000285c:	b591                	j	800026a0 <forkn+0xa6>

000000008000285e <waitall>:


int
waitall(int* n_addr, int* statuses_addr)
{
    8000285e:	c7010113          	addi	sp,sp,-912
    80002862:	38113423          	sd	ra,904(sp)
    80002866:	38813023          	sd	s0,896(sp)
    8000286a:	36913c23          	sd	s1,888(sp)
    8000286e:	37213823          	sd	s2,880(sp)
    80002872:	37313423          	sd	s3,872(sp)
    80002876:	37413023          	sd	s4,864(sp)
    8000287a:	35513c23          	sd	s5,856(sp)
    8000287e:	35613823          	sd	s6,848(sp)
    80002882:	35713423          	sd	s7,840(sp)
    80002886:	35813023          	sd	s8,832(sp)
    8000288a:	33913c23          	sd	s9,824(sp)
    8000288e:	33a13823          	sd	s10,816(sp)
    80002892:	33b13423          	sd	s11,808(sp)
    80002896:	0f00                	addi	s0,sp,912
    80002898:	8d2a                	mv	s10,a0
    8000289a:	c6b43c23          	sd	a1,-904(s0)
  struct proc *p = myproc();
    8000289e:	fffff097          	auipc	ra,0xfffff
    800028a2:	10e080e7          	jalr	270(ra) # 800019ac <myproc>
    800028a6:	892a                	mv	s2,a0
  struct proc *pp;
  int count = 0;
    800028a8:	f8042623          	sw	zero,-116(s0)
  struct proc *to_free[NPROC]; // temporary array to store pointers for later free
  int free_count = 0;
  int foundChild = 0;

  // Zero out statuses_local.
  for (int i = 0; i < NPROC; i++) {
    800028ac:	e8840793          	addi	a5,s0,-376
    800028b0:	f8840713          	addi	a4,s0,-120
    statuses_local[i] = 0;
    800028b4:	0007a023          	sw	zero,0(a5)
  for (int i = 0; i < NPROC; i++) {
    800028b8:	0791                	addi	a5,a5,4
    800028ba:	fee79de3          	bne	a5,a4,800028b4 <waitall+0x56>
  }

  acquire(&wait_lock);
    800028be:	0000e517          	auipc	a0,0xe
    800028c2:	2ca50513          	addi	a0,a0,714 # 80010b88 <wait_lock>
    800028c6:	ffffe097          	auipc	ra,0xffffe
    800028ca:	310080e7          	jalr	784(ra) # 80000bd6 <acquire>

  for (;;) {
    int allDone = 1;  // assume all children are done until we find one that isn't
    800028ce:	4b05                	li	s6,1
    count = 0;
    free_count = 0;
    foundChild = 0;
    800028d0:	4c01                	li	s8,0
    // Scan through the process table.
    for (pp = proc; pp < &proc[NPROC]; pp++) {
      acquire(&pp->lock);
      if (pp->parent == p) {
        foundChild = 1;
        if (pp->state != ZOMBIE) {
    800028d2:	4b95                	li	s7,5
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800028d4:	00015997          	auipc	s3,0x15
    800028d8:	8cc98993          	addi	s3,s3,-1844 # 800171a0 <tickslock>
    if (killed(p)) {
      release(&wait_lock);
      return -1;
    }
    // Sleep on our process pointer with wait_lock held.
    sleep(p, &wait_lock);
    800028dc:	0000ed97          	auipc	s11,0xe
    800028e0:	2acd8d93          	addi	s11,s11,684 # 80010b88 <wait_lock>
    count = 0;
    800028e4:	f8042623          	sw	zero,-116(s0)
    int allDone = 1;  // assume all children are done until we find one that isn't
    800028e8:	8cda                	mv	s9,s6
    foundChild = 0;
    800028ea:	8a62                	mv	s4,s8
    free_count = 0;
    800028ec:	8ae2                	mv	s5,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800028ee:	0000e497          	auipc	s1,0xe
    800028f2:	6b248493          	addi	s1,s1,1714 # 80010fa0 <proc>
    800028f6:	a089                	j	80002938 <waitall+0xda>
          statuses_local[count] = pp->xstate;
    800028f8:	f8c42783          	lw	a5,-116(s0)
    800028fc:	078a                	slli	a5,a5,0x2
    800028fe:	f9040713          	addi	a4,s0,-112
    80002902:	97ba                	add	a5,a5,a4
    80002904:	54d8                	lw	a4,44(s1)
    80002906:	eee7ac23          	sw	a4,-264(a5)
          to_free[free_count++] = pp;
    8000290a:	003a9793          	slli	a5,s5,0x3
    8000290e:	f9040713          	addi	a4,s0,-112
    80002912:	97ba                	add	a5,a5,a4
    80002914:	ce97bc23          	sd	s1,-776(a5)
    80002918:	2a85                	addiw	s5,s5,1
        count++;
    8000291a:	f8c42783          	lw	a5,-116(s0)
    8000291e:	2785                	addiw	a5,a5,1
    80002920:	f8f42623          	sw	a5,-116(s0)
        foundChild = 1;
    80002924:	8a5a                	mv	s4,s6
      release(&pp->lock);
    80002926:	8526                	mv	a0,s1
    80002928:	ffffe097          	auipc	ra,0xffffe
    8000292c:	362080e7          	jalr	866(ra) # 80000c8a <release>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002930:	18848493          	addi	s1,s1,392
    80002934:	01348f63          	beq	s1,s3,80002952 <waitall+0xf4>
      acquire(&pp->lock);
    80002938:	8526                	mv	a0,s1
    8000293a:	ffffe097          	auipc	ra,0xffffe
    8000293e:	29c080e7          	jalr	668(ra) # 80000bd6 <acquire>
      if (pp->parent == p) {
    80002942:	7c9c                	ld	a5,56(s1)
    80002944:	ff2791e3          	bne	a5,s2,80002926 <waitall+0xc8>
        if (pp->state != ZOMBIE) {
    80002948:	4c9c                	lw	a5,24(s1)
    8000294a:	fb7787e3          	beq	a5,s7,800028f8 <waitall+0x9a>
          allDone = 0;
    8000294e:	8ce2                	mv	s9,s8
    80002950:	b7e9                	j	8000291a <waitall+0xbc>
    if (!foundChild) {
    80002952:	060a0263          	beqz	s4,800029b6 <waitall+0x158>
    if (allDone) {
    80002956:	080c9763          	bnez	s9,800029e4 <waitall+0x186>
    if (killed(p)) {
    8000295a:	854a                	mv	a0,s2
    8000295c:	00000097          	auipc	ra,0x0
    80002960:	9b6080e7          	jalr	-1610(ra) # 80002312 <killed>
    80002964:	10050463          	beqz	a0,80002a6c <waitall+0x20e>
      release(&wait_lock);
    80002968:	0000e517          	auipc	a0,0xe
    8000296c:	22050513          	addi	a0,a0,544 # 80010b88 <wait_lock>
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	31a080e7          	jalr	794(ra) # 80000c8a <release>
      return -1;
    80002978:	5a7d                	li	s4,-1
  }
}
    8000297a:	8552                	mv	a0,s4
    8000297c:	38813083          	ld	ra,904(sp)
    80002980:	38013403          	ld	s0,896(sp)
    80002984:	37813483          	ld	s1,888(sp)
    80002988:	37013903          	ld	s2,880(sp)
    8000298c:	36813983          	ld	s3,872(sp)
    80002990:	36013a03          	ld	s4,864(sp)
    80002994:	35813a83          	ld	s5,856(sp)
    80002998:	35013b03          	ld	s6,848(sp)
    8000299c:	34813b83          	ld	s7,840(sp)
    800029a0:	34013c03          	ld	s8,832(sp)
    800029a4:	33813c83          	ld	s9,824(sp)
    800029a8:	33013d03          	ld	s10,816(sp)
    800029ac:	32813d83          	ld	s11,808(sp)
    800029b0:	39010113          	addi	sp,sp,912
    800029b4:	8082                	ret
      release(&wait_lock);
    800029b6:	0000e517          	auipc	a0,0xe
    800029ba:	1d250513          	addi	a0,a0,466 # 80010b88 <wait_lock>
    800029be:	ffffe097          	auipc	ra,0xffffe
    800029c2:	2cc080e7          	jalr	716(ra) # 80000c8a <release>
      if(n_addr){
    800029c6:	fa0d0ae3          	beqz	s10,8000297a <waitall+0x11c>
        int zero = 0;
    800029ca:	c8042223          	sw	zero,-892(s0)
        copyout(p->pagetable, (uint64)n_addr, (char*)&zero, sizeof(zero));
    800029ce:	4691                	li	a3,4
    800029d0:	c8440613          	addi	a2,s0,-892
    800029d4:	85ea                	mv	a1,s10
    800029d6:	05093503          	ld	a0,80(s2)
    800029da:	fffff097          	auipc	ra,0xfffff
    800029de:	c8e080e7          	jalr	-882(ra) # 80001668 <copyout>
    800029e2:	bf61                	j	8000297a <waitall+0x11c>
      for (int i = 0; i < free_count; i++) {
    800029e4:	05505063          	blez	s5,80002a24 <waitall+0x1c6>
    800029e8:	c8840993          	addi	s3,s0,-888
    800029ec:	fffa849b          	addiw	s1,s5,-1
    800029f0:	1482                	slli	s1,s1,0x20
    800029f2:	9081                	srli	s1,s1,0x20
    800029f4:	048e                	slli	s1,s1,0x3
    800029f6:	c9040793          	addi	a5,s0,-880
    800029fa:	94be                	add	s1,s1,a5
        struct proc *child = to_free[i];
    800029fc:	0009ba03          	ld	s4,0(s3)
        acquire(&child->lock);
    80002a00:	8552                	mv	a0,s4
    80002a02:	ffffe097          	auipc	ra,0xffffe
    80002a06:	1d4080e7          	jalr	468(ra) # 80000bd6 <acquire>
        freeproc(child);
    80002a0a:	8552                	mv	a0,s4
    80002a0c:	fffff097          	auipc	ra,0xfffff
    80002a10:	152080e7          	jalr	338(ra) # 80001b5e <freeproc>
        release(&child->lock);
    80002a14:	8552                	mv	a0,s4
    80002a16:	ffffe097          	auipc	ra,0xffffe
    80002a1a:	274080e7          	jalr	628(ra) # 80000c8a <release>
      for (int i = 0; i < free_count; i++) {
    80002a1e:	09a1                	addi	s3,s3,8
    80002a20:	fc999ee3          	bne	s3,s1,800029fc <waitall+0x19e>
      release(&wait_lock);
    80002a24:	0000e517          	auipc	a0,0xe
    80002a28:	16450513          	addi	a0,a0,356 # 80010b88 <wait_lock>
    80002a2c:	ffffe097          	auipc	ra,0xffffe
    80002a30:	25e080e7          	jalr	606(ra) # 80000c8a <release>
      if(n_addr){
    80002a34:	000d0c63          	beqz	s10,80002a4c <waitall+0x1ee>
        copyout(p->pagetable, (uint64)n_addr, (char*)&count, sizeof(count));
    80002a38:	4691                	li	a3,4
    80002a3a:	f8c40613          	addi	a2,s0,-116
    80002a3e:	85ea                	mv	a1,s10
    80002a40:	05093503          	ld	a0,80(s2)
    80002a44:	fffff097          	auipc	ra,0xfffff
    80002a48:	c24080e7          	jalr	-988(ra) # 80001668 <copyout>
      return 0;
    80002a4c:	4a01                	li	s4,0
      if(statuses_addr){
    80002a4e:	c7843583          	ld	a1,-904(s0)
    80002a52:	d585                	beqz	a1,8000297a <waitall+0x11c>
        copyout(p->pagetable, (uint64)statuses_addr, (char*)statuses_local,
    80002a54:	f8c42683          	lw	a3,-116(s0)
    80002a58:	068a                	slli	a3,a3,0x2
    80002a5a:	e8840613          	addi	a2,s0,-376
    80002a5e:	05093503          	ld	a0,80(s2)
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	c06080e7          	jalr	-1018(ra) # 80001668 <copyout>
    80002a6a:	bf01                	j	8000297a <waitall+0x11c>
    sleep(p, &wait_lock);
    80002a6c:	85ee                	mv	a1,s11
    80002a6e:	854a                	mv	a0,s2
    80002a70:	fffff097          	auipc	ra,0xfffff
    80002a74:	5e4080e7          	jalr	1508(ra) # 80002054 <sleep>
  for (;;) {
    80002a78:	b5b5                	j	800028e4 <waitall+0x86>

0000000080002a7a <swtch>:
    80002a7a:	00153023          	sd	ra,0(a0)
    80002a7e:	00253423          	sd	sp,8(a0)
    80002a82:	e900                	sd	s0,16(a0)
    80002a84:	ed04                	sd	s1,24(a0)
    80002a86:	03253023          	sd	s2,32(a0)
    80002a8a:	03353423          	sd	s3,40(a0)
    80002a8e:	03453823          	sd	s4,48(a0)
    80002a92:	03553c23          	sd	s5,56(a0)
    80002a96:	05653023          	sd	s6,64(a0)
    80002a9a:	05753423          	sd	s7,72(a0)
    80002a9e:	05853823          	sd	s8,80(a0)
    80002aa2:	05953c23          	sd	s9,88(a0)
    80002aa6:	07a53023          	sd	s10,96(a0)
    80002aaa:	07b53423          	sd	s11,104(a0)
    80002aae:	0005b083          	ld	ra,0(a1)
    80002ab2:	0085b103          	ld	sp,8(a1)
    80002ab6:	6980                	ld	s0,16(a1)
    80002ab8:	6d84                	ld	s1,24(a1)
    80002aba:	0205b903          	ld	s2,32(a1)
    80002abe:	0285b983          	ld	s3,40(a1)
    80002ac2:	0305ba03          	ld	s4,48(a1)
    80002ac6:	0385ba83          	ld	s5,56(a1)
    80002aca:	0405bb03          	ld	s6,64(a1)
    80002ace:	0485bb83          	ld	s7,72(a1)
    80002ad2:	0505bc03          	ld	s8,80(a1)
    80002ad6:	0585bc83          	ld	s9,88(a1)
    80002ada:	0605bd03          	ld	s10,96(a1)
    80002ade:	0685bd83          	ld	s11,104(a1)
    80002ae2:	8082                	ret

0000000080002ae4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002ae4:	1141                	addi	sp,sp,-16
    80002ae6:	e406                	sd	ra,8(sp)
    80002ae8:	e022                	sd	s0,0(sp)
    80002aea:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002aec:	00006597          	auipc	a1,0x6
    80002af0:	80c58593          	addi	a1,a1,-2036 # 800082f8 <states.0+0x30>
    80002af4:	00014517          	auipc	a0,0x14
    80002af8:	6ac50513          	addi	a0,a0,1708 # 800171a0 <tickslock>
    80002afc:	ffffe097          	auipc	ra,0xffffe
    80002b00:	04a080e7          	jalr	74(ra) # 80000b46 <initlock>
}
    80002b04:	60a2                	ld	ra,8(sp)
    80002b06:	6402                	ld	s0,0(sp)
    80002b08:	0141                	addi	sp,sp,16
    80002b0a:	8082                	ret

0000000080002b0c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b0c:	1141                	addi	sp,sp,-16
    80002b0e:	e422                	sd	s0,8(sp)
    80002b10:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b12:	00003797          	auipc	a5,0x3
    80002b16:	59e78793          	addi	a5,a5,1438 # 800060b0 <kernelvec>
    80002b1a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b1e:	6422                	ld	s0,8(sp)
    80002b20:	0141                	addi	sp,sp,16
    80002b22:	8082                	ret

0000000080002b24 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b24:	1141                	addi	sp,sp,-16
    80002b26:	e406                	sd	ra,8(sp)
    80002b28:	e022                	sd	s0,0(sp)
    80002b2a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b2c:	fffff097          	auipc	ra,0xfffff
    80002b30:	e80080e7          	jalr	-384(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b38:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b3a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b3e:	00004617          	auipc	a2,0x4
    80002b42:	4c260613          	addi	a2,a2,1218 # 80007000 <_trampoline>
    80002b46:	00004697          	auipc	a3,0x4
    80002b4a:	4ba68693          	addi	a3,a3,1210 # 80007000 <_trampoline>
    80002b4e:	8e91                	sub	a3,a3,a2
    80002b50:	040007b7          	lui	a5,0x4000
    80002b54:	17fd                	addi	a5,a5,-1
    80002b56:	07b2                	slli	a5,a5,0xc
    80002b58:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b5a:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b5e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b60:	180026f3          	csrr	a3,satp
    80002b64:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b66:	6d38                	ld	a4,88(a0)
    80002b68:	6134                	ld	a3,64(a0)
    80002b6a:	6585                	lui	a1,0x1
    80002b6c:	96ae                	add	a3,a3,a1
    80002b6e:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b70:	6d38                	ld	a4,88(a0)
    80002b72:	00000697          	auipc	a3,0x0
    80002b76:	13068693          	addi	a3,a3,304 # 80002ca2 <usertrap>
    80002b7a:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b7c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b7e:	8692                	mv	a3,tp
    80002b80:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b82:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b86:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b8a:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b8e:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b92:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b94:	6f18                	ld	a4,24(a4)
    80002b96:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b9a:	6928                	ld	a0,80(a0)
    80002b9c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b9e:	00004717          	auipc	a4,0x4
    80002ba2:	4fe70713          	addi	a4,a4,1278 # 8000709c <userret>
    80002ba6:	8f11                	sub	a4,a4,a2
    80002ba8:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002baa:	577d                	li	a4,-1
    80002bac:	177e                	slli	a4,a4,0x3f
    80002bae:	8d59                	or	a0,a0,a4
    80002bb0:	9782                	jalr	a5
}
    80002bb2:	60a2                	ld	ra,8(sp)
    80002bb4:	6402                	ld	s0,0(sp)
    80002bb6:	0141                	addi	sp,sp,16
    80002bb8:	8082                	ret

0000000080002bba <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bba:	1101                	addi	sp,sp,-32
    80002bbc:	ec06                	sd	ra,24(sp)
    80002bbe:	e822                	sd	s0,16(sp)
    80002bc0:	e426                	sd	s1,8(sp)
    80002bc2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002bc4:	00014497          	auipc	s1,0x14
    80002bc8:	5dc48493          	addi	s1,s1,1500 # 800171a0 <tickslock>
    80002bcc:	8526                	mv	a0,s1
    80002bce:	ffffe097          	auipc	ra,0xffffe
    80002bd2:	008080e7          	jalr	8(ra) # 80000bd6 <acquire>
  ticks++;
    80002bd6:	00006517          	auipc	a0,0x6
    80002bda:	d2a50513          	addi	a0,a0,-726 # 80008900 <ticks>
    80002bde:	411c                	lw	a5,0(a0)
    80002be0:	2785                	addiw	a5,a5,1
    80002be2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002be4:	fffff097          	auipc	ra,0xfffff
    80002be8:	4d4080e7          	jalr	1236(ra) # 800020b8 <wakeup>
  release(&tickslock);
    80002bec:	8526                	mv	a0,s1
    80002bee:	ffffe097          	auipc	ra,0xffffe
    80002bf2:	09c080e7          	jalr	156(ra) # 80000c8a <release>
}
    80002bf6:	60e2                	ld	ra,24(sp)
    80002bf8:	6442                	ld	s0,16(sp)
    80002bfa:	64a2                	ld	s1,8(sp)
    80002bfc:	6105                	addi	sp,sp,32
    80002bfe:	8082                	ret

0000000080002c00 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002c00:	1101                	addi	sp,sp,-32
    80002c02:	ec06                	sd	ra,24(sp)
    80002c04:	e822                	sd	s0,16(sp)
    80002c06:	e426                	sd	s1,8(sp)
    80002c08:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002c0e:	00074d63          	bltz	a4,80002c28 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002c12:	57fd                	li	a5,-1
    80002c14:	17fe                	slli	a5,a5,0x3f
    80002c16:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c18:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c1a:	06f70363          	beq	a4,a5,80002c80 <devintr+0x80>
  }
}
    80002c1e:	60e2                	ld	ra,24(sp)
    80002c20:	6442                	ld	s0,16(sp)
    80002c22:	64a2                	ld	s1,8(sp)
    80002c24:	6105                	addi	sp,sp,32
    80002c26:	8082                	ret
     (scause & 0xff) == 9){
    80002c28:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002c2c:	46a5                	li	a3,9
    80002c2e:	fed792e3          	bne	a5,a3,80002c12 <devintr+0x12>
    int irq = plic_claim();
    80002c32:	00003097          	auipc	ra,0x3
    80002c36:	586080e7          	jalr	1414(ra) # 800061b8 <plic_claim>
    80002c3a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c3c:	47a9                	li	a5,10
    80002c3e:	02f50763          	beq	a0,a5,80002c6c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002c42:	4785                	li	a5,1
    80002c44:	02f50963          	beq	a0,a5,80002c76 <devintr+0x76>
    return 1;
    80002c48:	4505                	li	a0,1
    } else if(irq){
    80002c4a:	d8f1                	beqz	s1,80002c1e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c4c:	85a6                	mv	a1,s1
    80002c4e:	00005517          	auipc	a0,0x5
    80002c52:	6b250513          	addi	a0,a0,1714 # 80008300 <states.0+0x38>
    80002c56:	ffffe097          	auipc	ra,0xffffe
    80002c5a:	932080e7          	jalr	-1742(ra) # 80000588 <printf>
      plic_complete(irq);
    80002c5e:	8526                	mv	a0,s1
    80002c60:	00003097          	auipc	ra,0x3
    80002c64:	57c080e7          	jalr	1404(ra) # 800061dc <plic_complete>
    return 1;
    80002c68:	4505                	li	a0,1
    80002c6a:	bf55                	j	80002c1e <devintr+0x1e>
      uartintr();
    80002c6c:	ffffe097          	auipc	ra,0xffffe
    80002c70:	d2e080e7          	jalr	-722(ra) # 8000099a <uartintr>
    80002c74:	b7ed                	j	80002c5e <devintr+0x5e>
      virtio_disk_intr();
    80002c76:	00004097          	auipc	ra,0x4
    80002c7a:	a32080e7          	jalr	-1486(ra) # 800066a8 <virtio_disk_intr>
    80002c7e:	b7c5                	j	80002c5e <devintr+0x5e>
    if(cpuid() == 0){
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	d00080e7          	jalr	-768(ra) # 80001980 <cpuid>
    80002c88:	c901                	beqz	a0,80002c98 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c8a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002c8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c90:	14479073          	csrw	sip,a5
    return 2;
    80002c94:	4509                	li	a0,2
    80002c96:	b761                	j	80002c1e <devintr+0x1e>
      clockintr();
    80002c98:	00000097          	auipc	ra,0x0
    80002c9c:	f22080e7          	jalr	-222(ra) # 80002bba <clockintr>
    80002ca0:	b7ed                	j	80002c8a <devintr+0x8a>

0000000080002ca2 <usertrap>:
{
    80002ca2:	1101                	addi	sp,sp,-32
    80002ca4:	ec06                	sd	ra,24(sp)
    80002ca6:	e822                	sd	s0,16(sp)
    80002ca8:	e426                	sd	s1,8(sp)
    80002caa:	e04a                	sd	s2,0(sp)
    80002cac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cae:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cb2:	1007f793          	andi	a5,a5,256
    80002cb6:	e3b1                	bnez	a5,80002cfa <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cb8:	00003797          	auipc	a5,0x3
    80002cbc:	3f878793          	addi	a5,a5,1016 # 800060b0 <kernelvec>
    80002cc0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002cc4:	fffff097          	auipc	ra,0xfffff
    80002cc8:	ce8080e7          	jalr	-792(ra) # 800019ac <myproc>
    80002ccc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002cce:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cd0:	14102773          	csrr	a4,sepc
    80002cd4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cd6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cda:	47a1                	li	a5,8
    80002cdc:	02f70763          	beq	a4,a5,80002d0a <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002ce0:	00000097          	auipc	ra,0x0
    80002ce4:	f20080e7          	jalr	-224(ra) # 80002c00 <devintr>
    80002ce8:	892a                	mv	s2,a0
    80002cea:	c951                	beqz	a0,80002d7e <usertrap+0xdc>
  if(killed(p))
    80002cec:	8526                	mv	a0,s1
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	624080e7          	jalr	1572(ra) # 80002312 <killed>
    80002cf6:	cd29                	beqz	a0,80002d50 <usertrap+0xae>
    80002cf8:	a099                	j	80002d3e <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002cfa:	00005517          	auipc	a0,0x5
    80002cfe:	62650513          	addi	a0,a0,1574 # 80008320 <states.0+0x58>
    80002d02:	ffffe097          	auipc	ra,0xffffe
    80002d06:	83c080e7          	jalr	-1988(ra) # 8000053e <panic>
    if(killed(p))
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	608080e7          	jalr	1544(ra) # 80002312 <killed>
    80002d12:	ed21                	bnez	a0,80002d6a <usertrap+0xc8>
    p->trapframe->epc += 4;
    80002d14:	6cb8                	ld	a4,88(s1)
    80002d16:	6f1c                	ld	a5,24(a4)
    80002d18:	0791                	addi	a5,a5,4
    80002d1a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d20:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d24:	10079073          	csrw	sstatus,a5
    syscall();
    80002d28:	00000097          	auipc	ra,0x0
    80002d2c:	2e4080e7          	jalr	740(ra) # 8000300c <syscall>
  if(killed(p))
    80002d30:	8526                	mv	a0,s1
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	5e0080e7          	jalr	1504(ra) # 80002312 <killed>
    80002d3a:	cd11                	beqz	a0,80002d56 <usertrap+0xb4>
    80002d3c:	4901                	li	s2,0
    exit(-1,"");
    80002d3e:	00005597          	auipc	a1,0x5
    80002d42:	62a58593          	addi	a1,a1,1578 # 80008368 <states.0+0xa0>
    80002d46:	557d                	li	a0,-1
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	440080e7          	jalr	1088(ra) # 80002188 <exit>
  if(which_dev == 2)
    80002d50:	4789                	li	a5,2
    80002d52:	06f90363          	beq	s2,a5,80002db8 <usertrap+0x116>
  usertrapret();
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	dce080e7          	jalr	-562(ra) # 80002b24 <usertrapret>
}
    80002d5e:	60e2                	ld	ra,24(sp)
    80002d60:	6442                	ld	s0,16(sp)
    80002d62:	64a2                	ld	s1,8(sp)
    80002d64:	6902                	ld	s2,0(sp)
    80002d66:	6105                	addi	sp,sp,32
    80002d68:	8082                	ret
      exit(-1,"");
    80002d6a:	00005597          	auipc	a1,0x5
    80002d6e:	5fe58593          	addi	a1,a1,1534 # 80008368 <states.0+0xa0>
    80002d72:	557d                	li	a0,-1
    80002d74:	fffff097          	auipc	ra,0xfffff
    80002d78:	414080e7          	jalr	1044(ra) # 80002188 <exit>
    80002d7c:	bf61                	j	80002d14 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d7e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d82:	5890                	lw	a2,48(s1)
    80002d84:	00005517          	auipc	a0,0x5
    80002d88:	5bc50513          	addi	a0,a0,1468 # 80008340 <states.0+0x78>
    80002d8c:	ffffd097          	auipc	ra,0xffffd
    80002d90:	7fc080e7          	jalr	2044(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d94:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d98:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d9c:	00005517          	auipc	a0,0x5
    80002da0:	5d450513          	addi	a0,a0,1492 # 80008370 <states.0+0xa8>
    80002da4:	ffffd097          	auipc	ra,0xffffd
    80002da8:	7e4080e7          	jalr	2020(ra) # 80000588 <printf>
    setkilled(p);
    80002dac:	8526                	mv	a0,s1
    80002dae:	fffff097          	auipc	ra,0xfffff
    80002db2:	538080e7          	jalr	1336(ra) # 800022e6 <setkilled>
    80002db6:	bfad                	j	80002d30 <usertrap+0x8e>
    yield();
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	260080e7          	jalr	608(ra) # 80002018 <yield>
    80002dc0:	bf59                	j	80002d56 <usertrap+0xb4>

0000000080002dc2 <kerneltrap>:
{
    80002dc2:	7179                	addi	sp,sp,-48
    80002dc4:	f406                	sd	ra,40(sp)
    80002dc6:	f022                	sd	s0,32(sp)
    80002dc8:	ec26                	sd	s1,24(sp)
    80002dca:	e84a                	sd	s2,16(sp)
    80002dcc:	e44e                	sd	s3,8(sp)
    80002dce:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dd0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dd4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002dd8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ddc:	1004f793          	andi	a5,s1,256
    80002de0:	cb85                	beqz	a5,80002e10 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002de2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002de6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002de8:	ef85                	bnez	a5,80002e20 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002dea:	00000097          	auipc	ra,0x0
    80002dee:	e16080e7          	jalr	-490(ra) # 80002c00 <devintr>
    80002df2:	cd1d                	beqz	a0,80002e30 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002df4:	4789                	li	a5,2
    80002df6:	06f50a63          	beq	a0,a5,80002e6a <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dfa:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dfe:	10049073          	csrw	sstatus,s1
}
    80002e02:	70a2                	ld	ra,40(sp)
    80002e04:	7402                	ld	s0,32(sp)
    80002e06:	64e2                	ld	s1,24(sp)
    80002e08:	6942                	ld	s2,16(sp)
    80002e0a:	69a2                	ld	s3,8(sp)
    80002e0c:	6145                	addi	sp,sp,48
    80002e0e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e10:	00005517          	auipc	a0,0x5
    80002e14:	58050513          	addi	a0,a0,1408 # 80008390 <states.0+0xc8>
    80002e18:	ffffd097          	auipc	ra,0xffffd
    80002e1c:	726080e7          	jalr	1830(ra) # 8000053e <panic>
    panic("kerneltrap: interrupts enabled");
    80002e20:	00005517          	auipc	a0,0x5
    80002e24:	59850513          	addi	a0,a0,1432 # 800083b8 <states.0+0xf0>
    80002e28:	ffffd097          	auipc	ra,0xffffd
    80002e2c:	716080e7          	jalr	1814(ra) # 8000053e <panic>
    printf("scause %p\n", scause);
    80002e30:	85ce                	mv	a1,s3
    80002e32:	00005517          	auipc	a0,0x5
    80002e36:	5a650513          	addi	a0,a0,1446 # 800083d8 <states.0+0x110>
    80002e3a:	ffffd097          	auipc	ra,0xffffd
    80002e3e:	74e080e7          	jalr	1870(ra) # 80000588 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e42:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e46:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e4a:	00005517          	auipc	a0,0x5
    80002e4e:	59e50513          	addi	a0,a0,1438 # 800083e8 <states.0+0x120>
    80002e52:	ffffd097          	auipc	ra,0xffffd
    80002e56:	736080e7          	jalr	1846(ra) # 80000588 <printf>
    panic("kerneltrap");
    80002e5a:	00005517          	auipc	a0,0x5
    80002e5e:	5a650513          	addi	a0,a0,1446 # 80008400 <states.0+0x138>
    80002e62:	ffffd097          	auipc	ra,0xffffd
    80002e66:	6dc080e7          	jalr	1756(ra) # 8000053e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e6a:	fffff097          	auipc	ra,0xfffff
    80002e6e:	b42080e7          	jalr	-1214(ra) # 800019ac <myproc>
    80002e72:	d541                	beqz	a0,80002dfa <kerneltrap+0x38>
    80002e74:	fffff097          	auipc	ra,0xfffff
    80002e78:	b38080e7          	jalr	-1224(ra) # 800019ac <myproc>
    80002e7c:	4d18                	lw	a4,24(a0)
    80002e7e:	4791                	li	a5,4
    80002e80:	f6f71de3          	bne	a4,a5,80002dfa <kerneltrap+0x38>
    yield();
    80002e84:	fffff097          	auipc	ra,0xfffff
    80002e88:	194080e7          	jalr	404(ra) # 80002018 <yield>
    80002e8c:	b7bd                	j	80002dfa <kerneltrap+0x38>

0000000080002e8e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e8e:	1101                	addi	sp,sp,-32
    80002e90:	ec06                	sd	ra,24(sp)
    80002e92:	e822                	sd	s0,16(sp)
    80002e94:	e426                	sd	s1,8(sp)
    80002e96:	1000                	addi	s0,sp,32
    80002e98:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	b12080e7          	jalr	-1262(ra) # 800019ac <myproc>
  switch (n) {
    80002ea2:	4795                	li	a5,5
    80002ea4:	0497e163          	bltu	a5,s1,80002ee6 <argraw+0x58>
    80002ea8:	048a                	slli	s1,s1,0x2
    80002eaa:	00005717          	auipc	a4,0x5
    80002eae:	58e70713          	addi	a4,a4,1422 # 80008438 <states.0+0x170>
    80002eb2:	94ba                	add	s1,s1,a4
    80002eb4:	409c                	lw	a5,0(s1)
    80002eb6:	97ba                	add	a5,a5,a4
    80002eb8:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002eba:	6d3c                	ld	a5,88(a0)
    80002ebc:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ebe:	60e2                	ld	ra,24(sp)
    80002ec0:	6442                	ld	s0,16(sp)
    80002ec2:	64a2                	ld	s1,8(sp)
    80002ec4:	6105                	addi	sp,sp,32
    80002ec6:	8082                	ret
    return p->trapframe->a1;
    80002ec8:	6d3c                	ld	a5,88(a0)
    80002eca:	7fa8                	ld	a0,120(a5)
    80002ecc:	bfcd                	j	80002ebe <argraw+0x30>
    return p->trapframe->a2;
    80002ece:	6d3c                	ld	a5,88(a0)
    80002ed0:	63c8                	ld	a0,128(a5)
    80002ed2:	b7f5                	j	80002ebe <argraw+0x30>
    return p->trapframe->a3;
    80002ed4:	6d3c                	ld	a5,88(a0)
    80002ed6:	67c8                	ld	a0,136(a5)
    80002ed8:	b7dd                	j	80002ebe <argraw+0x30>
    return p->trapframe->a4;
    80002eda:	6d3c                	ld	a5,88(a0)
    80002edc:	6bc8                	ld	a0,144(a5)
    80002ede:	b7c5                	j	80002ebe <argraw+0x30>
    return p->trapframe->a5;
    80002ee0:	6d3c                	ld	a5,88(a0)
    80002ee2:	6fc8                	ld	a0,152(a5)
    80002ee4:	bfe9                	j	80002ebe <argraw+0x30>
  panic("argraw");
    80002ee6:	00005517          	auipc	a0,0x5
    80002eea:	52a50513          	addi	a0,a0,1322 # 80008410 <states.0+0x148>
    80002eee:	ffffd097          	auipc	ra,0xffffd
    80002ef2:	650080e7          	jalr	1616(ra) # 8000053e <panic>

0000000080002ef6 <fetchaddr>:
{
    80002ef6:	1101                	addi	sp,sp,-32
    80002ef8:	ec06                	sd	ra,24(sp)
    80002efa:	e822                	sd	s0,16(sp)
    80002efc:	e426                	sd	s1,8(sp)
    80002efe:	e04a                	sd	s2,0(sp)
    80002f00:	1000                	addi	s0,sp,32
    80002f02:	84aa                	mv	s1,a0
    80002f04:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	aa6080e7          	jalr	-1370(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002f0e:	653c                	ld	a5,72(a0)
    80002f10:	02f4f863          	bgeu	s1,a5,80002f40 <fetchaddr+0x4a>
    80002f14:	00848713          	addi	a4,s1,8
    80002f18:	02e7e663          	bltu	a5,a4,80002f44 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f1c:	46a1                	li	a3,8
    80002f1e:	8626                	mv	a2,s1
    80002f20:	85ca                	mv	a1,s2
    80002f22:	6928                	ld	a0,80(a0)
    80002f24:	ffffe097          	auipc	ra,0xffffe
    80002f28:	7d0080e7          	jalr	2000(ra) # 800016f4 <copyin>
    80002f2c:	00a03533          	snez	a0,a0
    80002f30:	40a00533          	neg	a0,a0
}
    80002f34:	60e2                	ld	ra,24(sp)
    80002f36:	6442                	ld	s0,16(sp)
    80002f38:	64a2                	ld	s1,8(sp)
    80002f3a:	6902                	ld	s2,0(sp)
    80002f3c:	6105                	addi	sp,sp,32
    80002f3e:	8082                	ret
    return -1;
    80002f40:	557d                	li	a0,-1
    80002f42:	bfcd                	j	80002f34 <fetchaddr+0x3e>
    80002f44:	557d                	li	a0,-1
    80002f46:	b7fd                	j	80002f34 <fetchaddr+0x3e>

0000000080002f48 <fetchstr>:
{
    80002f48:	7179                	addi	sp,sp,-48
    80002f4a:	f406                	sd	ra,40(sp)
    80002f4c:	f022                	sd	s0,32(sp)
    80002f4e:	ec26                	sd	s1,24(sp)
    80002f50:	e84a                	sd	s2,16(sp)
    80002f52:	e44e                	sd	s3,8(sp)
    80002f54:	1800                	addi	s0,sp,48
    80002f56:	892a                	mv	s2,a0
    80002f58:	84ae                	mv	s1,a1
    80002f5a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002f5c:	fffff097          	auipc	ra,0xfffff
    80002f60:	a50080e7          	jalr	-1456(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f64:	86ce                	mv	a3,s3
    80002f66:	864a                	mv	a2,s2
    80002f68:	85a6                	mv	a1,s1
    80002f6a:	6928                	ld	a0,80(a0)
    80002f6c:	fffff097          	auipc	ra,0xfffff
    80002f70:	816080e7          	jalr	-2026(ra) # 80001782 <copyinstr>
    80002f74:	00054e63          	bltz	a0,80002f90 <fetchstr+0x48>
  return strlen(buf);
    80002f78:	8526                	mv	a0,s1
    80002f7a:	ffffe097          	auipc	ra,0xffffe
    80002f7e:	ed4080e7          	jalr	-300(ra) # 80000e4e <strlen>
}
    80002f82:	70a2                	ld	ra,40(sp)
    80002f84:	7402                	ld	s0,32(sp)
    80002f86:	64e2                	ld	s1,24(sp)
    80002f88:	6942                	ld	s2,16(sp)
    80002f8a:	69a2                	ld	s3,8(sp)
    80002f8c:	6145                	addi	sp,sp,48
    80002f8e:	8082                	ret
    return -1;
    80002f90:	557d                	li	a0,-1
    80002f92:	bfc5                	j	80002f82 <fetchstr+0x3a>

0000000080002f94 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002f94:	1101                	addi	sp,sp,-32
    80002f96:	ec06                	sd	ra,24(sp)
    80002f98:	e822                	sd	s0,16(sp)
    80002f9a:	e426                	sd	s1,8(sp)
    80002f9c:	1000                	addi	s0,sp,32
    80002f9e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fa0:	00000097          	auipc	ra,0x0
    80002fa4:	eee080e7          	jalr	-274(ra) # 80002e8e <argraw>
    80002fa8:	c088                	sw	a0,0(s1)
}
    80002faa:	60e2                	ld	ra,24(sp)
    80002fac:	6442                	ld	s0,16(sp)
    80002fae:	64a2                	ld	s1,8(sp)
    80002fb0:	6105                	addi	sp,sp,32
    80002fb2:	8082                	ret

0000000080002fb4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002fb4:	1101                	addi	sp,sp,-32
    80002fb6:	ec06                	sd	ra,24(sp)
    80002fb8:	e822                	sd	s0,16(sp)
    80002fba:	e426                	sd	s1,8(sp)
    80002fbc:	1000                	addi	s0,sp,32
    80002fbe:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002fc0:	00000097          	auipc	ra,0x0
    80002fc4:	ece080e7          	jalr	-306(ra) # 80002e8e <argraw>
    80002fc8:	e088                	sd	a0,0(s1)
}
    80002fca:	60e2                	ld	ra,24(sp)
    80002fcc:	6442                	ld	s0,16(sp)
    80002fce:	64a2                	ld	s1,8(sp)
    80002fd0:	6105                	addi	sp,sp,32
    80002fd2:	8082                	ret

0000000080002fd4 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002fd4:	7179                	addi	sp,sp,-48
    80002fd6:	f406                	sd	ra,40(sp)
    80002fd8:	f022                	sd	s0,32(sp)
    80002fda:	ec26                	sd	s1,24(sp)
    80002fdc:	e84a                	sd	s2,16(sp)
    80002fde:	1800                	addi	s0,sp,48
    80002fe0:	84ae                	mv	s1,a1
    80002fe2:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002fe4:	fd840593          	addi	a1,s0,-40
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	fcc080e7          	jalr	-52(ra) # 80002fb4 <argaddr>
  return fetchstr(addr, buf, max);
    80002ff0:	864a                	mv	a2,s2
    80002ff2:	85a6                	mv	a1,s1
    80002ff4:	fd843503          	ld	a0,-40(s0)
    80002ff8:	00000097          	auipc	ra,0x0
    80002ffc:	f50080e7          	jalr	-176(ra) # 80002f48 <fetchstr>
}
    80003000:	70a2                	ld	ra,40(sp)
    80003002:	7402                	ld	s0,32(sp)
    80003004:	64e2                	ld	s1,24(sp)
    80003006:	6942                	ld	s2,16(sp)
    80003008:	6145                	addi	sp,sp,48
    8000300a:	8082                	ret

000000008000300c <syscall>:

};

void
syscall(void)
{
    8000300c:	1101                	addi	sp,sp,-32
    8000300e:	ec06                	sd	ra,24(sp)
    80003010:	e822                	sd	s0,16(sp)
    80003012:	e426                	sd	s1,8(sp)
    80003014:	e04a                	sd	s2,0(sp)
    80003016:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80003018:	fffff097          	auipc	ra,0xfffff
    8000301c:	994080e7          	jalr	-1644(ra) # 800019ac <myproc>
    80003020:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80003022:	05853903          	ld	s2,88(a0)
    80003026:	0a893783          	ld	a5,168(s2)
    8000302a:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000302e:	37fd                	addiw	a5,a5,-1
    80003030:	475d                	li	a4,23
    80003032:	00f76f63          	bltu	a4,a5,80003050 <syscall+0x44>
    80003036:	00369713          	slli	a4,a3,0x3
    8000303a:	00005797          	auipc	a5,0x5
    8000303e:	41678793          	addi	a5,a5,1046 # 80008450 <syscalls>
    80003042:	97ba                	add	a5,a5,a4
    80003044:	639c                	ld	a5,0(a5)
    80003046:	c789                	beqz	a5,80003050 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80003048:	9782                	jalr	a5
    8000304a:	06a93823          	sd	a0,112(s2)
    8000304e:	a839                	j	8000306c <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003050:	15848613          	addi	a2,s1,344
    80003054:	588c                	lw	a1,48(s1)
    80003056:	00005517          	auipc	a0,0x5
    8000305a:	3c250513          	addi	a0,a0,962 # 80008418 <states.0+0x150>
    8000305e:	ffffd097          	auipc	ra,0xffffd
    80003062:	52a080e7          	jalr	1322(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80003066:	6cbc                	ld	a5,88(s1)
    80003068:	577d                	li	a4,-1
    8000306a:	fbb8                	sd	a4,112(a5)
  }
}
    8000306c:	60e2                	ld	ra,24(sp)
    8000306e:	6442                	ld	s0,16(sp)
    80003070:	64a2                	ld	s1,8(sp)
    80003072:	6902                	ld	s2,0(sp)
    80003074:	6105                	addi	sp,sp,32
    80003076:	8082                	ret

0000000080003078 <sys_exit>:
#include "proc.h"


uint64
sys_exit(void)
{
    80003078:	7139                	addi	sp,sp,-64
    8000307a:	fc06                	sd	ra,56(sp)
    8000307c:	f822                	sd	s0,48(sp)
    8000307e:	0080                	addi	s0,sp,64
  int status;
  uint64 msgaddr;     
  argint(0, &status);  // first arg: status
    80003080:	fec40593          	addi	a1,s0,-20
    80003084:	4501                	li	a0,0
    80003086:	00000097          	auipc	ra,0x0
    8000308a:	f0e080e7          	jalr	-242(ra) # 80002f94 <argint>
  argaddr(1, &msgaddr);// second arg: pointer to msg
    8000308e:	fe040593          	addi	a1,s0,-32
    80003092:	4505                	li	a0,1
    80003094:	00000097          	auipc	ra,0x0
    80003098:	f20080e7          	jalr	-224(ra) # 80002fb4 <argaddr>

  // We'll fetch the string from user space into a kernel buffer.
  char msgbuf[32];
  if(msgaddr != 0){
    8000309c:	fe043503          	ld	a0,-32(s0)
    800030a0:	e105                	bnez	a0,800030c0 <sys_exit+0x48>
      // invalid pointer or too long => just empty
      msgbuf[0] = '\0';
    }
  } else {
    // if user passed NULL
    msgbuf[0] = '\0';
    800030a2:	fc040023          	sb	zero,-64(s0)
  }

  exit(status, msgbuf);
    800030a6:	fc040593          	addi	a1,s0,-64
    800030aa:	fec42503          	lw	a0,-20(s0)
    800030ae:	fffff097          	auipc	ra,0xfffff
    800030b2:	0da080e7          	jalr	218(ra) # 80002188 <exit>
  return 0; // not reached
}
    800030b6:	4501                	li	a0,0
    800030b8:	70e2                	ld	ra,56(sp)
    800030ba:	7442                	ld	s0,48(sp)
    800030bc:	6121                	addi	sp,sp,64
    800030be:	8082                	ret
    if(fetchstr(msgaddr, msgbuf, sizeof(msgbuf)) < 0){
    800030c0:	02000613          	li	a2,32
    800030c4:	fc040593          	addi	a1,s0,-64
    800030c8:	00000097          	auipc	ra,0x0
    800030cc:	e80080e7          	jalr	-384(ra) # 80002f48 <fetchstr>
    800030d0:	fc055be3          	bgez	a0,800030a6 <sys_exit+0x2e>
      msgbuf[0] = '\0';
    800030d4:	fc040023          	sb	zero,-64(s0)
    800030d8:	b7f9                	j	800030a6 <sys_exit+0x2e>

00000000800030da <sys_getpid>:

uint64
sys_getpid(void)
{
    800030da:	1141                	addi	sp,sp,-16
    800030dc:	e406                	sd	ra,8(sp)
    800030de:	e022                	sd	s0,0(sp)
    800030e0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800030e2:	fffff097          	auipc	ra,0xfffff
    800030e6:	8ca080e7          	jalr	-1846(ra) # 800019ac <myproc>
}
    800030ea:	5908                	lw	a0,48(a0)
    800030ec:	60a2                	ld	ra,8(sp)
    800030ee:	6402                	ld	s0,0(sp)
    800030f0:	0141                	addi	sp,sp,16
    800030f2:	8082                	ret

00000000800030f4 <sys_fork>:

uint64
sys_fork(void)
{
    800030f4:	1141                	addi	sp,sp,-16
    800030f6:	e406                	sd	ra,8(sp)
    800030f8:	e022                	sd	s0,0(sp)
    800030fa:	0800                	addi	s0,sp,16
  return fork();
    800030fc:	fffff097          	auipc	ra,0xfffff
    80003100:	c66080e7          	jalr	-922(ra) # 80001d62 <fork>
}
    80003104:	60a2                	ld	ra,8(sp)
    80003106:	6402                	ld	s0,0(sp)
    80003108:	0141                	addi	sp,sp,16
    8000310a:	8082                	ret

000000008000310c <sys_wait>:

uint64
sys_wait(void)
{
    8000310c:	1101                	addi	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	1000                	addi	s0,sp,32
  uint64 statusaddr; 
  uint64 msgaddr;   
  argaddr(0, &statusaddr);
    80003114:	fe840593          	addi	a1,s0,-24
    80003118:	4501                	li	a0,0
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	e9a080e7          	jalr	-358(ra) # 80002fb4 <argaddr>
  argaddr(1, &msgaddr);
    80003122:	fe040593          	addi	a1,s0,-32
    80003126:	4505                	li	a0,1
    80003128:	00000097          	auipc	ra,0x0
    8000312c:	e8c080e7          	jalr	-372(ra) # 80002fb4 <argaddr>

  return wait(statusaddr, (char*) msgaddr);
    80003130:	fe043583          	ld	a1,-32(s0)
    80003134:	fe843503          	ld	a0,-24(s0)
    80003138:	fffff097          	auipc	ra,0xfffff
    8000313c:	20c080e7          	jalr	524(ra) # 80002344 <wait>
}
    80003140:	60e2                	ld	ra,24(sp)
    80003142:	6442                	ld	s0,16(sp)
    80003144:	6105                	addi	sp,sp,32
    80003146:	8082                	ret

0000000080003148 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003148:	7179                	addi	sp,sp,-48
    8000314a:	f406                	sd	ra,40(sp)
    8000314c:	f022                	sd	s0,32(sp)
    8000314e:	ec26                	sd	s1,24(sp)
    80003150:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80003152:	fdc40593          	addi	a1,s0,-36
    80003156:	4501                	li	a0,0
    80003158:	00000097          	auipc	ra,0x0
    8000315c:	e3c080e7          	jalr	-452(ra) # 80002f94 <argint>
  addr = myproc()->sz;
    80003160:	fffff097          	auipc	ra,0xfffff
    80003164:	84c080e7          	jalr	-1972(ra) # 800019ac <myproc>
    80003168:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000316a:	fdc42503          	lw	a0,-36(s0)
    8000316e:	fffff097          	auipc	ra,0xfffff
    80003172:	b98080e7          	jalr	-1128(ra) # 80001d06 <growproc>
    80003176:	00054863          	bltz	a0,80003186 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000317a:	8526                	mv	a0,s1
    8000317c:	70a2                	ld	ra,40(sp)
    8000317e:	7402                	ld	s0,32(sp)
    80003180:	64e2                	ld	s1,24(sp)
    80003182:	6145                	addi	sp,sp,48
    80003184:	8082                	ret
    return -1;
    80003186:	54fd                	li	s1,-1
    80003188:	bfcd                	j	8000317a <sys_sbrk+0x32>

000000008000318a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000318a:	7139                	addi	sp,sp,-64
    8000318c:	fc06                	sd	ra,56(sp)
    8000318e:	f822                	sd	s0,48(sp)
    80003190:	f426                	sd	s1,40(sp)
    80003192:	f04a                	sd	s2,32(sp)
    80003194:	ec4e                	sd	s3,24(sp)
    80003196:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003198:	fcc40593          	addi	a1,s0,-52
    8000319c:	4501                	li	a0,0
    8000319e:	00000097          	auipc	ra,0x0
    800031a2:	df6080e7          	jalr	-522(ra) # 80002f94 <argint>
  acquire(&tickslock);
    800031a6:	00014517          	auipc	a0,0x14
    800031aa:	ffa50513          	addi	a0,a0,-6 # 800171a0 <tickslock>
    800031ae:	ffffe097          	auipc	ra,0xffffe
    800031b2:	a28080e7          	jalr	-1496(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    800031b6:	00005917          	auipc	s2,0x5
    800031ba:	74a92903          	lw	s2,1866(s2) # 80008900 <ticks>
  while(ticks - ticks0 < n){
    800031be:	fcc42783          	lw	a5,-52(s0)
    800031c2:	cf9d                	beqz	a5,80003200 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800031c4:	00014997          	auipc	s3,0x14
    800031c8:	fdc98993          	addi	s3,s3,-36 # 800171a0 <tickslock>
    800031cc:	00005497          	auipc	s1,0x5
    800031d0:	73448493          	addi	s1,s1,1844 # 80008900 <ticks>
    if(killed(myproc())){
    800031d4:	ffffe097          	auipc	ra,0xffffe
    800031d8:	7d8080e7          	jalr	2008(ra) # 800019ac <myproc>
    800031dc:	fffff097          	auipc	ra,0xfffff
    800031e0:	136080e7          	jalr	310(ra) # 80002312 <killed>
    800031e4:	ed15                	bnez	a0,80003220 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    800031e6:	85ce                	mv	a1,s3
    800031e8:	8526                	mv	a0,s1
    800031ea:	fffff097          	auipc	ra,0xfffff
    800031ee:	e6a080e7          	jalr	-406(ra) # 80002054 <sleep>
  while(ticks - ticks0 < n){
    800031f2:	409c                	lw	a5,0(s1)
    800031f4:	412787bb          	subw	a5,a5,s2
    800031f8:	fcc42703          	lw	a4,-52(s0)
    800031fc:	fce7ece3          	bltu	a5,a4,800031d4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80003200:	00014517          	auipc	a0,0x14
    80003204:	fa050513          	addi	a0,a0,-96 # 800171a0 <tickslock>
    80003208:	ffffe097          	auipc	ra,0xffffe
    8000320c:	a82080e7          	jalr	-1406(ra) # 80000c8a <release>
  return 0;
    80003210:	4501                	li	a0,0
}
    80003212:	70e2                	ld	ra,56(sp)
    80003214:	7442                	ld	s0,48(sp)
    80003216:	74a2                	ld	s1,40(sp)
    80003218:	7902                	ld	s2,32(sp)
    8000321a:	69e2                	ld	s3,24(sp)
    8000321c:	6121                	addi	sp,sp,64
    8000321e:	8082                	ret
      release(&tickslock);
    80003220:	00014517          	auipc	a0,0x14
    80003224:	f8050513          	addi	a0,a0,-128 # 800171a0 <tickslock>
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	a62080e7          	jalr	-1438(ra) # 80000c8a <release>
      return -1;
    80003230:	557d                	li	a0,-1
    80003232:	b7c5                	j	80003212 <sys_sleep+0x88>

0000000080003234 <sys_kill>:

uint64
sys_kill(void)
{
    80003234:	1101                	addi	sp,sp,-32
    80003236:	ec06                	sd	ra,24(sp)
    80003238:	e822                	sd	s0,16(sp)
    8000323a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000323c:	fec40593          	addi	a1,s0,-20
    80003240:	4501                	li	a0,0
    80003242:	00000097          	auipc	ra,0x0
    80003246:	d52080e7          	jalr	-686(ra) # 80002f94 <argint>
  return kill(pid);
    8000324a:	fec42503          	lw	a0,-20(s0)
    8000324e:	fffff097          	auipc	ra,0xfffff
    80003252:	026080e7          	jalr	38(ra) # 80002274 <kill>
}
    80003256:	60e2                	ld	ra,24(sp)
    80003258:	6442                	ld	s0,16(sp)
    8000325a:	6105                	addi	sp,sp,32
    8000325c:	8082                	ret

000000008000325e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	e426                	sd	s1,8(sp)
    80003266:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003268:	00014517          	auipc	a0,0x14
    8000326c:	f3850513          	addi	a0,a0,-200 # 800171a0 <tickslock>
    80003270:	ffffe097          	auipc	ra,0xffffe
    80003274:	966080e7          	jalr	-1690(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80003278:	00005497          	auipc	s1,0x5
    8000327c:	6884a483          	lw	s1,1672(s1) # 80008900 <ticks>
  release(&tickslock);
    80003280:	00014517          	auipc	a0,0x14
    80003284:	f2050513          	addi	a0,a0,-224 # 800171a0 <tickslock>
    80003288:	ffffe097          	auipc	ra,0xffffe
    8000328c:	a02080e7          	jalr	-1534(ra) # 80000c8a <release>
  return xticks;
}
    80003290:	02049513          	slli	a0,s1,0x20
    80003294:	9101                	srli	a0,a0,0x20
    80003296:	60e2                	ld	ra,24(sp)
    80003298:	6442                	ld	s0,16(sp)
    8000329a:	64a2                	ld	s1,8(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret

00000000800032a0 <sys_memsize>:

uint64 sys_memsize(void){
    800032a0:	1141                	addi	sp,sp,-16
    800032a2:	e406                	sd	ra,8(sp)
    800032a4:	e022                	sd	s0,0(sp)
    800032a6:	0800                	addi	s0,sp,16

  uint64 size;
  size = myproc()->sz;
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	704080e7          	jalr	1796(ra) # 800019ac <myproc>
  
  return size;
}
    800032b0:	6528                	ld	a0,72(a0)
    800032b2:	60a2                	ld	ra,8(sp)
    800032b4:	6402                	ld	s0,0(sp)
    800032b6:	0141                	addi	sp,sp,16
    800032b8:	8082                	ret

00000000800032ba <sys_forkn>:

uint64
sys_forkn(void)
{
    800032ba:	1101                	addi	sp,sp,-32
    800032bc:	ec06                	sd	ra,24(sp)
    800032be:	e822                	sd	s0,16(sp)
    800032c0:	1000                	addi	s0,sp,32
  int n;  
  uint64 pids_addr;     
  argint(0, &n);  
    800032c2:	fec40593          	addi	a1,s0,-20
    800032c6:	4501                	li	a0,0
    800032c8:	00000097          	auipc	ra,0x0
    800032cc:	ccc080e7          	jalr	-820(ra) # 80002f94 <argint>
  argaddr(1, &pids_addr);
    800032d0:	fe040593          	addi	a1,s0,-32
    800032d4:	4505                	li	a0,1
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	cde080e7          	jalr	-802(ra) # 80002fb4 <argaddr>

  return forkn(n, (int*)pids_addr);
    800032de:	fe043583          	ld	a1,-32(s0)
    800032e2:	fec42503          	lw	a0,-20(s0)
    800032e6:	fffff097          	auipc	ra,0xfffff
    800032ea:	314080e7          	jalr	788(ra) # 800025fa <forkn>
}
    800032ee:	60e2                	ld	ra,24(sp)
    800032f0:	6442                	ld	s0,16(sp)
    800032f2:	6105                	addi	sp,sp,32
    800032f4:	8082                	ret

00000000800032f6 <sys_waitall>:

uint64
sys_waitall(void)
{
    800032f6:	1101                	addi	sp,sp,-32
    800032f8:	ec06                	sd	ra,24(sp)
    800032fa:	e822                	sd	s0,16(sp)
    800032fc:	1000                	addi	s0,sp,32
  uint64 n_addr;
  uint64 statuses_addr;
  argaddr(0, &n_addr);
    800032fe:	fe840593          	addi	a1,s0,-24
    80003302:	4501                	li	a0,0
    80003304:	00000097          	auipc	ra,0x0
    80003308:	cb0080e7          	jalr	-848(ra) # 80002fb4 <argaddr>
  argaddr(1, &statuses_addr);
    8000330c:	fe040593          	addi	a1,s0,-32
    80003310:	4505                	li	a0,1
    80003312:	00000097          	auipc	ra,0x0
    80003316:	ca2080e7          	jalr	-862(ra) # 80002fb4 <argaddr>
  return waitall((int*)n_addr, (int*)statuses_addr);
    8000331a:	fe043583          	ld	a1,-32(s0)
    8000331e:	fe843503          	ld	a0,-24(s0)
    80003322:	fffff097          	auipc	ra,0xfffff
    80003326:	53c080e7          	jalr	1340(ra) # 8000285e <waitall>

}
    8000332a:	60e2                	ld	ra,24(sp)
    8000332c:	6442                	ld	s0,16(sp)
    8000332e:	6105                	addi	sp,sp,32
    80003330:	8082                	ret

0000000080003332 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003332:	7179                	addi	sp,sp,-48
    80003334:	f406                	sd	ra,40(sp)
    80003336:	f022                	sd	s0,32(sp)
    80003338:	ec26                	sd	s1,24(sp)
    8000333a:	e84a                	sd	s2,16(sp)
    8000333c:	e44e                	sd	s3,8(sp)
    8000333e:	e052                	sd	s4,0(sp)
    80003340:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003342:	00005597          	auipc	a1,0x5
    80003346:	1d658593          	addi	a1,a1,470 # 80008518 <syscalls+0xc8>
    8000334a:	00014517          	auipc	a0,0x14
    8000334e:	e6e50513          	addi	a0,a0,-402 # 800171b8 <bcache>
    80003352:	ffffd097          	auipc	ra,0xffffd
    80003356:	7f4080e7          	jalr	2036(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000335a:	0001c797          	auipc	a5,0x1c
    8000335e:	e5e78793          	addi	a5,a5,-418 # 8001f1b8 <bcache+0x8000>
    80003362:	0001c717          	auipc	a4,0x1c
    80003366:	0be70713          	addi	a4,a4,190 # 8001f420 <bcache+0x8268>
    8000336a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000336e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003372:	00014497          	auipc	s1,0x14
    80003376:	e5e48493          	addi	s1,s1,-418 # 800171d0 <bcache+0x18>
    b->next = bcache.head.next;
    8000337a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000337c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000337e:	00005a17          	auipc	s4,0x5
    80003382:	1a2a0a13          	addi	s4,s4,418 # 80008520 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003386:	2b893783          	ld	a5,696(s2)
    8000338a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000338c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003390:	85d2                	mv	a1,s4
    80003392:	01048513          	addi	a0,s1,16
    80003396:	00001097          	auipc	ra,0x1
    8000339a:	4c4080e7          	jalr	1220(ra) # 8000485a <initsleeplock>
    bcache.head.next->prev = b;
    8000339e:	2b893783          	ld	a5,696(s2)
    800033a2:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033a4:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033a8:	45848493          	addi	s1,s1,1112
    800033ac:	fd349de3          	bne	s1,s3,80003386 <binit+0x54>
  }
}
    800033b0:	70a2                	ld	ra,40(sp)
    800033b2:	7402                	ld	s0,32(sp)
    800033b4:	64e2                	ld	s1,24(sp)
    800033b6:	6942                	ld	s2,16(sp)
    800033b8:	69a2                	ld	s3,8(sp)
    800033ba:	6a02                	ld	s4,0(sp)
    800033bc:	6145                	addi	sp,sp,48
    800033be:	8082                	ret

00000000800033c0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800033c0:	7179                	addi	sp,sp,-48
    800033c2:	f406                	sd	ra,40(sp)
    800033c4:	f022                	sd	s0,32(sp)
    800033c6:	ec26                	sd	s1,24(sp)
    800033c8:	e84a                	sd	s2,16(sp)
    800033ca:	e44e                	sd	s3,8(sp)
    800033cc:	1800                	addi	s0,sp,48
    800033ce:	892a                	mv	s2,a0
    800033d0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800033d2:	00014517          	auipc	a0,0x14
    800033d6:	de650513          	addi	a0,a0,-538 # 800171b8 <bcache>
    800033da:	ffffd097          	auipc	ra,0xffffd
    800033de:	7fc080e7          	jalr	2044(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033e2:	0001c497          	auipc	s1,0x1c
    800033e6:	08e4b483          	ld	s1,142(s1) # 8001f470 <bcache+0x82b8>
    800033ea:	0001c797          	auipc	a5,0x1c
    800033ee:	03678793          	addi	a5,a5,54 # 8001f420 <bcache+0x8268>
    800033f2:	02f48f63          	beq	s1,a5,80003430 <bread+0x70>
    800033f6:	873e                	mv	a4,a5
    800033f8:	a021                	j	80003400 <bread+0x40>
    800033fa:	68a4                	ld	s1,80(s1)
    800033fc:	02e48a63          	beq	s1,a4,80003430 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003400:	449c                	lw	a5,8(s1)
    80003402:	ff279ce3          	bne	a5,s2,800033fa <bread+0x3a>
    80003406:	44dc                	lw	a5,12(s1)
    80003408:	ff3799e3          	bne	a5,s3,800033fa <bread+0x3a>
      b->refcnt++;
    8000340c:	40bc                	lw	a5,64(s1)
    8000340e:	2785                	addiw	a5,a5,1
    80003410:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003412:	00014517          	auipc	a0,0x14
    80003416:	da650513          	addi	a0,a0,-602 # 800171b8 <bcache>
    8000341a:	ffffe097          	auipc	ra,0xffffe
    8000341e:	870080e7          	jalr	-1936(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003422:	01048513          	addi	a0,s1,16
    80003426:	00001097          	auipc	ra,0x1
    8000342a:	46e080e7          	jalr	1134(ra) # 80004894 <acquiresleep>
      return b;
    8000342e:	a8b9                	j	8000348c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003430:	0001c497          	auipc	s1,0x1c
    80003434:	0384b483          	ld	s1,56(s1) # 8001f468 <bcache+0x82b0>
    80003438:	0001c797          	auipc	a5,0x1c
    8000343c:	fe878793          	addi	a5,a5,-24 # 8001f420 <bcache+0x8268>
    80003440:	00f48863          	beq	s1,a5,80003450 <bread+0x90>
    80003444:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003446:	40bc                	lw	a5,64(s1)
    80003448:	cf81                	beqz	a5,80003460 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000344a:	64a4                	ld	s1,72(s1)
    8000344c:	fee49de3          	bne	s1,a4,80003446 <bread+0x86>
  panic("bget: no buffers");
    80003450:	00005517          	auipc	a0,0x5
    80003454:	0d850513          	addi	a0,a0,216 # 80008528 <syscalls+0xd8>
    80003458:	ffffd097          	auipc	ra,0xffffd
    8000345c:	0e6080e7          	jalr	230(ra) # 8000053e <panic>
      b->dev = dev;
    80003460:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003464:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003468:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000346c:	4785                	li	a5,1
    8000346e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003470:	00014517          	auipc	a0,0x14
    80003474:	d4850513          	addi	a0,a0,-696 # 800171b8 <bcache>
    80003478:	ffffe097          	auipc	ra,0xffffe
    8000347c:	812080e7          	jalr	-2030(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003480:	01048513          	addi	a0,s1,16
    80003484:	00001097          	auipc	ra,0x1
    80003488:	410080e7          	jalr	1040(ra) # 80004894 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000348c:	409c                	lw	a5,0(s1)
    8000348e:	cb89                	beqz	a5,800034a0 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003490:	8526                	mv	a0,s1
    80003492:	70a2                	ld	ra,40(sp)
    80003494:	7402                	ld	s0,32(sp)
    80003496:	64e2                	ld	s1,24(sp)
    80003498:	6942                	ld	s2,16(sp)
    8000349a:	69a2                	ld	s3,8(sp)
    8000349c:	6145                	addi	sp,sp,48
    8000349e:	8082                	ret
    virtio_disk_rw(b, 0);
    800034a0:	4581                	li	a1,0
    800034a2:	8526                	mv	a0,s1
    800034a4:	00003097          	auipc	ra,0x3
    800034a8:	fd0080e7          	jalr	-48(ra) # 80006474 <virtio_disk_rw>
    b->valid = 1;
    800034ac:	4785                	li	a5,1
    800034ae:	c09c                	sw	a5,0(s1)
  return b;
    800034b0:	b7c5                	j	80003490 <bread+0xd0>

00000000800034b2 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800034b2:	1101                	addi	sp,sp,-32
    800034b4:	ec06                	sd	ra,24(sp)
    800034b6:	e822                	sd	s0,16(sp)
    800034b8:	e426                	sd	s1,8(sp)
    800034ba:	1000                	addi	s0,sp,32
    800034bc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034be:	0541                	addi	a0,a0,16
    800034c0:	00001097          	auipc	ra,0x1
    800034c4:	46e080e7          	jalr	1134(ra) # 8000492e <holdingsleep>
    800034c8:	cd01                	beqz	a0,800034e0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800034ca:	4585                	li	a1,1
    800034cc:	8526                	mv	a0,s1
    800034ce:	00003097          	auipc	ra,0x3
    800034d2:	fa6080e7          	jalr	-90(ra) # 80006474 <virtio_disk_rw>
}
    800034d6:	60e2                	ld	ra,24(sp)
    800034d8:	6442                	ld	s0,16(sp)
    800034da:	64a2                	ld	s1,8(sp)
    800034dc:	6105                	addi	sp,sp,32
    800034de:	8082                	ret
    panic("bwrite");
    800034e0:	00005517          	auipc	a0,0x5
    800034e4:	06050513          	addi	a0,a0,96 # 80008540 <syscalls+0xf0>
    800034e8:	ffffd097          	auipc	ra,0xffffd
    800034ec:	056080e7          	jalr	86(ra) # 8000053e <panic>

00000000800034f0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034f0:	1101                	addi	sp,sp,-32
    800034f2:	ec06                	sd	ra,24(sp)
    800034f4:	e822                	sd	s0,16(sp)
    800034f6:	e426                	sd	s1,8(sp)
    800034f8:	e04a                	sd	s2,0(sp)
    800034fa:	1000                	addi	s0,sp,32
    800034fc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034fe:	01050913          	addi	s2,a0,16
    80003502:	854a                	mv	a0,s2
    80003504:	00001097          	auipc	ra,0x1
    80003508:	42a080e7          	jalr	1066(ra) # 8000492e <holdingsleep>
    8000350c:	c92d                	beqz	a0,8000357e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000350e:	854a                	mv	a0,s2
    80003510:	00001097          	auipc	ra,0x1
    80003514:	3da080e7          	jalr	986(ra) # 800048ea <releasesleep>

  acquire(&bcache.lock);
    80003518:	00014517          	auipc	a0,0x14
    8000351c:	ca050513          	addi	a0,a0,-864 # 800171b8 <bcache>
    80003520:	ffffd097          	auipc	ra,0xffffd
    80003524:	6b6080e7          	jalr	1718(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003528:	40bc                	lw	a5,64(s1)
    8000352a:	37fd                	addiw	a5,a5,-1
    8000352c:	0007871b          	sext.w	a4,a5
    80003530:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003532:	eb05                	bnez	a4,80003562 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003534:	68bc                	ld	a5,80(s1)
    80003536:	64b8                	ld	a4,72(s1)
    80003538:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000353a:	64bc                	ld	a5,72(s1)
    8000353c:	68b8                	ld	a4,80(s1)
    8000353e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003540:	0001c797          	auipc	a5,0x1c
    80003544:	c7878793          	addi	a5,a5,-904 # 8001f1b8 <bcache+0x8000>
    80003548:	2b87b703          	ld	a4,696(a5)
    8000354c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000354e:	0001c717          	auipc	a4,0x1c
    80003552:	ed270713          	addi	a4,a4,-302 # 8001f420 <bcache+0x8268>
    80003556:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003558:	2b87b703          	ld	a4,696(a5)
    8000355c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000355e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003562:	00014517          	auipc	a0,0x14
    80003566:	c5650513          	addi	a0,a0,-938 # 800171b8 <bcache>
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	720080e7          	jalr	1824(ra) # 80000c8a <release>
}
    80003572:	60e2                	ld	ra,24(sp)
    80003574:	6442                	ld	s0,16(sp)
    80003576:	64a2                	ld	s1,8(sp)
    80003578:	6902                	ld	s2,0(sp)
    8000357a:	6105                	addi	sp,sp,32
    8000357c:	8082                	ret
    panic("brelse");
    8000357e:	00005517          	auipc	a0,0x5
    80003582:	fca50513          	addi	a0,a0,-54 # 80008548 <syscalls+0xf8>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	fb8080e7          	jalr	-72(ra) # 8000053e <panic>

000000008000358e <bpin>:

void
bpin(struct buf *b) {
    8000358e:	1101                	addi	sp,sp,-32
    80003590:	ec06                	sd	ra,24(sp)
    80003592:	e822                	sd	s0,16(sp)
    80003594:	e426                	sd	s1,8(sp)
    80003596:	1000                	addi	s0,sp,32
    80003598:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000359a:	00014517          	auipc	a0,0x14
    8000359e:	c1e50513          	addi	a0,a0,-994 # 800171b8 <bcache>
    800035a2:	ffffd097          	auipc	ra,0xffffd
    800035a6:	634080e7          	jalr	1588(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800035aa:	40bc                	lw	a5,64(s1)
    800035ac:	2785                	addiw	a5,a5,1
    800035ae:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035b0:	00014517          	auipc	a0,0x14
    800035b4:	c0850513          	addi	a0,a0,-1016 # 800171b8 <bcache>
    800035b8:	ffffd097          	auipc	ra,0xffffd
    800035bc:	6d2080e7          	jalr	1746(ra) # 80000c8a <release>
}
    800035c0:	60e2                	ld	ra,24(sp)
    800035c2:	6442                	ld	s0,16(sp)
    800035c4:	64a2                	ld	s1,8(sp)
    800035c6:	6105                	addi	sp,sp,32
    800035c8:	8082                	ret

00000000800035ca <bunpin>:

void
bunpin(struct buf *b) {
    800035ca:	1101                	addi	sp,sp,-32
    800035cc:	ec06                	sd	ra,24(sp)
    800035ce:	e822                	sd	s0,16(sp)
    800035d0:	e426                	sd	s1,8(sp)
    800035d2:	1000                	addi	s0,sp,32
    800035d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035d6:	00014517          	auipc	a0,0x14
    800035da:	be250513          	addi	a0,a0,-1054 # 800171b8 <bcache>
    800035de:	ffffd097          	auipc	ra,0xffffd
    800035e2:	5f8080e7          	jalr	1528(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800035e6:	40bc                	lw	a5,64(s1)
    800035e8:	37fd                	addiw	a5,a5,-1
    800035ea:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035ec:	00014517          	auipc	a0,0x14
    800035f0:	bcc50513          	addi	a0,a0,-1076 # 800171b8 <bcache>
    800035f4:	ffffd097          	auipc	ra,0xffffd
    800035f8:	696080e7          	jalr	1686(ra) # 80000c8a <release>
}
    800035fc:	60e2                	ld	ra,24(sp)
    800035fe:	6442                	ld	s0,16(sp)
    80003600:	64a2                	ld	s1,8(sp)
    80003602:	6105                	addi	sp,sp,32
    80003604:	8082                	ret

0000000080003606 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003606:	1101                	addi	sp,sp,-32
    80003608:	ec06                	sd	ra,24(sp)
    8000360a:	e822                	sd	s0,16(sp)
    8000360c:	e426                	sd	s1,8(sp)
    8000360e:	e04a                	sd	s2,0(sp)
    80003610:	1000                	addi	s0,sp,32
    80003612:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003614:	00d5d59b          	srliw	a1,a1,0xd
    80003618:	0001c797          	auipc	a5,0x1c
    8000361c:	27c7a783          	lw	a5,636(a5) # 8001f894 <sb+0x1c>
    80003620:	9dbd                	addw	a1,a1,a5
    80003622:	00000097          	auipc	ra,0x0
    80003626:	d9e080e7          	jalr	-610(ra) # 800033c0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000362a:	0074f713          	andi	a4,s1,7
    8000362e:	4785                	li	a5,1
    80003630:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003634:	14ce                	slli	s1,s1,0x33
    80003636:	90d9                	srli	s1,s1,0x36
    80003638:	00950733          	add	a4,a0,s1
    8000363c:	05874703          	lbu	a4,88(a4)
    80003640:	00e7f6b3          	and	a3,a5,a4
    80003644:	c69d                	beqz	a3,80003672 <bfree+0x6c>
    80003646:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003648:	94aa                	add	s1,s1,a0
    8000364a:	fff7c793          	not	a5,a5
    8000364e:	8ff9                	and	a5,a5,a4
    80003650:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003654:	00001097          	auipc	ra,0x1
    80003658:	120080e7          	jalr	288(ra) # 80004774 <log_write>
  brelse(bp);
    8000365c:	854a                	mv	a0,s2
    8000365e:	00000097          	auipc	ra,0x0
    80003662:	e92080e7          	jalr	-366(ra) # 800034f0 <brelse>
}
    80003666:	60e2                	ld	ra,24(sp)
    80003668:	6442                	ld	s0,16(sp)
    8000366a:	64a2                	ld	s1,8(sp)
    8000366c:	6902                	ld	s2,0(sp)
    8000366e:	6105                	addi	sp,sp,32
    80003670:	8082                	ret
    panic("freeing free block");
    80003672:	00005517          	auipc	a0,0x5
    80003676:	ede50513          	addi	a0,a0,-290 # 80008550 <syscalls+0x100>
    8000367a:	ffffd097          	auipc	ra,0xffffd
    8000367e:	ec4080e7          	jalr	-316(ra) # 8000053e <panic>

0000000080003682 <balloc>:
{
    80003682:	711d                	addi	sp,sp,-96
    80003684:	ec86                	sd	ra,88(sp)
    80003686:	e8a2                	sd	s0,80(sp)
    80003688:	e4a6                	sd	s1,72(sp)
    8000368a:	e0ca                	sd	s2,64(sp)
    8000368c:	fc4e                	sd	s3,56(sp)
    8000368e:	f852                	sd	s4,48(sp)
    80003690:	f456                	sd	s5,40(sp)
    80003692:	f05a                	sd	s6,32(sp)
    80003694:	ec5e                	sd	s7,24(sp)
    80003696:	e862                	sd	s8,16(sp)
    80003698:	e466                	sd	s9,8(sp)
    8000369a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000369c:	0001c797          	auipc	a5,0x1c
    800036a0:	1e07a783          	lw	a5,480(a5) # 8001f87c <sb+0x4>
    800036a4:	10078163          	beqz	a5,800037a6 <balloc+0x124>
    800036a8:	8baa                	mv	s7,a0
    800036aa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036ac:	0001cb17          	auipc	s6,0x1c
    800036b0:	1ccb0b13          	addi	s6,s6,460 # 8001f878 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036b4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036b6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036b8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036ba:	6c89                	lui	s9,0x2
    800036bc:	a061                	j	80003744 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036be:	974a                	add	a4,a4,s2
    800036c0:	8fd5                	or	a5,a5,a3
    800036c2:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800036c6:	854a                	mv	a0,s2
    800036c8:	00001097          	auipc	ra,0x1
    800036cc:	0ac080e7          	jalr	172(ra) # 80004774 <log_write>
        brelse(bp);
    800036d0:	854a                	mv	a0,s2
    800036d2:	00000097          	auipc	ra,0x0
    800036d6:	e1e080e7          	jalr	-482(ra) # 800034f0 <brelse>
  bp = bread(dev, bno);
    800036da:	85a6                	mv	a1,s1
    800036dc:	855e                	mv	a0,s7
    800036de:	00000097          	auipc	ra,0x0
    800036e2:	ce2080e7          	jalr	-798(ra) # 800033c0 <bread>
    800036e6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036e8:	40000613          	li	a2,1024
    800036ec:	4581                	li	a1,0
    800036ee:	05850513          	addi	a0,a0,88
    800036f2:	ffffd097          	auipc	ra,0xffffd
    800036f6:	5e0080e7          	jalr	1504(ra) # 80000cd2 <memset>
  log_write(bp);
    800036fa:	854a                	mv	a0,s2
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	078080e7          	jalr	120(ra) # 80004774 <log_write>
  brelse(bp);
    80003704:	854a                	mv	a0,s2
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	dea080e7          	jalr	-534(ra) # 800034f0 <brelse>
}
    8000370e:	8526                	mv	a0,s1
    80003710:	60e6                	ld	ra,88(sp)
    80003712:	6446                	ld	s0,80(sp)
    80003714:	64a6                	ld	s1,72(sp)
    80003716:	6906                	ld	s2,64(sp)
    80003718:	79e2                	ld	s3,56(sp)
    8000371a:	7a42                	ld	s4,48(sp)
    8000371c:	7aa2                	ld	s5,40(sp)
    8000371e:	7b02                	ld	s6,32(sp)
    80003720:	6be2                	ld	s7,24(sp)
    80003722:	6c42                	ld	s8,16(sp)
    80003724:	6ca2                	ld	s9,8(sp)
    80003726:	6125                	addi	sp,sp,96
    80003728:	8082                	ret
    brelse(bp);
    8000372a:	854a                	mv	a0,s2
    8000372c:	00000097          	auipc	ra,0x0
    80003730:	dc4080e7          	jalr	-572(ra) # 800034f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003734:	015c87bb          	addw	a5,s9,s5
    80003738:	00078a9b          	sext.w	s5,a5
    8000373c:	004b2703          	lw	a4,4(s6)
    80003740:	06eaf363          	bgeu	s5,a4,800037a6 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    80003744:	41fad79b          	sraiw	a5,s5,0x1f
    80003748:	0137d79b          	srliw	a5,a5,0x13
    8000374c:	015787bb          	addw	a5,a5,s5
    80003750:	40d7d79b          	sraiw	a5,a5,0xd
    80003754:	01cb2583          	lw	a1,28(s6)
    80003758:	9dbd                	addw	a1,a1,a5
    8000375a:	855e                	mv	a0,s7
    8000375c:	00000097          	auipc	ra,0x0
    80003760:	c64080e7          	jalr	-924(ra) # 800033c0 <bread>
    80003764:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003766:	004b2503          	lw	a0,4(s6)
    8000376a:	000a849b          	sext.w	s1,s5
    8000376e:	8662                	mv	a2,s8
    80003770:	faa4fde3          	bgeu	s1,a0,8000372a <balloc+0xa8>
      m = 1 << (bi % 8);
    80003774:	41f6579b          	sraiw	a5,a2,0x1f
    80003778:	01d7d69b          	srliw	a3,a5,0x1d
    8000377c:	00c6873b          	addw	a4,a3,a2
    80003780:	00777793          	andi	a5,a4,7
    80003784:	9f95                	subw	a5,a5,a3
    80003786:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000378a:	4037571b          	sraiw	a4,a4,0x3
    8000378e:	00e906b3          	add	a3,s2,a4
    80003792:	0586c683          	lbu	a3,88(a3)
    80003796:	00d7f5b3          	and	a1,a5,a3
    8000379a:	d195                	beqz	a1,800036be <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000379c:	2605                	addiw	a2,a2,1
    8000379e:	2485                	addiw	s1,s1,1
    800037a0:	fd4618e3          	bne	a2,s4,80003770 <balloc+0xee>
    800037a4:	b759                	j	8000372a <balloc+0xa8>
  printf("balloc: out of blocks\n");
    800037a6:	00005517          	auipc	a0,0x5
    800037aa:	dc250513          	addi	a0,a0,-574 # 80008568 <syscalls+0x118>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	dda080e7          	jalr	-550(ra) # 80000588 <printf>
  return 0;
    800037b6:	4481                	li	s1,0
    800037b8:	bf99                	j	8000370e <balloc+0x8c>

00000000800037ba <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037ba:	7179                	addi	sp,sp,-48
    800037bc:	f406                	sd	ra,40(sp)
    800037be:	f022                	sd	s0,32(sp)
    800037c0:	ec26                	sd	s1,24(sp)
    800037c2:	e84a                	sd	s2,16(sp)
    800037c4:	e44e                	sd	s3,8(sp)
    800037c6:	e052                	sd	s4,0(sp)
    800037c8:	1800                	addi	s0,sp,48
    800037ca:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037cc:	47ad                	li	a5,11
    800037ce:	02b7e763          	bltu	a5,a1,800037fc <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    800037d2:	02059493          	slli	s1,a1,0x20
    800037d6:	9081                	srli	s1,s1,0x20
    800037d8:	048a                	slli	s1,s1,0x2
    800037da:	94aa                	add	s1,s1,a0
    800037dc:	0504a903          	lw	s2,80(s1)
    800037e0:	06091e63          	bnez	s2,8000385c <bmap+0xa2>
      addr = balloc(ip->dev);
    800037e4:	4108                	lw	a0,0(a0)
    800037e6:	00000097          	auipc	ra,0x0
    800037ea:	e9c080e7          	jalr	-356(ra) # 80003682 <balloc>
    800037ee:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037f2:	06090563          	beqz	s2,8000385c <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    800037f6:	0524a823          	sw	s2,80(s1)
    800037fa:	a08d                	j	8000385c <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037fc:	ff45849b          	addiw	s1,a1,-12
    80003800:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003804:	0ff00793          	li	a5,255
    80003808:	08e7e563          	bltu	a5,a4,80003892 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000380c:	08052903          	lw	s2,128(a0)
    80003810:	00091d63          	bnez	s2,8000382a <bmap+0x70>
      addr = balloc(ip->dev);
    80003814:	4108                	lw	a0,0(a0)
    80003816:	00000097          	auipc	ra,0x0
    8000381a:	e6c080e7          	jalr	-404(ra) # 80003682 <balloc>
    8000381e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003822:	02090d63          	beqz	s2,8000385c <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003826:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000382a:	85ca                	mv	a1,s2
    8000382c:	0009a503          	lw	a0,0(s3)
    80003830:	00000097          	auipc	ra,0x0
    80003834:	b90080e7          	jalr	-1136(ra) # 800033c0 <bread>
    80003838:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000383a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000383e:	02049593          	slli	a1,s1,0x20
    80003842:	9181                	srli	a1,a1,0x20
    80003844:	058a                	slli	a1,a1,0x2
    80003846:	00b784b3          	add	s1,a5,a1
    8000384a:	0004a903          	lw	s2,0(s1)
    8000384e:	02090063          	beqz	s2,8000386e <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003852:	8552                	mv	a0,s4
    80003854:	00000097          	auipc	ra,0x0
    80003858:	c9c080e7          	jalr	-868(ra) # 800034f0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000385c:	854a                	mv	a0,s2
    8000385e:	70a2                	ld	ra,40(sp)
    80003860:	7402                	ld	s0,32(sp)
    80003862:	64e2                	ld	s1,24(sp)
    80003864:	6942                	ld	s2,16(sp)
    80003866:	69a2                	ld	s3,8(sp)
    80003868:	6a02                	ld	s4,0(sp)
    8000386a:	6145                	addi	sp,sp,48
    8000386c:	8082                	ret
      addr = balloc(ip->dev);
    8000386e:	0009a503          	lw	a0,0(s3)
    80003872:	00000097          	auipc	ra,0x0
    80003876:	e10080e7          	jalr	-496(ra) # 80003682 <balloc>
    8000387a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000387e:	fc090ae3          	beqz	s2,80003852 <bmap+0x98>
        a[bn] = addr;
    80003882:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003886:	8552                	mv	a0,s4
    80003888:	00001097          	auipc	ra,0x1
    8000388c:	eec080e7          	jalr	-276(ra) # 80004774 <log_write>
    80003890:	b7c9                	j	80003852 <bmap+0x98>
  panic("bmap: out of range");
    80003892:	00005517          	auipc	a0,0x5
    80003896:	cee50513          	addi	a0,a0,-786 # 80008580 <syscalls+0x130>
    8000389a:	ffffd097          	auipc	ra,0xffffd
    8000389e:	ca4080e7          	jalr	-860(ra) # 8000053e <panic>

00000000800038a2 <iget>:
{
    800038a2:	7179                	addi	sp,sp,-48
    800038a4:	f406                	sd	ra,40(sp)
    800038a6:	f022                	sd	s0,32(sp)
    800038a8:	ec26                	sd	s1,24(sp)
    800038aa:	e84a                	sd	s2,16(sp)
    800038ac:	e44e                	sd	s3,8(sp)
    800038ae:	e052                	sd	s4,0(sp)
    800038b0:	1800                	addi	s0,sp,48
    800038b2:	89aa                	mv	s3,a0
    800038b4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038b6:	0001c517          	auipc	a0,0x1c
    800038ba:	fe250513          	addi	a0,a0,-30 # 8001f898 <itable>
    800038be:	ffffd097          	auipc	ra,0xffffd
    800038c2:	318080e7          	jalr	792(ra) # 80000bd6 <acquire>
  empty = 0;
    800038c6:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038c8:	0001c497          	auipc	s1,0x1c
    800038cc:	fe848493          	addi	s1,s1,-24 # 8001f8b0 <itable+0x18>
    800038d0:	0001e697          	auipc	a3,0x1e
    800038d4:	a7068693          	addi	a3,a3,-1424 # 80021340 <log>
    800038d8:	a039                	j	800038e6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038da:	02090b63          	beqz	s2,80003910 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038de:	08848493          	addi	s1,s1,136
    800038e2:	02d48a63          	beq	s1,a3,80003916 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038e6:	449c                	lw	a5,8(s1)
    800038e8:	fef059e3          	blez	a5,800038da <iget+0x38>
    800038ec:	4098                	lw	a4,0(s1)
    800038ee:	ff3716e3          	bne	a4,s3,800038da <iget+0x38>
    800038f2:	40d8                	lw	a4,4(s1)
    800038f4:	ff4713e3          	bne	a4,s4,800038da <iget+0x38>
      ip->ref++;
    800038f8:	2785                	addiw	a5,a5,1
    800038fa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038fc:	0001c517          	auipc	a0,0x1c
    80003900:	f9c50513          	addi	a0,a0,-100 # 8001f898 <itable>
    80003904:	ffffd097          	auipc	ra,0xffffd
    80003908:	386080e7          	jalr	902(ra) # 80000c8a <release>
      return ip;
    8000390c:	8926                	mv	s2,s1
    8000390e:	a03d                	j	8000393c <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003910:	f7f9                	bnez	a5,800038de <iget+0x3c>
    80003912:	8926                	mv	s2,s1
    80003914:	b7e9                	j	800038de <iget+0x3c>
  if(empty == 0)
    80003916:	02090c63          	beqz	s2,8000394e <iget+0xac>
  ip->dev = dev;
    8000391a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000391e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003922:	4785                	li	a5,1
    80003924:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003928:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000392c:	0001c517          	auipc	a0,0x1c
    80003930:	f6c50513          	addi	a0,a0,-148 # 8001f898 <itable>
    80003934:	ffffd097          	auipc	ra,0xffffd
    80003938:	356080e7          	jalr	854(ra) # 80000c8a <release>
}
    8000393c:	854a                	mv	a0,s2
    8000393e:	70a2                	ld	ra,40(sp)
    80003940:	7402                	ld	s0,32(sp)
    80003942:	64e2                	ld	s1,24(sp)
    80003944:	6942                	ld	s2,16(sp)
    80003946:	69a2                	ld	s3,8(sp)
    80003948:	6a02                	ld	s4,0(sp)
    8000394a:	6145                	addi	sp,sp,48
    8000394c:	8082                	ret
    panic("iget: no inodes");
    8000394e:	00005517          	auipc	a0,0x5
    80003952:	c4a50513          	addi	a0,a0,-950 # 80008598 <syscalls+0x148>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	be8080e7          	jalr	-1048(ra) # 8000053e <panic>

000000008000395e <fsinit>:
fsinit(int dev) {
    8000395e:	7179                	addi	sp,sp,-48
    80003960:	f406                	sd	ra,40(sp)
    80003962:	f022                	sd	s0,32(sp)
    80003964:	ec26                	sd	s1,24(sp)
    80003966:	e84a                	sd	s2,16(sp)
    80003968:	e44e                	sd	s3,8(sp)
    8000396a:	1800                	addi	s0,sp,48
    8000396c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000396e:	4585                	li	a1,1
    80003970:	00000097          	auipc	ra,0x0
    80003974:	a50080e7          	jalr	-1456(ra) # 800033c0 <bread>
    80003978:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000397a:	0001c997          	auipc	s3,0x1c
    8000397e:	efe98993          	addi	s3,s3,-258 # 8001f878 <sb>
    80003982:	02000613          	li	a2,32
    80003986:	05850593          	addi	a1,a0,88
    8000398a:	854e                	mv	a0,s3
    8000398c:	ffffd097          	auipc	ra,0xffffd
    80003990:	3a2080e7          	jalr	930(ra) # 80000d2e <memmove>
  brelse(bp);
    80003994:	8526                	mv	a0,s1
    80003996:	00000097          	auipc	ra,0x0
    8000399a:	b5a080e7          	jalr	-1190(ra) # 800034f0 <brelse>
  if(sb.magic != FSMAGIC)
    8000399e:	0009a703          	lw	a4,0(s3)
    800039a2:	102037b7          	lui	a5,0x10203
    800039a6:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800039aa:	02f71263          	bne	a4,a5,800039ce <fsinit+0x70>
  initlog(dev, &sb);
    800039ae:	0001c597          	auipc	a1,0x1c
    800039b2:	eca58593          	addi	a1,a1,-310 # 8001f878 <sb>
    800039b6:	854a                	mv	a0,s2
    800039b8:	00001097          	auipc	ra,0x1
    800039bc:	b40080e7          	jalr	-1216(ra) # 800044f8 <initlog>
}
    800039c0:	70a2                	ld	ra,40(sp)
    800039c2:	7402                	ld	s0,32(sp)
    800039c4:	64e2                	ld	s1,24(sp)
    800039c6:	6942                	ld	s2,16(sp)
    800039c8:	69a2                	ld	s3,8(sp)
    800039ca:	6145                	addi	sp,sp,48
    800039cc:	8082                	ret
    panic("invalid file system");
    800039ce:	00005517          	auipc	a0,0x5
    800039d2:	bda50513          	addi	a0,a0,-1062 # 800085a8 <syscalls+0x158>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	b68080e7          	jalr	-1176(ra) # 8000053e <panic>

00000000800039de <iinit>:
{
    800039de:	7179                	addi	sp,sp,-48
    800039e0:	f406                	sd	ra,40(sp)
    800039e2:	f022                	sd	s0,32(sp)
    800039e4:	ec26                	sd	s1,24(sp)
    800039e6:	e84a                	sd	s2,16(sp)
    800039e8:	e44e                	sd	s3,8(sp)
    800039ea:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039ec:	00005597          	auipc	a1,0x5
    800039f0:	bd458593          	addi	a1,a1,-1068 # 800085c0 <syscalls+0x170>
    800039f4:	0001c517          	auipc	a0,0x1c
    800039f8:	ea450513          	addi	a0,a0,-348 # 8001f898 <itable>
    800039fc:	ffffd097          	auipc	ra,0xffffd
    80003a00:	14a080e7          	jalr	330(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003a04:	0001c497          	auipc	s1,0x1c
    80003a08:	ebc48493          	addi	s1,s1,-324 # 8001f8c0 <itable+0x28>
    80003a0c:	0001e997          	auipc	s3,0x1e
    80003a10:	94498993          	addi	s3,s3,-1724 # 80021350 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003a14:	00005917          	auipc	s2,0x5
    80003a18:	bb490913          	addi	s2,s2,-1100 # 800085c8 <syscalls+0x178>
    80003a1c:	85ca                	mv	a1,s2
    80003a1e:	8526                	mv	a0,s1
    80003a20:	00001097          	auipc	ra,0x1
    80003a24:	e3a080e7          	jalr	-454(ra) # 8000485a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003a28:	08848493          	addi	s1,s1,136
    80003a2c:	ff3498e3          	bne	s1,s3,80003a1c <iinit+0x3e>
}
    80003a30:	70a2                	ld	ra,40(sp)
    80003a32:	7402                	ld	s0,32(sp)
    80003a34:	64e2                	ld	s1,24(sp)
    80003a36:	6942                	ld	s2,16(sp)
    80003a38:	69a2                	ld	s3,8(sp)
    80003a3a:	6145                	addi	sp,sp,48
    80003a3c:	8082                	ret

0000000080003a3e <ialloc>:
{
    80003a3e:	715d                	addi	sp,sp,-80
    80003a40:	e486                	sd	ra,72(sp)
    80003a42:	e0a2                	sd	s0,64(sp)
    80003a44:	fc26                	sd	s1,56(sp)
    80003a46:	f84a                	sd	s2,48(sp)
    80003a48:	f44e                	sd	s3,40(sp)
    80003a4a:	f052                	sd	s4,32(sp)
    80003a4c:	ec56                	sd	s5,24(sp)
    80003a4e:	e85a                	sd	s6,16(sp)
    80003a50:	e45e                	sd	s7,8(sp)
    80003a52:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a54:	0001c717          	auipc	a4,0x1c
    80003a58:	e3072703          	lw	a4,-464(a4) # 8001f884 <sb+0xc>
    80003a5c:	4785                	li	a5,1
    80003a5e:	04e7fa63          	bgeu	a5,a4,80003ab2 <ialloc+0x74>
    80003a62:	8aaa                	mv	s5,a0
    80003a64:	8bae                	mv	s7,a1
    80003a66:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a68:	0001ca17          	auipc	s4,0x1c
    80003a6c:	e10a0a13          	addi	s4,s4,-496 # 8001f878 <sb>
    80003a70:	00048b1b          	sext.w	s6,s1
    80003a74:	0044d793          	srli	a5,s1,0x4
    80003a78:	018a2583          	lw	a1,24(s4)
    80003a7c:	9dbd                	addw	a1,a1,a5
    80003a7e:	8556                	mv	a0,s5
    80003a80:	00000097          	auipc	ra,0x0
    80003a84:	940080e7          	jalr	-1728(ra) # 800033c0 <bread>
    80003a88:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a8a:	05850993          	addi	s3,a0,88
    80003a8e:	00f4f793          	andi	a5,s1,15
    80003a92:	079a                	slli	a5,a5,0x6
    80003a94:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a96:	00099783          	lh	a5,0(s3)
    80003a9a:	c3a1                	beqz	a5,80003ada <ialloc+0x9c>
    brelse(bp);
    80003a9c:	00000097          	auipc	ra,0x0
    80003aa0:	a54080e7          	jalr	-1452(ra) # 800034f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003aa4:	0485                	addi	s1,s1,1
    80003aa6:	00ca2703          	lw	a4,12(s4)
    80003aaa:	0004879b          	sext.w	a5,s1
    80003aae:	fce7e1e3          	bltu	a5,a4,80003a70 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003ab2:	00005517          	auipc	a0,0x5
    80003ab6:	b1e50513          	addi	a0,a0,-1250 # 800085d0 <syscalls+0x180>
    80003aba:	ffffd097          	auipc	ra,0xffffd
    80003abe:	ace080e7          	jalr	-1330(ra) # 80000588 <printf>
  return 0;
    80003ac2:	4501                	li	a0,0
}
    80003ac4:	60a6                	ld	ra,72(sp)
    80003ac6:	6406                	ld	s0,64(sp)
    80003ac8:	74e2                	ld	s1,56(sp)
    80003aca:	7942                	ld	s2,48(sp)
    80003acc:	79a2                	ld	s3,40(sp)
    80003ace:	7a02                	ld	s4,32(sp)
    80003ad0:	6ae2                	ld	s5,24(sp)
    80003ad2:	6b42                	ld	s6,16(sp)
    80003ad4:	6ba2                	ld	s7,8(sp)
    80003ad6:	6161                	addi	sp,sp,80
    80003ad8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003ada:	04000613          	li	a2,64
    80003ade:	4581                	li	a1,0
    80003ae0:	854e                	mv	a0,s3
    80003ae2:	ffffd097          	auipc	ra,0xffffd
    80003ae6:	1f0080e7          	jalr	496(ra) # 80000cd2 <memset>
      dip->type = type;
    80003aea:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003aee:	854a                	mv	a0,s2
    80003af0:	00001097          	auipc	ra,0x1
    80003af4:	c84080e7          	jalr	-892(ra) # 80004774 <log_write>
      brelse(bp);
    80003af8:	854a                	mv	a0,s2
    80003afa:	00000097          	auipc	ra,0x0
    80003afe:	9f6080e7          	jalr	-1546(ra) # 800034f0 <brelse>
      return iget(dev, inum);
    80003b02:	85da                	mv	a1,s6
    80003b04:	8556                	mv	a0,s5
    80003b06:	00000097          	auipc	ra,0x0
    80003b0a:	d9c080e7          	jalr	-612(ra) # 800038a2 <iget>
    80003b0e:	bf5d                	j	80003ac4 <ialloc+0x86>

0000000080003b10 <iupdate>:
{
    80003b10:	1101                	addi	sp,sp,-32
    80003b12:	ec06                	sd	ra,24(sp)
    80003b14:	e822                	sd	s0,16(sp)
    80003b16:	e426                	sd	s1,8(sp)
    80003b18:	e04a                	sd	s2,0(sp)
    80003b1a:	1000                	addi	s0,sp,32
    80003b1c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b1e:	415c                	lw	a5,4(a0)
    80003b20:	0047d79b          	srliw	a5,a5,0x4
    80003b24:	0001c597          	auipc	a1,0x1c
    80003b28:	d6c5a583          	lw	a1,-660(a1) # 8001f890 <sb+0x18>
    80003b2c:	9dbd                	addw	a1,a1,a5
    80003b2e:	4108                	lw	a0,0(a0)
    80003b30:	00000097          	auipc	ra,0x0
    80003b34:	890080e7          	jalr	-1904(ra) # 800033c0 <bread>
    80003b38:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b3a:	05850793          	addi	a5,a0,88
    80003b3e:	40c8                	lw	a0,4(s1)
    80003b40:	893d                	andi	a0,a0,15
    80003b42:	051a                	slli	a0,a0,0x6
    80003b44:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003b46:	04449703          	lh	a4,68(s1)
    80003b4a:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003b4e:	04649703          	lh	a4,70(s1)
    80003b52:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003b56:	04849703          	lh	a4,72(s1)
    80003b5a:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003b5e:	04a49703          	lh	a4,74(s1)
    80003b62:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003b66:	44f8                	lw	a4,76(s1)
    80003b68:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b6a:	03400613          	li	a2,52
    80003b6e:	05048593          	addi	a1,s1,80
    80003b72:	0531                	addi	a0,a0,12
    80003b74:	ffffd097          	auipc	ra,0xffffd
    80003b78:	1ba080e7          	jalr	442(ra) # 80000d2e <memmove>
  log_write(bp);
    80003b7c:	854a                	mv	a0,s2
    80003b7e:	00001097          	auipc	ra,0x1
    80003b82:	bf6080e7          	jalr	-1034(ra) # 80004774 <log_write>
  brelse(bp);
    80003b86:	854a                	mv	a0,s2
    80003b88:	00000097          	auipc	ra,0x0
    80003b8c:	968080e7          	jalr	-1688(ra) # 800034f0 <brelse>
}
    80003b90:	60e2                	ld	ra,24(sp)
    80003b92:	6442                	ld	s0,16(sp)
    80003b94:	64a2                	ld	s1,8(sp)
    80003b96:	6902                	ld	s2,0(sp)
    80003b98:	6105                	addi	sp,sp,32
    80003b9a:	8082                	ret

0000000080003b9c <idup>:
{
    80003b9c:	1101                	addi	sp,sp,-32
    80003b9e:	ec06                	sd	ra,24(sp)
    80003ba0:	e822                	sd	s0,16(sp)
    80003ba2:	e426                	sd	s1,8(sp)
    80003ba4:	1000                	addi	s0,sp,32
    80003ba6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ba8:	0001c517          	auipc	a0,0x1c
    80003bac:	cf050513          	addi	a0,a0,-784 # 8001f898 <itable>
    80003bb0:	ffffd097          	auipc	ra,0xffffd
    80003bb4:	026080e7          	jalr	38(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003bb8:	449c                	lw	a5,8(s1)
    80003bba:	2785                	addiw	a5,a5,1
    80003bbc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bbe:	0001c517          	auipc	a0,0x1c
    80003bc2:	cda50513          	addi	a0,a0,-806 # 8001f898 <itable>
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	0c4080e7          	jalr	196(ra) # 80000c8a <release>
}
    80003bce:	8526                	mv	a0,s1
    80003bd0:	60e2                	ld	ra,24(sp)
    80003bd2:	6442                	ld	s0,16(sp)
    80003bd4:	64a2                	ld	s1,8(sp)
    80003bd6:	6105                	addi	sp,sp,32
    80003bd8:	8082                	ret

0000000080003bda <ilock>:
{
    80003bda:	1101                	addi	sp,sp,-32
    80003bdc:	ec06                	sd	ra,24(sp)
    80003bde:	e822                	sd	s0,16(sp)
    80003be0:	e426                	sd	s1,8(sp)
    80003be2:	e04a                	sd	s2,0(sp)
    80003be4:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003be6:	c115                	beqz	a0,80003c0a <ilock+0x30>
    80003be8:	84aa                	mv	s1,a0
    80003bea:	451c                	lw	a5,8(a0)
    80003bec:	00f05f63          	blez	a5,80003c0a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003bf0:	0541                	addi	a0,a0,16
    80003bf2:	00001097          	auipc	ra,0x1
    80003bf6:	ca2080e7          	jalr	-862(ra) # 80004894 <acquiresleep>
  if(ip->valid == 0){
    80003bfa:	40bc                	lw	a5,64(s1)
    80003bfc:	cf99                	beqz	a5,80003c1a <ilock+0x40>
}
    80003bfe:	60e2                	ld	ra,24(sp)
    80003c00:	6442                	ld	s0,16(sp)
    80003c02:	64a2                	ld	s1,8(sp)
    80003c04:	6902                	ld	s2,0(sp)
    80003c06:	6105                	addi	sp,sp,32
    80003c08:	8082                	ret
    panic("ilock");
    80003c0a:	00005517          	auipc	a0,0x5
    80003c0e:	9de50513          	addi	a0,a0,-1570 # 800085e8 <syscalls+0x198>
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	92c080e7          	jalr	-1748(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003c1a:	40dc                	lw	a5,4(s1)
    80003c1c:	0047d79b          	srliw	a5,a5,0x4
    80003c20:	0001c597          	auipc	a1,0x1c
    80003c24:	c705a583          	lw	a1,-912(a1) # 8001f890 <sb+0x18>
    80003c28:	9dbd                	addw	a1,a1,a5
    80003c2a:	4088                	lw	a0,0(s1)
    80003c2c:	fffff097          	auipc	ra,0xfffff
    80003c30:	794080e7          	jalr	1940(ra) # 800033c0 <bread>
    80003c34:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003c36:	05850593          	addi	a1,a0,88
    80003c3a:	40dc                	lw	a5,4(s1)
    80003c3c:	8bbd                	andi	a5,a5,15
    80003c3e:	079a                	slli	a5,a5,0x6
    80003c40:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003c42:	00059783          	lh	a5,0(a1)
    80003c46:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003c4a:	00259783          	lh	a5,2(a1)
    80003c4e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c52:	00459783          	lh	a5,4(a1)
    80003c56:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c5a:	00659783          	lh	a5,6(a1)
    80003c5e:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c62:	459c                	lw	a5,8(a1)
    80003c64:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c66:	03400613          	li	a2,52
    80003c6a:	05b1                	addi	a1,a1,12
    80003c6c:	05048513          	addi	a0,s1,80
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	0be080e7          	jalr	190(ra) # 80000d2e <memmove>
    brelse(bp);
    80003c78:	854a                	mv	a0,s2
    80003c7a:	00000097          	auipc	ra,0x0
    80003c7e:	876080e7          	jalr	-1930(ra) # 800034f0 <brelse>
    ip->valid = 1;
    80003c82:	4785                	li	a5,1
    80003c84:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c86:	04449783          	lh	a5,68(s1)
    80003c8a:	fbb5                	bnez	a5,80003bfe <ilock+0x24>
      panic("ilock: no type");
    80003c8c:	00005517          	auipc	a0,0x5
    80003c90:	96450513          	addi	a0,a0,-1692 # 800085f0 <syscalls+0x1a0>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	8aa080e7          	jalr	-1878(ra) # 8000053e <panic>

0000000080003c9c <iunlock>:
{
    80003c9c:	1101                	addi	sp,sp,-32
    80003c9e:	ec06                	sd	ra,24(sp)
    80003ca0:	e822                	sd	s0,16(sp)
    80003ca2:	e426                	sd	s1,8(sp)
    80003ca4:	e04a                	sd	s2,0(sp)
    80003ca6:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003ca8:	c905                	beqz	a0,80003cd8 <iunlock+0x3c>
    80003caa:	84aa                	mv	s1,a0
    80003cac:	01050913          	addi	s2,a0,16
    80003cb0:	854a                	mv	a0,s2
    80003cb2:	00001097          	auipc	ra,0x1
    80003cb6:	c7c080e7          	jalr	-900(ra) # 8000492e <holdingsleep>
    80003cba:	cd19                	beqz	a0,80003cd8 <iunlock+0x3c>
    80003cbc:	449c                	lw	a5,8(s1)
    80003cbe:	00f05d63          	blez	a5,80003cd8 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003cc2:	854a                	mv	a0,s2
    80003cc4:	00001097          	auipc	ra,0x1
    80003cc8:	c26080e7          	jalr	-986(ra) # 800048ea <releasesleep>
}
    80003ccc:	60e2                	ld	ra,24(sp)
    80003cce:	6442                	ld	s0,16(sp)
    80003cd0:	64a2                	ld	s1,8(sp)
    80003cd2:	6902                	ld	s2,0(sp)
    80003cd4:	6105                	addi	sp,sp,32
    80003cd6:	8082                	ret
    panic("iunlock");
    80003cd8:	00005517          	auipc	a0,0x5
    80003cdc:	92850513          	addi	a0,a0,-1752 # 80008600 <syscalls+0x1b0>
    80003ce0:	ffffd097          	auipc	ra,0xffffd
    80003ce4:	85e080e7          	jalr	-1954(ra) # 8000053e <panic>

0000000080003ce8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003ce8:	7179                	addi	sp,sp,-48
    80003cea:	f406                	sd	ra,40(sp)
    80003cec:	f022                	sd	s0,32(sp)
    80003cee:	ec26                	sd	s1,24(sp)
    80003cf0:	e84a                	sd	s2,16(sp)
    80003cf2:	e44e                	sd	s3,8(sp)
    80003cf4:	e052                	sd	s4,0(sp)
    80003cf6:	1800                	addi	s0,sp,48
    80003cf8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cfa:	05050493          	addi	s1,a0,80
    80003cfe:	08050913          	addi	s2,a0,128
    80003d02:	a021                	j	80003d0a <itrunc+0x22>
    80003d04:	0491                	addi	s1,s1,4
    80003d06:	01248d63          	beq	s1,s2,80003d20 <itrunc+0x38>
    if(ip->addrs[i]){
    80003d0a:	408c                	lw	a1,0(s1)
    80003d0c:	dde5                	beqz	a1,80003d04 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003d0e:	0009a503          	lw	a0,0(s3)
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	8f4080e7          	jalr	-1804(ra) # 80003606 <bfree>
      ip->addrs[i] = 0;
    80003d1a:	0004a023          	sw	zero,0(s1)
    80003d1e:	b7dd                	j	80003d04 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003d20:	0809a583          	lw	a1,128(s3)
    80003d24:	e185                	bnez	a1,80003d44 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003d26:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003d2a:	854e                	mv	a0,s3
    80003d2c:	00000097          	auipc	ra,0x0
    80003d30:	de4080e7          	jalr	-540(ra) # 80003b10 <iupdate>
}
    80003d34:	70a2                	ld	ra,40(sp)
    80003d36:	7402                	ld	s0,32(sp)
    80003d38:	64e2                	ld	s1,24(sp)
    80003d3a:	6942                	ld	s2,16(sp)
    80003d3c:	69a2                	ld	s3,8(sp)
    80003d3e:	6a02                	ld	s4,0(sp)
    80003d40:	6145                	addi	sp,sp,48
    80003d42:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003d44:	0009a503          	lw	a0,0(s3)
    80003d48:	fffff097          	auipc	ra,0xfffff
    80003d4c:	678080e7          	jalr	1656(ra) # 800033c0 <bread>
    80003d50:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d52:	05850493          	addi	s1,a0,88
    80003d56:	45850913          	addi	s2,a0,1112
    80003d5a:	a021                	j	80003d62 <itrunc+0x7a>
    80003d5c:	0491                	addi	s1,s1,4
    80003d5e:	01248b63          	beq	s1,s2,80003d74 <itrunc+0x8c>
      if(a[j])
    80003d62:	408c                	lw	a1,0(s1)
    80003d64:	dde5                	beqz	a1,80003d5c <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d66:	0009a503          	lw	a0,0(s3)
    80003d6a:	00000097          	auipc	ra,0x0
    80003d6e:	89c080e7          	jalr	-1892(ra) # 80003606 <bfree>
    80003d72:	b7ed                	j	80003d5c <itrunc+0x74>
    brelse(bp);
    80003d74:	8552                	mv	a0,s4
    80003d76:	fffff097          	auipc	ra,0xfffff
    80003d7a:	77a080e7          	jalr	1914(ra) # 800034f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d7e:	0809a583          	lw	a1,128(s3)
    80003d82:	0009a503          	lw	a0,0(s3)
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	880080e7          	jalr	-1920(ra) # 80003606 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d8e:	0809a023          	sw	zero,128(s3)
    80003d92:	bf51                	j	80003d26 <itrunc+0x3e>

0000000080003d94 <iput>:
{
    80003d94:	1101                	addi	sp,sp,-32
    80003d96:	ec06                	sd	ra,24(sp)
    80003d98:	e822                	sd	s0,16(sp)
    80003d9a:	e426                	sd	s1,8(sp)
    80003d9c:	e04a                	sd	s2,0(sp)
    80003d9e:	1000                	addi	s0,sp,32
    80003da0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003da2:	0001c517          	auipc	a0,0x1c
    80003da6:	af650513          	addi	a0,a0,-1290 # 8001f898 <itable>
    80003daa:	ffffd097          	auipc	ra,0xffffd
    80003dae:	e2c080e7          	jalr	-468(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003db2:	4498                	lw	a4,8(s1)
    80003db4:	4785                	li	a5,1
    80003db6:	02f70363          	beq	a4,a5,80003ddc <iput+0x48>
  ip->ref--;
    80003dba:	449c                	lw	a5,8(s1)
    80003dbc:	37fd                	addiw	a5,a5,-1
    80003dbe:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003dc0:	0001c517          	auipc	a0,0x1c
    80003dc4:	ad850513          	addi	a0,a0,-1320 # 8001f898 <itable>
    80003dc8:	ffffd097          	auipc	ra,0xffffd
    80003dcc:	ec2080e7          	jalr	-318(ra) # 80000c8a <release>
}
    80003dd0:	60e2                	ld	ra,24(sp)
    80003dd2:	6442                	ld	s0,16(sp)
    80003dd4:	64a2                	ld	s1,8(sp)
    80003dd6:	6902                	ld	s2,0(sp)
    80003dd8:	6105                	addi	sp,sp,32
    80003dda:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ddc:	40bc                	lw	a5,64(s1)
    80003dde:	dff1                	beqz	a5,80003dba <iput+0x26>
    80003de0:	04a49783          	lh	a5,74(s1)
    80003de4:	fbf9                	bnez	a5,80003dba <iput+0x26>
    acquiresleep(&ip->lock);
    80003de6:	01048913          	addi	s2,s1,16
    80003dea:	854a                	mv	a0,s2
    80003dec:	00001097          	auipc	ra,0x1
    80003df0:	aa8080e7          	jalr	-1368(ra) # 80004894 <acquiresleep>
    release(&itable.lock);
    80003df4:	0001c517          	auipc	a0,0x1c
    80003df8:	aa450513          	addi	a0,a0,-1372 # 8001f898 <itable>
    80003dfc:	ffffd097          	auipc	ra,0xffffd
    80003e00:	e8e080e7          	jalr	-370(ra) # 80000c8a <release>
    itrunc(ip);
    80003e04:	8526                	mv	a0,s1
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	ee2080e7          	jalr	-286(ra) # 80003ce8 <itrunc>
    ip->type = 0;
    80003e0e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003e12:	8526                	mv	a0,s1
    80003e14:	00000097          	auipc	ra,0x0
    80003e18:	cfc080e7          	jalr	-772(ra) # 80003b10 <iupdate>
    ip->valid = 0;
    80003e1c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003e20:	854a                	mv	a0,s2
    80003e22:	00001097          	auipc	ra,0x1
    80003e26:	ac8080e7          	jalr	-1336(ra) # 800048ea <releasesleep>
    acquire(&itable.lock);
    80003e2a:	0001c517          	auipc	a0,0x1c
    80003e2e:	a6e50513          	addi	a0,a0,-1426 # 8001f898 <itable>
    80003e32:	ffffd097          	auipc	ra,0xffffd
    80003e36:	da4080e7          	jalr	-604(ra) # 80000bd6 <acquire>
    80003e3a:	b741                	j	80003dba <iput+0x26>

0000000080003e3c <iunlockput>:
{
    80003e3c:	1101                	addi	sp,sp,-32
    80003e3e:	ec06                	sd	ra,24(sp)
    80003e40:	e822                	sd	s0,16(sp)
    80003e42:	e426                	sd	s1,8(sp)
    80003e44:	1000                	addi	s0,sp,32
    80003e46:	84aa                	mv	s1,a0
  iunlock(ip);
    80003e48:	00000097          	auipc	ra,0x0
    80003e4c:	e54080e7          	jalr	-428(ra) # 80003c9c <iunlock>
  iput(ip);
    80003e50:	8526                	mv	a0,s1
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	f42080e7          	jalr	-190(ra) # 80003d94 <iput>
}
    80003e5a:	60e2                	ld	ra,24(sp)
    80003e5c:	6442                	ld	s0,16(sp)
    80003e5e:	64a2                	ld	s1,8(sp)
    80003e60:	6105                	addi	sp,sp,32
    80003e62:	8082                	ret

0000000080003e64 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e64:	1141                	addi	sp,sp,-16
    80003e66:	e422                	sd	s0,8(sp)
    80003e68:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e6a:	411c                	lw	a5,0(a0)
    80003e6c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e6e:	415c                	lw	a5,4(a0)
    80003e70:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e72:	04451783          	lh	a5,68(a0)
    80003e76:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e7a:	04a51783          	lh	a5,74(a0)
    80003e7e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e82:	04c56783          	lwu	a5,76(a0)
    80003e86:	e99c                	sd	a5,16(a1)
}
    80003e88:	6422                	ld	s0,8(sp)
    80003e8a:	0141                	addi	sp,sp,16
    80003e8c:	8082                	ret

0000000080003e8e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e8e:	457c                	lw	a5,76(a0)
    80003e90:	0ed7e963          	bltu	a5,a3,80003f82 <readi+0xf4>
{
    80003e94:	7159                	addi	sp,sp,-112
    80003e96:	f486                	sd	ra,104(sp)
    80003e98:	f0a2                	sd	s0,96(sp)
    80003e9a:	eca6                	sd	s1,88(sp)
    80003e9c:	e8ca                	sd	s2,80(sp)
    80003e9e:	e4ce                	sd	s3,72(sp)
    80003ea0:	e0d2                	sd	s4,64(sp)
    80003ea2:	fc56                	sd	s5,56(sp)
    80003ea4:	f85a                	sd	s6,48(sp)
    80003ea6:	f45e                	sd	s7,40(sp)
    80003ea8:	f062                	sd	s8,32(sp)
    80003eaa:	ec66                	sd	s9,24(sp)
    80003eac:	e86a                	sd	s10,16(sp)
    80003eae:	e46e                	sd	s11,8(sp)
    80003eb0:	1880                	addi	s0,sp,112
    80003eb2:	8b2a                	mv	s6,a0
    80003eb4:	8bae                	mv	s7,a1
    80003eb6:	8a32                	mv	s4,a2
    80003eb8:	84b6                	mv	s1,a3
    80003eba:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ebc:	9f35                	addw	a4,a4,a3
    return 0;
    80003ebe:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ec0:	0ad76063          	bltu	a4,a3,80003f60 <readi+0xd2>
  if(off + n > ip->size)
    80003ec4:	00e7f463          	bgeu	a5,a4,80003ecc <readi+0x3e>
    n = ip->size - off;
    80003ec8:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ecc:	0a0a8963          	beqz	s5,80003f7e <readi+0xf0>
    80003ed0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ed2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ed6:	5c7d                	li	s8,-1
    80003ed8:	a82d                	j	80003f12 <readi+0x84>
    80003eda:	020d1d93          	slli	s11,s10,0x20
    80003ede:	020ddd93          	srli	s11,s11,0x20
    80003ee2:	05890793          	addi	a5,s2,88
    80003ee6:	86ee                	mv	a3,s11
    80003ee8:	963e                	add	a2,a2,a5
    80003eea:	85d2                	mv	a1,s4
    80003eec:	855e                	mv	a0,s7
    80003eee:	ffffe097          	auipc	ra,0xffffe
    80003ef2:	5b2080e7          	jalr	1458(ra) # 800024a0 <either_copyout>
    80003ef6:	05850d63          	beq	a0,s8,80003f50 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003efa:	854a                	mv	a0,s2
    80003efc:	fffff097          	auipc	ra,0xfffff
    80003f00:	5f4080e7          	jalr	1524(ra) # 800034f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f04:	013d09bb          	addw	s3,s10,s3
    80003f08:	009d04bb          	addw	s1,s10,s1
    80003f0c:	9a6e                	add	s4,s4,s11
    80003f0e:	0559f763          	bgeu	s3,s5,80003f5c <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003f12:	00a4d59b          	srliw	a1,s1,0xa
    80003f16:	855a                	mv	a0,s6
    80003f18:	00000097          	auipc	ra,0x0
    80003f1c:	8a2080e7          	jalr	-1886(ra) # 800037ba <bmap>
    80003f20:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f24:	cd85                	beqz	a1,80003f5c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003f26:	000b2503          	lw	a0,0(s6)
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	496080e7          	jalr	1174(ra) # 800033c0 <bread>
    80003f32:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f34:	3ff4f613          	andi	a2,s1,1023
    80003f38:	40cc87bb          	subw	a5,s9,a2
    80003f3c:	413a873b          	subw	a4,s5,s3
    80003f40:	8d3e                	mv	s10,a5
    80003f42:	2781                	sext.w	a5,a5
    80003f44:	0007069b          	sext.w	a3,a4
    80003f48:	f8f6f9e3          	bgeu	a3,a5,80003eda <readi+0x4c>
    80003f4c:	8d3a                	mv	s10,a4
    80003f4e:	b771                	j	80003eda <readi+0x4c>
      brelse(bp);
    80003f50:	854a                	mv	a0,s2
    80003f52:	fffff097          	auipc	ra,0xfffff
    80003f56:	59e080e7          	jalr	1438(ra) # 800034f0 <brelse>
      tot = -1;
    80003f5a:	59fd                	li	s3,-1
  }
  return tot;
    80003f5c:	0009851b          	sext.w	a0,s3
}
    80003f60:	70a6                	ld	ra,104(sp)
    80003f62:	7406                	ld	s0,96(sp)
    80003f64:	64e6                	ld	s1,88(sp)
    80003f66:	6946                	ld	s2,80(sp)
    80003f68:	69a6                	ld	s3,72(sp)
    80003f6a:	6a06                	ld	s4,64(sp)
    80003f6c:	7ae2                	ld	s5,56(sp)
    80003f6e:	7b42                	ld	s6,48(sp)
    80003f70:	7ba2                	ld	s7,40(sp)
    80003f72:	7c02                	ld	s8,32(sp)
    80003f74:	6ce2                	ld	s9,24(sp)
    80003f76:	6d42                	ld	s10,16(sp)
    80003f78:	6da2                	ld	s11,8(sp)
    80003f7a:	6165                	addi	sp,sp,112
    80003f7c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f7e:	89d6                	mv	s3,s5
    80003f80:	bff1                	j	80003f5c <readi+0xce>
    return 0;
    80003f82:	4501                	li	a0,0
}
    80003f84:	8082                	ret

0000000080003f86 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f86:	457c                	lw	a5,76(a0)
    80003f88:	10d7e863          	bltu	a5,a3,80004098 <writei+0x112>
{
    80003f8c:	7159                	addi	sp,sp,-112
    80003f8e:	f486                	sd	ra,104(sp)
    80003f90:	f0a2                	sd	s0,96(sp)
    80003f92:	eca6                	sd	s1,88(sp)
    80003f94:	e8ca                	sd	s2,80(sp)
    80003f96:	e4ce                	sd	s3,72(sp)
    80003f98:	e0d2                	sd	s4,64(sp)
    80003f9a:	fc56                	sd	s5,56(sp)
    80003f9c:	f85a                	sd	s6,48(sp)
    80003f9e:	f45e                	sd	s7,40(sp)
    80003fa0:	f062                	sd	s8,32(sp)
    80003fa2:	ec66                	sd	s9,24(sp)
    80003fa4:	e86a                	sd	s10,16(sp)
    80003fa6:	e46e                	sd	s11,8(sp)
    80003fa8:	1880                	addi	s0,sp,112
    80003faa:	8aaa                	mv	s5,a0
    80003fac:	8bae                	mv	s7,a1
    80003fae:	8a32                	mv	s4,a2
    80003fb0:	8936                	mv	s2,a3
    80003fb2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fb4:	00e687bb          	addw	a5,a3,a4
    80003fb8:	0ed7e263          	bltu	a5,a3,8000409c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fbc:	00043737          	lui	a4,0x43
    80003fc0:	0ef76063          	bltu	a4,a5,800040a0 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fc4:	0c0b0863          	beqz	s6,80004094 <writei+0x10e>
    80003fc8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fca:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003fce:	5c7d                	li	s8,-1
    80003fd0:	a091                	j	80004014 <writei+0x8e>
    80003fd2:	020d1d93          	slli	s11,s10,0x20
    80003fd6:	020ddd93          	srli	s11,s11,0x20
    80003fda:	05848793          	addi	a5,s1,88
    80003fde:	86ee                	mv	a3,s11
    80003fe0:	8652                	mv	a2,s4
    80003fe2:	85de                	mv	a1,s7
    80003fe4:	953e                	add	a0,a0,a5
    80003fe6:	ffffe097          	auipc	ra,0xffffe
    80003fea:	510080e7          	jalr	1296(ra) # 800024f6 <either_copyin>
    80003fee:	07850263          	beq	a0,s8,80004052 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	00000097          	auipc	ra,0x0
    80003ff8:	780080e7          	jalr	1920(ra) # 80004774 <log_write>
    brelse(bp);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	fffff097          	auipc	ra,0xfffff
    80004002:	4f2080e7          	jalr	1266(ra) # 800034f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004006:	013d09bb          	addw	s3,s10,s3
    8000400a:	012d093b          	addw	s2,s10,s2
    8000400e:	9a6e                	add	s4,s4,s11
    80004010:	0569f663          	bgeu	s3,s6,8000405c <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80004014:	00a9559b          	srliw	a1,s2,0xa
    80004018:	8556                	mv	a0,s5
    8000401a:	fffff097          	auipc	ra,0xfffff
    8000401e:	7a0080e7          	jalr	1952(ra) # 800037ba <bmap>
    80004022:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004026:	c99d                	beqz	a1,8000405c <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004028:	000aa503          	lw	a0,0(s5)
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	394080e7          	jalr	916(ra) # 800033c0 <bread>
    80004034:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004036:	3ff97513          	andi	a0,s2,1023
    8000403a:	40ac87bb          	subw	a5,s9,a0
    8000403e:	413b073b          	subw	a4,s6,s3
    80004042:	8d3e                	mv	s10,a5
    80004044:	2781                	sext.w	a5,a5
    80004046:	0007069b          	sext.w	a3,a4
    8000404a:	f8f6f4e3          	bgeu	a3,a5,80003fd2 <writei+0x4c>
    8000404e:	8d3a                	mv	s10,a4
    80004050:	b749                	j	80003fd2 <writei+0x4c>
      brelse(bp);
    80004052:	8526                	mv	a0,s1
    80004054:	fffff097          	auipc	ra,0xfffff
    80004058:	49c080e7          	jalr	1180(ra) # 800034f0 <brelse>
  }

  if(off > ip->size)
    8000405c:	04caa783          	lw	a5,76(s5)
    80004060:	0127f463          	bgeu	a5,s2,80004068 <writei+0xe2>
    ip->size = off;
    80004064:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004068:	8556                	mv	a0,s5
    8000406a:	00000097          	auipc	ra,0x0
    8000406e:	aa6080e7          	jalr	-1370(ra) # 80003b10 <iupdate>

  return tot;
    80004072:	0009851b          	sext.w	a0,s3
}
    80004076:	70a6                	ld	ra,104(sp)
    80004078:	7406                	ld	s0,96(sp)
    8000407a:	64e6                	ld	s1,88(sp)
    8000407c:	6946                	ld	s2,80(sp)
    8000407e:	69a6                	ld	s3,72(sp)
    80004080:	6a06                	ld	s4,64(sp)
    80004082:	7ae2                	ld	s5,56(sp)
    80004084:	7b42                	ld	s6,48(sp)
    80004086:	7ba2                	ld	s7,40(sp)
    80004088:	7c02                	ld	s8,32(sp)
    8000408a:	6ce2                	ld	s9,24(sp)
    8000408c:	6d42                	ld	s10,16(sp)
    8000408e:	6da2                	ld	s11,8(sp)
    80004090:	6165                	addi	sp,sp,112
    80004092:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004094:	89da                	mv	s3,s6
    80004096:	bfc9                	j	80004068 <writei+0xe2>
    return -1;
    80004098:	557d                	li	a0,-1
}
    8000409a:	8082                	ret
    return -1;
    8000409c:	557d                	li	a0,-1
    8000409e:	bfe1                	j	80004076 <writei+0xf0>
    return -1;
    800040a0:	557d                	li	a0,-1
    800040a2:	bfd1                	j	80004076 <writei+0xf0>

00000000800040a4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040a4:	1141                	addi	sp,sp,-16
    800040a6:	e406                	sd	ra,8(sp)
    800040a8:	e022                	sd	s0,0(sp)
    800040aa:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040ac:	4639                	li	a2,14
    800040ae:	ffffd097          	auipc	ra,0xffffd
    800040b2:	cf4080e7          	jalr	-780(ra) # 80000da2 <strncmp>
}
    800040b6:	60a2                	ld	ra,8(sp)
    800040b8:	6402                	ld	s0,0(sp)
    800040ba:	0141                	addi	sp,sp,16
    800040bc:	8082                	ret

00000000800040be <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040be:	7139                	addi	sp,sp,-64
    800040c0:	fc06                	sd	ra,56(sp)
    800040c2:	f822                	sd	s0,48(sp)
    800040c4:	f426                	sd	s1,40(sp)
    800040c6:	f04a                	sd	s2,32(sp)
    800040c8:	ec4e                	sd	s3,24(sp)
    800040ca:	e852                	sd	s4,16(sp)
    800040cc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040ce:	04451703          	lh	a4,68(a0)
    800040d2:	4785                	li	a5,1
    800040d4:	00f71a63          	bne	a4,a5,800040e8 <dirlookup+0x2a>
    800040d8:	892a                	mv	s2,a0
    800040da:	89ae                	mv	s3,a1
    800040dc:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040de:	457c                	lw	a5,76(a0)
    800040e0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040e2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e4:	e79d                	bnez	a5,80004112 <dirlookup+0x54>
    800040e6:	a8a5                	j	8000415e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800040e8:	00004517          	auipc	a0,0x4
    800040ec:	52050513          	addi	a0,a0,1312 # 80008608 <syscalls+0x1b8>
    800040f0:	ffffc097          	auipc	ra,0xffffc
    800040f4:	44e080e7          	jalr	1102(ra) # 8000053e <panic>
      panic("dirlookup read");
    800040f8:	00004517          	auipc	a0,0x4
    800040fc:	52850513          	addi	a0,a0,1320 # 80008620 <syscalls+0x1d0>
    80004100:	ffffc097          	auipc	ra,0xffffc
    80004104:	43e080e7          	jalr	1086(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004108:	24c1                	addiw	s1,s1,16
    8000410a:	04c92783          	lw	a5,76(s2)
    8000410e:	04f4f763          	bgeu	s1,a5,8000415c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004112:	4741                	li	a4,16
    80004114:	86a6                	mv	a3,s1
    80004116:	fc040613          	addi	a2,s0,-64
    8000411a:	4581                	li	a1,0
    8000411c:	854a                	mv	a0,s2
    8000411e:	00000097          	auipc	ra,0x0
    80004122:	d70080e7          	jalr	-656(ra) # 80003e8e <readi>
    80004126:	47c1                	li	a5,16
    80004128:	fcf518e3          	bne	a0,a5,800040f8 <dirlookup+0x3a>
    if(de.inum == 0)
    8000412c:	fc045783          	lhu	a5,-64(s0)
    80004130:	dfe1                	beqz	a5,80004108 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004132:	fc240593          	addi	a1,s0,-62
    80004136:	854e                	mv	a0,s3
    80004138:	00000097          	auipc	ra,0x0
    8000413c:	f6c080e7          	jalr	-148(ra) # 800040a4 <namecmp>
    80004140:	f561                	bnez	a0,80004108 <dirlookup+0x4a>
      if(poff)
    80004142:	000a0463          	beqz	s4,8000414a <dirlookup+0x8c>
        *poff = off;
    80004146:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000414a:	fc045583          	lhu	a1,-64(s0)
    8000414e:	00092503          	lw	a0,0(s2)
    80004152:	fffff097          	auipc	ra,0xfffff
    80004156:	750080e7          	jalr	1872(ra) # 800038a2 <iget>
    8000415a:	a011                	j	8000415e <dirlookup+0xa0>
  return 0;
    8000415c:	4501                	li	a0,0
}
    8000415e:	70e2                	ld	ra,56(sp)
    80004160:	7442                	ld	s0,48(sp)
    80004162:	74a2                	ld	s1,40(sp)
    80004164:	7902                	ld	s2,32(sp)
    80004166:	69e2                	ld	s3,24(sp)
    80004168:	6a42                	ld	s4,16(sp)
    8000416a:	6121                	addi	sp,sp,64
    8000416c:	8082                	ret

000000008000416e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000416e:	711d                	addi	sp,sp,-96
    80004170:	ec86                	sd	ra,88(sp)
    80004172:	e8a2                	sd	s0,80(sp)
    80004174:	e4a6                	sd	s1,72(sp)
    80004176:	e0ca                	sd	s2,64(sp)
    80004178:	fc4e                	sd	s3,56(sp)
    8000417a:	f852                	sd	s4,48(sp)
    8000417c:	f456                	sd	s5,40(sp)
    8000417e:	f05a                	sd	s6,32(sp)
    80004180:	ec5e                	sd	s7,24(sp)
    80004182:	e862                	sd	s8,16(sp)
    80004184:	e466                	sd	s9,8(sp)
    80004186:	1080                	addi	s0,sp,96
    80004188:	84aa                	mv	s1,a0
    8000418a:	8aae                	mv	s5,a1
    8000418c:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000418e:	00054703          	lbu	a4,0(a0)
    80004192:	02f00793          	li	a5,47
    80004196:	02f70363          	beq	a4,a5,800041bc <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000419a:	ffffe097          	auipc	ra,0xffffe
    8000419e:	812080e7          	jalr	-2030(ra) # 800019ac <myproc>
    800041a2:	15053503          	ld	a0,336(a0)
    800041a6:	00000097          	auipc	ra,0x0
    800041aa:	9f6080e7          	jalr	-1546(ra) # 80003b9c <idup>
    800041ae:	89aa                	mv	s3,a0
  while(*path == '/')
    800041b0:	02f00913          	li	s2,47
  len = path - s;
    800041b4:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    800041b6:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041b8:	4b85                	li	s7,1
    800041ba:	a865                	j	80004272 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800041bc:	4585                	li	a1,1
    800041be:	4505                	li	a0,1
    800041c0:	fffff097          	auipc	ra,0xfffff
    800041c4:	6e2080e7          	jalr	1762(ra) # 800038a2 <iget>
    800041c8:	89aa                	mv	s3,a0
    800041ca:	b7dd                	j	800041b0 <namex+0x42>
      iunlockput(ip);
    800041cc:	854e                	mv	a0,s3
    800041ce:	00000097          	auipc	ra,0x0
    800041d2:	c6e080e7          	jalr	-914(ra) # 80003e3c <iunlockput>
      return 0;
    800041d6:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041d8:	854e                	mv	a0,s3
    800041da:	60e6                	ld	ra,88(sp)
    800041dc:	6446                	ld	s0,80(sp)
    800041de:	64a6                	ld	s1,72(sp)
    800041e0:	6906                	ld	s2,64(sp)
    800041e2:	79e2                	ld	s3,56(sp)
    800041e4:	7a42                	ld	s4,48(sp)
    800041e6:	7aa2                	ld	s5,40(sp)
    800041e8:	7b02                	ld	s6,32(sp)
    800041ea:	6be2                	ld	s7,24(sp)
    800041ec:	6c42                	ld	s8,16(sp)
    800041ee:	6ca2                	ld	s9,8(sp)
    800041f0:	6125                	addi	sp,sp,96
    800041f2:	8082                	ret
      iunlock(ip);
    800041f4:	854e                	mv	a0,s3
    800041f6:	00000097          	auipc	ra,0x0
    800041fa:	aa6080e7          	jalr	-1370(ra) # 80003c9c <iunlock>
      return ip;
    800041fe:	bfe9                	j	800041d8 <namex+0x6a>
      iunlockput(ip);
    80004200:	854e                	mv	a0,s3
    80004202:	00000097          	auipc	ra,0x0
    80004206:	c3a080e7          	jalr	-966(ra) # 80003e3c <iunlockput>
      return 0;
    8000420a:	89e6                	mv	s3,s9
    8000420c:	b7f1                	j	800041d8 <namex+0x6a>
  len = path - s;
    8000420e:	40b48633          	sub	a2,s1,a1
    80004212:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004216:	099c5463          	bge	s8,s9,8000429e <namex+0x130>
    memmove(name, s, DIRSIZ);
    8000421a:	4639                	li	a2,14
    8000421c:	8552                	mv	a0,s4
    8000421e:	ffffd097          	auipc	ra,0xffffd
    80004222:	b10080e7          	jalr	-1264(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004226:	0004c783          	lbu	a5,0(s1)
    8000422a:	01279763          	bne	a5,s2,80004238 <namex+0xca>
    path++;
    8000422e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004230:	0004c783          	lbu	a5,0(s1)
    80004234:	ff278de3          	beq	a5,s2,8000422e <namex+0xc0>
    ilock(ip);
    80004238:	854e                	mv	a0,s3
    8000423a:	00000097          	auipc	ra,0x0
    8000423e:	9a0080e7          	jalr	-1632(ra) # 80003bda <ilock>
    if(ip->type != T_DIR){
    80004242:	04499783          	lh	a5,68(s3)
    80004246:	f97793e3          	bne	a5,s7,800041cc <namex+0x5e>
    if(nameiparent && *path == '\0'){
    8000424a:	000a8563          	beqz	s5,80004254 <namex+0xe6>
    8000424e:	0004c783          	lbu	a5,0(s1)
    80004252:	d3cd                	beqz	a5,800041f4 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004254:	865a                	mv	a2,s6
    80004256:	85d2                	mv	a1,s4
    80004258:	854e                	mv	a0,s3
    8000425a:	00000097          	auipc	ra,0x0
    8000425e:	e64080e7          	jalr	-412(ra) # 800040be <dirlookup>
    80004262:	8caa                	mv	s9,a0
    80004264:	dd51                	beqz	a0,80004200 <namex+0x92>
    iunlockput(ip);
    80004266:	854e                	mv	a0,s3
    80004268:	00000097          	auipc	ra,0x0
    8000426c:	bd4080e7          	jalr	-1068(ra) # 80003e3c <iunlockput>
    ip = next;
    80004270:	89e6                	mv	s3,s9
  while(*path == '/')
    80004272:	0004c783          	lbu	a5,0(s1)
    80004276:	05279763          	bne	a5,s2,800042c4 <namex+0x156>
    path++;
    8000427a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000427c:	0004c783          	lbu	a5,0(s1)
    80004280:	ff278de3          	beq	a5,s2,8000427a <namex+0x10c>
  if(*path == 0)
    80004284:	c79d                	beqz	a5,800042b2 <namex+0x144>
    path++;
    80004286:	85a6                	mv	a1,s1
  len = path - s;
    80004288:	8cda                	mv	s9,s6
    8000428a:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000428c:	01278963          	beq	a5,s2,8000429e <namex+0x130>
    80004290:	dfbd                	beqz	a5,8000420e <namex+0xa0>
    path++;
    80004292:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004294:	0004c783          	lbu	a5,0(s1)
    80004298:	ff279ce3          	bne	a5,s2,80004290 <namex+0x122>
    8000429c:	bf8d                	j	8000420e <namex+0xa0>
    memmove(name, s, len);
    8000429e:	2601                	sext.w	a2,a2
    800042a0:	8552                	mv	a0,s4
    800042a2:	ffffd097          	auipc	ra,0xffffd
    800042a6:	a8c080e7          	jalr	-1396(ra) # 80000d2e <memmove>
    name[len] = 0;
    800042aa:	9cd2                	add	s9,s9,s4
    800042ac:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800042b0:	bf9d                	j	80004226 <namex+0xb8>
  if(nameiparent){
    800042b2:	f20a83e3          	beqz	s5,800041d8 <namex+0x6a>
    iput(ip);
    800042b6:	854e                	mv	a0,s3
    800042b8:	00000097          	auipc	ra,0x0
    800042bc:	adc080e7          	jalr	-1316(ra) # 80003d94 <iput>
    return 0;
    800042c0:	4981                	li	s3,0
    800042c2:	bf19                	j	800041d8 <namex+0x6a>
  if(*path == 0)
    800042c4:	d7fd                	beqz	a5,800042b2 <namex+0x144>
  while(*path != '/' && *path != 0)
    800042c6:	0004c783          	lbu	a5,0(s1)
    800042ca:	85a6                	mv	a1,s1
    800042cc:	b7d1                	j	80004290 <namex+0x122>

00000000800042ce <dirlink>:
{
    800042ce:	7139                	addi	sp,sp,-64
    800042d0:	fc06                	sd	ra,56(sp)
    800042d2:	f822                	sd	s0,48(sp)
    800042d4:	f426                	sd	s1,40(sp)
    800042d6:	f04a                	sd	s2,32(sp)
    800042d8:	ec4e                	sd	s3,24(sp)
    800042da:	e852                	sd	s4,16(sp)
    800042dc:	0080                	addi	s0,sp,64
    800042de:	892a                	mv	s2,a0
    800042e0:	8a2e                	mv	s4,a1
    800042e2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042e4:	4601                	li	a2,0
    800042e6:	00000097          	auipc	ra,0x0
    800042ea:	dd8080e7          	jalr	-552(ra) # 800040be <dirlookup>
    800042ee:	e93d                	bnez	a0,80004364 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042f0:	04c92483          	lw	s1,76(s2)
    800042f4:	c49d                	beqz	s1,80004322 <dirlink+0x54>
    800042f6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042f8:	4741                	li	a4,16
    800042fa:	86a6                	mv	a3,s1
    800042fc:	fc040613          	addi	a2,s0,-64
    80004300:	4581                	li	a1,0
    80004302:	854a                	mv	a0,s2
    80004304:	00000097          	auipc	ra,0x0
    80004308:	b8a080e7          	jalr	-1142(ra) # 80003e8e <readi>
    8000430c:	47c1                	li	a5,16
    8000430e:	06f51163          	bne	a0,a5,80004370 <dirlink+0xa2>
    if(de.inum == 0)
    80004312:	fc045783          	lhu	a5,-64(s0)
    80004316:	c791                	beqz	a5,80004322 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004318:	24c1                	addiw	s1,s1,16
    8000431a:	04c92783          	lw	a5,76(s2)
    8000431e:	fcf4ede3          	bltu	s1,a5,800042f8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004322:	4639                	li	a2,14
    80004324:	85d2                	mv	a1,s4
    80004326:	fc240513          	addi	a0,s0,-62
    8000432a:	ffffd097          	auipc	ra,0xffffd
    8000432e:	ab4080e7          	jalr	-1356(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004332:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004336:	4741                	li	a4,16
    80004338:	86a6                	mv	a3,s1
    8000433a:	fc040613          	addi	a2,s0,-64
    8000433e:	4581                	li	a1,0
    80004340:	854a                	mv	a0,s2
    80004342:	00000097          	auipc	ra,0x0
    80004346:	c44080e7          	jalr	-956(ra) # 80003f86 <writei>
    8000434a:	1541                	addi	a0,a0,-16
    8000434c:	00a03533          	snez	a0,a0
    80004350:	40a00533          	neg	a0,a0
}
    80004354:	70e2                	ld	ra,56(sp)
    80004356:	7442                	ld	s0,48(sp)
    80004358:	74a2                	ld	s1,40(sp)
    8000435a:	7902                	ld	s2,32(sp)
    8000435c:	69e2                	ld	s3,24(sp)
    8000435e:	6a42                	ld	s4,16(sp)
    80004360:	6121                	addi	sp,sp,64
    80004362:	8082                	ret
    iput(ip);
    80004364:	00000097          	auipc	ra,0x0
    80004368:	a30080e7          	jalr	-1488(ra) # 80003d94 <iput>
    return -1;
    8000436c:	557d                	li	a0,-1
    8000436e:	b7dd                	j	80004354 <dirlink+0x86>
      panic("dirlink read");
    80004370:	00004517          	auipc	a0,0x4
    80004374:	2c050513          	addi	a0,a0,704 # 80008630 <syscalls+0x1e0>
    80004378:	ffffc097          	auipc	ra,0xffffc
    8000437c:	1c6080e7          	jalr	454(ra) # 8000053e <panic>

0000000080004380 <namei>:

struct inode*
namei(char *path)
{
    80004380:	1101                	addi	sp,sp,-32
    80004382:	ec06                	sd	ra,24(sp)
    80004384:	e822                	sd	s0,16(sp)
    80004386:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004388:	fe040613          	addi	a2,s0,-32
    8000438c:	4581                	li	a1,0
    8000438e:	00000097          	auipc	ra,0x0
    80004392:	de0080e7          	jalr	-544(ra) # 8000416e <namex>
}
    80004396:	60e2                	ld	ra,24(sp)
    80004398:	6442                	ld	s0,16(sp)
    8000439a:	6105                	addi	sp,sp,32
    8000439c:	8082                	ret

000000008000439e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000439e:	1141                	addi	sp,sp,-16
    800043a0:	e406                	sd	ra,8(sp)
    800043a2:	e022                	sd	s0,0(sp)
    800043a4:	0800                	addi	s0,sp,16
    800043a6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043a8:	4585                	li	a1,1
    800043aa:	00000097          	auipc	ra,0x0
    800043ae:	dc4080e7          	jalr	-572(ra) # 8000416e <namex>
}
    800043b2:	60a2                	ld	ra,8(sp)
    800043b4:	6402                	ld	s0,0(sp)
    800043b6:	0141                	addi	sp,sp,16
    800043b8:	8082                	ret

00000000800043ba <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800043ba:	1101                	addi	sp,sp,-32
    800043bc:	ec06                	sd	ra,24(sp)
    800043be:	e822                	sd	s0,16(sp)
    800043c0:	e426                	sd	s1,8(sp)
    800043c2:	e04a                	sd	s2,0(sp)
    800043c4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800043c6:	0001d917          	auipc	s2,0x1d
    800043ca:	f7a90913          	addi	s2,s2,-134 # 80021340 <log>
    800043ce:	01892583          	lw	a1,24(s2)
    800043d2:	02892503          	lw	a0,40(s2)
    800043d6:	fffff097          	auipc	ra,0xfffff
    800043da:	fea080e7          	jalr	-22(ra) # 800033c0 <bread>
    800043de:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043e0:	02c92683          	lw	a3,44(s2)
    800043e4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043e6:	02d05763          	blez	a3,80004414 <write_head+0x5a>
    800043ea:	0001d797          	auipc	a5,0x1d
    800043ee:	f8678793          	addi	a5,a5,-122 # 80021370 <log+0x30>
    800043f2:	05c50713          	addi	a4,a0,92
    800043f6:	36fd                	addiw	a3,a3,-1
    800043f8:	1682                	slli	a3,a3,0x20
    800043fa:	9281                	srli	a3,a3,0x20
    800043fc:	068a                	slli	a3,a3,0x2
    800043fe:	0001d617          	auipc	a2,0x1d
    80004402:	f7660613          	addi	a2,a2,-138 # 80021374 <log+0x34>
    80004406:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004408:	4390                	lw	a2,0(a5)
    8000440a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000440c:	0791                	addi	a5,a5,4
    8000440e:	0711                	addi	a4,a4,4
    80004410:	fed79ce3          	bne	a5,a3,80004408 <write_head+0x4e>
  }
  bwrite(buf);
    80004414:	8526                	mv	a0,s1
    80004416:	fffff097          	auipc	ra,0xfffff
    8000441a:	09c080e7          	jalr	156(ra) # 800034b2 <bwrite>
  brelse(buf);
    8000441e:	8526                	mv	a0,s1
    80004420:	fffff097          	auipc	ra,0xfffff
    80004424:	0d0080e7          	jalr	208(ra) # 800034f0 <brelse>
}
    80004428:	60e2                	ld	ra,24(sp)
    8000442a:	6442                	ld	s0,16(sp)
    8000442c:	64a2                	ld	s1,8(sp)
    8000442e:	6902                	ld	s2,0(sp)
    80004430:	6105                	addi	sp,sp,32
    80004432:	8082                	ret

0000000080004434 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004434:	0001d797          	auipc	a5,0x1d
    80004438:	f387a783          	lw	a5,-200(a5) # 8002136c <log+0x2c>
    8000443c:	0af05d63          	blez	a5,800044f6 <install_trans+0xc2>
{
    80004440:	7139                	addi	sp,sp,-64
    80004442:	fc06                	sd	ra,56(sp)
    80004444:	f822                	sd	s0,48(sp)
    80004446:	f426                	sd	s1,40(sp)
    80004448:	f04a                	sd	s2,32(sp)
    8000444a:	ec4e                	sd	s3,24(sp)
    8000444c:	e852                	sd	s4,16(sp)
    8000444e:	e456                	sd	s5,8(sp)
    80004450:	e05a                	sd	s6,0(sp)
    80004452:	0080                	addi	s0,sp,64
    80004454:	8b2a                	mv	s6,a0
    80004456:	0001da97          	auipc	s5,0x1d
    8000445a:	f1aa8a93          	addi	s5,s5,-230 # 80021370 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000445e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004460:	0001d997          	auipc	s3,0x1d
    80004464:	ee098993          	addi	s3,s3,-288 # 80021340 <log>
    80004468:	a00d                	j	8000448a <install_trans+0x56>
    brelse(lbuf);
    8000446a:	854a                	mv	a0,s2
    8000446c:	fffff097          	auipc	ra,0xfffff
    80004470:	084080e7          	jalr	132(ra) # 800034f0 <brelse>
    brelse(dbuf);
    80004474:	8526                	mv	a0,s1
    80004476:	fffff097          	auipc	ra,0xfffff
    8000447a:	07a080e7          	jalr	122(ra) # 800034f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000447e:	2a05                	addiw	s4,s4,1
    80004480:	0a91                	addi	s5,s5,4
    80004482:	02c9a783          	lw	a5,44(s3)
    80004486:	04fa5e63          	bge	s4,a5,800044e2 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000448a:	0189a583          	lw	a1,24(s3)
    8000448e:	014585bb          	addw	a1,a1,s4
    80004492:	2585                	addiw	a1,a1,1
    80004494:	0289a503          	lw	a0,40(s3)
    80004498:	fffff097          	auipc	ra,0xfffff
    8000449c:	f28080e7          	jalr	-216(ra) # 800033c0 <bread>
    800044a0:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800044a2:	000aa583          	lw	a1,0(s5)
    800044a6:	0289a503          	lw	a0,40(s3)
    800044aa:	fffff097          	auipc	ra,0xfffff
    800044ae:	f16080e7          	jalr	-234(ra) # 800033c0 <bread>
    800044b2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800044b4:	40000613          	li	a2,1024
    800044b8:	05890593          	addi	a1,s2,88
    800044bc:	05850513          	addi	a0,a0,88
    800044c0:	ffffd097          	auipc	ra,0xffffd
    800044c4:	86e080e7          	jalr	-1938(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800044c8:	8526                	mv	a0,s1
    800044ca:	fffff097          	auipc	ra,0xfffff
    800044ce:	fe8080e7          	jalr	-24(ra) # 800034b2 <bwrite>
    if(recovering == 0)
    800044d2:	f80b1ce3          	bnez	s6,8000446a <install_trans+0x36>
      bunpin(dbuf);
    800044d6:	8526                	mv	a0,s1
    800044d8:	fffff097          	auipc	ra,0xfffff
    800044dc:	0f2080e7          	jalr	242(ra) # 800035ca <bunpin>
    800044e0:	b769                	j	8000446a <install_trans+0x36>
}
    800044e2:	70e2                	ld	ra,56(sp)
    800044e4:	7442                	ld	s0,48(sp)
    800044e6:	74a2                	ld	s1,40(sp)
    800044e8:	7902                	ld	s2,32(sp)
    800044ea:	69e2                	ld	s3,24(sp)
    800044ec:	6a42                	ld	s4,16(sp)
    800044ee:	6aa2                	ld	s5,8(sp)
    800044f0:	6b02                	ld	s6,0(sp)
    800044f2:	6121                	addi	sp,sp,64
    800044f4:	8082                	ret
    800044f6:	8082                	ret

00000000800044f8 <initlog>:
{
    800044f8:	7179                	addi	sp,sp,-48
    800044fa:	f406                	sd	ra,40(sp)
    800044fc:	f022                	sd	s0,32(sp)
    800044fe:	ec26                	sd	s1,24(sp)
    80004500:	e84a                	sd	s2,16(sp)
    80004502:	e44e                	sd	s3,8(sp)
    80004504:	1800                	addi	s0,sp,48
    80004506:	892a                	mv	s2,a0
    80004508:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000450a:	0001d497          	auipc	s1,0x1d
    8000450e:	e3648493          	addi	s1,s1,-458 # 80021340 <log>
    80004512:	00004597          	auipc	a1,0x4
    80004516:	12e58593          	addi	a1,a1,302 # 80008640 <syscalls+0x1f0>
    8000451a:	8526                	mv	a0,s1
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	62a080e7          	jalr	1578(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004524:	0149a583          	lw	a1,20(s3)
    80004528:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000452a:	0109a783          	lw	a5,16(s3)
    8000452e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004530:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004534:	854a                	mv	a0,s2
    80004536:	fffff097          	auipc	ra,0xfffff
    8000453a:	e8a080e7          	jalr	-374(ra) # 800033c0 <bread>
  log.lh.n = lh->n;
    8000453e:	4d34                	lw	a3,88(a0)
    80004540:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004542:	02d05563          	blez	a3,8000456c <initlog+0x74>
    80004546:	05c50793          	addi	a5,a0,92
    8000454a:	0001d717          	auipc	a4,0x1d
    8000454e:	e2670713          	addi	a4,a4,-474 # 80021370 <log+0x30>
    80004552:	36fd                	addiw	a3,a3,-1
    80004554:	1682                	slli	a3,a3,0x20
    80004556:	9281                	srli	a3,a3,0x20
    80004558:	068a                	slli	a3,a3,0x2
    8000455a:	06050613          	addi	a2,a0,96
    8000455e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004560:	4390                	lw	a2,0(a5)
    80004562:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004564:	0791                	addi	a5,a5,4
    80004566:	0711                	addi	a4,a4,4
    80004568:	fed79ce3          	bne	a5,a3,80004560 <initlog+0x68>
  brelse(buf);
    8000456c:	fffff097          	auipc	ra,0xfffff
    80004570:	f84080e7          	jalr	-124(ra) # 800034f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004574:	4505                	li	a0,1
    80004576:	00000097          	auipc	ra,0x0
    8000457a:	ebe080e7          	jalr	-322(ra) # 80004434 <install_trans>
  log.lh.n = 0;
    8000457e:	0001d797          	auipc	a5,0x1d
    80004582:	de07a723          	sw	zero,-530(a5) # 8002136c <log+0x2c>
  write_head(); // clear the log
    80004586:	00000097          	auipc	ra,0x0
    8000458a:	e34080e7          	jalr	-460(ra) # 800043ba <write_head>
}
    8000458e:	70a2                	ld	ra,40(sp)
    80004590:	7402                	ld	s0,32(sp)
    80004592:	64e2                	ld	s1,24(sp)
    80004594:	6942                	ld	s2,16(sp)
    80004596:	69a2                	ld	s3,8(sp)
    80004598:	6145                	addi	sp,sp,48
    8000459a:	8082                	ret

000000008000459c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000459c:	1101                	addi	sp,sp,-32
    8000459e:	ec06                	sd	ra,24(sp)
    800045a0:	e822                	sd	s0,16(sp)
    800045a2:	e426                	sd	s1,8(sp)
    800045a4:	e04a                	sd	s2,0(sp)
    800045a6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800045a8:	0001d517          	auipc	a0,0x1d
    800045ac:	d9850513          	addi	a0,a0,-616 # 80021340 <log>
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	626080e7          	jalr	1574(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800045b8:	0001d497          	auipc	s1,0x1d
    800045bc:	d8848493          	addi	s1,s1,-632 # 80021340 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045c0:	4979                	li	s2,30
    800045c2:	a039                	j	800045d0 <begin_op+0x34>
      sleep(&log, &log.lock);
    800045c4:	85a6                	mv	a1,s1
    800045c6:	8526                	mv	a0,s1
    800045c8:	ffffe097          	auipc	ra,0xffffe
    800045cc:	a8c080e7          	jalr	-1396(ra) # 80002054 <sleep>
    if(log.committing){
    800045d0:	50dc                	lw	a5,36(s1)
    800045d2:	fbed                	bnez	a5,800045c4 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800045d4:	509c                	lw	a5,32(s1)
    800045d6:	0017871b          	addiw	a4,a5,1
    800045da:	0007069b          	sext.w	a3,a4
    800045de:	0027179b          	slliw	a5,a4,0x2
    800045e2:	9fb9                	addw	a5,a5,a4
    800045e4:	0017979b          	slliw	a5,a5,0x1
    800045e8:	54d8                	lw	a4,44(s1)
    800045ea:	9fb9                	addw	a5,a5,a4
    800045ec:	00f95963          	bge	s2,a5,800045fe <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800045f0:	85a6                	mv	a1,s1
    800045f2:	8526                	mv	a0,s1
    800045f4:	ffffe097          	auipc	ra,0xffffe
    800045f8:	a60080e7          	jalr	-1440(ra) # 80002054 <sleep>
    800045fc:	bfd1                	j	800045d0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800045fe:	0001d517          	auipc	a0,0x1d
    80004602:	d4250513          	addi	a0,a0,-702 # 80021340 <log>
    80004606:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004608:	ffffc097          	auipc	ra,0xffffc
    8000460c:	682080e7          	jalr	1666(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004610:	60e2                	ld	ra,24(sp)
    80004612:	6442                	ld	s0,16(sp)
    80004614:	64a2                	ld	s1,8(sp)
    80004616:	6902                	ld	s2,0(sp)
    80004618:	6105                	addi	sp,sp,32
    8000461a:	8082                	ret

000000008000461c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000461c:	7139                	addi	sp,sp,-64
    8000461e:	fc06                	sd	ra,56(sp)
    80004620:	f822                	sd	s0,48(sp)
    80004622:	f426                	sd	s1,40(sp)
    80004624:	f04a                	sd	s2,32(sp)
    80004626:	ec4e                	sd	s3,24(sp)
    80004628:	e852                	sd	s4,16(sp)
    8000462a:	e456                	sd	s5,8(sp)
    8000462c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000462e:	0001d497          	auipc	s1,0x1d
    80004632:	d1248493          	addi	s1,s1,-750 # 80021340 <log>
    80004636:	8526                	mv	a0,s1
    80004638:	ffffc097          	auipc	ra,0xffffc
    8000463c:	59e080e7          	jalr	1438(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004640:	509c                	lw	a5,32(s1)
    80004642:	37fd                	addiw	a5,a5,-1
    80004644:	0007891b          	sext.w	s2,a5
    80004648:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000464a:	50dc                	lw	a5,36(s1)
    8000464c:	e7b9                	bnez	a5,8000469a <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000464e:	04091e63          	bnez	s2,800046aa <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004652:	0001d497          	auipc	s1,0x1d
    80004656:	cee48493          	addi	s1,s1,-786 # 80021340 <log>
    8000465a:	4785                	li	a5,1
    8000465c:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000465e:	8526                	mv	a0,s1
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	62a080e7          	jalr	1578(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004668:	54dc                	lw	a5,44(s1)
    8000466a:	06f04763          	bgtz	a5,800046d8 <end_op+0xbc>
    acquire(&log.lock);
    8000466e:	0001d497          	auipc	s1,0x1d
    80004672:	cd248493          	addi	s1,s1,-814 # 80021340 <log>
    80004676:	8526                	mv	a0,s1
    80004678:	ffffc097          	auipc	ra,0xffffc
    8000467c:	55e080e7          	jalr	1374(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004680:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004684:	8526                	mv	a0,s1
    80004686:	ffffe097          	auipc	ra,0xffffe
    8000468a:	a32080e7          	jalr	-1486(ra) # 800020b8 <wakeup>
    release(&log.lock);
    8000468e:	8526                	mv	a0,s1
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	5fa080e7          	jalr	1530(ra) # 80000c8a <release>
}
    80004698:	a03d                	j	800046c6 <end_op+0xaa>
    panic("log.committing");
    8000469a:	00004517          	auipc	a0,0x4
    8000469e:	fae50513          	addi	a0,a0,-82 # 80008648 <syscalls+0x1f8>
    800046a2:	ffffc097          	auipc	ra,0xffffc
    800046a6:	e9c080e7          	jalr	-356(ra) # 8000053e <panic>
    wakeup(&log);
    800046aa:	0001d497          	auipc	s1,0x1d
    800046ae:	c9648493          	addi	s1,s1,-874 # 80021340 <log>
    800046b2:	8526                	mv	a0,s1
    800046b4:	ffffe097          	auipc	ra,0xffffe
    800046b8:	a04080e7          	jalr	-1532(ra) # 800020b8 <wakeup>
  release(&log.lock);
    800046bc:	8526                	mv	a0,s1
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	5cc080e7          	jalr	1484(ra) # 80000c8a <release>
}
    800046c6:	70e2                	ld	ra,56(sp)
    800046c8:	7442                	ld	s0,48(sp)
    800046ca:	74a2                	ld	s1,40(sp)
    800046cc:	7902                	ld	s2,32(sp)
    800046ce:	69e2                	ld	s3,24(sp)
    800046d0:	6a42                	ld	s4,16(sp)
    800046d2:	6aa2                	ld	s5,8(sp)
    800046d4:	6121                	addi	sp,sp,64
    800046d6:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800046d8:	0001da97          	auipc	s5,0x1d
    800046dc:	c98a8a93          	addi	s5,s5,-872 # 80021370 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800046e0:	0001da17          	auipc	s4,0x1d
    800046e4:	c60a0a13          	addi	s4,s4,-928 # 80021340 <log>
    800046e8:	018a2583          	lw	a1,24(s4)
    800046ec:	012585bb          	addw	a1,a1,s2
    800046f0:	2585                	addiw	a1,a1,1
    800046f2:	028a2503          	lw	a0,40(s4)
    800046f6:	fffff097          	auipc	ra,0xfffff
    800046fa:	cca080e7          	jalr	-822(ra) # 800033c0 <bread>
    800046fe:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004700:	000aa583          	lw	a1,0(s5)
    80004704:	028a2503          	lw	a0,40(s4)
    80004708:	fffff097          	auipc	ra,0xfffff
    8000470c:	cb8080e7          	jalr	-840(ra) # 800033c0 <bread>
    80004710:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004712:	40000613          	li	a2,1024
    80004716:	05850593          	addi	a1,a0,88
    8000471a:	05848513          	addi	a0,s1,88
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	610080e7          	jalr	1552(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004726:	8526                	mv	a0,s1
    80004728:	fffff097          	auipc	ra,0xfffff
    8000472c:	d8a080e7          	jalr	-630(ra) # 800034b2 <bwrite>
    brelse(from);
    80004730:	854e                	mv	a0,s3
    80004732:	fffff097          	auipc	ra,0xfffff
    80004736:	dbe080e7          	jalr	-578(ra) # 800034f0 <brelse>
    brelse(to);
    8000473a:	8526                	mv	a0,s1
    8000473c:	fffff097          	auipc	ra,0xfffff
    80004740:	db4080e7          	jalr	-588(ra) # 800034f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004744:	2905                	addiw	s2,s2,1
    80004746:	0a91                	addi	s5,s5,4
    80004748:	02ca2783          	lw	a5,44(s4)
    8000474c:	f8f94ee3          	blt	s2,a5,800046e8 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004750:	00000097          	auipc	ra,0x0
    80004754:	c6a080e7          	jalr	-918(ra) # 800043ba <write_head>
    install_trans(0); // Now install writes to home locations
    80004758:	4501                	li	a0,0
    8000475a:	00000097          	auipc	ra,0x0
    8000475e:	cda080e7          	jalr	-806(ra) # 80004434 <install_trans>
    log.lh.n = 0;
    80004762:	0001d797          	auipc	a5,0x1d
    80004766:	c007a523          	sw	zero,-1014(a5) # 8002136c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000476a:	00000097          	auipc	ra,0x0
    8000476e:	c50080e7          	jalr	-944(ra) # 800043ba <write_head>
    80004772:	bdf5                	j	8000466e <end_op+0x52>

0000000080004774 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004774:	1101                	addi	sp,sp,-32
    80004776:	ec06                	sd	ra,24(sp)
    80004778:	e822                	sd	s0,16(sp)
    8000477a:	e426                	sd	s1,8(sp)
    8000477c:	e04a                	sd	s2,0(sp)
    8000477e:	1000                	addi	s0,sp,32
    80004780:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004782:	0001d917          	auipc	s2,0x1d
    80004786:	bbe90913          	addi	s2,s2,-1090 # 80021340 <log>
    8000478a:	854a                	mv	a0,s2
    8000478c:	ffffc097          	auipc	ra,0xffffc
    80004790:	44a080e7          	jalr	1098(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004794:	02c92603          	lw	a2,44(s2)
    80004798:	47f5                	li	a5,29
    8000479a:	06c7c563          	blt	a5,a2,80004804 <log_write+0x90>
    8000479e:	0001d797          	auipc	a5,0x1d
    800047a2:	bbe7a783          	lw	a5,-1090(a5) # 8002135c <log+0x1c>
    800047a6:	37fd                	addiw	a5,a5,-1
    800047a8:	04f65e63          	bge	a2,a5,80004804 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800047ac:	0001d797          	auipc	a5,0x1d
    800047b0:	bb47a783          	lw	a5,-1100(a5) # 80021360 <log+0x20>
    800047b4:	06f05063          	blez	a5,80004814 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800047b8:	4781                	li	a5,0
    800047ba:	06c05563          	blez	a2,80004824 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047be:	44cc                	lw	a1,12(s1)
    800047c0:	0001d717          	auipc	a4,0x1d
    800047c4:	bb070713          	addi	a4,a4,-1104 # 80021370 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800047c8:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800047ca:	4314                	lw	a3,0(a4)
    800047cc:	04b68c63          	beq	a3,a1,80004824 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800047d0:	2785                	addiw	a5,a5,1
    800047d2:	0711                	addi	a4,a4,4
    800047d4:	fef61be3          	bne	a2,a5,800047ca <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800047d8:	0621                	addi	a2,a2,8
    800047da:	060a                	slli	a2,a2,0x2
    800047dc:	0001d797          	auipc	a5,0x1d
    800047e0:	b6478793          	addi	a5,a5,-1180 # 80021340 <log>
    800047e4:	963e                	add	a2,a2,a5
    800047e6:	44dc                	lw	a5,12(s1)
    800047e8:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800047ea:	8526                	mv	a0,s1
    800047ec:	fffff097          	auipc	ra,0xfffff
    800047f0:	da2080e7          	jalr	-606(ra) # 8000358e <bpin>
    log.lh.n++;
    800047f4:	0001d717          	auipc	a4,0x1d
    800047f8:	b4c70713          	addi	a4,a4,-1204 # 80021340 <log>
    800047fc:	575c                	lw	a5,44(a4)
    800047fe:	2785                	addiw	a5,a5,1
    80004800:	d75c                	sw	a5,44(a4)
    80004802:	a835                	j	8000483e <log_write+0xca>
    panic("too big a transaction");
    80004804:	00004517          	auipc	a0,0x4
    80004808:	e5450513          	addi	a0,a0,-428 # 80008658 <syscalls+0x208>
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	d32080e7          	jalr	-718(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004814:	00004517          	auipc	a0,0x4
    80004818:	e5c50513          	addi	a0,a0,-420 # 80008670 <syscalls+0x220>
    8000481c:	ffffc097          	auipc	ra,0xffffc
    80004820:	d22080e7          	jalr	-734(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004824:	00878713          	addi	a4,a5,8
    80004828:	00271693          	slli	a3,a4,0x2
    8000482c:	0001d717          	auipc	a4,0x1d
    80004830:	b1470713          	addi	a4,a4,-1260 # 80021340 <log>
    80004834:	9736                	add	a4,a4,a3
    80004836:	44d4                	lw	a3,12(s1)
    80004838:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000483a:	faf608e3          	beq	a2,a5,800047ea <log_write+0x76>
  }
  release(&log.lock);
    8000483e:	0001d517          	auipc	a0,0x1d
    80004842:	b0250513          	addi	a0,a0,-1278 # 80021340 <log>
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	444080e7          	jalr	1092(ra) # 80000c8a <release>
}
    8000484e:	60e2                	ld	ra,24(sp)
    80004850:	6442                	ld	s0,16(sp)
    80004852:	64a2                	ld	s1,8(sp)
    80004854:	6902                	ld	s2,0(sp)
    80004856:	6105                	addi	sp,sp,32
    80004858:	8082                	ret

000000008000485a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000485a:	1101                	addi	sp,sp,-32
    8000485c:	ec06                	sd	ra,24(sp)
    8000485e:	e822                	sd	s0,16(sp)
    80004860:	e426                	sd	s1,8(sp)
    80004862:	e04a                	sd	s2,0(sp)
    80004864:	1000                	addi	s0,sp,32
    80004866:	84aa                	mv	s1,a0
    80004868:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000486a:	00004597          	auipc	a1,0x4
    8000486e:	e2658593          	addi	a1,a1,-474 # 80008690 <syscalls+0x240>
    80004872:	0521                	addi	a0,a0,8
    80004874:	ffffc097          	auipc	ra,0xffffc
    80004878:	2d2080e7          	jalr	722(ra) # 80000b46 <initlock>
  lk->name = name;
    8000487c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004880:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004884:	0204a423          	sw	zero,40(s1)
}
    80004888:	60e2                	ld	ra,24(sp)
    8000488a:	6442                	ld	s0,16(sp)
    8000488c:	64a2                	ld	s1,8(sp)
    8000488e:	6902                	ld	s2,0(sp)
    80004890:	6105                	addi	sp,sp,32
    80004892:	8082                	ret

0000000080004894 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004894:	1101                	addi	sp,sp,-32
    80004896:	ec06                	sd	ra,24(sp)
    80004898:	e822                	sd	s0,16(sp)
    8000489a:	e426                	sd	s1,8(sp)
    8000489c:	e04a                	sd	s2,0(sp)
    8000489e:	1000                	addi	s0,sp,32
    800048a0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048a2:	00850913          	addi	s2,a0,8
    800048a6:	854a                	mv	a0,s2
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	32e080e7          	jalr	814(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800048b0:	409c                	lw	a5,0(s1)
    800048b2:	cb89                	beqz	a5,800048c4 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800048b4:	85ca                	mv	a1,s2
    800048b6:	8526                	mv	a0,s1
    800048b8:	ffffd097          	auipc	ra,0xffffd
    800048bc:	79c080e7          	jalr	1948(ra) # 80002054 <sleep>
  while (lk->locked) {
    800048c0:	409c                	lw	a5,0(s1)
    800048c2:	fbed                	bnez	a5,800048b4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800048c4:	4785                	li	a5,1
    800048c6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800048c8:	ffffd097          	auipc	ra,0xffffd
    800048cc:	0e4080e7          	jalr	228(ra) # 800019ac <myproc>
    800048d0:	591c                	lw	a5,48(a0)
    800048d2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800048d4:	854a                	mv	a0,s2
    800048d6:	ffffc097          	auipc	ra,0xffffc
    800048da:	3b4080e7          	jalr	948(ra) # 80000c8a <release>
}
    800048de:	60e2                	ld	ra,24(sp)
    800048e0:	6442                	ld	s0,16(sp)
    800048e2:	64a2                	ld	s1,8(sp)
    800048e4:	6902                	ld	s2,0(sp)
    800048e6:	6105                	addi	sp,sp,32
    800048e8:	8082                	ret

00000000800048ea <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800048ea:	1101                	addi	sp,sp,-32
    800048ec:	ec06                	sd	ra,24(sp)
    800048ee:	e822                	sd	s0,16(sp)
    800048f0:	e426                	sd	s1,8(sp)
    800048f2:	e04a                	sd	s2,0(sp)
    800048f4:	1000                	addi	s0,sp,32
    800048f6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800048f8:	00850913          	addi	s2,a0,8
    800048fc:	854a                	mv	a0,s2
    800048fe:	ffffc097          	auipc	ra,0xffffc
    80004902:	2d8080e7          	jalr	728(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004906:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000490a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000490e:	8526                	mv	a0,s1
    80004910:	ffffd097          	auipc	ra,0xffffd
    80004914:	7a8080e7          	jalr	1960(ra) # 800020b8 <wakeup>
  release(&lk->lk);
    80004918:	854a                	mv	a0,s2
    8000491a:	ffffc097          	auipc	ra,0xffffc
    8000491e:	370080e7          	jalr	880(ra) # 80000c8a <release>
}
    80004922:	60e2                	ld	ra,24(sp)
    80004924:	6442                	ld	s0,16(sp)
    80004926:	64a2                	ld	s1,8(sp)
    80004928:	6902                	ld	s2,0(sp)
    8000492a:	6105                	addi	sp,sp,32
    8000492c:	8082                	ret

000000008000492e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000492e:	7179                	addi	sp,sp,-48
    80004930:	f406                	sd	ra,40(sp)
    80004932:	f022                	sd	s0,32(sp)
    80004934:	ec26                	sd	s1,24(sp)
    80004936:	e84a                	sd	s2,16(sp)
    80004938:	e44e                	sd	s3,8(sp)
    8000493a:	1800                	addi	s0,sp,48
    8000493c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000493e:	00850913          	addi	s2,a0,8
    80004942:	854a                	mv	a0,s2
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	292080e7          	jalr	658(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000494c:	409c                	lw	a5,0(s1)
    8000494e:	ef99                	bnez	a5,8000496c <holdingsleep+0x3e>
    80004950:	4481                	li	s1,0
  release(&lk->lk);
    80004952:	854a                	mv	a0,s2
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	336080e7          	jalr	822(ra) # 80000c8a <release>
  return r;
}
    8000495c:	8526                	mv	a0,s1
    8000495e:	70a2                	ld	ra,40(sp)
    80004960:	7402                	ld	s0,32(sp)
    80004962:	64e2                	ld	s1,24(sp)
    80004964:	6942                	ld	s2,16(sp)
    80004966:	69a2                	ld	s3,8(sp)
    80004968:	6145                	addi	sp,sp,48
    8000496a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000496c:	0284a983          	lw	s3,40(s1)
    80004970:	ffffd097          	auipc	ra,0xffffd
    80004974:	03c080e7          	jalr	60(ra) # 800019ac <myproc>
    80004978:	5904                	lw	s1,48(a0)
    8000497a:	413484b3          	sub	s1,s1,s3
    8000497e:	0014b493          	seqz	s1,s1
    80004982:	bfc1                	j	80004952 <holdingsleep+0x24>

0000000080004984 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004984:	1141                	addi	sp,sp,-16
    80004986:	e406                	sd	ra,8(sp)
    80004988:	e022                	sd	s0,0(sp)
    8000498a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000498c:	00004597          	auipc	a1,0x4
    80004990:	d1458593          	addi	a1,a1,-748 # 800086a0 <syscalls+0x250>
    80004994:	0001d517          	auipc	a0,0x1d
    80004998:	af450513          	addi	a0,a0,-1292 # 80021488 <ftable>
    8000499c:	ffffc097          	auipc	ra,0xffffc
    800049a0:	1aa080e7          	jalr	426(ra) # 80000b46 <initlock>
}
    800049a4:	60a2                	ld	ra,8(sp)
    800049a6:	6402                	ld	s0,0(sp)
    800049a8:	0141                	addi	sp,sp,16
    800049aa:	8082                	ret

00000000800049ac <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800049ac:	1101                	addi	sp,sp,-32
    800049ae:	ec06                	sd	ra,24(sp)
    800049b0:	e822                	sd	s0,16(sp)
    800049b2:	e426                	sd	s1,8(sp)
    800049b4:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800049b6:	0001d517          	auipc	a0,0x1d
    800049ba:	ad250513          	addi	a0,a0,-1326 # 80021488 <ftable>
    800049be:	ffffc097          	auipc	ra,0xffffc
    800049c2:	218080e7          	jalr	536(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049c6:	0001d497          	auipc	s1,0x1d
    800049ca:	ada48493          	addi	s1,s1,-1318 # 800214a0 <ftable+0x18>
    800049ce:	0001e717          	auipc	a4,0x1e
    800049d2:	a7270713          	addi	a4,a4,-1422 # 80022440 <disk>
    if(f->ref == 0){
    800049d6:	40dc                	lw	a5,4(s1)
    800049d8:	cf99                	beqz	a5,800049f6 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800049da:	02848493          	addi	s1,s1,40
    800049de:	fee49ce3          	bne	s1,a4,800049d6 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800049e2:	0001d517          	auipc	a0,0x1d
    800049e6:	aa650513          	addi	a0,a0,-1370 # 80021488 <ftable>
    800049ea:	ffffc097          	auipc	ra,0xffffc
    800049ee:	2a0080e7          	jalr	672(ra) # 80000c8a <release>
  return 0;
    800049f2:	4481                	li	s1,0
    800049f4:	a819                	j	80004a0a <filealloc+0x5e>
      f->ref = 1;
    800049f6:	4785                	li	a5,1
    800049f8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800049fa:	0001d517          	auipc	a0,0x1d
    800049fe:	a8e50513          	addi	a0,a0,-1394 # 80021488 <ftable>
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	288080e7          	jalr	648(ra) # 80000c8a <release>
}
    80004a0a:	8526                	mv	a0,s1
    80004a0c:	60e2                	ld	ra,24(sp)
    80004a0e:	6442                	ld	s0,16(sp)
    80004a10:	64a2                	ld	s1,8(sp)
    80004a12:	6105                	addi	sp,sp,32
    80004a14:	8082                	ret

0000000080004a16 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004a16:	1101                	addi	sp,sp,-32
    80004a18:	ec06                	sd	ra,24(sp)
    80004a1a:	e822                	sd	s0,16(sp)
    80004a1c:	e426                	sd	s1,8(sp)
    80004a1e:	1000                	addi	s0,sp,32
    80004a20:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004a22:	0001d517          	auipc	a0,0x1d
    80004a26:	a6650513          	addi	a0,a0,-1434 # 80021488 <ftable>
    80004a2a:	ffffc097          	auipc	ra,0xffffc
    80004a2e:	1ac080e7          	jalr	428(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a32:	40dc                	lw	a5,4(s1)
    80004a34:	02f05263          	blez	a5,80004a58 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004a38:	2785                	addiw	a5,a5,1
    80004a3a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004a3c:	0001d517          	auipc	a0,0x1d
    80004a40:	a4c50513          	addi	a0,a0,-1460 # 80021488 <ftable>
    80004a44:	ffffc097          	auipc	ra,0xffffc
    80004a48:	246080e7          	jalr	582(ra) # 80000c8a <release>
  return f;
}
    80004a4c:	8526                	mv	a0,s1
    80004a4e:	60e2                	ld	ra,24(sp)
    80004a50:	6442                	ld	s0,16(sp)
    80004a52:	64a2                	ld	s1,8(sp)
    80004a54:	6105                	addi	sp,sp,32
    80004a56:	8082                	ret
    panic("filedup");
    80004a58:	00004517          	auipc	a0,0x4
    80004a5c:	c5050513          	addi	a0,a0,-944 # 800086a8 <syscalls+0x258>
    80004a60:	ffffc097          	auipc	ra,0xffffc
    80004a64:	ade080e7          	jalr	-1314(ra) # 8000053e <panic>

0000000080004a68 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004a68:	7139                	addi	sp,sp,-64
    80004a6a:	fc06                	sd	ra,56(sp)
    80004a6c:	f822                	sd	s0,48(sp)
    80004a6e:	f426                	sd	s1,40(sp)
    80004a70:	f04a                	sd	s2,32(sp)
    80004a72:	ec4e                	sd	s3,24(sp)
    80004a74:	e852                	sd	s4,16(sp)
    80004a76:	e456                	sd	s5,8(sp)
    80004a78:	0080                	addi	s0,sp,64
    80004a7a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a7c:	0001d517          	auipc	a0,0x1d
    80004a80:	a0c50513          	addi	a0,a0,-1524 # 80021488 <ftable>
    80004a84:	ffffc097          	auipc	ra,0xffffc
    80004a88:	152080e7          	jalr	338(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a8c:	40dc                	lw	a5,4(s1)
    80004a8e:	06f05163          	blez	a5,80004af0 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a92:	37fd                	addiw	a5,a5,-1
    80004a94:	0007871b          	sext.w	a4,a5
    80004a98:	c0dc                	sw	a5,4(s1)
    80004a9a:	06e04363          	bgtz	a4,80004b00 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a9e:	0004a903          	lw	s2,0(s1)
    80004aa2:	0094ca83          	lbu	s5,9(s1)
    80004aa6:	0104ba03          	ld	s4,16(s1)
    80004aaa:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004aae:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004ab2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004ab6:	0001d517          	auipc	a0,0x1d
    80004aba:	9d250513          	addi	a0,a0,-1582 # 80021488 <ftable>
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	1cc080e7          	jalr	460(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004ac6:	4785                	li	a5,1
    80004ac8:	04f90d63          	beq	s2,a5,80004b22 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004acc:	3979                	addiw	s2,s2,-2
    80004ace:	4785                	li	a5,1
    80004ad0:	0527e063          	bltu	a5,s2,80004b10 <fileclose+0xa8>
    begin_op();
    80004ad4:	00000097          	auipc	ra,0x0
    80004ad8:	ac8080e7          	jalr	-1336(ra) # 8000459c <begin_op>
    iput(ff.ip);
    80004adc:	854e                	mv	a0,s3
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	2b6080e7          	jalr	694(ra) # 80003d94 <iput>
    end_op();
    80004ae6:	00000097          	auipc	ra,0x0
    80004aea:	b36080e7          	jalr	-1226(ra) # 8000461c <end_op>
    80004aee:	a00d                	j	80004b10 <fileclose+0xa8>
    panic("fileclose");
    80004af0:	00004517          	auipc	a0,0x4
    80004af4:	bc050513          	addi	a0,a0,-1088 # 800086b0 <syscalls+0x260>
    80004af8:	ffffc097          	auipc	ra,0xffffc
    80004afc:	a46080e7          	jalr	-1466(ra) # 8000053e <panic>
    release(&ftable.lock);
    80004b00:	0001d517          	auipc	a0,0x1d
    80004b04:	98850513          	addi	a0,a0,-1656 # 80021488 <ftable>
    80004b08:	ffffc097          	auipc	ra,0xffffc
    80004b0c:	182080e7          	jalr	386(ra) # 80000c8a <release>
  }
}
    80004b10:	70e2                	ld	ra,56(sp)
    80004b12:	7442                	ld	s0,48(sp)
    80004b14:	74a2                	ld	s1,40(sp)
    80004b16:	7902                	ld	s2,32(sp)
    80004b18:	69e2                	ld	s3,24(sp)
    80004b1a:	6a42                	ld	s4,16(sp)
    80004b1c:	6aa2                	ld	s5,8(sp)
    80004b1e:	6121                	addi	sp,sp,64
    80004b20:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004b22:	85d6                	mv	a1,s5
    80004b24:	8552                	mv	a0,s4
    80004b26:	00000097          	auipc	ra,0x0
    80004b2a:	34c080e7          	jalr	844(ra) # 80004e72 <pipeclose>
    80004b2e:	b7cd                	j	80004b10 <fileclose+0xa8>

0000000080004b30 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004b30:	715d                	addi	sp,sp,-80
    80004b32:	e486                	sd	ra,72(sp)
    80004b34:	e0a2                	sd	s0,64(sp)
    80004b36:	fc26                	sd	s1,56(sp)
    80004b38:	f84a                	sd	s2,48(sp)
    80004b3a:	f44e                	sd	s3,40(sp)
    80004b3c:	0880                	addi	s0,sp,80
    80004b3e:	84aa                	mv	s1,a0
    80004b40:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004b42:	ffffd097          	auipc	ra,0xffffd
    80004b46:	e6a080e7          	jalr	-406(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004b4a:	409c                	lw	a5,0(s1)
    80004b4c:	37f9                	addiw	a5,a5,-2
    80004b4e:	4705                	li	a4,1
    80004b50:	04f76763          	bltu	a4,a5,80004b9e <filestat+0x6e>
    80004b54:	892a                	mv	s2,a0
    ilock(f->ip);
    80004b56:	6c88                	ld	a0,24(s1)
    80004b58:	fffff097          	auipc	ra,0xfffff
    80004b5c:	082080e7          	jalr	130(ra) # 80003bda <ilock>
    stati(f->ip, &st);
    80004b60:	fb840593          	addi	a1,s0,-72
    80004b64:	6c88                	ld	a0,24(s1)
    80004b66:	fffff097          	auipc	ra,0xfffff
    80004b6a:	2fe080e7          	jalr	766(ra) # 80003e64 <stati>
    iunlock(f->ip);
    80004b6e:	6c88                	ld	a0,24(s1)
    80004b70:	fffff097          	auipc	ra,0xfffff
    80004b74:	12c080e7          	jalr	300(ra) # 80003c9c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b78:	46e1                	li	a3,24
    80004b7a:	fb840613          	addi	a2,s0,-72
    80004b7e:	85ce                	mv	a1,s3
    80004b80:	05093503          	ld	a0,80(s2)
    80004b84:	ffffd097          	auipc	ra,0xffffd
    80004b88:	ae4080e7          	jalr	-1308(ra) # 80001668 <copyout>
    80004b8c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b90:	60a6                	ld	ra,72(sp)
    80004b92:	6406                	ld	s0,64(sp)
    80004b94:	74e2                	ld	s1,56(sp)
    80004b96:	7942                	ld	s2,48(sp)
    80004b98:	79a2                	ld	s3,40(sp)
    80004b9a:	6161                	addi	sp,sp,80
    80004b9c:	8082                	ret
  return -1;
    80004b9e:	557d                	li	a0,-1
    80004ba0:	bfc5                	j	80004b90 <filestat+0x60>

0000000080004ba2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004ba2:	7179                	addi	sp,sp,-48
    80004ba4:	f406                	sd	ra,40(sp)
    80004ba6:	f022                	sd	s0,32(sp)
    80004ba8:	ec26                	sd	s1,24(sp)
    80004baa:	e84a                	sd	s2,16(sp)
    80004bac:	e44e                	sd	s3,8(sp)
    80004bae:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004bb0:	00854783          	lbu	a5,8(a0)
    80004bb4:	c3d5                	beqz	a5,80004c58 <fileread+0xb6>
    80004bb6:	84aa                	mv	s1,a0
    80004bb8:	89ae                	mv	s3,a1
    80004bba:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004bbc:	411c                	lw	a5,0(a0)
    80004bbe:	4705                	li	a4,1
    80004bc0:	04e78963          	beq	a5,a4,80004c12 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004bc4:	470d                	li	a4,3
    80004bc6:	04e78d63          	beq	a5,a4,80004c20 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004bca:	4709                	li	a4,2
    80004bcc:	06e79e63          	bne	a5,a4,80004c48 <fileread+0xa6>
    ilock(f->ip);
    80004bd0:	6d08                	ld	a0,24(a0)
    80004bd2:	fffff097          	auipc	ra,0xfffff
    80004bd6:	008080e7          	jalr	8(ra) # 80003bda <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004bda:	874a                	mv	a4,s2
    80004bdc:	5094                	lw	a3,32(s1)
    80004bde:	864e                	mv	a2,s3
    80004be0:	4585                	li	a1,1
    80004be2:	6c88                	ld	a0,24(s1)
    80004be4:	fffff097          	auipc	ra,0xfffff
    80004be8:	2aa080e7          	jalr	682(ra) # 80003e8e <readi>
    80004bec:	892a                	mv	s2,a0
    80004bee:	00a05563          	blez	a0,80004bf8 <fileread+0x56>
      f->off += r;
    80004bf2:	509c                	lw	a5,32(s1)
    80004bf4:	9fa9                	addw	a5,a5,a0
    80004bf6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004bf8:	6c88                	ld	a0,24(s1)
    80004bfa:	fffff097          	auipc	ra,0xfffff
    80004bfe:	0a2080e7          	jalr	162(ra) # 80003c9c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004c02:	854a                	mv	a0,s2
    80004c04:	70a2                	ld	ra,40(sp)
    80004c06:	7402                	ld	s0,32(sp)
    80004c08:	64e2                	ld	s1,24(sp)
    80004c0a:	6942                	ld	s2,16(sp)
    80004c0c:	69a2                	ld	s3,8(sp)
    80004c0e:	6145                	addi	sp,sp,48
    80004c10:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004c12:	6908                	ld	a0,16(a0)
    80004c14:	00000097          	auipc	ra,0x0
    80004c18:	3c6080e7          	jalr	966(ra) # 80004fda <piperead>
    80004c1c:	892a                	mv	s2,a0
    80004c1e:	b7d5                	j	80004c02 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004c20:	02451783          	lh	a5,36(a0)
    80004c24:	03079693          	slli	a3,a5,0x30
    80004c28:	92c1                	srli	a3,a3,0x30
    80004c2a:	4725                	li	a4,9
    80004c2c:	02d76863          	bltu	a4,a3,80004c5c <fileread+0xba>
    80004c30:	0792                	slli	a5,a5,0x4
    80004c32:	0001c717          	auipc	a4,0x1c
    80004c36:	7b670713          	addi	a4,a4,1974 # 800213e8 <devsw>
    80004c3a:	97ba                	add	a5,a5,a4
    80004c3c:	639c                	ld	a5,0(a5)
    80004c3e:	c38d                	beqz	a5,80004c60 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004c40:	4505                	li	a0,1
    80004c42:	9782                	jalr	a5
    80004c44:	892a                	mv	s2,a0
    80004c46:	bf75                	j	80004c02 <fileread+0x60>
    panic("fileread");
    80004c48:	00004517          	auipc	a0,0x4
    80004c4c:	a7850513          	addi	a0,a0,-1416 # 800086c0 <syscalls+0x270>
    80004c50:	ffffc097          	auipc	ra,0xffffc
    80004c54:	8ee080e7          	jalr	-1810(ra) # 8000053e <panic>
    return -1;
    80004c58:	597d                	li	s2,-1
    80004c5a:	b765                	j	80004c02 <fileread+0x60>
      return -1;
    80004c5c:	597d                	li	s2,-1
    80004c5e:	b755                	j	80004c02 <fileread+0x60>
    80004c60:	597d                	li	s2,-1
    80004c62:	b745                	j	80004c02 <fileread+0x60>

0000000080004c64 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004c64:	715d                	addi	sp,sp,-80
    80004c66:	e486                	sd	ra,72(sp)
    80004c68:	e0a2                	sd	s0,64(sp)
    80004c6a:	fc26                	sd	s1,56(sp)
    80004c6c:	f84a                	sd	s2,48(sp)
    80004c6e:	f44e                	sd	s3,40(sp)
    80004c70:	f052                	sd	s4,32(sp)
    80004c72:	ec56                	sd	s5,24(sp)
    80004c74:	e85a                	sd	s6,16(sp)
    80004c76:	e45e                	sd	s7,8(sp)
    80004c78:	e062                	sd	s8,0(sp)
    80004c7a:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c7c:	00954783          	lbu	a5,9(a0)
    80004c80:	10078663          	beqz	a5,80004d8c <filewrite+0x128>
    80004c84:	892a                	mv	s2,a0
    80004c86:	8aae                	mv	s5,a1
    80004c88:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c8a:	411c                	lw	a5,0(a0)
    80004c8c:	4705                	li	a4,1
    80004c8e:	02e78263          	beq	a5,a4,80004cb2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c92:	470d                	li	a4,3
    80004c94:	02e78663          	beq	a5,a4,80004cc0 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c98:	4709                	li	a4,2
    80004c9a:	0ee79163          	bne	a5,a4,80004d7c <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c9e:	0ac05d63          	blez	a2,80004d58 <filewrite+0xf4>
    int i = 0;
    80004ca2:	4981                	li	s3,0
    80004ca4:	6b05                	lui	s6,0x1
    80004ca6:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004caa:	6b85                	lui	s7,0x1
    80004cac:	c00b8b9b          	addiw	s7,s7,-1024
    80004cb0:	a861                	j	80004d48 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004cb2:	6908                	ld	a0,16(a0)
    80004cb4:	00000097          	auipc	ra,0x0
    80004cb8:	22e080e7          	jalr	558(ra) # 80004ee2 <pipewrite>
    80004cbc:	8a2a                	mv	s4,a0
    80004cbe:	a045                	j	80004d5e <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004cc0:	02451783          	lh	a5,36(a0)
    80004cc4:	03079693          	slli	a3,a5,0x30
    80004cc8:	92c1                	srli	a3,a3,0x30
    80004cca:	4725                	li	a4,9
    80004ccc:	0cd76263          	bltu	a4,a3,80004d90 <filewrite+0x12c>
    80004cd0:	0792                	slli	a5,a5,0x4
    80004cd2:	0001c717          	auipc	a4,0x1c
    80004cd6:	71670713          	addi	a4,a4,1814 # 800213e8 <devsw>
    80004cda:	97ba                	add	a5,a5,a4
    80004cdc:	679c                	ld	a5,8(a5)
    80004cde:	cbdd                	beqz	a5,80004d94 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004ce0:	4505                	li	a0,1
    80004ce2:	9782                	jalr	a5
    80004ce4:	8a2a                	mv	s4,a0
    80004ce6:	a8a5                	j	80004d5e <filewrite+0xfa>
    80004ce8:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004cec:	00000097          	auipc	ra,0x0
    80004cf0:	8b0080e7          	jalr	-1872(ra) # 8000459c <begin_op>
      ilock(f->ip);
    80004cf4:	01893503          	ld	a0,24(s2)
    80004cf8:	fffff097          	auipc	ra,0xfffff
    80004cfc:	ee2080e7          	jalr	-286(ra) # 80003bda <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004d00:	8762                	mv	a4,s8
    80004d02:	02092683          	lw	a3,32(s2)
    80004d06:	01598633          	add	a2,s3,s5
    80004d0a:	4585                	li	a1,1
    80004d0c:	01893503          	ld	a0,24(s2)
    80004d10:	fffff097          	auipc	ra,0xfffff
    80004d14:	276080e7          	jalr	630(ra) # 80003f86 <writei>
    80004d18:	84aa                	mv	s1,a0
    80004d1a:	00a05763          	blez	a0,80004d28 <filewrite+0xc4>
        f->off += r;
    80004d1e:	02092783          	lw	a5,32(s2)
    80004d22:	9fa9                	addw	a5,a5,a0
    80004d24:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004d28:	01893503          	ld	a0,24(s2)
    80004d2c:	fffff097          	auipc	ra,0xfffff
    80004d30:	f70080e7          	jalr	-144(ra) # 80003c9c <iunlock>
      end_op();
    80004d34:	00000097          	auipc	ra,0x0
    80004d38:	8e8080e7          	jalr	-1816(ra) # 8000461c <end_op>

      if(r != n1){
    80004d3c:	009c1f63          	bne	s8,s1,80004d5a <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004d40:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004d44:	0149db63          	bge	s3,s4,80004d5a <filewrite+0xf6>
      int n1 = n - i;
    80004d48:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004d4c:	84be                	mv	s1,a5
    80004d4e:	2781                	sext.w	a5,a5
    80004d50:	f8fb5ce3          	bge	s6,a5,80004ce8 <filewrite+0x84>
    80004d54:	84de                	mv	s1,s7
    80004d56:	bf49                	j	80004ce8 <filewrite+0x84>
    int i = 0;
    80004d58:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004d5a:	013a1f63          	bne	s4,s3,80004d78 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004d5e:	8552                	mv	a0,s4
    80004d60:	60a6                	ld	ra,72(sp)
    80004d62:	6406                	ld	s0,64(sp)
    80004d64:	74e2                	ld	s1,56(sp)
    80004d66:	7942                	ld	s2,48(sp)
    80004d68:	79a2                	ld	s3,40(sp)
    80004d6a:	7a02                	ld	s4,32(sp)
    80004d6c:	6ae2                	ld	s5,24(sp)
    80004d6e:	6b42                	ld	s6,16(sp)
    80004d70:	6ba2                	ld	s7,8(sp)
    80004d72:	6c02                	ld	s8,0(sp)
    80004d74:	6161                	addi	sp,sp,80
    80004d76:	8082                	ret
    ret = (i == n ? n : -1);
    80004d78:	5a7d                	li	s4,-1
    80004d7a:	b7d5                	j	80004d5e <filewrite+0xfa>
    panic("filewrite");
    80004d7c:	00004517          	auipc	a0,0x4
    80004d80:	95450513          	addi	a0,a0,-1708 # 800086d0 <syscalls+0x280>
    80004d84:	ffffb097          	auipc	ra,0xffffb
    80004d88:	7ba080e7          	jalr	1978(ra) # 8000053e <panic>
    return -1;
    80004d8c:	5a7d                	li	s4,-1
    80004d8e:	bfc1                	j	80004d5e <filewrite+0xfa>
      return -1;
    80004d90:	5a7d                	li	s4,-1
    80004d92:	b7f1                	j	80004d5e <filewrite+0xfa>
    80004d94:	5a7d                	li	s4,-1
    80004d96:	b7e1                	j	80004d5e <filewrite+0xfa>

0000000080004d98 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d98:	7179                	addi	sp,sp,-48
    80004d9a:	f406                	sd	ra,40(sp)
    80004d9c:	f022                	sd	s0,32(sp)
    80004d9e:	ec26                	sd	s1,24(sp)
    80004da0:	e84a                	sd	s2,16(sp)
    80004da2:	e44e                	sd	s3,8(sp)
    80004da4:	e052                	sd	s4,0(sp)
    80004da6:	1800                	addi	s0,sp,48
    80004da8:	84aa                	mv	s1,a0
    80004daa:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004dac:	0005b023          	sd	zero,0(a1)
    80004db0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004db4:	00000097          	auipc	ra,0x0
    80004db8:	bf8080e7          	jalr	-1032(ra) # 800049ac <filealloc>
    80004dbc:	e088                	sd	a0,0(s1)
    80004dbe:	c551                	beqz	a0,80004e4a <pipealloc+0xb2>
    80004dc0:	00000097          	auipc	ra,0x0
    80004dc4:	bec080e7          	jalr	-1044(ra) # 800049ac <filealloc>
    80004dc8:	00aa3023          	sd	a0,0(s4)
    80004dcc:	c92d                	beqz	a0,80004e3e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004dce:	ffffc097          	auipc	ra,0xffffc
    80004dd2:	d18080e7          	jalr	-744(ra) # 80000ae6 <kalloc>
    80004dd6:	892a                	mv	s2,a0
    80004dd8:	c125                	beqz	a0,80004e38 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004dda:	4985                	li	s3,1
    80004ddc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004de0:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004de4:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004de8:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004dec:	00004597          	auipc	a1,0x4
    80004df0:	8f458593          	addi	a1,a1,-1804 # 800086e0 <syscalls+0x290>
    80004df4:	ffffc097          	auipc	ra,0xffffc
    80004df8:	d52080e7          	jalr	-686(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004dfc:	609c                	ld	a5,0(s1)
    80004dfe:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004e02:	609c                	ld	a5,0(s1)
    80004e04:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004e08:	609c                	ld	a5,0(s1)
    80004e0a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004e0e:	609c                	ld	a5,0(s1)
    80004e10:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004e14:	000a3783          	ld	a5,0(s4)
    80004e18:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004e1c:	000a3783          	ld	a5,0(s4)
    80004e20:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004e24:	000a3783          	ld	a5,0(s4)
    80004e28:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004e2c:	000a3783          	ld	a5,0(s4)
    80004e30:	0127b823          	sd	s2,16(a5)
  return 0;
    80004e34:	4501                	li	a0,0
    80004e36:	a025                	j	80004e5e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004e38:	6088                	ld	a0,0(s1)
    80004e3a:	e501                	bnez	a0,80004e42 <pipealloc+0xaa>
    80004e3c:	a039                	j	80004e4a <pipealloc+0xb2>
    80004e3e:	6088                	ld	a0,0(s1)
    80004e40:	c51d                	beqz	a0,80004e6e <pipealloc+0xd6>
    fileclose(*f0);
    80004e42:	00000097          	auipc	ra,0x0
    80004e46:	c26080e7          	jalr	-986(ra) # 80004a68 <fileclose>
  if(*f1)
    80004e4a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004e4e:	557d                	li	a0,-1
  if(*f1)
    80004e50:	c799                	beqz	a5,80004e5e <pipealloc+0xc6>
    fileclose(*f1);
    80004e52:	853e                	mv	a0,a5
    80004e54:	00000097          	auipc	ra,0x0
    80004e58:	c14080e7          	jalr	-1004(ra) # 80004a68 <fileclose>
  return -1;
    80004e5c:	557d                	li	a0,-1
}
    80004e5e:	70a2                	ld	ra,40(sp)
    80004e60:	7402                	ld	s0,32(sp)
    80004e62:	64e2                	ld	s1,24(sp)
    80004e64:	6942                	ld	s2,16(sp)
    80004e66:	69a2                	ld	s3,8(sp)
    80004e68:	6a02                	ld	s4,0(sp)
    80004e6a:	6145                	addi	sp,sp,48
    80004e6c:	8082                	ret
  return -1;
    80004e6e:	557d                	li	a0,-1
    80004e70:	b7fd                	j	80004e5e <pipealloc+0xc6>

0000000080004e72 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e72:	1101                	addi	sp,sp,-32
    80004e74:	ec06                	sd	ra,24(sp)
    80004e76:	e822                	sd	s0,16(sp)
    80004e78:	e426                	sd	s1,8(sp)
    80004e7a:	e04a                	sd	s2,0(sp)
    80004e7c:	1000                	addi	s0,sp,32
    80004e7e:	84aa                	mv	s1,a0
    80004e80:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e82:	ffffc097          	auipc	ra,0xffffc
    80004e86:	d54080e7          	jalr	-684(ra) # 80000bd6 <acquire>
  if(writable){
    80004e8a:	02090d63          	beqz	s2,80004ec4 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e8e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e92:	21848513          	addi	a0,s1,536
    80004e96:	ffffd097          	auipc	ra,0xffffd
    80004e9a:	222080e7          	jalr	546(ra) # 800020b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e9e:	2204b783          	ld	a5,544(s1)
    80004ea2:	eb95                	bnez	a5,80004ed6 <pipeclose+0x64>
    release(&pi->lock);
    80004ea4:	8526                	mv	a0,s1
    80004ea6:	ffffc097          	auipc	ra,0xffffc
    80004eaa:	de4080e7          	jalr	-540(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004eae:	8526                	mv	a0,s1
    80004eb0:	ffffc097          	auipc	ra,0xffffc
    80004eb4:	b3a080e7          	jalr	-1222(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004eb8:	60e2                	ld	ra,24(sp)
    80004eba:	6442                	ld	s0,16(sp)
    80004ebc:	64a2                	ld	s1,8(sp)
    80004ebe:	6902                	ld	s2,0(sp)
    80004ec0:	6105                	addi	sp,sp,32
    80004ec2:	8082                	ret
    pi->readopen = 0;
    80004ec4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ec8:	21c48513          	addi	a0,s1,540
    80004ecc:	ffffd097          	auipc	ra,0xffffd
    80004ed0:	1ec080e7          	jalr	492(ra) # 800020b8 <wakeup>
    80004ed4:	b7e9                	j	80004e9e <pipeclose+0x2c>
    release(&pi->lock);
    80004ed6:	8526                	mv	a0,s1
    80004ed8:	ffffc097          	auipc	ra,0xffffc
    80004edc:	db2080e7          	jalr	-590(ra) # 80000c8a <release>
}
    80004ee0:	bfe1                	j	80004eb8 <pipeclose+0x46>

0000000080004ee2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ee2:	711d                	addi	sp,sp,-96
    80004ee4:	ec86                	sd	ra,88(sp)
    80004ee6:	e8a2                	sd	s0,80(sp)
    80004ee8:	e4a6                	sd	s1,72(sp)
    80004eea:	e0ca                	sd	s2,64(sp)
    80004eec:	fc4e                	sd	s3,56(sp)
    80004eee:	f852                	sd	s4,48(sp)
    80004ef0:	f456                	sd	s5,40(sp)
    80004ef2:	f05a                	sd	s6,32(sp)
    80004ef4:	ec5e                	sd	s7,24(sp)
    80004ef6:	e862                	sd	s8,16(sp)
    80004ef8:	1080                	addi	s0,sp,96
    80004efa:	84aa                	mv	s1,a0
    80004efc:	8aae                	mv	s5,a1
    80004efe:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004f00:	ffffd097          	auipc	ra,0xffffd
    80004f04:	aac080e7          	jalr	-1364(ra) # 800019ac <myproc>
    80004f08:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	cca080e7          	jalr	-822(ra) # 80000bd6 <acquire>
  while(i < n){
    80004f14:	0b405663          	blez	s4,80004fc0 <pipewrite+0xde>
  int i = 0;
    80004f18:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f1a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004f1c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004f20:	21c48b93          	addi	s7,s1,540
    80004f24:	a089                	j	80004f66 <pipewrite+0x84>
      release(&pi->lock);
    80004f26:	8526                	mv	a0,s1
    80004f28:	ffffc097          	auipc	ra,0xffffc
    80004f2c:	d62080e7          	jalr	-670(ra) # 80000c8a <release>
      return -1;
    80004f30:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004f32:	854a                	mv	a0,s2
    80004f34:	60e6                	ld	ra,88(sp)
    80004f36:	6446                	ld	s0,80(sp)
    80004f38:	64a6                	ld	s1,72(sp)
    80004f3a:	6906                	ld	s2,64(sp)
    80004f3c:	79e2                	ld	s3,56(sp)
    80004f3e:	7a42                	ld	s4,48(sp)
    80004f40:	7aa2                	ld	s5,40(sp)
    80004f42:	7b02                	ld	s6,32(sp)
    80004f44:	6be2                	ld	s7,24(sp)
    80004f46:	6c42                	ld	s8,16(sp)
    80004f48:	6125                	addi	sp,sp,96
    80004f4a:	8082                	ret
      wakeup(&pi->nread);
    80004f4c:	8562                	mv	a0,s8
    80004f4e:	ffffd097          	auipc	ra,0xffffd
    80004f52:	16a080e7          	jalr	362(ra) # 800020b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004f56:	85a6                	mv	a1,s1
    80004f58:	855e                	mv	a0,s7
    80004f5a:	ffffd097          	auipc	ra,0xffffd
    80004f5e:	0fa080e7          	jalr	250(ra) # 80002054 <sleep>
  while(i < n){
    80004f62:	07495063          	bge	s2,s4,80004fc2 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004f66:	2204a783          	lw	a5,544(s1)
    80004f6a:	dfd5                	beqz	a5,80004f26 <pipewrite+0x44>
    80004f6c:	854e                	mv	a0,s3
    80004f6e:	ffffd097          	auipc	ra,0xffffd
    80004f72:	3a4080e7          	jalr	932(ra) # 80002312 <killed>
    80004f76:	f945                	bnez	a0,80004f26 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f78:	2184a783          	lw	a5,536(s1)
    80004f7c:	21c4a703          	lw	a4,540(s1)
    80004f80:	2007879b          	addiw	a5,a5,512
    80004f84:	fcf704e3          	beq	a4,a5,80004f4c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f88:	4685                	li	a3,1
    80004f8a:	01590633          	add	a2,s2,s5
    80004f8e:	faf40593          	addi	a1,s0,-81
    80004f92:	0509b503          	ld	a0,80(s3)
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	75e080e7          	jalr	1886(ra) # 800016f4 <copyin>
    80004f9e:	03650263          	beq	a0,s6,80004fc2 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004fa2:	21c4a783          	lw	a5,540(s1)
    80004fa6:	0017871b          	addiw	a4,a5,1
    80004faa:	20e4ae23          	sw	a4,540(s1)
    80004fae:	1ff7f793          	andi	a5,a5,511
    80004fb2:	97a6                	add	a5,a5,s1
    80004fb4:	faf44703          	lbu	a4,-81(s0)
    80004fb8:	00e78c23          	sb	a4,24(a5)
      i++;
    80004fbc:	2905                	addiw	s2,s2,1
    80004fbe:	b755                	j	80004f62 <pipewrite+0x80>
  int i = 0;
    80004fc0:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004fc2:	21848513          	addi	a0,s1,536
    80004fc6:	ffffd097          	auipc	ra,0xffffd
    80004fca:	0f2080e7          	jalr	242(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004fce:	8526                	mv	a0,s1
    80004fd0:	ffffc097          	auipc	ra,0xffffc
    80004fd4:	cba080e7          	jalr	-838(ra) # 80000c8a <release>
  return i;
    80004fd8:	bfa9                	j	80004f32 <pipewrite+0x50>

0000000080004fda <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004fda:	715d                	addi	sp,sp,-80
    80004fdc:	e486                	sd	ra,72(sp)
    80004fde:	e0a2                	sd	s0,64(sp)
    80004fe0:	fc26                	sd	s1,56(sp)
    80004fe2:	f84a                	sd	s2,48(sp)
    80004fe4:	f44e                	sd	s3,40(sp)
    80004fe6:	f052                	sd	s4,32(sp)
    80004fe8:	ec56                	sd	s5,24(sp)
    80004fea:	e85a                	sd	s6,16(sp)
    80004fec:	0880                	addi	s0,sp,80
    80004fee:	84aa                	mv	s1,a0
    80004ff0:	892e                	mv	s2,a1
    80004ff2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	9b8080e7          	jalr	-1608(ra) # 800019ac <myproc>
    80004ffc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ffe:	8526                	mv	a0,s1
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	bd6080e7          	jalr	-1066(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005008:	2184a703          	lw	a4,536(s1)
    8000500c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005010:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005014:	02f71763          	bne	a4,a5,80005042 <piperead+0x68>
    80005018:	2244a783          	lw	a5,548(s1)
    8000501c:	c39d                	beqz	a5,80005042 <piperead+0x68>
    if(killed(pr)){
    8000501e:	8552                	mv	a0,s4
    80005020:	ffffd097          	auipc	ra,0xffffd
    80005024:	2f2080e7          	jalr	754(ra) # 80002312 <killed>
    80005028:	e941                	bnez	a0,800050b8 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000502a:	85a6                	mv	a1,s1
    8000502c:	854e                	mv	a0,s3
    8000502e:	ffffd097          	auipc	ra,0xffffd
    80005032:	026080e7          	jalr	38(ra) # 80002054 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005036:	2184a703          	lw	a4,536(s1)
    8000503a:	21c4a783          	lw	a5,540(s1)
    8000503e:	fcf70de3          	beq	a4,a5,80005018 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005042:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005044:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005046:	05505363          	blez	s5,8000508c <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    8000504a:	2184a783          	lw	a5,536(s1)
    8000504e:	21c4a703          	lw	a4,540(s1)
    80005052:	02f70d63          	beq	a4,a5,8000508c <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005056:	0017871b          	addiw	a4,a5,1
    8000505a:	20e4ac23          	sw	a4,536(s1)
    8000505e:	1ff7f793          	andi	a5,a5,511
    80005062:	97a6                	add	a5,a5,s1
    80005064:	0187c783          	lbu	a5,24(a5)
    80005068:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000506c:	4685                	li	a3,1
    8000506e:	fbf40613          	addi	a2,s0,-65
    80005072:	85ca                	mv	a1,s2
    80005074:	050a3503          	ld	a0,80(s4)
    80005078:	ffffc097          	auipc	ra,0xffffc
    8000507c:	5f0080e7          	jalr	1520(ra) # 80001668 <copyout>
    80005080:	01650663          	beq	a0,s6,8000508c <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005084:	2985                	addiw	s3,s3,1
    80005086:	0905                	addi	s2,s2,1
    80005088:	fd3a91e3          	bne	s5,s3,8000504a <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000508c:	21c48513          	addi	a0,s1,540
    80005090:	ffffd097          	auipc	ra,0xffffd
    80005094:	028080e7          	jalr	40(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80005098:	8526                	mv	a0,s1
    8000509a:	ffffc097          	auipc	ra,0xffffc
    8000509e:	bf0080e7          	jalr	-1040(ra) # 80000c8a <release>
  return i;
}
    800050a2:	854e                	mv	a0,s3
    800050a4:	60a6                	ld	ra,72(sp)
    800050a6:	6406                	ld	s0,64(sp)
    800050a8:	74e2                	ld	s1,56(sp)
    800050aa:	7942                	ld	s2,48(sp)
    800050ac:	79a2                	ld	s3,40(sp)
    800050ae:	7a02                	ld	s4,32(sp)
    800050b0:	6ae2                	ld	s5,24(sp)
    800050b2:	6b42                	ld	s6,16(sp)
    800050b4:	6161                	addi	sp,sp,80
    800050b6:	8082                	ret
      release(&pi->lock);
    800050b8:	8526                	mv	a0,s1
    800050ba:	ffffc097          	auipc	ra,0xffffc
    800050be:	bd0080e7          	jalr	-1072(ra) # 80000c8a <release>
      return -1;
    800050c2:	59fd                	li	s3,-1
    800050c4:	bff9                	j	800050a2 <piperead+0xc8>

00000000800050c6 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800050c6:	1141                	addi	sp,sp,-16
    800050c8:	e422                	sd	s0,8(sp)
    800050ca:	0800                	addi	s0,sp,16
    800050cc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800050ce:	8905                	andi	a0,a0,1
    800050d0:	c111                	beqz	a0,800050d4 <flags2perm+0xe>
      perm = PTE_X;
    800050d2:	4521                	li	a0,8
    if(flags & 0x2)
    800050d4:	8b89                	andi	a5,a5,2
    800050d6:	c399                	beqz	a5,800050dc <flags2perm+0x16>
      perm |= PTE_W;
    800050d8:	00456513          	ori	a0,a0,4
    return perm;
}
    800050dc:	6422                	ld	s0,8(sp)
    800050de:	0141                	addi	sp,sp,16
    800050e0:	8082                	ret

00000000800050e2 <exec>:

int
exec(char *path, char **argv)
{
    800050e2:	de010113          	addi	sp,sp,-544
    800050e6:	20113c23          	sd	ra,536(sp)
    800050ea:	20813823          	sd	s0,528(sp)
    800050ee:	20913423          	sd	s1,520(sp)
    800050f2:	21213023          	sd	s2,512(sp)
    800050f6:	ffce                	sd	s3,504(sp)
    800050f8:	fbd2                	sd	s4,496(sp)
    800050fa:	f7d6                	sd	s5,488(sp)
    800050fc:	f3da                	sd	s6,480(sp)
    800050fe:	efde                	sd	s7,472(sp)
    80005100:	ebe2                	sd	s8,464(sp)
    80005102:	e7e6                	sd	s9,456(sp)
    80005104:	e3ea                	sd	s10,448(sp)
    80005106:	ff6e                	sd	s11,440(sp)
    80005108:	1400                	addi	s0,sp,544
    8000510a:	892a                	mv	s2,a0
    8000510c:	dea43423          	sd	a0,-536(s0)
    80005110:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005114:	ffffd097          	auipc	ra,0xffffd
    80005118:	898080e7          	jalr	-1896(ra) # 800019ac <myproc>
    8000511c:	84aa                	mv	s1,a0

  begin_op();
    8000511e:	fffff097          	auipc	ra,0xfffff
    80005122:	47e080e7          	jalr	1150(ra) # 8000459c <begin_op>

  if((ip = namei(path)) == 0){
    80005126:	854a                	mv	a0,s2
    80005128:	fffff097          	auipc	ra,0xfffff
    8000512c:	258080e7          	jalr	600(ra) # 80004380 <namei>
    80005130:	c93d                	beqz	a0,800051a6 <exec+0xc4>
    80005132:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	aa6080e7          	jalr	-1370(ra) # 80003bda <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000513c:	04000713          	li	a4,64
    80005140:	4681                	li	a3,0
    80005142:	e5040613          	addi	a2,s0,-432
    80005146:	4581                	li	a1,0
    80005148:	8556                	mv	a0,s5
    8000514a:	fffff097          	auipc	ra,0xfffff
    8000514e:	d44080e7          	jalr	-700(ra) # 80003e8e <readi>
    80005152:	04000793          	li	a5,64
    80005156:	00f51a63          	bne	a0,a5,8000516a <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000515a:	e5042703          	lw	a4,-432(s0)
    8000515e:	464c47b7          	lui	a5,0x464c4
    80005162:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005166:	04f70663          	beq	a4,a5,800051b2 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000516a:	8556                	mv	a0,s5
    8000516c:	fffff097          	auipc	ra,0xfffff
    80005170:	cd0080e7          	jalr	-816(ra) # 80003e3c <iunlockput>
    end_op();
    80005174:	fffff097          	auipc	ra,0xfffff
    80005178:	4a8080e7          	jalr	1192(ra) # 8000461c <end_op>
  }
  return -1;
    8000517c:	557d                	li	a0,-1
}
    8000517e:	21813083          	ld	ra,536(sp)
    80005182:	21013403          	ld	s0,528(sp)
    80005186:	20813483          	ld	s1,520(sp)
    8000518a:	20013903          	ld	s2,512(sp)
    8000518e:	79fe                	ld	s3,504(sp)
    80005190:	7a5e                	ld	s4,496(sp)
    80005192:	7abe                	ld	s5,488(sp)
    80005194:	7b1e                	ld	s6,480(sp)
    80005196:	6bfe                	ld	s7,472(sp)
    80005198:	6c5e                	ld	s8,464(sp)
    8000519a:	6cbe                	ld	s9,456(sp)
    8000519c:	6d1e                	ld	s10,448(sp)
    8000519e:	7dfa                	ld	s11,440(sp)
    800051a0:	22010113          	addi	sp,sp,544
    800051a4:	8082                	ret
    end_op();
    800051a6:	fffff097          	auipc	ra,0xfffff
    800051aa:	476080e7          	jalr	1142(ra) # 8000461c <end_op>
    return -1;
    800051ae:	557d                	li	a0,-1
    800051b0:	b7f9                	j	8000517e <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    800051b2:	8526                	mv	a0,s1
    800051b4:	ffffd097          	auipc	ra,0xffffd
    800051b8:	8bc080e7          	jalr	-1860(ra) # 80001a70 <proc_pagetable>
    800051bc:	8b2a                	mv	s6,a0
    800051be:	d555                	beqz	a0,8000516a <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051c0:	e7042783          	lw	a5,-400(s0)
    800051c4:	e8845703          	lhu	a4,-376(s0)
    800051c8:	c735                	beqz	a4,80005234 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051ca:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051cc:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    800051d0:	6a05                	lui	s4,0x1
    800051d2:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800051d6:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800051da:	6d85                	lui	s11,0x1
    800051dc:	7d7d                	lui	s10,0xfffff
    800051de:	a481                	j	8000541e <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800051e0:	00003517          	auipc	a0,0x3
    800051e4:	50850513          	addi	a0,a0,1288 # 800086e8 <syscalls+0x298>
    800051e8:	ffffb097          	auipc	ra,0xffffb
    800051ec:	356080e7          	jalr	854(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800051f0:	874a                	mv	a4,s2
    800051f2:	009c86bb          	addw	a3,s9,s1
    800051f6:	4581                	li	a1,0
    800051f8:	8556                	mv	a0,s5
    800051fa:	fffff097          	auipc	ra,0xfffff
    800051fe:	c94080e7          	jalr	-876(ra) # 80003e8e <readi>
    80005202:	2501                	sext.w	a0,a0
    80005204:	1aa91a63          	bne	s2,a0,800053b8 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80005208:	009d84bb          	addw	s1,s11,s1
    8000520c:	013d09bb          	addw	s3,s10,s3
    80005210:	1f74f763          	bgeu	s1,s7,800053fe <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80005214:	02049593          	slli	a1,s1,0x20
    80005218:	9181                	srli	a1,a1,0x20
    8000521a:	95e2                	add	a1,a1,s8
    8000521c:	855a                	mv	a0,s6
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	e3e080e7          	jalr	-450(ra) # 8000105c <walkaddr>
    80005226:	862a                	mv	a2,a0
    if(pa == 0)
    80005228:	dd45                	beqz	a0,800051e0 <exec+0xfe>
      n = PGSIZE;
    8000522a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000522c:	fd49f2e3          	bgeu	s3,s4,800051f0 <exec+0x10e>
      n = sz - i;
    80005230:	894e                	mv	s2,s3
    80005232:	bf7d                	j	800051f0 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005234:	4901                	li	s2,0
  iunlockput(ip);
    80005236:	8556                	mv	a0,s5
    80005238:	fffff097          	auipc	ra,0xfffff
    8000523c:	c04080e7          	jalr	-1020(ra) # 80003e3c <iunlockput>
  end_op();
    80005240:	fffff097          	auipc	ra,0xfffff
    80005244:	3dc080e7          	jalr	988(ra) # 8000461c <end_op>
  p = myproc();
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	764080e7          	jalr	1892(ra) # 800019ac <myproc>
    80005250:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80005252:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005256:	6785                	lui	a5,0x1
    80005258:	17fd                	addi	a5,a5,-1
    8000525a:	993e                	add	s2,s2,a5
    8000525c:	77fd                	lui	a5,0xfffff
    8000525e:	00f977b3          	and	a5,s2,a5
    80005262:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005266:	4691                	li	a3,4
    80005268:	6609                	lui	a2,0x2
    8000526a:	963e                	add	a2,a2,a5
    8000526c:	85be                	mv	a1,a5
    8000526e:	855a                	mv	a0,s6
    80005270:	ffffc097          	auipc	ra,0xffffc
    80005274:	1a0080e7          	jalr	416(ra) # 80001410 <uvmalloc>
    80005278:	8c2a                	mv	s8,a0
  ip = 0;
    8000527a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    8000527c:	12050e63          	beqz	a0,800053b8 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005280:	75f9                	lui	a1,0xffffe
    80005282:	95aa                	add	a1,a1,a0
    80005284:	855a                	mv	a0,s6
    80005286:	ffffc097          	auipc	ra,0xffffc
    8000528a:	3b0080e7          	jalr	944(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    8000528e:	7afd                	lui	s5,0xfffff
    80005290:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005292:	df043783          	ld	a5,-528(s0)
    80005296:	6388                	ld	a0,0(a5)
    80005298:	c925                	beqz	a0,80005308 <exec+0x226>
    8000529a:	e9040993          	addi	s3,s0,-368
    8000529e:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800052a2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800052a4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052a6:	ffffc097          	auipc	ra,0xffffc
    800052aa:	ba8080e7          	jalr	-1112(ra) # 80000e4e <strlen>
    800052ae:	0015079b          	addiw	a5,a0,1
    800052b2:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052b6:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    800052ba:	13596663          	bltu	s2,s5,800053e6 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052be:	df043d83          	ld	s11,-528(s0)
    800052c2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    800052c6:	8552                	mv	a0,s4
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	b86080e7          	jalr	-1146(ra) # 80000e4e <strlen>
    800052d0:	0015069b          	addiw	a3,a0,1
    800052d4:	8652                	mv	a2,s4
    800052d6:	85ca                	mv	a1,s2
    800052d8:	855a                	mv	a0,s6
    800052da:	ffffc097          	auipc	ra,0xffffc
    800052de:	38e080e7          	jalr	910(ra) # 80001668 <copyout>
    800052e2:	10054663          	bltz	a0,800053ee <exec+0x30c>
    ustack[argc] = sp;
    800052e6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800052ea:	0485                	addi	s1,s1,1
    800052ec:	008d8793          	addi	a5,s11,8
    800052f0:	def43823          	sd	a5,-528(s0)
    800052f4:	008db503          	ld	a0,8(s11)
    800052f8:	c911                	beqz	a0,8000530c <exec+0x22a>
    if(argc >= MAXARG)
    800052fa:	09a1                	addi	s3,s3,8
    800052fc:	fb3c95e3          	bne	s9,s3,800052a6 <exec+0x1c4>
  sz = sz1;
    80005300:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005304:	4a81                	li	s5,0
    80005306:	a84d                	j	800053b8 <exec+0x2d6>
  sp = sz;
    80005308:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000530a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000530c:	00349793          	slli	a5,s1,0x3
    80005310:	f9040713          	addi	a4,s0,-112
    80005314:	97ba                	add	a5,a5,a4
    80005316:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdc980>
  sp -= (argc+1) * sizeof(uint64);
    8000531a:	00148693          	addi	a3,s1,1
    8000531e:	068e                	slli	a3,a3,0x3
    80005320:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005324:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005328:	01597663          	bgeu	s2,s5,80005334 <exec+0x252>
  sz = sz1;
    8000532c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005330:	4a81                	li	s5,0
    80005332:	a059                	j	800053b8 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005334:	e9040613          	addi	a2,s0,-368
    80005338:	85ca                	mv	a1,s2
    8000533a:	855a                	mv	a0,s6
    8000533c:	ffffc097          	auipc	ra,0xffffc
    80005340:	32c080e7          	jalr	812(ra) # 80001668 <copyout>
    80005344:	0a054963          	bltz	a0,800053f6 <exec+0x314>
  p->trapframe->a1 = sp;
    80005348:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    8000534c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005350:	de843783          	ld	a5,-536(s0)
    80005354:	0007c703          	lbu	a4,0(a5)
    80005358:	cf11                	beqz	a4,80005374 <exec+0x292>
    8000535a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000535c:	02f00693          	li	a3,47
    80005360:	a039                	j	8000536e <exec+0x28c>
      last = s+1;
    80005362:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005366:	0785                	addi	a5,a5,1
    80005368:	fff7c703          	lbu	a4,-1(a5)
    8000536c:	c701                	beqz	a4,80005374 <exec+0x292>
    if(*s == '/')
    8000536e:	fed71ce3          	bne	a4,a3,80005366 <exec+0x284>
    80005372:	bfc5                	j	80005362 <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80005374:	4641                	li	a2,16
    80005376:	de843583          	ld	a1,-536(s0)
    8000537a:	158b8513          	addi	a0,s7,344
    8000537e:	ffffc097          	auipc	ra,0xffffc
    80005382:	a9e080e7          	jalr	-1378(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005386:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000538a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000538e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005392:	058bb783          	ld	a5,88(s7)
    80005396:	e6843703          	ld	a4,-408(s0)
    8000539a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000539c:	058bb783          	ld	a5,88(s7)
    800053a0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053a4:	85ea                	mv	a1,s10
    800053a6:	ffffc097          	auipc	ra,0xffffc
    800053aa:	766080e7          	jalr	1894(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053ae:	0004851b          	sext.w	a0,s1
    800053b2:	b3f1                	j	8000517e <exec+0x9c>
    800053b4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800053b8:	df843583          	ld	a1,-520(s0)
    800053bc:	855a                	mv	a0,s6
    800053be:	ffffc097          	auipc	ra,0xffffc
    800053c2:	74e080e7          	jalr	1870(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    800053c6:	da0a92e3          	bnez	s5,8000516a <exec+0x88>
  return -1;
    800053ca:	557d                	li	a0,-1
    800053cc:	bb4d                	j	8000517e <exec+0x9c>
    800053ce:	df243c23          	sd	s2,-520(s0)
    800053d2:	b7dd                	j	800053b8 <exec+0x2d6>
    800053d4:	df243c23          	sd	s2,-520(s0)
    800053d8:	b7c5                	j	800053b8 <exec+0x2d6>
    800053da:	df243c23          	sd	s2,-520(s0)
    800053de:	bfe9                	j	800053b8 <exec+0x2d6>
    800053e0:	df243c23          	sd	s2,-520(s0)
    800053e4:	bfd1                	j	800053b8 <exec+0x2d6>
  sz = sz1;
    800053e6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053ea:	4a81                	li	s5,0
    800053ec:	b7f1                	j	800053b8 <exec+0x2d6>
  sz = sz1;
    800053ee:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053f2:	4a81                	li	s5,0
    800053f4:	b7d1                	j	800053b8 <exec+0x2d6>
  sz = sz1;
    800053f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800053fa:	4a81                	li	s5,0
    800053fc:	bf75                	j	800053b8 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053fe:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005402:	e0843783          	ld	a5,-504(s0)
    80005406:	0017869b          	addiw	a3,a5,1
    8000540a:	e0d43423          	sd	a3,-504(s0)
    8000540e:	e0043783          	ld	a5,-512(s0)
    80005412:	0387879b          	addiw	a5,a5,56
    80005416:	e8845703          	lhu	a4,-376(s0)
    8000541a:	e0e6dee3          	bge	a3,a4,80005236 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000541e:	2781                	sext.w	a5,a5
    80005420:	e0f43023          	sd	a5,-512(s0)
    80005424:	03800713          	li	a4,56
    80005428:	86be                	mv	a3,a5
    8000542a:	e1840613          	addi	a2,s0,-488
    8000542e:	4581                	li	a1,0
    80005430:	8556                	mv	a0,s5
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	a5c080e7          	jalr	-1444(ra) # 80003e8e <readi>
    8000543a:	03800793          	li	a5,56
    8000543e:	f6f51be3          	bne	a0,a5,800053b4 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80005442:	e1842783          	lw	a5,-488(s0)
    80005446:	4705                	li	a4,1
    80005448:	fae79de3          	bne	a5,a4,80005402 <exec+0x320>
    if(ph.memsz < ph.filesz)
    8000544c:	e4043483          	ld	s1,-448(s0)
    80005450:	e3843783          	ld	a5,-456(s0)
    80005454:	f6f4ede3          	bltu	s1,a5,800053ce <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005458:	e2843783          	ld	a5,-472(s0)
    8000545c:	94be                	add	s1,s1,a5
    8000545e:	f6f4ebe3          	bltu	s1,a5,800053d4 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80005462:	de043703          	ld	a4,-544(s0)
    80005466:	8ff9                	and	a5,a5,a4
    80005468:	fbad                	bnez	a5,800053da <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000546a:	e1c42503          	lw	a0,-484(s0)
    8000546e:	00000097          	auipc	ra,0x0
    80005472:	c58080e7          	jalr	-936(ra) # 800050c6 <flags2perm>
    80005476:	86aa                	mv	a3,a0
    80005478:	8626                	mv	a2,s1
    8000547a:	85ca                	mv	a1,s2
    8000547c:	855a                	mv	a0,s6
    8000547e:	ffffc097          	auipc	ra,0xffffc
    80005482:	f92080e7          	jalr	-110(ra) # 80001410 <uvmalloc>
    80005486:	dea43c23          	sd	a0,-520(s0)
    8000548a:	d939                	beqz	a0,800053e0 <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000548c:	e2843c03          	ld	s8,-472(s0)
    80005490:	e2042c83          	lw	s9,-480(s0)
    80005494:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005498:	f60b83e3          	beqz	s7,800053fe <exec+0x31c>
    8000549c:	89de                	mv	s3,s7
    8000549e:	4481                	li	s1,0
    800054a0:	bb95                	j	80005214 <exec+0x132>

00000000800054a2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800054a2:	7179                	addi	sp,sp,-48
    800054a4:	f406                	sd	ra,40(sp)
    800054a6:	f022                	sd	s0,32(sp)
    800054a8:	ec26                	sd	s1,24(sp)
    800054aa:	e84a                	sd	s2,16(sp)
    800054ac:	1800                	addi	s0,sp,48
    800054ae:	892e                	mv	s2,a1
    800054b0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800054b2:	fdc40593          	addi	a1,s0,-36
    800054b6:	ffffe097          	auipc	ra,0xffffe
    800054ba:	ade080e7          	jalr	-1314(ra) # 80002f94 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800054be:	fdc42703          	lw	a4,-36(s0)
    800054c2:	47bd                	li	a5,15
    800054c4:	02e7eb63          	bltu	a5,a4,800054fa <argfd+0x58>
    800054c8:	ffffc097          	auipc	ra,0xffffc
    800054cc:	4e4080e7          	jalr	1252(ra) # 800019ac <myproc>
    800054d0:	fdc42703          	lw	a4,-36(s0)
    800054d4:	01a70793          	addi	a5,a4,26
    800054d8:	078e                	slli	a5,a5,0x3
    800054da:	953e                	add	a0,a0,a5
    800054dc:	611c                	ld	a5,0(a0)
    800054de:	c385                	beqz	a5,800054fe <argfd+0x5c>
    return -1;
  if(pfd)
    800054e0:	00090463          	beqz	s2,800054e8 <argfd+0x46>
    *pfd = fd;
    800054e4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800054e8:	4501                	li	a0,0
  if(pf)
    800054ea:	c091                	beqz	s1,800054ee <argfd+0x4c>
    *pf = f;
    800054ec:	e09c                	sd	a5,0(s1)
}
    800054ee:	70a2                	ld	ra,40(sp)
    800054f0:	7402                	ld	s0,32(sp)
    800054f2:	64e2                	ld	s1,24(sp)
    800054f4:	6942                	ld	s2,16(sp)
    800054f6:	6145                	addi	sp,sp,48
    800054f8:	8082                	ret
    return -1;
    800054fa:	557d                	li	a0,-1
    800054fc:	bfcd                	j	800054ee <argfd+0x4c>
    800054fe:	557d                	li	a0,-1
    80005500:	b7fd                	j	800054ee <argfd+0x4c>

0000000080005502 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005502:	1101                	addi	sp,sp,-32
    80005504:	ec06                	sd	ra,24(sp)
    80005506:	e822                	sd	s0,16(sp)
    80005508:	e426                	sd	s1,8(sp)
    8000550a:	1000                	addi	s0,sp,32
    8000550c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000550e:	ffffc097          	auipc	ra,0xffffc
    80005512:	49e080e7          	jalr	1182(ra) # 800019ac <myproc>
    80005516:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005518:	0d050793          	addi	a5,a0,208
    8000551c:	4501                	li	a0,0
    8000551e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005520:	6398                	ld	a4,0(a5)
    80005522:	cb19                	beqz	a4,80005538 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005524:	2505                	addiw	a0,a0,1
    80005526:	07a1                	addi	a5,a5,8
    80005528:	fed51ce3          	bne	a0,a3,80005520 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000552c:	557d                	li	a0,-1
}
    8000552e:	60e2                	ld	ra,24(sp)
    80005530:	6442                	ld	s0,16(sp)
    80005532:	64a2                	ld	s1,8(sp)
    80005534:	6105                	addi	sp,sp,32
    80005536:	8082                	ret
      p->ofile[fd] = f;
    80005538:	01a50793          	addi	a5,a0,26
    8000553c:	078e                	slli	a5,a5,0x3
    8000553e:	963e                	add	a2,a2,a5
    80005540:	e204                	sd	s1,0(a2)
      return fd;
    80005542:	b7f5                	j	8000552e <fdalloc+0x2c>

0000000080005544 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005544:	715d                	addi	sp,sp,-80
    80005546:	e486                	sd	ra,72(sp)
    80005548:	e0a2                	sd	s0,64(sp)
    8000554a:	fc26                	sd	s1,56(sp)
    8000554c:	f84a                	sd	s2,48(sp)
    8000554e:	f44e                	sd	s3,40(sp)
    80005550:	f052                	sd	s4,32(sp)
    80005552:	ec56                	sd	s5,24(sp)
    80005554:	e85a                	sd	s6,16(sp)
    80005556:	0880                	addi	s0,sp,80
    80005558:	8b2e                	mv	s6,a1
    8000555a:	89b2                	mv	s3,a2
    8000555c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000555e:	fb040593          	addi	a1,s0,-80
    80005562:	fffff097          	auipc	ra,0xfffff
    80005566:	e3c080e7          	jalr	-452(ra) # 8000439e <nameiparent>
    8000556a:	84aa                	mv	s1,a0
    8000556c:	14050f63          	beqz	a0,800056ca <create+0x186>
    return 0;

  ilock(dp);
    80005570:	ffffe097          	auipc	ra,0xffffe
    80005574:	66a080e7          	jalr	1642(ra) # 80003bda <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005578:	4601                	li	a2,0
    8000557a:	fb040593          	addi	a1,s0,-80
    8000557e:	8526                	mv	a0,s1
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	b3e080e7          	jalr	-1218(ra) # 800040be <dirlookup>
    80005588:	8aaa                	mv	s5,a0
    8000558a:	c931                	beqz	a0,800055de <create+0x9a>
    iunlockput(dp);
    8000558c:	8526                	mv	a0,s1
    8000558e:	fffff097          	auipc	ra,0xfffff
    80005592:	8ae080e7          	jalr	-1874(ra) # 80003e3c <iunlockput>
    ilock(ip);
    80005596:	8556                	mv	a0,s5
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	642080e7          	jalr	1602(ra) # 80003bda <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800055a0:	000b059b          	sext.w	a1,s6
    800055a4:	4789                	li	a5,2
    800055a6:	02f59563          	bne	a1,a5,800055d0 <create+0x8c>
    800055aa:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcac4>
    800055ae:	37f9                	addiw	a5,a5,-2
    800055b0:	17c2                	slli	a5,a5,0x30
    800055b2:	93c1                	srli	a5,a5,0x30
    800055b4:	4705                	li	a4,1
    800055b6:	00f76d63          	bltu	a4,a5,800055d0 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800055ba:	8556                	mv	a0,s5
    800055bc:	60a6                	ld	ra,72(sp)
    800055be:	6406                	ld	s0,64(sp)
    800055c0:	74e2                	ld	s1,56(sp)
    800055c2:	7942                	ld	s2,48(sp)
    800055c4:	79a2                	ld	s3,40(sp)
    800055c6:	7a02                	ld	s4,32(sp)
    800055c8:	6ae2                	ld	s5,24(sp)
    800055ca:	6b42                	ld	s6,16(sp)
    800055cc:	6161                	addi	sp,sp,80
    800055ce:	8082                	ret
    iunlockput(ip);
    800055d0:	8556                	mv	a0,s5
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	86a080e7          	jalr	-1942(ra) # 80003e3c <iunlockput>
    return 0;
    800055da:	4a81                	li	s5,0
    800055dc:	bff9                	j	800055ba <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800055de:	85da                	mv	a1,s6
    800055e0:	4088                	lw	a0,0(s1)
    800055e2:	ffffe097          	auipc	ra,0xffffe
    800055e6:	45c080e7          	jalr	1116(ra) # 80003a3e <ialloc>
    800055ea:	8a2a                	mv	s4,a0
    800055ec:	c539                	beqz	a0,8000563a <create+0xf6>
  ilock(ip);
    800055ee:	ffffe097          	auipc	ra,0xffffe
    800055f2:	5ec080e7          	jalr	1516(ra) # 80003bda <ilock>
  ip->major = major;
    800055f6:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800055fa:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800055fe:	4905                	li	s2,1
    80005600:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005604:	8552                	mv	a0,s4
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	50a080e7          	jalr	1290(ra) # 80003b10 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000560e:	000b059b          	sext.w	a1,s6
    80005612:	03258b63          	beq	a1,s2,80005648 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005616:	004a2603          	lw	a2,4(s4)
    8000561a:	fb040593          	addi	a1,s0,-80
    8000561e:	8526                	mv	a0,s1
    80005620:	fffff097          	auipc	ra,0xfffff
    80005624:	cae080e7          	jalr	-850(ra) # 800042ce <dirlink>
    80005628:	06054f63          	bltz	a0,800056a6 <create+0x162>
  iunlockput(dp);
    8000562c:	8526                	mv	a0,s1
    8000562e:	fffff097          	auipc	ra,0xfffff
    80005632:	80e080e7          	jalr	-2034(ra) # 80003e3c <iunlockput>
  return ip;
    80005636:	8ad2                	mv	s5,s4
    80005638:	b749                	j	800055ba <create+0x76>
    iunlockput(dp);
    8000563a:	8526                	mv	a0,s1
    8000563c:	fffff097          	auipc	ra,0xfffff
    80005640:	800080e7          	jalr	-2048(ra) # 80003e3c <iunlockput>
    return 0;
    80005644:	8ad2                	mv	s5,s4
    80005646:	bf95                	j	800055ba <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005648:	004a2603          	lw	a2,4(s4)
    8000564c:	00003597          	auipc	a1,0x3
    80005650:	0bc58593          	addi	a1,a1,188 # 80008708 <syscalls+0x2b8>
    80005654:	8552                	mv	a0,s4
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	c78080e7          	jalr	-904(ra) # 800042ce <dirlink>
    8000565e:	04054463          	bltz	a0,800056a6 <create+0x162>
    80005662:	40d0                	lw	a2,4(s1)
    80005664:	00003597          	auipc	a1,0x3
    80005668:	0ac58593          	addi	a1,a1,172 # 80008710 <syscalls+0x2c0>
    8000566c:	8552                	mv	a0,s4
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	c60080e7          	jalr	-928(ra) # 800042ce <dirlink>
    80005676:	02054863          	bltz	a0,800056a6 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000567a:	004a2603          	lw	a2,4(s4)
    8000567e:	fb040593          	addi	a1,s0,-80
    80005682:	8526                	mv	a0,s1
    80005684:	fffff097          	auipc	ra,0xfffff
    80005688:	c4a080e7          	jalr	-950(ra) # 800042ce <dirlink>
    8000568c:	00054d63          	bltz	a0,800056a6 <create+0x162>
    dp->nlink++;  // for ".."
    80005690:	04a4d783          	lhu	a5,74(s1)
    80005694:	2785                	addiw	a5,a5,1
    80005696:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000569a:	8526                	mv	a0,s1
    8000569c:	ffffe097          	auipc	ra,0xffffe
    800056a0:	474080e7          	jalr	1140(ra) # 80003b10 <iupdate>
    800056a4:	b761                	j	8000562c <create+0xe8>
  ip->nlink = 0;
    800056a6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800056aa:	8552                	mv	a0,s4
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	464080e7          	jalr	1124(ra) # 80003b10 <iupdate>
  iunlockput(ip);
    800056b4:	8552                	mv	a0,s4
    800056b6:	ffffe097          	auipc	ra,0xffffe
    800056ba:	786080e7          	jalr	1926(ra) # 80003e3c <iunlockput>
  iunlockput(dp);
    800056be:	8526                	mv	a0,s1
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	77c080e7          	jalr	1916(ra) # 80003e3c <iunlockput>
  return 0;
    800056c8:	bdcd                	j	800055ba <create+0x76>
    return 0;
    800056ca:	8aaa                	mv	s5,a0
    800056cc:	b5fd                	j	800055ba <create+0x76>

00000000800056ce <sys_dup>:
{
    800056ce:	7179                	addi	sp,sp,-48
    800056d0:	f406                	sd	ra,40(sp)
    800056d2:	f022                	sd	s0,32(sp)
    800056d4:	ec26                	sd	s1,24(sp)
    800056d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800056d8:	fd840613          	addi	a2,s0,-40
    800056dc:	4581                	li	a1,0
    800056de:	4501                	li	a0,0
    800056e0:	00000097          	auipc	ra,0x0
    800056e4:	dc2080e7          	jalr	-574(ra) # 800054a2 <argfd>
    return -1;
    800056e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800056ea:	02054363          	bltz	a0,80005710 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800056ee:	fd843503          	ld	a0,-40(s0)
    800056f2:	00000097          	auipc	ra,0x0
    800056f6:	e10080e7          	jalr	-496(ra) # 80005502 <fdalloc>
    800056fa:	84aa                	mv	s1,a0
    return -1;
    800056fc:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800056fe:	00054963          	bltz	a0,80005710 <sys_dup+0x42>
  filedup(f);
    80005702:	fd843503          	ld	a0,-40(s0)
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	310080e7          	jalr	784(ra) # 80004a16 <filedup>
  return fd;
    8000570e:	87a6                	mv	a5,s1
}
    80005710:	853e                	mv	a0,a5
    80005712:	70a2                	ld	ra,40(sp)
    80005714:	7402                	ld	s0,32(sp)
    80005716:	64e2                	ld	s1,24(sp)
    80005718:	6145                	addi	sp,sp,48
    8000571a:	8082                	ret

000000008000571c <sys_read>:
{
    8000571c:	7179                	addi	sp,sp,-48
    8000571e:	f406                	sd	ra,40(sp)
    80005720:	f022                	sd	s0,32(sp)
    80005722:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005724:	fd840593          	addi	a1,s0,-40
    80005728:	4505                	li	a0,1
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	88a080e7          	jalr	-1910(ra) # 80002fb4 <argaddr>
  argint(2, &n);
    80005732:	fe440593          	addi	a1,s0,-28
    80005736:	4509                	li	a0,2
    80005738:	ffffe097          	auipc	ra,0xffffe
    8000573c:	85c080e7          	jalr	-1956(ra) # 80002f94 <argint>
  if(argfd(0, 0, &f) < 0)
    80005740:	fe840613          	addi	a2,s0,-24
    80005744:	4581                	li	a1,0
    80005746:	4501                	li	a0,0
    80005748:	00000097          	auipc	ra,0x0
    8000574c:	d5a080e7          	jalr	-678(ra) # 800054a2 <argfd>
    80005750:	87aa                	mv	a5,a0
    return -1;
    80005752:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005754:	0007cc63          	bltz	a5,8000576c <sys_read+0x50>
  return fileread(f, p, n);
    80005758:	fe442603          	lw	a2,-28(s0)
    8000575c:	fd843583          	ld	a1,-40(s0)
    80005760:	fe843503          	ld	a0,-24(s0)
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	43e080e7          	jalr	1086(ra) # 80004ba2 <fileread>
}
    8000576c:	70a2                	ld	ra,40(sp)
    8000576e:	7402                	ld	s0,32(sp)
    80005770:	6145                	addi	sp,sp,48
    80005772:	8082                	ret

0000000080005774 <sys_write>:
{
    80005774:	7179                	addi	sp,sp,-48
    80005776:	f406                	sd	ra,40(sp)
    80005778:	f022                	sd	s0,32(sp)
    8000577a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000577c:	fd840593          	addi	a1,s0,-40
    80005780:	4505                	li	a0,1
    80005782:	ffffe097          	auipc	ra,0xffffe
    80005786:	832080e7          	jalr	-1998(ra) # 80002fb4 <argaddr>
  argint(2, &n);
    8000578a:	fe440593          	addi	a1,s0,-28
    8000578e:	4509                	li	a0,2
    80005790:	ffffe097          	auipc	ra,0xffffe
    80005794:	804080e7          	jalr	-2044(ra) # 80002f94 <argint>
  if(argfd(0, 0, &f) < 0)
    80005798:	fe840613          	addi	a2,s0,-24
    8000579c:	4581                	li	a1,0
    8000579e:	4501                	li	a0,0
    800057a0:	00000097          	auipc	ra,0x0
    800057a4:	d02080e7          	jalr	-766(ra) # 800054a2 <argfd>
    800057a8:	87aa                	mv	a5,a0
    return -1;
    800057aa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057ac:	0007cc63          	bltz	a5,800057c4 <sys_write+0x50>
  return filewrite(f, p, n);
    800057b0:	fe442603          	lw	a2,-28(s0)
    800057b4:	fd843583          	ld	a1,-40(s0)
    800057b8:	fe843503          	ld	a0,-24(s0)
    800057bc:	fffff097          	auipc	ra,0xfffff
    800057c0:	4a8080e7          	jalr	1192(ra) # 80004c64 <filewrite>
}
    800057c4:	70a2                	ld	ra,40(sp)
    800057c6:	7402                	ld	s0,32(sp)
    800057c8:	6145                	addi	sp,sp,48
    800057ca:	8082                	ret

00000000800057cc <sys_close>:
{
    800057cc:	1101                	addi	sp,sp,-32
    800057ce:	ec06                	sd	ra,24(sp)
    800057d0:	e822                	sd	s0,16(sp)
    800057d2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800057d4:	fe040613          	addi	a2,s0,-32
    800057d8:	fec40593          	addi	a1,s0,-20
    800057dc:	4501                	li	a0,0
    800057de:	00000097          	auipc	ra,0x0
    800057e2:	cc4080e7          	jalr	-828(ra) # 800054a2 <argfd>
    return -1;
    800057e6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800057e8:	02054463          	bltz	a0,80005810 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800057ec:	ffffc097          	auipc	ra,0xffffc
    800057f0:	1c0080e7          	jalr	448(ra) # 800019ac <myproc>
    800057f4:	fec42783          	lw	a5,-20(s0)
    800057f8:	07e9                	addi	a5,a5,26
    800057fa:	078e                	slli	a5,a5,0x3
    800057fc:	97aa                	add	a5,a5,a0
    800057fe:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005802:	fe043503          	ld	a0,-32(s0)
    80005806:	fffff097          	auipc	ra,0xfffff
    8000580a:	262080e7          	jalr	610(ra) # 80004a68 <fileclose>
  return 0;
    8000580e:	4781                	li	a5,0
}
    80005810:	853e                	mv	a0,a5
    80005812:	60e2                	ld	ra,24(sp)
    80005814:	6442                	ld	s0,16(sp)
    80005816:	6105                	addi	sp,sp,32
    80005818:	8082                	ret

000000008000581a <sys_fstat>:
{
    8000581a:	1101                	addi	sp,sp,-32
    8000581c:	ec06                	sd	ra,24(sp)
    8000581e:	e822                	sd	s0,16(sp)
    80005820:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005822:	fe040593          	addi	a1,s0,-32
    80005826:	4505                	li	a0,1
    80005828:	ffffd097          	auipc	ra,0xffffd
    8000582c:	78c080e7          	jalr	1932(ra) # 80002fb4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005830:	fe840613          	addi	a2,s0,-24
    80005834:	4581                	li	a1,0
    80005836:	4501                	li	a0,0
    80005838:	00000097          	auipc	ra,0x0
    8000583c:	c6a080e7          	jalr	-918(ra) # 800054a2 <argfd>
    80005840:	87aa                	mv	a5,a0
    return -1;
    80005842:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005844:	0007ca63          	bltz	a5,80005858 <sys_fstat+0x3e>
  return filestat(f, st);
    80005848:	fe043583          	ld	a1,-32(s0)
    8000584c:	fe843503          	ld	a0,-24(s0)
    80005850:	fffff097          	auipc	ra,0xfffff
    80005854:	2e0080e7          	jalr	736(ra) # 80004b30 <filestat>
}
    80005858:	60e2                	ld	ra,24(sp)
    8000585a:	6442                	ld	s0,16(sp)
    8000585c:	6105                	addi	sp,sp,32
    8000585e:	8082                	ret

0000000080005860 <sys_link>:
{
    80005860:	7169                	addi	sp,sp,-304
    80005862:	f606                	sd	ra,296(sp)
    80005864:	f222                	sd	s0,288(sp)
    80005866:	ee26                	sd	s1,280(sp)
    80005868:	ea4a                	sd	s2,272(sp)
    8000586a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000586c:	08000613          	li	a2,128
    80005870:	ed040593          	addi	a1,s0,-304
    80005874:	4501                	li	a0,0
    80005876:	ffffd097          	auipc	ra,0xffffd
    8000587a:	75e080e7          	jalr	1886(ra) # 80002fd4 <argstr>
    return -1;
    8000587e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005880:	10054e63          	bltz	a0,8000599c <sys_link+0x13c>
    80005884:	08000613          	li	a2,128
    80005888:	f5040593          	addi	a1,s0,-176
    8000588c:	4505                	li	a0,1
    8000588e:	ffffd097          	auipc	ra,0xffffd
    80005892:	746080e7          	jalr	1862(ra) # 80002fd4 <argstr>
    return -1;
    80005896:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005898:	10054263          	bltz	a0,8000599c <sys_link+0x13c>
  begin_op();
    8000589c:	fffff097          	auipc	ra,0xfffff
    800058a0:	d00080e7          	jalr	-768(ra) # 8000459c <begin_op>
  if((ip = namei(old)) == 0){
    800058a4:	ed040513          	addi	a0,s0,-304
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	ad8080e7          	jalr	-1320(ra) # 80004380 <namei>
    800058b0:	84aa                	mv	s1,a0
    800058b2:	c551                	beqz	a0,8000593e <sys_link+0xde>
  ilock(ip);
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	326080e7          	jalr	806(ra) # 80003bda <ilock>
  if(ip->type == T_DIR){
    800058bc:	04449703          	lh	a4,68(s1)
    800058c0:	4785                	li	a5,1
    800058c2:	08f70463          	beq	a4,a5,8000594a <sys_link+0xea>
  ip->nlink++;
    800058c6:	04a4d783          	lhu	a5,74(s1)
    800058ca:	2785                	addiw	a5,a5,1
    800058cc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058d0:	8526                	mv	a0,s1
    800058d2:	ffffe097          	auipc	ra,0xffffe
    800058d6:	23e080e7          	jalr	574(ra) # 80003b10 <iupdate>
  iunlock(ip);
    800058da:	8526                	mv	a0,s1
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	3c0080e7          	jalr	960(ra) # 80003c9c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800058e4:	fd040593          	addi	a1,s0,-48
    800058e8:	f5040513          	addi	a0,s0,-176
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	ab2080e7          	jalr	-1358(ra) # 8000439e <nameiparent>
    800058f4:	892a                	mv	s2,a0
    800058f6:	c935                	beqz	a0,8000596a <sys_link+0x10a>
  ilock(dp);
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	2e2080e7          	jalr	738(ra) # 80003bda <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005900:	00092703          	lw	a4,0(s2)
    80005904:	409c                	lw	a5,0(s1)
    80005906:	04f71d63          	bne	a4,a5,80005960 <sys_link+0x100>
    8000590a:	40d0                	lw	a2,4(s1)
    8000590c:	fd040593          	addi	a1,s0,-48
    80005910:	854a                	mv	a0,s2
    80005912:	fffff097          	auipc	ra,0xfffff
    80005916:	9bc080e7          	jalr	-1604(ra) # 800042ce <dirlink>
    8000591a:	04054363          	bltz	a0,80005960 <sys_link+0x100>
  iunlockput(dp);
    8000591e:	854a                	mv	a0,s2
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	51c080e7          	jalr	1308(ra) # 80003e3c <iunlockput>
  iput(ip);
    80005928:	8526                	mv	a0,s1
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	46a080e7          	jalr	1130(ra) # 80003d94 <iput>
  end_op();
    80005932:	fffff097          	auipc	ra,0xfffff
    80005936:	cea080e7          	jalr	-790(ra) # 8000461c <end_op>
  return 0;
    8000593a:	4781                	li	a5,0
    8000593c:	a085                	j	8000599c <sys_link+0x13c>
    end_op();
    8000593e:	fffff097          	auipc	ra,0xfffff
    80005942:	cde080e7          	jalr	-802(ra) # 8000461c <end_op>
    return -1;
    80005946:	57fd                	li	a5,-1
    80005948:	a891                	j	8000599c <sys_link+0x13c>
    iunlockput(ip);
    8000594a:	8526                	mv	a0,s1
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	4f0080e7          	jalr	1264(ra) # 80003e3c <iunlockput>
    end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	cc8080e7          	jalr	-824(ra) # 8000461c <end_op>
    return -1;
    8000595c:	57fd                	li	a5,-1
    8000595e:	a83d                	j	8000599c <sys_link+0x13c>
    iunlockput(dp);
    80005960:	854a                	mv	a0,s2
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	4da080e7          	jalr	1242(ra) # 80003e3c <iunlockput>
  ilock(ip);
    8000596a:	8526                	mv	a0,s1
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	26e080e7          	jalr	622(ra) # 80003bda <ilock>
  ip->nlink--;
    80005974:	04a4d783          	lhu	a5,74(s1)
    80005978:	37fd                	addiw	a5,a5,-1
    8000597a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000597e:	8526                	mv	a0,s1
    80005980:	ffffe097          	auipc	ra,0xffffe
    80005984:	190080e7          	jalr	400(ra) # 80003b10 <iupdate>
  iunlockput(ip);
    80005988:	8526                	mv	a0,s1
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	4b2080e7          	jalr	1202(ra) # 80003e3c <iunlockput>
  end_op();
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	c8a080e7          	jalr	-886(ra) # 8000461c <end_op>
  return -1;
    8000599a:	57fd                	li	a5,-1
}
    8000599c:	853e                	mv	a0,a5
    8000599e:	70b2                	ld	ra,296(sp)
    800059a0:	7412                	ld	s0,288(sp)
    800059a2:	64f2                	ld	s1,280(sp)
    800059a4:	6952                	ld	s2,272(sp)
    800059a6:	6155                	addi	sp,sp,304
    800059a8:	8082                	ret

00000000800059aa <sys_unlink>:
{
    800059aa:	7151                	addi	sp,sp,-240
    800059ac:	f586                	sd	ra,232(sp)
    800059ae:	f1a2                	sd	s0,224(sp)
    800059b0:	eda6                	sd	s1,216(sp)
    800059b2:	e9ca                	sd	s2,208(sp)
    800059b4:	e5ce                	sd	s3,200(sp)
    800059b6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800059b8:	08000613          	li	a2,128
    800059bc:	f3040593          	addi	a1,s0,-208
    800059c0:	4501                	li	a0,0
    800059c2:	ffffd097          	auipc	ra,0xffffd
    800059c6:	612080e7          	jalr	1554(ra) # 80002fd4 <argstr>
    800059ca:	18054163          	bltz	a0,80005b4c <sys_unlink+0x1a2>
  begin_op();
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	bce080e7          	jalr	-1074(ra) # 8000459c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800059d6:	fb040593          	addi	a1,s0,-80
    800059da:	f3040513          	addi	a0,s0,-208
    800059de:	fffff097          	auipc	ra,0xfffff
    800059e2:	9c0080e7          	jalr	-1600(ra) # 8000439e <nameiparent>
    800059e6:	84aa                	mv	s1,a0
    800059e8:	c979                	beqz	a0,80005abe <sys_unlink+0x114>
  ilock(dp);
    800059ea:	ffffe097          	auipc	ra,0xffffe
    800059ee:	1f0080e7          	jalr	496(ra) # 80003bda <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800059f2:	00003597          	auipc	a1,0x3
    800059f6:	d1658593          	addi	a1,a1,-746 # 80008708 <syscalls+0x2b8>
    800059fa:	fb040513          	addi	a0,s0,-80
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	6a6080e7          	jalr	1702(ra) # 800040a4 <namecmp>
    80005a06:	14050a63          	beqz	a0,80005b5a <sys_unlink+0x1b0>
    80005a0a:	00003597          	auipc	a1,0x3
    80005a0e:	d0658593          	addi	a1,a1,-762 # 80008710 <syscalls+0x2c0>
    80005a12:	fb040513          	addi	a0,s0,-80
    80005a16:	ffffe097          	auipc	ra,0xffffe
    80005a1a:	68e080e7          	jalr	1678(ra) # 800040a4 <namecmp>
    80005a1e:	12050e63          	beqz	a0,80005b5a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005a22:	f2c40613          	addi	a2,s0,-212
    80005a26:	fb040593          	addi	a1,s0,-80
    80005a2a:	8526                	mv	a0,s1
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	692080e7          	jalr	1682(ra) # 800040be <dirlookup>
    80005a34:	892a                	mv	s2,a0
    80005a36:	12050263          	beqz	a0,80005b5a <sys_unlink+0x1b0>
  ilock(ip);
    80005a3a:	ffffe097          	auipc	ra,0xffffe
    80005a3e:	1a0080e7          	jalr	416(ra) # 80003bda <ilock>
  if(ip->nlink < 1)
    80005a42:	04a91783          	lh	a5,74(s2)
    80005a46:	08f05263          	blez	a5,80005aca <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005a4a:	04491703          	lh	a4,68(s2)
    80005a4e:	4785                	li	a5,1
    80005a50:	08f70563          	beq	a4,a5,80005ada <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005a54:	4641                	li	a2,16
    80005a56:	4581                	li	a1,0
    80005a58:	fc040513          	addi	a0,s0,-64
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	276080e7          	jalr	630(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a64:	4741                	li	a4,16
    80005a66:	f2c42683          	lw	a3,-212(s0)
    80005a6a:	fc040613          	addi	a2,s0,-64
    80005a6e:	4581                	li	a1,0
    80005a70:	8526                	mv	a0,s1
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	514080e7          	jalr	1300(ra) # 80003f86 <writei>
    80005a7a:	47c1                	li	a5,16
    80005a7c:	0af51563          	bne	a0,a5,80005b26 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a80:	04491703          	lh	a4,68(s2)
    80005a84:	4785                	li	a5,1
    80005a86:	0af70863          	beq	a4,a5,80005b36 <sys_unlink+0x18c>
  iunlockput(dp);
    80005a8a:	8526                	mv	a0,s1
    80005a8c:	ffffe097          	auipc	ra,0xffffe
    80005a90:	3b0080e7          	jalr	944(ra) # 80003e3c <iunlockput>
  ip->nlink--;
    80005a94:	04a95783          	lhu	a5,74(s2)
    80005a98:	37fd                	addiw	a5,a5,-1
    80005a9a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a9e:	854a                	mv	a0,s2
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	070080e7          	jalr	112(ra) # 80003b10 <iupdate>
  iunlockput(ip);
    80005aa8:	854a                	mv	a0,s2
    80005aaa:	ffffe097          	auipc	ra,0xffffe
    80005aae:	392080e7          	jalr	914(ra) # 80003e3c <iunlockput>
  end_op();
    80005ab2:	fffff097          	auipc	ra,0xfffff
    80005ab6:	b6a080e7          	jalr	-1174(ra) # 8000461c <end_op>
  return 0;
    80005aba:	4501                	li	a0,0
    80005abc:	a84d                	j	80005b6e <sys_unlink+0x1c4>
    end_op();
    80005abe:	fffff097          	auipc	ra,0xfffff
    80005ac2:	b5e080e7          	jalr	-1186(ra) # 8000461c <end_op>
    return -1;
    80005ac6:	557d                	li	a0,-1
    80005ac8:	a05d                	j	80005b6e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005aca:	00003517          	auipc	a0,0x3
    80005ace:	c4e50513          	addi	a0,a0,-946 # 80008718 <syscalls+0x2c8>
    80005ad2:	ffffb097          	auipc	ra,0xffffb
    80005ad6:	a6c080e7          	jalr	-1428(ra) # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005ada:	04c92703          	lw	a4,76(s2)
    80005ade:	02000793          	li	a5,32
    80005ae2:	f6e7f9e3          	bgeu	a5,a4,80005a54 <sys_unlink+0xaa>
    80005ae6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005aea:	4741                	li	a4,16
    80005aec:	86ce                	mv	a3,s3
    80005aee:	f1840613          	addi	a2,s0,-232
    80005af2:	4581                	li	a1,0
    80005af4:	854a                	mv	a0,s2
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	398080e7          	jalr	920(ra) # 80003e8e <readi>
    80005afe:	47c1                	li	a5,16
    80005b00:	00f51b63          	bne	a0,a5,80005b16 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005b04:	f1845783          	lhu	a5,-232(s0)
    80005b08:	e7a1                	bnez	a5,80005b50 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005b0a:	29c1                	addiw	s3,s3,16
    80005b0c:	04c92783          	lw	a5,76(s2)
    80005b10:	fcf9ede3          	bltu	s3,a5,80005aea <sys_unlink+0x140>
    80005b14:	b781                	j	80005a54 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005b16:	00003517          	auipc	a0,0x3
    80005b1a:	c1a50513          	addi	a0,a0,-998 # 80008730 <syscalls+0x2e0>
    80005b1e:	ffffb097          	auipc	ra,0xffffb
    80005b22:	a20080e7          	jalr	-1504(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005b26:	00003517          	auipc	a0,0x3
    80005b2a:	c2250513          	addi	a0,a0,-990 # 80008748 <syscalls+0x2f8>
    80005b2e:	ffffb097          	auipc	ra,0xffffb
    80005b32:	a10080e7          	jalr	-1520(ra) # 8000053e <panic>
    dp->nlink--;
    80005b36:	04a4d783          	lhu	a5,74(s1)
    80005b3a:	37fd                	addiw	a5,a5,-1
    80005b3c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005b40:	8526                	mv	a0,s1
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	fce080e7          	jalr	-50(ra) # 80003b10 <iupdate>
    80005b4a:	b781                	j	80005a8a <sys_unlink+0xe0>
    return -1;
    80005b4c:	557d                	li	a0,-1
    80005b4e:	a005                	j	80005b6e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005b50:	854a                	mv	a0,s2
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	2ea080e7          	jalr	746(ra) # 80003e3c <iunlockput>
  iunlockput(dp);
    80005b5a:	8526                	mv	a0,s1
    80005b5c:	ffffe097          	auipc	ra,0xffffe
    80005b60:	2e0080e7          	jalr	736(ra) # 80003e3c <iunlockput>
  end_op();
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	ab8080e7          	jalr	-1352(ra) # 8000461c <end_op>
  return -1;
    80005b6c:	557d                	li	a0,-1
}
    80005b6e:	70ae                	ld	ra,232(sp)
    80005b70:	740e                	ld	s0,224(sp)
    80005b72:	64ee                	ld	s1,216(sp)
    80005b74:	694e                	ld	s2,208(sp)
    80005b76:	69ae                	ld	s3,200(sp)
    80005b78:	616d                	addi	sp,sp,240
    80005b7a:	8082                	ret

0000000080005b7c <sys_open>:

uint64
sys_open(void)
{
    80005b7c:	7131                	addi	sp,sp,-192
    80005b7e:	fd06                	sd	ra,184(sp)
    80005b80:	f922                	sd	s0,176(sp)
    80005b82:	f526                	sd	s1,168(sp)
    80005b84:	f14a                	sd	s2,160(sp)
    80005b86:	ed4e                	sd	s3,152(sp)
    80005b88:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b8a:	f4c40593          	addi	a1,s0,-180
    80005b8e:	4505                	li	a0,1
    80005b90:	ffffd097          	auipc	ra,0xffffd
    80005b94:	404080e7          	jalr	1028(ra) # 80002f94 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b98:	08000613          	li	a2,128
    80005b9c:	f5040593          	addi	a1,s0,-176
    80005ba0:	4501                	li	a0,0
    80005ba2:	ffffd097          	auipc	ra,0xffffd
    80005ba6:	432080e7          	jalr	1074(ra) # 80002fd4 <argstr>
    80005baa:	87aa                	mv	a5,a0
    return -1;
    80005bac:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005bae:	0a07c963          	bltz	a5,80005c60 <sys_open+0xe4>

  begin_op();
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	9ea080e7          	jalr	-1558(ra) # 8000459c <begin_op>

  if(omode & O_CREATE){
    80005bba:	f4c42783          	lw	a5,-180(s0)
    80005bbe:	2007f793          	andi	a5,a5,512
    80005bc2:	cfc5                	beqz	a5,80005c7a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005bc4:	4681                	li	a3,0
    80005bc6:	4601                	li	a2,0
    80005bc8:	4589                	li	a1,2
    80005bca:	f5040513          	addi	a0,s0,-176
    80005bce:	00000097          	auipc	ra,0x0
    80005bd2:	976080e7          	jalr	-1674(ra) # 80005544 <create>
    80005bd6:	84aa                	mv	s1,a0
    if(ip == 0){
    80005bd8:	c959                	beqz	a0,80005c6e <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005bda:	04449703          	lh	a4,68(s1)
    80005bde:	478d                	li	a5,3
    80005be0:	00f71763          	bne	a4,a5,80005bee <sys_open+0x72>
    80005be4:	0464d703          	lhu	a4,70(s1)
    80005be8:	47a5                	li	a5,9
    80005bea:	0ce7ed63          	bltu	a5,a4,80005cc4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	dbe080e7          	jalr	-578(ra) # 800049ac <filealloc>
    80005bf6:	89aa                	mv	s3,a0
    80005bf8:	10050363          	beqz	a0,80005cfe <sys_open+0x182>
    80005bfc:	00000097          	auipc	ra,0x0
    80005c00:	906080e7          	jalr	-1786(ra) # 80005502 <fdalloc>
    80005c04:	892a                	mv	s2,a0
    80005c06:	0e054763          	bltz	a0,80005cf4 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005c0a:	04449703          	lh	a4,68(s1)
    80005c0e:	478d                	li	a5,3
    80005c10:	0cf70563          	beq	a4,a5,80005cda <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005c14:	4789                	li	a5,2
    80005c16:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005c1a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005c1e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005c22:	f4c42783          	lw	a5,-180(s0)
    80005c26:	0017c713          	xori	a4,a5,1
    80005c2a:	8b05                	andi	a4,a4,1
    80005c2c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005c30:	0037f713          	andi	a4,a5,3
    80005c34:	00e03733          	snez	a4,a4
    80005c38:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005c3c:	4007f793          	andi	a5,a5,1024
    80005c40:	c791                	beqz	a5,80005c4c <sys_open+0xd0>
    80005c42:	04449703          	lh	a4,68(s1)
    80005c46:	4789                	li	a5,2
    80005c48:	0af70063          	beq	a4,a5,80005ce8 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005c4c:	8526                	mv	a0,s1
    80005c4e:	ffffe097          	auipc	ra,0xffffe
    80005c52:	04e080e7          	jalr	78(ra) # 80003c9c <iunlock>
  end_op();
    80005c56:	fffff097          	auipc	ra,0xfffff
    80005c5a:	9c6080e7          	jalr	-1594(ra) # 8000461c <end_op>

  return fd;
    80005c5e:	854a                	mv	a0,s2
}
    80005c60:	70ea                	ld	ra,184(sp)
    80005c62:	744a                	ld	s0,176(sp)
    80005c64:	74aa                	ld	s1,168(sp)
    80005c66:	790a                	ld	s2,160(sp)
    80005c68:	69ea                	ld	s3,152(sp)
    80005c6a:	6129                	addi	sp,sp,192
    80005c6c:	8082                	ret
      end_op();
    80005c6e:	fffff097          	auipc	ra,0xfffff
    80005c72:	9ae080e7          	jalr	-1618(ra) # 8000461c <end_op>
      return -1;
    80005c76:	557d                	li	a0,-1
    80005c78:	b7e5                	j	80005c60 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c7a:	f5040513          	addi	a0,s0,-176
    80005c7e:	ffffe097          	auipc	ra,0xffffe
    80005c82:	702080e7          	jalr	1794(ra) # 80004380 <namei>
    80005c86:	84aa                	mv	s1,a0
    80005c88:	c905                	beqz	a0,80005cb8 <sys_open+0x13c>
    ilock(ip);
    80005c8a:	ffffe097          	auipc	ra,0xffffe
    80005c8e:	f50080e7          	jalr	-176(ra) # 80003bda <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c92:	04449703          	lh	a4,68(s1)
    80005c96:	4785                	li	a5,1
    80005c98:	f4f711e3          	bne	a4,a5,80005bda <sys_open+0x5e>
    80005c9c:	f4c42783          	lw	a5,-180(s0)
    80005ca0:	d7b9                	beqz	a5,80005bee <sys_open+0x72>
      iunlockput(ip);
    80005ca2:	8526                	mv	a0,s1
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	198080e7          	jalr	408(ra) # 80003e3c <iunlockput>
      end_op();
    80005cac:	fffff097          	auipc	ra,0xfffff
    80005cb0:	970080e7          	jalr	-1680(ra) # 8000461c <end_op>
      return -1;
    80005cb4:	557d                	li	a0,-1
    80005cb6:	b76d                	j	80005c60 <sys_open+0xe4>
      end_op();
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	964080e7          	jalr	-1692(ra) # 8000461c <end_op>
      return -1;
    80005cc0:	557d                	li	a0,-1
    80005cc2:	bf79                	j	80005c60 <sys_open+0xe4>
    iunlockput(ip);
    80005cc4:	8526                	mv	a0,s1
    80005cc6:	ffffe097          	auipc	ra,0xffffe
    80005cca:	176080e7          	jalr	374(ra) # 80003e3c <iunlockput>
    end_op();
    80005cce:	fffff097          	auipc	ra,0xfffff
    80005cd2:	94e080e7          	jalr	-1714(ra) # 8000461c <end_op>
    return -1;
    80005cd6:	557d                	li	a0,-1
    80005cd8:	b761                	j	80005c60 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005cda:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005cde:	04649783          	lh	a5,70(s1)
    80005ce2:	02f99223          	sh	a5,36(s3)
    80005ce6:	bf25                	j	80005c1e <sys_open+0xa2>
    itrunc(ip);
    80005ce8:	8526                	mv	a0,s1
    80005cea:	ffffe097          	auipc	ra,0xffffe
    80005cee:	ffe080e7          	jalr	-2(ra) # 80003ce8 <itrunc>
    80005cf2:	bfa9                	j	80005c4c <sys_open+0xd0>
      fileclose(f);
    80005cf4:	854e                	mv	a0,s3
    80005cf6:	fffff097          	auipc	ra,0xfffff
    80005cfa:	d72080e7          	jalr	-654(ra) # 80004a68 <fileclose>
    iunlockput(ip);
    80005cfe:	8526                	mv	a0,s1
    80005d00:	ffffe097          	auipc	ra,0xffffe
    80005d04:	13c080e7          	jalr	316(ra) # 80003e3c <iunlockput>
    end_op();
    80005d08:	fffff097          	auipc	ra,0xfffff
    80005d0c:	914080e7          	jalr	-1772(ra) # 8000461c <end_op>
    return -1;
    80005d10:	557d                	li	a0,-1
    80005d12:	b7b9                	j	80005c60 <sys_open+0xe4>

0000000080005d14 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005d14:	7175                	addi	sp,sp,-144
    80005d16:	e506                	sd	ra,136(sp)
    80005d18:	e122                	sd	s0,128(sp)
    80005d1a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005d1c:	fffff097          	auipc	ra,0xfffff
    80005d20:	880080e7          	jalr	-1920(ra) # 8000459c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005d24:	08000613          	li	a2,128
    80005d28:	f7040593          	addi	a1,s0,-144
    80005d2c:	4501                	li	a0,0
    80005d2e:	ffffd097          	auipc	ra,0xffffd
    80005d32:	2a6080e7          	jalr	678(ra) # 80002fd4 <argstr>
    80005d36:	02054963          	bltz	a0,80005d68 <sys_mkdir+0x54>
    80005d3a:	4681                	li	a3,0
    80005d3c:	4601                	li	a2,0
    80005d3e:	4585                	li	a1,1
    80005d40:	f7040513          	addi	a0,s0,-144
    80005d44:	00000097          	auipc	ra,0x0
    80005d48:	800080e7          	jalr	-2048(ra) # 80005544 <create>
    80005d4c:	cd11                	beqz	a0,80005d68 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d4e:	ffffe097          	auipc	ra,0xffffe
    80005d52:	0ee080e7          	jalr	238(ra) # 80003e3c <iunlockput>
  end_op();
    80005d56:	fffff097          	auipc	ra,0xfffff
    80005d5a:	8c6080e7          	jalr	-1850(ra) # 8000461c <end_op>
  return 0;
    80005d5e:	4501                	li	a0,0
}
    80005d60:	60aa                	ld	ra,136(sp)
    80005d62:	640a                	ld	s0,128(sp)
    80005d64:	6149                	addi	sp,sp,144
    80005d66:	8082                	ret
    end_op();
    80005d68:	fffff097          	auipc	ra,0xfffff
    80005d6c:	8b4080e7          	jalr	-1868(ra) # 8000461c <end_op>
    return -1;
    80005d70:	557d                	li	a0,-1
    80005d72:	b7fd                	j	80005d60 <sys_mkdir+0x4c>

0000000080005d74 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d74:	7135                	addi	sp,sp,-160
    80005d76:	ed06                	sd	ra,152(sp)
    80005d78:	e922                	sd	s0,144(sp)
    80005d7a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d7c:	fffff097          	auipc	ra,0xfffff
    80005d80:	820080e7          	jalr	-2016(ra) # 8000459c <begin_op>
  argint(1, &major);
    80005d84:	f6c40593          	addi	a1,s0,-148
    80005d88:	4505                	li	a0,1
    80005d8a:	ffffd097          	auipc	ra,0xffffd
    80005d8e:	20a080e7          	jalr	522(ra) # 80002f94 <argint>
  argint(2, &minor);
    80005d92:	f6840593          	addi	a1,s0,-152
    80005d96:	4509                	li	a0,2
    80005d98:	ffffd097          	auipc	ra,0xffffd
    80005d9c:	1fc080e7          	jalr	508(ra) # 80002f94 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005da0:	08000613          	li	a2,128
    80005da4:	f7040593          	addi	a1,s0,-144
    80005da8:	4501                	li	a0,0
    80005daa:	ffffd097          	auipc	ra,0xffffd
    80005dae:	22a080e7          	jalr	554(ra) # 80002fd4 <argstr>
    80005db2:	02054b63          	bltz	a0,80005de8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005db6:	f6841683          	lh	a3,-152(s0)
    80005dba:	f6c41603          	lh	a2,-148(s0)
    80005dbe:	458d                	li	a1,3
    80005dc0:	f7040513          	addi	a0,s0,-144
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	780080e7          	jalr	1920(ra) # 80005544 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005dcc:	cd11                	beqz	a0,80005de8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005dce:	ffffe097          	auipc	ra,0xffffe
    80005dd2:	06e080e7          	jalr	110(ra) # 80003e3c <iunlockput>
  end_op();
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	846080e7          	jalr	-1978(ra) # 8000461c <end_op>
  return 0;
    80005dde:	4501                	li	a0,0
}
    80005de0:	60ea                	ld	ra,152(sp)
    80005de2:	644a                	ld	s0,144(sp)
    80005de4:	610d                	addi	sp,sp,160
    80005de6:	8082                	ret
    end_op();
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	834080e7          	jalr	-1996(ra) # 8000461c <end_op>
    return -1;
    80005df0:	557d                	li	a0,-1
    80005df2:	b7fd                	j	80005de0 <sys_mknod+0x6c>

0000000080005df4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005df4:	7135                	addi	sp,sp,-160
    80005df6:	ed06                	sd	ra,152(sp)
    80005df8:	e922                	sd	s0,144(sp)
    80005dfa:	e526                	sd	s1,136(sp)
    80005dfc:	e14a                	sd	s2,128(sp)
    80005dfe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005e00:	ffffc097          	auipc	ra,0xffffc
    80005e04:	bac080e7          	jalr	-1108(ra) # 800019ac <myproc>
    80005e08:	892a                	mv	s2,a0
  
  begin_op();
    80005e0a:	ffffe097          	auipc	ra,0xffffe
    80005e0e:	792080e7          	jalr	1938(ra) # 8000459c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005e12:	08000613          	li	a2,128
    80005e16:	f6040593          	addi	a1,s0,-160
    80005e1a:	4501                	li	a0,0
    80005e1c:	ffffd097          	auipc	ra,0xffffd
    80005e20:	1b8080e7          	jalr	440(ra) # 80002fd4 <argstr>
    80005e24:	04054b63          	bltz	a0,80005e7a <sys_chdir+0x86>
    80005e28:	f6040513          	addi	a0,s0,-160
    80005e2c:	ffffe097          	auipc	ra,0xffffe
    80005e30:	554080e7          	jalr	1364(ra) # 80004380 <namei>
    80005e34:	84aa                	mv	s1,a0
    80005e36:	c131                	beqz	a0,80005e7a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005e38:	ffffe097          	auipc	ra,0xffffe
    80005e3c:	da2080e7          	jalr	-606(ra) # 80003bda <ilock>
  if(ip->type != T_DIR){
    80005e40:	04449703          	lh	a4,68(s1)
    80005e44:	4785                	li	a5,1
    80005e46:	04f71063          	bne	a4,a5,80005e86 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005e4a:	8526                	mv	a0,s1
    80005e4c:	ffffe097          	auipc	ra,0xffffe
    80005e50:	e50080e7          	jalr	-432(ra) # 80003c9c <iunlock>
  iput(p->cwd);
    80005e54:	15093503          	ld	a0,336(s2)
    80005e58:	ffffe097          	auipc	ra,0xffffe
    80005e5c:	f3c080e7          	jalr	-196(ra) # 80003d94 <iput>
  end_op();
    80005e60:	ffffe097          	auipc	ra,0xffffe
    80005e64:	7bc080e7          	jalr	1980(ra) # 8000461c <end_op>
  p->cwd = ip;
    80005e68:	14993823          	sd	s1,336(s2)
  return 0;
    80005e6c:	4501                	li	a0,0
}
    80005e6e:	60ea                	ld	ra,152(sp)
    80005e70:	644a                	ld	s0,144(sp)
    80005e72:	64aa                	ld	s1,136(sp)
    80005e74:	690a                	ld	s2,128(sp)
    80005e76:	610d                	addi	sp,sp,160
    80005e78:	8082                	ret
    end_op();
    80005e7a:	ffffe097          	auipc	ra,0xffffe
    80005e7e:	7a2080e7          	jalr	1954(ra) # 8000461c <end_op>
    return -1;
    80005e82:	557d                	li	a0,-1
    80005e84:	b7ed                	j	80005e6e <sys_chdir+0x7a>
    iunlockput(ip);
    80005e86:	8526                	mv	a0,s1
    80005e88:	ffffe097          	auipc	ra,0xffffe
    80005e8c:	fb4080e7          	jalr	-76(ra) # 80003e3c <iunlockput>
    end_op();
    80005e90:	ffffe097          	auipc	ra,0xffffe
    80005e94:	78c080e7          	jalr	1932(ra) # 8000461c <end_op>
    return -1;
    80005e98:	557d                	li	a0,-1
    80005e9a:	bfd1                	j	80005e6e <sys_chdir+0x7a>

0000000080005e9c <sys_exec>:

uint64
sys_exec(void)
{
    80005e9c:	7145                	addi	sp,sp,-464
    80005e9e:	e786                	sd	ra,456(sp)
    80005ea0:	e3a2                	sd	s0,448(sp)
    80005ea2:	ff26                	sd	s1,440(sp)
    80005ea4:	fb4a                	sd	s2,432(sp)
    80005ea6:	f74e                	sd	s3,424(sp)
    80005ea8:	f352                	sd	s4,416(sp)
    80005eaa:	ef56                	sd	s5,408(sp)
    80005eac:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005eae:	e3840593          	addi	a1,s0,-456
    80005eb2:	4505                	li	a0,1
    80005eb4:	ffffd097          	auipc	ra,0xffffd
    80005eb8:	100080e7          	jalr	256(ra) # 80002fb4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ebc:	08000613          	li	a2,128
    80005ec0:	f4040593          	addi	a1,s0,-192
    80005ec4:	4501                	li	a0,0
    80005ec6:	ffffd097          	auipc	ra,0xffffd
    80005eca:	10e080e7          	jalr	270(ra) # 80002fd4 <argstr>
    80005ece:	87aa                	mv	a5,a0
    return -1;
    80005ed0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ed2:	0c07c263          	bltz	a5,80005f96 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005ed6:	10000613          	li	a2,256
    80005eda:	4581                	li	a1,0
    80005edc:	e4040513          	addi	a0,s0,-448
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	df2080e7          	jalr	-526(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005ee8:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005eec:	89a6                	mv	s3,s1
    80005eee:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ef0:	02000a13          	li	s4,32
    80005ef4:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005ef8:	00391793          	slli	a5,s2,0x3
    80005efc:	e3040593          	addi	a1,s0,-464
    80005f00:	e3843503          	ld	a0,-456(s0)
    80005f04:	953e                	add	a0,a0,a5
    80005f06:	ffffd097          	auipc	ra,0xffffd
    80005f0a:	ff0080e7          	jalr	-16(ra) # 80002ef6 <fetchaddr>
    80005f0e:	02054a63          	bltz	a0,80005f42 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005f12:	e3043783          	ld	a5,-464(s0)
    80005f16:	c3b9                	beqz	a5,80005f5c <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005f18:	ffffb097          	auipc	ra,0xffffb
    80005f1c:	bce080e7          	jalr	-1074(ra) # 80000ae6 <kalloc>
    80005f20:	85aa                	mv	a1,a0
    80005f22:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005f26:	cd11                	beqz	a0,80005f42 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005f28:	6605                	lui	a2,0x1
    80005f2a:	e3043503          	ld	a0,-464(s0)
    80005f2e:	ffffd097          	auipc	ra,0xffffd
    80005f32:	01a080e7          	jalr	26(ra) # 80002f48 <fetchstr>
    80005f36:	00054663          	bltz	a0,80005f42 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005f3a:	0905                	addi	s2,s2,1
    80005f3c:	09a1                	addi	s3,s3,8
    80005f3e:	fb491be3          	bne	s2,s4,80005ef4 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f42:	10048913          	addi	s2,s1,256
    80005f46:	6088                	ld	a0,0(s1)
    80005f48:	c531                	beqz	a0,80005f94 <sys_exec+0xf8>
    kfree(argv[i]);
    80005f4a:	ffffb097          	auipc	ra,0xffffb
    80005f4e:	aa0080e7          	jalr	-1376(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f52:	04a1                	addi	s1,s1,8
    80005f54:	ff2499e3          	bne	s1,s2,80005f46 <sys_exec+0xaa>
  return -1;
    80005f58:	557d                	li	a0,-1
    80005f5a:	a835                	j	80005f96 <sys_exec+0xfa>
      argv[i] = 0;
    80005f5c:	0a8e                	slli	s5,s5,0x3
    80005f5e:	fc040793          	addi	a5,s0,-64
    80005f62:	9abe                	add	s5,s5,a5
    80005f64:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f68:	e4040593          	addi	a1,s0,-448
    80005f6c:	f4040513          	addi	a0,s0,-192
    80005f70:	fffff097          	auipc	ra,0xfffff
    80005f74:	172080e7          	jalr	370(ra) # 800050e2 <exec>
    80005f78:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f7a:	10048993          	addi	s3,s1,256
    80005f7e:	6088                	ld	a0,0(s1)
    80005f80:	c901                	beqz	a0,80005f90 <sys_exec+0xf4>
    kfree(argv[i]);
    80005f82:	ffffb097          	auipc	ra,0xffffb
    80005f86:	a68080e7          	jalr	-1432(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f8a:	04a1                	addi	s1,s1,8
    80005f8c:	ff3499e3          	bne	s1,s3,80005f7e <sys_exec+0xe2>
  return ret;
    80005f90:	854a                	mv	a0,s2
    80005f92:	a011                	j	80005f96 <sys_exec+0xfa>
  return -1;
    80005f94:	557d                	li	a0,-1
}
    80005f96:	60be                	ld	ra,456(sp)
    80005f98:	641e                	ld	s0,448(sp)
    80005f9a:	74fa                	ld	s1,440(sp)
    80005f9c:	795a                	ld	s2,432(sp)
    80005f9e:	79ba                	ld	s3,424(sp)
    80005fa0:	7a1a                	ld	s4,416(sp)
    80005fa2:	6afa                	ld	s5,408(sp)
    80005fa4:	6179                	addi	sp,sp,464
    80005fa6:	8082                	ret

0000000080005fa8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005fa8:	7139                	addi	sp,sp,-64
    80005faa:	fc06                	sd	ra,56(sp)
    80005fac:	f822                	sd	s0,48(sp)
    80005fae:	f426                	sd	s1,40(sp)
    80005fb0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005fb2:	ffffc097          	auipc	ra,0xffffc
    80005fb6:	9fa080e7          	jalr	-1542(ra) # 800019ac <myproc>
    80005fba:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005fbc:	fd840593          	addi	a1,s0,-40
    80005fc0:	4501                	li	a0,0
    80005fc2:	ffffd097          	auipc	ra,0xffffd
    80005fc6:	ff2080e7          	jalr	-14(ra) # 80002fb4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005fca:	fc840593          	addi	a1,s0,-56
    80005fce:	fd040513          	addi	a0,s0,-48
    80005fd2:	fffff097          	auipc	ra,0xfffff
    80005fd6:	dc6080e7          	jalr	-570(ra) # 80004d98 <pipealloc>
    return -1;
    80005fda:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005fdc:	0c054463          	bltz	a0,800060a4 <sys_pipe+0xfc>
  fd0 = -1;
    80005fe0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005fe4:	fd043503          	ld	a0,-48(s0)
    80005fe8:	fffff097          	auipc	ra,0xfffff
    80005fec:	51a080e7          	jalr	1306(ra) # 80005502 <fdalloc>
    80005ff0:	fca42223          	sw	a0,-60(s0)
    80005ff4:	08054b63          	bltz	a0,8000608a <sys_pipe+0xe2>
    80005ff8:	fc843503          	ld	a0,-56(s0)
    80005ffc:	fffff097          	auipc	ra,0xfffff
    80006000:	506080e7          	jalr	1286(ra) # 80005502 <fdalloc>
    80006004:	fca42023          	sw	a0,-64(s0)
    80006008:	06054863          	bltz	a0,80006078 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000600c:	4691                	li	a3,4
    8000600e:	fc440613          	addi	a2,s0,-60
    80006012:	fd843583          	ld	a1,-40(s0)
    80006016:	68a8                	ld	a0,80(s1)
    80006018:	ffffb097          	auipc	ra,0xffffb
    8000601c:	650080e7          	jalr	1616(ra) # 80001668 <copyout>
    80006020:	02054063          	bltz	a0,80006040 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006024:	4691                	li	a3,4
    80006026:	fc040613          	addi	a2,s0,-64
    8000602a:	fd843583          	ld	a1,-40(s0)
    8000602e:	0591                	addi	a1,a1,4
    80006030:	68a8                	ld	a0,80(s1)
    80006032:	ffffb097          	auipc	ra,0xffffb
    80006036:	636080e7          	jalr	1590(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000603a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000603c:	06055463          	bgez	a0,800060a4 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80006040:	fc442783          	lw	a5,-60(s0)
    80006044:	07e9                	addi	a5,a5,26
    80006046:	078e                	slli	a5,a5,0x3
    80006048:	97a6                	add	a5,a5,s1
    8000604a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000604e:	fc042503          	lw	a0,-64(s0)
    80006052:	0569                	addi	a0,a0,26
    80006054:	050e                	slli	a0,a0,0x3
    80006056:	94aa                	add	s1,s1,a0
    80006058:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000605c:	fd043503          	ld	a0,-48(s0)
    80006060:	fffff097          	auipc	ra,0xfffff
    80006064:	a08080e7          	jalr	-1528(ra) # 80004a68 <fileclose>
    fileclose(wf);
    80006068:	fc843503          	ld	a0,-56(s0)
    8000606c:	fffff097          	auipc	ra,0xfffff
    80006070:	9fc080e7          	jalr	-1540(ra) # 80004a68 <fileclose>
    return -1;
    80006074:	57fd                	li	a5,-1
    80006076:	a03d                	j	800060a4 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006078:	fc442783          	lw	a5,-60(s0)
    8000607c:	0007c763          	bltz	a5,8000608a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80006080:	07e9                	addi	a5,a5,26
    80006082:	078e                	slli	a5,a5,0x3
    80006084:	94be                	add	s1,s1,a5
    80006086:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000608a:	fd043503          	ld	a0,-48(s0)
    8000608e:	fffff097          	auipc	ra,0xfffff
    80006092:	9da080e7          	jalr	-1574(ra) # 80004a68 <fileclose>
    fileclose(wf);
    80006096:	fc843503          	ld	a0,-56(s0)
    8000609a:	fffff097          	auipc	ra,0xfffff
    8000609e:	9ce080e7          	jalr	-1586(ra) # 80004a68 <fileclose>
    return -1;
    800060a2:	57fd                	li	a5,-1
}
    800060a4:	853e                	mv	a0,a5
    800060a6:	70e2                	ld	ra,56(sp)
    800060a8:	7442                	ld	s0,48(sp)
    800060aa:	74a2                	ld	s1,40(sp)
    800060ac:	6121                	addi	sp,sp,64
    800060ae:	8082                	ret

00000000800060b0 <kernelvec>:
    800060b0:	7111                	addi	sp,sp,-256
    800060b2:	e006                	sd	ra,0(sp)
    800060b4:	e40a                	sd	sp,8(sp)
    800060b6:	e80e                	sd	gp,16(sp)
    800060b8:	ec12                	sd	tp,24(sp)
    800060ba:	f016                	sd	t0,32(sp)
    800060bc:	f41a                	sd	t1,40(sp)
    800060be:	f81e                	sd	t2,48(sp)
    800060c0:	fc22                	sd	s0,56(sp)
    800060c2:	e0a6                	sd	s1,64(sp)
    800060c4:	e4aa                	sd	a0,72(sp)
    800060c6:	e8ae                	sd	a1,80(sp)
    800060c8:	ecb2                	sd	a2,88(sp)
    800060ca:	f0b6                	sd	a3,96(sp)
    800060cc:	f4ba                	sd	a4,104(sp)
    800060ce:	f8be                	sd	a5,112(sp)
    800060d0:	fcc2                	sd	a6,120(sp)
    800060d2:	e146                	sd	a7,128(sp)
    800060d4:	e54a                	sd	s2,136(sp)
    800060d6:	e94e                	sd	s3,144(sp)
    800060d8:	ed52                	sd	s4,152(sp)
    800060da:	f156                	sd	s5,160(sp)
    800060dc:	f55a                	sd	s6,168(sp)
    800060de:	f95e                	sd	s7,176(sp)
    800060e0:	fd62                	sd	s8,184(sp)
    800060e2:	e1e6                	sd	s9,192(sp)
    800060e4:	e5ea                	sd	s10,200(sp)
    800060e6:	e9ee                	sd	s11,208(sp)
    800060e8:	edf2                	sd	t3,216(sp)
    800060ea:	f1f6                	sd	t4,224(sp)
    800060ec:	f5fa                	sd	t5,232(sp)
    800060ee:	f9fe                	sd	t6,240(sp)
    800060f0:	cd3fc0ef          	jal	ra,80002dc2 <kerneltrap>
    800060f4:	6082                	ld	ra,0(sp)
    800060f6:	6122                	ld	sp,8(sp)
    800060f8:	61c2                	ld	gp,16(sp)
    800060fa:	7282                	ld	t0,32(sp)
    800060fc:	7322                	ld	t1,40(sp)
    800060fe:	73c2                	ld	t2,48(sp)
    80006100:	7462                	ld	s0,56(sp)
    80006102:	6486                	ld	s1,64(sp)
    80006104:	6526                	ld	a0,72(sp)
    80006106:	65c6                	ld	a1,80(sp)
    80006108:	6666                	ld	a2,88(sp)
    8000610a:	7686                	ld	a3,96(sp)
    8000610c:	7726                	ld	a4,104(sp)
    8000610e:	77c6                	ld	a5,112(sp)
    80006110:	7866                	ld	a6,120(sp)
    80006112:	688a                	ld	a7,128(sp)
    80006114:	692a                	ld	s2,136(sp)
    80006116:	69ca                	ld	s3,144(sp)
    80006118:	6a6a                	ld	s4,152(sp)
    8000611a:	7a8a                	ld	s5,160(sp)
    8000611c:	7b2a                	ld	s6,168(sp)
    8000611e:	7bca                	ld	s7,176(sp)
    80006120:	7c6a                	ld	s8,184(sp)
    80006122:	6c8e                	ld	s9,192(sp)
    80006124:	6d2e                	ld	s10,200(sp)
    80006126:	6dce                	ld	s11,208(sp)
    80006128:	6e6e                	ld	t3,216(sp)
    8000612a:	7e8e                	ld	t4,224(sp)
    8000612c:	7f2e                	ld	t5,232(sp)
    8000612e:	7fce                	ld	t6,240(sp)
    80006130:	6111                	addi	sp,sp,256
    80006132:	10200073          	sret
    80006136:	00000013          	nop
    8000613a:	00000013          	nop
    8000613e:	0001                	nop

0000000080006140 <timervec>:
    80006140:	34051573          	csrrw	a0,mscratch,a0
    80006144:	e10c                	sd	a1,0(a0)
    80006146:	e510                	sd	a2,8(a0)
    80006148:	e914                	sd	a3,16(a0)
    8000614a:	6d0c                	ld	a1,24(a0)
    8000614c:	7110                	ld	a2,32(a0)
    8000614e:	6194                	ld	a3,0(a1)
    80006150:	96b2                	add	a3,a3,a2
    80006152:	e194                	sd	a3,0(a1)
    80006154:	4589                	li	a1,2
    80006156:	14459073          	csrw	sip,a1
    8000615a:	6914                	ld	a3,16(a0)
    8000615c:	6510                	ld	a2,8(a0)
    8000615e:	610c                	ld	a1,0(a0)
    80006160:	34051573          	csrrw	a0,mscratch,a0
    80006164:	30200073          	mret
	...

000000008000616a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000616a:	1141                	addi	sp,sp,-16
    8000616c:	e422                	sd	s0,8(sp)
    8000616e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006170:	0c0007b7          	lui	a5,0xc000
    80006174:	4705                	li	a4,1
    80006176:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006178:	c3d8                	sw	a4,4(a5)
}
    8000617a:	6422                	ld	s0,8(sp)
    8000617c:	0141                	addi	sp,sp,16
    8000617e:	8082                	ret

0000000080006180 <plicinithart>:

void
plicinithart(void)
{
    80006180:	1141                	addi	sp,sp,-16
    80006182:	e406                	sd	ra,8(sp)
    80006184:	e022                	sd	s0,0(sp)
    80006186:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006188:	ffffb097          	auipc	ra,0xffffb
    8000618c:	7f8080e7          	jalr	2040(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006190:	0085171b          	slliw	a4,a0,0x8
    80006194:	0c0027b7          	lui	a5,0xc002
    80006198:	97ba                	add	a5,a5,a4
    8000619a:	40200713          	li	a4,1026
    8000619e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800061a2:	00d5151b          	slliw	a0,a0,0xd
    800061a6:	0c2017b7          	lui	a5,0xc201
    800061aa:	953e                	add	a0,a0,a5
    800061ac:	00052023          	sw	zero,0(a0)
}
    800061b0:	60a2                	ld	ra,8(sp)
    800061b2:	6402                	ld	s0,0(sp)
    800061b4:	0141                	addi	sp,sp,16
    800061b6:	8082                	ret

00000000800061b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800061b8:	1141                	addi	sp,sp,-16
    800061ba:	e406                	sd	ra,8(sp)
    800061bc:	e022                	sd	s0,0(sp)
    800061be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800061c0:	ffffb097          	auipc	ra,0xffffb
    800061c4:	7c0080e7          	jalr	1984(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800061c8:	00d5179b          	slliw	a5,a0,0xd
    800061cc:	0c201537          	lui	a0,0xc201
    800061d0:	953e                	add	a0,a0,a5
  return irq;
}
    800061d2:	4148                	lw	a0,4(a0)
    800061d4:	60a2                	ld	ra,8(sp)
    800061d6:	6402                	ld	s0,0(sp)
    800061d8:	0141                	addi	sp,sp,16
    800061da:	8082                	ret

00000000800061dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800061dc:	1101                	addi	sp,sp,-32
    800061de:	ec06                	sd	ra,24(sp)
    800061e0:	e822                	sd	s0,16(sp)
    800061e2:	e426                	sd	s1,8(sp)
    800061e4:	1000                	addi	s0,sp,32
    800061e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800061e8:	ffffb097          	auipc	ra,0xffffb
    800061ec:	798080e7          	jalr	1944(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800061f0:	00d5151b          	slliw	a0,a0,0xd
    800061f4:	0c2017b7          	lui	a5,0xc201
    800061f8:	97aa                	add	a5,a5,a0
    800061fa:	c3c4                	sw	s1,4(a5)
}
    800061fc:	60e2                	ld	ra,24(sp)
    800061fe:	6442                	ld	s0,16(sp)
    80006200:	64a2                	ld	s1,8(sp)
    80006202:	6105                	addi	sp,sp,32
    80006204:	8082                	ret

0000000080006206 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006206:	1141                	addi	sp,sp,-16
    80006208:	e406                	sd	ra,8(sp)
    8000620a:	e022                	sd	s0,0(sp)
    8000620c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000620e:	479d                	li	a5,7
    80006210:	04a7cc63          	blt	a5,a0,80006268 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006214:	0001c797          	auipc	a5,0x1c
    80006218:	22c78793          	addi	a5,a5,556 # 80022440 <disk>
    8000621c:	97aa                	add	a5,a5,a0
    8000621e:	0187c783          	lbu	a5,24(a5)
    80006222:	ebb9                	bnez	a5,80006278 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006224:	00451613          	slli	a2,a0,0x4
    80006228:	0001c797          	auipc	a5,0x1c
    8000622c:	21878793          	addi	a5,a5,536 # 80022440 <disk>
    80006230:	6394                	ld	a3,0(a5)
    80006232:	96b2                	add	a3,a3,a2
    80006234:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006238:	6398                	ld	a4,0(a5)
    8000623a:	9732                	add	a4,a4,a2
    8000623c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80006240:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80006244:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80006248:	953e                	add	a0,a0,a5
    8000624a:	4785                	li	a5,1
    8000624c:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80006250:	0001c517          	auipc	a0,0x1c
    80006254:	20850513          	addi	a0,a0,520 # 80022458 <disk+0x18>
    80006258:	ffffc097          	auipc	ra,0xffffc
    8000625c:	e60080e7          	jalr	-416(ra) # 800020b8 <wakeup>
}
    80006260:	60a2                	ld	ra,8(sp)
    80006262:	6402                	ld	s0,0(sp)
    80006264:	0141                	addi	sp,sp,16
    80006266:	8082                	ret
    panic("free_desc 1");
    80006268:	00002517          	auipc	a0,0x2
    8000626c:	4f050513          	addi	a0,a0,1264 # 80008758 <syscalls+0x308>
    80006270:	ffffa097          	auipc	ra,0xffffa
    80006274:	2ce080e7          	jalr	718(ra) # 8000053e <panic>
    panic("free_desc 2");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	4f050513          	addi	a0,a0,1264 # 80008768 <syscalls+0x318>
    80006280:	ffffa097          	auipc	ra,0xffffa
    80006284:	2be080e7          	jalr	702(ra) # 8000053e <panic>

0000000080006288 <virtio_disk_init>:
{
    80006288:	1101                	addi	sp,sp,-32
    8000628a:	ec06                	sd	ra,24(sp)
    8000628c:	e822                	sd	s0,16(sp)
    8000628e:	e426                	sd	s1,8(sp)
    80006290:	e04a                	sd	s2,0(sp)
    80006292:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006294:	00002597          	auipc	a1,0x2
    80006298:	4e458593          	addi	a1,a1,1252 # 80008778 <syscalls+0x328>
    8000629c:	0001c517          	auipc	a0,0x1c
    800062a0:	2cc50513          	addi	a0,a0,716 # 80022568 <disk+0x128>
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	8a2080e7          	jalr	-1886(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062ac:	100017b7          	lui	a5,0x10001
    800062b0:	4398                	lw	a4,0(a5)
    800062b2:	2701                	sext.w	a4,a4
    800062b4:	747277b7          	lui	a5,0x74727
    800062b8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800062bc:	14f71c63          	bne	a4,a5,80006414 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062c0:	100017b7          	lui	a5,0x10001
    800062c4:	43dc                	lw	a5,4(a5)
    800062c6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800062c8:	4709                	li	a4,2
    800062ca:	14e79563          	bne	a5,a4,80006414 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062ce:	100017b7          	lui	a5,0x10001
    800062d2:	479c                	lw	a5,8(a5)
    800062d4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800062d6:	12e79f63          	bne	a5,a4,80006414 <virtio_disk_init+0x18c>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800062da:	100017b7          	lui	a5,0x10001
    800062de:	47d8                	lw	a4,12(a5)
    800062e0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800062e2:	554d47b7          	lui	a5,0x554d4
    800062e6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800062ea:	12f71563          	bne	a4,a5,80006414 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ee:	100017b7          	lui	a5,0x10001
    800062f2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800062f6:	4705                	li	a4,1
    800062f8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062fa:	470d                	li	a4,3
    800062fc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800062fe:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006300:	c7ffe737          	lui	a4,0xc7ffe
    80006304:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc1df>
    80006308:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000630a:	2701                	sext.w	a4,a4
    8000630c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000630e:	472d                	li	a4,11
    80006310:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006312:	5bbc                	lw	a5,112(a5)
    80006314:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006318:	8ba1                	andi	a5,a5,8
    8000631a:	10078563          	beqz	a5,80006424 <virtio_disk_init+0x19c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000631e:	100017b7          	lui	a5,0x10001
    80006322:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006326:	43fc                	lw	a5,68(a5)
    80006328:	2781                	sext.w	a5,a5
    8000632a:	10079563          	bnez	a5,80006434 <virtio_disk_init+0x1ac>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000632e:	100017b7          	lui	a5,0x10001
    80006332:	5bdc                	lw	a5,52(a5)
    80006334:	2781                	sext.w	a5,a5
  if(max == 0)
    80006336:	10078763          	beqz	a5,80006444 <virtio_disk_init+0x1bc>
  if(max < NUM)
    8000633a:	471d                	li	a4,7
    8000633c:	10f77c63          	bgeu	a4,a5,80006454 <virtio_disk_init+0x1cc>
  disk.desc = kalloc();
    80006340:	ffffa097          	auipc	ra,0xffffa
    80006344:	7a6080e7          	jalr	1958(ra) # 80000ae6 <kalloc>
    80006348:	0001c497          	auipc	s1,0x1c
    8000634c:	0f848493          	addi	s1,s1,248 # 80022440 <disk>
    80006350:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006352:	ffffa097          	auipc	ra,0xffffa
    80006356:	794080e7          	jalr	1940(ra) # 80000ae6 <kalloc>
    8000635a:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000635c:	ffffa097          	auipc	ra,0xffffa
    80006360:	78a080e7          	jalr	1930(ra) # 80000ae6 <kalloc>
    80006364:	87aa                	mv	a5,a0
    80006366:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006368:	6088                	ld	a0,0(s1)
    8000636a:	cd6d                	beqz	a0,80006464 <virtio_disk_init+0x1dc>
    8000636c:	0001c717          	auipc	a4,0x1c
    80006370:	0dc73703          	ld	a4,220(a4) # 80022448 <disk+0x8>
    80006374:	cb65                	beqz	a4,80006464 <virtio_disk_init+0x1dc>
    80006376:	c7fd                	beqz	a5,80006464 <virtio_disk_init+0x1dc>
  memset(disk.desc, 0, PGSIZE);
    80006378:	6605                	lui	a2,0x1
    8000637a:	4581                	li	a1,0
    8000637c:	ffffb097          	auipc	ra,0xffffb
    80006380:	956080e7          	jalr	-1706(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006384:	0001c497          	auipc	s1,0x1c
    80006388:	0bc48493          	addi	s1,s1,188 # 80022440 <disk>
    8000638c:	6605                	lui	a2,0x1
    8000638e:	4581                	li	a1,0
    80006390:	6488                	ld	a0,8(s1)
    80006392:	ffffb097          	auipc	ra,0xffffb
    80006396:	940080e7          	jalr	-1728(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    8000639a:	6605                	lui	a2,0x1
    8000639c:	4581                	li	a1,0
    8000639e:	6888                	ld	a0,16(s1)
    800063a0:	ffffb097          	auipc	ra,0xffffb
    800063a4:	932080e7          	jalr	-1742(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800063a8:	100017b7          	lui	a5,0x10001
    800063ac:	4721                	li	a4,8
    800063ae:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800063b0:	4098                	lw	a4,0(s1)
    800063b2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800063b6:	40d8                	lw	a4,4(s1)
    800063b8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800063bc:	6498                	ld	a4,8(s1)
    800063be:	0007069b          	sext.w	a3,a4
    800063c2:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800063c6:	9701                	srai	a4,a4,0x20
    800063c8:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800063cc:	6898                	ld	a4,16(s1)
    800063ce:	0007069b          	sext.w	a3,a4
    800063d2:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800063d6:	9701                	srai	a4,a4,0x20
    800063d8:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800063dc:	4705                	li	a4,1
    800063de:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800063e0:	00e48c23          	sb	a4,24(s1)
    800063e4:	00e48ca3          	sb	a4,25(s1)
    800063e8:	00e48d23          	sb	a4,26(s1)
    800063ec:	00e48da3          	sb	a4,27(s1)
    800063f0:	00e48e23          	sb	a4,28(s1)
    800063f4:	00e48ea3          	sb	a4,29(s1)
    800063f8:	00e48f23          	sb	a4,30(s1)
    800063fc:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006400:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006404:	0727a823          	sw	s2,112(a5)
}
    80006408:	60e2                	ld	ra,24(sp)
    8000640a:	6442                	ld	s0,16(sp)
    8000640c:	64a2                	ld	s1,8(sp)
    8000640e:	6902                	ld	s2,0(sp)
    80006410:	6105                	addi	sp,sp,32
    80006412:	8082                	ret
    panic("could not find virtio disk");
    80006414:	00002517          	auipc	a0,0x2
    80006418:	37450513          	addi	a0,a0,884 # 80008788 <syscalls+0x338>
    8000641c:	ffffa097          	auipc	ra,0xffffa
    80006420:	122080e7          	jalr	290(ra) # 8000053e <panic>
    panic("virtio disk FEATURES_OK unset");
    80006424:	00002517          	auipc	a0,0x2
    80006428:	38450513          	addi	a0,a0,900 # 800087a8 <syscalls+0x358>
    8000642c:	ffffa097          	auipc	ra,0xffffa
    80006430:	112080e7          	jalr	274(ra) # 8000053e <panic>
    panic("virtio disk should not be ready");
    80006434:	00002517          	auipc	a0,0x2
    80006438:	39450513          	addi	a0,a0,916 # 800087c8 <syscalls+0x378>
    8000643c:	ffffa097          	auipc	ra,0xffffa
    80006440:	102080e7          	jalr	258(ra) # 8000053e <panic>
    panic("virtio disk has no queue 0");
    80006444:	00002517          	auipc	a0,0x2
    80006448:	3a450513          	addi	a0,a0,932 # 800087e8 <syscalls+0x398>
    8000644c:	ffffa097          	auipc	ra,0xffffa
    80006450:	0f2080e7          	jalr	242(ra) # 8000053e <panic>
    panic("virtio disk max queue too short");
    80006454:	00002517          	auipc	a0,0x2
    80006458:	3b450513          	addi	a0,a0,948 # 80008808 <syscalls+0x3b8>
    8000645c:	ffffa097          	auipc	ra,0xffffa
    80006460:	0e2080e7          	jalr	226(ra) # 8000053e <panic>
    panic("virtio disk kalloc");
    80006464:	00002517          	auipc	a0,0x2
    80006468:	3c450513          	addi	a0,a0,964 # 80008828 <syscalls+0x3d8>
    8000646c:	ffffa097          	auipc	ra,0xffffa
    80006470:	0d2080e7          	jalr	210(ra) # 8000053e <panic>

0000000080006474 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006474:	7119                	addi	sp,sp,-128
    80006476:	fc86                	sd	ra,120(sp)
    80006478:	f8a2                	sd	s0,112(sp)
    8000647a:	f4a6                	sd	s1,104(sp)
    8000647c:	f0ca                	sd	s2,96(sp)
    8000647e:	ecce                	sd	s3,88(sp)
    80006480:	e8d2                	sd	s4,80(sp)
    80006482:	e4d6                	sd	s5,72(sp)
    80006484:	e0da                	sd	s6,64(sp)
    80006486:	fc5e                	sd	s7,56(sp)
    80006488:	f862                	sd	s8,48(sp)
    8000648a:	f466                	sd	s9,40(sp)
    8000648c:	f06a                	sd	s10,32(sp)
    8000648e:	ec6e                	sd	s11,24(sp)
    80006490:	0100                	addi	s0,sp,128
    80006492:	8aaa                	mv	s5,a0
    80006494:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006496:	00c52d03          	lw	s10,12(a0)
    8000649a:	001d1d1b          	slliw	s10,s10,0x1
    8000649e:	1d02                	slli	s10,s10,0x20
    800064a0:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800064a4:	0001c517          	auipc	a0,0x1c
    800064a8:	0c450513          	addi	a0,a0,196 # 80022568 <disk+0x128>
    800064ac:	ffffa097          	auipc	ra,0xffffa
    800064b0:	72a080e7          	jalr	1834(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800064b4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800064b6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800064b8:	0001cb97          	auipc	s7,0x1c
    800064bc:	f88b8b93          	addi	s7,s7,-120 # 80022440 <disk>
  for(int i = 0; i < 3; i++){
    800064c0:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064c2:	0001cc97          	auipc	s9,0x1c
    800064c6:	0a6c8c93          	addi	s9,s9,166 # 80022568 <disk+0x128>
    800064ca:	a08d                	j	8000652c <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800064cc:	00fb8733          	add	a4,s7,a5
    800064d0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800064d4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800064d6:	0207c563          	bltz	a5,80006500 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800064da:	2905                	addiw	s2,s2,1
    800064dc:	0611                	addi	a2,a2,4
    800064de:	05690c63          	beq	s2,s6,80006536 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800064e2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800064e4:	0001c717          	auipc	a4,0x1c
    800064e8:	f5c70713          	addi	a4,a4,-164 # 80022440 <disk>
    800064ec:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800064ee:	01874683          	lbu	a3,24(a4)
    800064f2:	fee9                	bnez	a3,800064cc <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800064f4:	2785                	addiw	a5,a5,1
    800064f6:	0705                	addi	a4,a4,1
    800064f8:	fe979be3          	bne	a5,s1,800064ee <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800064fc:	57fd                	li	a5,-1
    800064fe:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006500:	01205d63          	blez	s2,8000651a <virtio_disk_rw+0xa6>
    80006504:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006506:	000a2503          	lw	a0,0(s4)
    8000650a:	00000097          	auipc	ra,0x0
    8000650e:	cfc080e7          	jalr	-772(ra) # 80006206 <free_desc>
      for(int j = 0; j < i; j++)
    80006512:	2d85                	addiw	s11,s11,1
    80006514:	0a11                	addi	s4,s4,4
    80006516:	ffb918e3          	bne	s2,s11,80006506 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000651a:	85e6                	mv	a1,s9
    8000651c:	0001c517          	auipc	a0,0x1c
    80006520:	f3c50513          	addi	a0,a0,-196 # 80022458 <disk+0x18>
    80006524:	ffffc097          	auipc	ra,0xffffc
    80006528:	b30080e7          	jalr	-1232(ra) # 80002054 <sleep>
  for(int i = 0; i < 3; i++){
    8000652c:	f8040a13          	addi	s4,s0,-128
{
    80006530:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006532:	894e                	mv	s2,s3
    80006534:	b77d                	j	800064e2 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006536:	f8042583          	lw	a1,-128(s0)
    8000653a:	00a58793          	addi	a5,a1,10
    8000653e:	0792                	slli	a5,a5,0x4

  if(write)
    80006540:	0001c617          	auipc	a2,0x1c
    80006544:	f0060613          	addi	a2,a2,-256 # 80022440 <disk>
    80006548:	00f60733          	add	a4,a2,a5
    8000654c:	018036b3          	snez	a3,s8
    80006550:	c714                	sw	a3,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006552:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006556:	01a73823          	sd	s10,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000655a:	f6078693          	addi	a3,a5,-160
    8000655e:	6218                	ld	a4,0(a2)
    80006560:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006562:	00878513          	addi	a0,a5,8
    80006566:	9532                	add	a0,a0,a2
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006568:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000656a:	6208                	ld	a0,0(a2)
    8000656c:	96aa                	add	a3,a3,a0
    8000656e:	4741                	li	a4,16
    80006570:	c698                	sw	a4,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006572:	4705                	li	a4,1
    80006574:	00e69623          	sh	a4,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80006578:	f8442703          	lw	a4,-124(s0)
    8000657c:	00e69723          	sh	a4,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006580:	0712                	slli	a4,a4,0x4
    80006582:	953a                	add	a0,a0,a4
    80006584:	058a8693          	addi	a3,s5,88
    80006588:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000658a:	6208                	ld	a0,0(a2)
    8000658c:	972a                	add	a4,a4,a0
    8000658e:	40000693          	li	a3,1024
    80006592:	c714                	sw	a3,8(a4)
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006594:	001c3c13          	seqz	s8,s8
    80006598:	0c06                	slli	s8,s8,0x1
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000659a:	001c6c13          	ori	s8,s8,1
    8000659e:	01871623          	sh	s8,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800065a2:	f8842603          	lw	a2,-120(s0)
    800065a6:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800065aa:	0001c697          	auipc	a3,0x1c
    800065ae:	e9668693          	addi	a3,a3,-362 # 80022440 <disk>
    800065b2:	00258713          	addi	a4,a1,2
    800065b6:	0712                	slli	a4,a4,0x4
    800065b8:	9736                	add	a4,a4,a3
    800065ba:	587d                	li	a6,-1
    800065bc:	01070823          	sb	a6,16(a4)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800065c0:	0612                	slli	a2,a2,0x4
    800065c2:	9532                	add	a0,a0,a2
    800065c4:	f9078793          	addi	a5,a5,-112
    800065c8:	97b6                	add	a5,a5,a3
    800065ca:	e11c                	sd	a5,0(a0)
  disk.desc[idx[2]].len = 1;
    800065cc:	629c                	ld	a5,0(a3)
    800065ce:	97b2                	add	a5,a5,a2
    800065d0:	4605                	li	a2,1
    800065d2:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800065d4:	4509                	li	a0,2
    800065d6:	00a79623          	sh	a0,12(a5)
  disk.desc[idx[2]].next = 0;
    800065da:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800065de:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800065e2:	01573423          	sd	s5,8(a4)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800065e6:	6698                	ld	a4,8(a3)
    800065e8:	00275783          	lhu	a5,2(a4)
    800065ec:	8b9d                	andi	a5,a5,7
    800065ee:	0786                	slli	a5,a5,0x1
    800065f0:	97ba                	add	a5,a5,a4
    800065f2:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    800065f6:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800065fa:	6698                	ld	a4,8(a3)
    800065fc:	00275783          	lhu	a5,2(a4)
    80006600:	2785                	addiw	a5,a5,1
    80006602:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006606:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000660a:	100017b7          	lui	a5,0x10001
    8000660e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006612:	004aa783          	lw	a5,4(s5)
    80006616:	02c79163          	bne	a5,a2,80006638 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    8000661a:	0001c917          	auipc	s2,0x1c
    8000661e:	f4e90913          	addi	s2,s2,-178 # 80022568 <disk+0x128>
  while(b->disk == 1) {
    80006622:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006624:	85ca                	mv	a1,s2
    80006626:	8556                	mv	a0,s5
    80006628:	ffffc097          	auipc	ra,0xffffc
    8000662c:	a2c080e7          	jalr	-1492(ra) # 80002054 <sleep>
  while(b->disk == 1) {
    80006630:	004aa783          	lw	a5,4(s5)
    80006634:	fe9788e3          	beq	a5,s1,80006624 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006638:	f8042903          	lw	s2,-128(s0)
    8000663c:	00290793          	addi	a5,s2,2
    80006640:	00479713          	slli	a4,a5,0x4
    80006644:	0001c797          	auipc	a5,0x1c
    80006648:	dfc78793          	addi	a5,a5,-516 # 80022440 <disk>
    8000664c:	97ba                	add	a5,a5,a4
    8000664e:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006652:	0001c997          	auipc	s3,0x1c
    80006656:	dee98993          	addi	s3,s3,-530 # 80022440 <disk>
    8000665a:	00491713          	slli	a4,s2,0x4
    8000665e:	0009b783          	ld	a5,0(s3)
    80006662:	97ba                	add	a5,a5,a4
    80006664:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006668:	854a                	mv	a0,s2
    8000666a:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000666e:	00000097          	auipc	ra,0x0
    80006672:	b98080e7          	jalr	-1128(ra) # 80006206 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006676:	8885                	andi	s1,s1,1
    80006678:	f0ed                	bnez	s1,8000665a <virtio_disk_rw+0x1e6>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000667a:	0001c517          	auipc	a0,0x1c
    8000667e:	eee50513          	addi	a0,a0,-274 # 80022568 <disk+0x128>
    80006682:	ffffa097          	auipc	ra,0xffffa
    80006686:	608080e7          	jalr	1544(ra) # 80000c8a <release>
}
    8000668a:	70e6                	ld	ra,120(sp)
    8000668c:	7446                	ld	s0,112(sp)
    8000668e:	74a6                	ld	s1,104(sp)
    80006690:	7906                	ld	s2,96(sp)
    80006692:	69e6                	ld	s3,88(sp)
    80006694:	6a46                	ld	s4,80(sp)
    80006696:	6aa6                	ld	s5,72(sp)
    80006698:	6b06                	ld	s6,64(sp)
    8000669a:	7be2                	ld	s7,56(sp)
    8000669c:	7c42                	ld	s8,48(sp)
    8000669e:	7ca2                	ld	s9,40(sp)
    800066a0:	7d02                	ld	s10,32(sp)
    800066a2:	6de2                	ld	s11,24(sp)
    800066a4:	6109                	addi	sp,sp,128
    800066a6:	8082                	ret

00000000800066a8 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800066a8:	1101                	addi	sp,sp,-32
    800066aa:	ec06                	sd	ra,24(sp)
    800066ac:	e822                	sd	s0,16(sp)
    800066ae:	e426                	sd	s1,8(sp)
    800066b0:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800066b2:	0001c497          	auipc	s1,0x1c
    800066b6:	d8e48493          	addi	s1,s1,-626 # 80022440 <disk>
    800066ba:	0001c517          	auipc	a0,0x1c
    800066be:	eae50513          	addi	a0,a0,-338 # 80022568 <disk+0x128>
    800066c2:	ffffa097          	auipc	ra,0xffffa
    800066c6:	514080e7          	jalr	1300(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800066ca:	10001737          	lui	a4,0x10001
    800066ce:	533c                	lw	a5,96(a4)
    800066d0:	8b8d                	andi	a5,a5,3
    800066d2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800066d4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800066d8:	689c                	ld	a5,16(s1)
    800066da:	0204d703          	lhu	a4,32(s1)
    800066de:	0027d783          	lhu	a5,2(a5)
    800066e2:	04f70863          	beq	a4,a5,80006732 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800066e6:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800066ea:	6898                	ld	a4,16(s1)
    800066ec:	0204d783          	lhu	a5,32(s1)
    800066f0:	8b9d                	andi	a5,a5,7
    800066f2:	078e                	slli	a5,a5,0x3
    800066f4:	97ba                	add	a5,a5,a4
    800066f6:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800066f8:	00278713          	addi	a4,a5,2
    800066fc:	0712                	slli	a4,a4,0x4
    800066fe:	9726                	add	a4,a4,s1
    80006700:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006704:	e721                	bnez	a4,8000674c <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006706:	0789                	addi	a5,a5,2
    80006708:	0792                	slli	a5,a5,0x4
    8000670a:	97a6                	add	a5,a5,s1
    8000670c:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000670e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006712:	ffffc097          	auipc	ra,0xffffc
    80006716:	9a6080e7          	jalr	-1626(ra) # 800020b8 <wakeup>

    disk.used_idx += 1;
    8000671a:	0204d783          	lhu	a5,32(s1)
    8000671e:	2785                	addiw	a5,a5,1
    80006720:	17c2                	slli	a5,a5,0x30
    80006722:	93c1                	srli	a5,a5,0x30
    80006724:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006728:	6898                	ld	a4,16(s1)
    8000672a:	00275703          	lhu	a4,2(a4)
    8000672e:	faf71ce3          	bne	a4,a5,800066e6 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006732:	0001c517          	auipc	a0,0x1c
    80006736:	e3650513          	addi	a0,a0,-458 # 80022568 <disk+0x128>
    8000673a:	ffffa097          	auipc	ra,0xffffa
    8000673e:	550080e7          	jalr	1360(ra) # 80000c8a <release>
}
    80006742:	60e2                	ld	ra,24(sp)
    80006744:	6442                	ld	s0,16(sp)
    80006746:	64a2                	ld	s1,8(sp)
    80006748:	6105                	addi	sp,sp,32
    8000674a:	8082                	ret
      panic("virtio_disk_intr status");
    8000674c:	00002517          	auipc	a0,0x2
    80006750:	0f450513          	addi	a0,a0,244 # 80008840 <syscalls+0x3f0>
    80006754:	ffffa097          	auipc	ra,0xffffa
    80006758:	dea080e7          	jalr	-534(ra) # 8000053e <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
