
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	2b2080e7          	jalr	690(ra) # 2ba <fork>
  10:	00a04b63          	bgtz	a0,26 <main+0x26>
    sleep(5);  // Let child exit before parent.
  exit(0,"");
  14:	00000597          	auipc	a1,0x0
  18:	7dc58593          	addi	a1,a1,2012 # 7f0 <malloc+0xf0>
  1c:	4501                	li	a0,0
  1e:	00000097          	auipc	ra,0x0
  22:	2a4080e7          	jalr	676(ra) # 2c2 <exit>
    sleep(5);  // Let child exit before parent.
  26:	4515                	li	a0,5
  28:	00000097          	auipc	ra,0x0
  2c:	32a080e7          	jalr	810(ra) # 352 <sleep>
  30:	b7d5                	j	14 <main+0x14>

0000000000000032 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  32:	1141                	addi	sp,sp,-16
  34:	e406                	sd	ra,8(sp)
  36:	e022                	sd	s0,0(sp)
  38:	0800                	addi	s0,sp,16
  extern int main();
  main();
  3a:	00000097          	auipc	ra,0x0
  3e:	fc6080e7          	jalr	-58(ra) # 0 <main>
  exit(0,"");
  42:	00000597          	auipc	a1,0x0
  46:	7ae58593          	addi	a1,a1,1966 # 7f0 <malloc+0xf0>
  4a:	4501                	li	a0,0
  4c:	00000097          	auipc	ra,0x0
  50:	276080e7          	jalr	630(ra) # 2c2 <exit>

0000000000000054 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  54:	1141                	addi	sp,sp,-16
  56:	e422                	sd	s0,8(sp)
  58:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5a:	87aa                	mv	a5,a0
  5c:	0585                	addi	a1,a1,1
  5e:	0785                	addi	a5,a5,1
  60:	fff5c703          	lbu	a4,-1(a1)
  64:	fee78fa3          	sb	a4,-1(a5)
  68:	fb75                	bnez	a4,5c <strcpy+0x8>
    ;
  return os;
}
  6a:	6422                	ld	s0,8(sp)
  6c:	0141                	addi	sp,sp,16
  6e:	8082                	ret

0000000000000070 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  70:	1141                	addi	sp,sp,-16
  72:	e422                	sd	s0,8(sp)
  74:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  76:	00054783          	lbu	a5,0(a0)
  7a:	cb91                	beqz	a5,8e <strcmp+0x1e>
  7c:	0005c703          	lbu	a4,0(a1)
  80:	00f71763          	bne	a4,a5,8e <strcmp+0x1e>
    p++, q++;
  84:	0505                	addi	a0,a0,1
  86:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  88:	00054783          	lbu	a5,0(a0)
  8c:	fbe5                	bnez	a5,7c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  8e:	0005c503          	lbu	a0,0(a1)
}
  92:	40a7853b          	subw	a0,a5,a0
  96:	6422                	ld	s0,8(sp)
  98:	0141                	addi	sp,sp,16
  9a:	8082                	ret

000000000000009c <strlen>:

uint
strlen(const char *s)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a2:	00054783          	lbu	a5,0(a0)
  a6:	cf91                	beqz	a5,c2 <strlen+0x26>
  a8:	0505                	addi	a0,a0,1
  aa:	87aa                	mv	a5,a0
  ac:	4685                	li	a3,1
  ae:	9e89                	subw	a3,a3,a0
  b0:	00f6853b          	addw	a0,a3,a5
  b4:	0785                	addi	a5,a5,1
  b6:	fff7c703          	lbu	a4,-1(a5)
  ba:	fb7d                	bnez	a4,b0 <strlen+0x14>
    ;
  return n;
}
  bc:	6422                	ld	s0,8(sp)
  be:	0141                	addi	sp,sp,16
  c0:	8082                	ret
  for(n = 0; s[n]; n++)
  c2:	4501                	li	a0,0
  c4:	bfe5                	j	bc <strlen+0x20>

00000000000000c6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  cc:	ca19                	beqz	a2,e2 <memset+0x1c>
  ce:	87aa                	mv	a5,a0
  d0:	1602                	slli	a2,a2,0x20
  d2:	9201                	srli	a2,a2,0x20
  d4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  dc:	0785                	addi	a5,a5,1
  de:	fee79de3          	bne	a5,a4,d8 <memset+0x12>
  }
  return dst;
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret

00000000000000e8 <strchr>:

char*
strchr(const char *s, char c)
{
  e8:	1141                	addi	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	cb99                	beqz	a5,108 <strchr+0x20>
    if(*s == c)
  f4:	00f58763          	beq	a1,a5,102 <strchr+0x1a>
  for(; *s; s++)
  f8:	0505                	addi	a0,a0,1
  fa:	00054783          	lbu	a5,0(a0)
  fe:	fbfd                	bnez	a5,f4 <strchr+0xc>
      return (char*)s;
  return 0;
 100:	4501                	li	a0,0
}
 102:	6422                	ld	s0,8(sp)
 104:	0141                	addi	sp,sp,16
 106:	8082                	ret
  return 0;
 108:	4501                	li	a0,0
 10a:	bfe5                	j	102 <strchr+0x1a>

000000000000010c <gets>:

char*
gets(char *buf, int max)
{
 10c:	711d                	addi	sp,sp,-96
 10e:	ec86                	sd	ra,88(sp)
 110:	e8a2                	sd	s0,80(sp)
 112:	e4a6                	sd	s1,72(sp)
 114:	e0ca                	sd	s2,64(sp)
 116:	fc4e                	sd	s3,56(sp)
 118:	f852                	sd	s4,48(sp)
 11a:	f456                	sd	s5,40(sp)
 11c:	f05a                	sd	s6,32(sp)
 11e:	ec5e                	sd	s7,24(sp)
 120:	1080                	addi	s0,sp,96
 122:	8baa                	mv	s7,a0
 124:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 126:	892a                	mv	s2,a0
 128:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 12a:	4aa9                	li	s5,10
 12c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 12e:	89a6                	mv	s3,s1
 130:	2485                	addiw	s1,s1,1
 132:	0344d863          	bge	s1,s4,162 <gets+0x56>
    cc = read(0, &c, 1);
 136:	4605                	li	a2,1
 138:	faf40593          	addi	a1,s0,-81
 13c:	4501                	li	a0,0
 13e:	00000097          	auipc	ra,0x0
 142:	19c080e7          	jalr	412(ra) # 2da <read>
    if(cc < 1)
 146:	00a05e63          	blez	a0,162 <gets+0x56>
    buf[i++] = c;
 14a:	faf44783          	lbu	a5,-81(s0)
 14e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 152:	01578763          	beq	a5,s5,160 <gets+0x54>
 156:	0905                	addi	s2,s2,1
 158:	fd679be3          	bne	a5,s6,12e <gets+0x22>
  for(i=0; i+1 < max; ){
 15c:	89a6                	mv	s3,s1
 15e:	a011                	j	162 <gets+0x56>
 160:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 162:	99de                	add	s3,s3,s7
 164:	00098023          	sb	zero,0(s3)
  return buf;
}
 168:	855e                	mv	a0,s7
 16a:	60e6                	ld	ra,88(sp)
 16c:	6446                	ld	s0,80(sp)
 16e:	64a6                	ld	s1,72(sp)
 170:	6906                	ld	s2,64(sp)
 172:	79e2                	ld	s3,56(sp)
 174:	7a42                	ld	s4,48(sp)
 176:	7aa2                	ld	s5,40(sp)
 178:	7b02                	ld	s6,32(sp)
 17a:	6be2                	ld	s7,24(sp)
 17c:	6125                	addi	sp,sp,96
 17e:	8082                	ret

0000000000000180 <stat>:

int
stat(const char *n, struct stat *st)
{
 180:	1101                	addi	sp,sp,-32
 182:	ec06                	sd	ra,24(sp)
 184:	e822                	sd	s0,16(sp)
 186:	e426                	sd	s1,8(sp)
 188:	e04a                	sd	s2,0(sp)
 18a:	1000                	addi	s0,sp,32
 18c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 18e:	4581                	li	a1,0
 190:	00000097          	auipc	ra,0x0
 194:	172080e7          	jalr	370(ra) # 302 <open>
  if(fd < 0)
 198:	02054563          	bltz	a0,1c2 <stat+0x42>
 19c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 19e:	85ca                	mv	a1,s2
 1a0:	00000097          	auipc	ra,0x0
 1a4:	17a080e7          	jalr	378(ra) # 31a <fstat>
 1a8:	892a                	mv	s2,a0
  close(fd);
 1aa:	8526                	mv	a0,s1
 1ac:	00000097          	auipc	ra,0x0
 1b0:	13e080e7          	jalr	318(ra) # 2ea <close>
  return r;
}
 1b4:	854a                	mv	a0,s2
 1b6:	60e2                	ld	ra,24(sp)
 1b8:	6442                	ld	s0,16(sp)
 1ba:	64a2                	ld	s1,8(sp)
 1bc:	6902                	ld	s2,0(sp)
 1be:	6105                	addi	sp,sp,32
 1c0:	8082                	ret
    return -1;
 1c2:	597d                	li	s2,-1
 1c4:	bfc5                	j	1b4 <stat+0x34>

00000000000001c6 <atoi>:

int
atoi(const char *s)
{
 1c6:	1141                	addi	sp,sp,-16
 1c8:	e422                	sd	s0,8(sp)
 1ca:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1cc:	00054603          	lbu	a2,0(a0)
 1d0:	fd06079b          	addiw	a5,a2,-48
 1d4:	0ff7f793          	andi	a5,a5,255
 1d8:	4725                	li	a4,9
 1da:	02f76963          	bltu	a4,a5,20c <atoi+0x46>
 1de:	86aa                	mv	a3,a0
  n = 0;
 1e0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1e2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1e4:	0685                	addi	a3,a3,1
 1e6:	0025179b          	slliw	a5,a0,0x2
 1ea:	9fa9                	addw	a5,a5,a0
 1ec:	0017979b          	slliw	a5,a5,0x1
 1f0:	9fb1                	addw	a5,a5,a2
 1f2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f6:	0006c603          	lbu	a2,0(a3)
 1fa:	fd06071b          	addiw	a4,a2,-48
 1fe:	0ff77713          	andi	a4,a4,255
 202:	fee5f1e3          	bgeu	a1,a4,1e4 <atoi+0x1e>
  return n;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret
  n = 0;
 20c:	4501                	li	a0,0
 20e:	bfe5                	j	206 <atoi+0x40>

0000000000000210 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 210:	1141                	addi	sp,sp,-16
 212:	e422                	sd	s0,8(sp)
 214:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 216:	02b57463          	bgeu	a0,a1,23e <memmove+0x2e>
    while(n-- > 0)
 21a:	00c05f63          	blez	a2,238 <memmove+0x28>
 21e:	1602                	slli	a2,a2,0x20
 220:	9201                	srli	a2,a2,0x20
 222:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 226:	872a                	mv	a4,a0
      *dst++ = *src++;
 228:	0585                	addi	a1,a1,1
 22a:	0705                	addi	a4,a4,1
 22c:	fff5c683          	lbu	a3,-1(a1)
 230:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 234:	fee79ae3          	bne	a5,a4,228 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 238:	6422                	ld	s0,8(sp)
 23a:	0141                	addi	sp,sp,16
 23c:	8082                	ret
    dst += n;
 23e:	00c50733          	add	a4,a0,a2
    src += n;
 242:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 244:	fec05ae3          	blez	a2,238 <memmove+0x28>
 248:	fff6079b          	addiw	a5,a2,-1
 24c:	1782                	slli	a5,a5,0x20
 24e:	9381                	srli	a5,a5,0x20
 250:	fff7c793          	not	a5,a5
 254:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 256:	15fd                	addi	a1,a1,-1
 258:	177d                	addi	a4,a4,-1
 25a:	0005c683          	lbu	a3,0(a1)
 25e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 262:	fee79ae3          	bne	a5,a4,256 <memmove+0x46>
 266:	bfc9                	j	238 <memmove+0x28>

0000000000000268 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e422                	sd	s0,8(sp)
 26c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 26e:	ca05                	beqz	a2,29e <memcmp+0x36>
 270:	fff6069b          	addiw	a3,a2,-1
 274:	1682                	slli	a3,a3,0x20
 276:	9281                	srli	a3,a3,0x20
 278:	0685                	addi	a3,a3,1
 27a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 27c:	00054783          	lbu	a5,0(a0)
 280:	0005c703          	lbu	a4,0(a1)
 284:	00e79863          	bne	a5,a4,294 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 288:	0505                	addi	a0,a0,1
    p2++;
 28a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 28c:	fed518e3          	bne	a0,a3,27c <memcmp+0x14>
  }
  return 0;
 290:	4501                	li	a0,0
 292:	a019                	j	298 <memcmp+0x30>
      return *p1 - *p2;
 294:	40e7853b          	subw	a0,a5,a4
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret
  return 0;
 29e:	4501                	li	a0,0
 2a0:	bfe5                	j	298 <memcmp+0x30>

00000000000002a2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e406                	sd	ra,8(sp)
 2a6:	e022                	sd	s0,0(sp)
 2a8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2aa:	00000097          	auipc	ra,0x0
 2ae:	f66080e7          	jalr	-154(ra) # 210 <memmove>
}
 2b2:	60a2                	ld	ra,8(sp)
 2b4:	6402                	ld	s0,0(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ba:	4885                	li	a7,1
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c2:	4889                	li	a7,2
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ca:	488d                	li	a7,3
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d2:	4891                	li	a7,4
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <read>:
.global read
read:
 li a7, SYS_read
 2da:	4895                	li	a7,5
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <write>:
.global write
write:
 li a7, SYS_write
 2e2:	48c1                	li	a7,16
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <close>:
.global close
close:
 li a7, SYS_close
 2ea:	48d5                	li	a7,21
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f2:	4899                	li	a7,6
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fa:	489d                	li	a7,7
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <open>:
.global open
open:
 li a7, SYS_open
 302:	48bd                	li	a7,15
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30a:	48c5                	li	a7,17
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 312:	48c9                	li	a7,18
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31a:	48a1                	li	a7,8
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <link>:
.global link
link:
 li a7, SYS_link
 322:	48cd                	li	a7,19
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32a:	48d1                	li	a7,20
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 332:	48a5                	li	a7,9
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <dup>:
.global dup
dup:
 li a7, SYS_dup
 33a:	48a9                	li	a7,10
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 342:	48ad                	li	a7,11
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 34a:	48b1                	li	a7,12
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 352:	48b5                	li	a7,13
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35a:	48b9                	li	a7,14
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 362:	48d9                	li	a7,22
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 36a:	1101                	addi	sp,sp,-32
 36c:	ec06                	sd	ra,24(sp)
 36e:	e822                	sd	s0,16(sp)
 370:	1000                	addi	s0,sp,32
 372:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 376:	4605                	li	a2,1
 378:	fef40593          	addi	a1,s0,-17
 37c:	00000097          	auipc	ra,0x0
 380:	f66080e7          	jalr	-154(ra) # 2e2 <write>
}
 384:	60e2                	ld	ra,24(sp)
 386:	6442                	ld	s0,16(sp)
 388:	6105                	addi	sp,sp,32
 38a:	8082                	ret

000000000000038c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38c:	7139                	addi	sp,sp,-64
 38e:	fc06                	sd	ra,56(sp)
 390:	f822                	sd	s0,48(sp)
 392:	f426                	sd	s1,40(sp)
 394:	f04a                	sd	s2,32(sp)
 396:	ec4e                	sd	s3,24(sp)
 398:	0080                	addi	s0,sp,64
 39a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 39c:	c299                	beqz	a3,3a2 <printint+0x16>
 39e:	0805c863          	bltz	a1,42e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3a2:	2581                	sext.w	a1,a1
  neg = 0;
 3a4:	4881                	li	a7,0
 3a6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3aa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ac:	2601                	sext.w	a2,a2
 3ae:	00000517          	auipc	a0,0x0
 3b2:	45250513          	addi	a0,a0,1106 # 800 <digits>
 3b6:	883a                	mv	a6,a4
 3b8:	2705                	addiw	a4,a4,1
 3ba:	02c5f7bb          	remuw	a5,a1,a2
 3be:	1782                	slli	a5,a5,0x20
 3c0:	9381                	srli	a5,a5,0x20
 3c2:	97aa                	add	a5,a5,a0
 3c4:	0007c783          	lbu	a5,0(a5)
 3c8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3cc:	0005879b          	sext.w	a5,a1
 3d0:	02c5d5bb          	divuw	a1,a1,a2
 3d4:	0685                	addi	a3,a3,1
 3d6:	fec7f0e3          	bgeu	a5,a2,3b6 <printint+0x2a>
  if(neg)
 3da:	00088b63          	beqz	a7,3f0 <printint+0x64>
    buf[i++] = '-';
 3de:	fd040793          	addi	a5,s0,-48
 3e2:	973e                	add	a4,a4,a5
 3e4:	02d00793          	li	a5,45
 3e8:	fef70823          	sb	a5,-16(a4)
 3ec:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3f0:	02e05863          	blez	a4,420 <printint+0x94>
 3f4:	fc040793          	addi	a5,s0,-64
 3f8:	00e78933          	add	s2,a5,a4
 3fc:	fff78993          	addi	s3,a5,-1
 400:	99ba                	add	s3,s3,a4
 402:	377d                	addiw	a4,a4,-1
 404:	1702                	slli	a4,a4,0x20
 406:	9301                	srli	a4,a4,0x20
 408:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 40c:	fff94583          	lbu	a1,-1(s2)
 410:	8526                	mv	a0,s1
 412:	00000097          	auipc	ra,0x0
 416:	f58080e7          	jalr	-168(ra) # 36a <putc>
  while(--i >= 0)
 41a:	197d                	addi	s2,s2,-1
 41c:	ff3918e3          	bne	s2,s3,40c <printint+0x80>
}
 420:	70e2                	ld	ra,56(sp)
 422:	7442                	ld	s0,48(sp)
 424:	74a2                	ld	s1,40(sp)
 426:	7902                	ld	s2,32(sp)
 428:	69e2                	ld	s3,24(sp)
 42a:	6121                	addi	sp,sp,64
 42c:	8082                	ret
    x = -xx;
 42e:	40b005bb          	negw	a1,a1
    neg = 1;
 432:	4885                	li	a7,1
    x = -xx;
 434:	bf8d                	j	3a6 <printint+0x1a>

0000000000000436 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 436:	7119                	addi	sp,sp,-128
 438:	fc86                	sd	ra,120(sp)
 43a:	f8a2                	sd	s0,112(sp)
 43c:	f4a6                	sd	s1,104(sp)
 43e:	f0ca                	sd	s2,96(sp)
 440:	ecce                	sd	s3,88(sp)
 442:	e8d2                	sd	s4,80(sp)
 444:	e4d6                	sd	s5,72(sp)
 446:	e0da                	sd	s6,64(sp)
 448:	fc5e                	sd	s7,56(sp)
 44a:	f862                	sd	s8,48(sp)
 44c:	f466                	sd	s9,40(sp)
 44e:	f06a                	sd	s10,32(sp)
 450:	ec6e                	sd	s11,24(sp)
 452:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 454:	0005c903          	lbu	s2,0(a1)
 458:	18090f63          	beqz	s2,5f6 <vprintf+0x1c0>
 45c:	8aaa                	mv	s5,a0
 45e:	8b32                	mv	s6,a2
 460:	00158493          	addi	s1,a1,1
  state = 0;
 464:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 466:	02500a13          	li	s4,37
      if(c == 'd'){
 46a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 46e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 472:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 476:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 47a:	00000b97          	auipc	s7,0x0
 47e:	386b8b93          	addi	s7,s7,902 # 800 <digits>
 482:	a839                	j	4a0 <vprintf+0x6a>
        putc(fd, c);
 484:	85ca                	mv	a1,s2
 486:	8556                	mv	a0,s5
 488:	00000097          	auipc	ra,0x0
 48c:	ee2080e7          	jalr	-286(ra) # 36a <putc>
 490:	a019                	j	496 <vprintf+0x60>
    } else if(state == '%'){
 492:	01498f63          	beq	s3,s4,4b0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 496:	0485                	addi	s1,s1,1
 498:	fff4c903          	lbu	s2,-1(s1)
 49c:	14090d63          	beqz	s2,5f6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4a0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4a4:	fe0997e3          	bnez	s3,492 <vprintf+0x5c>
      if(c == '%'){
 4a8:	fd479ee3          	bne	a5,s4,484 <vprintf+0x4e>
        state = '%';
 4ac:	89be                	mv	s3,a5
 4ae:	b7e5                	j	496 <vprintf+0x60>
      if(c == 'd'){
 4b0:	05878063          	beq	a5,s8,4f0 <vprintf+0xba>
      } else if(c == 'l') {
 4b4:	05978c63          	beq	a5,s9,50c <vprintf+0xd6>
      } else if(c == 'x') {
 4b8:	07a78863          	beq	a5,s10,528 <vprintf+0xf2>
      } else if(c == 'p') {
 4bc:	09b78463          	beq	a5,s11,544 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4c0:	07300713          	li	a4,115
 4c4:	0ce78663          	beq	a5,a4,590 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4c8:	06300713          	li	a4,99
 4cc:	0ee78e63          	beq	a5,a4,5c8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4d0:	11478863          	beq	a5,s4,5e0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4d4:	85d2                	mv	a1,s4
 4d6:	8556                	mv	a0,s5
 4d8:	00000097          	auipc	ra,0x0
 4dc:	e92080e7          	jalr	-366(ra) # 36a <putc>
        putc(fd, c);
 4e0:	85ca                	mv	a1,s2
 4e2:	8556                	mv	a0,s5
 4e4:	00000097          	auipc	ra,0x0
 4e8:	e86080e7          	jalr	-378(ra) # 36a <putc>
      }
      state = 0;
 4ec:	4981                	li	s3,0
 4ee:	b765                	j	496 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4f0:	008b0913          	addi	s2,s6,8
 4f4:	4685                	li	a3,1
 4f6:	4629                	li	a2,10
 4f8:	000b2583          	lw	a1,0(s6)
 4fc:	8556                	mv	a0,s5
 4fe:	00000097          	auipc	ra,0x0
 502:	e8e080e7          	jalr	-370(ra) # 38c <printint>
 506:	8b4a                	mv	s6,s2
      state = 0;
 508:	4981                	li	s3,0
 50a:	b771                	j	496 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 50c:	008b0913          	addi	s2,s6,8
 510:	4681                	li	a3,0
 512:	4629                	li	a2,10
 514:	000b2583          	lw	a1,0(s6)
 518:	8556                	mv	a0,s5
 51a:	00000097          	auipc	ra,0x0
 51e:	e72080e7          	jalr	-398(ra) # 38c <printint>
 522:	8b4a                	mv	s6,s2
      state = 0;
 524:	4981                	li	s3,0
 526:	bf85                	j	496 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 528:	008b0913          	addi	s2,s6,8
 52c:	4681                	li	a3,0
 52e:	4641                	li	a2,16
 530:	000b2583          	lw	a1,0(s6)
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e56080e7          	jalr	-426(ra) # 38c <printint>
 53e:	8b4a                	mv	s6,s2
      state = 0;
 540:	4981                	li	s3,0
 542:	bf91                	j	496 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 544:	008b0793          	addi	a5,s6,8
 548:	f8f43423          	sd	a5,-120(s0)
 54c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 550:	03000593          	li	a1,48
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	e14080e7          	jalr	-492(ra) # 36a <putc>
  putc(fd, 'x');
 55e:	85ea                	mv	a1,s10
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e08080e7          	jalr	-504(ra) # 36a <putc>
 56a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56c:	03c9d793          	srli	a5,s3,0x3c
 570:	97de                	add	a5,a5,s7
 572:	0007c583          	lbu	a1,0(a5)
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	df2080e7          	jalr	-526(ra) # 36a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 580:	0992                	slli	s3,s3,0x4
 582:	397d                	addiw	s2,s2,-1
 584:	fe0914e3          	bnez	s2,56c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 588:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 58c:	4981                	li	s3,0
 58e:	b721                	j	496 <vprintf+0x60>
        s = va_arg(ap, char*);
 590:	008b0993          	addi	s3,s6,8
 594:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 598:	02090163          	beqz	s2,5ba <vprintf+0x184>
        while(*s != 0){
 59c:	00094583          	lbu	a1,0(s2)
 5a0:	c9a1                	beqz	a1,5f0 <vprintf+0x1ba>
          putc(fd, *s);
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	dc6080e7          	jalr	-570(ra) # 36a <putc>
          s++;
 5ac:	0905                	addi	s2,s2,1
        while(*s != 0){
 5ae:	00094583          	lbu	a1,0(s2)
 5b2:	f9e5                	bnez	a1,5a2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 5b4:	8b4e                	mv	s6,s3
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	bdf9                	j	496 <vprintf+0x60>
          s = "(null)";
 5ba:	00000917          	auipc	s2,0x0
 5be:	23e90913          	addi	s2,s2,574 # 7f8 <malloc+0xf8>
        while(*s != 0){
 5c2:	02800593          	li	a1,40
 5c6:	bff1                	j	5a2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5c8:	008b0913          	addi	s2,s6,8
 5cc:	000b4583          	lbu	a1,0(s6)
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	d98080e7          	jalr	-616(ra) # 36a <putc>
 5da:	8b4a                	mv	s6,s2
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	bd65                	j	496 <vprintf+0x60>
        putc(fd, c);
 5e0:	85d2                	mv	a1,s4
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	d86080e7          	jalr	-634(ra) # 36a <putc>
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b565                	j	496 <vprintf+0x60>
        s = va_arg(ap, char*);
 5f0:	8b4e                	mv	s6,s3
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b54d                	j	496 <vprintf+0x60>
    }
  }
}
 5f6:	70e6                	ld	ra,120(sp)
 5f8:	7446                	ld	s0,112(sp)
 5fa:	74a6                	ld	s1,104(sp)
 5fc:	7906                	ld	s2,96(sp)
 5fe:	69e6                	ld	s3,88(sp)
 600:	6a46                	ld	s4,80(sp)
 602:	6aa6                	ld	s5,72(sp)
 604:	6b06                	ld	s6,64(sp)
 606:	7be2                	ld	s7,56(sp)
 608:	7c42                	ld	s8,48(sp)
 60a:	7ca2                	ld	s9,40(sp)
 60c:	7d02                	ld	s10,32(sp)
 60e:	6de2                	ld	s11,24(sp)
 610:	6109                	addi	sp,sp,128
 612:	8082                	ret

0000000000000614 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 614:	715d                	addi	sp,sp,-80
 616:	ec06                	sd	ra,24(sp)
 618:	e822                	sd	s0,16(sp)
 61a:	1000                	addi	s0,sp,32
 61c:	e010                	sd	a2,0(s0)
 61e:	e414                	sd	a3,8(s0)
 620:	e818                	sd	a4,16(s0)
 622:	ec1c                	sd	a5,24(s0)
 624:	03043023          	sd	a6,32(s0)
 628:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 62c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 630:	8622                	mv	a2,s0
 632:	00000097          	auipc	ra,0x0
 636:	e04080e7          	jalr	-508(ra) # 436 <vprintf>
}
 63a:	60e2                	ld	ra,24(sp)
 63c:	6442                	ld	s0,16(sp)
 63e:	6161                	addi	sp,sp,80
 640:	8082                	ret

0000000000000642 <printf>:

void
printf(const char *fmt, ...)
{
 642:	711d                	addi	sp,sp,-96
 644:	ec06                	sd	ra,24(sp)
 646:	e822                	sd	s0,16(sp)
 648:	1000                	addi	s0,sp,32
 64a:	e40c                	sd	a1,8(s0)
 64c:	e810                	sd	a2,16(s0)
 64e:	ec14                	sd	a3,24(s0)
 650:	f018                	sd	a4,32(s0)
 652:	f41c                	sd	a5,40(s0)
 654:	03043823          	sd	a6,48(s0)
 658:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 65c:	00840613          	addi	a2,s0,8
 660:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 664:	85aa                	mv	a1,a0
 666:	4505                	li	a0,1
 668:	00000097          	auipc	ra,0x0
 66c:	dce080e7          	jalr	-562(ra) # 436 <vprintf>
}
 670:	60e2                	ld	ra,24(sp)
 672:	6442                	ld	s0,16(sp)
 674:	6125                	addi	sp,sp,96
 676:	8082                	ret

0000000000000678 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 678:	1141                	addi	sp,sp,-16
 67a:	e422                	sd	s0,8(sp)
 67c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 67e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 682:	00001797          	auipc	a5,0x1
 686:	97e7b783          	ld	a5,-1666(a5) # 1000 <freep>
 68a:	a805                	j	6ba <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 68c:	4618                	lw	a4,8(a2)
 68e:	9db9                	addw	a1,a1,a4
 690:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 694:	6398                	ld	a4,0(a5)
 696:	6318                	ld	a4,0(a4)
 698:	fee53823          	sd	a4,-16(a0)
 69c:	a091                	j	6e0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 69e:	ff852703          	lw	a4,-8(a0)
 6a2:	9e39                	addw	a2,a2,a4
 6a4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6a6:	ff053703          	ld	a4,-16(a0)
 6aa:	e398                	sd	a4,0(a5)
 6ac:	a099                	j	6f2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ae:	6398                	ld	a4,0(a5)
 6b0:	00e7e463          	bltu	a5,a4,6b8 <free+0x40>
 6b4:	00e6ea63          	bltu	a3,a4,6c8 <free+0x50>
{
 6b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ba:	fed7fae3          	bgeu	a5,a3,6ae <free+0x36>
 6be:	6398                	ld	a4,0(a5)
 6c0:	00e6e463          	bltu	a3,a4,6c8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c4:	fee7eae3          	bltu	a5,a4,6b8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6c8:	ff852583          	lw	a1,-8(a0)
 6cc:	6390                	ld	a2,0(a5)
 6ce:	02059713          	slli	a4,a1,0x20
 6d2:	9301                	srli	a4,a4,0x20
 6d4:	0712                	slli	a4,a4,0x4
 6d6:	9736                	add	a4,a4,a3
 6d8:	fae60ae3          	beq	a2,a4,68c <free+0x14>
    bp->s.ptr = p->s.ptr;
 6dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e0:	4790                	lw	a2,8(a5)
 6e2:	02061713          	slli	a4,a2,0x20
 6e6:	9301                	srli	a4,a4,0x20
 6e8:	0712                	slli	a4,a4,0x4
 6ea:	973e                	add	a4,a4,a5
 6ec:	fae689e3          	beq	a3,a4,69e <free+0x26>
  } else
    p->s.ptr = bp;
 6f0:	e394                	sd	a3,0(a5)
  freep = p;
 6f2:	00001717          	auipc	a4,0x1
 6f6:	90f73723          	sd	a5,-1778(a4) # 1000 <freep>
}
 6fa:	6422                	ld	s0,8(sp)
 6fc:	0141                	addi	sp,sp,16
 6fe:	8082                	ret

0000000000000700 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 700:	7139                	addi	sp,sp,-64
 702:	fc06                	sd	ra,56(sp)
 704:	f822                	sd	s0,48(sp)
 706:	f426                	sd	s1,40(sp)
 708:	f04a                	sd	s2,32(sp)
 70a:	ec4e                	sd	s3,24(sp)
 70c:	e852                	sd	s4,16(sp)
 70e:	e456                	sd	s5,8(sp)
 710:	e05a                	sd	s6,0(sp)
 712:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 714:	02051493          	slli	s1,a0,0x20
 718:	9081                	srli	s1,s1,0x20
 71a:	04bd                	addi	s1,s1,15
 71c:	8091                	srli	s1,s1,0x4
 71e:	0014899b          	addiw	s3,s1,1
 722:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 724:	00001517          	auipc	a0,0x1
 728:	8dc53503          	ld	a0,-1828(a0) # 1000 <freep>
 72c:	c515                	beqz	a0,758 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 72e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 730:	4798                	lw	a4,8(a5)
 732:	02977f63          	bgeu	a4,s1,770 <malloc+0x70>
 736:	8a4e                	mv	s4,s3
 738:	0009871b          	sext.w	a4,s3
 73c:	6685                	lui	a3,0x1
 73e:	00d77363          	bgeu	a4,a3,744 <malloc+0x44>
 742:	6a05                	lui	s4,0x1
 744:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 748:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 74c:	00001917          	auipc	s2,0x1
 750:	8b490913          	addi	s2,s2,-1868 # 1000 <freep>
  if(p == (char*)-1)
 754:	5afd                	li	s5,-1
 756:	a88d                	j	7c8 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 758:	00001797          	auipc	a5,0x1
 75c:	8b878793          	addi	a5,a5,-1864 # 1010 <base>
 760:	00001717          	auipc	a4,0x1
 764:	8af73023          	sd	a5,-1888(a4) # 1000 <freep>
 768:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 76a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 76e:	b7e1                	j	736 <malloc+0x36>
      if(p->s.size == nunits)
 770:	02e48b63          	beq	s1,a4,7a6 <malloc+0xa6>
        p->s.size -= nunits;
 774:	4137073b          	subw	a4,a4,s3
 778:	c798                	sw	a4,8(a5)
        p += p->s.size;
 77a:	1702                	slli	a4,a4,0x20
 77c:	9301                	srli	a4,a4,0x20
 77e:	0712                	slli	a4,a4,0x4
 780:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 782:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 786:	00001717          	auipc	a4,0x1
 78a:	86a73d23          	sd	a0,-1926(a4) # 1000 <freep>
      return (void*)(p + 1);
 78e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 792:	70e2                	ld	ra,56(sp)
 794:	7442                	ld	s0,48(sp)
 796:	74a2                	ld	s1,40(sp)
 798:	7902                	ld	s2,32(sp)
 79a:	69e2                	ld	s3,24(sp)
 79c:	6a42                	ld	s4,16(sp)
 79e:	6aa2                	ld	s5,8(sp)
 7a0:	6b02                	ld	s6,0(sp)
 7a2:	6121                	addi	sp,sp,64
 7a4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7a6:	6398                	ld	a4,0(a5)
 7a8:	e118                	sd	a4,0(a0)
 7aa:	bff1                	j	786 <malloc+0x86>
  hp->s.size = nu;
 7ac:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b0:	0541                	addi	a0,a0,16
 7b2:	00000097          	auipc	ra,0x0
 7b6:	ec6080e7          	jalr	-314(ra) # 678 <free>
  return freep;
 7ba:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7be:	d971                	beqz	a0,792 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c2:	4798                	lw	a4,8(a5)
 7c4:	fa9776e3          	bgeu	a4,s1,770 <malloc+0x70>
    if(p == freep)
 7c8:	00093703          	ld	a4,0(s2)
 7cc:	853e                	mv	a0,a5
 7ce:	fef719e3          	bne	a4,a5,7c0 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 7d2:	8552                	mv	a0,s4
 7d4:	00000097          	auipc	ra,0x0
 7d8:	b76080e7          	jalr	-1162(ra) # 34a <sbrk>
  if(p == (char*)-1)
 7dc:	fd5518e3          	bne	a0,s5,7ac <malloc+0xac>
        return 0;
 7e0:	4501                	li	a0,0
 7e2:	bf45                	j	792 <malloc+0x92>
