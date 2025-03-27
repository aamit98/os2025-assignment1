
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8a013103          	ld	sp,-1888(sp) # 800088a0 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000056:	8ae70713          	addi	a4,a4,-1874 # 80008900 <timer_scratch>
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
    80000068:	b4c78793          	addi	a5,a5,-1204 # 80005bb0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca8f>
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
    80000130:	386080e7          	jalr	902(ra) # 800024b2 <either_copyin>
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
    8000018e:	8b650513          	addi	a0,a0,-1866 # 80010a40 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8a648493          	addi	s1,s1,-1882 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	93690913          	addi	s2,s2,-1738 # 80010ad8 <cons+0x98>
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
    800001cc:	134080e7          	jalr	308(ra) # 800022fc <killed>
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
    80000216:	24a080e7          	jalr	586(ra) # 8000245c <either_copyout>
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
    8000022a:	81a50513          	addi	a0,a0,-2022 # 80010a40 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	80450513          	addi	a0,a0,-2044 # 80010a40 <cons>
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
    80000276:	86f72323          	sw	a5,-1946(a4) # 80010ad8 <cons+0x98>
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
    800002d0:	77450513          	addi	a0,a0,1908 # 80010a40 <cons>
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
    800002f6:	216080e7          	jalr	534(ra) # 80002508 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	74650513          	addi	a0,a0,1862 # 80010a40 <cons>
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
    80000322:	72270713          	addi	a4,a4,1826 # 80010a40 <cons>
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
    8000034c:	6f878793          	addi	a5,a5,1784 # 80010a40 <cons>
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
    8000037a:	7627a783          	lw	a5,1890(a5) # 80010ad8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6b670713          	addi	a4,a4,1718 # 80010a40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6a648493          	addi	s1,s1,1702 # 80010a40 <cons>
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
    800003da:	66a70713          	addi	a4,a4,1642 # 80010a40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72a23          	sw	a5,1780(a4) # 80010ae0 <cons+0xa0>
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
    80000416:	62e78793          	addi	a5,a5,1582 # 80010a40 <cons>
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
    8000043a:	6ac7a323          	sw	a2,1702(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	69a50513          	addi	a0,a0,1690 # 80010ad8 <cons+0x98>
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
    80000464:	5e050513          	addi	a0,a0,1504 # 80010a40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32a080e7          	jalr	810(ra) # 8000079a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	76078793          	addi	a5,a5,1888 # 80020bd8 <devsw>
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
    8000054e:	5a07ab23          	sw	zero,1462(a5) # 80010b00 <pr+0x18>
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
    80000582:	34f72123          	sw	a5,834(a4) # 800088c0 <panicked>
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
    800005be:	546dad83          	lw	s11,1350(s11) # 80010b00 <pr+0x18>
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
    800005fc:	4f050513          	addi	a0,a0,1264 # 80010ae8 <pr>
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
    8000075a:	39250513          	addi	a0,a0,914 # 80010ae8 <pr>
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
    80000776:	37648493          	addi	s1,s1,886 # 80010ae8 <pr>
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
    8000079a:	1141                	addi	sp,sp,-16
    8000079c:	e406                	sd	ra,8(sp)
    8000079e:	e022                	sd	s0,0(sp)
    800007a0:	0800                	addi	s0,sp,16
    800007a2:	100007b7          	lui	a5,0x10000
    800007a6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    800007aa:	f8000713          	li	a4,-128
    800007ae:	00e781a3          	sb	a4,3(a5)
    800007b2:	470d                	li	a4,3
    800007b4:	00e78023          	sb	a4,0(a5)
    800007b8:	000780a3          	sb	zero,1(a5)
    800007bc:	00e781a3          	sb	a4,3(a5)
    800007c0:	469d                	li	a3,7
    800007c2:	00d78123          	sb	a3,2(a5)
    800007c6:	00e780a3          	sb	a4,1(a5)
    800007ca:	00008597          	auipc	a1,0x8
    800007ce:	88e58593          	addi	a1,a1,-1906 # 80008058 <digits+0x18>
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	33650513          	addi	a0,a0,822 # 80010b08 <uart_tx_lock>
    800007da:	00000097          	auipc	ra,0x0
    800007de:	36c080e7          	jalr	876(ra) # 80000b46 <initlock>
    800007e2:	60a2                	ld	ra,8(sp)
    800007e4:	6402                	ld	s0,0(sp)
    800007e6:	0141                	addi	sp,sp,16
    800007e8:	8082                	ret

00000000800007ea <uartputc_sync>:
    800007ea:	1101                	addi	sp,sp,-32
    800007ec:	ec06                	sd	ra,24(sp)
    800007ee:	e822                	sd	s0,16(sp)
    800007f0:	e426                	sd	s1,8(sp)
    800007f2:	1000                	addi	s0,sp,32
    800007f4:	84aa                	mv	s1,a0
    800007f6:	00000097          	auipc	ra,0x0
    800007fa:	394080e7          	jalr	916(ra) # 80000b8a <push_off>
    800007fe:	00008797          	auipc	a5,0x8
    80000802:	0c27a783          	lw	a5,194(a5) # 800088c0 <panicked>
    80000806:	10000737          	lui	a4,0x10000
    8000080a:	c391                	beqz	a5,8000080e <uartputc_sync+0x24>
    8000080c:	a001                	j	8000080c <uartputc_sync+0x22>
    8000080e:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000812:	0207f793          	andi	a5,a5,32
    80000816:	dfe5                	beqz	a5,8000080e <uartputc_sync+0x24>
    80000818:	0ff4f513          	andi	a0,s1,255
    8000081c:	100007b7          	lui	a5,0x10000
    80000820:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000824:	00000097          	auipc	ra,0x0
    80000828:	406080e7          	jalr	1030(ra) # 80000c2a <pop_off>
    8000082c:	60e2                	ld	ra,24(sp)
    8000082e:	6442                	ld	s0,16(sp)
    80000830:	64a2                	ld	s1,8(sp)
    80000832:	6105                	addi	sp,sp,32
    80000834:	8082                	ret

0000000080000836 <uartstart>:
    80000836:	00008797          	auipc	a5,0x8
    8000083a:	0927b783          	ld	a5,146(a5) # 800088c8 <uart_tx_r>
    8000083e:	00008717          	auipc	a4,0x8
    80000842:	09273703          	ld	a4,146(a4) # 800088d0 <uart_tx_w>
    80000846:	06f70a63          	beq	a4,a5,800008ba <uartstart+0x84>
    8000084a:	7139                	addi	sp,sp,-64
    8000084c:	fc06                	sd	ra,56(sp)
    8000084e:	f822                	sd	s0,48(sp)
    80000850:	f426                	sd	s1,40(sp)
    80000852:	f04a                	sd	s2,32(sp)
    80000854:	ec4e                	sd	s3,24(sp)
    80000856:	e852                	sd	s4,16(sp)
    80000858:	e456                	sd	s5,8(sp)
    8000085a:	0080                	addi	s0,sp,64
    8000085c:	10000937          	lui	s2,0x10000
    80000860:	00010a17          	auipc	s4,0x10
    80000864:	2a8a0a13          	addi	s4,s4,680 # 80010b08 <uart_tx_lock>
    80000868:	00008497          	auipc	s1,0x8
    8000086c:	06048493          	addi	s1,s1,96 # 800088c8 <uart_tx_r>
    80000870:	00008997          	auipc	s3,0x8
    80000874:	06098993          	addi	s3,s3,96 # 800088d0 <uart_tx_w>
    80000878:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087c:	02077713          	andi	a4,a4,32
    80000880:	c705                	beqz	a4,800008a8 <uartstart+0x72>
    80000882:	01f7f713          	andi	a4,a5,31
    80000886:	9752                	add	a4,a4,s4
    80000888:	01874a83          	lbu	s5,24(a4)
    8000088c:	0785                	addi	a5,a5,1
    8000088e:	e09c                	sd	a5,0(s1)
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	826080e7          	jalr	-2010(ra) # 800020b8 <wakeup>
    8000089a:	01590023          	sb	s5,0(s2)
    8000089e:	609c                	ld	a5,0(s1)
    800008a0:	0009b703          	ld	a4,0(s3)
    800008a4:	fcf71ae3          	bne	a4,a5,80000878 <uartstart+0x42>
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
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	8a2a                	mv	s4,a0
    800008ce:	00010517          	auipc	a0,0x10
    800008d2:	23a50513          	addi	a0,a0,570 # 80010b08 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	300080e7          	jalr	768(ra) # 80000bd6 <acquire>
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	fe27a783          	lw	a5,-30(a5) # 800088c0 <panicked>
    800008e6:	e7c9                	bnez	a5,80000970 <uartputc+0xb4>
    800008e8:	00008717          	auipc	a4,0x8
    800008ec:	fe873703          	ld	a4,-24(a4) # 800088d0 <uart_tx_w>
    800008f0:	00008797          	auipc	a5,0x8
    800008f4:	fd87b783          	ld	a5,-40(a5) # 800088c8 <uart_tx_r>
    800008f8:	02078793          	addi	a5,a5,32
    800008fc:	00010997          	auipc	s3,0x10
    80000900:	20c98993          	addi	s3,s3,524 # 80010b08 <uart_tx_lock>
    80000904:	00008497          	auipc	s1,0x8
    80000908:	fc448493          	addi	s1,s1,-60 # 800088c8 <uart_tx_r>
    8000090c:	00008917          	auipc	s2,0x8
    80000910:	fc490913          	addi	s2,s2,-60 # 800088d0 <uart_tx_w>
    80000914:	00e79f63          	bne	a5,a4,80000932 <uartputc+0x76>
    80000918:	85ce                	mv	a1,s3
    8000091a:	8526                	mv	a0,s1
    8000091c:	00001097          	auipc	ra,0x1
    80000920:	738080e7          	jalr	1848(ra) # 80002054 <sleep>
    80000924:	00093703          	ld	a4,0(s2)
    80000928:	609c                	ld	a5,0(s1)
    8000092a:	02078793          	addi	a5,a5,32
    8000092e:	fee785e3          	beq	a5,a4,80000918 <uartputc+0x5c>
    80000932:	00010497          	auipc	s1,0x10
    80000936:	1d648493          	addi	s1,s1,470 # 80010b08 <uart_tx_lock>
    8000093a:	01f77793          	andi	a5,a4,31
    8000093e:	97a6                	add	a5,a5,s1
    80000940:	01478c23          	sb	s4,24(a5)
    80000944:	0705                	addi	a4,a4,1
    80000946:	00008797          	auipc	a5,0x8
    8000094a:	f8e7b523          	sd	a4,-118(a5) # 800088d0 <uart_tx_w>
    8000094e:	00000097          	auipc	ra,0x0
    80000952:	ee8080e7          	jalr	-280(ra) # 80000836 <uartstart>
    80000956:	8526                	mv	a0,s1
    80000958:	00000097          	auipc	ra,0x0
    8000095c:	332080e7          	jalr	818(ra) # 80000c8a <release>
    80000960:	70a2                	ld	ra,40(sp)
    80000962:	7402                	ld	s0,32(sp)
    80000964:	64e2                	ld	s1,24(sp)
    80000966:	6942                	ld	s2,16(sp)
    80000968:	69a2                	ld	s3,8(sp)
    8000096a:	6a02                	ld	s4,0(sp)
    8000096c:	6145                	addi	sp,sp,48
    8000096e:	8082                	ret
    80000970:	a001                	j	80000970 <uartputc+0xb4>

0000000080000972 <uartgetc>:
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb91                	beqz	a5,80000996 <uartgetc+0x24>
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000098c:	0ff57513          	andi	a0,a0,255
    80000990:	6422                	ld	s0,8(sp)
    80000992:	0141                	addi	sp,sp,16
    80000994:	8082                	ret
    80000996:	557d                	li	a0,-1
    80000998:	bfe5                	j	80000990 <uartgetc+0x1e>

000000008000099a <uartintr>:
    8000099a:	1101                	addi	sp,sp,-32
    8000099c:	ec06                	sd	ra,24(sp)
    8000099e:	e822                	sd	s0,16(sp)
    800009a0:	e426                	sd	s1,8(sp)
    800009a2:	1000                	addi	s0,sp,32
    800009a4:	54fd                	li	s1,-1
    800009a6:	a029                	j	800009b0 <uartintr+0x16>
    800009a8:	00000097          	auipc	ra,0x0
    800009ac:	916080e7          	jalr	-1770(ra) # 800002be <consoleintr>
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	fc2080e7          	jalr	-62(ra) # 80000972 <uartgetc>
    800009b8:	fe9518e3          	bne	a0,s1,800009a8 <uartintr+0xe>
    800009bc:	00010497          	auipc	s1,0x10
    800009c0:	14c48493          	addi	s1,s1,332 # 80010b08 <uart_tx_lock>
    800009c4:	8526                	mv	a0,s1
    800009c6:	00000097          	auipc	ra,0x0
    800009ca:	210080e7          	jalr	528(ra) # 80000bd6 <acquire>
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	e68080e7          	jalr	-408(ra) # 80000836 <uartstart>
    800009d6:	8526                	mv	a0,s1
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
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
    800009fe:	00021797          	auipc	a5,0x21
    80000a02:	37278793          	addi	a5,a5,882 # 80021d70 <end>
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
    80000a22:	12290913          	addi	s2,s2,290 # 80010b40 <kmem>
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
    80000abe:	08650513          	addi	a0,a0,134 # 80010b40 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	2a250513          	addi	a0,a0,674 # 80021d70 <end>
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
    80000af4:	05048493          	addi	s1,s1,80 # 80010b40 <kmem>
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
    80000b0c:	03850513          	addi	a0,a0,56 # 80010b40 <kmem>
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
    80000b38:	00c50513          	addi	a0,a0,12 # 80010b40 <kmem>
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
    80000e8c:	a5070713          	addi	a4,a4,-1456 # 800088d8 <started>
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
    80000ebe:	00001097          	auipc	ra,0x1
    80000ec2:	78a080e7          	jalr	1930(ra) # 80002648 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	d2a080e7          	jalr	-726(ra) # 80005bf0 <plicinithart>
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
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	6ea080e7          	jalr	1770(ra) # 80002620 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00001097          	auipc	ra,0x1
    80000f42:	70a080e7          	jalr	1802(ra) # 80002648 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	c94080e7          	jalr	-876(ra) # 80005bda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	ca2080e7          	jalr	-862(ra) # 80005bf0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	e48080e7          	jalr	-440(ra) # 80002d9e <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	4ec080e7          	jalr	1260(ra) # 8000344a <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	48a080e7          	jalr	1162(ra) # 800043f0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	d8a080e7          	jalr	-630(ra) # 80005cf8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d0e080e7          	jalr	-754(ra) # 80001c84 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	94f72a23          	sw	a5,-1708(a4) # 800088d8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
    80000f94:	12000073          	sfence.vma
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9487b783          	ld	a5,-1720(a5) # 800088e0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
    80000fa8:	18079073          	csrw	satp,a5
    80000fac:	12000073          	sfence.vma
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
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
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    80000fd6:	4b31                	li	s6,12
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55a080e7          	jalr	1370(ra) # 8000053e <panic>
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
    80001016:	3a5d                	addiw	s4,s4,-9
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
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
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    80001064:	4501                	li	a0,0
    80001066:	8082                	ret
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
    8000107c:	611c                	ld	a5,0(a0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    80001084:	4501                	li	a0,0
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
    80001092:	00a7d513          	srli	a0,a5,0xa
    80001096:	0532                	slli	a0,a0,0xc
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
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
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    800010ba:	77fd                	lui	a5,0xfffff
    800010bc:	00f5fa33          	and	s4,a1,a5
    800010c0:	15fd                	addi	a1,a1,-1
    800010c2:	00c589b3          	add	s3,a1,a2
    800010c6:	00f9f9b3          	and	s3,s3,a5
    800010ca:	8952                	mv	s2,s4
    800010cc:	41468a33          	sub	s4,a3,s4
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    800010fe:	995e                	add	s2,s2,s7
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	434080e7          	jalr	1076(ra) # 8000053e <panic>
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	424080e7          	jalr	1060(ra) # 8000053e <panic>
    80001122:	557d                	li	a0,-1
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
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3d8080e7          	jalr	984(ra) # 8000053e <panic>

000000008000116e <kvmmake>:
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
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
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
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
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7b623          	sd	a0,1676(a5) # 800088e0 <kernel_pagetable>
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
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
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    8000128c:	4b85                	li	s7,1
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
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
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28c080e7          	jalr	652(ra) # 8000053e <panic>
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27c080e7          	jalr	636(ra) # 8000053e <panic>
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26c080e7          	jalr	620(ra) # 8000053e <panic>
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25c080e7          	jalr	604(ra) # 8000053e <panic>
    800012ea:	0004b023          	sd	zero,0(s1)
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
    8000131a:	8129                	srli	a0,a0,0xa
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6cc080e7          	jalr	1740(ra) # 800009ea <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	17e080e7          	jalr	382(ra) # 8000053e <panic>

00000000800013c8 <uvmdealloc>:
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
    800013d2:	84ae                	mv	s1,a1
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	767d                	lui	a2,0xfffff
    800013e4:	8f71                	and	a4,a4,a2
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff1                	and	a5,a5,a2
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
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
    8000142c:	6985                	lui	s3,0x1
    8000142e:	19fd                	addi	s3,s3,-1
    80001430:	95ce                	add	a1,a1,s3
    80001432:	79fd                	lui	s3,0xfffff
    80001434:	0135f9b3          	and	s3,a1,s3
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    8000143e:	0126eb13          	ori	s6,a3,18
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
    80001488:	4501                	li	a0,0
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
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	54a080e7          	jalr	1354(ra) # 800009ea <kfree>
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    800014ba:	852e                	mv	a0,a1
    800014bc:	8082                	ret
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    800014da:	4985                	li	s3,1
    800014dc:	a821                	j	800014f4 <freewalk+0x32>
    800014de:	8129                	srli	a0,a0,0xa
    800014e0:	0532                	slli	a0,a0,0xc
    800014e2:	00000097          	auipc	ra,0x0
    800014e6:	fe0080e7          	jalr	-32(ra) # 800014c2 <freewalk>
    800014ea:	0004b023          	sd	zero,0(s1)
    800014ee:	04a1                	addi	s1,s1,8
    800014f0:	03248163          	beq	s1,s2,80001512 <freewalk+0x50>
    800014f4:	6088                	ld	a0,0(s1)
    800014f6:	00f57793          	andi	a5,a0,15
    800014fa:	ff3782e3          	beq	a5,s3,800014de <freewalk+0x1c>
    800014fe:	8905                	andi	a0,a0,1
    80001500:	d57d                	beqz	a0,800014ee <freewalk+0x2c>
    80001502:	00007517          	auipc	a0,0x7
    80001506:	c7650513          	addi	a0,a0,-906 # 80008178 <digits+0x138>
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	034080e7          	jalr	52(ra) # 8000053e <panic>
    80001512:	8552                	mv	a0,s4
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	4d6080e7          	jalr	1238(ra) # 800009ea <kfree>
    8000151c:	70a2                	ld	ra,40(sp)
    8000151e:	7402                	ld	s0,32(sp)
    80001520:	64e2                	ld	s1,24(sp)
    80001522:	6942                	ld	s2,16(sp)
    80001524:	69a2                	ld	s3,8(sp)
    80001526:	6a02                	ld	s4,0(sp)
    80001528:	6145                	addi	sp,sp,48
    8000152a:	8082                	ret

000000008000152c <uvmfree>:
    8000152c:	1101                	addi	sp,sp,-32
    8000152e:	ec06                	sd	ra,24(sp)
    80001530:	e822                	sd	s0,16(sp)
    80001532:	e426                	sd	s1,8(sp)
    80001534:	1000                	addi	s0,sp,32
    80001536:	84aa                	mv	s1,a0
    80001538:	e999                	bnez	a1,8000154e <uvmfree+0x22>
    8000153a:	8526                	mv	a0,s1
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	f86080e7          	jalr	-122(ra) # 800014c2 <freewalk>
    80001544:	60e2                	ld	ra,24(sp)
    80001546:	6442                	ld	s0,16(sp)
    80001548:	64a2                	ld	s1,8(sp)
    8000154a:	6105                	addi	sp,sp,32
    8000154c:	8082                	ret
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
    80001564:	c679                	beqz	a2,80001632 <uvmcopy+0xce>
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
    80001582:	4981                	li	s3,0
    80001584:	4601                	li	a2,0
    80001586:	85ce                	mv	a1,s3
    80001588:	855a                	mv	a0,s6
    8000158a:	00000097          	auipc	ra,0x0
    8000158e:	a2c080e7          	jalr	-1492(ra) # 80000fb6 <walk>
    80001592:	c531                	beqz	a0,800015de <uvmcopy+0x7a>
    80001594:	6118                	ld	a4,0(a0)
    80001596:	00177793          	andi	a5,a4,1
    8000159a:	cbb1                	beqz	a5,800015ee <uvmcopy+0x8a>
    8000159c:	00a75593          	srli	a1,a4,0xa
    800015a0:	00c59b93          	slli	s7,a1,0xc
    800015a4:	3ff77493          	andi	s1,a4,1023
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	53e080e7          	jalr	1342(ra) # 80000ae6 <kalloc>
    800015b0:	892a                	mv	s2,a0
    800015b2:	c939                	beqz	a0,80001608 <uvmcopy+0xa4>
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85de                	mv	a1,s7
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	776080e7          	jalr	1910(ra) # 80000d2e <memmove>
    800015c0:	8726                	mv	a4,s1
    800015c2:	86ca                	mv	a3,s2
    800015c4:	6605                	lui	a2,0x1
    800015c6:	85ce                	mv	a1,s3
    800015c8:	8556                	mv	a0,s5
    800015ca:	00000097          	auipc	ra,0x0
    800015ce:	ad4080e7          	jalr	-1324(ra) # 8000109e <mappages>
    800015d2:	e515                	bnez	a0,800015fe <uvmcopy+0x9a>
    800015d4:	6785                	lui	a5,0x1
    800015d6:	99be                	add	s3,s3,a5
    800015d8:	fb49e6e3          	bltu	s3,s4,80001584 <uvmcopy+0x20>
    800015dc:	a081                	j	8000161c <uvmcopy+0xb8>
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	baa50513          	addi	a0,a0,-1110 # 80008188 <digits+0x148>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f58080e7          	jalr	-168(ra) # 8000053e <panic>
    800015ee:	00007517          	auipc	a0,0x7
    800015f2:	bba50513          	addi	a0,a0,-1094 # 800081a8 <digits+0x168>
    800015f6:	fffff097          	auipc	ra,0xfffff
    800015fa:	f48080e7          	jalr	-184(ra) # 8000053e <panic>
    800015fe:	854a                	mv	a0,s2
    80001600:	fffff097          	auipc	ra,0xfffff
    80001604:	3ea080e7          	jalr	1002(ra) # 800009ea <kfree>
    80001608:	4685                	li	a3,1
    8000160a:	00c9d613          	srli	a2,s3,0xc
    8000160e:	4581                	li	a1,0
    80001610:	8556                	mv	a0,s5
    80001612:	00000097          	auipc	ra,0x0
    80001616:	c52080e7          	jalr	-942(ra) # 80001264 <uvmunmap>
    8000161a:	557d                	li	a0,-1
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
    80001632:	4501                	li	a0,0
    80001634:	8082                	ret

0000000080001636 <uvmclear>:
    80001636:	1141                	addi	sp,sp,-16
    80001638:	e406                	sd	ra,8(sp)
    8000163a:	e022                	sd	s0,0(sp)
    8000163c:	0800                	addi	s0,sp,16
    8000163e:	4601                	li	a2,0
    80001640:	00000097          	auipc	ra,0x0
    80001644:	976080e7          	jalr	-1674(ra) # 80000fb6 <walk>
    80001648:	c901                	beqz	a0,80001658 <uvmclear+0x22>
    8000164a:	611c                	ld	a5,0(a0)
    8000164c:	9bbd                	andi	a5,a5,-17
    8000164e:	e11c                	sd	a5,0(a0)
    80001650:	60a2                	ld	ra,8(sp)
    80001652:	6402                	ld	s0,0(sp)
    80001654:	0141                	addi	sp,sp,16
    80001656:	8082                	ret
    80001658:	00007517          	auipc	a0,0x7
    8000165c:	b7050513          	addi	a0,a0,-1168 # 800081c8 <digits+0x188>
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	ede080e7          	jalr	-290(ra) # 8000053e <panic>

0000000080001668 <copyout>:
    80001668:	c6bd                	beqz	a3,800016d6 <copyout+0x6e>
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
    8000168a:	7bfd                	lui	s7,0xfffff
    8000168c:	6a85                	lui	s5,0x1
    8000168e:	a015                	j	800016b2 <copyout+0x4a>
    80001690:	9562                	add	a0,a0,s8
    80001692:	0004861b          	sext.w	a2,s1
    80001696:	85d2                	mv	a1,s4
    80001698:	41250533          	sub	a0,a0,s2
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	692080e7          	jalr	1682(ra) # 80000d2e <memmove>
    800016a4:	409989b3          	sub	s3,s3,s1
    800016a8:	9a26                	add	s4,s4,s1
    800016aa:	01590c33          	add	s8,s2,s5
    800016ae:	02098263          	beqz	s3,800016d2 <copyout+0x6a>
    800016b2:	017c7933          	and	s2,s8,s7
    800016b6:	85ca                	mv	a1,s2
    800016b8:	855a                	mv	a0,s6
    800016ba:	00000097          	auipc	ra,0x0
    800016be:	9a2080e7          	jalr	-1630(ra) # 8000105c <walkaddr>
    800016c2:	cd01                	beqz	a0,800016da <copyout+0x72>
    800016c4:	418904b3          	sub	s1,s2,s8
    800016c8:	94d6                	add	s1,s1,s5
    800016ca:	fc99f3e3          	bgeu	s3,s1,80001690 <copyout+0x28>
    800016ce:	84ce                	mv	s1,s3
    800016d0:	b7c1                	j	80001690 <copyout+0x28>
    800016d2:	4501                	li	a0,0
    800016d4:	a021                	j	800016dc <copyout+0x74>
    800016d6:	4501                	li	a0,0
    800016d8:	8082                	ret
    800016da:	557d                	li	a0,-1
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
    800016f4:	caa5                	beqz	a3,80001764 <copyin+0x70>
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
    80001716:	7bfd                	lui	s7,0xfffff
    80001718:	6a85                	lui	s5,0x1
    8000171a:	a01d                	j	80001740 <copyin+0x4c>
    8000171c:	018505b3          	add	a1,a0,s8
    80001720:	0004861b          	sext.w	a2,s1
    80001724:	412585b3          	sub	a1,a1,s2
    80001728:	8552                	mv	a0,s4
    8000172a:	fffff097          	auipc	ra,0xfffff
    8000172e:	604080e7          	jalr	1540(ra) # 80000d2e <memmove>
    80001732:	409989b3          	sub	s3,s3,s1
    80001736:	9a26                	add	s4,s4,s1
    80001738:	01590c33          	add	s8,s2,s5
    8000173c:	02098263          	beqz	s3,80001760 <copyin+0x6c>
    80001740:	017c7933          	and	s2,s8,s7
    80001744:	85ca                	mv	a1,s2
    80001746:	855a                	mv	a0,s6
    80001748:	00000097          	auipc	ra,0x0
    8000174c:	914080e7          	jalr	-1772(ra) # 8000105c <walkaddr>
    80001750:	cd01                	beqz	a0,80001768 <copyin+0x74>
    80001752:	418904b3          	sub	s1,s2,s8
    80001756:	94d6                	add	s1,s1,s5
    80001758:	fc99f2e3          	bgeu	s3,s1,8000171c <copyin+0x28>
    8000175c:	84ce                	mv	s1,s3
    8000175e:	bf7d                	j	8000171c <copyin+0x28>
    80001760:	4501                	li	a0,0
    80001762:	a021                	j	8000176a <copyin+0x76>
    80001764:	4501                	li	a0,0
    80001766:	8082                	ret
    80001768:	557d                	li	a0,-1
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
    80001782:	c6c5                	beqz	a3,8000182a <copyinstr+0xa8>
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
    800017a2:	7afd                	lui	s5,0xfffff
    800017a4:	6985                	lui	s3,0x1
    800017a6:	a035                	j	800017d2 <copyinstr+0x50>
    800017a8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ac:	4785                	li	a5,1
    800017ae:	0017b793          	seqz	a5,a5
    800017b2:	40f00533          	neg	a0,a5
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
    800017cc:	01390bb3          	add	s7,s2,s3
    800017d0:	c8a9                	beqz	s1,80001822 <copyinstr+0xa0>
    800017d2:	015bf933          	and	s2,s7,s5
    800017d6:	85ca                	mv	a1,s2
    800017d8:	8552                	mv	a0,s4
    800017da:	00000097          	auipc	ra,0x0
    800017de:	882080e7          	jalr	-1918(ra) # 8000105c <walkaddr>
    800017e2:	c131                	beqz	a0,80001826 <copyinstr+0xa4>
    800017e4:	41790833          	sub	a6,s2,s7
    800017e8:	984e                	add	a6,a6,s3
    800017ea:	0104f363          	bgeu	s1,a6,800017f0 <copyinstr+0x6e>
    800017ee:	8826                	mv	a6,s1
    800017f0:	955e                	add	a0,a0,s7
    800017f2:	41250533          	sub	a0,a0,s2
    800017f6:	fc080be3          	beqz	a6,800017cc <copyinstr+0x4a>
    800017fa:	985a                	add	a6,a6,s6
    800017fc:	87da                	mv	a5,s6
    800017fe:	41650633          	sub	a2,a0,s6
    80001802:	14fd                	addi	s1,s1,-1
    80001804:	9b26                	add	s6,s6,s1
    80001806:	00f60733          	add	a4,a2,a5
    8000180a:	00074703          	lbu	a4,0(a4)
    8000180e:	df49                	beqz	a4,800017a8 <copyinstr+0x26>
    80001810:	00e78023          	sb	a4,0(a5)
    80001814:	40fb04b3          	sub	s1,s6,a5
    80001818:	0785                	addi	a5,a5,1
    8000181a:	ff0796e3          	bne	a5,a6,80001806 <copyinstr+0x84>
    8000181e:	8b42                	mv	s6,a6
    80001820:	b775                	j	800017cc <copyinstr+0x4a>
    80001822:	4781                	li	a5,0
    80001824:	b769                	j	800017ae <copyinstr+0x2c>
    80001826:	557d                	li	a0,-1
    80001828:	b779                	j	800017b6 <copyinstr+0x34>
    8000182a:	4781                	li	a5,0
    8000182c:	0017b793          	seqz	a5,a5
    80001830:	40f00533          	neg	a0,a5
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
    80001850:	74448493          	addi	s1,s1,1860 # 80010f90 <proc>
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
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	12aa0a13          	addi	s4,s4,298 # 80016990 <tickslock>
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
    800018a0:	16848493          	addi	s1,s1,360
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
    800018ec:	27850513          	addi	a0,a0,632 # 80010b60 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	27850513          	addi	a0,a0,632 # 80010b78 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	68048493          	addi	s1,s1,1664 # 80010f90 <proc>
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
    80001932:	00015997          	auipc	s3,0x15
    80001936:	05e98993          	addi	s3,s3,94 # 80016990 <tickslock>
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
    80001964:	16848493          	addi	s1,s1,360
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
    800019a0:	1f450513          	addi	a0,a0,500 # 80010b90 <cpus>
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
    800019c8:	19c70713          	addi	a4,a4,412 # 80010b60 <pid_lock>
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
    80001a00:	e547a783          	lw	a5,-428(a5) # 80008850 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	c5a080e7          	jalr	-934(ra) # 80002660 <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e207ad23          	sw	zero,-454(a5) # 80008850 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	9aa080e7          	jalr	-1622(ra) # 800033ca <fsinit>
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
    80001a3a:	12a90913          	addi	s2,s2,298 # 80010b60 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e0c78793          	addi	a5,a5,-500 # 80008854 <nextpid>
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
    80001bc6:	3ce48493          	addi	s1,s1,974 # 80010f90 <proc>
    80001bca:	00015917          	auipc	s2,0x15
    80001bce:	dc690913          	addi	s2,s2,-570 # 80016990 <tickslock>
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
    80001bea:	16848493          	addi	s1,s1,360
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
    80001c9c:	c4a7b823          	sd	a0,-944(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ca0:	03400613          	li	a2,52
    80001ca4:	00007597          	auipc	a1,0x7
    80001ca8:	bbc58593          	addi	a1,a1,-1092 # 80008860 <initcode>
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
    80001ce6:	10a080e7          	jalr	266(ra) # 80003dec <namei>
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
    80001e12:	00002097          	auipc	ra,0x2
    80001e16:	670080e7          	jalr	1648(ra) # 80004482 <filedup>
    80001e1a:	00a93023          	sd	a0,0(s2)
    80001e1e:	b7e5                	j	80001e06 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e20:	150ab503          	ld	a0,336(s5)
    80001e24:	00001097          	auipc	ra,0x1
    80001e28:	7e4080e7          	jalr	2020(ra) # 80003608 <idup>
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
    80001e54:	d2848493          	addi	s1,s1,-728 # 80010b78 <wait_lock>
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
    80001ec2:	ca270713          	addi	a4,a4,-862 # 80010b60 <pid_lock>
    80001ec6:	9756                	add	a4,a4,s5
    80001ec8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ecc:	0000f717          	auipc	a4,0xf
    80001ed0:	ccc70713          	addi	a4,a4,-820 # 80010b98 <cpus+0x8>
    80001ed4:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed6:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed8:	4b11                	li	s6,4
        c->proc = p;
    80001eda:	079e                	slli	a5,a5,0x7
    80001edc:	0000fa17          	auipc	s4,0xf
    80001ee0:	c84a0a13          	addi	s4,s4,-892 # 80010b60 <pid_lock>
    80001ee4:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee6:	00015917          	auipc	s2,0x15
    80001eea:	aaa90913          	addi	s2,s2,-1366 # 80016990 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ef2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef6:	10079073          	csrw	sstatus,a5
    80001efa:	0000f497          	auipc	s1,0xf
    80001efe:	09648493          	addi	s1,s1,150 # 80010f90 <proc>
    80001f02:	a811                	j	80001f16 <scheduler+0x74>
      release(&p->lock);
    80001f04:	8526                	mv	a0,s1
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	d84080e7          	jalr	-636(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f0e:	16848493          	addi	s1,s1,360
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
    80001f34:	00000097          	auipc	ra,0x0
    80001f38:	682080e7          	jalr	1666(ra) # 800025b6 <swtch>
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
    80001f6e:	bf670713          	addi	a4,a4,-1034 # 80010b60 <pid_lock>
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
    80001f94:	bd090913          	addi	s2,s2,-1072 # 80010b60 <pid_lock>
    80001f98:	2781                	sext.w	a5,a5
    80001f9a:	079e                	slli	a5,a5,0x7
    80001f9c:	97ca                	add	a5,a5,s2
    80001f9e:	0ac7a983          	lw	s3,172(a5)
    80001fa2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001fa4:	2781                	sext.w	a5,a5
    80001fa6:	079e                	slli	a5,a5,0x7
    80001fa8:	0000f597          	auipc	a1,0xf
    80001fac:	bf058593          	addi	a1,a1,-1040 # 80010b98 <cpus+0x8>
    80001fb0:	95be                	add	a1,a1,a5
    80001fb2:	06048513          	addi	a0,s1,96
    80001fb6:	00000097          	auipc	ra,0x0
    80001fba:	600080e7          	jalr	1536(ra) # 800025b6 <swtch>
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
    800020d0:	ec448493          	addi	s1,s1,-316 # 80010f90 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020d4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d6:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d8:	00015917          	auipc	s2,0x15
    800020dc:	8b890913          	addi	s2,s2,-1864 # 80016990 <tickslock>
    800020e0:	a811                	j	800020f4 <wakeup+0x3c>
      }
      release(&p->lock);
    800020e2:	8526                	mv	a0,s1
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	ba6080e7          	jalr	-1114(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ec:	16848493          	addi	s1,s1,360
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
    80002144:	e5048493          	addi	s1,s1,-432 # 80010f90 <proc>
      pp->parent = initproc;
    80002148:	00006a17          	auipc	s4,0x6
    8000214c:	7a0a0a13          	addi	s4,s4,1952 # 800088e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002150:	00015997          	auipc	s3,0x15
    80002154:	84098993          	addi	s3,s3,-1984 # 80016990 <tickslock>
    80002158:	a029                	j	80002162 <reparent+0x34>
    8000215a:	16848493          	addi	s1,s1,360
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
    80002188:	7179                	addi	sp,sp,-48
    8000218a:	f406                	sd	ra,40(sp)
    8000218c:	f022                	sd	s0,32(sp)
    8000218e:	ec26                	sd	s1,24(sp)
    80002190:	e84a                	sd	s2,16(sp)
    80002192:	e44e                	sd	s3,8(sp)
    80002194:	e052                	sd	s4,0(sp)
    80002196:	1800                	addi	s0,sp,48
    80002198:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000219a:	00000097          	auipc	ra,0x0
    8000219e:	812080e7          	jalr	-2030(ra) # 800019ac <myproc>
    800021a2:	89aa                	mv	s3,a0
  if(p == initproc)
    800021a4:	00006797          	auipc	a5,0x6
    800021a8:	7447b783          	ld	a5,1860(a5) # 800088e8 <initproc>
    800021ac:	0d050493          	addi	s1,a0,208
    800021b0:	15050913          	addi	s2,a0,336
    800021b4:	02a79363          	bne	a5,a0,800021da <exit+0x52>
    panic("init exiting");
    800021b8:	00006517          	auipc	a0,0x6
    800021bc:	0a850513          	addi	a0,a0,168 # 80008260 <digits+0x220>
    800021c0:	ffffe097          	auipc	ra,0xffffe
    800021c4:	37e080e7          	jalr	894(ra) # 8000053e <panic>
      fileclose(f);
    800021c8:	00002097          	auipc	ra,0x2
    800021cc:	30c080e7          	jalr	780(ra) # 800044d4 <fileclose>
      p->ofile[fd] = 0;
    800021d0:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021d4:	04a1                	addi	s1,s1,8
    800021d6:	01248563          	beq	s1,s2,800021e0 <exit+0x58>
    if(p->ofile[fd]){
    800021da:	6088                	ld	a0,0(s1)
    800021dc:	f575                	bnez	a0,800021c8 <exit+0x40>
    800021de:	bfdd                	j	800021d4 <exit+0x4c>
  begin_op();
    800021e0:	00002097          	auipc	ra,0x2
    800021e4:	e28080e7          	jalr	-472(ra) # 80004008 <begin_op>
  iput(p->cwd);
    800021e8:	1509b503          	ld	a0,336(s3)
    800021ec:	00001097          	auipc	ra,0x1
    800021f0:	614080e7          	jalr	1556(ra) # 80003800 <iput>
  end_op();
    800021f4:	00002097          	auipc	ra,0x2
    800021f8:	e94080e7          	jalr	-364(ra) # 80004088 <end_op>
  p->cwd = 0;
    800021fc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002200:	0000f497          	auipc	s1,0xf
    80002204:	97848493          	addi	s1,s1,-1672 # 80010b78 <wait_lock>
    80002208:	8526                	mv	a0,s1
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	9cc080e7          	jalr	-1588(ra) # 80000bd6 <acquire>
  reparent(p);
    80002212:	854e                	mv	a0,s3
    80002214:	00000097          	auipc	ra,0x0
    80002218:	f1a080e7          	jalr	-230(ra) # 8000212e <reparent>
  wakeup(p->parent);
    8000221c:	0389b503          	ld	a0,56(s3)
    80002220:	00000097          	auipc	ra,0x0
    80002224:	e98080e7          	jalr	-360(ra) # 800020b8 <wakeup>
  acquire(&p->lock);
    80002228:	854e                	mv	a0,s3
    8000222a:	fffff097          	auipc	ra,0xfffff
    8000222e:	9ac080e7          	jalr	-1620(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002232:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002236:	4795                	li	a5,5
    80002238:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000223c:	8526                	mv	a0,s1
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	a4c080e7          	jalr	-1460(ra) # 80000c8a <release>
  sched();
    80002246:	00000097          	auipc	ra,0x0
    8000224a:	cfc080e7          	jalr	-772(ra) # 80001f42 <sched>
  panic("zombie exit");
    8000224e:	00006517          	auipc	a0,0x6
    80002252:	02250513          	addi	a0,a0,34 # 80008270 <digits+0x230>
    80002256:	ffffe097          	auipc	ra,0xffffe
    8000225a:	2e8080e7          	jalr	744(ra) # 8000053e <panic>

000000008000225e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000225e:	7179                	addi	sp,sp,-48
    80002260:	f406                	sd	ra,40(sp)
    80002262:	f022                	sd	s0,32(sp)
    80002264:	ec26                	sd	s1,24(sp)
    80002266:	e84a                	sd	s2,16(sp)
    80002268:	e44e                	sd	s3,8(sp)
    8000226a:	1800                	addi	s0,sp,48
    8000226c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000226e:	0000f497          	auipc	s1,0xf
    80002272:	d2248493          	addi	s1,s1,-734 # 80010f90 <proc>
    80002276:	00014997          	auipc	s3,0x14
    8000227a:	71a98993          	addi	s3,s3,1818 # 80016990 <tickslock>
    acquire(&p->lock);
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	956080e7          	jalr	-1706(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    80002288:	589c                	lw	a5,48(s1)
    8000228a:	01278d63          	beq	a5,s2,800022a4 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000228e:	8526                	mv	a0,s1
    80002290:	fffff097          	auipc	ra,0xfffff
    80002294:	9fa080e7          	jalr	-1542(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002298:	16848493          	addi	s1,s1,360
    8000229c:	ff3491e3          	bne	s1,s3,8000227e <kill+0x20>
  }
  return -1;
    800022a0:	557d                	li	a0,-1
    800022a2:	a829                	j	800022bc <kill+0x5e>
      p->killed = 1;
    800022a4:	4785                	li	a5,1
    800022a6:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022a8:	4c98                	lw	a4,24(s1)
    800022aa:	4789                	li	a5,2
    800022ac:	00f70f63          	beq	a4,a5,800022ca <kill+0x6c>
      release(&p->lock);
    800022b0:	8526                	mv	a0,s1
    800022b2:	fffff097          	auipc	ra,0xfffff
    800022b6:	9d8080e7          	jalr	-1576(ra) # 80000c8a <release>
      return 0;
    800022ba:	4501                	li	a0,0
}
    800022bc:	70a2                	ld	ra,40(sp)
    800022be:	7402                	ld	s0,32(sp)
    800022c0:	64e2                	ld	s1,24(sp)
    800022c2:	6942                	ld	s2,16(sp)
    800022c4:	69a2                	ld	s3,8(sp)
    800022c6:	6145                	addi	sp,sp,48
    800022c8:	8082                	ret
        p->state = RUNNABLE;
    800022ca:	478d                	li	a5,3
    800022cc:	cc9c                	sw	a5,24(s1)
    800022ce:	b7cd                	j	800022b0 <kill+0x52>

00000000800022d0 <setkilled>:

void
setkilled(struct proc *p)
{
    800022d0:	1101                	addi	sp,sp,-32
    800022d2:	ec06                	sd	ra,24(sp)
    800022d4:	e822                	sd	s0,16(sp)
    800022d6:	e426                	sd	s1,8(sp)
    800022d8:	1000                	addi	s0,sp,32
    800022da:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	8fa080e7          	jalr	-1798(ra) # 80000bd6 <acquire>
  p->killed = 1;
    800022e4:	4785                	li	a5,1
    800022e6:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	9a0080e7          	jalr	-1632(ra) # 80000c8a <release>
}
    800022f2:	60e2                	ld	ra,24(sp)
    800022f4:	6442                	ld	s0,16(sp)
    800022f6:	64a2                	ld	s1,8(sp)
    800022f8:	6105                	addi	sp,sp,32
    800022fa:	8082                	ret

00000000800022fc <killed>:

int
killed(struct proc *p)
{
    800022fc:	1101                	addi	sp,sp,-32
    800022fe:	ec06                	sd	ra,24(sp)
    80002300:	e822                	sd	s0,16(sp)
    80002302:	e426                	sd	s1,8(sp)
    80002304:	e04a                	sd	s2,0(sp)
    80002306:	1000                	addi	s0,sp,32
    80002308:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000230a:	fffff097          	auipc	ra,0xfffff
    8000230e:	8cc080e7          	jalr	-1844(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002312:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002316:	8526                	mv	a0,s1
    80002318:	fffff097          	auipc	ra,0xfffff
    8000231c:	972080e7          	jalr	-1678(ra) # 80000c8a <release>
  return k;
}
    80002320:	854a                	mv	a0,s2
    80002322:	60e2                	ld	ra,24(sp)
    80002324:	6442                	ld	s0,16(sp)
    80002326:	64a2                	ld	s1,8(sp)
    80002328:	6902                	ld	s2,0(sp)
    8000232a:	6105                	addi	sp,sp,32
    8000232c:	8082                	ret

000000008000232e <wait>:
{
    8000232e:	715d                	addi	sp,sp,-80
    80002330:	e486                	sd	ra,72(sp)
    80002332:	e0a2                	sd	s0,64(sp)
    80002334:	fc26                	sd	s1,56(sp)
    80002336:	f84a                	sd	s2,48(sp)
    80002338:	f44e                	sd	s3,40(sp)
    8000233a:	f052                	sd	s4,32(sp)
    8000233c:	ec56                	sd	s5,24(sp)
    8000233e:	e85a                	sd	s6,16(sp)
    80002340:	e45e                	sd	s7,8(sp)
    80002342:	e062                	sd	s8,0(sp)
    80002344:	0880                	addi	s0,sp,80
    80002346:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002348:	fffff097          	auipc	ra,0xfffff
    8000234c:	664080e7          	jalr	1636(ra) # 800019ac <myproc>
    80002350:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002352:	0000f517          	auipc	a0,0xf
    80002356:	82650513          	addi	a0,a0,-2010 # 80010b78 <wait_lock>
    8000235a:	fffff097          	auipc	ra,0xfffff
    8000235e:	87c080e7          	jalr	-1924(ra) # 80000bd6 <acquire>
    havekids = 0;
    80002362:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002364:	4a15                	li	s4,5
        havekids = 1;
    80002366:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002368:	00014997          	auipc	s3,0x14
    8000236c:	62898993          	addi	s3,s3,1576 # 80016990 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002370:	0000fc17          	auipc	s8,0xf
    80002374:	808c0c13          	addi	s8,s8,-2040 # 80010b78 <wait_lock>
    havekids = 0;
    80002378:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000237a:	0000f497          	auipc	s1,0xf
    8000237e:	c1648493          	addi	s1,s1,-1002 # 80010f90 <proc>
    80002382:	a0bd                	j	800023f0 <wait+0xc2>
          pid = pp->pid;
    80002384:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002388:	000b0e63          	beqz	s6,800023a4 <wait+0x76>
    8000238c:	4691                	li	a3,4
    8000238e:	02c48613          	addi	a2,s1,44
    80002392:	85da                	mv	a1,s6
    80002394:	05093503          	ld	a0,80(s2)
    80002398:	fffff097          	auipc	ra,0xfffff
    8000239c:	2d0080e7          	jalr	720(ra) # 80001668 <copyout>
    800023a0:	02054563          	bltz	a0,800023ca <wait+0x9c>
          freeproc(pp);
    800023a4:	8526                	mv	a0,s1
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	7b8080e7          	jalr	1976(ra) # 80001b5e <freeproc>
          release(&pp->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8da080e7          	jalr	-1830(ra) # 80000c8a <release>
          release(&wait_lock);
    800023b8:	0000e517          	auipc	a0,0xe
    800023bc:	7c050513          	addi	a0,a0,1984 # 80010b78 <wait_lock>
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	8ca080e7          	jalr	-1846(ra) # 80000c8a <release>
          return pid;
    800023c8:	a0b5                	j	80002434 <wait+0x106>
            release(&pp->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8be080e7          	jalr	-1858(ra) # 80000c8a <release>
            release(&wait_lock);
    800023d4:	0000e517          	auipc	a0,0xe
    800023d8:	7a450513          	addi	a0,a0,1956 # 80010b78 <wait_lock>
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
            return -1;
    800023e4:	59fd                	li	s3,-1
    800023e6:	a0b9                	j	80002434 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023e8:	16848493          	addi	s1,s1,360
    800023ec:	03348463          	beq	s1,s3,80002414 <wait+0xe6>
      if(pp->parent == p){
    800023f0:	7c9c                	ld	a5,56(s1)
    800023f2:	ff279be3          	bne	a5,s2,800023e8 <wait+0xba>
        acquire(&pp->lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	ffffe097          	auipc	ra,0xffffe
    800023fc:	7de080e7          	jalr	2014(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002400:	4c9c                	lw	a5,24(s1)
    80002402:	f94781e3          	beq	a5,s4,80002384 <wait+0x56>
        release(&pp->lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	882080e7          	jalr	-1918(ra) # 80000c8a <release>
        havekids = 1;
    80002410:	8756                	mv	a4,s5
    80002412:	bfd9                	j	800023e8 <wait+0xba>
    if(!havekids || killed(p)){
    80002414:	c719                	beqz	a4,80002422 <wait+0xf4>
    80002416:	854a                	mv	a0,s2
    80002418:	00000097          	auipc	ra,0x0
    8000241c:	ee4080e7          	jalr	-284(ra) # 800022fc <killed>
    80002420:	c51d                	beqz	a0,8000244e <wait+0x120>
      release(&wait_lock);
    80002422:	0000e517          	auipc	a0,0xe
    80002426:	75650513          	addi	a0,a0,1878 # 80010b78 <wait_lock>
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	860080e7          	jalr	-1952(ra) # 80000c8a <release>
      return -1;
    80002432:	59fd                	li	s3,-1
}
    80002434:	854e                	mv	a0,s3
    80002436:	60a6                	ld	ra,72(sp)
    80002438:	6406                	ld	s0,64(sp)
    8000243a:	74e2                	ld	s1,56(sp)
    8000243c:	7942                	ld	s2,48(sp)
    8000243e:	79a2                	ld	s3,40(sp)
    80002440:	7a02                	ld	s4,32(sp)
    80002442:	6ae2                	ld	s5,24(sp)
    80002444:	6b42                	ld	s6,16(sp)
    80002446:	6ba2                	ld	s7,8(sp)
    80002448:	6c02                	ld	s8,0(sp)
    8000244a:	6161                	addi	sp,sp,80
    8000244c:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000244e:	85e2                	mv	a1,s8
    80002450:	854a                	mv	a0,s2
    80002452:	00000097          	auipc	ra,0x0
    80002456:	c02080e7          	jalr	-1022(ra) # 80002054 <sleep>
    havekids = 0;
    8000245a:	bf39                	j	80002378 <wait+0x4a>

000000008000245c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000245c:	7179                	addi	sp,sp,-48
    8000245e:	f406                	sd	ra,40(sp)
    80002460:	f022                	sd	s0,32(sp)
    80002462:	ec26                	sd	s1,24(sp)
    80002464:	e84a                	sd	s2,16(sp)
    80002466:	e44e                	sd	s3,8(sp)
    80002468:	e052                	sd	s4,0(sp)
    8000246a:	1800                	addi	s0,sp,48
    8000246c:	84aa                	mv	s1,a0
    8000246e:	892e                	mv	s2,a1
    80002470:	89b2                	mv	s3,a2
    80002472:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	538080e7          	jalr	1336(ra) # 800019ac <myproc>
  if(user_dst){
    8000247c:	c08d                	beqz	s1,8000249e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000247e:	86d2                	mv	a3,s4
    80002480:	864e                	mv	a2,s3
    80002482:	85ca                	mv	a1,s2
    80002484:	6928                	ld	a0,80(a0)
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	1e2080e7          	jalr	482(ra) # 80001668 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000248e:	70a2                	ld	ra,40(sp)
    80002490:	7402                	ld	s0,32(sp)
    80002492:	64e2                	ld	s1,24(sp)
    80002494:	6942                	ld	s2,16(sp)
    80002496:	69a2                	ld	s3,8(sp)
    80002498:	6a02                	ld	s4,0(sp)
    8000249a:	6145                	addi	sp,sp,48
    8000249c:	8082                	ret
    memmove((char *)dst, src, len);
    8000249e:	000a061b          	sext.w	a2,s4
    800024a2:	85ce                	mv	a1,s3
    800024a4:	854a                	mv	a0,s2
    800024a6:	fffff097          	auipc	ra,0xfffff
    800024aa:	888080e7          	jalr	-1912(ra) # 80000d2e <memmove>
    return 0;
    800024ae:	8526                	mv	a0,s1
    800024b0:	bff9                	j	8000248e <either_copyout+0x32>

00000000800024b2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024b2:	7179                	addi	sp,sp,-48
    800024b4:	f406                	sd	ra,40(sp)
    800024b6:	f022                	sd	s0,32(sp)
    800024b8:	ec26                	sd	s1,24(sp)
    800024ba:	e84a                	sd	s2,16(sp)
    800024bc:	e44e                	sd	s3,8(sp)
    800024be:	e052                	sd	s4,0(sp)
    800024c0:	1800                	addi	s0,sp,48
    800024c2:	892a                	mv	s2,a0
    800024c4:	84ae                	mv	s1,a1
    800024c6:	89b2                	mv	s3,a2
    800024c8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ca:	fffff097          	auipc	ra,0xfffff
    800024ce:	4e2080e7          	jalr	1250(ra) # 800019ac <myproc>
  if(user_src){
    800024d2:	c08d                	beqz	s1,800024f4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024d4:	86d2                	mv	a3,s4
    800024d6:	864e                	mv	a2,s3
    800024d8:	85ca                	mv	a1,s2
    800024da:	6928                	ld	a0,80(a0)
    800024dc:	fffff097          	auipc	ra,0xfffff
    800024e0:	218080e7          	jalr	536(ra) # 800016f4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024e4:	70a2                	ld	ra,40(sp)
    800024e6:	7402                	ld	s0,32(sp)
    800024e8:	64e2                	ld	s1,24(sp)
    800024ea:	6942                	ld	s2,16(sp)
    800024ec:	69a2                	ld	s3,8(sp)
    800024ee:	6a02                	ld	s4,0(sp)
    800024f0:	6145                	addi	sp,sp,48
    800024f2:	8082                	ret
    memmove(dst, (char*)src, len);
    800024f4:	000a061b          	sext.w	a2,s4
    800024f8:	85ce                	mv	a1,s3
    800024fa:	854a                	mv	a0,s2
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	832080e7          	jalr	-1998(ra) # 80000d2e <memmove>
    return 0;
    80002504:	8526                	mv	a0,s1
    80002506:	bff9                	j	800024e4 <either_copyin+0x32>

0000000080002508 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002508:	715d                	addi	sp,sp,-80
    8000250a:	e486                	sd	ra,72(sp)
    8000250c:	e0a2                	sd	s0,64(sp)
    8000250e:	fc26                	sd	s1,56(sp)
    80002510:	f84a                	sd	s2,48(sp)
    80002512:	f44e                	sd	s3,40(sp)
    80002514:	f052                	sd	s4,32(sp)
    80002516:	ec56                	sd	s5,24(sp)
    80002518:	e85a                	sd	s6,16(sp)
    8000251a:	e45e                	sd	s7,8(sp)
    8000251c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000251e:	00006517          	auipc	a0,0x6
    80002522:	baa50513          	addi	a0,a0,-1110 # 800080c8 <digits+0x88>
    80002526:	ffffe097          	auipc	ra,0xffffe
    8000252a:	062080e7          	jalr	98(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000252e:	0000f497          	auipc	s1,0xf
    80002532:	bba48493          	addi	s1,s1,-1094 # 800110e8 <proc+0x158>
    80002536:	00014917          	auipc	s2,0x14
    8000253a:	5b290913          	addi	s2,s2,1458 # 80016ae8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000253e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002540:	00006997          	auipc	s3,0x6
    80002544:	d4098993          	addi	s3,s3,-704 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002548:	00006a97          	auipc	s5,0x6
    8000254c:	d40a8a93          	addi	s5,s5,-704 # 80008288 <digits+0x248>
    printf("\n");
    80002550:	00006a17          	auipc	s4,0x6
    80002554:	b78a0a13          	addi	s4,s4,-1160 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002558:	00006b97          	auipc	s7,0x6
    8000255c:	d70b8b93          	addi	s7,s7,-656 # 800082c8 <states.0>
    80002560:	a00d                	j	80002582 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002562:	ed86a583          	lw	a1,-296(a3)
    80002566:	8556                	mv	a0,s5
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	020080e7          	jalr	32(ra) # 80000588 <printf>
    printf("\n");
    80002570:	8552                	mv	a0,s4
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	016080e7          	jalr	22(ra) # 80000588 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000257a:	16848493          	addi	s1,s1,360
    8000257e:	03248163          	beq	s1,s2,800025a0 <procdump+0x98>
    if(p->state == UNUSED)
    80002582:	86a6                	mv	a3,s1
    80002584:	ec04a783          	lw	a5,-320(s1)
    80002588:	dbed                	beqz	a5,8000257a <procdump+0x72>
      state = "???";
    8000258a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000258c:	fcfb6be3          	bltu	s6,a5,80002562 <procdump+0x5a>
    80002590:	1782                	slli	a5,a5,0x20
    80002592:	9381                	srli	a5,a5,0x20
    80002594:	078e                	slli	a5,a5,0x3
    80002596:	97de                	add	a5,a5,s7
    80002598:	6390                	ld	a2,0(a5)
    8000259a:	f661                	bnez	a2,80002562 <procdump+0x5a>
      state = "???";
    8000259c:	864e                	mv	a2,s3
    8000259e:	b7d1                	j	80002562 <procdump+0x5a>
  }
}
    800025a0:	60a6                	ld	ra,72(sp)
    800025a2:	6406                	ld	s0,64(sp)
    800025a4:	74e2                	ld	s1,56(sp)
    800025a6:	7942                	ld	s2,48(sp)
    800025a8:	79a2                	ld	s3,40(sp)
    800025aa:	7a02                	ld	s4,32(sp)
    800025ac:	6ae2                	ld	s5,24(sp)
    800025ae:	6b42                	ld	s6,16(sp)
    800025b0:	6ba2                	ld	s7,8(sp)
    800025b2:	6161                	addi	sp,sp,80
    800025b4:	8082                	ret

00000000800025b6 <swtch>:
    800025b6:	00153023          	sd	ra,0(a0)
    800025ba:	00253423          	sd	sp,8(a0)
    800025be:	e900                	sd	s0,16(a0)
    800025c0:	ed04                	sd	s1,24(a0)
    800025c2:	03253023          	sd	s2,32(a0)
    800025c6:	03353423          	sd	s3,40(a0)
    800025ca:	03453823          	sd	s4,48(a0)
    800025ce:	03553c23          	sd	s5,56(a0)
    800025d2:	05653023          	sd	s6,64(a0)
    800025d6:	05753423          	sd	s7,72(a0)
    800025da:	05853823          	sd	s8,80(a0)
    800025de:	05953c23          	sd	s9,88(a0)
    800025e2:	07a53023          	sd	s10,96(a0)
    800025e6:	07b53423          	sd	s11,104(a0)
    800025ea:	0005b083          	ld	ra,0(a1)
    800025ee:	0085b103          	ld	sp,8(a1)
    800025f2:	6980                	ld	s0,16(a1)
    800025f4:	6d84                	ld	s1,24(a1)
    800025f6:	0205b903          	ld	s2,32(a1)
    800025fa:	0285b983          	ld	s3,40(a1)
    800025fe:	0305ba03          	ld	s4,48(a1)
    80002602:	0385ba83          	ld	s5,56(a1)
    80002606:	0405bb03          	ld	s6,64(a1)
    8000260a:	0485bb83          	ld	s7,72(a1)
    8000260e:	0505bc03          	ld	s8,80(a1)
    80002612:	0585bc83          	ld	s9,88(a1)
    80002616:	0605bd03          	ld	s10,96(a1)
    8000261a:	0685bd83          	ld	s11,104(a1)
    8000261e:	8082                	ret

0000000080002620 <trapinit>:
    80002620:	1141                	addi	sp,sp,-16
    80002622:	e406                	sd	ra,8(sp)
    80002624:	e022                	sd	s0,0(sp)
    80002626:	0800                	addi	s0,sp,16
    80002628:	00006597          	auipc	a1,0x6
    8000262c:	cd058593          	addi	a1,a1,-816 # 800082f8 <states.0+0x30>
    80002630:	00014517          	auipc	a0,0x14
    80002634:	36050513          	addi	a0,a0,864 # 80016990 <tickslock>
    80002638:	ffffe097          	auipc	ra,0xffffe
    8000263c:	50e080e7          	jalr	1294(ra) # 80000b46 <initlock>
    80002640:	60a2                	ld	ra,8(sp)
    80002642:	6402                	ld	s0,0(sp)
    80002644:	0141                	addi	sp,sp,16
    80002646:	8082                	ret

0000000080002648 <trapinithart>:
    80002648:	1141                	addi	sp,sp,-16
    8000264a:	e422                	sd	s0,8(sp)
    8000264c:	0800                	addi	s0,sp,16
    8000264e:	00003797          	auipc	a5,0x3
    80002652:	4d278793          	addi	a5,a5,1234 # 80005b20 <kernelvec>
    80002656:	10579073          	csrw	stvec,a5
    8000265a:	6422                	ld	s0,8(sp)
    8000265c:	0141                	addi	sp,sp,16
    8000265e:	8082                	ret

0000000080002660 <usertrapret>:
    80002660:	1141                	addi	sp,sp,-16
    80002662:	e406                	sd	ra,8(sp)
    80002664:	e022                	sd	s0,0(sp)
    80002666:	0800                	addi	s0,sp,16
    80002668:	fffff097          	auipc	ra,0xfffff
    8000266c:	344080e7          	jalr	836(ra) # 800019ac <myproc>
    80002670:	100027f3          	csrr	a5,sstatus
    80002674:	9bf5                	andi	a5,a5,-3
    80002676:	10079073          	csrw	sstatus,a5
    8000267a:	00005617          	auipc	a2,0x5
    8000267e:	98660613          	addi	a2,a2,-1658 # 80007000 <_trampoline>
    80002682:	00005697          	auipc	a3,0x5
    80002686:	97e68693          	addi	a3,a3,-1666 # 80007000 <_trampoline>
    8000268a:	8e91                	sub	a3,a3,a2
    8000268c:	040007b7          	lui	a5,0x4000
    80002690:	17fd                	addi	a5,a5,-1
    80002692:	07b2                	slli	a5,a5,0xc
    80002694:	96be                	add	a3,a3,a5
    80002696:	10569073          	csrw	stvec,a3
    8000269a:	6d38                	ld	a4,88(a0)
    8000269c:	180026f3          	csrr	a3,satp
    800026a0:	e314                	sd	a3,0(a4)
    800026a2:	6d38                	ld	a4,88(a0)
    800026a4:	6134                	ld	a3,64(a0)
    800026a6:	6585                	lui	a1,0x1
    800026a8:	96ae                	add	a3,a3,a1
    800026aa:	e714                	sd	a3,8(a4)
    800026ac:	6d38                	ld	a4,88(a0)
    800026ae:	00000697          	auipc	a3,0x0
    800026b2:	13068693          	addi	a3,a3,304 # 800027de <usertrap>
    800026b6:	eb14                	sd	a3,16(a4)
    800026b8:	6d38                	ld	a4,88(a0)
    800026ba:	8692                	mv	a3,tp
    800026bc:	f314                	sd	a3,32(a4)
    800026be:	100026f3          	csrr	a3,sstatus
    800026c2:	eff6f693          	andi	a3,a3,-257
    800026c6:	0206e693          	ori	a3,a3,32
    800026ca:	10069073          	csrw	sstatus,a3
    800026ce:	6d38                	ld	a4,88(a0)
    800026d0:	6f18                	ld	a4,24(a4)
    800026d2:	14171073          	csrw	sepc,a4
    800026d6:	6928                	ld	a0,80(a0)
    800026d8:	8131                	srli	a0,a0,0xc
    800026da:	00005717          	auipc	a4,0x5
    800026de:	9c270713          	addi	a4,a4,-1598 # 8000709c <userret>
    800026e2:	8f11                	sub	a4,a4,a2
    800026e4:	97ba                	add	a5,a5,a4
    800026e6:	577d                	li	a4,-1
    800026e8:	177e                	slli	a4,a4,0x3f
    800026ea:	8d59                	or	a0,a0,a4
    800026ec:	9782                	jalr	a5
    800026ee:	60a2                	ld	ra,8(sp)
    800026f0:	6402                	ld	s0,0(sp)
    800026f2:	0141                	addi	sp,sp,16
    800026f4:	8082                	ret

00000000800026f6 <clockintr>:
    800026f6:	1101                	addi	sp,sp,-32
    800026f8:	ec06                	sd	ra,24(sp)
    800026fa:	e822                	sd	s0,16(sp)
    800026fc:	e426                	sd	s1,8(sp)
    800026fe:	1000                	addi	s0,sp,32
    80002700:	00014497          	auipc	s1,0x14
    80002704:	29048493          	addi	s1,s1,656 # 80016990 <tickslock>
    80002708:	8526                	mv	a0,s1
    8000270a:	ffffe097          	auipc	ra,0xffffe
    8000270e:	4cc080e7          	jalr	1228(ra) # 80000bd6 <acquire>
    80002712:	00006517          	auipc	a0,0x6
    80002716:	1de50513          	addi	a0,a0,478 # 800088f0 <ticks>
    8000271a:	411c                	lw	a5,0(a0)
    8000271c:	2785                	addiw	a5,a5,1
    8000271e:	c11c                	sw	a5,0(a0)
    80002720:	00000097          	auipc	ra,0x0
    80002724:	998080e7          	jalr	-1640(ra) # 800020b8 <wakeup>
    80002728:	8526                	mv	a0,s1
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	560080e7          	jalr	1376(ra) # 80000c8a <release>
    80002732:	60e2                	ld	ra,24(sp)
    80002734:	6442                	ld	s0,16(sp)
    80002736:	64a2                	ld	s1,8(sp)
    80002738:	6105                	addi	sp,sp,32
    8000273a:	8082                	ret

000000008000273c <devintr>:
    8000273c:	1101                	addi	sp,sp,-32
    8000273e:	ec06                	sd	ra,24(sp)
    80002740:	e822                	sd	s0,16(sp)
    80002742:	e426                	sd	s1,8(sp)
    80002744:	1000                	addi	s0,sp,32
    80002746:	14202773          	csrr	a4,scause
    8000274a:	00074d63          	bltz	a4,80002764 <devintr+0x28>
    8000274e:	57fd                	li	a5,-1
    80002750:	17fe                	slli	a5,a5,0x3f
    80002752:	0785                	addi	a5,a5,1
    80002754:	4501                	li	a0,0
    80002756:	06f70363          	beq	a4,a5,800027bc <devintr+0x80>
    8000275a:	60e2                	ld	ra,24(sp)
    8000275c:	6442                	ld	s0,16(sp)
    8000275e:	64a2                	ld	s1,8(sp)
    80002760:	6105                	addi	sp,sp,32
    80002762:	8082                	ret
    80002764:	0ff77793          	andi	a5,a4,255
    80002768:	46a5                	li	a3,9
    8000276a:	fed792e3          	bne	a5,a3,8000274e <devintr+0x12>
    8000276e:	00003097          	auipc	ra,0x3
    80002772:	4ba080e7          	jalr	1210(ra) # 80005c28 <plic_claim>
    80002776:	84aa                	mv	s1,a0
    80002778:	47a9                	li	a5,10
    8000277a:	02f50763          	beq	a0,a5,800027a8 <devintr+0x6c>
    8000277e:	4785                	li	a5,1
    80002780:	02f50963          	beq	a0,a5,800027b2 <devintr+0x76>
    80002784:	4505                	li	a0,1
    80002786:	d8f1                	beqz	s1,8000275a <devintr+0x1e>
    80002788:	85a6                	mv	a1,s1
    8000278a:	00006517          	auipc	a0,0x6
    8000278e:	b7650513          	addi	a0,a0,-1162 # 80008300 <states.0+0x38>
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	df6080e7          	jalr	-522(ra) # 80000588 <printf>
    8000279a:	8526                	mv	a0,s1
    8000279c:	00003097          	auipc	ra,0x3
    800027a0:	4b0080e7          	jalr	1200(ra) # 80005c4c <plic_complete>
    800027a4:	4505                	li	a0,1
    800027a6:	bf55                	j	8000275a <devintr+0x1e>
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	1f2080e7          	jalr	498(ra) # 8000099a <uartintr>
    800027b0:	b7ed                	j	8000279a <devintr+0x5e>
    800027b2:	00004097          	auipc	ra,0x4
    800027b6:	966080e7          	jalr	-1690(ra) # 80006118 <virtio_disk_intr>
    800027ba:	b7c5                	j	8000279a <devintr+0x5e>
    800027bc:	fffff097          	auipc	ra,0xfffff
    800027c0:	1c4080e7          	jalr	452(ra) # 80001980 <cpuid>
    800027c4:	c901                	beqz	a0,800027d4 <devintr+0x98>
    800027c6:	144027f3          	csrr	a5,sip
    800027ca:	9bf5                	andi	a5,a5,-3
    800027cc:	14479073          	csrw	sip,a5
    800027d0:	4509                	li	a0,2
    800027d2:	b761                	j	8000275a <devintr+0x1e>
    800027d4:	00000097          	auipc	ra,0x0
    800027d8:	f22080e7          	jalr	-222(ra) # 800026f6 <clockintr>
    800027dc:	b7ed                	j	800027c6 <devintr+0x8a>

00000000800027de <usertrap>:
    800027de:	1101                	addi	sp,sp,-32
    800027e0:	ec06                	sd	ra,24(sp)
    800027e2:	e822                	sd	s0,16(sp)
    800027e4:	e426                	sd	s1,8(sp)
    800027e6:	e04a                	sd	s2,0(sp)
    800027e8:	1000                	addi	s0,sp,32
    800027ea:	100027f3          	csrr	a5,sstatus
    800027ee:	1007f793          	andi	a5,a5,256
    800027f2:	e3b1                	bnez	a5,80002836 <usertrap+0x58>
    800027f4:	00003797          	auipc	a5,0x3
    800027f8:	32c78793          	addi	a5,a5,812 # 80005b20 <kernelvec>
    800027fc:	10579073          	csrw	stvec,a5
    80002800:	fffff097          	auipc	ra,0xfffff
    80002804:	1ac080e7          	jalr	428(ra) # 800019ac <myproc>
    80002808:	84aa                	mv	s1,a0
    8000280a:	6d3c                	ld	a5,88(a0)
    8000280c:	14102773          	csrr	a4,sepc
    80002810:	ef98                	sd	a4,24(a5)
    80002812:	14202773          	csrr	a4,scause
    80002816:	47a1                	li	a5,8
    80002818:	02f70763          	beq	a4,a5,80002846 <usertrap+0x68>
    8000281c:	00000097          	auipc	ra,0x0
    80002820:	f20080e7          	jalr	-224(ra) # 8000273c <devintr>
    80002824:	892a                	mv	s2,a0
    80002826:	c151                	beqz	a0,800028aa <usertrap+0xcc>
    80002828:	8526                	mv	a0,s1
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	ad2080e7          	jalr	-1326(ra) # 800022fc <killed>
    80002832:	c929                	beqz	a0,80002884 <usertrap+0xa6>
    80002834:	a099                	j	8000287a <usertrap+0x9c>
    80002836:	00006517          	auipc	a0,0x6
    8000283a:	aea50513          	addi	a0,a0,-1302 # 80008320 <states.0+0x58>
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	d00080e7          	jalr	-768(ra) # 8000053e <panic>
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	ab6080e7          	jalr	-1354(ra) # 800022fc <killed>
    8000284e:	e921                	bnez	a0,8000289e <usertrap+0xc0>
    80002850:	6cb8                	ld	a4,88(s1)
    80002852:	6f1c                	ld	a5,24(a4)
    80002854:	0791                	addi	a5,a5,4
    80002856:	ef1c                	sd	a5,24(a4)
    80002858:	100027f3          	csrr	a5,sstatus
    8000285c:	0027e793          	ori	a5,a5,2
    80002860:	10079073          	csrw	sstatus,a5
    80002864:	00000097          	auipc	ra,0x0
    80002868:	2d4080e7          	jalr	724(ra) # 80002b38 <syscall>
    8000286c:	8526                	mv	a0,s1
    8000286e:	00000097          	auipc	ra,0x0
    80002872:	a8e080e7          	jalr	-1394(ra) # 800022fc <killed>
    80002876:	c911                	beqz	a0,8000288a <usertrap+0xac>
    80002878:	4901                	li	s2,0
    8000287a:	557d                	li	a0,-1
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	90c080e7          	jalr	-1780(ra) # 80002188 <exit>
    80002884:	4789                	li	a5,2
    80002886:	04f90f63          	beq	s2,a5,800028e4 <usertrap+0x106>
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	dd6080e7          	jalr	-554(ra) # 80002660 <usertrapret>
    80002892:	60e2                	ld	ra,24(sp)
    80002894:	6442                	ld	s0,16(sp)
    80002896:	64a2                	ld	s1,8(sp)
    80002898:	6902                	ld	s2,0(sp)
    8000289a:	6105                	addi	sp,sp,32
    8000289c:	8082                	ret
    8000289e:	557d                	li	a0,-1
    800028a0:	00000097          	auipc	ra,0x0
    800028a4:	8e8080e7          	jalr	-1816(ra) # 80002188 <exit>
    800028a8:	b765                	j	80002850 <usertrap+0x72>
    800028aa:	142025f3          	csrr	a1,scause
    800028ae:	5890                	lw	a2,48(s1)
    800028b0:	00006517          	auipc	a0,0x6
    800028b4:	a9050513          	addi	a0,a0,-1392 # 80008340 <states.0+0x78>
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	cd0080e7          	jalr	-816(ra) # 80000588 <printf>
    800028c0:	141025f3          	csrr	a1,sepc
    800028c4:	14302673          	csrr	a2,stval
    800028c8:	00006517          	auipc	a0,0x6
    800028cc:	aa850513          	addi	a0,a0,-1368 # 80008370 <states.0+0xa8>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	cb8080e7          	jalr	-840(ra) # 80000588 <printf>
    800028d8:	8526                	mv	a0,s1
    800028da:	00000097          	auipc	ra,0x0
    800028de:	9f6080e7          	jalr	-1546(ra) # 800022d0 <setkilled>
    800028e2:	b769                	j	8000286c <usertrap+0x8e>
    800028e4:	fffff097          	auipc	ra,0xfffff
    800028e8:	734080e7          	jalr	1844(ra) # 80002018 <yield>
    800028ec:	bf79                	j	8000288a <usertrap+0xac>

00000000800028ee <kerneltrap>:
    800028ee:	7179                	addi	sp,sp,-48
    800028f0:	f406                	sd	ra,40(sp)
    800028f2:	f022                	sd	s0,32(sp)
    800028f4:	ec26                	sd	s1,24(sp)
    800028f6:	e84a                	sd	s2,16(sp)
    800028f8:	e44e                	sd	s3,8(sp)
    800028fa:	1800                	addi	s0,sp,48
    800028fc:	14102973          	csrr	s2,sepc
    80002900:	100024f3          	csrr	s1,sstatus
    80002904:	142029f3          	csrr	s3,scause
    80002908:	1004f793          	andi	a5,s1,256
    8000290c:	cb85                	beqz	a5,8000293c <kerneltrap+0x4e>
    8000290e:	100027f3          	csrr	a5,sstatus
    80002912:	8b89                	andi	a5,a5,2
    80002914:	ef85                	bnez	a5,8000294c <kerneltrap+0x5e>
    80002916:	00000097          	auipc	ra,0x0
    8000291a:	e26080e7          	jalr	-474(ra) # 8000273c <devintr>
    8000291e:	cd1d                	beqz	a0,8000295c <kerneltrap+0x6e>
    80002920:	4789                	li	a5,2
    80002922:	06f50a63          	beq	a0,a5,80002996 <kerneltrap+0xa8>
    80002926:	14191073          	csrw	sepc,s2
    8000292a:	10049073          	csrw	sstatus,s1
    8000292e:	70a2                	ld	ra,40(sp)
    80002930:	7402                	ld	s0,32(sp)
    80002932:	64e2                	ld	s1,24(sp)
    80002934:	6942                	ld	s2,16(sp)
    80002936:	69a2                	ld	s3,8(sp)
    80002938:	6145                	addi	sp,sp,48
    8000293a:	8082                	ret
    8000293c:	00006517          	auipc	a0,0x6
    80002940:	a5450513          	addi	a0,a0,-1452 # 80008390 <states.0+0xc8>
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	bfa080e7          	jalr	-1030(ra) # 8000053e <panic>
    8000294c:	00006517          	auipc	a0,0x6
    80002950:	a6c50513          	addi	a0,a0,-1428 # 800083b8 <states.0+0xf0>
    80002954:	ffffe097          	auipc	ra,0xffffe
    80002958:	bea080e7          	jalr	-1046(ra) # 8000053e <panic>
    8000295c:	85ce                	mv	a1,s3
    8000295e:	00006517          	auipc	a0,0x6
    80002962:	a7a50513          	addi	a0,a0,-1414 # 800083d8 <states.0+0x110>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	c22080e7          	jalr	-990(ra) # 80000588 <printf>
    8000296e:	141025f3          	csrr	a1,sepc
    80002972:	14302673          	csrr	a2,stval
    80002976:	00006517          	auipc	a0,0x6
    8000297a:	a7250513          	addi	a0,a0,-1422 # 800083e8 <states.0+0x120>
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	c0a080e7          	jalr	-1014(ra) # 80000588 <printf>
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	a7a50513          	addi	a0,a0,-1414 # 80008400 <states.0+0x138>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	bb0080e7          	jalr	-1104(ra) # 8000053e <panic>
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	016080e7          	jalr	22(ra) # 800019ac <myproc>
    8000299e:	d541                	beqz	a0,80002926 <kerneltrap+0x38>
    800029a0:	fffff097          	auipc	ra,0xfffff
    800029a4:	00c080e7          	jalr	12(ra) # 800019ac <myproc>
    800029a8:	4d18                	lw	a4,24(a0)
    800029aa:	4791                	li	a5,4
    800029ac:	f6f71de3          	bne	a4,a5,80002926 <kerneltrap+0x38>
    800029b0:	fffff097          	auipc	ra,0xfffff
    800029b4:	668080e7          	jalr	1640(ra) # 80002018 <yield>
    800029b8:	b7bd                	j	80002926 <kerneltrap+0x38>

00000000800029ba <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	1000                	addi	s0,sp,32
    800029c4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029c6:	fffff097          	auipc	ra,0xfffff
    800029ca:	fe6080e7          	jalr	-26(ra) # 800019ac <myproc>
  switch (n) {
    800029ce:	4795                	li	a5,5
    800029d0:	0497e163          	bltu	a5,s1,80002a12 <argraw+0x58>
    800029d4:	048a                	slli	s1,s1,0x2
    800029d6:	00006717          	auipc	a4,0x6
    800029da:	a6270713          	addi	a4,a4,-1438 # 80008438 <states.0+0x170>
    800029de:	94ba                	add	s1,s1,a4
    800029e0:	409c                	lw	a5,0(s1)
    800029e2:	97ba                	add	a5,a5,a4
    800029e4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029e6:	6d3c                	ld	a5,88(a0)
    800029e8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	64a2                	ld	s1,8(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret
    return p->trapframe->a1;
    800029f4:	6d3c                	ld	a5,88(a0)
    800029f6:	7fa8                	ld	a0,120(a5)
    800029f8:	bfcd                	j	800029ea <argraw+0x30>
    return p->trapframe->a2;
    800029fa:	6d3c                	ld	a5,88(a0)
    800029fc:	63c8                	ld	a0,128(a5)
    800029fe:	b7f5                	j	800029ea <argraw+0x30>
    return p->trapframe->a3;
    80002a00:	6d3c                	ld	a5,88(a0)
    80002a02:	67c8                	ld	a0,136(a5)
    80002a04:	b7dd                	j	800029ea <argraw+0x30>
    return p->trapframe->a4;
    80002a06:	6d3c                	ld	a5,88(a0)
    80002a08:	6bc8                	ld	a0,144(a5)
    80002a0a:	b7c5                	j	800029ea <argraw+0x30>
    return p->trapframe->a5;
    80002a0c:	6d3c                	ld	a5,88(a0)
    80002a0e:	6fc8                	ld	a0,152(a5)
    80002a10:	bfe9                	j	800029ea <argraw+0x30>
  panic("argraw");
    80002a12:	00006517          	auipc	a0,0x6
    80002a16:	9fe50513          	addi	a0,a0,-1538 # 80008410 <states.0+0x148>
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	b24080e7          	jalr	-1244(ra) # 8000053e <panic>

0000000080002a22 <fetchaddr>:
{
    80002a22:	1101                	addi	sp,sp,-32
    80002a24:	ec06                	sd	ra,24(sp)
    80002a26:	e822                	sd	s0,16(sp)
    80002a28:	e426                	sd	s1,8(sp)
    80002a2a:	e04a                	sd	s2,0(sp)
    80002a2c:	1000                	addi	s0,sp,32
    80002a2e:	84aa                	mv	s1,a0
    80002a30:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a32:	fffff097          	auipc	ra,0xfffff
    80002a36:	f7a080e7          	jalr	-134(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a3a:	653c                	ld	a5,72(a0)
    80002a3c:	02f4f863          	bgeu	s1,a5,80002a6c <fetchaddr+0x4a>
    80002a40:	00848713          	addi	a4,s1,8
    80002a44:	02e7e663          	bltu	a5,a4,80002a70 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a48:	46a1                	li	a3,8
    80002a4a:	8626                	mv	a2,s1
    80002a4c:	85ca                	mv	a1,s2
    80002a4e:	6928                	ld	a0,80(a0)
    80002a50:	fffff097          	auipc	ra,0xfffff
    80002a54:	ca4080e7          	jalr	-860(ra) # 800016f4 <copyin>
    80002a58:	00a03533          	snez	a0,a0
    80002a5c:	40a00533          	neg	a0,a0
}
    80002a60:	60e2                	ld	ra,24(sp)
    80002a62:	6442                	ld	s0,16(sp)
    80002a64:	64a2                	ld	s1,8(sp)
    80002a66:	6902                	ld	s2,0(sp)
    80002a68:	6105                	addi	sp,sp,32
    80002a6a:	8082                	ret
    return -1;
    80002a6c:	557d                	li	a0,-1
    80002a6e:	bfcd                	j	80002a60 <fetchaddr+0x3e>
    80002a70:	557d                	li	a0,-1
    80002a72:	b7fd                	j	80002a60 <fetchaddr+0x3e>

0000000080002a74 <fetchstr>:
{
    80002a74:	7179                	addi	sp,sp,-48
    80002a76:	f406                	sd	ra,40(sp)
    80002a78:	f022                	sd	s0,32(sp)
    80002a7a:	ec26                	sd	s1,24(sp)
    80002a7c:	e84a                	sd	s2,16(sp)
    80002a7e:	e44e                	sd	s3,8(sp)
    80002a80:	1800                	addi	s0,sp,48
    80002a82:	892a                	mv	s2,a0
    80002a84:	84ae                	mv	s1,a1
    80002a86:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a88:	fffff097          	auipc	ra,0xfffff
    80002a8c:	f24080e7          	jalr	-220(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a90:	86ce                	mv	a3,s3
    80002a92:	864a                	mv	a2,s2
    80002a94:	85a6                	mv	a1,s1
    80002a96:	6928                	ld	a0,80(a0)
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	cea080e7          	jalr	-790(ra) # 80001782 <copyinstr>
    80002aa0:	00054e63          	bltz	a0,80002abc <fetchstr+0x48>
  return strlen(buf);
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	3a8080e7          	jalr	936(ra) # 80000e4e <strlen>
}
    80002aae:	70a2                	ld	ra,40(sp)
    80002ab0:	7402                	ld	s0,32(sp)
    80002ab2:	64e2                	ld	s1,24(sp)
    80002ab4:	6942                	ld	s2,16(sp)
    80002ab6:	69a2                	ld	s3,8(sp)
    80002ab8:	6145                	addi	sp,sp,48
    80002aba:	8082                	ret
    return -1;
    80002abc:	557d                	li	a0,-1
    80002abe:	bfc5                	j	80002aae <fetchstr+0x3a>

0000000080002ac0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ac0:	1101                	addi	sp,sp,-32
    80002ac2:	ec06                	sd	ra,24(sp)
    80002ac4:	e822                	sd	s0,16(sp)
    80002ac6:	e426                	sd	s1,8(sp)
    80002ac8:	1000                	addi	s0,sp,32
    80002aca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002acc:	00000097          	auipc	ra,0x0
    80002ad0:	eee080e7          	jalr	-274(ra) # 800029ba <argraw>
    80002ad4:	c088                	sw	a0,0(s1)
}
    80002ad6:	60e2                	ld	ra,24(sp)
    80002ad8:	6442                	ld	s0,16(sp)
    80002ada:	64a2                	ld	s1,8(sp)
    80002adc:	6105                	addi	sp,sp,32
    80002ade:	8082                	ret

0000000080002ae0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ae0:	1101                	addi	sp,sp,-32
    80002ae2:	ec06                	sd	ra,24(sp)
    80002ae4:	e822                	sd	s0,16(sp)
    80002ae6:	e426                	sd	s1,8(sp)
    80002ae8:	1000                	addi	s0,sp,32
    80002aea:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002aec:	00000097          	auipc	ra,0x0
    80002af0:	ece080e7          	jalr	-306(ra) # 800029ba <argraw>
    80002af4:	e088                	sd	a0,0(s1)
}
    80002af6:	60e2                	ld	ra,24(sp)
    80002af8:	6442                	ld	s0,16(sp)
    80002afa:	64a2                	ld	s1,8(sp)
    80002afc:	6105                	addi	sp,sp,32
    80002afe:	8082                	ret

0000000080002b00 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b00:	7179                	addi	sp,sp,-48
    80002b02:	f406                	sd	ra,40(sp)
    80002b04:	f022                	sd	s0,32(sp)
    80002b06:	ec26                	sd	s1,24(sp)
    80002b08:	e84a                	sd	s2,16(sp)
    80002b0a:	1800                	addi	s0,sp,48
    80002b0c:	84ae                	mv	s1,a1
    80002b0e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b10:	fd840593          	addi	a1,s0,-40
    80002b14:	00000097          	auipc	ra,0x0
    80002b18:	fcc080e7          	jalr	-52(ra) # 80002ae0 <argaddr>
  return fetchstr(addr, buf, max);
    80002b1c:	864a                	mv	a2,s2
    80002b1e:	85a6                	mv	a1,s1
    80002b20:	fd843503          	ld	a0,-40(s0)
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	f50080e7          	jalr	-176(ra) # 80002a74 <fetchstr>
}
    80002b2c:	70a2                	ld	ra,40(sp)
    80002b2e:	7402                	ld	s0,32(sp)
    80002b30:	64e2                	ld	s1,24(sp)
    80002b32:	6942                	ld	s2,16(sp)
    80002b34:	6145                	addi	sp,sp,48
    80002b36:	8082                	ret

0000000080002b38 <syscall>:
[SYS_memsize] sys_memsize,
};

void
syscall(void)
{
    80002b38:	1101                	addi	sp,sp,-32
    80002b3a:	ec06                	sd	ra,24(sp)
    80002b3c:	e822                	sd	s0,16(sp)
    80002b3e:	e426                	sd	s1,8(sp)
    80002b40:	e04a                	sd	s2,0(sp)
    80002b42:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b44:	fffff097          	auipc	ra,0xfffff
    80002b48:	e68080e7          	jalr	-408(ra) # 800019ac <myproc>
    80002b4c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b4e:	05853903          	ld	s2,88(a0)
    80002b52:	0a893783          	ld	a5,168(s2)
    80002b56:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b5a:	37fd                	addiw	a5,a5,-1
    80002b5c:	4755                	li	a4,21
    80002b5e:	00f76f63          	bltu	a4,a5,80002b7c <syscall+0x44>
    80002b62:	00369713          	slli	a4,a3,0x3
    80002b66:	00006797          	auipc	a5,0x6
    80002b6a:	8ea78793          	addi	a5,a5,-1814 # 80008450 <syscalls>
    80002b6e:	97ba                	add	a5,a5,a4
    80002b70:	639c                	ld	a5,0(a5)
    80002b72:	c789                	beqz	a5,80002b7c <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b74:	9782                	jalr	a5
    80002b76:	06a93823          	sd	a0,112(s2)
    80002b7a:	a839                	j	80002b98 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b7c:	15848613          	addi	a2,s1,344
    80002b80:	588c                	lw	a1,48(s1)
    80002b82:	00006517          	auipc	a0,0x6
    80002b86:	89650513          	addi	a0,a0,-1898 # 80008418 <states.0+0x150>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	9fe080e7          	jalr	-1538(ra) # 80000588 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b92:	6cbc                	ld	a5,88(s1)
    80002b94:	577d                	li	a4,-1
    80002b96:	fbb8                	sd	a4,112(a5)
  }
}
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	64a2                	ld	s1,8(sp)
    80002b9e:	6902                	ld	s2,0(sp)
    80002ba0:	6105                	addi	sp,sp,32
    80002ba2:	8082                	ret

0000000080002ba4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ba4:	1101                	addi	sp,sp,-32
    80002ba6:	ec06                	sd	ra,24(sp)
    80002ba8:	e822                	sd	s0,16(sp)
    80002baa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bac:	fec40593          	addi	a1,s0,-20
    80002bb0:	4501                	li	a0,0
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	f0e080e7          	jalr	-242(ra) # 80002ac0 <argint>
  exit(n);
    80002bba:	fec42503          	lw	a0,-20(s0)
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	5ca080e7          	jalr	1482(ra) # 80002188 <exit>
  return 0;  // not reached
}
    80002bc6:	4501                	li	a0,0
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd0:	1141                	addi	sp,sp,-16
    80002bd2:	e406                	sd	ra,8(sp)
    80002bd4:	e022                	sd	s0,0(sp)
    80002bd6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	dd4080e7          	jalr	-556(ra) # 800019ac <myproc>
}
    80002be0:	5908                	lw	a0,48(a0)
    80002be2:	60a2                	ld	ra,8(sp)
    80002be4:	6402                	ld	s0,0(sp)
    80002be6:	0141                	addi	sp,sp,16
    80002be8:	8082                	ret

0000000080002bea <sys_fork>:

uint64
sys_fork(void)
{
    80002bea:	1141                	addi	sp,sp,-16
    80002bec:	e406                	sd	ra,8(sp)
    80002bee:	e022                	sd	s0,0(sp)
    80002bf0:	0800                	addi	s0,sp,16
  return fork();
    80002bf2:	fffff097          	auipc	ra,0xfffff
    80002bf6:	170080e7          	jalr	368(ra) # 80001d62 <fork>
}
    80002bfa:	60a2                	ld	ra,8(sp)
    80002bfc:	6402                	ld	s0,0(sp)
    80002bfe:	0141                	addi	sp,sp,16
    80002c00:	8082                	ret

0000000080002c02 <sys_wait>:

uint64
sys_wait(void)
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c0a:	fe840593          	addi	a1,s0,-24
    80002c0e:	4501                	li	a0,0
    80002c10:	00000097          	auipc	ra,0x0
    80002c14:	ed0080e7          	jalr	-304(ra) # 80002ae0 <argaddr>
  return wait(p);
    80002c18:	fe843503          	ld	a0,-24(s0)
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	712080e7          	jalr	1810(ra) # 8000232e <wait>
}
    80002c24:	60e2                	ld	ra,24(sp)
    80002c26:	6442                	ld	s0,16(sp)
    80002c28:	6105                	addi	sp,sp,32
    80002c2a:	8082                	ret

0000000080002c2c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c2c:	7179                	addi	sp,sp,-48
    80002c2e:	f406                	sd	ra,40(sp)
    80002c30:	f022                	sd	s0,32(sp)
    80002c32:	ec26                	sd	s1,24(sp)
    80002c34:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c36:	fdc40593          	addi	a1,s0,-36
    80002c3a:	4501                	li	a0,0
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	e84080e7          	jalr	-380(ra) # 80002ac0 <argint>
  addr = myproc()->sz;
    80002c44:	fffff097          	auipc	ra,0xfffff
    80002c48:	d68080e7          	jalr	-664(ra) # 800019ac <myproc>
    80002c4c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c4e:	fdc42503          	lw	a0,-36(s0)
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	0b4080e7          	jalr	180(ra) # 80001d06 <growproc>
    80002c5a:	00054863          	bltz	a0,80002c6a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c5e:	8526                	mv	a0,s1
    80002c60:	70a2                	ld	ra,40(sp)
    80002c62:	7402                	ld	s0,32(sp)
    80002c64:	64e2                	ld	s1,24(sp)
    80002c66:	6145                	addi	sp,sp,48
    80002c68:	8082                	ret
    return -1;
    80002c6a:	54fd                	li	s1,-1
    80002c6c:	bfcd                	j	80002c5e <sys_sbrk+0x32>

0000000080002c6e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c6e:	7139                	addi	sp,sp,-64
    80002c70:	fc06                	sd	ra,56(sp)
    80002c72:	f822                	sd	s0,48(sp)
    80002c74:	f426                	sd	s1,40(sp)
    80002c76:	f04a                	sd	s2,32(sp)
    80002c78:	ec4e                	sd	s3,24(sp)
    80002c7a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c7c:	fcc40593          	addi	a1,s0,-52
    80002c80:	4501                	li	a0,0
    80002c82:	00000097          	auipc	ra,0x0
    80002c86:	e3e080e7          	jalr	-450(ra) # 80002ac0 <argint>
  acquire(&tickslock);
    80002c8a:	00014517          	auipc	a0,0x14
    80002c8e:	d0650513          	addi	a0,a0,-762 # 80016990 <tickslock>
    80002c92:	ffffe097          	auipc	ra,0xffffe
    80002c96:	f44080e7          	jalr	-188(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002c9a:	00006917          	auipc	s2,0x6
    80002c9e:	c5692903          	lw	s2,-938(s2) # 800088f0 <ticks>
  while(ticks - ticks0 < n){
    80002ca2:	fcc42783          	lw	a5,-52(s0)
    80002ca6:	cf9d                	beqz	a5,80002ce4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ca8:	00014997          	auipc	s3,0x14
    80002cac:	ce898993          	addi	s3,s3,-792 # 80016990 <tickslock>
    80002cb0:	00006497          	auipc	s1,0x6
    80002cb4:	c4048493          	addi	s1,s1,-960 # 800088f0 <ticks>
    if(killed(myproc())){
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	cf4080e7          	jalr	-780(ra) # 800019ac <myproc>
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	63c080e7          	jalr	1596(ra) # 800022fc <killed>
    80002cc8:	ed15                	bnez	a0,80002d04 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cca:	85ce                	mv	a1,s3
    80002ccc:	8526                	mv	a0,s1
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	386080e7          	jalr	902(ra) # 80002054 <sleep>
  while(ticks - ticks0 < n){
    80002cd6:	409c                	lw	a5,0(s1)
    80002cd8:	412787bb          	subw	a5,a5,s2
    80002cdc:	fcc42703          	lw	a4,-52(s0)
    80002ce0:	fce7ece3          	bltu	a5,a4,80002cb8 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ce4:	00014517          	auipc	a0,0x14
    80002ce8:	cac50513          	addi	a0,a0,-852 # 80016990 <tickslock>
    80002cec:	ffffe097          	auipc	ra,0xffffe
    80002cf0:	f9e080e7          	jalr	-98(ra) # 80000c8a <release>
  return 0;
    80002cf4:	4501                	li	a0,0
}
    80002cf6:	70e2                	ld	ra,56(sp)
    80002cf8:	7442                	ld	s0,48(sp)
    80002cfa:	74a2                	ld	s1,40(sp)
    80002cfc:	7902                	ld	s2,32(sp)
    80002cfe:	69e2                	ld	s3,24(sp)
    80002d00:	6121                	addi	sp,sp,64
    80002d02:	8082                	ret
      release(&tickslock);
    80002d04:	00014517          	auipc	a0,0x14
    80002d08:	c8c50513          	addi	a0,a0,-884 # 80016990 <tickslock>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	f7e080e7          	jalr	-130(ra) # 80000c8a <release>
      return -1;
    80002d14:	557d                	li	a0,-1
    80002d16:	b7c5                	j	80002cf6 <sys_sleep+0x88>

0000000080002d18 <sys_kill>:

uint64
sys_kill(void)
{
    80002d18:	1101                	addi	sp,sp,-32
    80002d1a:	ec06                	sd	ra,24(sp)
    80002d1c:	e822                	sd	s0,16(sp)
    80002d1e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d20:	fec40593          	addi	a1,s0,-20
    80002d24:	4501                	li	a0,0
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	d9a080e7          	jalr	-614(ra) # 80002ac0 <argint>
  return kill(pid);
    80002d2e:	fec42503          	lw	a0,-20(s0)
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	52c080e7          	jalr	1324(ra) # 8000225e <kill>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	6105                	addi	sp,sp,32
    80002d40:	8082                	ret

0000000080002d42 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d42:	1101                	addi	sp,sp,-32
    80002d44:	ec06                	sd	ra,24(sp)
    80002d46:	e822                	sd	s0,16(sp)
    80002d48:	e426                	sd	s1,8(sp)
    80002d4a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d4c:	00014517          	auipc	a0,0x14
    80002d50:	c4450513          	addi	a0,a0,-956 # 80016990 <tickslock>
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	e82080e7          	jalr	-382(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002d5c:	00006497          	auipc	s1,0x6
    80002d60:	b944a483          	lw	s1,-1132(s1) # 800088f0 <ticks>
  release(&tickslock);
    80002d64:	00014517          	auipc	a0,0x14
    80002d68:	c2c50513          	addi	a0,a0,-980 # 80016990 <tickslock>
    80002d6c:	ffffe097          	auipc	ra,0xffffe
    80002d70:	f1e080e7          	jalr	-226(ra) # 80000c8a <release>
  return xticks;
}
    80002d74:	02049513          	slli	a0,s1,0x20
    80002d78:	9101                	srli	a0,a0,0x20
    80002d7a:	60e2                	ld	ra,24(sp)
    80002d7c:	6442                	ld	s0,16(sp)
    80002d7e:	64a2                	ld	s1,8(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret

0000000080002d84 <sys_memsize>:

uint64 sys_memsize(void){
    80002d84:	1141                	addi	sp,sp,-16
    80002d86:	e406                	sd	ra,8(sp)
    80002d88:	e022                	sd	s0,0(sp)
    80002d8a:	0800                	addi	s0,sp,16

  uint64 size;
  size = myproc()->sz;
    80002d8c:	fffff097          	auipc	ra,0xfffff
    80002d90:	c20080e7          	jalr	-992(ra) # 800019ac <myproc>
  
  return size;
}
    80002d94:	6528                	ld	a0,72(a0)
    80002d96:	60a2                	ld	ra,8(sp)
    80002d98:	6402                	ld	s0,0(sp)
    80002d9a:	0141                	addi	sp,sp,16
    80002d9c:	8082                	ret

0000000080002d9e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d9e:	7179                	addi	sp,sp,-48
    80002da0:	f406                	sd	ra,40(sp)
    80002da2:	f022                	sd	s0,32(sp)
    80002da4:	ec26                	sd	s1,24(sp)
    80002da6:	e84a                	sd	s2,16(sp)
    80002da8:	e44e                	sd	s3,8(sp)
    80002daa:	e052                	sd	s4,0(sp)
    80002dac:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002dae:	00005597          	auipc	a1,0x5
    80002db2:	75a58593          	addi	a1,a1,1882 # 80008508 <syscalls+0xb8>
    80002db6:	00014517          	auipc	a0,0x14
    80002dba:	bf250513          	addi	a0,a0,-1038 # 800169a8 <bcache>
    80002dbe:	ffffe097          	auipc	ra,0xffffe
    80002dc2:	d88080e7          	jalr	-632(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dc6:	0001c797          	auipc	a5,0x1c
    80002dca:	be278793          	addi	a5,a5,-1054 # 8001e9a8 <bcache+0x8000>
    80002dce:	0001c717          	auipc	a4,0x1c
    80002dd2:	e4270713          	addi	a4,a4,-446 # 8001ec10 <bcache+0x8268>
    80002dd6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002dda:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dde:	00014497          	auipc	s1,0x14
    80002de2:	be248493          	addi	s1,s1,-1054 # 800169c0 <bcache+0x18>
    b->next = bcache.head.next;
    80002de6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002de8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dea:	00005a17          	auipc	s4,0x5
    80002dee:	726a0a13          	addi	s4,s4,1830 # 80008510 <syscalls+0xc0>
    b->next = bcache.head.next;
    80002df2:	2b893783          	ld	a5,696(s2)
    80002df6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002df8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002dfc:	85d2                	mv	a1,s4
    80002dfe:	01048513          	addi	a0,s1,16
    80002e02:	00001097          	auipc	ra,0x1
    80002e06:	4c4080e7          	jalr	1220(ra) # 800042c6 <initsleeplock>
    bcache.head.next->prev = b;
    80002e0a:	2b893783          	ld	a5,696(s2)
    80002e0e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e10:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e14:	45848493          	addi	s1,s1,1112
    80002e18:	fd349de3          	bne	s1,s3,80002df2 <binit+0x54>
  }
}
    80002e1c:	70a2                	ld	ra,40(sp)
    80002e1e:	7402                	ld	s0,32(sp)
    80002e20:	64e2                	ld	s1,24(sp)
    80002e22:	6942                	ld	s2,16(sp)
    80002e24:	69a2                	ld	s3,8(sp)
    80002e26:	6a02                	ld	s4,0(sp)
    80002e28:	6145                	addi	sp,sp,48
    80002e2a:	8082                	ret

0000000080002e2c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e2c:	7179                	addi	sp,sp,-48
    80002e2e:	f406                	sd	ra,40(sp)
    80002e30:	f022                	sd	s0,32(sp)
    80002e32:	ec26                	sd	s1,24(sp)
    80002e34:	e84a                	sd	s2,16(sp)
    80002e36:	e44e                	sd	s3,8(sp)
    80002e38:	1800                	addi	s0,sp,48
    80002e3a:	892a                	mv	s2,a0
    80002e3c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e3e:	00014517          	auipc	a0,0x14
    80002e42:	b6a50513          	addi	a0,a0,-1174 # 800169a8 <bcache>
    80002e46:	ffffe097          	auipc	ra,0xffffe
    80002e4a:	d90080e7          	jalr	-624(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e4e:	0001c497          	auipc	s1,0x1c
    80002e52:	e124b483          	ld	s1,-494(s1) # 8001ec60 <bcache+0x82b8>
    80002e56:	0001c797          	auipc	a5,0x1c
    80002e5a:	dba78793          	addi	a5,a5,-582 # 8001ec10 <bcache+0x8268>
    80002e5e:	02f48f63          	beq	s1,a5,80002e9c <bread+0x70>
    80002e62:	873e                	mv	a4,a5
    80002e64:	a021                	j	80002e6c <bread+0x40>
    80002e66:	68a4                	ld	s1,80(s1)
    80002e68:	02e48a63          	beq	s1,a4,80002e9c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e6c:	449c                	lw	a5,8(s1)
    80002e6e:	ff279ce3          	bne	a5,s2,80002e66 <bread+0x3a>
    80002e72:	44dc                	lw	a5,12(s1)
    80002e74:	ff3799e3          	bne	a5,s3,80002e66 <bread+0x3a>
      b->refcnt++;
    80002e78:	40bc                	lw	a5,64(s1)
    80002e7a:	2785                	addiw	a5,a5,1
    80002e7c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e7e:	00014517          	auipc	a0,0x14
    80002e82:	b2a50513          	addi	a0,a0,-1238 # 800169a8 <bcache>
    80002e86:	ffffe097          	auipc	ra,0xffffe
    80002e8a:	e04080e7          	jalr	-508(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002e8e:	01048513          	addi	a0,s1,16
    80002e92:	00001097          	auipc	ra,0x1
    80002e96:	46e080e7          	jalr	1134(ra) # 80004300 <acquiresleep>
      return b;
    80002e9a:	a8b9                	j	80002ef8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e9c:	0001c497          	auipc	s1,0x1c
    80002ea0:	dbc4b483          	ld	s1,-580(s1) # 8001ec58 <bcache+0x82b0>
    80002ea4:	0001c797          	auipc	a5,0x1c
    80002ea8:	d6c78793          	addi	a5,a5,-660 # 8001ec10 <bcache+0x8268>
    80002eac:	00f48863          	beq	s1,a5,80002ebc <bread+0x90>
    80002eb0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002eb2:	40bc                	lw	a5,64(s1)
    80002eb4:	cf81                	beqz	a5,80002ecc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002eb6:	64a4                	ld	s1,72(s1)
    80002eb8:	fee49de3          	bne	s1,a4,80002eb2 <bread+0x86>
  panic("bget: no buffers");
    80002ebc:	00005517          	auipc	a0,0x5
    80002ec0:	65c50513          	addi	a0,a0,1628 # 80008518 <syscalls+0xc8>
    80002ec4:	ffffd097          	auipc	ra,0xffffd
    80002ec8:	67a080e7          	jalr	1658(ra) # 8000053e <panic>
      b->dev = dev;
    80002ecc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002ed0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002ed4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ed8:	4785                	li	a5,1
    80002eda:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002edc:	00014517          	auipc	a0,0x14
    80002ee0:	acc50513          	addi	a0,a0,-1332 # 800169a8 <bcache>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	da6080e7          	jalr	-602(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80002eec:	01048513          	addi	a0,s1,16
    80002ef0:	00001097          	auipc	ra,0x1
    80002ef4:	410080e7          	jalr	1040(ra) # 80004300 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ef8:	409c                	lw	a5,0(s1)
    80002efa:	cb89                	beqz	a5,80002f0c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002efc:	8526                	mv	a0,s1
    80002efe:	70a2                	ld	ra,40(sp)
    80002f00:	7402                	ld	s0,32(sp)
    80002f02:	64e2                	ld	s1,24(sp)
    80002f04:	6942                	ld	s2,16(sp)
    80002f06:	69a2                	ld	s3,8(sp)
    80002f08:	6145                	addi	sp,sp,48
    80002f0a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f0c:	4581                	li	a1,0
    80002f0e:	8526                	mv	a0,s1
    80002f10:	00003097          	auipc	ra,0x3
    80002f14:	fd4080e7          	jalr	-44(ra) # 80005ee4 <virtio_disk_rw>
    b->valid = 1;
    80002f18:	4785                	li	a5,1
    80002f1a:	c09c                	sw	a5,0(s1)
  return b;
    80002f1c:	b7c5                	j	80002efc <bread+0xd0>

0000000080002f1e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f1e:	1101                	addi	sp,sp,-32
    80002f20:	ec06                	sd	ra,24(sp)
    80002f22:	e822                	sd	s0,16(sp)
    80002f24:	e426                	sd	s1,8(sp)
    80002f26:	1000                	addi	s0,sp,32
    80002f28:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f2a:	0541                	addi	a0,a0,16
    80002f2c:	00001097          	auipc	ra,0x1
    80002f30:	46e080e7          	jalr	1134(ra) # 8000439a <holdingsleep>
    80002f34:	cd01                	beqz	a0,80002f4c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f36:	4585                	li	a1,1
    80002f38:	8526                	mv	a0,s1
    80002f3a:	00003097          	auipc	ra,0x3
    80002f3e:	faa080e7          	jalr	-86(ra) # 80005ee4 <virtio_disk_rw>
}
    80002f42:	60e2                	ld	ra,24(sp)
    80002f44:	6442                	ld	s0,16(sp)
    80002f46:	64a2                	ld	s1,8(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret
    panic("bwrite");
    80002f4c:	00005517          	auipc	a0,0x5
    80002f50:	5e450513          	addi	a0,a0,1508 # 80008530 <syscalls+0xe0>
    80002f54:	ffffd097          	auipc	ra,0xffffd
    80002f58:	5ea080e7          	jalr	1514(ra) # 8000053e <panic>

0000000080002f5c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f5c:	1101                	addi	sp,sp,-32
    80002f5e:	ec06                	sd	ra,24(sp)
    80002f60:	e822                	sd	s0,16(sp)
    80002f62:	e426                	sd	s1,8(sp)
    80002f64:	e04a                	sd	s2,0(sp)
    80002f66:	1000                	addi	s0,sp,32
    80002f68:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f6a:	01050913          	addi	s2,a0,16
    80002f6e:	854a                	mv	a0,s2
    80002f70:	00001097          	auipc	ra,0x1
    80002f74:	42a080e7          	jalr	1066(ra) # 8000439a <holdingsleep>
    80002f78:	c92d                	beqz	a0,80002fea <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80002f7a:	854a                	mv	a0,s2
    80002f7c:	00001097          	auipc	ra,0x1
    80002f80:	3da080e7          	jalr	986(ra) # 80004356 <releasesleep>

  acquire(&bcache.lock);
    80002f84:	00014517          	auipc	a0,0x14
    80002f88:	a2450513          	addi	a0,a0,-1500 # 800169a8 <bcache>
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	c4a080e7          	jalr	-950(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80002f94:	40bc                	lw	a5,64(s1)
    80002f96:	37fd                	addiw	a5,a5,-1
    80002f98:	0007871b          	sext.w	a4,a5
    80002f9c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f9e:	eb05                	bnez	a4,80002fce <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fa0:	68bc                	ld	a5,80(s1)
    80002fa2:	64b8                	ld	a4,72(s1)
    80002fa4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002fa6:	64bc                	ld	a5,72(s1)
    80002fa8:	68b8                	ld	a4,80(s1)
    80002faa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fac:	0001c797          	auipc	a5,0x1c
    80002fb0:	9fc78793          	addi	a5,a5,-1540 # 8001e9a8 <bcache+0x8000>
    80002fb4:	2b87b703          	ld	a4,696(a5)
    80002fb8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fba:	0001c717          	auipc	a4,0x1c
    80002fbe:	c5670713          	addi	a4,a4,-938 # 8001ec10 <bcache+0x8268>
    80002fc2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fc4:	2b87b703          	ld	a4,696(a5)
    80002fc8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fca:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fce:	00014517          	auipc	a0,0x14
    80002fd2:	9da50513          	addi	a0,a0,-1574 # 800169a8 <bcache>
    80002fd6:	ffffe097          	auipc	ra,0xffffe
    80002fda:	cb4080e7          	jalr	-844(ra) # 80000c8a <release>
}
    80002fde:	60e2                	ld	ra,24(sp)
    80002fe0:	6442                	ld	s0,16(sp)
    80002fe2:	64a2                	ld	s1,8(sp)
    80002fe4:	6902                	ld	s2,0(sp)
    80002fe6:	6105                	addi	sp,sp,32
    80002fe8:	8082                	ret
    panic("brelse");
    80002fea:	00005517          	auipc	a0,0x5
    80002fee:	54e50513          	addi	a0,a0,1358 # 80008538 <syscalls+0xe8>
    80002ff2:	ffffd097          	auipc	ra,0xffffd
    80002ff6:	54c080e7          	jalr	1356(ra) # 8000053e <panic>

0000000080002ffa <bpin>:

void
bpin(struct buf *b) {
    80002ffa:	1101                	addi	sp,sp,-32
    80002ffc:	ec06                	sd	ra,24(sp)
    80002ffe:	e822                	sd	s0,16(sp)
    80003000:	e426                	sd	s1,8(sp)
    80003002:	1000                	addi	s0,sp,32
    80003004:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003006:	00014517          	auipc	a0,0x14
    8000300a:	9a250513          	addi	a0,a0,-1630 # 800169a8 <bcache>
    8000300e:	ffffe097          	auipc	ra,0xffffe
    80003012:	bc8080e7          	jalr	-1080(ra) # 80000bd6 <acquire>
  b->refcnt++;
    80003016:	40bc                	lw	a5,64(s1)
    80003018:	2785                	addiw	a5,a5,1
    8000301a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000301c:	00014517          	auipc	a0,0x14
    80003020:	98c50513          	addi	a0,a0,-1652 # 800169a8 <bcache>
    80003024:	ffffe097          	auipc	ra,0xffffe
    80003028:	c66080e7          	jalr	-922(ra) # 80000c8a <release>
}
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	64a2                	ld	s1,8(sp)
    80003032:	6105                	addi	sp,sp,32
    80003034:	8082                	ret

0000000080003036 <bunpin>:

void
bunpin(struct buf *b) {
    80003036:	1101                	addi	sp,sp,-32
    80003038:	ec06                	sd	ra,24(sp)
    8000303a:	e822                	sd	s0,16(sp)
    8000303c:	e426                	sd	s1,8(sp)
    8000303e:	1000                	addi	s0,sp,32
    80003040:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003042:	00014517          	auipc	a0,0x14
    80003046:	96650513          	addi	a0,a0,-1690 # 800169a8 <bcache>
    8000304a:	ffffe097          	auipc	ra,0xffffe
    8000304e:	b8c080e7          	jalr	-1140(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003052:	40bc                	lw	a5,64(s1)
    80003054:	37fd                	addiw	a5,a5,-1
    80003056:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003058:	00014517          	auipc	a0,0x14
    8000305c:	95050513          	addi	a0,a0,-1712 # 800169a8 <bcache>
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	c2a080e7          	jalr	-982(ra) # 80000c8a <release>
}
    80003068:	60e2                	ld	ra,24(sp)
    8000306a:	6442                	ld	s0,16(sp)
    8000306c:	64a2                	ld	s1,8(sp)
    8000306e:	6105                	addi	sp,sp,32
    80003070:	8082                	ret

0000000080003072 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003072:	1101                	addi	sp,sp,-32
    80003074:	ec06                	sd	ra,24(sp)
    80003076:	e822                	sd	s0,16(sp)
    80003078:	e426                	sd	s1,8(sp)
    8000307a:	e04a                	sd	s2,0(sp)
    8000307c:	1000                	addi	s0,sp,32
    8000307e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003080:	00d5d59b          	srliw	a1,a1,0xd
    80003084:	0001c797          	auipc	a5,0x1c
    80003088:	0007a783          	lw	a5,0(a5) # 8001f084 <sb+0x1c>
    8000308c:	9dbd                	addw	a1,a1,a5
    8000308e:	00000097          	auipc	ra,0x0
    80003092:	d9e080e7          	jalr	-610(ra) # 80002e2c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003096:	0074f713          	andi	a4,s1,7
    8000309a:	4785                	li	a5,1
    8000309c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030a0:	14ce                	slli	s1,s1,0x33
    800030a2:	90d9                	srli	s1,s1,0x36
    800030a4:	00950733          	add	a4,a0,s1
    800030a8:	05874703          	lbu	a4,88(a4)
    800030ac:	00e7f6b3          	and	a3,a5,a4
    800030b0:	c69d                	beqz	a3,800030de <bfree+0x6c>
    800030b2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030b4:	94aa                	add	s1,s1,a0
    800030b6:	fff7c793          	not	a5,a5
    800030ba:	8ff9                	and	a5,a5,a4
    800030bc:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800030c0:	00001097          	auipc	ra,0x1
    800030c4:	120080e7          	jalr	288(ra) # 800041e0 <log_write>
  brelse(bp);
    800030c8:	854a                	mv	a0,s2
    800030ca:	00000097          	auipc	ra,0x0
    800030ce:	e92080e7          	jalr	-366(ra) # 80002f5c <brelse>
}
    800030d2:	60e2                	ld	ra,24(sp)
    800030d4:	6442                	ld	s0,16(sp)
    800030d6:	64a2                	ld	s1,8(sp)
    800030d8:	6902                	ld	s2,0(sp)
    800030da:	6105                	addi	sp,sp,32
    800030dc:	8082                	ret
    panic("freeing free block");
    800030de:	00005517          	auipc	a0,0x5
    800030e2:	46250513          	addi	a0,a0,1122 # 80008540 <syscalls+0xf0>
    800030e6:	ffffd097          	auipc	ra,0xffffd
    800030ea:	458080e7          	jalr	1112(ra) # 8000053e <panic>

00000000800030ee <balloc>:
{
    800030ee:	711d                	addi	sp,sp,-96
    800030f0:	ec86                	sd	ra,88(sp)
    800030f2:	e8a2                	sd	s0,80(sp)
    800030f4:	e4a6                	sd	s1,72(sp)
    800030f6:	e0ca                	sd	s2,64(sp)
    800030f8:	fc4e                	sd	s3,56(sp)
    800030fa:	f852                	sd	s4,48(sp)
    800030fc:	f456                	sd	s5,40(sp)
    800030fe:	f05a                	sd	s6,32(sp)
    80003100:	ec5e                	sd	s7,24(sp)
    80003102:	e862                	sd	s8,16(sp)
    80003104:	e466                	sd	s9,8(sp)
    80003106:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003108:	0001c797          	auipc	a5,0x1c
    8000310c:	f647a783          	lw	a5,-156(a5) # 8001f06c <sb+0x4>
    80003110:	10078163          	beqz	a5,80003212 <balloc+0x124>
    80003114:	8baa                	mv	s7,a0
    80003116:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003118:	0001cb17          	auipc	s6,0x1c
    8000311c:	f50b0b13          	addi	s6,s6,-176 # 8001f068 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003120:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003122:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003124:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003126:	6c89                	lui	s9,0x2
    80003128:	a061                	j	800031b0 <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000312a:	974a                	add	a4,a4,s2
    8000312c:	8fd5                	or	a5,a5,a3
    8000312e:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003132:	854a                	mv	a0,s2
    80003134:	00001097          	auipc	ra,0x1
    80003138:	0ac080e7          	jalr	172(ra) # 800041e0 <log_write>
        brelse(bp);
    8000313c:	854a                	mv	a0,s2
    8000313e:	00000097          	auipc	ra,0x0
    80003142:	e1e080e7          	jalr	-482(ra) # 80002f5c <brelse>
  bp = bread(dev, bno);
    80003146:	85a6                	mv	a1,s1
    80003148:	855e                	mv	a0,s7
    8000314a:	00000097          	auipc	ra,0x0
    8000314e:	ce2080e7          	jalr	-798(ra) # 80002e2c <bread>
    80003152:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003154:	40000613          	li	a2,1024
    80003158:	4581                	li	a1,0
    8000315a:	05850513          	addi	a0,a0,88
    8000315e:	ffffe097          	auipc	ra,0xffffe
    80003162:	b74080e7          	jalr	-1164(ra) # 80000cd2 <memset>
  log_write(bp);
    80003166:	854a                	mv	a0,s2
    80003168:	00001097          	auipc	ra,0x1
    8000316c:	078080e7          	jalr	120(ra) # 800041e0 <log_write>
  brelse(bp);
    80003170:	854a                	mv	a0,s2
    80003172:	00000097          	auipc	ra,0x0
    80003176:	dea080e7          	jalr	-534(ra) # 80002f5c <brelse>
}
    8000317a:	8526                	mv	a0,s1
    8000317c:	60e6                	ld	ra,88(sp)
    8000317e:	6446                	ld	s0,80(sp)
    80003180:	64a6                	ld	s1,72(sp)
    80003182:	6906                	ld	s2,64(sp)
    80003184:	79e2                	ld	s3,56(sp)
    80003186:	7a42                	ld	s4,48(sp)
    80003188:	7aa2                	ld	s5,40(sp)
    8000318a:	7b02                	ld	s6,32(sp)
    8000318c:	6be2                	ld	s7,24(sp)
    8000318e:	6c42                	ld	s8,16(sp)
    80003190:	6ca2                	ld	s9,8(sp)
    80003192:	6125                	addi	sp,sp,96
    80003194:	8082                	ret
    brelse(bp);
    80003196:	854a                	mv	a0,s2
    80003198:	00000097          	auipc	ra,0x0
    8000319c:	dc4080e7          	jalr	-572(ra) # 80002f5c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800031a0:	015c87bb          	addw	a5,s9,s5
    800031a4:	00078a9b          	sext.w	s5,a5
    800031a8:	004b2703          	lw	a4,4(s6)
    800031ac:	06eaf363          	bgeu	s5,a4,80003212 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800031b0:	41fad79b          	sraiw	a5,s5,0x1f
    800031b4:	0137d79b          	srliw	a5,a5,0x13
    800031b8:	015787bb          	addw	a5,a5,s5
    800031bc:	40d7d79b          	sraiw	a5,a5,0xd
    800031c0:	01cb2583          	lw	a1,28(s6)
    800031c4:	9dbd                	addw	a1,a1,a5
    800031c6:	855e                	mv	a0,s7
    800031c8:	00000097          	auipc	ra,0x0
    800031cc:	c64080e7          	jalr	-924(ra) # 80002e2c <bread>
    800031d0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d2:	004b2503          	lw	a0,4(s6)
    800031d6:	000a849b          	sext.w	s1,s5
    800031da:	8662                	mv	a2,s8
    800031dc:	faa4fde3          	bgeu	s1,a0,80003196 <balloc+0xa8>
      m = 1 << (bi % 8);
    800031e0:	41f6579b          	sraiw	a5,a2,0x1f
    800031e4:	01d7d69b          	srliw	a3,a5,0x1d
    800031e8:	00c6873b          	addw	a4,a3,a2
    800031ec:	00777793          	andi	a5,a4,7
    800031f0:	9f95                	subw	a5,a5,a3
    800031f2:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031f6:	4037571b          	sraiw	a4,a4,0x3
    800031fa:	00e906b3          	add	a3,s2,a4
    800031fe:	0586c683          	lbu	a3,88(a3)
    80003202:	00d7f5b3          	and	a1,a5,a3
    80003206:	d195                	beqz	a1,8000312a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003208:	2605                	addiw	a2,a2,1
    8000320a:	2485                	addiw	s1,s1,1
    8000320c:	fd4618e3          	bne	a2,s4,800031dc <balloc+0xee>
    80003210:	b759                	j	80003196 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80003212:	00005517          	auipc	a0,0x5
    80003216:	34650513          	addi	a0,a0,838 # 80008558 <syscalls+0x108>
    8000321a:	ffffd097          	auipc	ra,0xffffd
    8000321e:	36e080e7          	jalr	878(ra) # 80000588 <printf>
  return 0;
    80003222:	4481                	li	s1,0
    80003224:	bf99                	j	8000317a <balloc+0x8c>

0000000080003226 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003226:	7179                	addi	sp,sp,-48
    80003228:	f406                	sd	ra,40(sp)
    8000322a:	f022                	sd	s0,32(sp)
    8000322c:	ec26                	sd	s1,24(sp)
    8000322e:	e84a                	sd	s2,16(sp)
    80003230:	e44e                	sd	s3,8(sp)
    80003232:	e052                	sd	s4,0(sp)
    80003234:	1800                	addi	s0,sp,48
    80003236:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003238:	47ad                	li	a5,11
    8000323a:	02b7e763          	bltu	a5,a1,80003268 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    8000323e:	02059493          	slli	s1,a1,0x20
    80003242:	9081                	srli	s1,s1,0x20
    80003244:	048a                	slli	s1,s1,0x2
    80003246:	94aa                	add	s1,s1,a0
    80003248:	0504a903          	lw	s2,80(s1)
    8000324c:	06091e63          	bnez	s2,800032c8 <bmap+0xa2>
      addr = balloc(ip->dev);
    80003250:	4108                	lw	a0,0(a0)
    80003252:	00000097          	auipc	ra,0x0
    80003256:	e9c080e7          	jalr	-356(ra) # 800030ee <balloc>
    8000325a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000325e:	06090563          	beqz	s2,800032c8 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80003262:	0524a823          	sw	s2,80(s1)
    80003266:	a08d                	j	800032c8 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003268:	ff45849b          	addiw	s1,a1,-12
    8000326c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003270:	0ff00793          	li	a5,255
    80003274:	08e7e563          	bltu	a5,a4,800032fe <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003278:	08052903          	lw	s2,128(a0)
    8000327c:	00091d63          	bnez	s2,80003296 <bmap+0x70>
      addr = balloc(ip->dev);
    80003280:	4108                	lw	a0,0(a0)
    80003282:	00000097          	auipc	ra,0x0
    80003286:	e6c080e7          	jalr	-404(ra) # 800030ee <balloc>
    8000328a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000328e:	02090d63          	beqz	s2,800032c8 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003292:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003296:	85ca                	mv	a1,s2
    80003298:	0009a503          	lw	a0,0(s3)
    8000329c:	00000097          	auipc	ra,0x0
    800032a0:	b90080e7          	jalr	-1136(ra) # 80002e2c <bread>
    800032a4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800032a6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800032aa:	02049593          	slli	a1,s1,0x20
    800032ae:	9181                	srli	a1,a1,0x20
    800032b0:	058a                	slli	a1,a1,0x2
    800032b2:	00b784b3          	add	s1,a5,a1
    800032b6:	0004a903          	lw	s2,0(s1)
    800032ba:	02090063          	beqz	s2,800032da <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800032be:	8552                	mv	a0,s4
    800032c0:	00000097          	auipc	ra,0x0
    800032c4:	c9c080e7          	jalr	-868(ra) # 80002f5c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032c8:	854a                	mv	a0,s2
    800032ca:	70a2                	ld	ra,40(sp)
    800032cc:	7402                	ld	s0,32(sp)
    800032ce:	64e2                	ld	s1,24(sp)
    800032d0:	6942                	ld	s2,16(sp)
    800032d2:	69a2                	ld	s3,8(sp)
    800032d4:	6a02                	ld	s4,0(sp)
    800032d6:	6145                	addi	sp,sp,48
    800032d8:	8082                	ret
      addr = balloc(ip->dev);
    800032da:	0009a503          	lw	a0,0(s3)
    800032de:	00000097          	auipc	ra,0x0
    800032e2:	e10080e7          	jalr	-496(ra) # 800030ee <balloc>
    800032e6:	0005091b          	sext.w	s2,a0
      if(addr){
    800032ea:	fc090ae3          	beqz	s2,800032be <bmap+0x98>
        a[bn] = addr;
    800032ee:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032f2:	8552                	mv	a0,s4
    800032f4:	00001097          	auipc	ra,0x1
    800032f8:	eec080e7          	jalr	-276(ra) # 800041e0 <log_write>
    800032fc:	b7c9                	j	800032be <bmap+0x98>
  panic("bmap: out of range");
    800032fe:	00005517          	auipc	a0,0x5
    80003302:	27250513          	addi	a0,a0,626 # 80008570 <syscalls+0x120>
    80003306:	ffffd097          	auipc	ra,0xffffd
    8000330a:	238080e7          	jalr	568(ra) # 8000053e <panic>

000000008000330e <iget>:
{
    8000330e:	7179                	addi	sp,sp,-48
    80003310:	f406                	sd	ra,40(sp)
    80003312:	f022                	sd	s0,32(sp)
    80003314:	ec26                	sd	s1,24(sp)
    80003316:	e84a                	sd	s2,16(sp)
    80003318:	e44e                	sd	s3,8(sp)
    8000331a:	e052                	sd	s4,0(sp)
    8000331c:	1800                	addi	s0,sp,48
    8000331e:	89aa                	mv	s3,a0
    80003320:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003322:	0001c517          	auipc	a0,0x1c
    80003326:	d6650513          	addi	a0,a0,-666 # 8001f088 <itable>
    8000332a:	ffffe097          	auipc	ra,0xffffe
    8000332e:	8ac080e7          	jalr	-1876(ra) # 80000bd6 <acquire>
  empty = 0;
    80003332:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003334:	0001c497          	auipc	s1,0x1c
    80003338:	d6c48493          	addi	s1,s1,-660 # 8001f0a0 <itable+0x18>
    8000333c:	0001d697          	auipc	a3,0x1d
    80003340:	7f468693          	addi	a3,a3,2036 # 80020b30 <log>
    80003344:	a039                	j	80003352 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003346:	02090b63          	beqz	s2,8000337c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000334a:	08848493          	addi	s1,s1,136
    8000334e:	02d48a63          	beq	s1,a3,80003382 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003352:	449c                	lw	a5,8(s1)
    80003354:	fef059e3          	blez	a5,80003346 <iget+0x38>
    80003358:	4098                	lw	a4,0(s1)
    8000335a:	ff3716e3          	bne	a4,s3,80003346 <iget+0x38>
    8000335e:	40d8                	lw	a4,4(s1)
    80003360:	ff4713e3          	bne	a4,s4,80003346 <iget+0x38>
      ip->ref++;
    80003364:	2785                	addiw	a5,a5,1
    80003366:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003368:	0001c517          	auipc	a0,0x1c
    8000336c:	d2050513          	addi	a0,a0,-736 # 8001f088 <itable>
    80003370:	ffffe097          	auipc	ra,0xffffe
    80003374:	91a080e7          	jalr	-1766(ra) # 80000c8a <release>
      return ip;
    80003378:	8926                	mv	s2,s1
    8000337a:	a03d                	j	800033a8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000337c:	f7f9                	bnez	a5,8000334a <iget+0x3c>
    8000337e:	8926                	mv	s2,s1
    80003380:	b7e9                	j	8000334a <iget+0x3c>
  if(empty == 0)
    80003382:	02090c63          	beqz	s2,800033ba <iget+0xac>
  ip->dev = dev;
    80003386:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000338a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000338e:	4785                	li	a5,1
    80003390:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003394:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003398:	0001c517          	auipc	a0,0x1c
    8000339c:	cf050513          	addi	a0,a0,-784 # 8001f088 <itable>
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	8ea080e7          	jalr	-1814(ra) # 80000c8a <release>
}
    800033a8:	854a                	mv	a0,s2
    800033aa:	70a2                	ld	ra,40(sp)
    800033ac:	7402                	ld	s0,32(sp)
    800033ae:	64e2                	ld	s1,24(sp)
    800033b0:	6942                	ld	s2,16(sp)
    800033b2:	69a2                	ld	s3,8(sp)
    800033b4:	6a02                	ld	s4,0(sp)
    800033b6:	6145                	addi	sp,sp,48
    800033b8:	8082                	ret
    panic("iget: no inodes");
    800033ba:	00005517          	auipc	a0,0x5
    800033be:	1ce50513          	addi	a0,a0,462 # 80008588 <syscalls+0x138>
    800033c2:	ffffd097          	auipc	ra,0xffffd
    800033c6:	17c080e7          	jalr	380(ra) # 8000053e <panic>

00000000800033ca <fsinit>:
fsinit(int dev) {
    800033ca:	7179                	addi	sp,sp,-48
    800033cc:	f406                	sd	ra,40(sp)
    800033ce:	f022                	sd	s0,32(sp)
    800033d0:	ec26                	sd	s1,24(sp)
    800033d2:	e84a                	sd	s2,16(sp)
    800033d4:	e44e                	sd	s3,8(sp)
    800033d6:	1800                	addi	s0,sp,48
    800033d8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033da:	4585                	li	a1,1
    800033dc:	00000097          	auipc	ra,0x0
    800033e0:	a50080e7          	jalr	-1456(ra) # 80002e2c <bread>
    800033e4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033e6:	0001c997          	auipc	s3,0x1c
    800033ea:	c8298993          	addi	s3,s3,-894 # 8001f068 <sb>
    800033ee:	02000613          	li	a2,32
    800033f2:	05850593          	addi	a1,a0,88
    800033f6:	854e                	mv	a0,s3
    800033f8:	ffffe097          	auipc	ra,0xffffe
    800033fc:	936080e7          	jalr	-1738(ra) # 80000d2e <memmove>
  brelse(bp);
    80003400:	8526                	mv	a0,s1
    80003402:	00000097          	auipc	ra,0x0
    80003406:	b5a080e7          	jalr	-1190(ra) # 80002f5c <brelse>
  if(sb.magic != FSMAGIC)
    8000340a:	0009a703          	lw	a4,0(s3)
    8000340e:	102037b7          	lui	a5,0x10203
    80003412:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003416:	02f71263          	bne	a4,a5,8000343a <fsinit+0x70>
  initlog(dev, &sb);
    8000341a:	0001c597          	auipc	a1,0x1c
    8000341e:	c4e58593          	addi	a1,a1,-946 # 8001f068 <sb>
    80003422:	854a                	mv	a0,s2
    80003424:	00001097          	auipc	ra,0x1
    80003428:	b40080e7          	jalr	-1216(ra) # 80003f64 <initlog>
}
    8000342c:	70a2                	ld	ra,40(sp)
    8000342e:	7402                	ld	s0,32(sp)
    80003430:	64e2                	ld	s1,24(sp)
    80003432:	6942                	ld	s2,16(sp)
    80003434:	69a2                	ld	s3,8(sp)
    80003436:	6145                	addi	sp,sp,48
    80003438:	8082                	ret
    panic("invalid file system");
    8000343a:	00005517          	auipc	a0,0x5
    8000343e:	15e50513          	addi	a0,a0,350 # 80008598 <syscalls+0x148>
    80003442:	ffffd097          	auipc	ra,0xffffd
    80003446:	0fc080e7          	jalr	252(ra) # 8000053e <panic>

000000008000344a <iinit>:
{
    8000344a:	7179                	addi	sp,sp,-48
    8000344c:	f406                	sd	ra,40(sp)
    8000344e:	f022                	sd	s0,32(sp)
    80003450:	ec26                	sd	s1,24(sp)
    80003452:	e84a                	sd	s2,16(sp)
    80003454:	e44e                	sd	s3,8(sp)
    80003456:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003458:	00005597          	auipc	a1,0x5
    8000345c:	15858593          	addi	a1,a1,344 # 800085b0 <syscalls+0x160>
    80003460:	0001c517          	auipc	a0,0x1c
    80003464:	c2850513          	addi	a0,a0,-984 # 8001f088 <itable>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003470:	0001c497          	auipc	s1,0x1c
    80003474:	c4048493          	addi	s1,s1,-960 # 8001f0b0 <itable+0x28>
    80003478:	0001d997          	auipc	s3,0x1d
    8000347c:	6c898993          	addi	s3,s3,1736 # 80020b40 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003480:	00005917          	auipc	s2,0x5
    80003484:	13890913          	addi	s2,s2,312 # 800085b8 <syscalls+0x168>
    80003488:	85ca                	mv	a1,s2
    8000348a:	8526                	mv	a0,s1
    8000348c:	00001097          	auipc	ra,0x1
    80003490:	e3a080e7          	jalr	-454(ra) # 800042c6 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003494:	08848493          	addi	s1,s1,136
    80003498:	ff3498e3          	bne	s1,s3,80003488 <iinit+0x3e>
}
    8000349c:	70a2                	ld	ra,40(sp)
    8000349e:	7402                	ld	s0,32(sp)
    800034a0:	64e2                	ld	s1,24(sp)
    800034a2:	6942                	ld	s2,16(sp)
    800034a4:	69a2                	ld	s3,8(sp)
    800034a6:	6145                	addi	sp,sp,48
    800034a8:	8082                	ret

00000000800034aa <ialloc>:
{
    800034aa:	715d                	addi	sp,sp,-80
    800034ac:	e486                	sd	ra,72(sp)
    800034ae:	e0a2                	sd	s0,64(sp)
    800034b0:	fc26                	sd	s1,56(sp)
    800034b2:	f84a                	sd	s2,48(sp)
    800034b4:	f44e                	sd	s3,40(sp)
    800034b6:	f052                	sd	s4,32(sp)
    800034b8:	ec56                	sd	s5,24(sp)
    800034ba:	e85a                	sd	s6,16(sp)
    800034bc:	e45e                	sd	s7,8(sp)
    800034be:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800034c0:	0001c717          	auipc	a4,0x1c
    800034c4:	bb472703          	lw	a4,-1100(a4) # 8001f074 <sb+0xc>
    800034c8:	4785                	li	a5,1
    800034ca:	04e7fa63          	bgeu	a5,a4,8000351e <ialloc+0x74>
    800034ce:	8aaa                	mv	s5,a0
    800034d0:	8bae                	mv	s7,a1
    800034d2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034d4:	0001ca17          	auipc	s4,0x1c
    800034d8:	b94a0a13          	addi	s4,s4,-1132 # 8001f068 <sb>
    800034dc:	00048b1b          	sext.w	s6,s1
    800034e0:	0044d793          	srli	a5,s1,0x4
    800034e4:	018a2583          	lw	a1,24(s4)
    800034e8:	9dbd                	addw	a1,a1,a5
    800034ea:	8556                	mv	a0,s5
    800034ec:	00000097          	auipc	ra,0x0
    800034f0:	940080e7          	jalr	-1728(ra) # 80002e2c <bread>
    800034f4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034f6:	05850993          	addi	s3,a0,88
    800034fa:	00f4f793          	andi	a5,s1,15
    800034fe:	079a                	slli	a5,a5,0x6
    80003500:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003502:	00099783          	lh	a5,0(s3)
    80003506:	c3a1                	beqz	a5,80003546 <ialloc+0x9c>
    brelse(bp);
    80003508:	00000097          	auipc	ra,0x0
    8000350c:	a54080e7          	jalr	-1452(ra) # 80002f5c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003510:	0485                	addi	s1,s1,1
    80003512:	00ca2703          	lw	a4,12(s4)
    80003516:	0004879b          	sext.w	a5,s1
    8000351a:	fce7e1e3          	bltu	a5,a4,800034dc <ialloc+0x32>
  printf("ialloc: no inodes\n");
    8000351e:	00005517          	auipc	a0,0x5
    80003522:	0a250513          	addi	a0,a0,162 # 800085c0 <syscalls+0x170>
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	062080e7          	jalr	98(ra) # 80000588 <printf>
  return 0;
    8000352e:	4501                	li	a0,0
}
    80003530:	60a6                	ld	ra,72(sp)
    80003532:	6406                	ld	s0,64(sp)
    80003534:	74e2                	ld	s1,56(sp)
    80003536:	7942                	ld	s2,48(sp)
    80003538:	79a2                	ld	s3,40(sp)
    8000353a:	7a02                	ld	s4,32(sp)
    8000353c:	6ae2                	ld	s5,24(sp)
    8000353e:	6b42                	ld	s6,16(sp)
    80003540:	6ba2                	ld	s7,8(sp)
    80003542:	6161                	addi	sp,sp,80
    80003544:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003546:	04000613          	li	a2,64
    8000354a:	4581                	li	a1,0
    8000354c:	854e                	mv	a0,s3
    8000354e:	ffffd097          	auipc	ra,0xffffd
    80003552:	784080e7          	jalr	1924(ra) # 80000cd2 <memset>
      dip->type = type;
    80003556:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000355a:	854a                	mv	a0,s2
    8000355c:	00001097          	auipc	ra,0x1
    80003560:	c84080e7          	jalr	-892(ra) # 800041e0 <log_write>
      brelse(bp);
    80003564:	854a                	mv	a0,s2
    80003566:	00000097          	auipc	ra,0x0
    8000356a:	9f6080e7          	jalr	-1546(ra) # 80002f5c <brelse>
      return iget(dev, inum);
    8000356e:	85da                	mv	a1,s6
    80003570:	8556                	mv	a0,s5
    80003572:	00000097          	auipc	ra,0x0
    80003576:	d9c080e7          	jalr	-612(ra) # 8000330e <iget>
    8000357a:	bf5d                	j	80003530 <ialloc+0x86>

000000008000357c <iupdate>:
{
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	e426                	sd	s1,8(sp)
    80003584:	e04a                	sd	s2,0(sp)
    80003586:	1000                	addi	s0,sp,32
    80003588:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000358a:	415c                	lw	a5,4(a0)
    8000358c:	0047d79b          	srliw	a5,a5,0x4
    80003590:	0001c597          	auipc	a1,0x1c
    80003594:	af05a583          	lw	a1,-1296(a1) # 8001f080 <sb+0x18>
    80003598:	9dbd                	addw	a1,a1,a5
    8000359a:	4108                	lw	a0,0(a0)
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	890080e7          	jalr	-1904(ra) # 80002e2c <bread>
    800035a4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035a6:	05850793          	addi	a5,a0,88
    800035aa:	40c8                	lw	a0,4(s1)
    800035ac:	893d                	andi	a0,a0,15
    800035ae:	051a                	slli	a0,a0,0x6
    800035b0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800035b2:	04449703          	lh	a4,68(s1)
    800035b6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800035ba:	04649703          	lh	a4,70(s1)
    800035be:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800035c2:	04849703          	lh	a4,72(s1)
    800035c6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800035ca:	04a49703          	lh	a4,74(s1)
    800035ce:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800035d2:	44f8                	lw	a4,76(s1)
    800035d4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035d6:	03400613          	li	a2,52
    800035da:	05048593          	addi	a1,s1,80
    800035de:	0531                	addi	a0,a0,12
    800035e0:	ffffd097          	auipc	ra,0xffffd
    800035e4:	74e080e7          	jalr	1870(ra) # 80000d2e <memmove>
  log_write(bp);
    800035e8:	854a                	mv	a0,s2
    800035ea:	00001097          	auipc	ra,0x1
    800035ee:	bf6080e7          	jalr	-1034(ra) # 800041e0 <log_write>
  brelse(bp);
    800035f2:	854a                	mv	a0,s2
    800035f4:	00000097          	auipc	ra,0x0
    800035f8:	968080e7          	jalr	-1688(ra) # 80002f5c <brelse>
}
    800035fc:	60e2                	ld	ra,24(sp)
    800035fe:	6442                	ld	s0,16(sp)
    80003600:	64a2                	ld	s1,8(sp)
    80003602:	6902                	ld	s2,0(sp)
    80003604:	6105                	addi	sp,sp,32
    80003606:	8082                	ret

0000000080003608 <idup>:
{
    80003608:	1101                	addi	sp,sp,-32
    8000360a:	ec06                	sd	ra,24(sp)
    8000360c:	e822                	sd	s0,16(sp)
    8000360e:	e426                	sd	s1,8(sp)
    80003610:	1000                	addi	s0,sp,32
    80003612:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003614:	0001c517          	auipc	a0,0x1c
    80003618:	a7450513          	addi	a0,a0,-1420 # 8001f088 <itable>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	5ba080e7          	jalr	1466(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003624:	449c                	lw	a5,8(s1)
    80003626:	2785                	addiw	a5,a5,1
    80003628:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000362a:	0001c517          	auipc	a0,0x1c
    8000362e:	a5e50513          	addi	a0,a0,-1442 # 8001f088 <itable>
    80003632:	ffffd097          	auipc	ra,0xffffd
    80003636:	658080e7          	jalr	1624(ra) # 80000c8a <release>
}
    8000363a:	8526                	mv	a0,s1
    8000363c:	60e2                	ld	ra,24(sp)
    8000363e:	6442                	ld	s0,16(sp)
    80003640:	64a2                	ld	s1,8(sp)
    80003642:	6105                	addi	sp,sp,32
    80003644:	8082                	ret

0000000080003646 <ilock>:
{
    80003646:	1101                	addi	sp,sp,-32
    80003648:	ec06                	sd	ra,24(sp)
    8000364a:	e822                	sd	s0,16(sp)
    8000364c:	e426                	sd	s1,8(sp)
    8000364e:	e04a                	sd	s2,0(sp)
    80003650:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003652:	c115                	beqz	a0,80003676 <ilock+0x30>
    80003654:	84aa                	mv	s1,a0
    80003656:	451c                	lw	a5,8(a0)
    80003658:	00f05f63          	blez	a5,80003676 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000365c:	0541                	addi	a0,a0,16
    8000365e:	00001097          	auipc	ra,0x1
    80003662:	ca2080e7          	jalr	-862(ra) # 80004300 <acquiresleep>
  if(ip->valid == 0){
    80003666:	40bc                	lw	a5,64(s1)
    80003668:	cf99                	beqz	a5,80003686 <ilock+0x40>
}
    8000366a:	60e2                	ld	ra,24(sp)
    8000366c:	6442                	ld	s0,16(sp)
    8000366e:	64a2                	ld	s1,8(sp)
    80003670:	6902                	ld	s2,0(sp)
    80003672:	6105                	addi	sp,sp,32
    80003674:	8082                	ret
    panic("ilock");
    80003676:	00005517          	auipc	a0,0x5
    8000367a:	f6250513          	addi	a0,a0,-158 # 800085d8 <syscalls+0x188>
    8000367e:	ffffd097          	auipc	ra,0xffffd
    80003682:	ec0080e7          	jalr	-320(ra) # 8000053e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003686:	40dc                	lw	a5,4(s1)
    80003688:	0047d79b          	srliw	a5,a5,0x4
    8000368c:	0001c597          	auipc	a1,0x1c
    80003690:	9f45a583          	lw	a1,-1548(a1) # 8001f080 <sb+0x18>
    80003694:	9dbd                	addw	a1,a1,a5
    80003696:	4088                	lw	a0,0(s1)
    80003698:	fffff097          	auipc	ra,0xfffff
    8000369c:	794080e7          	jalr	1940(ra) # 80002e2c <bread>
    800036a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a2:	05850593          	addi	a1,a0,88
    800036a6:	40dc                	lw	a5,4(s1)
    800036a8:	8bbd                	andi	a5,a5,15
    800036aa:	079a                	slli	a5,a5,0x6
    800036ac:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036ae:	00059783          	lh	a5,0(a1)
    800036b2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036b6:	00259783          	lh	a5,2(a1)
    800036ba:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036be:	00459783          	lh	a5,4(a1)
    800036c2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036c6:	00659783          	lh	a5,6(a1)
    800036ca:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036ce:	459c                	lw	a5,8(a1)
    800036d0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036d2:	03400613          	li	a2,52
    800036d6:	05b1                	addi	a1,a1,12
    800036d8:	05048513          	addi	a0,s1,80
    800036dc:	ffffd097          	auipc	ra,0xffffd
    800036e0:	652080e7          	jalr	1618(ra) # 80000d2e <memmove>
    brelse(bp);
    800036e4:	854a                	mv	a0,s2
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	876080e7          	jalr	-1930(ra) # 80002f5c <brelse>
    ip->valid = 1;
    800036ee:	4785                	li	a5,1
    800036f0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036f2:	04449783          	lh	a5,68(s1)
    800036f6:	fbb5                	bnez	a5,8000366a <ilock+0x24>
      panic("ilock: no type");
    800036f8:	00005517          	auipc	a0,0x5
    800036fc:	ee850513          	addi	a0,a0,-280 # 800085e0 <syscalls+0x190>
    80003700:	ffffd097          	auipc	ra,0xffffd
    80003704:	e3e080e7          	jalr	-450(ra) # 8000053e <panic>

0000000080003708 <iunlock>:
{
    80003708:	1101                	addi	sp,sp,-32
    8000370a:	ec06                	sd	ra,24(sp)
    8000370c:	e822                	sd	s0,16(sp)
    8000370e:	e426                	sd	s1,8(sp)
    80003710:	e04a                	sd	s2,0(sp)
    80003712:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003714:	c905                	beqz	a0,80003744 <iunlock+0x3c>
    80003716:	84aa                	mv	s1,a0
    80003718:	01050913          	addi	s2,a0,16
    8000371c:	854a                	mv	a0,s2
    8000371e:	00001097          	auipc	ra,0x1
    80003722:	c7c080e7          	jalr	-900(ra) # 8000439a <holdingsleep>
    80003726:	cd19                	beqz	a0,80003744 <iunlock+0x3c>
    80003728:	449c                	lw	a5,8(s1)
    8000372a:	00f05d63          	blez	a5,80003744 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000372e:	854a                	mv	a0,s2
    80003730:	00001097          	auipc	ra,0x1
    80003734:	c26080e7          	jalr	-986(ra) # 80004356 <releasesleep>
}
    80003738:	60e2                	ld	ra,24(sp)
    8000373a:	6442                	ld	s0,16(sp)
    8000373c:	64a2                	ld	s1,8(sp)
    8000373e:	6902                	ld	s2,0(sp)
    80003740:	6105                	addi	sp,sp,32
    80003742:	8082                	ret
    panic("iunlock");
    80003744:	00005517          	auipc	a0,0x5
    80003748:	eac50513          	addi	a0,a0,-340 # 800085f0 <syscalls+0x1a0>
    8000374c:	ffffd097          	auipc	ra,0xffffd
    80003750:	df2080e7          	jalr	-526(ra) # 8000053e <panic>

0000000080003754 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003754:	7179                	addi	sp,sp,-48
    80003756:	f406                	sd	ra,40(sp)
    80003758:	f022                	sd	s0,32(sp)
    8000375a:	ec26                	sd	s1,24(sp)
    8000375c:	e84a                	sd	s2,16(sp)
    8000375e:	e44e                	sd	s3,8(sp)
    80003760:	e052                	sd	s4,0(sp)
    80003762:	1800                	addi	s0,sp,48
    80003764:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003766:	05050493          	addi	s1,a0,80
    8000376a:	08050913          	addi	s2,a0,128
    8000376e:	a021                	j	80003776 <itrunc+0x22>
    80003770:	0491                	addi	s1,s1,4
    80003772:	01248d63          	beq	s1,s2,8000378c <itrunc+0x38>
    if(ip->addrs[i]){
    80003776:	408c                	lw	a1,0(s1)
    80003778:	dde5                	beqz	a1,80003770 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000377a:	0009a503          	lw	a0,0(s3)
    8000377e:	00000097          	auipc	ra,0x0
    80003782:	8f4080e7          	jalr	-1804(ra) # 80003072 <bfree>
      ip->addrs[i] = 0;
    80003786:	0004a023          	sw	zero,0(s1)
    8000378a:	b7dd                	j	80003770 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000378c:	0809a583          	lw	a1,128(s3)
    80003790:	e185                	bnez	a1,800037b0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003792:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003796:	854e                	mv	a0,s3
    80003798:	00000097          	auipc	ra,0x0
    8000379c:	de4080e7          	jalr	-540(ra) # 8000357c <iupdate>
}
    800037a0:	70a2                	ld	ra,40(sp)
    800037a2:	7402                	ld	s0,32(sp)
    800037a4:	64e2                	ld	s1,24(sp)
    800037a6:	6942                	ld	s2,16(sp)
    800037a8:	69a2                	ld	s3,8(sp)
    800037aa:	6a02                	ld	s4,0(sp)
    800037ac:	6145                	addi	sp,sp,48
    800037ae:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037b0:	0009a503          	lw	a0,0(s3)
    800037b4:	fffff097          	auipc	ra,0xfffff
    800037b8:	678080e7          	jalr	1656(ra) # 80002e2c <bread>
    800037bc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037be:	05850493          	addi	s1,a0,88
    800037c2:	45850913          	addi	s2,a0,1112
    800037c6:	a021                	j	800037ce <itrunc+0x7a>
    800037c8:	0491                	addi	s1,s1,4
    800037ca:	01248b63          	beq	s1,s2,800037e0 <itrunc+0x8c>
      if(a[j])
    800037ce:	408c                	lw	a1,0(s1)
    800037d0:	dde5                	beqz	a1,800037c8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037d2:	0009a503          	lw	a0,0(s3)
    800037d6:	00000097          	auipc	ra,0x0
    800037da:	89c080e7          	jalr	-1892(ra) # 80003072 <bfree>
    800037de:	b7ed                	j	800037c8 <itrunc+0x74>
    brelse(bp);
    800037e0:	8552                	mv	a0,s4
    800037e2:	fffff097          	auipc	ra,0xfffff
    800037e6:	77a080e7          	jalr	1914(ra) # 80002f5c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037ea:	0809a583          	lw	a1,128(s3)
    800037ee:	0009a503          	lw	a0,0(s3)
    800037f2:	00000097          	auipc	ra,0x0
    800037f6:	880080e7          	jalr	-1920(ra) # 80003072 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037fa:	0809a023          	sw	zero,128(s3)
    800037fe:	bf51                	j	80003792 <itrunc+0x3e>

0000000080003800 <iput>:
{
    80003800:	1101                	addi	sp,sp,-32
    80003802:	ec06                	sd	ra,24(sp)
    80003804:	e822                	sd	s0,16(sp)
    80003806:	e426                	sd	s1,8(sp)
    80003808:	e04a                	sd	s2,0(sp)
    8000380a:	1000                	addi	s0,sp,32
    8000380c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000380e:	0001c517          	auipc	a0,0x1c
    80003812:	87a50513          	addi	a0,a0,-1926 # 8001f088 <itable>
    80003816:	ffffd097          	auipc	ra,0xffffd
    8000381a:	3c0080e7          	jalr	960(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000381e:	4498                	lw	a4,8(s1)
    80003820:	4785                	li	a5,1
    80003822:	02f70363          	beq	a4,a5,80003848 <iput+0x48>
  ip->ref--;
    80003826:	449c                	lw	a5,8(s1)
    80003828:	37fd                	addiw	a5,a5,-1
    8000382a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000382c:	0001c517          	auipc	a0,0x1c
    80003830:	85c50513          	addi	a0,a0,-1956 # 8001f088 <itable>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	456080e7          	jalr	1110(ra) # 80000c8a <release>
}
    8000383c:	60e2                	ld	ra,24(sp)
    8000383e:	6442                	ld	s0,16(sp)
    80003840:	64a2                	ld	s1,8(sp)
    80003842:	6902                	ld	s2,0(sp)
    80003844:	6105                	addi	sp,sp,32
    80003846:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003848:	40bc                	lw	a5,64(s1)
    8000384a:	dff1                	beqz	a5,80003826 <iput+0x26>
    8000384c:	04a49783          	lh	a5,74(s1)
    80003850:	fbf9                	bnez	a5,80003826 <iput+0x26>
    acquiresleep(&ip->lock);
    80003852:	01048913          	addi	s2,s1,16
    80003856:	854a                	mv	a0,s2
    80003858:	00001097          	auipc	ra,0x1
    8000385c:	aa8080e7          	jalr	-1368(ra) # 80004300 <acquiresleep>
    release(&itable.lock);
    80003860:	0001c517          	auipc	a0,0x1c
    80003864:	82850513          	addi	a0,a0,-2008 # 8001f088 <itable>
    80003868:	ffffd097          	auipc	ra,0xffffd
    8000386c:	422080e7          	jalr	1058(ra) # 80000c8a <release>
    itrunc(ip);
    80003870:	8526                	mv	a0,s1
    80003872:	00000097          	auipc	ra,0x0
    80003876:	ee2080e7          	jalr	-286(ra) # 80003754 <itrunc>
    ip->type = 0;
    8000387a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000387e:	8526                	mv	a0,s1
    80003880:	00000097          	auipc	ra,0x0
    80003884:	cfc080e7          	jalr	-772(ra) # 8000357c <iupdate>
    ip->valid = 0;
    80003888:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000388c:	854a                	mv	a0,s2
    8000388e:	00001097          	auipc	ra,0x1
    80003892:	ac8080e7          	jalr	-1336(ra) # 80004356 <releasesleep>
    acquire(&itable.lock);
    80003896:	0001b517          	auipc	a0,0x1b
    8000389a:	7f250513          	addi	a0,a0,2034 # 8001f088 <itable>
    8000389e:	ffffd097          	auipc	ra,0xffffd
    800038a2:	338080e7          	jalr	824(ra) # 80000bd6 <acquire>
    800038a6:	b741                	j	80003826 <iput+0x26>

00000000800038a8 <iunlockput>:
{
    800038a8:	1101                	addi	sp,sp,-32
    800038aa:	ec06                	sd	ra,24(sp)
    800038ac:	e822                	sd	s0,16(sp)
    800038ae:	e426                	sd	s1,8(sp)
    800038b0:	1000                	addi	s0,sp,32
    800038b2:	84aa                	mv	s1,a0
  iunlock(ip);
    800038b4:	00000097          	auipc	ra,0x0
    800038b8:	e54080e7          	jalr	-428(ra) # 80003708 <iunlock>
  iput(ip);
    800038bc:	8526                	mv	a0,s1
    800038be:	00000097          	auipc	ra,0x0
    800038c2:	f42080e7          	jalr	-190(ra) # 80003800 <iput>
}
    800038c6:	60e2                	ld	ra,24(sp)
    800038c8:	6442                	ld	s0,16(sp)
    800038ca:	64a2                	ld	s1,8(sp)
    800038cc:	6105                	addi	sp,sp,32
    800038ce:	8082                	ret

00000000800038d0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038d0:	1141                	addi	sp,sp,-16
    800038d2:	e422                	sd	s0,8(sp)
    800038d4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038d6:	411c                	lw	a5,0(a0)
    800038d8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038da:	415c                	lw	a5,4(a0)
    800038dc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038de:	04451783          	lh	a5,68(a0)
    800038e2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038e6:	04a51783          	lh	a5,74(a0)
    800038ea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038ee:	04c56783          	lwu	a5,76(a0)
    800038f2:	e99c                	sd	a5,16(a1)
}
    800038f4:	6422                	ld	s0,8(sp)
    800038f6:	0141                	addi	sp,sp,16
    800038f8:	8082                	ret

00000000800038fa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038fa:	457c                	lw	a5,76(a0)
    800038fc:	0ed7e963          	bltu	a5,a3,800039ee <readi+0xf4>
{
    80003900:	7159                	addi	sp,sp,-112
    80003902:	f486                	sd	ra,104(sp)
    80003904:	f0a2                	sd	s0,96(sp)
    80003906:	eca6                	sd	s1,88(sp)
    80003908:	e8ca                	sd	s2,80(sp)
    8000390a:	e4ce                	sd	s3,72(sp)
    8000390c:	e0d2                	sd	s4,64(sp)
    8000390e:	fc56                	sd	s5,56(sp)
    80003910:	f85a                	sd	s6,48(sp)
    80003912:	f45e                	sd	s7,40(sp)
    80003914:	f062                	sd	s8,32(sp)
    80003916:	ec66                	sd	s9,24(sp)
    80003918:	e86a                	sd	s10,16(sp)
    8000391a:	e46e                	sd	s11,8(sp)
    8000391c:	1880                	addi	s0,sp,112
    8000391e:	8b2a                	mv	s6,a0
    80003920:	8bae                	mv	s7,a1
    80003922:	8a32                	mv	s4,a2
    80003924:	84b6                	mv	s1,a3
    80003926:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003928:	9f35                	addw	a4,a4,a3
    return 0;
    8000392a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000392c:	0ad76063          	bltu	a4,a3,800039cc <readi+0xd2>
  if(off + n > ip->size)
    80003930:	00e7f463          	bgeu	a5,a4,80003938 <readi+0x3e>
    n = ip->size - off;
    80003934:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003938:	0a0a8963          	beqz	s5,800039ea <readi+0xf0>
    8000393c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000393e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003942:	5c7d                	li	s8,-1
    80003944:	a82d                	j	8000397e <readi+0x84>
    80003946:	020d1d93          	slli	s11,s10,0x20
    8000394a:	020ddd93          	srli	s11,s11,0x20
    8000394e:	05890793          	addi	a5,s2,88
    80003952:	86ee                	mv	a3,s11
    80003954:	963e                	add	a2,a2,a5
    80003956:	85d2                	mv	a1,s4
    80003958:	855e                	mv	a0,s7
    8000395a:	fffff097          	auipc	ra,0xfffff
    8000395e:	b02080e7          	jalr	-1278(ra) # 8000245c <either_copyout>
    80003962:	05850d63          	beq	a0,s8,800039bc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003966:	854a                	mv	a0,s2
    80003968:	fffff097          	auipc	ra,0xfffff
    8000396c:	5f4080e7          	jalr	1524(ra) # 80002f5c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003970:	013d09bb          	addw	s3,s10,s3
    80003974:	009d04bb          	addw	s1,s10,s1
    80003978:	9a6e                	add	s4,s4,s11
    8000397a:	0559f763          	bgeu	s3,s5,800039c8 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000397e:	00a4d59b          	srliw	a1,s1,0xa
    80003982:	855a                	mv	a0,s6
    80003984:	00000097          	auipc	ra,0x0
    80003988:	8a2080e7          	jalr	-1886(ra) # 80003226 <bmap>
    8000398c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003990:	cd85                	beqz	a1,800039c8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003992:	000b2503          	lw	a0,0(s6)
    80003996:	fffff097          	auipc	ra,0xfffff
    8000399a:	496080e7          	jalr	1174(ra) # 80002e2c <bread>
    8000399e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039a0:	3ff4f613          	andi	a2,s1,1023
    800039a4:	40cc87bb          	subw	a5,s9,a2
    800039a8:	413a873b          	subw	a4,s5,s3
    800039ac:	8d3e                	mv	s10,a5
    800039ae:	2781                	sext.w	a5,a5
    800039b0:	0007069b          	sext.w	a3,a4
    800039b4:	f8f6f9e3          	bgeu	a3,a5,80003946 <readi+0x4c>
    800039b8:	8d3a                	mv	s10,a4
    800039ba:	b771                	j	80003946 <readi+0x4c>
      brelse(bp);
    800039bc:	854a                	mv	a0,s2
    800039be:	fffff097          	auipc	ra,0xfffff
    800039c2:	59e080e7          	jalr	1438(ra) # 80002f5c <brelse>
      tot = -1;
    800039c6:	59fd                	li	s3,-1
  }
  return tot;
    800039c8:	0009851b          	sext.w	a0,s3
}
    800039cc:	70a6                	ld	ra,104(sp)
    800039ce:	7406                	ld	s0,96(sp)
    800039d0:	64e6                	ld	s1,88(sp)
    800039d2:	6946                	ld	s2,80(sp)
    800039d4:	69a6                	ld	s3,72(sp)
    800039d6:	6a06                	ld	s4,64(sp)
    800039d8:	7ae2                	ld	s5,56(sp)
    800039da:	7b42                	ld	s6,48(sp)
    800039dc:	7ba2                	ld	s7,40(sp)
    800039de:	7c02                	ld	s8,32(sp)
    800039e0:	6ce2                	ld	s9,24(sp)
    800039e2:	6d42                	ld	s10,16(sp)
    800039e4:	6da2                	ld	s11,8(sp)
    800039e6:	6165                	addi	sp,sp,112
    800039e8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039ea:	89d6                	mv	s3,s5
    800039ec:	bff1                	j	800039c8 <readi+0xce>
    return 0;
    800039ee:	4501                	li	a0,0
}
    800039f0:	8082                	ret

00000000800039f2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039f2:	457c                	lw	a5,76(a0)
    800039f4:	10d7e863          	bltu	a5,a3,80003b04 <writei+0x112>
{
    800039f8:	7159                	addi	sp,sp,-112
    800039fa:	f486                	sd	ra,104(sp)
    800039fc:	f0a2                	sd	s0,96(sp)
    800039fe:	eca6                	sd	s1,88(sp)
    80003a00:	e8ca                	sd	s2,80(sp)
    80003a02:	e4ce                	sd	s3,72(sp)
    80003a04:	e0d2                	sd	s4,64(sp)
    80003a06:	fc56                	sd	s5,56(sp)
    80003a08:	f85a                	sd	s6,48(sp)
    80003a0a:	f45e                	sd	s7,40(sp)
    80003a0c:	f062                	sd	s8,32(sp)
    80003a0e:	ec66                	sd	s9,24(sp)
    80003a10:	e86a                	sd	s10,16(sp)
    80003a12:	e46e                	sd	s11,8(sp)
    80003a14:	1880                	addi	s0,sp,112
    80003a16:	8aaa                	mv	s5,a0
    80003a18:	8bae                	mv	s7,a1
    80003a1a:	8a32                	mv	s4,a2
    80003a1c:	8936                	mv	s2,a3
    80003a1e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a20:	00e687bb          	addw	a5,a3,a4
    80003a24:	0ed7e263          	bltu	a5,a3,80003b08 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a28:	00043737          	lui	a4,0x43
    80003a2c:	0ef76063          	bltu	a4,a5,80003b0c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a30:	0c0b0863          	beqz	s6,80003b00 <writei+0x10e>
    80003a34:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a36:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a3a:	5c7d                	li	s8,-1
    80003a3c:	a091                	j	80003a80 <writei+0x8e>
    80003a3e:	020d1d93          	slli	s11,s10,0x20
    80003a42:	020ddd93          	srli	s11,s11,0x20
    80003a46:	05848793          	addi	a5,s1,88
    80003a4a:	86ee                	mv	a3,s11
    80003a4c:	8652                	mv	a2,s4
    80003a4e:	85de                	mv	a1,s7
    80003a50:	953e                	add	a0,a0,a5
    80003a52:	fffff097          	auipc	ra,0xfffff
    80003a56:	a60080e7          	jalr	-1440(ra) # 800024b2 <either_copyin>
    80003a5a:	07850263          	beq	a0,s8,80003abe <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a5e:	8526                	mv	a0,s1
    80003a60:	00000097          	auipc	ra,0x0
    80003a64:	780080e7          	jalr	1920(ra) # 800041e0 <log_write>
    brelse(bp);
    80003a68:	8526                	mv	a0,s1
    80003a6a:	fffff097          	auipc	ra,0xfffff
    80003a6e:	4f2080e7          	jalr	1266(ra) # 80002f5c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a72:	013d09bb          	addw	s3,s10,s3
    80003a76:	012d093b          	addw	s2,s10,s2
    80003a7a:	9a6e                	add	s4,s4,s11
    80003a7c:	0569f663          	bgeu	s3,s6,80003ac8 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003a80:	00a9559b          	srliw	a1,s2,0xa
    80003a84:	8556                	mv	a0,s5
    80003a86:	fffff097          	auipc	ra,0xfffff
    80003a8a:	7a0080e7          	jalr	1952(ra) # 80003226 <bmap>
    80003a8e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a92:	c99d                	beqz	a1,80003ac8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003a94:	000aa503          	lw	a0,0(s5)
    80003a98:	fffff097          	auipc	ra,0xfffff
    80003a9c:	394080e7          	jalr	916(ra) # 80002e2c <bread>
    80003aa0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aa2:	3ff97513          	andi	a0,s2,1023
    80003aa6:	40ac87bb          	subw	a5,s9,a0
    80003aaa:	413b073b          	subw	a4,s6,s3
    80003aae:	8d3e                	mv	s10,a5
    80003ab0:	2781                	sext.w	a5,a5
    80003ab2:	0007069b          	sext.w	a3,a4
    80003ab6:	f8f6f4e3          	bgeu	a3,a5,80003a3e <writei+0x4c>
    80003aba:	8d3a                	mv	s10,a4
    80003abc:	b749                	j	80003a3e <writei+0x4c>
      brelse(bp);
    80003abe:	8526                	mv	a0,s1
    80003ac0:	fffff097          	auipc	ra,0xfffff
    80003ac4:	49c080e7          	jalr	1180(ra) # 80002f5c <brelse>
  }

  if(off > ip->size)
    80003ac8:	04caa783          	lw	a5,76(s5)
    80003acc:	0127f463          	bgeu	a5,s2,80003ad4 <writei+0xe2>
    ip->size = off;
    80003ad0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ad4:	8556                	mv	a0,s5
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	aa6080e7          	jalr	-1370(ra) # 8000357c <iupdate>

  return tot;
    80003ade:	0009851b          	sext.w	a0,s3
}
    80003ae2:	70a6                	ld	ra,104(sp)
    80003ae4:	7406                	ld	s0,96(sp)
    80003ae6:	64e6                	ld	s1,88(sp)
    80003ae8:	6946                	ld	s2,80(sp)
    80003aea:	69a6                	ld	s3,72(sp)
    80003aec:	6a06                	ld	s4,64(sp)
    80003aee:	7ae2                	ld	s5,56(sp)
    80003af0:	7b42                	ld	s6,48(sp)
    80003af2:	7ba2                	ld	s7,40(sp)
    80003af4:	7c02                	ld	s8,32(sp)
    80003af6:	6ce2                	ld	s9,24(sp)
    80003af8:	6d42                	ld	s10,16(sp)
    80003afa:	6da2                	ld	s11,8(sp)
    80003afc:	6165                	addi	sp,sp,112
    80003afe:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b00:	89da                	mv	s3,s6
    80003b02:	bfc9                	j	80003ad4 <writei+0xe2>
    return -1;
    80003b04:	557d                	li	a0,-1
}
    80003b06:	8082                	ret
    return -1;
    80003b08:	557d                	li	a0,-1
    80003b0a:	bfe1                	j	80003ae2 <writei+0xf0>
    return -1;
    80003b0c:	557d                	li	a0,-1
    80003b0e:	bfd1                	j	80003ae2 <writei+0xf0>

0000000080003b10 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b10:	1141                	addi	sp,sp,-16
    80003b12:	e406                	sd	ra,8(sp)
    80003b14:	e022                	sd	s0,0(sp)
    80003b16:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b18:	4639                	li	a2,14
    80003b1a:	ffffd097          	auipc	ra,0xffffd
    80003b1e:	288080e7          	jalr	648(ra) # 80000da2 <strncmp>
}
    80003b22:	60a2                	ld	ra,8(sp)
    80003b24:	6402                	ld	s0,0(sp)
    80003b26:	0141                	addi	sp,sp,16
    80003b28:	8082                	ret

0000000080003b2a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b2a:	7139                	addi	sp,sp,-64
    80003b2c:	fc06                	sd	ra,56(sp)
    80003b2e:	f822                	sd	s0,48(sp)
    80003b30:	f426                	sd	s1,40(sp)
    80003b32:	f04a                	sd	s2,32(sp)
    80003b34:	ec4e                	sd	s3,24(sp)
    80003b36:	e852                	sd	s4,16(sp)
    80003b38:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b3a:	04451703          	lh	a4,68(a0)
    80003b3e:	4785                	li	a5,1
    80003b40:	00f71a63          	bne	a4,a5,80003b54 <dirlookup+0x2a>
    80003b44:	892a                	mv	s2,a0
    80003b46:	89ae                	mv	s3,a1
    80003b48:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b4a:	457c                	lw	a5,76(a0)
    80003b4c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b4e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b50:	e79d                	bnez	a5,80003b7e <dirlookup+0x54>
    80003b52:	a8a5                	j	80003bca <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b54:	00005517          	auipc	a0,0x5
    80003b58:	aa450513          	addi	a0,a0,-1372 # 800085f8 <syscalls+0x1a8>
    80003b5c:	ffffd097          	auipc	ra,0xffffd
    80003b60:	9e2080e7          	jalr	-1566(ra) # 8000053e <panic>
      panic("dirlookup read");
    80003b64:	00005517          	auipc	a0,0x5
    80003b68:	aac50513          	addi	a0,a0,-1364 # 80008610 <syscalls+0x1c0>
    80003b6c:	ffffd097          	auipc	ra,0xffffd
    80003b70:	9d2080e7          	jalr	-1582(ra) # 8000053e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b74:	24c1                	addiw	s1,s1,16
    80003b76:	04c92783          	lw	a5,76(s2)
    80003b7a:	04f4f763          	bgeu	s1,a5,80003bc8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b7e:	4741                	li	a4,16
    80003b80:	86a6                	mv	a3,s1
    80003b82:	fc040613          	addi	a2,s0,-64
    80003b86:	4581                	li	a1,0
    80003b88:	854a                	mv	a0,s2
    80003b8a:	00000097          	auipc	ra,0x0
    80003b8e:	d70080e7          	jalr	-656(ra) # 800038fa <readi>
    80003b92:	47c1                	li	a5,16
    80003b94:	fcf518e3          	bne	a0,a5,80003b64 <dirlookup+0x3a>
    if(de.inum == 0)
    80003b98:	fc045783          	lhu	a5,-64(s0)
    80003b9c:	dfe1                	beqz	a5,80003b74 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b9e:	fc240593          	addi	a1,s0,-62
    80003ba2:	854e                	mv	a0,s3
    80003ba4:	00000097          	auipc	ra,0x0
    80003ba8:	f6c080e7          	jalr	-148(ra) # 80003b10 <namecmp>
    80003bac:	f561                	bnez	a0,80003b74 <dirlookup+0x4a>
      if(poff)
    80003bae:	000a0463          	beqz	s4,80003bb6 <dirlookup+0x8c>
        *poff = off;
    80003bb2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bb6:	fc045583          	lhu	a1,-64(s0)
    80003bba:	00092503          	lw	a0,0(s2)
    80003bbe:	fffff097          	auipc	ra,0xfffff
    80003bc2:	750080e7          	jalr	1872(ra) # 8000330e <iget>
    80003bc6:	a011                	j	80003bca <dirlookup+0xa0>
  return 0;
    80003bc8:	4501                	li	a0,0
}
    80003bca:	70e2                	ld	ra,56(sp)
    80003bcc:	7442                	ld	s0,48(sp)
    80003bce:	74a2                	ld	s1,40(sp)
    80003bd0:	7902                	ld	s2,32(sp)
    80003bd2:	69e2                	ld	s3,24(sp)
    80003bd4:	6a42                	ld	s4,16(sp)
    80003bd6:	6121                	addi	sp,sp,64
    80003bd8:	8082                	ret

0000000080003bda <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bda:	711d                	addi	sp,sp,-96
    80003bdc:	ec86                	sd	ra,88(sp)
    80003bde:	e8a2                	sd	s0,80(sp)
    80003be0:	e4a6                	sd	s1,72(sp)
    80003be2:	e0ca                	sd	s2,64(sp)
    80003be4:	fc4e                	sd	s3,56(sp)
    80003be6:	f852                	sd	s4,48(sp)
    80003be8:	f456                	sd	s5,40(sp)
    80003bea:	f05a                	sd	s6,32(sp)
    80003bec:	ec5e                	sd	s7,24(sp)
    80003bee:	e862                	sd	s8,16(sp)
    80003bf0:	e466                	sd	s9,8(sp)
    80003bf2:	1080                	addi	s0,sp,96
    80003bf4:	84aa                	mv	s1,a0
    80003bf6:	8aae                	mv	s5,a1
    80003bf8:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003bfa:	00054703          	lbu	a4,0(a0)
    80003bfe:	02f00793          	li	a5,47
    80003c02:	02f70363          	beq	a4,a5,80003c28 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c06:	ffffe097          	auipc	ra,0xffffe
    80003c0a:	da6080e7          	jalr	-602(ra) # 800019ac <myproc>
    80003c0e:	15053503          	ld	a0,336(a0)
    80003c12:	00000097          	auipc	ra,0x0
    80003c16:	9f6080e7          	jalr	-1546(ra) # 80003608 <idup>
    80003c1a:	89aa                	mv	s3,a0
  while(*path == '/')
    80003c1c:	02f00913          	li	s2,47
  len = path - s;
    80003c20:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003c22:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c24:	4b85                	li	s7,1
    80003c26:	a865                	j	80003cde <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003c28:	4585                	li	a1,1
    80003c2a:	4505                	li	a0,1
    80003c2c:	fffff097          	auipc	ra,0xfffff
    80003c30:	6e2080e7          	jalr	1762(ra) # 8000330e <iget>
    80003c34:	89aa                	mv	s3,a0
    80003c36:	b7dd                	j	80003c1c <namex+0x42>
      iunlockput(ip);
    80003c38:	854e                	mv	a0,s3
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	c6e080e7          	jalr	-914(ra) # 800038a8 <iunlockput>
      return 0;
    80003c42:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c44:	854e                	mv	a0,s3
    80003c46:	60e6                	ld	ra,88(sp)
    80003c48:	6446                	ld	s0,80(sp)
    80003c4a:	64a6                	ld	s1,72(sp)
    80003c4c:	6906                	ld	s2,64(sp)
    80003c4e:	79e2                	ld	s3,56(sp)
    80003c50:	7a42                	ld	s4,48(sp)
    80003c52:	7aa2                	ld	s5,40(sp)
    80003c54:	7b02                	ld	s6,32(sp)
    80003c56:	6be2                	ld	s7,24(sp)
    80003c58:	6c42                	ld	s8,16(sp)
    80003c5a:	6ca2                	ld	s9,8(sp)
    80003c5c:	6125                	addi	sp,sp,96
    80003c5e:	8082                	ret
      iunlock(ip);
    80003c60:	854e                	mv	a0,s3
    80003c62:	00000097          	auipc	ra,0x0
    80003c66:	aa6080e7          	jalr	-1370(ra) # 80003708 <iunlock>
      return ip;
    80003c6a:	bfe9                	j	80003c44 <namex+0x6a>
      iunlockput(ip);
    80003c6c:	854e                	mv	a0,s3
    80003c6e:	00000097          	auipc	ra,0x0
    80003c72:	c3a080e7          	jalr	-966(ra) # 800038a8 <iunlockput>
      return 0;
    80003c76:	89e6                	mv	s3,s9
    80003c78:	b7f1                	j	80003c44 <namex+0x6a>
  len = path - s;
    80003c7a:	40b48633          	sub	a2,s1,a1
    80003c7e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c82:	099c5463          	bge	s8,s9,80003d0a <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003c86:	4639                	li	a2,14
    80003c88:	8552                	mv	a0,s4
    80003c8a:	ffffd097          	auipc	ra,0xffffd
    80003c8e:	0a4080e7          	jalr	164(ra) # 80000d2e <memmove>
  while(*path == '/')
    80003c92:	0004c783          	lbu	a5,0(s1)
    80003c96:	01279763          	bne	a5,s2,80003ca4 <namex+0xca>
    path++;
    80003c9a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c9c:	0004c783          	lbu	a5,0(s1)
    80003ca0:	ff278de3          	beq	a5,s2,80003c9a <namex+0xc0>
    ilock(ip);
    80003ca4:	854e                	mv	a0,s3
    80003ca6:	00000097          	auipc	ra,0x0
    80003caa:	9a0080e7          	jalr	-1632(ra) # 80003646 <ilock>
    if(ip->type != T_DIR){
    80003cae:	04499783          	lh	a5,68(s3)
    80003cb2:	f97793e3          	bne	a5,s7,80003c38 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003cb6:	000a8563          	beqz	s5,80003cc0 <namex+0xe6>
    80003cba:	0004c783          	lbu	a5,0(s1)
    80003cbe:	d3cd                	beqz	a5,80003c60 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cc0:	865a                	mv	a2,s6
    80003cc2:	85d2                	mv	a1,s4
    80003cc4:	854e                	mv	a0,s3
    80003cc6:	00000097          	auipc	ra,0x0
    80003cca:	e64080e7          	jalr	-412(ra) # 80003b2a <dirlookup>
    80003cce:	8caa                	mv	s9,a0
    80003cd0:	dd51                	beqz	a0,80003c6c <namex+0x92>
    iunlockput(ip);
    80003cd2:	854e                	mv	a0,s3
    80003cd4:	00000097          	auipc	ra,0x0
    80003cd8:	bd4080e7          	jalr	-1068(ra) # 800038a8 <iunlockput>
    ip = next;
    80003cdc:	89e6                	mv	s3,s9
  while(*path == '/')
    80003cde:	0004c783          	lbu	a5,0(s1)
    80003ce2:	05279763          	bne	a5,s2,80003d30 <namex+0x156>
    path++;
    80003ce6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ce8:	0004c783          	lbu	a5,0(s1)
    80003cec:	ff278de3          	beq	a5,s2,80003ce6 <namex+0x10c>
  if(*path == 0)
    80003cf0:	c79d                	beqz	a5,80003d1e <namex+0x144>
    path++;
    80003cf2:	85a6                	mv	a1,s1
  len = path - s;
    80003cf4:	8cda                	mv	s9,s6
    80003cf6:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003cf8:	01278963          	beq	a5,s2,80003d0a <namex+0x130>
    80003cfc:	dfbd                	beqz	a5,80003c7a <namex+0xa0>
    path++;
    80003cfe:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003d00:	0004c783          	lbu	a5,0(s1)
    80003d04:	ff279ce3          	bne	a5,s2,80003cfc <namex+0x122>
    80003d08:	bf8d                	j	80003c7a <namex+0xa0>
    memmove(name, s, len);
    80003d0a:	2601                	sext.w	a2,a2
    80003d0c:	8552                	mv	a0,s4
    80003d0e:	ffffd097          	auipc	ra,0xffffd
    80003d12:	020080e7          	jalr	32(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003d16:	9cd2                	add	s9,s9,s4
    80003d18:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d1c:	bf9d                	j	80003c92 <namex+0xb8>
  if(nameiparent){
    80003d1e:	f20a83e3          	beqz	s5,80003c44 <namex+0x6a>
    iput(ip);
    80003d22:	854e                	mv	a0,s3
    80003d24:	00000097          	auipc	ra,0x0
    80003d28:	adc080e7          	jalr	-1316(ra) # 80003800 <iput>
    return 0;
    80003d2c:	4981                	li	s3,0
    80003d2e:	bf19                	j	80003c44 <namex+0x6a>
  if(*path == 0)
    80003d30:	d7fd                	beqz	a5,80003d1e <namex+0x144>
  while(*path != '/' && *path != 0)
    80003d32:	0004c783          	lbu	a5,0(s1)
    80003d36:	85a6                	mv	a1,s1
    80003d38:	b7d1                	j	80003cfc <namex+0x122>

0000000080003d3a <dirlink>:
{
    80003d3a:	7139                	addi	sp,sp,-64
    80003d3c:	fc06                	sd	ra,56(sp)
    80003d3e:	f822                	sd	s0,48(sp)
    80003d40:	f426                	sd	s1,40(sp)
    80003d42:	f04a                	sd	s2,32(sp)
    80003d44:	ec4e                	sd	s3,24(sp)
    80003d46:	e852                	sd	s4,16(sp)
    80003d48:	0080                	addi	s0,sp,64
    80003d4a:	892a                	mv	s2,a0
    80003d4c:	8a2e                	mv	s4,a1
    80003d4e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d50:	4601                	li	a2,0
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	dd8080e7          	jalr	-552(ra) # 80003b2a <dirlookup>
    80003d5a:	e93d                	bnez	a0,80003dd0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d5c:	04c92483          	lw	s1,76(s2)
    80003d60:	c49d                	beqz	s1,80003d8e <dirlink+0x54>
    80003d62:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d64:	4741                	li	a4,16
    80003d66:	86a6                	mv	a3,s1
    80003d68:	fc040613          	addi	a2,s0,-64
    80003d6c:	4581                	li	a1,0
    80003d6e:	854a                	mv	a0,s2
    80003d70:	00000097          	auipc	ra,0x0
    80003d74:	b8a080e7          	jalr	-1142(ra) # 800038fa <readi>
    80003d78:	47c1                	li	a5,16
    80003d7a:	06f51163          	bne	a0,a5,80003ddc <dirlink+0xa2>
    if(de.inum == 0)
    80003d7e:	fc045783          	lhu	a5,-64(s0)
    80003d82:	c791                	beqz	a5,80003d8e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d84:	24c1                	addiw	s1,s1,16
    80003d86:	04c92783          	lw	a5,76(s2)
    80003d8a:	fcf4ede3          	bltu	s1,a5,80003d64 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d8e:	4639                	li	a2,14
    80003d90:	85d2                	mv	a1,s4
    80003d92:	fc240513          	addi	a0,s0,-62
    80003d96:	ffffd097          	auipc	ra,0xffffd
    80003d9a:	048080e7          	jalr	72(ra) # 80000dde <strncpy>
  de.inum = inum;
    80003d9e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003da2:	4741                	li	a4,16
    80003da4:	86a6                	mv	a3,s1
    80003da6:	fc040613          	addi	a2,s0,-64
    80003daa:	4581                	li	a1,0
    80003dac:	854a                	mv	a0,s2
    80003dae:	00000097          	auipc	ra,0x0
    80003db2:	c44080e7          	jalr	-956(ra) # 800039f2 <writei>
    80003db6:	1541                	addi	a0,a0,-16
    80003db8:	00a03533          	snez	a0,a0
    80003dbc:	40a00533          	neg	a0,a0
}
    80003dc0:	70e2                	ld	ra,56(sp)
    80003dc2:	7442                	ld	s0,48(sp)
    80003dc4:	74a2                	ld	s1,40(sp)
    80003dc6:	7902                	ld	s2,32(sp)
    80003dc8:	69e2                	ld	s3,24(sp)
    80003dca:	6a42                	ld	s4,16(sp)
    80003dcc:	6121                	addi	sp,sp,64
    80003dce:	8082                	ret
    iput(ip);
    80003dd0:	00000097          	auipc	ra,0x0
    80003dd4:	a30080e7          	jalr	-1488(ra) # 80003800 <iput>
    return -1;
    80003dd8:	557d                	li	a0,-1
    80003dda:	b7dd                	j	80003dc0 <dirlink+0x86>
      panic("dirlink read");
    80003ddc:	00005517          	auipc	a0,0x5
    80003de0:	84450513          	addi	a0,a0,-1980 # 80008620 <syscalls+0x1d0>
    80003de4:	ffffc097          	auipc	ra,0xffffc
    80003de8:	75a080e7          	jalr	1882(ra) # 8000053e <panic>

0000000080003dec <namei>:

struct inode*
namei(char *path)
{
    80003dec:	1101                	addi	sp,sp,-32
    80003dee:	ec06                	sd	ra,24(sp)
    80003df0:	e822                	sd	s0,16(sp)
    80003df2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003df4:	fe040613          	addi	a2,s0,-32
    80003df8:	4581                	li	a1,0
    80003dfa:	00000097          	auipc	ra,0x0
    80003dfe:	de0080e7          	jalr	-544(ra) # 80003bda <namex>
}
    80003e02:	60e2                	ld	ra,24(sp)
    80003e04:	6442                	ld	s0,16(sp)
    80003e06:	6105                	addi	sp,sp,32
    80003e08:	8082                	ret

0000000080003e0a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e0a:	1141                	addi	sp,sp,-16
    80003e0c:	e406                	sd	ra,8(sp)
    80003e0e:	e022                	sd	s0,0(sp)
    80003e10:	0800                	addi	s0,sp,16
    80003e12:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e14:	4585                	li	a1,1
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	dc4080e7          	jalr	-572(ra) # 80003bda <namex>
}
    80003e1e:	60a2                	ld	ra,8(sp)
    80003e20:	6402                	ld	s0,0(sp)
    80003e22:	0141                	addi	sp,sp,16
    80003e24:	8082                	ret

0000000080003e26 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e26:	1101                	addi	sp,sp,-32
    80003e28:	ec06                	sd	ra,24(sp)
    80003e2a:	e822                	sd	s0,16(sp)
    80003e2c:	e426                	sd	s1,8(sp)
    80003e2e:	e04a                	sd	s2,0(sp)
    80003e30:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e32:	0001d917          	auipc	s2,0x1d
    80003e36:	cfe90913          	addi	s2,s2,-770 # 80020b30 <log>
    80003e3a:	01892583          	lw	a1,24(s2)
    80003e3e:	02892503          	lw	a0,40(s2)
    80003e42:	fffff097          	auipc	ra,0xfffff
    80003e46:	fea080e7          	jalr	-22(ra) # 80002e2c <bread>
    80003e4a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e4c:	02c92683          	lw	a3,44(s2)
    80003e50:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e52:	02d05763          	blez	a3,80003e80 <write_head+0x5a>
    80003e56:	0001d797          	auipc	a5,0x1d
    80003e5a:	d0a78793          	addi	a5,a5,-758 # 80020b60 <log+0x30>
    80003e5e:	05c50713          	addi	a4,a0,92
    80003e62:	36fd                	addiw	a3,a3,-1
    80003e64:	1682                	slli	a3,a3,0x20
    80003e66:	9281                	srli	a3,a3,0x20
    80003e68:	068a                	slli	a3,a3,0x2
    80003e6a:	0001d617          	auipc	a2,0x1d
    80003e6e:	cfa60613          	addi	a2,a2,-774 # 80020b64 <log+0x34>
    80003e72:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003e74:	4390                	lw	a2,0(a5)
    80003e76:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003e78:	0791                	addi	a5,a5,4
    80003e7a:	0711                	addi	a4,a4,4
    80003e7c:	fed79ce3          	bne	a5,a3,80003e74 <write_head+0x4e>
  }
  bwrite(buf);
    80003e80:	8526                	mv	a0,s1
    80003e82:	fffff097          	auipc	ra,0xfffff
    80003e86:	09c080e7          	jalr	156(ra) # 80002f1e <bwrite>
  brelse(buf);
    80003e8a:	8526                	mv	a0,s1
    80003e8c:	fffff097          	auipc	ra,0xfffff
    80003e90:	0d0080e7          	jalr	208(ra) # 80002f5c <brelse>
}
    80003e94:	60e2                	ld	ra,24(sp)
    80003e96:	6442                	ld	s0,16(sp)
    80003e98:	64a2                	ld	s1,8(sp)
    80003e9a:	6902                	ld	s2,0(sp)
    80003e9c:	6105                	addi	sp,sp,32
    80003e9e:	8082                	ret

0000000080003ea0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ea0:	0001d797          	auipc	a5,0x1d
    80003ea4:	cbc7a783          	lw	a5,-836(a5) # 80020b5c <log+0x2c>
    80003ea8:	0af05d63          	blez	a5,80003f62 <install_trans+0xc2>
{
    80003eac:	7139                	addi	sp,sp,-64
    80003eae:	fc06                	sd	ra,56(sp)
    80003eb0:	f822                	sd	s0,48(sp)
    80003eb2:	f426                	sd	s1,40(sp)
    80003eb4:	f04a                	sd	s2,32(sp)
    80003eb6:	ec4e                	sd	s3,24(sp)
    80003eb8:	e852                	sd	s4,16(sp)
    80003eba:	e456                	sd	s5,8(sp)
    80003ebc:	e05a                	sd	s6,0(sp)
    80003ebe:	0080                	addi	s0,sp,64
    80003ec0:	8b2a                	mv	s6,a0
    80003ec2:	0001da97          	auipc	s5,0x1d
    80003ec6:	c9ea8a93          	addi	s5,s5,-866 # 80020b60 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eca:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ecc:	0001d997          	auipc	s3,0x1d
    80003ed0:	c6498993          	addi	s3,s3,-924 # 80020b30 <log>
    80003ed4:	a00d                	j	80003ef6 <install_trans+0x56>
    brelse(lbuf);
    80003ed6:	854a                	mv	a0,s2
    80003ed8:	fffff097          	auipc	ra,0xfffff
    80003edc:	084080e7          	jalr	132(ra) # 80002f5c <brelse>
    brelse(dbuf);
    80003ee0:	8526                	mv	a0,s1
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	07a080e7          	jalr	122(ra) # 80002f5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eea:	2a05                	addiw	s4,s4,1
    80003eec:	0a91                	addi	s5,s5,4
    80003eee:	02c9a783          	lw	a5,44(s3)
    80003ef2:	04fa5e63          	bge	s4,a5,80003f4e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ef6:	0189a583          	lw	a1,24(s3)
    80003efa:	014585bb          	addw	a1,a1,s4
    80003efe:	2585                	addiw	a1,a1,1
    80003f00:	0289a503          	lw	a0,40(s3)
    80003f04:	fffff097          	auipc	ra,0xfffff
    80003f08:	f28080e7          	jalr	-216(ra) # 80002e2c <bread>
    80003f0c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f0e:	000aa583          	lw	a1,0(s5)
    80003f12:	0289a503          	lw	a0,40(s3)
    80003f16:	fffff097          	auipc	ra,0xfffff
    80003f1a:	f16080e7          	jalr	-234(ra) # 80002e2c <bread>
    80003f1e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f20:	40000613          	li	a2,1024
    80003f24:	05890593          	addi	a1,s2,88
    80003f28:	05850513          	addi	a0,a0,88
    80003f2c:	ffffd097          	auipc	ra,0xffffd
    80003f30:	e02080e7          	jalr	-510(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f34:	8526                	mv	a0,s1
    80003f36:	fffff097          	auipc	ra,0xfffff
    80003f3a:	fe8080e7          	jalr	-24(ra) # 80002f1e <bwrite>
    if(recovering == 0)
    80003f3e:	f80b1ce3          	bnez	s6,80003ed6 <install_trans+0x36>
      bunpin(dbuf);
    80003f42:	8526                	mv	a0,s1
    80003f44:	fffff097          	auipc	ra,0xfffff
    80003f48:	0f2080e7          	jalr	242(ra) # 80003036 <bunpin>
    80003f4c:	b769                	j	80003ed6 <install_trans+0x36>
}
    80003f4e:	70e2                	ld	ra,56(sp)
    80003f50:	7442                	ld	s0,48(sp)
    80003f52:	74a2                	ld	s1,40(sp)
    80003f54:	7902                	ld	s2,32(sp)
    80003f56:	69e2                	ld	s3,24(sp)
    80003f58:	6a42                	ld	s4,16(sp)
    80003f5a:	6aa2                	ld	s5,8(sp)
    80003f5c:	6b02                	ld	s6,0(sp)
    80003f5e:	6121                	addi	sp,sp,64
    80003f60:	8082                	ret
    80003f62:	8082                	ret

0000000080003f64 <initlog>:
{
    80003f64:	7179                	addi	sp,sp,-48
    80003f66:	f406                	sd	ra,40(sp)
    80003f68:	f022                	sd	s0,32(sp)
    80003f6a:	ec26                	sd	s1,24(sp)
    80003f6c:	e84a                	sd	s2,16(sp)
    80003f6e:	e44e                	sd	s3,8(sp)
    80003f70:	1800                	addi	s0,sp,48
    80003f72:	892a                	mv	s2,a0
    80003f74:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f76:	0001d497          	auipc	s1,0x1d
    80003f7a:	bba48493          	addi	s1,s1,-1094 # 80020b30 <log>
    80003f7e:	00004597          	auipc	a1,0x4
    80003f82:	6b258593          	addi	a1,a1,1714 # 80008630 <syscalls+0x1e0>
    80003f86:	8526                	mv	a0,s1
    80003f88:	ffffd097          	auipc	ra,0xffffd
    80003f8c:	bbe080e7          	jalr	-1090(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80003f90:	0149a583          	lw	a1,20(s3)
    80003f94:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f96:	0109a783          	lw	a5,16(s3)
    80003f9a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f9c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fa0:	854a                	mv	a0,s2
    80003fa2:	fffff097          	auipc	ra,0xfffff
    80003fa6:	e8a080e7          	jalr	-374(ra) # 80002e2c <bread>
  log.lh.n = lh->n;
    80003faa:	4d34                	lw	a3,88(a0)
    80003fac:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fae:	02d05563          	blez	a3,80003fd8 <initlog+0x74>
    80003fb2:	05c50793          	addi	a5,a0,92
    80003fb6:	0001d717          	auipc	a4,0x1d
    80003fba:	baa70713          	addi	a4,a4,-1110 # 80020b60 <log+0x30>
    80003fbe:	36fd                	addiw	a3,a3,-1
    80003fc0:	1682                	slli	a3,a3,0x20
    80003fc2:	9281                	srli	a3,a3,0x20
    80003fc4:	068a                	slli	a3,a3,0x2
    80003fc6:	06050613          	addi	a2,a0,96
    80003fca:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003fcc:	4390                	lw	a2,0(a5)
    80003fce:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fd0:	0791                	addi	a5,a5,4
    80003fd2:	0711                	addi	a4,a4,4
    80003fd4:	fed79ce3          	bne	a5,a3,80003fcc <initlog+0x68>
  brelse(buf);
    80003fd8:	fffff097          	auipc	ra,0xfffff
    80003fdc:	f84080e7          	jalr	-124(ra) # 80002f5c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fe0:	4505                	li	a0,1
    80003fe2:	00000097          	auipc	ra,0x0
    80003fe6:	ebe080e7          	jalr	-322(ra) # 80003ea0 <install_trans>
  log.lh.n = 0;
    80003fea:	0001d797          	auipc	a5,0x1d
    80003fee:	b607a923          	sw	zero,-1166(a5) # 80020b5c <log+0x2c>
  write_head(); // clear the log
    80003ff2:	00000097          	auipc	ra,0x0
    80003ff6:	e34080e7          	jalr	-460(ra) # 80003e26 <write_head>
}
    80003ffa:	70a2                	ld	ra,40(sp)
    80003ffc:	7402                	ld	s0,32(sp)
    80003ffe:	64e2                	ld	s1,24(sp)
    80004000:	6942                	ld	s2,16(sp)
    80004002:	69a2                	ld	s3,8(sp)
    80004004:	6145                	addi	sp,sp,48
    80004006:	8082                	ret

0000000080004008 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004008:	1101                	addi	sp,sp,-32
    8000400a:	ec06                	sd	ra,24(sp)
    8000400c:	e822                	sd	s0,16(sp)
    8000400e:	e426                	sd	s1,8(sp)
    80004010:	e04a                	sd	s2,0(sp)
    80004012:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004014:	0001d517          	auipc	a0,0x1d
    80004018:	b1c50513          	addi	a0,a0,-1252 # 80020b30 <log>
    8000401c:	ffffd097          	auipc	ra,0xffffd
    80004020:	bba080e7          	jalr	-1094(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004024:	0001d497          	auipc	s1,0x1d
    80004028:	b0c48493          	addi	s1,s1,-1268 # 80020b30 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000402c:	4979                	li	s2,30
    8000402e:	a039                	j	8000403c <begin_op+0x34>
      sleep(&log, &log.lock);
    80004030:	85a6                	mv	a1,s1
    80004032:	8526                	mv	a0,s1
    80004034:	ffffe097          	auipc	ra,0xffffe
    80004038:	020080e7          	jalr	32(ra) # 80002054 <sleep>
    if(log.committing){
    8000403c:	50dc                	lw	a5,36(s1)
    8000403e:	fbed                	bnez	a5,80004030 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004040:	509c                	lw	a5,32(s1)
    80004042:	0017871b          	addiw	a4,a5,1
    80004046:	0007069b          	sext.w	a3,a4
    8000404a:	0027179b          	slliw	a5,a4,0x2
    8000404e:	9fb9                	addw	a5,a5,a4
    80004050:	0017979b          	slliw	a5,a5,0x1
    80004054:	54d8                	lw	a4,44(s1)
    80004056:	9fb9                	addw	a5,a5,a4
    80004058:	00f95963          	bge	s2,a5,8000406a <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000405c:	85a6                	mv	a1,s1
    8000405e:	8526                	mv	a0,s1
    80004060:	ffffe097          	auipc	ra,0xffffe
    80004064:	ff4080e7          	jalr	-12(ra) # 80002054 <sleep>
    80004068:	bfd1                	j	8000403c <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000406a:	0001d517          	auipc	a0,0x1d
    8000406e:	ac650513          	addi	a0,a0,-1338 # 80020b30 <log>
    80004072:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004074:	ffffd097          	auipc	ra,0xffffd
    80004078:	c16080e7          	jalr	-1002(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000407c:	60e2                	ld	ra,24(sp)
    8000407e:	6442                	ld	s0,16(sp)
    80004080:	64a2                	ld	s1,8(sp)
    80004082:	6902                	ld	s2,0(sp)
    80004084:	6105                	addi	sp,sp,32
    80004086:	8082                	ret

0000000080004088 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004088:	7139                	addi	sp,sp,-64
    8000408a:	fc06                	sd	ra,56(sp)
    8000408c:	f822                	sd	s0,48(sp)
    8000408e:	f426                	sd	s1,40(sp)
    80004090:	f04a                	sd	s2,32(sp)
    80004092:	ec4e                	sd	s3,24(sp)
    80004094:	e852                	sd	s4,16(sp)
    80004096:	e456                	sd	s5,8(sp)
    80004098:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000409a:	0001d497          	auipc	s1,0x1d
    8000409e:	a9648493          	addi	s1,s1,-1386 # 80020b30 <log>
    800040a2:	8526                	mv	a0,s1
    800040a4:	ffffd097          	auipc	ra,0xffffd
    800040a8:	b32080e7          	jalr	-1230(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800040ac:	509c                	lw	a5,32(s1)
    800040ae:	37fd                	addiw	a5,a5,-1
    800040b0:	0007891b          	sext.w	s2,a5
    800040b4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040b6:	50dc                	lw	a5,36(s1)
    800040b8:	e7b9                	bnez	a5,80004106 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800040ba:	04091e63          	bnez	s2,80004116 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040be:	0001d497          	auipc	s1,0x1d
    800040c2:	a7248493          	addi	s1,s1,-1422 # 80020b30 <log>
    800040c6:	4785                	li	a5,1
    800040c8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040ca:	8526                	mv	a0,s1
    800040cc:	ffffd097          	auipc	ra,0xffffd
    800040d0:	bbe080e7          	jalr	-1090(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040d4:	54dc                	lw	a5,44(s1)
    800040d6:	06f04763          	bgtz	a5,80004144 <end_op+0xbc>
    acquire(&log.lock);
    800040da:	0001d497          	auipc	s1,0x1d
    800040de:	a5648493          	addi	s1,s1,-1450 # 80020b30 <log>
    800040e2:	8526                	mv	a0,s1
    800040e4:	ffffd097          	auipc	ra,0xffffd
    800040e8:	af2080e7          	jalr	-1294(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800040ec:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800040f0:	8526                	mv	a0,s1
    800040f2:	ffffe097          	auipc	ra,0xffffe
    800040f6:	fc6080e7          	jalr	-58(ra) # 800020b8 <wakeup>
    release(&log.lock);
    800040fa:	8526                	mv	a0,s1
    800040fc:	ffffd097          	auipc	ra,0xffffd
    80004100:	b8e080e7          	jalr	-1138(ra) # 80000c8a <release>
}
    80004104:	a03d                	j	80004132 <end_op+0xaa>
    panic("log.committing");
    80004106:	00004517          	auipc	a0,0x4
    8000410a:	53250513          	addi	a0,a0,1330 # 80008638 <syscalls+0x1e8>
    8000410e:	ffffc097          	auipc	ra,0xffffc
    80004112:	430080e7          	jalr	1072(ra) # 8000053e <panic>
    wakeup(&log);
    80004116:	0001d497          	auipc	s1,0x1d
    8000411a:	a1a48493          	addi	s1,s1,-1510 # 80020b30 <log>
    8000411e:	8526                	mv	a0,s1
    80004120:	ffffe097          	auipc	ra,0xffffe
    80004124:	f98080e7          	jalr	-104(ra) # 800020b8 <wakeup>
  release(&log.lock);
    80004128:	8526                	mv	a0,s1
    8000412a:	ffffd097          	auipc	ra,0xffffd
    8000412e:	b60080e7          	jalr	-1184(ra) # 80000c8a <release>
}
    80004132:	70e2                	ld	ra,56(sp)
    80004134:	7442                	ld	s0,48(sp)
    80004136:	74a2                	ld	s1,40(sp)
    80004138:	7902                	ld	s2,32(sp)
    8000413a:	69e2                	ld	s3,24(sp)
    8000413c:	6a42                	ld	s4,16(sp)
    8000413e:	6aa2                	ld	s5,8(sp)
    80004140:	6121                	addi	sp,sp,64
    80004142:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004144:	0001da97          	auipc	s5,0x1d
    80004148:	a1ca8a93          	addi	s5,s5,-1508 # 80020b60 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000414c:	0001da17          	auipc	s4,0x1d
    80004150:	9e4a0a13          	addi	s4,s4,-1564 # 80020b30 <log>
    80004154:	018a2583          	lw	a1,24(s4)
    80004158:	012585bb          	addw	a1,a1,s2
    8000415c:	2585                	addiw	a1,a1,1
    8000415e:	028a2503          	lw	a0,40(s4)
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	cca080e7          	jalr	-822(ra) # 80002e2c <bread>
    8000416a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000416c:	000aa583          	lw	a1,0(s5)
    80004170:	028a2503          	lw	a0,40(s4)
    80004174:	fffff097          	auipc	ra,0xfffff
    80004178:	cb8080e7          	jalr	-840(ra) # 80002e2c <bread>
    8000417c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000417e:	40000613          	li	a2,1024
    80004182:	05850593          	addi	a1,a0,88
    80004186:	05848513          	addi	a0,s1,88
    8000418a:	ffffd097          	auipc	ra,0xffffd
    8000418e:	ba4080e7          	jalr	-1116(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004192:	8526                	mv	a0,s1
    80004194:	fffff097          	auipc	ra,0xfffff
    80004198:	d8a080e7          	jalr	-630(ra) # 80002f1e <bwrite>
    brelse(from);
    8000419c:	854e                	mv	a0,s3
    8000419e:	fffff097          	auipc	ra,0xfffff
    800041a2:	dbe080e7          	jalr	-578(ra) # 80002f5c <brelse>
    brelse(to);
    800041a6:	8526                	mv	a0,s1
    800041a8:	fffff097          	auipc	ra,0xfffff
    800041ac:	db4080e7          	jalr	-588(ra) # 80002f5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041b0:	2905                	addiw	s2,s2,1
    800041b2:	0a91                	addi	s5,s5,4
    800041b4:	02ca2783          	lw	a5,44(s4)
    800041b8:	f8f94ee3          	blt	s2,a5,80004154 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	c6a080e7          	jalr	-918(ra) # 80003e26 <write_head>
    install_trans(0); // Now install writes to home locations
    800041c4:	4501                	li	a0,0
    800041c6:	00000097          	auipc	ra,0x0
    800041ca:	cda080e7          	jalr	-806(ra) # 80003ea0 <install_trans>
    log.lh.n = 0;
    800041ce:	0001d797          	auipc	a5,0x1d
    800041d2:	9807a723          	sw	zero,-1650(a5) # 80020b5c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041d6:	00000097          	auipc	ra,0x0
    800041da:	c50080e7          	jalr	-944(ra) # 80003e26 <write_head>
    800041de:	bdf5                	j	800040da <end_op+0x52>

00000000800041e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800041e0:	1101                	addi	sp,sp,-32
    800041e2:	ec06                	sd	ra,24(sp)
    800041e4:	e822                	sd	s0,16(sp)
    800041e6:	e426                	sd	s1,8(sp)
    800041e8:	e04a                	sd	s2,0(sp)
    800041ea:	1000                	addi	s0,sp,32
    800041ec:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041ee:	0001d917          	auipc	s2,0x1d
    800041f2:	94290913          	addi	s2,s2,-1726 # 80020b30 <log>
    800041f6:	854a                	mv	a0,s2
    800041f8:	ffffd097          	auipc	ra,0xffffd
    800041fc:	9de080e7          	jalr	-1570(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004200:	02c92603          	lw	a2,44(s2)
    80004204:	47f5                	li	a5,29
    80004206:	06c7c563          	blt	a5,a2,80004270 <log_write+0x90>
    8000420a:	0001d797          	auipc	a5,0x1d
    8000420e:	9427a783          	lw	a5,-1726(a5) # 80020b4c <log+0x1c>
    80004212:	37fd                	addiw	a5,a5,-1
    80004214:	04f65e63          	bge	a2,a5,80004270 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004218:	0001d797          	auipc	a5,0x1d
    8000421c:	9387a783          	lw	a5,-1736(a5) # 80020b50 <log+0x20>
    80004220:	06f05063          	blez	a5,80004280 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004224:	4781                	li	a5,0
    80004226:	06c05563          	blez	a2,80004290 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000422a:	44cc                	lw	a1,12(s1)
    8000422c:	0001d717          	auipc	a4,0x1d
    80004230:	93470713          	addi	a4,a4,-1740 # 80020b60 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004234:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004236:	4314                	lw	a3,0(a4)
    80004238:	04b68c63          	beq	a3,a1,80004290 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000423c:	2785                	addiw	a5,a5,1
    8000423e:	0711                	addi	a4,a4,4
    80004240:	fef61be3          	bne	a2,a5,80004236 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004244:	0621                	addi	a2,a2,8
    80004246:	060a                	slli	a2,a2,0x2
    80004248:	0001d797          	auipc	a5,0x1d
    8000424c:	8e878793          	addi	a5,a5,-1816 # 80020b30 <log>
    80004250:	963e                	add	a2,a2,a5
    80004252:	44dc                	lw	a5,12(s1)
    80004254:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004256:	8526                	mv	a0,s1
    80004258:	fffff097          	auipc	ra,0xfffff
    8000425c:	da2080e7          	jalr	-606(ra) # 80002ffa <bpin>
    log.lh.n++;
    80004260:	0001d717          	auipc	a4,0x1d
    80004264:	8d070713          	addi	a4,a4,-1840 # 80020b30 <log>
    80004268:	575c                	lw	a5,44(a4)
    8000426a:	2785                	addiw	a5,a5,1
    8000426c:	d75c                	sw	a5,44(a4)
    8000426e:	a835                	j	800042aa <log_write+0xca>
    panic("too big a transaction");
    80004270:	00004517          	auipc	a0,0x4
    80004274:	3d850513          	addi	a0,a0,984 # 80008648 <syscalls+0x1f8>
    80004278:	ffffc097          	auipc	ra,0xffffc
    8000427c:	2c6080e7          	jalr	710(ra) # 8000053e <panic>
    panic("log_write outside of trans");
    80004280:	00004517          	auipc	a0,0x4
    80004284:	3e050513          	addi	a0,a0,992 # 80008660 <syscalls+0x210>
    80004288:	ffffc097          	auipc	ra,0xffffc
    8000428c:	2b6080e7          	jalr	694(ra) # 8000053e <panic>
  log.lh.block[i] = b->blockno;
    80004290:	00878713          	addi	a4,a5,8
    80004294:	00271693          	slli	a3,a4,0x2
    80004298:	0001d717          	auipc	a4,0x1d
    8000429c:	89870713          	addi	a4,a4,-1896 # 80020b30 <log>
    800042a0:	9736                	add	a4,a4,a3
    800042a2:	44d4                	lw	a3,12(s1)
    800042a4:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042a6:	faf608e3          	beq	a2,a5,80004256 <log_write+0x76>
  }
  release(&log.lock);
    800042aa:	0001d517          	auipc	a0,0x1d
    800042ae:	88650513          	addi	a0,a0,-1914 # 80020b30 <log>
    800042b2:	ffffd097          	auipc	ra,0xffffd
    800042b6:	9d8080e7          	jalr	-1576(ra) # 80000c8a <release>
}
    800042ba:	60e2                	ld	ra,24(sp)
    800042bc:	6442                	ld	s0,16(sp)
    800042be:	64a2                	ld	s1,8(sp)
    800042c0:	6902                	ld	s2,0(sp)
    800042c2:	6105                	addi	sp,sp,32
    800042c4:	8082                	ret

00000000800042c6 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042c6:	1101                	addi	sp,sp,-32
    800042c8:	ec06                	sd	ra,24(sp)
    800042ca:	e822                	sd	s0,16(sp)
    800042cc:	e426                	sd	s1,8(sp)
    800042ce:	e04a                	sd	s2,0(sp)
    800042d0:	1000                	addi	s0,sp,32
    800042d2:	84aa                	mv	s1,a0
    800042d4:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800042d6:	00004597          	auipc	a1,0x4
    800042da:	3aa58593          	addi	a1,a1,938 # 80008680 <syscalls+0x230>
    800042de:	0521                	addi	a0,a0,8
    800042e0:	ffffd097          	auipc	ra,0xffffd
    800042e4:	866080e7          	jalr	-1946(ra) # 80000b46 <initlock>
  lk->name = name;
    800042e8:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042ec:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042f0:	0204a423          	sw	zero,40(s1)
}
    800042f4:	60e2                	ld	ra,24(sp)
    800042f6:	6442                	ld	s0,16(sp)
    800042f8:	64a2                	ld	s1,8(sp)
    800042fa:	6902                	ld	s2,0(sp)
    800042fc:	6105                	addi	sp,sp,32
    800042fe:	8082                	ret

0000000080004300 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004300:	1101                	addi	sp,sp,-32
    80004302:	ec06                	sd	ra,24(sp)
    80004304:	e822                	sd	s0,16(sp)
    80004306:	e426                	sd	s1,8(sp)
    80004308:	e04a                	sd	s2,0(sp)
    8000430a:	1000                	addi	s0,sp,32
    8000430c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000430e:	00850913          	addi	s2,a0,8
    80004312:	854a                	mv	a0,s2
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	8c2080e7          	jalr	-1854(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    8000431c:	409c                	lw	a5,0(s1)
    8000431e:	cb89                	beqz	a5,80004330 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004320:	85ca                	mv	a1,s2
    80004322:	8526                	mv	a0,s1
    80004324:	ffffe097          	auipc	ra,0xffffe
    80004328:	d30080e7          	jalr	-720(ra) # 80002054 <sleep>
  while (lk->locked) {
    8000432c:	409c                	lw	a5,0(s1)
    8000432e:	fbed                	bnez	a5,80004320 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004330:	4785                	li	a5,1
    80004332:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004334:	ffffd097          	auipc	ra,0xffffd
    80004338:	678080e7          	jalr	1656(ra) # 800019ac <myproc>
    8000433c:	591c                	lw	a5,48(a0)
    8000433e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004340:	854a                	mv	a0,s2
    80004342:	ffffd097          	auipc	ra,0xffffd
    80004346:	948080e7          	jalr	-1720(ra) # 80000c8a <release>
}
    8000434a:	60e2                	ld	ra,24(sp)
    8000434c:	6442                	ld	s0,16(sp)
    8000434e:	64a2                	ld	s1,8(sp)
    80004350:	6902                	ld	s2,0(sp)
    80004352:	6105                	addi	sp,sp,32
    80004354:	8082                	ret

0000000080004356 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004356:	1101                	addi	sp,sp,-32
    80004358:	ec06                	sd	ra,24(sp)
    8000435a:	e822                	sd	s0,16(sp)
    8000435c:	e426                	sd	s1,8(sp)
    8000435e:	e04a                	sd	s2,0(sp)
    80004360:	1000                	addi	s0,sp,32
    80004362:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004364:	00850913          	addi	s2,a0,8
    80004368:	854a                	mv	a0,s2
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	86c080e7          	jalr	-1940(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004372:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004376:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000437a:	8526                	mv	a0,s1
    8000437c:	ffffe097          	auipc	ra,0xffffe
    80004380:	d3c080e7          	jalr	-708(ra) # 800020b8 <wakeup>
  release(&lk->lk);
    80004384:	854a                	mv	a0,s2
    80004386:	ffffd097          	auipc	ra,0xffffd
    8000438a:	904080e7          	jalr	-1788(ra) # 80000c8a <release>
}
    8000438e:	60e2                	ld	ra,24(sp)
    80004390:	6442                	ld	s0,16(sp)
    80004392:	64a2                	ld	s1,8(sp)
    80004394:	6902                	ld	s2,0(sp)
    80004396:	6105                	addi	sp,sp,32
    80004398:	8082                	ret

000000008000439a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000439a:	7179                	addi	sp,sp,-48
    8000439c:	f406                	sd	ra,40(sp)
    8000439e:	f022                	sd	s0,32(sp)
    800043a0:	ec26                	sd	s1,24(sp)
    800043a2:	e84a                	sd	s2,16(sp)
    800043a4:	e44e                	sd	s3,8(sp)
    800043a6:	1800                	addi	s0,sp,48
    800043a8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043aa:	00850913          	addi	s2,a0,8
    800043ae:	854a                	mv	a0,s2
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	826080e7          	jalr	-2010(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043b8:	409c                	lw	a5,0(s1)
    800043ba:	ef99                	bnez	a5,800043d8 <holdingsleep+0x3e>
    800043bc:	4481                	li	s1,0
  release(&lk->lk);
    800043be:	854a                	mv	a0,s2
    800043c0:	ffffd097          	auipc	ra,0xffffd
    800043c4:	8ca080e7          	jalr	-1846(ra) # 80000c8a <release>
  return r;
}
    800043c8:	8526                	mv	a0,s1
    800043ca:	70a2                	ld	ra,40(sp)
    800043cc:	7402                	ld	s0,32(sp)
    800043ce:	64e2                	ld	s1,24(sp)
    800043d0:	6942                	ld	s2,16(sp)
    800043d2:	69a2                	ld	s3,8(sp)
    800043d4:	6145                	addi	sp,sp,48
    800043d6:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800043d8:	0284a983          	lw	s3,40(s1)
    800043dc:	ffffd097          	auipc	ra,0xffffd
    800043e0:	5d0080e7          	jalr	1488(ra) # 800019ac <myproc>
    800043e4:	5904                	lw	s1,48(a0)
    800043e6:	413484b3          	sub	s1,s1,s3
    800043ea:	0014b493          	seqz	s1,s1
    800043ee:	bfc1                	j	800043be <holdingsleep+0x24>

00000000800043f0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043f0:	1141                	addi	sp,sp,-16
    800043f2:	e406                	sd	ra,8(sp)
    800043f4:	e022                	sd	s0,0(sp)
    800043f6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043f8:	00004597          	auipc	a1,0x4
    800043fc:	29858593          	addi	a1,a1,664 # 80008690 <syscalls+0x240>
    80004400:	0001d517          	auipc	a0,0x1d
    80004404:	87850513          	addi	a0,a0,-1928 # 80020c78 <ftable>
    80004408:	ffffc097          	auipc	ra,0xffffc
    8000440c:	73e080e7          	jalr	1854(ra) # 80000b46 <initlock>
}
    80004410:	60a2                	ld	ra,8(sp)
    80004412:	6402                	ld	s0,0(sp)
    80004414:	0141                	addi	sp,sp,16
    80004416:	8082                	ret

0000000080004418 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004418:	1101                	addi	sp,sp,-32
    8000441a:	ec06                	sd	ra,24(sp)
    8000441c:	e822                	sd	s0,16(sp)
    8000441e:	e426                	sd	s1,8(sp)
    80004420:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004422:	0001d517          	auipc	a0,0x1d
    80004426:	85650513          	addi	a0,a0,-1962 # 80020c78 <ftable>
    8000442a:	ffffc097          	auipc	ra,0xffffc
    8000442e:	7ac080e7          	jalr	1964(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004432:	0001d497          	auipc	s1,0x1d
    80004436:	85e48493          	addi	s1,s1,-1954 # 80020c90 <ftable+0x18>
    8000443a:	0001d717          	auipc	a4,0x1d
    8000443e:	7f670713          	addi	a4,a4,2038 # 80021c30 <disk>
    if(f->ref == 0){
    80004442:	40dc                	lw	a5,4(s1)
    80004444:	cf99                	beqz	a5,80004462 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004446:	02848493          	addi	s1,s1,40
    8000444a:	fee49ce3          	bne	s1,a4,80004442 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000444e:	0001d517          	auipc	a0,0x1d
    80004452:	82a50513          	addi	a0,a0,-2006 # 80020c78 <ftable>
    80004456:	ffffd097          	auipc	ra,0xffffd
    8000445a:	834080e7          	jalr	-1996(ra) # 80000c8a <release>
  return 0;
    8000445e:	4481                	li	s1,0
    80004460:	a819                	j	80004476 <filealloc+0x5e>
      f->ref = 1;
    80004462:	4785                	li	a5,1
    80004464:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004466:	0001d517          	auipc	a0,0x1d
    8000446a:	81250513          	addi	a0,a0,-2030 # 80020c78 <ftable>
    8000446e:	ffffd097          	auipc	ra,0xffffd
    80004472:	81c080e7          	jalr	-2020(ra) # 80000c8a <release>
}
    80004476:	8526                	mv	a0,s1
    80004478:	60e2                	ld	ra,24(sp)
    8000447a:	6442                	ld	s0,16(sp)
    8000447c:	64a2                	ld	s1,8(sp)
    8000447e:	6105                	addi	sp,sp,32
    80004480:	8082                	ret

0000000080004482 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004482:	1101                	addi	sp,sp,-32
    80004484:	ec06                	sd	ra,24(sp)
    80004486:	e822                	sd	s0,16(sp)
    80004488:	e426                	sd	s1,8(sp)
    8000448a:	1000                	addi	s0,sp,32
    8000448c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000448e:	0001c517          	auipc	a0,0x1c
    80004492:	7ea50513          	addi	a0,a0,2026 # 80020c78 <ftable>
    80004496:	ffffc097          	auipc	ra,0xffffc
    8000449a:	740080e7          	jalr	1856(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000449e:	40dc                	lw	a5,4(s1)
    800044a0:	02f05263          	blez	a5,800044c4 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044a4:	2785                	addiw	a5,a5,1
    800044a6:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044a8:	0001c517          	auipc	a0,0x1c
    800044ac:	7d050513          	addi	a0,a0,2000 # 80020c78 <ftable>
    800044b0:	ffffc097          	auipc	ra,0xffffc
    800044b4:	7da080e7          	jalr	2010(ra) # 80000c8a <release>
  return f;
}
    800044b8:	8526                	mv	a0,s1
    800044ba:	60e2                	ld	ra,24(sp)
    800044bc:	6442                	ld	s0,16(sp)
    800044be:	64a2                	ld	s1,8(sp)
    800044c0:	6105                	addi	sp,sp,32
    800044c2:	8082                	ret
    panic("filedup");
    800044c4:	00004517          	auipc	a0,0x4
    800044c8:	1d450513          	addi	a0,a0,468 # 80008698 <syscalls+0x248>
    800044cc:	ffffc097          	auipc	ra,0xffffc
    800044d0:	072080e7          	jalr	114(ra) # 8000053e <panic>

00000000800044d4 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044d4:	7139                	addi	sp,sp,-64
    800044d6:	fc06                	sd	ra,56(sp)
    800044d8:	f822                	sd	s0,48(sp)
    800044da:	f426                	sd	s1,40(sp)
    800044dc:	f04a                	sd	s2,32(sp)
    800044de:	ec4e                	sd	s3,24(sp)
    800044e0:	e852                	sd	s4,16(sp)
    800044e2:	e456                	sd	s5,8(sp)
    800044e4:	0080                	addi	s0,sp,64
    800044e6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044e8:	0001c517          	auipc	a0,0x1c
    800044ec:	79050513          	addi	a0,a0,1936 # 80020c78 <ftable>
    800044f0:	ffffc097          	auipc	ra,0xffffc
    800044f4:	6e6080e7          	jalr	1766(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800044f8:	40dc                	lw	a5,4(s1)
    800044fa:	06f05163          	blez	a5,8000455c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044fe:	37fd                	addiw	a5,a5,-1
    80004500:	0007871b          	sext.w	a4,a5
    80004504:	c0dc                	sw	a5,4(s1)
    80004506:	06e04363          	bgtz	a4,8000456c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000450a:	0004a903          	lw	s2,0(s1)
    8000450e:	0094ca83          	lbu	s5,9(s1)
    80004512:	0104ba03          	ld	s4,16(s1)
    80004516:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000451a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000451e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004522:	0001c517          	auipc	a0,0x1c
    80004526:	75650513          	addi	a0,a0,1878 # 80020c78 <ftable>
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	760080e7          	jalr	1888(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004532:	4785                	li	a5,1
    80004534:	04f90d63          	beq	s2,a5,8000458e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004538:	3979                	addiw	s2,s2,-2
    8000453a:	4785                	li	a5,1
    8000453c:	0527e063          	bltu	a5,s2,8000457c <fileclose+0xa8>
    begin_op();
    80004540:	00000097          	auipc	ra,0x0
    80004544:	ac8080e7          	jalr	-1336(ra) # 80004008 <begin_op>
    iput(ff.ip);
    80004548:	854e                	mv	a0,s3
    8000454a:	fffff097          	auipc	ra,0xfffff
    8000454e:	2b6080e7          	jalr	694(ra) # 80003800 <iput>
    end_op();
    80004552:	00000097          	auipc	ra,0x0
    80004556:	b36080e7          	jalr	-1226(ra) # 80004088 <end_op>
    8000455a:	a00d                	j	8000457c <fileclose+0xa8>
    panic("fileclose");
    8000455c:	00004517          	auipc	a0,0x4
    80004560:	14450513          	addi	a0,a0,324 # 800086a0 <syscalls+0x250>
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	fda080e7          	jalr	-38(ra) # 8000053e <panic>
    release(&ftable.lock);
    8000456c:	0001c517          	auipc	a0,0x1c
    80004570:	70c50513          	addi	a0,a0,1804 # 80020c78 <ftable>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	716080e7          	jalr	1814(ra) # 80000c8a <release>
  }
}
    8000457c:	70e2                	ld	ra,56(sp)
    8000457e:	7442                	ld	s0,48(sp)
    80004580:	74a2                	ld	s1,40(sp)
    80004582:	7902                	ld	s2,32(sp)
    80004584:	69e2                	ld	s3,24(sp)
    80004586:	6a42                	ld	s4,16(sp)
    80004588:	6aa2                	ld	s5,8(sp)
    8000458a:	6121                	addi	sp,sp,64
    8000458c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000458e:	85d6                	mv	a1,s5
    80004590:	8552                	mv	a0,s4
    80004592:	00000097          	auipc	ra,0x0
    80004596:	34c080e7          	jalr	844(ra) # 800048de <pipeclose>
    8000459a:	b7cd                	j	8000457c <fileclose+0xa8>

000000008000459c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000459c:	715d                	addi	sp,sp,-80
    8000459e:	e486                	sd	ra,72(sp)
    800045a0:	e0a2                	sd	s0,64(sp)
    800045a2:	fc26                	sd	s1,56(sp)
    800045a4:	f84a                	sd	s2,48(sp)
    800045a6:	f44e                	sd	s3,40(sp)
    800045a8:	0880                	addi	s0,sp,80
    800045aa:	84aa                	mv	s1,a0
    800045ac:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045ae:	ffffd097          	auipc	ra,0xffffd
    800045b2:	3fe080e7          	jalr	1022(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045b6:	409c                	lw	a5,0(s1)
    800045b8:	37f9                	addiw	a5,a5,-2
    800045ba:	4705                	li	a4,1
    800045bc:	04f76763          	bltu	a4,a5,8000460a <filestat+0x6e>
    800045c0:	892a                	mv	s2,a0
    ilock(f->ip);
    800045c2:	6c88                	ld	a0,24(s1)
    800045c4:	fffff097          	auipc	ra,0xfffff
    800045c8:	082080e7          	jalr	130(ra) # 80003646 <ilock>
    stati(f->ip, &st);
    800045cc:	fb840593          	addi	a1,s0,-72
    800045d0:	6c88                	ld	a0,24(s1)
    800045d2:	fffff097          	auipc	ra,0xfffff
    800045d6:	2fe080e7          	jalr	766(ra) # 800038d0 <stati>
    iunlock(f->ip);
    800045da:	6c88                	ld	a0,24(s1)
    800045dc:	fffff097          	auipc	ra,0xfffff
    800045e0:	12c080e7          	jalr	300(ra) # 80003708 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800045e4:	46e1                	li	a3,24
    800045e6:	fb840613          	addi	a2,s0,-72
    800045ea:	85ce                	mv	a1,s3
    800045ec:	05093503          	ld	a0,80(s2)
    800045f0:	ffffd097          	auipc	ra,0xffffd
    800045f4:	078080e7          	jalr	120(ra) # 80001668 <copyout>
    800045f8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045fc:	60a6                	ld	ra,72(sp)
    800045fe:	6406                	ld	s0,64(sp)
    80004600:	74e2                	ld	s1,56(sp)
    80004602:	7942                	ld	s2,48(sp)
    80004604:	79a2                	ld	s3,40(sp)
    80004606:	6161                	addi	sp,sp,80
    80004608:	8082                	ret
  return -1;
    8000460a:	557d                	li	a0,-1
    8000460c:	bfc5                	j	800045fc <filestat+0x60>

000000008000460e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000460e:	7179                	addi	sp,sp,-48
    80004610:	f406                	sd	ra,40(sp)
    80004612:	f022                	sd	s0,32(sp)
    80004614:	ec26                	sd	s1,24(sp)
    80004616:	e84a                	sd	s2,16(sp)
    80004618:	e44e                	sd	s3,8(sp)
    8000461a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000461c:	00854783          	lbu	a5,8(a0)
    80004620:	c3d5                	beqz	a5,800046c4 <fileread+0xb6>
    80004622:	84aa                	mv	s1,a0
    80004624:	89ae                	mv	s3,a1
    80004626:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004628:	411c                	lw	a5,0(a0)
    8000462a:	4705                	li	a4,1
    8000462c:	04e78963          	beq	a5,a4,8000467e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004630:	470d                	li	a4,3
    80004632:	04e78d63          	beq	a5,a4,8000468c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004636:	4709                	li	a4,2
    80004638:	06e79e63          	bne	a5,a4,800046b4 <fileread+0xa6>
    ilock(f->ip);
    8000463c:	6d08                	ld	a0,24(a0)
    8000463e:	fffff097          	auipc	ra,0xfffff
    80004642:	008080e7          	jalr	8(ra) # 80003646 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004646:	874a                	mv	a4,s2
    80004648:	5094                	lw	a3,32(s1)
    8000464a:	864e                	mv	a2,s3
    8000464c:	4585                	li	a1,1
    8000464e:	6c88                	ld	a0,24(s1)
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	2aa080e7          	jalr	682(ra) # 800038fa <readi>
    80004658:	892a                	mv	s2,a0
    8000465a:	00a05563          	blez	a0,80004664 <fileread+0x56>
      f->off += r;
    8000465e:	509c                	lw	a5,32(s1)
    80004660:	9fa9                	addw	a5,a5,a0
    80004662:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004664:	6c88                	ld	a0,24(s1)
    80004666:	fffff097          	auipc	ra,0xfffff
    8000466a:	0a2080e7          	jalr	162(ra) # 80003708 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000466e:	854a                	mv	a0,s2
    80004670:	70a2                	ld	ra,40(sp)
    80004672:	7402                	ld	s0,32(sp)
    80004674:	64e2                	ld	s1,24(sp)
    80004676:	6942                	ld	s2,16(sp)
    80004678:	69a2                	ld	s3,8(sp)
    8000467a:	6145                	addi	sp,sp,48
    8000467c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000467e:	6908                	ld	a0,16(a0)
    80004680:	00000097          	auipc	ra,0x0
    80004684:	3c6080e7          	jalr	966(ra) # 80004a46 <piperead>
    80004688:	892a                	mv	s2,a0
    8000468a:	b7d5                	j	8000466e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000468c:	02451783          	lh	a5,36(a0)
    80004690:	03079693          	slli	a3,a5,0x30
    80004694:	92c1                	srli	a3,a3,0x30
    80004696:	4725                	li	a4,9
    80004698:	02d76863          	bltu	a4,a3,800046c8 <fileread+0xba>
    8000469c:	0792                	slli	a5,a5,0x4
    8000469e:	0001c717          	auipc	a4,0x1c
    800046a2:	53a70713          	addi	a4,a4,1338 # 80020bd8 <devsw>
    800046a6:	97ba                	add	a5,a5,a4
    800046a8:	639c                	ld	a5,0(a5)
    800046aa:	c38d                	beqz	a5,800046cc <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800046ac:	4505                	li	a0,1
    800046ae:	9782                	jalr	a5
    800046b0:	892a                	mv	s2,a0
    800046b2:	bf75                	j	8000466e <fileread+0x60>
    panic("fileread");
    800046b4:	00004517          	auipc	a0,0x4
    800046b8:	ffc50513          	addi	a0,a0,-4 # 800086b0 <syscalls+0x260>
    800046bc:	ffffc097          	auipc	ra,0xffffc
    800046c0:	e82080e7          	jalr	-382(ra) # 8000053e <panic>
    return -1;
    800046c4:	597d                	li	s2,-1
    800046c6:	b765                	j	8000466e <fileread+0x60>
      return -1;
    800046c8:	597d                	li	s2,-1
    800046ca:	b755                	j	8000466e <fileread+0x60>
    800046cc:	597d                	li	s2,-1
    800046ce:	b745                	j	8000466e <fileread+0x60>

00000000800046d0 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800046d0:	715d                	addi	sp,sp,-80
    800046d2:	e486                	sd	ra,72(sp)
    800046d4:	e0a2                	sd	s0,64(sp)
    800046d6:	fc26                	sd	s1,56(sp)
    800046d8:	f84a                	sd	s2,48(sp)
    800046da:	f44e                	sd	s3,40(sp)
    800046dc:	f052                	sd	s4,32(sp)
    800046de:	ec56                	sd	s5,24(sp)
    800046e0:	e85a                	sd	s6,16(sp)
    800046e2:	e45e                	sd	s7,8(sp)
    800046e4:	e062                	sd	s8,0(sp)
    800046e6:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800046e8:	00954783          	lbu	a5,9(a0)
    800046ec:	10078663          	beqz	a5,800047f8 <filewrite+0x128>
    800046f0:	892a                	mv	s2,a0
    800046f2:	8aae                	mv	s5,a1
    800046f4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046f6:	411c                	lw	a5,0(a0)
    800046f8:	4705                	li	a4,1
    800046fa:	02e78263          	beq	a5,a4,8000471e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046fe:	470d                	li	a4,3
    80004700:	02e78663          	beq	a5,a4,8000472c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004704:	4709                	li	a4,2
    80004706:	0ee79163          	bne	a5,a4,800047e8 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000470a:	0ac05d63          	blez	a2,800047c4 <filewrite+0xf4>
    int i = 0;
    8000470e:	4981                	li	s3,0
    80004710:	6b05                	lui	s6,0x1
    80004712:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004716:	6b85                	lui	s7,0x1
    80004718:	c00b8b9b          	addiw	s7,s7,-1024
    8000471c:	a861                	j	800047b4 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    8000471e:	6908                	ld	a0,16(a0)
    80004720:	00000097          	auipc	ra,0x0
    80004724:	22e080e7          	jalr	558(ra) # 8000494e <pipewrite>
    80004728:	8a2a                	mv	s4,a0
    8000472a:	a045                	j	800047ca <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000472c:	02451783          	lh	a5,36(a0)
    80004730:	03079693          	slli	a3,a5,0x30
    80004734:	92c1                	srli	a3,a3,0x30
    80004736:	4725                	li	a4,9
    80004738:	0cd76263          	bltu	a4,a3,800047fc <filewrite+0x12c>
    8000473c:	0792                	slli	a5,a5,0x4
    8000473e:	0001c717          	auipc	a4,0x1c
    80004742:	49a70713          	addi	a4,a4,1178 # 80020bd8 <devsw>
    80004746:	97ba                	add	a5,a5,a4
    80004748:	679c                	ld	a5,8(a5)
    8000474a:	cbdd                	beqz	a5,80004800 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000474c:	4505                	li	a0,1
    8000474e:	9782                	jalr	a5
    80004750:	8a2a                	mv	s4,a0
    80004752:	a8a5                	j	800047ca <filewrite+0xfa>
    80004754:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004758:	00000097          	auipc	ra,0x0
    8000475c:	8b0080e7          	jalr	-1872(ra) # 80004008 <begin_op>
      ilock(f->ip);
    80004760:	01893503          	ld	a0,24(s2)
    80004764:	fffff097          	auipc	ra,0xfffff
    80004768:	ee2080e7          	jalr	-286(ra) # 80003646 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000476c:	8762                	mv	a4,s8
    8000476e:	02092683          	lw	a3,32(s2)
    80004772:	01598633          	add	a2,s3,s5
    80004776:	4585                	li	a1,1
    80004778:	01893503          	ld	a0,24(s2)
    8000477c:	fffff097          	auipc	ra,0xfffff
    80004780:	276080e7          	jalr	630(ra) # 800039f2 <writei>
    80004784:	84aa                	mv	s1,a0
    80004786:	00a05763          	blez	a0,80004794 <filewrite+0xc4>
        f->off += r;
    8000478a:	02092783          	lw	a5,32(s2)
    8000478e:	9fa9                	addw	a5,a5,a0
    80004790:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004794:	01893503          	ld	a0,24(s2)
    80004798:	fffff097          	auipc	ra,0xfffff
    8000479c:	f70080e7          	jalr	-144(ra) # 80003708 <iunlock>
      end_op();
    800047a0:	00000097          	auipc	ra,0x0
    800047a4:	8e8080e7          	jalr	-1816(ra) # 80004088 <end_op>

      if(r != n1){
    800047a8:	009c1f63          	bne	s8,s1,800047c6 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800047ac:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800047b0:	0149db63          	bge	s3,s4,800047c6 <filewrite+0xf6>
      int n1 = n - i;
    800047b4:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800047b8:	84be                	mv	s1,a5
    800047ba:	2781                	sext.w	a5,a5
    800047bc:	f8fb5ce3          	bge	s6,a5,80004754 <filewrite+0x84>
    800047c0:	84de                	mv	s1,s7
    800047c2:	bf49                	j	80004754 <filewrite+0x84>
    int i = 0;
    800047c4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800047c6:	013a1f63          	bne	s4,s3,800047e4 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800047ca:	8552                	mv	a0,s4
    800047cc:	60a6                	ld	ra,72(sp)
    800047ce:	6406                	ld	s0,64(sp)
    800047d0:	74e2                	ld	s1,56(sp)
    800047d2:	7942                	ld	s2,48(sp)
    800047d4:	79a2                	ld	s3,40(sp)
    800047d6:	7a02                	ld	s4,32(sp)
    800047d8:	6ae2                	ld	s5,24(sp)
    800047da:	6b42                	ld	s6,16(sp)
    800047dc:	6ba2                	ld	s7,8(sp)
    800047de:	6c02                	ld	s8,0(sp)
    800047e0:	6161                	addi	sp,sp,80
    800047e2:	8082                	ret
    ret = (i == n ? n : -1);
    800047e4:	5a7d                	li	s4,-1
    800047e6:	b7d5                	j	800047ca <filewrite+0xfa>
    panic("filewrite");
    800047e8:	00004517          	auipc	a0,0x4
    800047ec:	ed850513          	addi	a0,a0,-296 # 800086c0 <syscalls+0x270>
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	d4e080e7          	jalr	-690(ra) # 8000053e <panic>
    return -1;
    800047f8:	5a7d                	li	s4,-1
    800047fa:	bfc1                	j	800047ca <filewrite+0xfa>
      return -1;
    800047fc:	5a7d                	li	s4,-1
    800047fe:	b7f1                	j	800047ca <filewrite+0xfa>
    80004800:	5a7d                	li	s4,-1
    80004802:	b7e1                	j	800047ca <filewrite+0xfa>

0000000080004804 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004804:	7179                	addi	sp,sp,-48
    80004806:	f406                	sd	ra,40(sp)
    80004808:	f022                	sd	s0,32(sp)
    8000480a:	ec26                	sd	s1,24(sp)
    8000480c:	e84a                	sd	s2,16(sp)
    8000480e:	e44e                	sd	s3,8(sp)
    80004810:	e052                	sd	s4,0(sp)
    80004812:	1800                	addi	s0,sp,48
    80004814:	84aa                	mv	s1,a0
    80004816:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004818:	0005b023          	sd	zero,0(a1)
    8000481c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004820:	00000097          	auipc	ra,0x0
    80004824:	bf8080e7          	jalr	-1032(ra) # 80004418 <filealloc>
    80004828:	e088                	sd	a0,0(s1)
    8000482a:	c551                	beqz	a0,800048b6 <pipealloc+0xb2>
    8000482c:	00000097          	auipc	ra,0x0
    80004830:	bec080e7          	jalr	-1044(ra) # 80004418 <filealloc>
    80004834:	00aa3023          	sd	a0,0(s4)
    80004838:	c92d                	beqz	a0,800048aa <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000483a:	ffffc097          	auipc	ra,0xffffc
    8000483e:	2ac080e7          	jalr	684(ra) # 80000ae6 <kalloc>
    80004842:	892a                	mv	s2,a0
    80004844:	c125                	beqz	a0,800048a4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004846:	4985                	li	s3,1
    80004848:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000484c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004850:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004854:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004858:	00004597          	auipc	a1,0x4
    8000485c:	e7858593          	addi	a1,a1,-392 # 800086d0 <syscalls+0x280>
    80004860:	ffffc097          	auipc	ra,0xffffc
    80004864:	2e6080e7          	jalr	742(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004868:	609c                	ld	a5,0(s1)
    8000486a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000486e:	609c                	ld	a5,0(s1)
    80004870:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004874:	609c                	ld	a5,0(s1)
    80004876:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000487a:	609c                	ld	a5,0(s1)
    8000487c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004880:	000a3783          	ld	a5,0(s4)
    80004884:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004888:	000a3783          	ld	a5,0(s4)
    8000488c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004890:	000a3783          	ld	a5,0(s4)
    80004894:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004898:	000a3783          	ld	a5,0(s4)
    8000489c:	0127b823          	sd	s2,16(a5)
  return 0;
    800048a0:	4501                	li	a0,0
    800048a2:	a025                	j	800048ca <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800048a4:	6088                	ld	a0,0(s1)
    800048a6:	e501                	bnez	a0,800048ae <pipealloc+0xaa>
    800048a8:	a039                	j	800048b6 <pipealloc+0xb2>
    800048aa:	6088                	ld	a0,0(s1)
    800048ac:	c51d                	beqz	a0,800048da <pipealloc+0xd6>
    fileclose(*f0);
    800048ae:	00000097          	auipc	ra,0x0
    800048b2:	c26080e7          	jalr	-986(ra) # 800044d4 <fileclose>
  if(*f1)
    800048b6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800048ba:	557d                	li	a0,-1
  if(*f1)
    800048bc:	c799                	beqz	a5,800048ca <pipealloc+0xc6>
    fileclose(*f1);
    800048be:	853e                	mv	a0,a5
    800048c0:	00000097          	auipc	ra,0x0
    800048c4:	c14080e7          	jalr	-1004(ra) # 800044d4 <fileclose>
  return -1;
    800048c8:	557d                	li	a0,-1
}
    800048ca:	70a2                	ld	ra,40(sp)
    800048cc:	7402                	ld	s0,32(sp)
    800048ce:	64e2                	ld	s1,24(sp)
    800048d0:	6942                	ld	s2,16(sp)
    800048d2:	69a2                	ld	s3,8(sp)
    800048d4:	6a02                	ld	s4,0(sp)
    800048d6:	6145                	addi	sp,sp,48
    800048d8:	8082                	ret
  return -1;
    800048da:	557d                	li	a0,-1
    800048dc:	b7fd                	j	800048ca <pipealloc+0xc6>

00000000800048de <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800048de:	1101                	addi	sp,sp,-32
    800048e0:	ec06                	sd	ra,24(sp)
    800048e2:	e822                	sd	s0,16(sp)
    800048e4:	e426                	sd	s1,8(sp)
    800048e6:	e04a                	sd	s2,0(sp)
    800048e8:	1000                	addi	s0,sp,32
    800048ea:	84aa                	mv	s1,a0
    800048ec:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048ee:	ffffc097          	auipc	ra,0xffffc
    800048f2:	2e8080e7          	jalr	744(ra) # 80000bd6 <acquire>
  if(writable){
    800048f6:	02090d63          	beqz	s2,80004930 <pipeclose+0x52>
    pi->writeopen = 0;
    800048fa:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048fe:	21848513          	addi	a0,s1,536
    80004902:	ffffd097          	auipc	ra,0xffffd
    80004906:	7b6080e7          	jalr	1974(ra) # 800020b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000490a:	2204b783          	ld	a5,544(s1)
    8000490e:	eb95                	bnez	a5,80004942 <pipeclose+0x64>
    release(&pi->lock);
    80004910:	8526                	mv	a0,s1
    80004912:	ffffc097          	auipc	ra,0xffffc
    80004916:	378080e7          	jalr	888(ra) # 80000c8a <release>
    kfree((char*)pi);
    8000491a:	8526                	mv	a0,s1
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	0ce080e7          	jalr	206(ra) # 800009ea <kfree>
  } else
    release(&pi->lock);
}
    80004924:	60e2                	ld	ra,24(sp)
    80004926:	6442                	ld	s0,16(sp)
    80004928:	64a2                	ld	s1,8(sp)
    8000492a:	6902                	ld	s2,0(sp)
    8000492c:	6105                	addi	sp,sp,32
    8000492e:	8082                	ret
    pi->readopen = 0;
    80004930:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004934:	21c48513          	addi	a0,s1,540
    80004938:	ffffd097          	auipc	ra,0xffffd
    8000493c:	780080e7          	jalr	1920(ra) # 800020b8 <wakeup>
    80004940:	b7e9                	j	8000490a <pipeclose+0x2c>
    release(&pi->lock);
    80004942:	8526                	mv	a0,s1
    80004944:	ffffc097          	auipc	ra,0xffffc
    80004948:	346080e7          	jalr	838(ra) # 80000c8a <release>
}
    8000494c:	bfe1                	j	80004924 <pipeclose+0x46>

000000008000494e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000494e:	711d                	addi	sp,sp,-96
    80004950:	ec86                	sd	ra,88(sp)
    80004952:	e8a2                	sd	s0,80(sp)
    80004954:	e4a6                	sd	s1,72(sp)
    80004956:	e0ca                	sd	s2,64(sp)
    80004958:	fc4e                	sd	s3,56(sp)
    8000495a:	f852                	sd	s4,48(sp)
    8000495c:	f456                	sd	s5,40(sp)
    8000495e:	f05a                	sd	s6,32(sp)
    80004960:	ec5e                	sd	s7,24(sp)
    80004962:	e862                	sd	s8,16(sp)
    80004964:	1080                	addi	s0,sp,96
    80004966:	84aa                	mv	s1,a0
    80004968:	8aae                	mv	s5,a1
    8000496a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000496c:	ffffd097          	auipc	ra,0xffffd
    80004970:	040080e7          	jalr	64(ra) # 800019ac <myproc>
    80004974:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004976:	8526                	mv	a0,s1
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	25e080e7          	jalr	606(ra) # 80000bd6 <acquire>
  while(i < n){
    80004980:	0b405663          	blez	s4,80004a2c <pipewrite+0xde>
  int i = 0;
    80004984:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004986:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004988:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000498c:	21c48b93          	addi	s7,s1,540
    80004990:	a089                	j	800049d2 <pipewrite+0x84>
      release(&pi->lock);
    80004992:	8526                	mv	a0,s1
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	2f6080e7          	jalr	758(ra) # 80000c8a <release>
      return -1;
    8000499c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000499e:	854a                	mv	a0,s2
    800049a0:	60e6                	ld	ra,88(sp)
    800049a2:	6446                	ld	s0,80(sp)
    800049a4:	64a6                	ld	s1,72(sp)
    800049a6:	6906                	ld	s2,64(sp)
    800049a8:	79e2                	ld	s3,56(sp)
    800049aa:	7a42                	ld	s4,48(sp)
    800049ac:	7aa2                	ld	s5,40(sp)
    800049ae:	7b02                	ld	s6,32(sp)
    800049b0:	6be2                	ld	s7,24(sp)
    800049b2:	6c42                	ld	s8,16(sp)
    800049b4:	6125                	addi	sp,sp,96
    800049b6:	8082                	ret
      wakeup(&pi->nread);
    800049b8:	8562                	mv	a0,s8
    800049ba:	ffffd097          	auipc	ra,0xffffd
    800049be:	6fe080e7          	jalr	1790(ra) # 800020b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800049c2:	85a6                	mv	a1,s1
    800049c4:	855e                	mv	a0,s7
    800049c6:	ffffd097          	auipc	ra,0xffffd
    800049ca:	68e080e7          	jalr	1678(ra) # 80002054 <sleep>
  while(i < n){
    800049ce:	07495063          	bge	s2,s4,80004a2e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800049d2:	2204a783          	lw	a5,544(s1)
    800049d6:	dfd5                	beqz	a5,80004992 <pipewrite+0x44>
    800049d8:	854e                	mv	a0,s3
    800049da:	ffffe097          	auipc	ra,0xffffe
    800049de:	922080e7          	jalr	-1758(ra) # 800022fc <killed>
    800049e2:	f945                	bnez	a0,80004992 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800049e4:	2184a783          	lw	a5,536(s1)
    800049e8:	21c4a703          	lw	a4,540(s1)
    800049ec:	2007879b          	addiw	a5,a5,512
    800049f0:	fcf704e3          	beq	a4,a5,800049b8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049f4:	4685                	li	a3,1
    800049f6:	01590633          	add	a2,s2,s5
    800049fa:	faf40593          	addi	a1,s0,-81
    800049fe:	0509b503          	ld	a0,80(s3)
    80004a02:	ffffd097          	auipc	ra,0xffffd
    80004a06:	cf2080e7          	jalr	-782(ra) # 800016f4 <copyin>
    80004a0a:	03650263          	beq	a0,s6,80004a2e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a0e:	21c4a783          	lw	a5,540(s1)
    80004a12:	0017871b          	addiw	a4,a5,1
    80004a16:	20e4ae23          	sw	a4,540(s1)
    80004a1a:	1ff7f793          	andi	a5,a5,511
    80004a1e:	97a6                	add	a5,a5,s1
    80004a20:	faf44703          	lbu	a4,-81(s0)
    80004a24:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a28:	2905                	addiw	s2,s2,1
    80004a2a:	b755                	j	800049ce <pipewrite+0x80>
  int i = 0;
    80004a2c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004a2e:	21848513          	addi	a0,s1,536
    80004a32:	ffffd097          	auipc	ra,0xffffd
    80004a36:	686080e7          	jalr	1670(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004a3a:	8526                	mv	a0,s1
    80004a3c:	ffffc097          	auipc	ra,0xffffc
    80004a40:	24e080e7          	jalr	590(ra) # 80000c8a <release>
  return i;
    80004a44:	bfa9                	j	8000499e <pipewrite+0x50>

0000000080004a46 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004a46:	715d                	addi	sp,sp,-80
    80004a48:	e486                	sd	ra,72(sp)
    80004a4a:	e0a2                	sd	s0,64(sp)
    80004a4c:	fc26                	sd	s1,56(sp)
    80004a4e:	f84a                	sd	s2,48(sp)
    80004a50:	f44e                	sd	s3,40(sp)
    80004a52:	f052                	sd	s4,32(sp)
    80004a54:	ec56                	sd	s5,24(sp)
    80004a56:	e85a                	sd	s6,16(sp)
    80004a58:	0880                	addi	s0,sp,80
    80004a5a:	84aa                	mv	s1,a0
    80004a5c:	892e                	mv	s2,a1
    80004a5e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a60:	ffffd097          	auipc	ra,0xffffd
    80004a64:	f4c080e7          	jalr	-180(ra) # 800019ac <myproc>
    80004a68:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	16a080e7          	jalr	362(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a74:	2184a703          	lw	a4,536(s1)
    80004a78:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a7c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a80:	02f71763          	bne	a4,a5,80004aae <piperead+0x68>
    80004a84:	2244a783          	lw	a5,548(s1)
    80004a88:	c39d                	beqz	a5,80004aae <piperead+0x68>
    if(killed(pr)){
    80004a8a:	8552                	mv	a0,s4
    80004a8c:	ffffe097          	auipc	ra,0xffffe
    80004a90:	870080e7          	jalr	-1936(ra) # 800022fc <killed>
    80004a94:	e941                	bnez	a0,80004b24 <piperead+0xde>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a96:	85a6                	mv	a1,s1
    80004a98:	854e                	mv	a0,s3
    80004a9a:	ffffd097          	auipc	ra,0xffffd
    80004a9e:	5ba080e7          	jalr	1466(ra) # 80002054 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004aa2:	2184a703          	lw	a4,536(s1)
    80004aa6:	21c4a783          	lw	a5,540(s1)
    80004aaa:	fcf70de3          	beq	a4,a5,80004a84 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aae:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ab0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ab2:	05505363          	blez	s5,80004af8 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80004ab6:	2184a783          	lw	a5,536(s1)
    80004aba:	21c4a703          	lw	a4,540(s1)
    80004abe:	02f70d63          	beq	a4,a5,80004af8 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004ac2:	0017871b          	addiw	a4,a5,1
    80004ac6:	20e4ac23          	sw	a4,536(s1)
    80004aca:	1ff7f793          	andi	a5,a5,511
    80004ace:	97a6                	add	a5,a5,s1
    80004ad0:	0187c783          	lbu	a5,24(a5)
    80004ad4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ad8:	4685                	li	a3,1
    80004ada:	fbf40613          	addi	a2,s0,-65
    80004ade:	85ca                	mv	a1,s2
    80004ae0:	050a3503          	ld	a0,80(s4)
    80004ae4:	ffffd097          	auipc	ra,0xffffd
    80004ae8:	b84080e7          	jalr	-1148(ra) # 80001668 <copyout>
    80004aec:	01650663          	beq	a0,s6,80004af8 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004af0:	2985                	addiw	s3,s3,1
    80004af2:	0905                	addi	s2,s2,1
    80004af4:	fd3a91e3          	bne	s5,s3,80004ab6 <piperead+0x70>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004af8:	21c48513          	addi	a0,s1,540
    80004afc:	ffffd097          	auipc	ra,0xffffd
    80004b00:	5bc080e7          	jalr	1468(ra) # 800020b8 <wakeup>
  release(&pi->lock);
    80004b04:	8526                	mv	a0,s1
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	184080e7          	jalr	388(ra) # 80000c8a <release>
  return i;
}
    80004b0e:	854e                	mv	a0,s3
    80004b10:	60a6                	ld	ra,72(sp)
    80004b12:	6406                	ld	s0,64(sp)
    80004b14:	74e2                	ld	s1,56(sp)
    80004b16:	7942                	ld	s2,48(sp)
    80004b18:	79a2                	ld	s3,40(sp)
    80004b1a:	7a02                	ld	s4,32(sp)
    80004b1c:	6ae2                	ld	s5,24(sp)
    80004b1e:	6b42                	ld	s6,16(sp)
    80004b20:	6161                	addi	sp,sp,80
    80004b22:	8082                	ret
      release(&pi->lock);
    80004b24:	8526                	mv	a0,s1
    80004b26:	ffffc097          	auipc	ra,0xffffc
    80004b2a:	164080e7          	jalr	356(ra) # 80000c8a <release>
      return -1;
    80004b2e:	59fd                	li	s3,-1
    80004b30:	bff9                	j	80004b0e <piperead+0xc8>

0000000080004b32 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004b32:	1141                	addi	sp,sp,-16
    80004b34:	e422                	sd	s0,8(sp)
    80004b36:	0800                	addi	s0,sp,16
    80004b38:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004b3a:	8905                	andi	a0,a0,1
    80004b3c:	c111                	beqz	a0,80004b40 <flags2perm+0xe>
      perm = PTE_X;
    80004b3e:	4521                	li	a0,8
    if(flags & 0x2)
    80004b40:	8b89                	andi	a5,a5,2
    80004b42:	c399                	beqz	a5,80004b48 <flags2perm+0x16>
      perm |= PTE_W;
    80004b44:	00456513          	ori	a0,a0,4
    return perm;
}
    80004b48:	6422                	ld	s0,8(sp)
    80004b4a:	0141                	addi	sp,sp,16
    80004b4c:	8082                	ret

0000000080004b4e <exec>:

int
exec(char *path, char **argv)
{
    80004b4e:	de010113          	addi	sp,sp,-544
    80004b52:	20113c23          	sd	ra,536(sp)
    80004b56:	20813823          	sd	s0,528(sp)
    80004b5a:	20913423          	sd	s1,520(sp)
    80004b5e:	21213023          	sd	s2,512(sp)
    80004b62:	ffce                	sd	s3,504(sp)
    80004b64:	fbd2                	sd	s4,496(sp)
    80004b66:	f7d6                	sd	s5,488(sp)
    80004b68:	f3da                	sd	s6,480(sp)
    80004b6a:	efde                	sd	s7,472(sp)
    80004b6c:	ebe2                	sd	s8,464(sp)
    80004b6e:	e7e6                	sd	s9,456(sp)
    80004b70:	e3ea                	sd	s10,448(sp)
    80004b72:	ff6e                	sd	s11,440(sp)
    80004b74:	1400                	addi	s0,sp,544
    80004b76:	892a                	mv	s2,a0
    80004b78:	dea43423          	sd	a0,-536(s0)
    80004b7c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b80:	ffffd097          	auipc	ra,0xffffd
    80004b84:	e2c080e7          	jalr	-468(ra) # 800019ac <myproc>
    80004b88:	84aa                	mv	s1,a0

  begin_op();
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	47e080e7          	jalr	1150(ra) # 80004008 <begin_op>

  if((ip = namei(path)) == 0){
    80004b92:	854a                	mv	a0,s2
    80004b94:	fffff097          	auipc	ra,0xfffff
    80004b98:	258080e7          	jalr	600(ra) # 80003dec <namei>
    80004b9c:	c93d                	beqz	a0,80004c12 <exec+0xc4>
    80004b9e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ba0:	fffff097          	auipc	ra,0xfffff
    80004ba4:	aa6080e7          	jalr	-1370(ra) # 80003646 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ba8:	04000713          	li	a4,64
    80004bac:	4681                	li	a3,0
    80004bae:	e5040613          	addi	a2,s0,-432
    80004bb2:	4581                	li	a1,0
    80004bb4:	8556                	mv	a0,s5
    80004bb6:	fffff097          	auipc	ra,0xfffff
    80004bba:	d44080e7          	jalr	-700(ra) # 800038fa <readi>
    80004bbe:	04000793          	li	a5,64
    80004bc2:	00f51a63          	bne	a0,a5,80004bd6 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004bc6:	e5042703          	lw	a4,-432(s0)
    80004bca:	464c47b7          	lui	a5,0x464c4
    80004bce:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004bd2:	04f70663          	beq	a4,a5,80004c1e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004bd6:	8556                	mv	a0,s5
    80004bd8:	fffff097          	auipc	ra,0xfffff
    80004bdc:	cd0080e7          	jalr	-816(ra) # 800038a8 <iunlockput>
    end_op();
    80004be0:	fffff097          	auipc	ra,0xfffff
    80004be4:	4a8080e7          	jalr	1192(ra) # 80004088 <end_op>
  }
  return -1;
    80004be8:	557d                	li	a0,-1
}
    80004bea:	21813083          	ld	ra,536(sp)
    80004bee:	21013403          	ld	s0,528(sp)
    80004bf2:	20813483          	ld	s1,520(sp)
    80004bf6:	20013903          	ld	s2,512(sp)
    80004bfa:	79fe                	ld	s3,504(sp)
    80004bfc:	7a5e                	ld	s4,496(sp)
    80004bfe:	7abe                	ld	s5,488(sp)
    80004c00:	7b1e                	ld	s6,480(sp)
    80004c02:	6bfe                	ld	s7,472(sp)
    80004c04:	6c5e                	ld	s8,464(sp)
    80004c06:	6cbe                	ld	s9,456(sp)
    80004c08:	6d1e                	ld	s10,448(sp)
    80004c0a:	7dfa                	ld	s11,440(sp)
    80004c0c:	22010113          	addi	sp,sp,544
    80004c10:	8082                	ret
    end_op();
    80004c12:	fffff097          	auipc	ra,0xfffff
    80004c16:	476080e7          	jalr	1142(ra) # 80004088 <end_op>
    return -1;
    80004c1a:	557d                	li	a0,-1
    80004c1c:	b7f9                	j	80004bea <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004c1e:	8526                	mv	a0,s1
    80004c20:	ffffd097          	auipc	ra,0xffffd
    80004c24:	e50080e7          	jalr	-432(ra) # 80001a70 <proc_pagetable>
    80004c28:	8b2a                	mv	s6,a0
    80004c2a:	d555                	beqz	a0,80004bd6 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c2c:	e7042783          	lw	a5,-400(s0)
    80004c30:	e8845703          	lhu	a4,-376(s0)
    80004c34:	c735                	beqz	a4,80004ca0 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c36:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c38:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004c3c:	6a05                	lui	s4,0x1
    80004c3e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004c42:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c46:	6d85                	lui	s11,0x1
    80004c48:	7d7d                	lui	s10,0xfffff
    80004c4a:	a481                	j	80004e8a <exec+0x33c>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004c4c:	00004517          	auipc	a0,0x4
    80004c50:	a8c50513          	addi	a0,a0,-1396 # 800086d8 <syscalls+0x288>
    80004c54:	ffffc097          	auipc	ra,0xffffc
    80004c58:	8ea080e7          	jalr	-1814(ra) # 8000053e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c5c:	874a                	mv	a4,s2
    80004c5e:	009c86bb          	addw	a3,s9,s1
    80004c62:	4581                	li	a1,0
    80004c64:	8556                	mv	a0,s5
    80004c66:	fffff097          	auipc	ra,0xfffff
    80004c6a:	c94080e7          	jalr	-876(ra) # 800038fa <readi>
    80004c6e:	2501                	sext.w	a0,a0
    80004c70:	1aa91a63          	bne	s2,a0,80004e24 <exec+0x2d6>
  for(i = 0; i < sz; i += PGSIZE){
    80004c74:	009d84bb          	addw	s1,s11,s1
    80004c78:	013d09bb          	addw	s3,s10,s3
    80004c7c:	1f74f763          	bgeu	s1,s7,80004e6a <exec+0x31c>
    pa = walkaddr(pagetable, va + i);
    80004c80:	02049593          	slli	a1,s1,0x20
    80004c84:	9181                	srli	a1,a1,0x20
    80004c86:	95e2                	add	a1,a1,s8
    80004c88:	855a                	mv	a0,s6
    80004c8a:	ffffc097          	auipc	ra,0xffffc
    80004c8e:	3d2080e7          	jalr	978(ra) # 8000105c <walkaddr>
    80004c92:	862a                	mv	a2,a0
    if(pa == 0)
    80004c94:	dd45                	beqz	a0,80004c4c <exec+0xfe>
      n = PGSIZE;
    80004c96:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004c98:	fd49f2e3          	bgeu	s3,s4,80004c5c <exec+0x10e>
      n = sz - i;
    80004c9c:	894e                	mv	s2,s3
    80004c9e:	bf7d                	j	80004c5c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ca0:	4901                	li	s2,0
  iunlockput(ip);
    80004ca2:	8556                	mv	a0,s5
    80004ca4:	fffff097          	auipc	ra,0xfffff
    80004ca8:	c04080e7          	jalr	-1020(ra) # 800038a8 <iunlockput>
  end_op();
    80004cac:	fffff097          	auipc	ra,0xfffff
    80004cb0:	3dc080e7          	jalr	988(ra) # 80004088 <end_op>
  p = myproc();
    80004cb4:	ffffd097          	auipc	ra,0xffffd
    80004cb8:	cf8080e7          	jalr	-776(ra) # 800019ac <myproc>
    80004cbc:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004cbe:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004cc2:	6785                	lui	a5,0x1
    80004cc4:	17fd                	addi	a5,a5,-1
    80004cc6:	993e                	add	s2,s2,a5
    80004cc8:	77fd                	lui	a5,0xfffff
    80004cca:	00f977b3          	and	a5,s2,a5
    80004cce:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004cd2:	4691                	li	a3,4
    80004cd4:	6609                	lui	a2,0x2
    80004cd6:	963e                	add	a2,a2,a5
    80004cd8:	85be                	mv	a1,a5
    80004cda:	855a                	mv	a0,s6
    80004cdc:	ffffc097          	auipc	ra,0xffffc
    80004ce0:	734080e7          	jalr	1844(ra) # 80001410 <uvmalloc>
    80004ce4:	8c2a                	mv	s8,a0
  ip = 0;
    80004ce6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004ce8:	12050e63          	beqz	a0,80004e24 <exec+0x2d6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004cec:	75f9                	lui	a1,0xffffe
    80004cee:	95aa                	add	a1,a1,a0
    80004cf0:	855a                	mv	a0,s6
    80004cf2:	ffffd097          	auipc	ra,0xffffd
    80004cf6:	944080e7          	jalr	-1724(ra) # 80001636 <uvmclear>
  stackbase = sp - PGSIZE;
    80004cfa:	7afd                	lui	s5,0xfffff
    80004cfc:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004cfe:	df043783          	ld	a5,-528(s0)
    80004d02:	6388                	ld	a0,0(a5)
    80004d04:	c925                	beqz	a0,80004d74 <exec+0x226>
    80004d06:	e9040993          	addi	s3,s0,-368
    80004d0a:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004d0e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d10:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d12:	ffffc097          	auipc	ra,0xffffc
    80004d16:	13c080e7          	jalr	316(ra) # 80000e4e <strlen>
    80004d1a:	0015079b          	addiw	a5,a0,1
    80004d1e:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d22:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004d26:	13596663          	bltu	s2,s5,80004e52 <exec+0x304>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d2a:	df043d83          	ld	s11,-528(s0)
    80004d2e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004d32:	8552                	mv	a0,s4
    80004d34:	ffffc097          	auipc	ra,0xffffc
    80004d38:	11a080e7          	jalr	282(ra) # 80000e4e <strlen>
    80004d3c:	0015069b          	addiw	a3,a0,1
    80004d40:	8652                	mv	a2,s4
    80004d42:	85ca                	mv	a1,s2
    80004d44:	855a                	mv	a0,s6
    80004d46:	ffffd097          	auipc	ra,0xffffd
    80004d4a:	922080e7          	jalr	-1758(ra) # 80001668 <copyout>
    80004d4e:	10054663          	bltz	a0,80004e5a <exec+0x30c>
    ustack[argc] = sp;
    80004d52:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004d56:	0485                	addi	s1,s1,1
    80004d58:	008d8793          	addi	a5,s11,8
    80004d5c:	def43823          	sd	a5,-528(s0)
    80004d60:	008db503          	ld	a0,8(s11)
    80004d64:	c911                	beqz	a0,80004d78 <exec+0x22a>
    if(argc >= MAXARG)
    80004d66:	09a1                	addi	s3,s3,8
    80004d68:	fb3c95e3          	bne	s9,s3,80004d12 <exec+0x1c4>
  sz = sz1;
    80004d6c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d70:	4a81                	li	s5,0
    80004d72:	a84d                	j	80004e24 <exec+0x2d6>
  sp = sz;
    80004d74:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004d76:	4481                	li	s1,0
  ustack[argc] = 0;
    80004d78:	00349793          	slli	a5,s1,0x3
    80004d7c:	f9040713          	addi	a4,s0,-112
    80004d80:	97ba                	add	a5,a5,a4
    80004d82:	f007b023          	sd	zero,-256(a5) # ffffffffffffef00 <end+0xffffffff7ffdd190>
  sp -= (argc+1) * sizeof(uint64);
    80004d86:	00148693          	addi	a3,s1,1
    80004d8a:	068e                	slli	a3,a3,0x3
    80004d8c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004d90:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004d94:	01597663          	bgeu	s2,s5,80004da0 <exec+0x252>
  sz = sz1;
    80004d98:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004d9c:	4a81                	li	s5,0
    80004d9e:	a059                	j	80004e24 <exec+0x2d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004da0:	e9040613          	addi	a2,s0,-368
    80004da4:	85ca                	mv	a1,s2
    80004da6:	855a                	mv	a0,s6
    80004da8:	ffffd097          	auipc	ra,0xffffd
    80004dac:	8c0080e7          	jalr	-1856(ra) # 80001668 <copyout>
    80004db0:	0a054963          	bltz	a0,80004e62 <exec+0x314>
  p->trapframe->a1 = sp;
    80004db4:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004db8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004dbc:	de843783          	ld	a5,-536(s0)
    80004dc0:	0007c703          	lbu	a4,0(a5)
    80004dc4:	cf11                	beqz	a4,80004de0 <exec+0x292>
    80004dc6:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004dc8:	02f00693          	li	a3,47
    80004dcc:	a039                	j	80004dda <exec+0x28c>
      last = s+1;
    80004dce:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004dd2:	0785                	addi	a5,a5,1
    80004dd4:	fff7c703          	lbu	a4,-1(a5)
    80004dd8:	c701                	beqz	a4,80004de0 <exec+0x292>
    if(*s == '/')
    80004dda:	fed71ce3          	bne	a4,a3,80004dd2 <exec+0x284>
    80004dde:	bfc5                	j	80004dce <exec+0x280>
  safestrcpy(p->name, last, sizeof(p->name));
    80004de0:	4641                	li	a2,16
    80004de2:	de843583          	ld	a1,-536(s0)
    80004de6:	158b8513          	addi	a0,s7,344
    80004dea:	ffffc097          	auipc	ra,0xffffc
    80004dee:	032080e7          	jalr	50(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80004df2:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004df6:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004dfa:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004dfe:	058bb783          	ld	a5,88(s7)
    80004e02:	e6843703          	ld	a4,-408(s0)
    80004e06:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e08:	058bb783          	ld	a5,88(s7)
    80004e0c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e10:	85ea                	mv	a1,s10
    80004e12:	ffffd097          	auipc	ra,0xffffd
    80004e16:	cfa080e7          	jalr	-774(ra) # 80001b0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e1a:	0004851b          	sext.w	a0,s1
    80004e1e:	b3f1                	j	80004bea <exec+0x9c>
    80004e20:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004e24:	df843583          	ld	a1,-520(s0)
    80004e28:	855a                	mv	a0,s6
    80004e2a:	ffffd097          	auipc	ra,0xffffd
    80004e2e:	ce2080e7          	jalr	-798(ra) # 80001b0c <proc_freepagetable>
  if(ip){
    80004e32:	da0a92e3          	bnez	s5,80004bd6 <exec+0x88>
  return -1;
    80004e36:	557d                	li	a0,-1
    80004e38:	bb4d                	j	80004bea <exec+0x9c>
    80004e3a:	df243c23          	sd	s2,-520(s0)
    80004e3e:	b7dd                	j	80004e24 <exec+0x2d6>
    80004e40:	df243c23          	sd	s2,-520(s0)
    80004e44:	b7c5                	j	80004e24 <exec+0x2d6>
    80004e46:	df243c23          	sd	s2,-520(s0)
    80004e4a:	bfe9                	j	80004e24 <exec+0x2d6>
    80004e4c:	df243c23          	sd	s2,-520(s0)
    80004e50:	bfd1                	j	80004e24 <exec+0x2d6>
  sz = sz1;
    80004e52:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e56:	4a81                	li	s5,0
    80004e58:	b7f1                	j	80004e24 <exec+0x2d6>
  sz = sz1;
    80004e5a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e5e:	4a81                	li	s5,0
    80004e60:	b7d1                	j	80004e24 <exec+0x2d6>
  sz = sz1;
    80004e62:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e66:	4a81                	li	s5,0
    80004e68:	bf75                	j	80004e24 <exec+0x2d6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e6a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e6e:	e0843783          	ld	a5,-504(s0)
    80004e72:	0017869b          	addiw	a3,a5,1
    80004e76:	e0d43423          	sd	a3,-504(s0)
    80004e7a:	e0043783          	ld	a5,-512(s0)
    80004e7e:	0387879b          	addiw	a5,a5,56
    80004e82:	e8845703          	lhu	a4,-376(s0)
    80004e86:	e0e6dee3          	bge	a3,a4,80004ca2 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e8a:	2781                	sext.w	a5,a5
    80004e8c:	e0f43023          	sd	a5,-512(s0)
    80004e90:	03800713          	li	a4,56
    80004e94:	86be                	mv	a3,a5
    80004e96:	e1840613          	addi	a2,s0,-488
    80004e9a:	4581                	li	a1,0
    80004e9c:	8556                	mv	a0,s5
    80004e9e:	fffff097          	auipc	ra,0xfffff
    80004ea2:	a5c080e7          	jalr	-1444(ra) # 800038fa <readi>
    80004ea6:	03800793          	li	a5,56
    80004eaa:	f6f51be3          	bne	a0,a5,80004e20 <exec+0x2d2>
    if(ph.type != ELF_PROG_LOAD)
    80004eae:	e1842783          	lw	a5,-488(s0)
    80004eb2:	4705                	li	a4,1
    80004eb4:	fae79de3          	bne	a5,a4,80004e6e <exec+0x320>
    if(ph.memsz < ph.filesz)
    80004eb8:	e4043483          	ld	s1,-448(s0)
    80004ebc:	e3843783          	ld	a5,-456(s0)
    80004ec0:	f6f4ede3          	bltu	s1,a5,80004e3a <exec+0x2ec>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ec4:	e2843783          	ld	a5,-472(s0)
    80004ec8:	94be                	add	s1,s1,a5
    80004eca:	f6f4ebe3          	bltu	s1,a5,80004e40 <exec+0x2f2>
    if(ph.vaddr % PGSIZE != 0)
    80004ece:	de043703          	ld	a4,-544(s0)
    80004ed2:	8ff9                	and	a5,a5,a4
    80004ed4:	fbad                	bnez	a5,80004e46 <exec+0x2f8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ed6:	e1c42503          	lw	a0,-484(s0)
    80004eda:	00000097          	auipc	ra,0x0
    80004ede:	c58080e7          	jalr	-936(ra) # 80004b32 <flags2perm>
    80004ee2:	86aa                	mv	a3,a0
    80004ee4:	8626                	mv	a2,s1
    80004ee6:	85ca                	mv	a1,s2
    80004ee8:	855a                	mv	a0,s6
    80004eea:	ffffc097          	auipc	ra,0xffffc
    80004eee:	526080e7          	jalr	1318(ra) # 80001410 <uvmalloc>
    80004ef2:	dea43c23          	sd	a0,-520(s0)
    80004ef6:	d939                	beqz	a0,80004e4c <exec+0x2fe>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ef8:	e2843c03          	ld	s8,-472(s0)
    80004efc:	e2042c83          	lw	s9,-480(s0)
    80004f00:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f04:	f60b83e3          	beqz	s7,80004e6a <exec+0x31c>
    80004f08:	89de                	mv	s3,s7
    80004f0a:	4481                	li	s1,0
    80004f0c:	bb95                	j	80004c80 <exec+0x132>

0000000080004f0e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f0e:	7179                	addi	sp,sp,-48
    80004f10:	f406                	sd	ra,40(sp)
    80004f12:	f022                	sd	s0,32(sp)
    80004f14:	ec26                	sd	s1,24(sp)
    80004f16:	e84a                	sd	s2,16(sp)
    80004f18:	1800                	addi	s0,sp,48
    80004f1a:	892e                	mv	s2,a1
    80004f1c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f1e:	fdc40593          	addi	a1,s0,-36
    80004f22:	ffffe097          	auipc	ra,0xffffe
    80004f26:	b9e080e7          	jalr	-1122(ra) # 80002ac0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f2a:	fdc42703          	lw	a4,-36(s0)
    80004f2e:	47bd                	li	a5,15
    80004f30:	02e7eb63          	bltu	a5,a4,80004f66 <argfd+0x58>
    80004f34:	ffffd097          	auipc	ra,0xffffd
    80004f38:	a78080e7          	jalr	-1416(ra) # 800019ac <myproc>
    80004f3c:	fdc42703          	lw	a4,-36(s0)
    80004f40:	01a70793          	addi	a5,a4,26
    80004f44:	078e                	slli	a5,a5,0x3
    80004f46:	953e                	add	a0,a0,a5
    80004f48:	611c                	ld	a5,0(a0)
    80004f4a:	c385                	beqz	a5,80004f6a <argfd+0x5c>
    return -1;
  if(pfd)
    80004f4c:	00090463          	beqz	s2,80004f54 <argfd+0x46>
    *pfd = fd;
    80004f50:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f54:	4501                	li	a0,0
  if(pf)
    80004f56:	c091                	beqz	s1,80004f5a <argfd+0x4c>
    *pf = f;
    80004f58:	e09c                	sd	a5,0(s1)
}
    80004f5a:	70a2                	ld	ra,40(sp)
    80004f5c:	7402                	ld	s0,32(sp)
    80004f5e:	64e2                	ld	s1,24(sp)
    80004f60:	6942                	ld	s2,16(sp)
    80004f62:	6145                	addi	sp,sp,48
    80004f64:	8082                	ret
    return -1;
    80004f66:	557d                	li	a0,-1
    80004f68:	bfcd                	j	80004f5a <argfd+0x4c>
    80004f6a:	557d                	li	a0,-1
    80004f6c:	b7fd                	j	80004f5a <argfd+0x4c>

0000000080004f6e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f6e:	1101                	addi	sp,sp,-32
    80004f70:	ec06                	sd	ra,24(sp)
    80004f72:	e822                	sd	s0,16(sp)
    80004f74:	e426                	sd	s1,8(sp)
    80004f76:	1000                	addi	s0,sp,32
    80004f78:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f7a:	ffffd097          	auipc	ra,0xffffd
    80004f7e:	a32080e7          	jalr	-1486(ra) # 800019ac <myproc>
    80004f82:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f84:	0d050793          	addi	a5,a0,208
    80004f88:	4501                	li	a0,0
    80004f8a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f8c:	6398                	ld	a4,0(a5)
    80004f8e:	cb19                	beqz	a4,80004fa4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f90:	2505                	addiw	a0,a0,1
    80004f92:	07a1                	addi	a5,a5,8
    80004f94:	fed51ce3          	bne	a0,a3,80004f8c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f98:	557d                	li	a0,-1
}
    80004f9a:	60e2                	ld	ra,24(sp)
    80004f9c:	6442                	ld	s0,16(sp)
    80004f9e:	64a2                	ld	s1,8(sp)
    80004fa0:	6105                	addi	sp,sp,32
    80004fa2:	8082                	ret
      p->ofile[fd] = f;
    80004fa4:	01a50793          	addi	a5,a0,26
    80004fa8:	078e                	slli	a5,a5,0x3
    80004faa:	963e                	add	a2,a2,a5
    80004fac:	e204                	sd	s1,0(a2)
      return fd;
    80004fae:	b7f5                	j	80004f9a <fdalloc+0x2c>

0000000080004fb0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fb0:	715d                	addi	sp,sp,-80
    80004fb2:	e486                	sd	ra,72(sp)
    80004fb4:	e0a2                	sd	s0,64(sp)
    80004fb6:	fc26                	sd	s1,56(sp)
    80004fb8:	f84a                	sd	s2,48(sp)
    80004fba:	f44e                	sd	s3,40(sp)
    80004fbc:	f052                	sd	s4,32(sp)
    80004fbe:	ec56                	sd	s5,24(sp)
    80004fc0:	e85a                	sd	s6,16(sp)
    80004fc2:	0880                	addi	s0,sp,80
    80004fc4:	8b2e                	mv	s6,a1
    80004fc6:	89b2                	mv	s3,a2
    80004fc8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004fca:	fb040593          	addi	a1,s0,-80
    80004fce:	fffff097          	auipc	ra,0xfffff
    80004fd2:	e3c080e7          	jalr	-452(ra) # 80003e0a <nameiparent>
    80004fd6:	84aa                	mv	s1,a0
    80004fd8:	14050f63          	beqz	a0,80005136 <create+0x186>
    return 0;

  ilock(dp);
    80004fdc:	ffffe097          	auipc	ra,0xffffe
    80004fe0:	66a080e7          	jalr	1642(ra) # 80003646 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004fe4:	4601                	li	a2,0
    80004fe6:	fb040593          	addi	a1,s0,-80
    80004fea:	8526                	mv	a0,s1
    80004fec:	fffff097          	auipc	ra,0xfffff
    80004ff0:	b3e080e7          	jalr	-1218(ra) # 80003b2a <dirlookup>
    80004ff4:	8aaa                	mv	s5,a0
    80004ff6:	c931                	beqz	a0,8000504a <create+0x9a>
    iunlockput(dp);
    80004ff8:	8526                	mv	a0,s1
    80004ffa:	fffff097          	auipc	ra,0xfffff
    80004ffe:	8ae080e7          	jalr	-1874(ra) # 800038a8 <iunlockput>
    ilock(ip);
    80005002:	8556                	mv	a0,s5
    80005004:	ffffe097          	auipc	ra,0xffffe
    80005008:	642080e7          	jalr	1602(ra) # 80003646 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000500c:	000b059b          	sext.w	a1,s6
    80005010:	4789                	li	a5,2
    80005012:	02f59563          	bne	a1,a5,8000503c <create+0x8c>
    80005016:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd2d4>
    8000501a:	37f9                	addiw	a5,a5,-2
    8000501c:	17c2                	slli	a5,a5,0x30
    8000501e:	93c1                	srli	a5,a5,0x30
    80005020:	4705                	li	a4,1
    80005022:	00f76d63          	bltu	a4,a5,8000503c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005026:	8556                	mv	a0,s5
    80005028:	60a6                	ld	ra,72(sp)
    8000502a:	6406                	ld	s0,64(sp)
    8000502c:	74e2                	ld	s1,56(sp)
    8000502e:	7942                	ld	s2,48(sp)
    80005030:	79a2                	ld	s3,40(sp)
    80005032:	7a02                	ld	s4,32(sp)
    80005034:	6ae2                	ld	s5,24(sp)
    80005036:	6b42                	ld	s6,16(sp)
    80005038:	6161                	addi	sp,sp,80
    8000503a:	8082                	ret
    iunlockput(ip);
    8000503c:	8556                	mv	a0,s5
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	86a080e7          	jalr	-1942(ra) # 800038a8 <iunlockput>
    return 0;
    80005046:	4a81                	li	s5,0
    80005048:	bff9                	j	80005026 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000504a:	85da                	mv	a1,s6
    8000504c:	4088                	lw	a0,0(s1)
    8000504e:	ffffe097          	auipc	ra,0xffffe
    80005052:	45c080e7          	jalr	1116(ra) # 800034aa <ialloc>
    80005056:	8a2a                	mv	s4,a0
    80005058:	c539                	beqz	a0,800050a6 <create+0xf6>
  ilock(ip);
    8000505a:	ffffe097          	auipc	ra,0xffffe
    8000505e:	5ec080e7          	jalr	1516(ra) # 80003646 <ilock>
  ip->major = major;
    80005062:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005066:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000506a:	4905                	li	s2,1
    8000506c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005070:	8552                	mv	a0,s4
    80005072:	ffffe097          	auipc	ra,0xffffe
    80005076:	50a080e7          	jalr	1290(ra) # 8000357c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000507a:	000b059b          	sext.w	a1,s6
    8000507e:	03258b63          	beq	a1,s2,800050b4 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005082:	004a2603          	lw	a2,4(s4)
    80005086:	fb040593          	addi	a1,s0,-80
    8000508a:	8526                	mv	a0,s1
    8000508c:	fffff097          	auipc	ra,0xfffff
    80005090:	cae080e7          	jalr	-850(ra) # 80003d3a <dirlink>
    80005094:	06054f63          	bltz	a0,80005112 <create+0x162>
  iunlockput(dp);
    80005098:	8526                	mv	a0,s1
    8000509a:	fffff097          	auipc	ra,0xfffff
    8000509e:	80e080e7          	jalr	-2034(ra) # 800038a8 <iunlockput>
  return ip;
    800050a2:	8ad2                	mv	s5,s4
    800050a4:	b749                	j	80005026 <create+0x76>
    iunlockput(dp);
    800050a6:	8526                	mv	a0,s1
    800050a8:	fffff097          	auipc	ra,0xfffff
    800050ac:	800080e7          	jalr	-2048(ra) # 800038a8 <iunlockput>
    return 0;
    800050b0:	8ad2                	mv	s5,s4
    800050b2:	bf95                	j	80005026 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050b4:	004a2603          	lw	a2,4(s4)
    800050b8:	00003597          	auipc	a1,0x3
    800050bc:	64058593          	addi	a1,a1,1600 # 800086f8 <syscalls+0x2a8>
    800050c0:	8552                	mv	a0,s4
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	c78080e7          	jalr	-904(ra) # 80003d3a <dirlink>
    800050ca:	04054463          	bltz	a0,80005112 <create+0x162>
    800050ce:	40d0                	lw	a2,4(s1)
    800050d0:	00003597          	auipc	a1,0x3
    800050d4:	63058593          	addi	a1,a1,1584 # 80008700 <syscalls+0x2b0>
    800050d8:	8552                	mv	a0,s4
    800050da:	fffff097          	auipc	ra,0xfffff
    800050de:	c60080e7          	jalr	-928(ra) # 80003d3a <dirlink>
    800050e2:	02054863          	bltz	a0,80005112 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800050e6:	004a2603          	lw	a2,4(s4)
    800050ea:	fb040593          	addi	a1,s0,-80
    800050ee:	8526                	mv	a0,s1
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	c4a080e7          	jalr	-950(ra) # 80003d3a <dirlink>
    800050f8:	00054d63          	bltz	a0,80005112 <create+0x162>
    dp->nlink++;  // for ".."
    800050fc:	04a4d783          	lhu	a5,74(s1)
    80005100:	2785                	addiw	a5,a5,1
    80005102:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005106:	8526                	mv	a0,s1
    80005108:	ffffe097          	auipc	ra,0xffffe
    8000510c:	474080e7          	jalr	1140(ra) # 8000357c <iupdate>
    80005110:	b761                	j	80005098 <create+0xe8>
  ip->nlink = 0;
    80005112:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005116:	8552                	mv	a0,s4
    80005118:	ffffe097          	auipc	ra,0xffffe
    8000511c:	464080e7          	jalr	1124(ra) # 8000357c <iupdate>
  iunlockput(ip);
    80005120:	8552                	mv	a0,s4
    80005122:	ffffe097          	auipc	ra,0xffffe
    80005126:	786080e7          	jalr	1926(ra) # 800038a8 <iunlockput>
  iunlockput(dp);
    8000512a:	8526                	mv	a0,s1
    8000512c:	ffffe097          	auipc	ra,0xffffe
    80005130:	77c080e7          	jalr	1916(ra) # 800038a8 <iunlockput>
  return 0;
    80005134:	bdcd                	j	80005026 <create+0x76>
    return 0;
    80005136:	8aaa                	mv	s5,a0
    80005138:	b5fd                	j	80005026 <create+0x76>

000000008000513a <sys_dup>:
{
    8000513a:	7179                	addi	sp,sp,-48
    8000513c:	f406                	sd	ra,40(sp)
    8000513e:	f022                	sd	s0,32(sp)
    80005140:	ec26                	sd	s1,24(sp)
    80005142:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005144:	fd840613          	addi	a2,s0,-40
    80005148:	4581                	li	a1,0
    8000514a:	4501                	li	a0,0
    8000514c:	00000097          	auipc	ra,0x0
    80005150:	dc2080e7          	jalr	-574(ra) # 80004f0e <argfd>
    return -1;
    80005154:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005156:	02054363          	bltz	a0,8000517c <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000515a:	fd843503          	ld	a0,-40(s0)
    8000515e:	00000097          	auipc	ra,0x0
    80005162:	e10080e7          	jalr	-496(ra) # 80004f6e <fdalloc>
    80005166:	84aa                	mv	s1,a0
    return -1;
    80005168:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000516a:	00054963          	bltz	a0,8000517c <sys_dup+0x42>
  filedup(f);
    8000516e:	fd843503          	ld	a0,-40(s0)
    80005172:	fffff097          	auipc	ra,0xfffff
    80005176:	310080e7          	jalr	784(ra) # 80004482 <filedup>
  return fd;
    8000517a:	87a6                	mv	a5,s1
}
    8000517c:	853e                	mv	a0,a5
    8000517e:	70a2                	ld	ra,40(sp)
    80005180:	7402                	ld	s0,32(sp)
    80005182:	64e2                	ld	s1,24(sp)
    80005184:	6145                	addi	sp,sp,48
    80005186:	8082                	ret

0000000080005188 <sys_read>:
{
    80005188:	7179                	addi	sp,sp,-48
    8000518a:	f406                	sd	ra,40(sp)
    8000518c:	f022                	sd	s0,32(sp)
    8000518e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005190:	fd840593          	addi	a1,s0,-40
    80005194:	4505                	li	a0,1
    80005196:	ffffe097          	auipc	ra,0xffffe
    8000519a:	94a080e7          	jalr	-1718(ra) # 80002ae0 <argaddr>
  argint(2, &n);
    8000519e:	fe440593          	addi	a1,s0,-28
    800051a2:	4509                	li	a0,2
    800051a4:	ffffe097          	auipc	ra,0xffffe
    800051a8:	91c080e7          	jalr	-1764(ra) # 80002ac0 <argint>
  if(argfd(0, 0, &f) < 0)
    800051ac:	fe840613          	addi	a2,s0,-24
    800051b0:	4581                	li	a1,0
    800051b2:	4501                	li	a0,0
    800051b4:	00000097          	auipc	ra,0x0
    800051b8:	d5a080e7          	jalr	-678(ra) # 80004f0e <argfd>
    800051bc:	87aa                	mv	a5,a0
    return -1;
    800051be:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051c0:	0007cc63          	bltz	a5,800051d8 <sys_read+0x50>
  return fileread(f, p, n);
    800051c4:	fe442603          	lw	a2,-28(s0)
    800051c8:	fd843583          	ld	a1,-40(s0)
    800051cc:	fe843503          	ld	a0,-24(s0)
    800051d0:	fffff097          	auipc	ra,0xfffff
    800051d4:	43e080e7          	jalr	1086(ra) # 8000460e <fileread>
}
    800051d8:	70a2                	ld	ra,40(sp)
    800051da:	7402                	ld	s0,32(sp)
    800051dc:	6145                	addi	sp,sp,48
    800051de:	8082                	ret

00000000800051e0 <sys_write>:
{
    800051e0:	7179                	addi	sp,sp,-48
    800051e2:	f406                	sd	ra,40(sp)
    800051e4:	f022                	sd	s0,32(sp)
    800051e6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051e8:	fd840593          	addi	a1,s0,-40
    800051ec:	4505                	li	a0,1
    800051ee:	ffffe097          	auipc	ra,0xffffe
    800051f2:	8f2080e7          	jalr	-1806(ra) # 80002ae0 <argaddr>
  argint(2, &n);
    800051f6:	fe440593          	addi	a1,s0,-28
    800051fa:	4509                	li	a0,2
    800051fc:	ffffe097          	auipc	ra,0xffffe
    80005200:	8c4080e7          	jalr	-1852(ra) # 80002ac0 <argint>
  if(argfd(0, 0, &f) < 0)
    80005204:	fe840613          	addi	a2,s0,-24
    80005208:	4581                	li	a1,0
    8000520a:	4501                	li	a0,0
    8000520c:	00000097          	auipc	ra,0x0
    80005210:	d02080e7          	jalr	-766(ra) # 80004f0e <argfd>
    80005214:	87aa                	mv	a5,a0
    return -1;
    80005216:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005218:	0007cc63          	bltz	a5,80005230 <sys_write+0x50>
  return filewrite(f, p, n);
    8000521c:	fe442603          	lw	a2,-28(s0)
    80005220:	fd843583          	ld	a1,-40(s0)
    80005224:	fe843503          	ld	a0,-24(s0)
    80005228:	fffff097          	auipc	ra,0xfffff
    8000522c:	4a8080e7          	jalr	1192(ra) # 800046d0 <filewrite>
}
    80005230:	70a2                	ld	ra,40(sp)
    80005232:	7402                	ld	s0,32(sp)
    80005234:	6145                	addi	sp,sp,48
    80005236:	8082                	ret

0000000080005238 <sys_close>:
{
    80005238:	1101                	addi	sp,sp,-32
    8000523a:	ec06                	sd	ra,24(sp)
    8000523c:	e822                	sd	s0,16(sp)
    8000523e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005240:	fe040613          	addi	a2,s0,-32
    80005244:	fec40593          	addi	a1,s0,-20
    80005248:	4501                	li	a0,0
    8000524a:	00000097          	auipc	ra,0x0
    8000524e:	cc4080e7          	jalr	-828(ra) # 80004f0e <argfd>
    return -1;
    80005252:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005254:	02054463          	bltz	a0,8000527c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005258:	ffffc097          	auipc	ra,0xffffc
    8000525c:	754080e7          	jalr	1876(ra) # 800019ac <myproc>
    80005260:	fec42783          	lw	a5,-20(s0)
    80005264:	07e9                	addi	a5,a5,26
    80005266:	078e                	slli	a5,a5,0x3
    80005268:	97aa                	add	a5,a5,a0
    8000526a:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    8000526e:	fe043503          	ld	a0,-32(s0)
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	262080e7          	jalr	610(ra) # 800044d4 <fileclose>
  return 0;
    8000527a:	4781                	li	a5,0
}
    8000527c:	853e                	mv	a0,a5
    8000527e:	60e2                	ld	ra,24(sp)
    80005280:	6442                	ld	s0,16(sp)
    80005282:	6105                	addi	sp,sp,32
    80005284:	8082                	ret

0000000080005286 <sys_fstat>:
{
    80005286:	1101                	addi	sp,sp,-32
    80005288:	ec06                	sd	ra,24(sp)
    8000528a:	e822                	sd	s0,16(sp)
    8000528c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000528e:	fe040593          	addi	a1,s0,-32
    80005292:	4505                	li	a0,1
    80005294:	ffffe097          	auipc	ra,0xffffe
    80005298:	84c080e7          	jalr	-1972(ra) # 80002ae0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000529c:	fe840613          	addi	a2,s0,-24
    800052a0:	4581                	li	a1,0
    800052a2:	4501                	li	a0,0
    800052a4:	00000097          	auipc	ra,0x0
    800052a8:	c6a080e7          	jalr	-918(ra) # 80004f0e <argfd>
    800052ac:	87aa                	mv	a5,a0
    return -1;
    800052ae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052b0:	0007ca63          	bltz	a5,800052c4 <sys_fstat+0x3e>
  return filestat(f, st);
    800052b4:	fe043583          	ld	a1,-32(s0)
    800052b8:	fe843503          	ld	a0,-24(s0)
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	2e0080e7          	jalr	736(ra) # 8000459c <filestat>
}
    800052c4:	60e2                	ld	ra,24(sp)
    800052c6:	6442                	ld	s0,16(sp)
    800052c8:	6105                	addi	sp,sp,32
    800052ca:	8082                	ret

00000000800052cc <sys_link>:
{
    800052cc:	7169                	addi	sp,sp,-304
    800052ce:	f606                	sd	ra,296(sp)
    800052d0:	f222                	sd	s0,288(sp)
    800052d2:	ee26                	sd	s1,280(sp)
    800052d4:	ea4a                	sd	s2,272(sp)
    800052d6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052d8:	08000613          	li	a2,128
    800052dc:	ed040593          	addi	a1,s0,-304
    800052e0:	4501                	li	a0,0
    800052e2:	ffffe097          	auipc	ra,0xffffe
    800052e6:	81e080e7          	jalr	-2018(ra) # 80002b00 <argstr>
    return -1;
    800052ea:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800052ec:	10054e63          	bltz	a0,80005408 <sys_link+0x13c>
    800052f0:	08000613          	li	a2,128
    800052f4:	f5040593          	addi	a1,s0,-176
    800052f8:	4505                	li	a0,1
    800052fa:	ffffe097          	auipc	ra,0xffffe
    800052fe:	806080e7          	jalr	-2042(ra) # 80002b00 <argstr>
    return -1;
    80005302:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005304:	10054263          	bltz	a0,80005408 <sys_link+0x13c>
  begin_op();
    80005308:	fffff097          	auipc	ra,0xfffff
    8000530c:	d00080e7          	jalr	-768(ra) # 80004008 <begin_op>
  if((ip = namei(old)) == 0){
    80005310:	ed040513          	addi	a0,s0,-304
    80005314:	fffff097          	auipc	ra,0xfffff
    80005318:	ad8080e7          	jalr	-1320(ra) # 80003dec <namei>
    8000531c:	84aa                	mv	s1,a0
    8000531e:	c551                	beqz	a0,800053aa <sys_link+0xde>
  ilock(ip);
    80005320:	ffffe097          	auipc	ra,0xffffe
    80005324:	326080e7          	jalr	806(ra) # 80003646 <ilock>
  if(ip->type == T_DIR){
    80005328:	04449703          	lh	a4,68(s1)
    8000532c:	4785                	li	a5,1
    8000532e:	08f70463          	beq	a4,a5,800053b6 <sys_link+0xea>
  ip->nlink++;
    80005332:	04a4d783          	lhu	a5,74(s1)
    80005336:	2785                	addiw	a5,a5,1
    80005338:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000533c:	8526                	mv	a0,s1
    8000533e:	ffffe097          	auipc	ra,0xffffe
    80005342:	23e080e7          	jalr	574(ra) # 8000357c <iupdate>
  iunlock(ip);
    80005346:	8526                	mv	a0,s1
    80005348:	ffffe097          	auipc	ra,0xffffe
    8000534c:	3c0080e7          	jalr	960(ra) # 80003708 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005350:	fd040593          	addi	a1,s0,-48
    80005354:	f5040513          	addi	a0,s0,-176
    80005358:	fffff097          	auipc	ra,0xfffff
    8000535c:	ab2080e7          	jalr	-1358(ra) # 80003e0a <nameiparent>
    80005360:	892a                	mv	s2,a0
    80005362:	c935                	beqz	a0,800053d6 <sys_link+0x10a>
  ilock(dp);
    80005364:	ffffe097          	auipc	ra,0xffffe
    80005368:	2e2080e7          	jalr	738(ra) # 80003646 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000536c:	00092703          	lw	a4,0(s2)
    80005370:	409c                	lw	a5,0(s1)
    80005372:	04f71d63          	bne	a4,a5,800053cc <sys_link+0x100>
    80005376:	40d0                	lw	a2,4(s1)
    80005378:	fd040593          	addi	a1,s0,-48
    8000537c:	854a                	mv	a0,s2
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	9bc080e7          	jalr	-1604(ra) # 80003d3a <dirlink>
    80005386:	04054363          	bltz	a0,800053cc <sys_link+0x100>
  iunlockput(dp);
    8000538a:	854a                	mv	a0,s2
    8000538c:	ffffe097          	auipc	ra,0xffffe
    80005390:	51c080e7          	jalr	1308(ra) # 800038a8 <iunlockput>
  iput(ip);
    80005394:	8526                	mv	a0,s1
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	46a080e7          	jalr	1130(ra) # 80003800 <iput>
  end_op();
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	cea080e7          	jalr	-790(ra) # 80004088 <end_op>
  return 0;
    800053a6:	4781                	li	a5,0
    800053a8:	a085                	j	80005408 <sys_link+0x13c>
    end_op();
    800053aa:	fffff097          	auipc	ra,0xfffff
    800053ae:	cde080e7          	jalr	-802(ra) # 80004088 <end_op>
    return -1;
    800053b2:	57fd                	li	a5,-1
    800053b4:	a891                	j	80005408 <sys_link+0x13c>
    iunlockput(ip);
    800053b6:	8526                	mv	a0,s1
    800053b8:	ffffe097          	auipc	ra,0xffffe
    800053bc:	4f0080e7          	jalr	1264(ra) # 800038a8 <iunlockput>
    end_op();
    800053c0:	fffff097          	auipc	ra,0xfffff
    800053c4:	cc8080e7          	jalr	-824(ra) # 80004088 <end_op>
    return -1;
    800053c8:	57fd                	li	a5,-1
    800053ca:	a83d                	j	80005408 <sys_link+0x13c>
    iunlockput(dp);
    800053cc:	854a                	mv	a0,s2
    800053ce:	ffffe097          	auipc	ra,0xffffe
    800053d2:	4da080e7          	jalr	1242(ra) # 800038a8 <iunlockput>
  ilock(ip);
    800053d6:	8526                	mv	a0,s1
    800053d8:	ffffe097          	auipc	ra,0xffffe
    800053dc:	26e080e7          	jalr	622(ra) # 80003646 <ilock>
  ip->nlink--;
    800053e0:	04a4d783          	lhu	a5,74(s1)
    800053e4:	37fd                	addiw	a5,a5,-1
    800053e6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053ea:	8526                	mv	a0,s1
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	190080e7          	jalr	400(ra) # 8000357c <iupdate>
  iunlockput(ip);
    800053f4:	8526                	mv	a0,s1
    800053f6:	ffffe097          	auipc	ra,0xffffe
    800053fa:	4b2080e7          	jalr	1202(ra) # 800038a8 <iunlockput>
  end_op();
    800053fe:	fffff097          	auipc	ra,0xfffff
    80005402:	c8a080e7          	jalr	-886(ra) # 80004088 <end_op>
  return -1;
    80005406:	57fd                	li	a5,-1
}
    80005408:	853e                	mv	a0,a5
    8000540a:	70b2                	ld	ra,296(sp)
    8000540c:	7412                	ld	s0,288(sp)
    8000540e:	64f2                	ld	s1,280(sp)
    80005410:	6952                	ld	s2,272(sp)
    80005412:	6155                	addi	sp,sp,304
    80005414:	8082                	ret

0000000080005416 <sys_unlink>:
{
    80005416:	7151                	addi	sp,sp,-240
    80005418:	f586                	sd	ra,232(sp)
    8000541a:	f1a2                	sd	s0,224(sp)
    8000541c:	eda6                	sd	s1,216(sp)
    8000541e:	e9ca                	sd	s2,208(sp)
    80005420:	e5ce                	sd	s3,200(sp)
    80005422:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005424:	08000613          	li	a2,128
    80005428:	f3040593          	addi	a1,s0,-208
    8000542c:	4501                	li	a0,0
    8000542e:	ffffd097          	auipc	ra,0xffffd
    80005432:	6d2080e7          	jalr	1746(ra) # 80002b00 <argstr>
    80005436:	18054163          	bltz	a0,800055b8 <sys_unlink+0x1a2>
  begin_op();
    8000543a:	fffff097          	auipc	ra,0xfffff
    8000543e:	bce080e7          	jalr	-1074(ra) # 80004008 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005442:	fb040593          	addi	a1,s0,-80
    80005446:	f3040513          	addi	a0,s0,-208
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	9c0080e7          	jalr	-1600(ra) # 80003e0a <nameiparent>
    80005452:	84aa                	mv	s1,a0
    80005454:	c979                	beqz	a0,8000552a <sys_unlink+0x114>
  ilock(dp);
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	1f0080e7          	jalr	496(ra) # 80003646 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000545e:	00003597          	auipc	a1,0x3
    80005462:	29a58593          	addi	a1,a1,666 # 800086f8 <syscalls+0x2a8>
    80005466:	fb040513          	addi	a0,s0,-80
    8000546a:	ffffe097          	auipc	ra,0xffffe
    8000546e:	6a6080e7          	jalr	1702(ra) # 80003b10 <namecmp>
    80005472:	14050a63          	beqz	a0,800055c6 <sys_unlink+0x1b0>
    80005476:	00003597          	auipc	a1,0x3
    8000547a:	28a58593          	addi	a1,a1,650 # 80008700 <syscalls+0x2b0>
    8000547e:	fb040513          	addi	a0,s0,-80
    80005482:	ffffe097          	auipc	ra,0xffffe
    80005486:	68e080e7          	jalr	1678(ra) # 80003b10 <namecmp>
    8000548a:	12050e63          	beqz	a0,800055c6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000548e:	f2c40613          	addi	a2,s0,-212
    80005492:	fb040593          	addi	a1,s0,-80
    80005496:	8526                	mv	a0,s1
    80005498:	ffffe097          	auipc	ra,0xffffe
    8000549c:	692080e7          	jalr	1682(ra) # 80003b2a <dirlookup>
    800054a0:	892a                	mv	s2,a0
    800054a2:	12050263          	beqz	a0,800055c6 <sys_unlink+0x1b0>
  ilock(ip);
    800054a6:	ffffe097          	auipc	ra,0xffffe
    800054aa:	1a0080e7          	jalr	416(ra) # 80003646 <ilock>
  if(ip->nlink < 1)
    800054ae:	04a91783          	lh	a5,74(s2)
    800054b2:	08f05263          	blez	a5,80005536 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054b6:	04491703          	lh	a4,68(s2)
    800054ba:	4785                	li	a5,1
    800054bc:	08f70563          	beq	a4,a5,80005546 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800054c0:	4641                	li	a2,16
    800054c2:	4581                	li	a1,0
    800054c4:	fc040513          	addi	a0,s0,-64
    800054c8:	ffffc097          	auipc	ra,0xffffc
    800054cc:	80a080e7          	jalr	-2038(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054d0:	4741                	li	a4,16
    800054d2:	f2c42683          	lw	a3,-212(s0)
    800054d6:	fc040613          	addi	a2,s0,-64
    800054da:	4581                	li	a1,0
    800054dc:	8526                	mv	a0,s1
    800054de:	ffffe097          	auipc	ra,0xffffe
    800054e2:	514080e7          	jalr	1300(ra) # 800039f2 <writei>
    800054e6:	47c1                	li	a5,16
    800054e8:	0af51563          	bne	a0,a5,80005592 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800054ec:	04491703          	lh	a4,68(s2)
    800054f0:	4785                	li	a5,1
    800054f2:	0af70863          	beq	a4,a5,800055a2 <sys_unlink+0x18c>
  iunlockput(dp);
    800054f6:	8526                	mv	a0,s1
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	3b0080e7          	jalr	944(ra) # 800038a8 <iunlockput>
  ip->nlink--;
    80005500:	04a95783          	lhu	a5,74(s2)
    80005504:	37fd                	addiw	a5,a5,-1
    80005506:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000550a:	854a                	mv	a0,s2
    8000550c:	ffffe097          	auipc	ra,0xffffe
    80005510:	070080e7          	jalr	112(ra) # 8000357c <iupdate>
  iunlockput(ip);
    80005514:	854a                	mv	a0,s2
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	392080e7          	jalr	914(ra) # 800038a8 <iunlockput>
  end_op();
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	b6a080e7          	jalr	-1174(ra) # 80004088 <end_op>
  return 0;
    80005526:	4501                	li	a0,0
    80005528:	a84d                	j	800055da <sys_unlink+0x1c4>
    end_op();
    8000552a:	fffff097          	auipc	ra,0xfffff
    8000552e:	b5e080e7          	jalr	-1186(ra) # 80004088 <end_op>
    return -1;
    80005532:	557d                	li	a0,-1
    80005534:	a05d                	j	800055da <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005536:	00003517          	auipc	a0,0x3
    8000553a:	1d250513          	addi	a0,a0,466 # 80008708 <syscalls+0x2b8>
    8000553e:	ffffb097          	auipc	ra,0xffffb
    80005542:	000080e7          	jalr	ra # 8000053e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005546:	04c92703          	lw	a4,76(s2)
    8000554a:	02000793          	li	a5,32
    8000554e:	f6e7f9e3          	bgeu	a5,a4,800054c0 <sys_unlink+0xaa>
    80005552:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005556:	4741                	li	a4,16
    80005558:	86ce                	mv	a3,s3
    8000555a:	f1840613          	addi	a2,s0,-232
    8000555e:	4581                	li	a1,0
    80005560:	854a                	mv	a0,s2
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	398080e7          	jalr	920(ra) # 800038fa <readi>
    8000556a:	47c1                	li	a5,16
    8000556c:	00f51b63          	bne	a0,a5,80005582 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005570:	f1845783          	lhu	a5,-232(s0)
    80005574:	e7a1                	bnez	a5,800055bc <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005576:	29c1                	addiw	s3,s3,16
    80005578:	04c92783          	lw	a5,76(s2)
    8000557c:	fcf9ede3          	bltu	s3,a5,80005556 <sys_unlink+0x140>
    80005580:	b781                	j	800054c0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005582:	00003517          	auipc	a0,0x3
    80005586:	19e50513          	addi	a0,a0,414 # 80008720 <syscalls+0x2d0>
    8000558a:	ffffb097          	auipc	ra,0xffffb
    8000558e:	fb4080e7          	jalr	-76(ra) # 8000053e <panic>
    panic("unlink: writei");
    80005592:	00003517          	auipc	a0,0x3
    80005596:	1a650513          	addi	a0,a0,422 # 80008738 <syscalls+0x2e8>
    8000559a:	ffffb097          	auipc	ra,0xffffb
    8000559e:	fa4080e7          	jalr	-92(ra) # 8000053e <panic>
    dp->nlink--;
    800055a2:	04a4d783          	lhu	a5,74(s1)
    800055a6:	37fd                	addiw	a5,a5,-1
    800055a8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055ac:	8526                	mv	a0,s1
    800055ae:	ffffe097          	auipc	ra,0xffffe
    800055b2:	fce080e7          	jalr	-50(ra) # 8000357c <iupdate>
    800055b6:	b781                	j	800054f6 <sys_unlink+0xe0>
    return -1;
    800055b8:	557d                	li	a0,-1
    800055ba:	a005                	j	800055da <sys_unlink+0x1c4>
    iunlockput(ip);
    800055bc:	854a                	mv	a0,s2
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	2ea080e7          	jalr	746(ra) # 800038a8 <iunlockput>
  iunlockput(dp);
    800055c6:	8526                	mv	a0,s1
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	2e0080e7          	jalr	736(ra) # 800038a8 <iunlockput>
  end_op();
    800055d0:	fffff097          	auipc	ra,0xfffff
    800055d4:	ab8080e7          	jalr	-1352(ra) # 80004088 <end_op>
  return -1;
    800055d8:	557d                	li	a0,-1
}
    800055da:	70ae                	ld	ra,232(sp)
    800055dc:	740e                	ld	s0,224(sp)
    800055de:	64ee                	ld	s1,216(sp)
    800055e0:	694e                	ld	s2,208(sp)
    800055e2:	69ae                	ld	s3,200(sp)
    800055e4:	616d                	addi	sp,sp,240
    800055e6:	8082                	ret

00000000800055e8 <sys_open>:

uint64
sys_open(void)
{
    800055e8:	7131                	addi	sp,sp,-192
    800055ea:	fd06                	sd	ra,184(sp)
    800055ec:	f922                	sd	s0,176(sp)
    800055ee:	f526                	sd	s1,168(sp)
    800055f0:	f14a                	sd	s2,160(sp)
    800055f2:	ed4e                	sd	s3,152(sp)
    800055f4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800055f6:	f4c40593          	addi	a1,s0,-180
    800055fa:	4505                	li	a0,1
    800055fc:	ffffd097          	auipc	ra,0xffffd
    80005600:	4c4080e7          	jalr	1220(ra) # 80002ac0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005604:	08000613          	li	a2,128
    80005608:	f5040593          	addi	a1,s0,-176
    8000560c:	4501                	li	a0,0
    8000560e:	ffffd097          	auipc	ra,0xffffd
    80005612:	4f2080e7          	jalr	1266(ra) # 80002b00 <argstr>
    80005616:	87aa                	mv	a5,a0
    return -1;
    80005618:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000561a:	0a07c963          	bltz	a5,800056cc <sys_open+0xe4>

  begin_op();
    8000561e:	fffff097          	auipc	ra,0xfffff
    80005622:	9ea080e7          	jalr	-1558(ra) # 80004008 <begin_op>

  if(omode & O_CREATE){
    80005626:	f4c42783          	lw	a5,-180(s0)
    8000562a:	2007f793          	andi	a5,a5,512
    8000562e:	cfc5                	beqz	a5,800056e6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005630:	4681                	li	a3,0
    80005632:	4601                	li	a2,0
    80005634:	4589                	li	a1,2
    80005636:	f5040513          	addi	a0,s0,-176
    8000563a:	00000097          	auipc	ra,0x0
    8000563e:	976080e7          	jalr	-1674(ra) # 80004fb0 <create>
    80005642:	84aa                	mv	s1,a0
    if(ip == 0){
    80005644:	c959                	beqz	a0,800056da <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005646:	04449703          	lh	a4,68(s1)
    8000564a:	478d                	li	a5,3
    8000564c:	00f71763          	bne	a4,a5,8000565a <sys_open+0x72>
    80005650:	0464d703          	lhu	a4,70(s1)
    80005654:	47a5                	li	a5,9
    80005656:	0ce7ed63          	bltu	a5,a4,80005730 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000565a:	fffff097          	auipc	ra,0xfffff
    8000565e:	dbe080e7          	jalr	-578(ra) # 80004418 <filealloc>
    80005662:	89aa                	mv	s3,a0
    80005664:	10050363          	beqz	a0,8000576a <sys_open+0x182>
    80005668:	00000097          	auipc	ra,0x0
    8000566c:	906080e7          	jalr	-1786(ra) # 80004f6e <fdalloc>
    80005670:	892a                	mv	s2,a0
    80005672:	0e054763          	bltz	a0,80005760 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005676:	04449703          	lh	a4,68(s1)
    8000567a:	478d                	li	a5,3
    8000567c:	0cf70563          	beq	a4,a5,80005746 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005680:	4789                	li	a5,2
    80005682:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005686:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000568a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000568e:	f4c42783          	lw	a5,-180(s0)
    80005692:	0017c713          	xori	a4,a5,1
    80005696:	8b05                	andi	a4,a4,1
    80005698:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000569c:	0037f713          	andi	a4,a5,3
    800056a0:	00e03733          	snez	a4,a4
    800056a4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800056a8:	4007f793          	andi	a5,a5,1024
    800056ac:	c791                	beqz	a5,800056b8 <sys_open+0xd0>
    800056ae:	04449703          	lh	a4,68(s1)
    800056b2:	4789                	li	a5,2
    800056b4:	0af70063          	beq	a4,a5,80005754 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800056b8:	8526                	mv	a0,s1
    800056ba:	ffffe097          	auipc	ra,0xffffe
    800056be:	04e080e7          	jalr	78(ra) # 80003708 <iunlock>
  end_op();
    800056c2:	fffff097          	auipc	ra,0xfffff
    800056c6:	9c6080e7          	jalr	-1594(ra) # 80004088 <end_op>

  return fd;
    800056ca:	854a                	mv	a0,s2
}
    800056cc:	70ea                	ld	ra,184(sp)
    800056ce:	744a                	ld	s0,176(sp)
    800056d0:	74aa                	ld	s1,168(sp)
    800056d2:	790a                	ld	s2,160(sp)
    800056d4:	69ea                	ld	s3,152(sp)
    800056d6:	6129                	addi	sp,sp,192
    800056d8:	8082                	ret
      end_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	9ae080e7          	jalr	-1618(ra) # 80004088 <end_op>
      return -1;
    800056e2:	557d                	li	a0,-1
    800056e4:	b7e5                	j	800056cc <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800056e6:	f5040513          	addi	a0,s0,-176
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	702080e7          	jalr	1794(ra) # 80003dec <namei>
    800056f2:	84aa                	mv	s1,a0
    800056f4:	c905                	beqz	a0,80005724 <sys_open+0x13c>
    ilock(ip);
    800056f6:	ffffe097          	auipc	ra,0xffffe
    800056fa:	f50080e7          	jalr	-176(ra) # 80003646 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056fe:	04449703          	lh	a4,68(s1)
    80005702:	4785                	li	a5,1
    80005704:	f4f711e3          	bne	a4,a5,80005646 <sys_open+0x5e>
    80005708:	f4c42783          	lw	a5,-180(s0)
    8000570c:	d7b9                	beqz	a5,8000565a <sys_open+0x72>
      iunlockput(ip);
    8000570e:	8526                	mv	a0,s1
    80005710:	ffffe097          	auipc	ra,0xffffe
    80005714:	198080e7          	jalr	408(ra) # 800038a8 <iunlockput>
      end_op();
    80005718:	fffff097          	auipc	ra,0xfffff
    8000571c:	970080e7          	jalr	-1680(ra) # 80004088 <end_op>
      return -1;
    80005720:	557d                	li	a0,-1
    80005722:	b76d                	j	800056cc <sys_open+0xe4>
      end_op();
    80005724:	fffff097          	auipc	ra,0xfffff
    80005728:	964080e7          	jalr	-1692(ra) # 80004088 <end_op>
      return -1;
    8000572c:	557d                	li	a0,-1
    8000572e:	bf79                	j	800056cc <sys_open+0xe4>
    iunlockput(ip);
    80005730:	8526                	mv	a0,s1
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	176080e7          	jalr	374(ra) # 800038a8 <iunlockput>
    end_op();
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	94e080e7          	jalr	-1714(ra) # 80004088 <end_op>
    return -1;
    80005742:	557d                	li	a0,-1
    80005744:	b761                	j	800056cc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005746:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    8000574a:	04649783          	lh	a5,70(s1)
    8000574e:	02f99223          	sh	a5,36(s3)
    80005752:	bf25                	j	8000568a <sys_open+0xa2>
    itrunc(ip);
    80005754:	8526                	mv	a0,s1
    80005756:	ffffe097          	auipc	ra,0xffffe
    8000575a:	ffe080e7          	jalr	-2(ra) # 80003754 <itrunc>
    8000575e:	bfa9                	j	800056b8 <sys_open+0xd0>
      fileclose(f);
    80005760:	854e                	mv	a0,s3
    80005762:	fffff097          	auipc	ra,0xfffff
    80005766:	d72080e7          	jalr	-654(ra) # 800044d4 <fileclose>
    iunlockput(ip);
    8000576a:	8526                	mv	a0,s1
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	13c080e7          	jalr	316(ra) # 800038a8 <iunlockput>
    end_op();
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	914080e7          	jalr	-1772(ra) # 80004088 <end_op>
    return -1;
    8000577c:	557d                	li	a0,-1
    8000577e:	b7b9                	j	800056cc <sys_open+0xe4>

0000000080005780 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005780:	7175                	addi	sp,sp,-144
    80005782:	e506                	sd	ra,136(sp)
    80005784:	e122                	sd	s0,128(sp)
    80005786:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	880080e7          	jalr	-1920(ra) # 80004008 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005790:	08000613          	li	a2,128
    80005794:	f7040593          	addi	a1,s0,-144
    80005798:	4501                	li	a0,0
    8000579a:	ffffd097          	auipc	ra,0xffffd
    8000579e:	366080e7          	jalr	870(ra) # 80002b00 <argstr>
    800057a2:	02054963          	bltz	a0,800057d4 <sys_mkdir+0x54>
    800057a6:	4681                	li	a3,0
    800057a8:	4601                	li	a2,0
    800057aa:	4585                	li	a1,1
    800057ac:	f7040513          	addi	a0,s0,-144
    800057b0:	00000097          	auipc	ra,0x0
    800057b4:	800080e7          	jalr	-2048(ra) # 80004fb0 <create>
    800057b8:	cd11                	beqz	a0,800057d4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	0ee080e7          	jalr	238(ra) # 800038a8 <iunlockput>
  end_op();
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	8c6080e7          	jalr	-1850(ra) # 80004088 <end_op>
  return 0;
    800057ca:	4501                	li	a0,0
}
    800057cc:	60aa                	ld	ra,136(sp)
    800057ce:	640a                	ld	s0,128(sp)
    800057d0:	6149                	addi	sp,sp,144
    800057d2:	8082                	ret
    end_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	8b4080e7          	jalr	-1868(ra) # 80004088 <end_op>
    return -1;
    800057dc:	557d                	li	a0,-1
    800057de:	b7fd                	j	800057cc <sys_mkdir+0x4c>

00000000800057e0 <sys_mknod>:

uint64
sys_mknod(void)
{
    800057e0:	7135                	addi	sp,sp,-160
    800057e2:	ed06                	sd	ra,152(sp)
    800057e4:	e922                	sd	s0,144(sp)
    800057e6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	820080e7          	jalr	-2016(ra) # 80004008 <begin_op>
  argint(1, &major);
    800057f0:	f6c40593          	addi	a1,s0,-148
    800057f4:	4505                	li	a0,1
    800057f6:	ffffd097          	auipc	ra,0xffffd
    800057fa:	2ca080e7          	jalr	714(ra) # 80002ac0 <argint>
  argint(2, &minor);
    800057fe:	f6840593          	addi	a1,s0,-152
    80005802:	4509                	li	a0,2
    80005804:	ffffd097          	auipc	ra,0xffffd
    80005808:	2bc080e7          	jalr	700(ra) # 80002ac0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000580c:	08000613          	li	a2,128
    80005810:	f7040593          	addi	a1,s0,-144
    80005814:	4501                	li	a0,0
    80005816:	ffffd097          	auipc	ra,0xffffd
    8000581a:	2ea080e7          	jalr	746(ra) # 80002b00 <argstr>
    8000581e:	02054b63          	bltz	a0,80005854 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005822:	f6841683          	lh	a3,-152(s0)
    80005826:	f6c41603          	lh	a2,-148(s0)
    8000582a:	458d                	li	a1,3
    8000582c:	f7040513          	addi	a0,s0,-144
    80005830:	fffff097          	auipc	ra,0xfffff
    80005834:	780080e7          	jalr	1920(ra) # 80004fb0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005838:	cd11                	beqz	a0,80005854 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000583a:	ffffe097          	auipc	ra,0xffffe
    8000583e:	06e080e7          	jalr	110(ra) # 800038a8 <iunlockput>
  end_op();
    80005842:	fffff097          	auipc	ra,0xfffff
    80005846:	846080e7          	jalr	-1978(ra) # 80004088 <end_op>
  return 0;
    8000584a:	4501                	li	a0,0
}
    8000584c:	60ea                	ld	ra,152(sp)
    8000584e:	644a                	ld	s0,144(sp)
    80005850:	610d                	addi	sp,sp,160
    80005852:	8082                	ret
    end_op();
    80005854:	fffff097          	auipc	ra,0xfffff
    80005858:	834080e7          	jalr	-1996(ra) # 80004088 <end_op>
    return -1;
    8000585c:	557d                	li	a0,-1
    8000585e:	b7fd                	j	8000584c <sys_mknod+0x6c>

0000000080005860 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005860:	7135                	addi	sp,sp,-160
    80005862:	ed06                	sd	ra,152(sp)
    80005864:	e922                	sd	s0,144(sp)
    80005866:	e526                	sd	s1,136(sp)
    80005868:	e14a                	sd	s2,128(sp)
    8000586a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000586c:	ffffc097          	auipc	ra,0xffffc
    80005870:	140080e7          	jalr	320(ra) # 800019ac <myproc>
    80005874:	892a                	mv	s2,a0
  
  begin_op();
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	792080e7          	jalr	1938(ra) # 80004008 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000587e:	08000613          	li	a2,128
    80005882:	f6040593          	addi	a1,s0,-160
    80005886:	4501                	li	a0,0
    80005888:	ffffd097          	auipc	ra,0xffffd
    8000588c:	278080e7          	jalr	632(ra) # 80002b00 <argstr>
    80005890:	04054b63          	bltz	a0,800058e6 <sys_chdir+0x86>
    80005894:	f6040513          	addi	a0,s0,-160
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	554080e7          	jalr	1364(ra) # 80003dec <namei>
    800058a0:	84aa                	mv	s1,a0
    800058a2:	c131                	beqz	a0,800058e6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	da2080e7          	jalr	-606(ra) # 80003646 <ilock>
  if(ip->type != T_DIR){
    800058ac:	04449703          	lh	a4,68(s1)
    800058b0:	4785                	li	a5,1
    800058b2:	04f71063          	bne	a4,a5,800058f2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800058b6:	8526                	mv	a0,s1
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	e50080e7          	jalr	-432(ra) # 80003708 <iunlock>
  iput(p->cwd);
    800058c0:	15093503          	ld	a0,336(s2)
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	f3c080e7          	jalr	-196(ra) # 80003800 <iput>
  end_op();
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	7bc080e7          	jalr	1980(ra) # 80004088 <end_op>
  p->cwd = ip;
    800058d4:	14993823          	sd	s1,336(s2)
  return 0;
    800058d8:	4501                	li	a0,0
}
    800058da:	60ea                	ld	ra,152(sp)
    800058dc:	644a                	ld	s0,144(sp)
    800058de:	64aa                	ld	s1,136(sp)
    800058e0:	690a                	ld	s2,128(sp)
    800058e2:	610d                	addi	sp,sp,160
    800058e4:	8082                	ret
    end_op();
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	7a2080e7          	jalr	1954(ra) # 80004088 <end_op>
    return -1;
    800058ee:	557d                	li	a0,-1
    800058f0:	b7ed                	j	800058da <sys_chdir+0x7a>
    iunlockput(ip);
    800058f2:	8526                	mv	a0,s1
    800058f4:	ffffe097          	auipc	ra,0xffffe
    800058f8:	fb4080e7          	jalr	-76(ra) # 800038a8 <iunlockput>
    end_op();
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	78c080e7          	jalr	1932(ra) # 80004088 <end_op>
    return -1;
    80005904:	557d                	li	a0,-1
    80005906:	bfd1                	j	800058da <sys_chdir+0x7a>

0000000080005908 <sys_exec>:

uint64
sys_exec(void)
{
    80005908:	7145                	addi	sp,sp,-464
    8000590a:	e786                	sd	ra,456(sp)
    8000590c:	e3a2                	sd	s0,448(sp)
    8000590e:	ff26                	sd	s1,440(sp)
    80005910:	fb4a                	sd	s2,432(sp)
    80005912:	f74e                	sd	s3,424(sp)
    80005914:	f352                	sd	s4,416(sp)
    80005916:	ef56                	sd	s5,408(sp)
    80005918:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000591a:	e3840593          	addi	a1,s0,-456
    8000591e:	4505                	li	a0,1
    80005920:	ffffd097          	auipc	ra,0xffffd
    80005924:	1c0080e7          	jalr	448(ra) # 80002ae0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005928:	08000613          	li	a2,128
    8000592c:	f4040593          	addi	a1,s0,-192
    80005930:	4501                	li	a0,0
    80005932:	ffffd097          	auipc	ra,0xffffd
    80005936:	1ce080e7          	jalr	462(ra) # 80002b00 <argstr>
    8000593a:	87aa                	mv	a5,a0
    return -1;
    8000593c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000593e:	0c07c263          	bltz	a5,80005a02 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005942:	10000613          	li	a2,256
    80005946:	4581                	li	a1,0
    80005948:	e4040513          	addi	a0,s0,-448
    8000594c:	ffffb097          	auipc	ra,0xffffb
    80005950:	386080e7          	jalr	902(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005954:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005958:	89a6                	mv	s3,s1
    8000595a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000595c:	02000a13          	li	s4,32
    80005960:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005964:	00391793          	slli	a5,s2,0x3
    80005968:	e3040593          	addi	a1,s0,-464
    8000596c:	e3843503          	ld	a0,-456(s0)
    80005970:	953e                	add	a0,a0,a5
    80005972:	ffffd097          	auipc	ra,0xffffd
    80005976:	0b0080e7          	jalr	176(ra) # 80002a22 <fetchaddr>
    8000597a:	02054a63          	bltz	a0,800059ae <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    8000597e:	e3043783          	ld	a5,-464(s0)
    80005982:	c3b9                	beqz	a5,800059c8 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005984:	ffffb097          	auipc	ra,0xffffb
    80005988:	162080e7          	jalr	354(ra) # 80000ae6 <kalloc>
    8000598c:	85aa                	mv	a1,a0
    8000598e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005992:	cd11                	beqz	a0,800059ae <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005994:	6605                	lui	a2,0x1
    80005996:	e3043503          	ld	a0,-464(s0)
    8000599a:	ffffd097          	auipc	ra,0xffffd
    8000599e:	0da080e7          	jalr	218(ra) # 80002a74 <fetchstr>
    800059a2:	00054663          	bltz	a0,800059ae <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800059a6:	0905                	addi	s2,s2,1
    800059a8:	09a1                	addi	s3,s3,8
    800059aa:	fb491be3          	bne	s2,s4,80005960 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059ae:	10048913          	addi	s2,s1,256
    800059b2:	6088                	ld	a0,0(s1)
    800059b4:	c531                	beqz	a0,80005a00 <sys_exec+0xf8>
    kfree(argv[i]);
    800059b6:	ffffb097          	auipc	ra,0xffffb
    800059ba:	034080e7          	jalr	52(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059be:	04a1                	addi	s1,s1,8
    800059c0:	ff2499e3          	bne	s1,s2,800059b2 <sys_exec+0xaa>
  return -1;
    800059c4:	557d                	li	a0,-1
    800059c6:	a835                	j	80005a02 <sys_exec+0xfa>
      argv[i] = 0;
    800059c8:	0a8e                	slli	s5,s5,0x3
    800059ca:	fc040793          	addi	a5,s0,-64
    800059ce:	9abe                	add	s5,s5,a5
    800059d0:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800059d4:	e4040593          	addi	a1,s0,-448
    800059d8:	f4040513          	addi	a0,s0,-192
    800059dc:	fffff097          	auipc	ra,0xfffff
    800059e0:	172080e7          	jalr	370(ra) # 80004b4e <exec>
    800059e4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059e6:	10048993          	addi	s3,s1,256
    800059ea:	6088                	ld	a0,0(s1)
    800059ec:	c901                	beqz	a0,800059fc <sys_exec+0xf4>
    kfree(argv[i]);
    800059ee:	ffffb097          	auipc	ra,0xffffb
    800059f2:	ffc080e7          	jalr	-4(ra) # 800009ea <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800059f6:	04a1                	addi	s1,s1,8
    800059f8:	ff3499e3          	bne	s1,s3,800059ea <sys_exec+0xe2>
  return ret;
    800059fc:	854a                	mv	a0,s2
    800059fe:	a011                	j	80005a02 <sys_exec+0xfa>
  return -1;
    80005a00:	557d                	li	a0,-1
}
    80005a02:	60be                	ld	ra,456(sp)
    80005a04:	641e                	ld	s0,448(sp)
    80005a06:	74fa                	ld	s1,440(sp)
    80005a08:	795a                	ld	s2,432(sp)
    80005a0a:	79ba                	ld	s3,424(sp)
    80005a0c:	7a1a                	ld	s4,416(sp)
    80005a0e:	6afa                	ld	s5,408(sp)
    80005a10:	6179                	addi	sp,sp,464
    80005a12:	8082                	ret

0000000080005a14 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005a14:	7139                	addi	sp,sp,-64
    80005a16:	fc06                	sd	ra,56(sp)
    80005a18:	f822                	sd	s0,48(sp)
    80005a1a:	f426                	sd	s1,40(sp)
    80005a1c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005a1e:	ffffc097          	auipc	ra,0xffffc
    80005a22:	f8e080e7          	jalr	-114(ra) # 800019ac <myproc>
    80005a26:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005a28:	fd840593          	addi	a1,s0,-40
    80005a2c:	4501                	li	a0,0
    80005a2e:	ffffd097          	auipc	ra,0xffffd
    80005a32:	0b2080e7          	jalr	178(ra) # 80002ae0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005a36:	fc840593          	addi	a1,s0,-56
    80005a3a:	fd040513          	addi	a0,s0,-48
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	dc6080e7          	jalr	-570(ra) # 80004804 <pipealloc>
    return -1;
    80005a46:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005a48:	0c054463          	bltz	a0,80005b10 <sys_pipe+0xfc>
  fd0 = -1;
    80005a4c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005a50:	fd043503          	ld	a0,-48(s0)
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	51a080e7          	jalr	1306(ra) # 80004f6e <fdalloc>
    80005a5c:	fca42223          	sw	a0,-60(s0)
    80005a60:	08054b63          	bltz	a0,80005af6 <sys_pipe+0xe2>
    80005a64:	fc843503          	ld	a0,-56(s0)
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	506080e7          	jalr	1286(ra) # 80004f6e <fdalloc>
    80005a70:	fca42023          	sw	a0,-64(s0)
    80005a74:	06054863          	bltz	a0,80005ae4 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a78:	4691                	li	a3,4
    80005a7a:	fc440613          	addi	a2,s0,-60
    80005a7e:	fd843583          	ld	a1,-40(s0)
    80005a82:	68a8                	ld	a0,80(s1)
    80005a84:	ffffc097          	auipc	ra,0xffffc
    80005a88:	be4080e7          	jalr	-1052(ra) # 80001668 <copyout>
    80005a8c:	02054063          	bltz	a0,80005aac <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a90:	4691                	li	a3,4
    80005a92:	fc040613          	addi	a2,s0,-64
    80005a96:	fd843583          	ld	a1,-40(s0)
    80005a9a:	0591                	addi	a1,a1,4
    80005a9c:	68a8                	ld	a0,80(s1)
    80005a9e:	ffffc097          	auipc	ra,0xffffc
    80005aa2:	bca080e7          	jalr	-1078(ra) # 80001668 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005aa6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005aa8:	06055463          	bgez	a0,80005b10 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005aac:	fc442783          	lw	a5,-60(s0)
    80005ab0:	07e9                	addi	a5,a5,26
    80005ab2:	078e                	slli	a5,a5,0x3
    80005ab4:	97a6                	add	a5,a5,s1
    80005ab6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005aba:	fc042503          	lw	a0,-64(s0)
    80005abe:	0569                	addi	a0,a0,26
    80005ac0:	050e                	slli	a0,a0,0x3
    80005ac2:	94aa                	add	s1,s1,a0
    80005ac4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ac8:	fd043503          	ld	a0,-48(s0)
    80005acc:	fffff097          	auipc	ra,0xfffff
    80005ad0:	a08080e7          	jalr	-1528(ra) # 800044d4 <fileclose>
    fileclose(wf);
    80005ad4:	fc843503          	ld	a0,-56(s0)
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	9fc080e7          	jalr	-1540(ra) # 800044d4 <fileclose>
    return -1;
    80005ae0:	57fd                	li	a5,-1
    80005ae2:	a03d                	j	80005b10 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ae4:	fc442783          	lw	a5,-60(s0)
    80005ae8:	0007c763          	bltz	a5,80005af6 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005aec:	07e9                	addi	a5,a5,26
    80005aee:	078e                	slli	a5,a5,0x3
    80005af0:	94be                	add	s1,s1,a5
    80005af2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005af6:	fd043503          	ld	a0,-48(s0)
    80005afa:	fffff097          	auipc	ra,0xfffff
    80005afe:	9da080e7          	jalr	-1574(ra) # 800044d4 <fileclose>
    fileclose(wf);
    80005b02:	fc843503          	ld	a0,-56(s0)
    80005b06:	fffff097          	auipc	ra,0xfffff
    80005b0a:	9ce080e7          	jalr	-1586(ra) # 800044d4 <fileclose>
    return -1;
    80005b0e:	57fd                	li	a5,-1
}
    80005b10:	853e                	mv	a0,a5
    80005b12:	70e2                	ld	ra,56(sp)
    80005b14:	7442                	ld	s0,48(sp)
    80005b16:	74a2                	ld	s1,40(sp)
    80005b18:	6121                	addi	sp,sp,64
    80005b1a:	8082                	ret
    80005b1c:	0000                	unimp
	...

0000000080005b20 <kernelvec>:
    80005b20:	7111                	addi	sp,sp,-256
    80005b22:	e006                	sd	ra,0(sp)
    80005b24:	e40a                	sd	sp,8(sp)
    80005b26:	e80e                	sd	gp,16(sp)
    80005b28:	ec12                	sd	tp,24(sp)
    80005b2a:	f016                	sd	t0,32(sp)
    80005b2c:	f41a                	sd	t1,40(sp)
    80005b2e:	f81e                	sd	t2,48(sp)
    80005b30:	fc22                	sd	s0,56(sp)
    80005b32:	e0a6                	sd	s1,64(sp)
    80005b34:	e4aa                	sd	a0,72(sp)
    80005b36:	e8ae                	sd	a1,80(sp)
    80005b38:	ecb2                	sd	a2,88(sp)
    80005b3a:	f0b6                	sd	a3,96(sp)
    80005b3c:	f4ba                	sd	a4,104(sp)
    80005b3e:	f8be                	sd	a5,112(sp)
    80005b40:	fcc2                	sd	a6,120(sp)
    80005b42:	e146                	sd	a7,128(sp)
    80005b44:	e54a                	sd	s2,136(sp)
    80005b46:	e94e                	sd	s3,144(sp)
    80005b48:	ed52                	sd	s4,152(sp)
    80005b4a:	f156                	sd	s5,160(sp)
    80005b4c:	f55a                	sd	s6,168(sp)
    80005b4e:	f95e                	sd	s7,176(sp)
    80005b50:	fd62                	sd	s8,184(sp)
    80005b52:	e1e6                	sd	s9,192(sp)
    80005b54:	e5ea                	sd	s10,200(sp)
    80005b56:	e9ee                	sd	s11,208(sp)
    80005b58:	edf2                	sd	t3,216(sp)
    80005b5a:	f1f6                	sd	t4,224(sp)
    80005b5c:	f5fa                	sd	t5,232(sp)
    80005b5e:	f9fe                	sd	t6,240(sp)
    80005b60:	d8ffc0ef          	jal	ra,800028ee <kerneltrap>
    80005b64:	6082                	ld	ra,0(sp)
    80005b66:	6122                	ld	sp,8(sp)
    80005b68:	61c2                	ld	gp,16(sp)
    80005b6a:	7282                	ld	t0,32(sp)
    80005b6c:	7322                	ld	t1,40(sp)
    80005b6e:	73c2                	ld	t2,48(sp)
    80005b70:	7462                	ld	s0,56(sp)
    80005b72:	6486                	ld	s1,64(sp)
    80005b74:	6526                	ld	a0,72(sp)
    80005b76:	65c6                	ld	a1,80(sp)
    80005b78:	6666                	ld	a2,88(sp)
    80005b7a:	7686                	ld	a3,96(sp)
    80005b7c:	7726                	ld	a4,104(sp)
    80005b7e:	77c6                	ld	a5,112(sp)
    80005b80:	7866                	ld	a6,120(sp)
    80005b82:	688a                	ld	a7,128(sp)
    80005b84:	692a                	ld	s2,136(sp)
    80005b86:	69ca                	ld	s3,144(sp)
    80005b88:	6a6a                	ld	s4,152(sp)
    80005b8a:	7a8a                	ld	s5,160(sp)
    80005b8c:	7b2a                	ld	s6,168(sp)
    80005b8e:	7bca                	ld	s7,176(sp)
    80005b90:	7c6a                	ld	s8,184(sp)
    80005b92:	6c8e                	ld	s9,192(sp)
    80005b94:	6d2e                	ld	s10,200(sp)
    80005b96:	6dce                	ld	s11,208(sp)
    80005b98:	6e6e                	ld	t3,216(sp)
    80005b9a:	7e8e                	ld	t4,224(sp)
    80005b9c:	7f2e                	ld	t5,232(sp)
    80005b9e:	7fce                	ld	t6,240(sp)
    80005ba0:	6111                	addi	sp,sp,256
    80005ba2:	10200073          	sret
    80005ba6:	00000013          	nop
    80005baa:	00000013          	nop
    80005bae:	0001                	nop

0000000080005bb0 <timervec>:
    80005bb0:	34051573          	csrrw	a0,mscratch,a0
    80005bb4:	e10c                	sd	a1,0(a0)
    80005bb6:	e510                	sd	a2,8(a0)
    80005bb8:	e914                	sd	a3,16(a0)
    80005bba:	6d0c                	ld	a1,24(a0)
    80005bbc:	7110                	ld	a2,32(a0)
    80005bbe:	6194                	ld	a3,0(a1)
    80005bc0:	96b2                	add	a3,a3,a2
    80005bc2:	e194                	sd	a3,0(a1)
    80005bc4:	4589                	li	a1,2
    80005bc6:	14459073          	csrw	sip,a1
    80005bca:	6914                	ld	a3,16(a0)
    80005bcc:	6510                	ld	a2,8(a0)
    80005bce:	610c                	ld	a1,0(a0)
    80005bd0:	34051573          	csrrw	a0,mscratch,a0
    80005bd4:	30200073          	mret
	...

0000000080005bda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005bda:	1141                	addi	sp,sp,-16
    80005bdc:	e422                	sd	s0,8(sp)
    80005bde:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005be0:	0c0007b7          	lui	a5,0xc000
    80005be4:	4705                	li	a4,1
    80005be6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005be8:	c3d8                	sw	a4,4(a5)
}
    80005bea:	6422                	ld	s0,8(sp)
    80005bec:	0141                	addi	sp,sp,16
    80005bee:	8082                	ret

0000000080005bf0 <plicinithart>:

void
plicinithart(void)
{
    80005bf0:	1141                	addi	sp,sp,-16
    80005bf2:	e406                	sd	ra,8(sp)
    80005bf4:	e022                	sd	s0,0(sp)
    80005bf6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bf8:	ffffc097          	auipc	ra,0xffffc
    80005bfc:	d88080e7          	jalr	-632(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c00:	0085171b          	slliw	a4,a0,0x8
    80005c04:	0c0027b7          	lui	a5,0xc002
    80005c08:	97ba                	add	a5,a5,a4
    80005c0a:	40200713          	li	a4,1026
    80005c0e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c12:	00d5151b          	slliw	a0,a0,0xd
    80005c16:	0c2017b7          	lui	a5,0xc201
    80005c1a:	953e                	add	a0,a0,a5
    80005c1c:	00052023          	sw	zero,0(a0)
}
    80005c20:	60a2                	ld	ra,8(sp)
    80005c22:	6402                	ld	s0,0(sp)
    80005c24:	0141                	addi	sp,sp,16
    80005c26:	8082                	ret

0000000080005c28 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c28:	1141                	addi	sp,sp,-16
    80005c2a:	e406                	sd	ra,8(sp)
    80005c2c:	e022                	sd	s0,0(sp)
    80005c2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c30:	ffffc097          	auipc	ra,0xffffc
    80005c34:	d50080e7          	jalr	-688(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c38:	00d5179b          	slliw	a5,a0,0xd
    80005c3c:	0c201537          	lui	a0,0xc201
    80005c40:	953e                	add	a0,a0,a5
  return irq;
}
    80005c42:	4148                	lw	a0,4(a0)
    80005c44:	60a2                	ld	ra,8(sp)
    80005c46:	6402                	ld	s0,0(sp)
    80005c48:	0141                	addi	sp,sp,16
    80005c4a:	8082                	ret

0000000080005c4c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c4c:	1101                	addi	sp,sp,-32
    80005c4e:	ec06                	sd	ra,24(sp)
    80005c50:	e822                	sd	s0,16(sp)
    80005c52:	e426                	sd	s1,8(sp)
    80005c54:	1000                	addi	s0,sp,32
    80005c56:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	d28080e7          	jalr	-728(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c60:	00d5151b          	slliw	a0,a0,0xd
    80005c64:	0c2017b7          	lui	a5,0xc201
    80005c68:	97aa                	add	a5,a5,a0
    80005c6a:	c3c4                	sw	s1,4(a5)
}
    80005c6c:	60e2                	ld	ra,24(sp)
    80005c6e:	6442                	ld	s0,16(sp)
    80005c70:	64a2                	ld	s1,8(sp)
    80005c72:	6105                	addi	sp,sp,32
    80005c74:	8082                	ret

0000000080005c76 <free_desc>:
    80005c76:	1141                	addi	sp,sp,-16
    80005c78:	e406                	sd	ra,8(sp)
    80005c7a:	e022                	sd	s0,0(sp)
    80005c7c:	0800                	addi	s0,sp,16
    80005c7e:	479d                	li	a5,7
    80005c80:	04a7cc63          	blt	a5,a0,80005cd8 <free_desc+0x62>
    80005c84:	0001c797          	auipc	a5,0x1c
    80005c88:	fac78793          	addi	a5,a5,-84 # 80021c30 <disk>
    80005c8c:	97aa                	add	a5,a5,a0
    80005c8e:	0187c783          	lbu	a5,24(a5)
    80005c92:	ebb9                	bnez	a5,80005ce8 <free_desc+0x72>
    80005c94:	00451613          	slli	a2,a0,0x4
    80005c98:	0001c797          	auipc	a5,0x1c
    80005c9c:	f9878793          	addi	a5,a5,-104 # 80021c30 <disk>
    80005ca0:	6394                	ld	a3,0(a5)
    80005ca2:	96b2                	add	a3,a3,a2
    80005ca4:	0006b023          	sd	zero,0(a3)
    80005ca8:	6398                	ld	a4,0(a5)
    80005caa:	9732                	add	a4,a4,a2
    80005cac:	00072423          	sw	zero,8(a4)
    80005cb0:	00071623          	sh	zero,12(a4)
    80005cb4:	00071723          	sh	zero,14(a4)
    80005cb8:	953e                	add	a0,a0,a5
    80005cba:	4785                	li	a5,1
    80005cbc:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
    80005cc0:	0001c517          	auipc	a0,0x1c
    80005cc4:	f8850513          	addi	a0,a0,-120 # 80021c48 <disk+0x18>
    80005cc8:	ffffc097          	auipc	ra,0xffffc
    80005ccc:	3f0080e7          	jalr	1008(ra) # 800020b8 <wakeup>
    80005cd0:	60a2                	ld	ra,8(sp)
    80005cd2:	6402                	ld	s0,0(sp)
    80005cd4:	0141                	addi	sp,sp,16
    80005cd6:	8082                	ret
    80005cd8:	00003517          	auipc	a0,0x3
    80005cdc:	a7050513          	addi	a0,a0,-1424 # 80008748 <syscalls+0x2f8>
    80005ce0:	ffffb097          	auipc	ra,0xffffb
    80005ce4:	85e080e7          	jalr	-1954(ra) # 8000053e <panic>
    80005ce8:	00003517          	auipc	a0,0x3
    80005cec:	a7050513          	addi	a0,a0,-1424 # 80008758 <syscalls+0x308>
    80005cf0:	ffffb097          	auipc	ra,0xffffb
    80005cf4:	84e080e7          	jalr	-1970(ra) # 8000053e <panic>

0000000080005cf8 <virtio_disk_init>:
    80005cf8:	1101                	addi	sp,sp,-32
    80005cfa:	ec06                	sd	ra,24(sp)
    80005cfc:	e822                	sd	s0,16(sp)
    80005cfe:	e426                	sd	s1,8(sp)
    80005d00:	e04a                	sd	s2,0(sp)
    80005d02:	1000                	addi	s0,sp,32
    80005d04:	00003597          	auipc	a1,0x3
    80005d08:	a6458593          	addi	a1,a1,-1436 # 80008768 <syscalls+0x318>
    80005d0c:	0001c517          	auipc	a0,0x1c
    80005d10:	04c50513          	addi	a0,a0,76 # 80021d58 <disk+0x128>
    80005d14:	ffffb097          	auipc	ra,0xffffb
    80005d18:	e32080e7          	jalr	-462(ra) # 80000b46 <initlock>
    80005d1c:	100017b7          	lui	a5,0x10001
    80005d20:	4398                	lw	a4,0(a5)
    80005d22:	2701                	sext.w	a4,a4
    80005d24:	747277b7          	lui	a5,0x74727
    80005d28:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d2c:	14f71c63          	bne	a4,a5,80005e84 <virtio_disk_init+0x18c>
    80005d30:	100017b7          	lui	a5,0x10001
    80005d34:	43dc                	lw	a5,4(a5)
    80005d36:	2781                	sext.w	a5,a5
    80005d38:	4709                	li	a4,2
    80005d3a:	14e79563          	bne	a5,a4,80005e84 <virtio_disk_init+0x18c>
    80005d3e:	100017b7          	lui	a5,0x10001
    80005d42:	479c                	lw	a5,8(a5)
    80005d44:	2781                	sext.w	a5,a5
    80005d46:	12e79f63          	bne	a5,a4,80005e84 <virtio_disk_init+0x18c>
    80005d4a:	100017b7          	lui	a5,0x10001
    80005d4e:	47d8                	lw	a4,12(a5)
    80005d50:	2701                	sext.w	a4,a4
    80005d52:	554d47b7          	lui	a5,0x554d4
    80005d56:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d5a:	12f71563          	bne	a4,a5,80005e84 <virtio_disk_init+0x18c>
    80005d5e:	100017b7          	lui	a5,0x10001
    80005d62:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
    80005d66:	4705                	li	a4,1
    80005d68:	dbb8                	sw	a4,112(a5)
    80005d6a:	470d                	li	a4,3
    80005d6c:	dbb8                	sw	a4,112(a5)
    80005d6e:	4b94                	lw	a3,16(a5)
    80005d70:	c7ffe737          	lui	a4,0xc7ffe
    80005d74:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc9ef>
    80005d78:	8f75                	and	a4,a4,a3
    80005d7a:	2701                	sext.w	a4,a4
    80005d7c:	d398                	sw	a4,32(a5)
    80005d7e:	472d                	li	a4,11
    80005d80:	dbb8                	sw	a4,112(a5)
    80005d82:	5bbc                	lw	a5,112(a5)
    80005d84:	0007891b          	sext.w	s2,a5
    80005d88:	8ba1                	andi	a5,a5,8
    80005d8a:	10078563          	beqz	a5,80005e94 <virtio_disk_init+0x19c>
    80005d8e:	100017b7          	lui	a5,0x10001
    80005d92:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
    80005d96:	43fc                	lw	a5,68(a5)
    80005d98:	2781                	sext.w	a5,a5
    80005d9a:	10079563          	bnez	a5,80005ea4 <virtio_disk_init+0x1ac>
    80005d9e:	100017b7          	lui	a5,0x10001
    80005da2:	5bdc                	lw	a5,52(a5)
    80005da4:	2781                	sext.w	a5,a5
    80005da6:	10078763          	beqz	a5,80005eb4 <virtio_disk_init+0x1bc>
    80005daa:	471d                	li	a4,7
    80005dac:	10f77c63          	bgeu	a4,a5,80005ec4 <virtio_disk_init+0x1cc>
    80005db0:	ffffb097          	auipc	ra,0xffffb
    80005db4:	d36080e7          	jalr	-714(ra) # 80000ae6 <kalloc>
    80005db8:	0001c497          	auipc	s1,0x1c
    80005dbc:	e7848493          	addi	s1,s1,-392 # 80021c30 <disk>
    80005dc0:	e088                	sd	a0,0(s1)
    80005dc2:	ffffb097          	auipc	ra,0xffffb
    80005dc6:	d24080e7          	jalr	-732(ra) # 80000ae6 <kalloc>
    80005dca:	e488                	sd	a0,8(s1)
    80005dcc:	ffffb097          	auipc	ra,0xffffb
    80005dd0:	d1a080e7          	jalr	-742(ra) # 80000ae6 <kalloc>
    80005dd4:	87aa                	mv	a5,a0
    80005dd6:	e888                	sd	a0,16(s1)
    80005dd8:	6088                	ld	a0,0(s1)
    80005dda:	cd6d                	beqz	a0,80005ed4 <virtio_disk_init+0x1dc>
    80005ddc:	0001c717          	auipc	a4,0x1c
    80005de0:	e5c73703          	ld	a4,-420(a4) # 80021c38 <disk+0x8>
    80005de4:	cb65                	beqz	a4,80005ed4 <virtio_disk_init+0x1dc>
    80005de6:	c7fd                	beqz	a5,80005ed4 <virtio_disk_init+0x1dc>
    80005de8:	6605                	lui	a2,0x1
    80005dea:	4581                	li	a1,0
    80005dec:	ffffb097          	auipc	ra,0xffffb
    80005df0:	ee6080e7          	jalr	-282(ra) # 80000cd2 <memset>
    80005df4:	0001c497          	auipc	s1,0x1c
    80005df8:	e3c48493          	addi	s1,s1,-452 # 80021c30 <disk>
    80005dfc:	6605                	lui	a2,0x1
    80005dfe:	4581                	li	a1,0
    80005e00:	6488                	ld	a0,8(s1)
    80005e02:	ffffb097          	auipc	ra,0xffffb
    80005e06:	ed0080e7          	jalr	-304(ra) # 80000cd2 <memset>
    80005e0a:	6605                	lui	a2,0x1
    80005e0c:	4581                	li	a1,0
    80005e0e:	6888                	ld	a0,16(s1)
    80005e10:	ffffb097          	auipc	ra,0xffffb
    80005e14:	ec2080e7          	jalr	-318(ra) # 80000cd2 <memset>
    80005e18:	100017b7          	lui	a5,0x10001
    80005e1c:	4721                	li	a4,8
    80005e1e:	df98                	sw	a4,56(a5)
    80005e20:	4098                	lw	a4,0(s1)
    80005e22:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
    80005e26:	40d8                	lw	a4,4(s1)
    80005e28:	08e7a223          	sw	a4,132(a5)
    80005e2c:	6498                	ld	a4,8(s1)
    80005e2e:	0007069b          	sext.w	a3,a4
    80005e32:	08d7a823          	sw	a3,144(a5)
    80005e36:	9701                	srai	a4,a4,0x20
    80005e38:	08e7aa23          	sw	a4,148(a5)
    80005e3c:	6898                	ld	a4,16(s1)
    80005e3e:	0007069b          	sext.w	a3,a4
    80005e42:	0ad7a023          	sw	a3,160(a5)
    80005e46:	9701                	srai	a4,a4,0x20
    80005e48:	0ae7a223          	sw	a4,164(a5)
    80005e4c:	4705                	li	a4,1
    80005e4e:	c3f8                	sw	a4,68(a5)
    80005e50:	00e48c23          	sb	a4,24(s1)
    80005e54:	00e48ca3          	sb	a4,25(s1)
    80005e58:	00e48d23          	sb	a4,26(s1)
    80005e5c:	00e48da3          	sb	a4,27(s1)
    80005e60:	00e48e23          	sb	a4,28(s1)
    80005e64:	00e48ea3          	sb	a4,29(s1)
    80005e68:	00e48f23          	sb	a4,30(s1)
    80005e6c:	00e48fa3          	sb	a4,31(s1)
    80005e70:	00496913          	ori	s2,s2,4
    80005e74:	0727a823          	sw	s2,112(a5)
    80005e78:	60e2                	ld	ra,24(sp)
    80005e7a:	6442                	ld	s0,16(sp)
    80005e7c:	64a2                	ld	s1,8(sp)
    80005e7e:	6902                	ld	s2,0(sp)
    80005e80:	6105                	addi	sp,sp,32
    80005e82:	8082                	ret
    80005e84:	00003517          	auipc	a0,0x3
    80005e88:	8f450513          	addi	a0,a0,-1804 # 80008778 <syscalls+0x328>
    80005e8c:	ffffa097          	auipc	ra,0xffffa
    80005e90:	6b2080e7          	jalr	1714(ra) # 8000053e <panic>
    80005e94:	00003517          	auipc	a0,0x3
    80005e98:	90450513          	addi	a0,a0,-1788 # 80008798 <syscalls+0x348>
    80005e9c:	ffffa097          	auipc	ra,0xffffa
    80005ea0:	6a2080e7          	jalr	1698(ra) # 8000053e <panic>
    80005ea4:	00003517          	auipc	a0,0x3
    80005ea8:	91450513          	addi	a0,a0,-1772 # 800087b8 <syscalls+0x368>
    80005eac:	ffffa097          	auipc	ra,0xffffa
    80005eb0:	692080e7          	jalr	1682(ra) # 8000053e <panic>
    80005eb4:	00003517          	auipc	a0,0x3
    80005eb8:	92450513          	addi	a0,a0,-1756 # 800087d8 <syscalls+0x388>
    80005ebc:	ffffa097          	auipc	ra,0xffffa
    80005ec0:	682080e7          	jalr	1666(ra) # 8000053e <panic>
    80005ec4:	00003517          	auipc	a0,0x3
    80005ec8:	93450513          	addi	a0,a0,-1740 # 800087f8 <syscalls+0x3a8>
    80005ecc:	ffffa097          	auipc	ra,0xffffa
    80005ed0:	672080e7          	jalr	1650(ra) # 8000053e <panic>
    80005ed4:	00003517          	auipc	a0,0x3
    80005ed8:	94450513          	addi	a0,a0,-1724 # 80008818 <syscalls+0x3c8>
    80005edc:	ffffa097          	auipc	ra,0xffffa
    80005ee0:	662080e7          	jalr	1634(ra) # 8000053e <panic>

0000000080005ee4 <virtio_disk_rw>:
    80005ee4:	7119                	addi	sp,sp,-128
    80005ee6:	fc86                	sd	ra,120(sp)
    80005ee8:	f8a2                	sd	s0,112(sp)
    80005eea:	f4a6                	sd	s1,104(sp)
    80005eec:	f0ca                	sd	s2,96(sp)
    80005eee:	ecce                	sd	s3,88(sp)
    80005ef0:	e8d2                	sd	s4,80(sp)
    80005ef2:	e4d6                	sd	s5,72(sp)
    80005ef4:	e0da                	sd	s6,64(sp)
    80005ef6:	fc5e                	sd	s7,56(sp)
    80005ef8:	f862                	sd	s8,48(sp)
    80005efa:	f466                	sd	s9,40(sp)
    80005efc:	f06a                	sd	s10,32(sp)
    80005efe:	ec6e                	sd	s11,24(sp)
    80005f00:	0100                	addi	s0,sp,128
    80005f02:	8aaa                	mv	s5,a0
    80005f04:	8c2e                	mv	s8,a1
    80005f06:	00c52d03          	lw	s10,12(a0)
    80005f0a:	001d1d1b          	slliw	s10,s10,0x1
    80005f0e:	1d02                	slli	s10,s10,0x20
    80005f10:	020d5d13          	srli	s10,s10,0x20
    80005f14:	0001c517          	auipc	a0,0x1c
    80005f18:	e4450513          	addi	a0,a0,-444 # 80021d58 <disk+0x128>
    80005f1c:	ffffb097          	auipc	ra,0xffffb
    80005f20:	cba080e7          	jalr	-838(ra) # 80000bd6 <acquire>
    80005f24:	4981                	li	s3,0
    80005f26:	44a1                	li	s1,8
    80005f28:	0001cb97          	auipc	s7,0x1c
    80005f2c:	d08b8b93          	addi	s7,s7,-760 # 80021c30 <disk>
    80005f30:	4b0d                	li	s6,3
    80005f32:	0001cc97          	auipc	s9,0x1c
    80005f36:	e26c8c93          	addi	s9,s9,-474 # 80021d58 <disk+0x128>
    80005f3a:	a08d                	j	80005f9c <virtio_disk_rw+0xb8>
    80005f3c:	00fb8733          	add	a4,s7,a5
    80005f40:	00070c23          	sb	zero,24(a4)
    80005f44:	c19c                	sw	a5,0(a1)
    80005f46:	0207c563          	bltz	a5,80005f70 <virtio_disk_rw+0x8c>
    80005f4a:	2905                	addiw	s2,s2,1
    80005f4c:	0611                	addi	a2,a2,4
    80005f4e:	05690c63          	beq	s2,s6,80005fa6 <virtio_disk_rw+0xc2>
    80005f52:	85b2                	mv	a1,a2
    80005f54:	0001c717          	auipc	a4,0x1c
    80005f58:	cdc70713          	addi	a4,a4,-804 # 80021c30 <disk>
    80005f5c:	87ce                	mv	a5,s3
    80005f5e:	01874683          	lbu	a3,24(a4)
    80005f62:	fee9                	bnez	a3,80005f3c <virtio_disk_rw+0x58>
    80005f64:	2785                	addiw	a5,a5,1
    80005f66:	0705                	addi	a4,a4,1
    80005f68:	fe979be3          	bne	a5,s1,80005f5e <virtio_disk_rw+0x7a>
    80005f6c:	57fd                	li	a5,-1
    80005f6e:	c19c                	sw	a5,0(a1)
    80005f70:	01205d63          	blez	s2,80005f8a <virtio_disk_rw+0xa6>
    80005f74:	8dce                	mv	s11,s3
    80005f76:	000a2503          	lw	a0,0(s4)
    80005f7a:	00000097          	auipc	ra,0x0
    80005f7e:	cfc080e7          	jalr	-772(ra) # 80005c76 <free_desc>
    80005f82:	2d85                	addiw	s11,s11,1
    80005f84:	0a11                	addi	s4,s4,4
    80005f86:	ffb918e3          	bne	s2,s11,80005f76 <virtio_disk_rw+0x92>
    80005f8a:	85e6                	mv	a1,s9
    80005f8c:	0001c517          	auipc	a0,0x1c
    80005f90:	cbc50513          	addi	a0,a0,-836 # 80021c48 <disk+0x18>
    80005f94:	ffffc097          	auipc	ra,0xffffc
    80005f98:	0c0080e7          	jalr	192(ra) # 80002054 <sleep>
    80005f9c:	f8040a13          	addi	s4,s0,-128
    80005fa0:	8652                	mv	a2,s4
    80005fa2:	894e                	mv	s2,s3
    80005fa4:	b77d                	j	80005f52 <virtio_disk_rw+0x6e>
    80005fa6:	f8042583          	lw	a1,-128(s0)
    80005faa:	00a58793          	addi	a5,a1,10
    80005fae:	0792                	slli	a5,a5,0x4
    80005fb0:	0001c617          	auipc	a2,0x1c
    80005fb4:	c8060613          	addi	a2,a2,-896 # 80021c30 <disk>
    80005fb8:	00f60733          	add	a4,a2,a5
    80005fbc:	018036b3          	snez	a3,s8
    80005fc0:	c714                	sw	a3,8(a4)
    80005fc2:	00072623          	sw	zero,12(a4)
    80005fc6:	01a73823          	sd	s10,16(a4)
    80005fca:	f6078693          	addi	a3,a5,-160
    80005fce:	6218                	ld	a4,0(a2)
    80005fd0:	9736                	add	a4,a4,a3
    80005fd2:	00878513          	addi	a0,a5,8
    80005fd6:	9532                	add	a0,a0,a2
    80005fd8:	e308                	sd	a0,0(a4)
    80005fda:	6208                	ld	a0,0(a2)
    80005fdc:	96aa                	add	a3,a3,a0
    80005fde:	4741                	li	a4,16
    80005fe0:	c698                	sw	a4,8(a3)
    80005fe2:	4705                	li	a4,1
    80005fe4:	00e69623          	sh	a4,12(a3)
    80005fe8:	f8442703          	lw	a4,-124(s0)
    80005fec:	00e69723          	sh	a4,14(a3)
    80005ff0:	0712                	slli	a4,a4,0x4
    80005ff2:	953a                	add	a0,a0,a4
    80005ff4:	058a8693          	addi	a3,s5,88
    80005ff8:	e114                	sd	a3,0(a0)
    80005ffa:	6208                	ld	a0,0(a2)
    80005ffc:	972a                	add	a4,a4,a0
    80005ffe:	40000693          	li	a3,1024
    80006002:	c714                	sw	a3,8(a4)
    80006004:	001c3c13          	seqz	s8,s8
    80006008:	0c06                	slli	s8,s8,0x1
    8000600a:	001c6c13          	ori	s8,s8,1
    8000600e:	01871623          	sh	s8,12(a4)
    80006012:	f8842603          	lw	a2,-120(s0)
    80006016:	00c71723          	sh	a2,14(a4)
    8000601a:	0001c697          	auipc	a3,0x1c
    8000601e:	c1668693          	addi	a3,a3,-1002 # 80021c30 <disk>
    80006022:	00258713          	addi	a4,a1,2
    80006026:	0712                	slli	a4,a4,0x4
    80006028:	9736                	add	a4,a4,a3
    8000602a:	587d                	li	a6,-1
    8000602c:	01070823          	sb	a6,16(a4)
    80006030:	0612                	slli	a2,a2,0x4
    80006032:	9532                	add	a0,a0,a2
    80006034:	f9078793          	addi	a5,a5,-112
    80006038:	97b6                	add	a5,a5,a3
    8000603a:	e11c                	sd	a5,0(a0)
    8000603c:	629c                	ld	a5,0(a3)
    8000603e:	97b2                	add	a5,a5,a2
    80006040:	4605                	li	a2,1
    80006042:	c790                	sw	a2,8(a5)
    80006044:	4509                	li	a0,2
    80006046:	00a79623          	sh	a0,12(a5)
    8000604a:	00079723          	sh	zero,14(a5)
    8000604e:	00caa223          	sw	a2,4(s5)
    80006052:	01573423          	sd	s5,8(a4)
    80006056:	6698                	ld	a4,8(a3)
    80006058:	00275783          	lhu	a5,2(a4)
    8000605c:	8b9d                	andi	a5,a5,7
    8000605e:	0786                	slli	a5,a5,0x1
    80006060:	97ba                	add	a5,a5,a4
    80006062:	00b79223          	sh	a1,4(a5)
    80006066:	0ff0000f          	fence
    8000606a:	6698                	ld	a4,8(a3)
    8000606c:	00275783          	lhu	a5,2(a4)
    80006070:	2785                	addiw	a5,a5,1
    80006072:	00f71123          	sh	a5,2(a4)
    80006076:	0ff0000f          	fence
    8000607a:	100017b7          	lui	a5,0x10001
    8000607e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    80006082:	004aa783          	lw	a5,4(s5)
    80006086:	02c79163          	bne	a5,a2,800060a8 <virtio_disk_rw+0x1c4>
    8000608a:	0001c917          	auipc	s2,0x1c
    8000608e:	cce90913          	addi	s2,s2,-818 # 80021d58 <disk+0x128>
    80006092:	4485                	li	s1,1
    80006094:	85ca                	mv	a1,s2
    80006096:	8556                	mv	a0,s5
    80006098:	ffffc097          	auipc	ra,0xffffc
    8000609c:	fbc080e7          	jalr	-68(ra) # 80002054 <sleep>
    800060a0:	004aa783          	lw	a5,4(s5)
    800060a4:	fe9788e3          	beq	a5,s1,80006094 <virtio_disk_rw+0x1b0>
    800060a8:	f8042903          	lw	s2,-128(s0)
    800060ac:	00290793          	addi	a5,s2,2
    800060b0:	00479713          	slli	a4,a5,0x4
    800060b4:	0001c797          	auipc	a5,0x1c
    800060b8:	b7c78793          	addi	a5,a5,-1156 # 80021c30 <disk>
    800060bc:	97ba                	add	a5,a5,a4
    800060be:	0007b423          	sd	zero,8(a5)
    800060c2:	0001c997          	auipc	s3,0x1c
    800060c6:	b6e98993          	addi	s3,s3,-1170 # 80021c30 <disk>
    800060ca:	00491713          	slli	a4,s2,0x4
    800060ce:	0009b783          	ld	a5,0(s3)
    800060d2:	97ba                	add	a5,a5,a4
    800060d4:	00c7d483          	lhu	s1,12(a5)
    800060d8:	854a                	mv	a0,s2
    800060da:	00e7d903          	lhu	s2,14(a5)
    800060de:	00000097          	auipc	ra,0x0
    800060e2:	b98080e7          	jalr	-1128(ra) # 80005c76 <free_desc>
    800060e6:	8885                	andi	s1,s1,1
    800060e8:	f0ed                	bnez	s1,800060ca <virtio_disk_rw+0x1e6>
    800060ea:	0001c517          	auipc	a0,0x1c
    800060ee:	c6e50513          	addi	a0,a0,-914 # 80021d58 <disk+0x128>
    800060f2:	ffffb097          	auipc	ra,0xffffb
    800060f6:	b98080e7          	jalr	-1128(ra) # 80000c8a <release>
    800060fa:	70e6                	ld	ra,120(sp)
    800060fc:	7446                	ld	s0,112(sp)
    800060fe:	74a6                	ld	s1,104(sp)
    80006100:	7906                	ld	s2,96(sp)
    80006102:	69e6                	ld	s3,88(sp)
    80006104:	6a46                	ld	s4,80(sp)
    80006106:	6aa6                	ld	s5,72(sp)
    80006108:	6b06                	ld	s6,64(sp)
    8000610a:	7be2                	ld	s7,56(sp)
    8000610c:	7c42                	ld	s8,48(sp)
    8000610e:	7ca2                	ld	s9,40(sp)
    80006110:	7d02                	ld	s10,32(sp)
    80006112:	6de2                	ld	s11,24(sp)
    80006114:	6109                	addi	sp,sp,128
    80006116:	8082                	ret

0000000080006118 <virtio_disk_intr>:
    80006118:	1101                	addi	sp,sp,-32
    8000611a:	ec06                	sd	ra,24(sp)
    8000611c:	e822                	sd	s0,16(sp)
    8000611e:	e426                	sd	s1,8(sp)
    80006120:	1000                	addi	s0,sp,32
    80006122:	0001c497          	auipc	s1,0x1c
    80006126:	b0e48493          	addi	s1,s1,-1266 # 80021c30 <disk>
    8000612a:	0001c517          	auipc	a0,0x1c
    8000612e:	c2e50513          	addi	a0,a0,-978 # 80021d58 <disk+0x128>
    80006132:	ffffb097          	auipc	ra,0xffffb
    80006136:	aa4080e7          	jalr	-1372(ra) # 80000bd6 <acquire>
    8000613a:	10001737          	lui	a4,0x10001
    8000613e:	533c                	lw	a5,96(a4)
    80006140:	8b8d                	andi	a5,a5,3
    80006142:	d37c                	sw	a5,100(a4)
    80006144:	0ff0000f          	fence
    80006148:	689c                	ld	a5,16(s1)
    8000614a:	0204d703          	lhu	a4,32(s1)
    8000614e:	0027d783          	lhu	a5,2(a5)
    80006152:	04f70863          	beq	a4,a5,800061a2 <virtio_disk_intr+0x8a>
    80006156:	0ff0000f          	fence
    8000615a:	6898                	ld	a4,16(s1)
    8000615c:	0204d783          	lhu	a5,32(s1)
    80006160:	8b9d                	andi	a5,a5,7
    80006162:	078e                	slli	a5,a5,0x3
    80006164:	97ba                	add	a5,a5,a4
    80006166:	43dc                	lw	a5,4(a5)
    80006168:	00278713          	addi	a4,a5,2
    8000616c:	0712                	slli	a4,a4,0x4
    8000616e:	9726                	add	a4,a4,s1
    80006170:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006174:	e721                	bnez	a4,800061bc <virtio_disk_intr+0xa4>
    80006176:	0789                	addi	a5,a5,2
    80006178:	0792                	slli	a5,a5,0x4
    8000617a:	97a6                	add	a5,a5,s1
    8000617c:	6788                	ld	a0,8(a5)
    8000617e:	00052223          	sw	zero,4(a0)
    80006182:	ffffc097          	auipc	ra,0xffffc
    80006186:	f36080e7          	jalr	-202(ra) # 800020b8 <wakeup>
    8000618a:	0204d783          	lhu	a5,32(s1)
    8000618e:	2785                	addiw	a5,a5,1
    80006190:	17c2                	slli	a5,a5,0x30
    80006192:	93c1                	srli	a5,a5,0x30
    80006194:	02f49023          	sh	a5,32(s1)
    80006198:	6898                	ld	a4,16(s1)
    8000619a:	00275703          	lhu	a4,2(a4)
    8000619e:	faf71ce3          	bne	a4,a5,80006156 <virtio_disk_intr+0x3e>
    800061a2:	0001c517          	auipc	a0,0x1c
    800061a6:	bb650513          	addi	a0,a0,-1098 # 80021d58 <disk+0x128>
    800061aa:	ffffb097          	auipc	ra,0xffffb
    800061ae:	ae0080e7          	jalr	-1312(ra) # 80000c8a <release>
    800061b2:	60e2                	ld	ra,24(sp)
    800061b4:	6442                	ld	s0,16(sp)
    800061b6:	64a2                	ld	s1,8(sp)
    800061b8:	6105                	addi	sp,sp,32
    800061ba:	8082                	ret
    800061bc:	00002517          	auipc	a0,0x2
    800061c0:	67450513          	addi	a0,a0,1652 # 80008830 <syscalls+0x3e0>
    800061c4:	ffffa097          	auipc	ra,0xffffa
    800061c8:	37a080e7          	jalr	890(ra) # 8000053e <panic>
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
