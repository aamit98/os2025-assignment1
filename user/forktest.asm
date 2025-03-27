
user/_forktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:

#define N  1000

void
print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
  write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	1b6080e7          	jalr	438(ra) # 1c2 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	3ec080e7          	jalr	1004(ra) # 408 <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <forktest>:

void
forktest(void)
{
  2e:	1101                	addi	sp,sp,-32
  30:	ec06                	sd	ra,24(sp)
  32:	e822                	sd	s0,16(sp)
  34:	e426                	sd	s1,8(sp)
  36:	e04a                	sd	s2,0(sp)
  38:	1000                	addi	s0,sp,32
  int n, pid;

  print("fork test\n");
  3a:	00000517          	auipc	a0,0x0
  3e:	45650513          	addi	a0,a0,1110 # 490 <memsize+0x8>
  42:	00000097          	auipc	ra,0x0
  46:	fbe080e7          	jalr	-66(ra) # 0 <print>

  for(n=0; n<N; n++){
  4a:	4481                	li	s1,0
  4c:	3e800913          	li	s2,1000
    pid = fork();
  50:	00000097          	auipc	ra,0x0
  54:	390080e7          	jalr	912(ra) # 3e0 <fork>
    if(pid < 0)
  58:	02054f63          	bltz	a0,96 <forktest+0x68>
      break;
    if(pid == 0)
  5c:	c50d                	beqz	a0,86 <forktest+0x58>
  for(n=0; n<N; n++){
  5e:	2485                	addiw	s1,s1,1
  60:	ff2498e3          	bne	s1,s2,50 <forktest+0x22>
      exit(0,"");
  }

  if(n == N){
    print("fork claimed to work N times!\n");
  64:	00000517          	auipc	a0,0x0
  68:	44450513          	addi	a0,a0,1092 # 4a8 <memsize+0x20>
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <print>
    exit(1,"");
  74:	00000597          	auipc	a1,0x0
  78:	42c58593          	addi	a1,a1,1068 # 4a0 <memsize+0x18>
  7c:	4505                	li	a0,1
  7e:	00000097          	auipc	ra,0x0
  82:	36a080e7          	jalr	874(ra) # 3e8 <exit>
      exit(0,"");
  86:	00000597          	auipc	a1,0x0
  8a:	41a58593          	addi	a1,a1,1050 # 4a0 <memsize+0x18>
  8e:	00000097          	auipc	ra,0x0
  92:	35a080e7          	jalr	858(ra) # 3e8 <exit>
  if(n == N){
  96:	3e800793          	li	a5,1000
  9a:	fcf485e3          	beq	s1,a5,64 <forktest+0x36>
  }

  for(; n > 0; n--){
    if(wait(0,"") < 0){
  9e:	00000917          	auipc	s2,0x0
  a2:	40290913          	addi	s2,s2,1026 # 4a0 <memsize+0x18>
  for(; n > 0; n--){
  a6:	00905c63          	blez	s1,be <forktest+0x90>
    if(wait(0,"") < 0){
  aa:	85ca                	mv	a1,s2
  ac:	4501                	li	a0,0
  ae:	00000097          	auipc	ra,0x0
  b2:	342080e7          	jalr	834(ra) # 3f0 <wait>
  b6:	02054e63          	bltz	a0,f2 <forktest+0xc4>
  for(; n > 0; n--){
  ba:	34fd                	addiw	s1,s1,-1
  bc:	f4fd                	bnez	s1,aa <forktest+0x7c>
      print("wait stopped early\n");
      exit(1,"");
    }
  }

  if(wait(0,"") != -1){
  be:	00000597          	auipc	a1,0x0
  c2:	3e258593          	addi	a1,a1,994 # 4a0 <memsize+0x18>
  c6:	4501                	li	a0,0
  c8:	00000097          	auipc	ra,0x0
  cc:	328080e7          	jalr	808(ra) # 3f0 <wait>
  d0:	57fd                	li	a5,-1
  d2:	04f51163          	bne	a0,a5,114 <forktest+0xe6>
    print("wait got too many\n");
    exit(1,"");
  }

  print("fork test OK\n");
  d6:	00000517          	auipc	a0,0x0
  da:	42250513          	addi	a0,a0,1058 # 4f8 <memsize+0x70>
  de:	00000097          	auipc	ra,0x0
  e2:	f22080e7          	jalr	-222(ra) # 0 <print>
}
  e6:	60e2                	ld	ra,24(sp)
  e8:	6442                	ld	s0,16(sp)
  ea:	64a2                	ld	s1,8(sp)
  ec:	6902                	ld	s2,0(sp)
  ee:	6105                	addi	sp,sp,32
  f0:	8082                	ret
      print("wait stopped early\n");
  f2:	00000517          	auipc	a0,0x0
  f6:	3d650513          	addi	a0,a0,982 # 4c8 <memsize+0x40>
  fa:	00000097          	auipc	ra,0x0
  fe:	f06080e7          	jalr	-250(ra) # 0 <print>
      exit(1,"");
 102:	00000597          	auipc	a1,0x0
 106:	39e58593          	addi	a1,a1,926 # 4a0 <memsize+0x18>
 10a:	4505                	li	a0,1
 10c:	00000097          	auipc	ra,0x0
 110:	2dc080e7          	jalr	732(ra) # 3e8 <exit>
    print("wait got too many\n");
 114:	00000517          	auipc	a0,0x0
 118:	3cc50513          	addi	a0,a0,972 # 4e0 <memsize+0x58>
 11c:	00000097          	auipc	ra,0x0
 120:	ee4080e7          	jalr	-284(ra) # 0 <print>
    exit(1,"");
 124:	00000597          	auipc	a1,0x0
 128:	37c58593          	addi	a1,a1,892 # 4a0 <memsize+0x18>
 12c:	4505                	li	a0,1
 12e:	00000097          	auipc	ra,0x0
 132:	2ba080e7          	jalr	698(ra) # 3e8 <exit>

0000000000000136 <main>:

int
main(void)
{
 136:	1141                	addi	sp,sp,-16
 138:	e406                	sd	ra,8(sp)
 13a:	e022                	sd	s0,0(sp)
 13c:	0800                	addi	s0,sp,16
  forktest();
 13e:	00000097          	auipc	ra,0x0
 142:	ef0080e7          	jalr	-272(ra) # 2e <forktest>
  exit(0,"");
 146:	00000597          	auipc	a1,0x0
 14a:	35a58593          	addi	a1,a1,858 # 4a0 <memsize+0x18>
 14e:	4501                	li	a0,0
 150:	00000097          	auipc	ra,0x0
 154:	298080e7          	jalr	664(ra) # 3e8 <exit>

0000000000000158 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 158:	1141                	addi	sp,sp,-16
 15a:	e406                	sd	ra,8(sp)
 15c:	e022                	sd	s0,0(sp)
 15e:	0800                	addi	s0,sp,16
  extern int main();
  main();
 160:	00000097          	auipc	ra,0x0
 164:	fd6080e7          	jalr	-42(ra) # 136 <main>
  exit(0,"");
 168:	00000597          	auipc	a1,0x0
 16c:	33858593          	addi	a1,a1,824 # 4a0 <memsize+0x18>
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	276080e7          	jalr	630(ra) # 3e8 <exit>

000000000000017a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 17a:	1141                	addi	sp,sp,-16
 17c:	e422                	sd	s0,8(sp)
 17e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 180:	87aa                	mv	a5,a0
 182:	0585                	addi	a1,a1,1
 184:	0785                	addi	a5,a5,1
 186:	fff5c703          	lbu	a4,-1(a1)
 18a:	fee78fa3          	sb	a4,-1(a5)
 18e:	fb75                	bnez	a4,182 <strcpy+0x8>
    ;
  return os;
}
 190:	6422                	ld	s0,8(sp)
 192:	0141                	addi	sp,sp,16
 194:	8082                	ret

0000000000000196 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	cb91                	beqz	a5,1b4 <strcmp+0x1e>
 1a2:	0005c703          	lbu	a4,0(a1)
 1a6:	00f71763          	bne	a4,a5,1b4 <strcmp+0x1e>
    p++, q++;
 1aa:	0505                	addi	a0,a0,1
 1ac:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ae:	00054783          	lbu	a5,0(a0)
 1b2:	fbe5                	bnez	a5,1a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1b4:	0005c503          	lbu	a0,0(a1)
}
 1b8:	40a7853b          	subw	a0,a5,a0
 1bc:	6422                	ld	s0,8(sp)
 1be:	0141                	addi	sp,sp,16
 1c0:	8082                	ret

00000000000001c2 <strlen>:

uint
strlen(const char *s)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	cf91                	beqz	a5,1e8 <strlen+0x26>
 1ce:	0505                	addi	a0,a0,1
 1d0:	87aa                	mv	a5,a0
 1d2:	4685                	li	a3,1
 1d4:	9e89                	subw	a3,a3,a0
 1d6:	00f6853b          	addw	a0,a3,a5
 1da:	0785                	addi	a5,a5,1
 1dc:	fff7c703          	lbu	a4,-1(a5)
 1e0:	fb7d                	bnez	a4,1d6 <strlen+0x14>
    ;
  return n;
}
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret
  for(n = 0; s[n]; n++)
 1e8:	4501                	li	a0,0
 1ea:	bfe5                	j	1e2 <strlen+0x20>

00000000000001ec <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f2:	ca19                	beqz	a2,208 <memset+0x1c>
 1f4:	87aa                	mv	a5,a0
 1f6:	1602                	slli	a2,a2,0x20
 1f8:	9201                	srli	a2,a2,0x20
 1fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 202:	0785                	addi	a5,a5,1
 204:	fee79de3          	bne	a5,a4,1fe <memset+0x12>
  }
  return dst;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret

000000000000020e <strchr>:

char*
strchr(const char *s, char c)
{
 20e:	1141                	addi	sp,sp,-16
 210:	e422                	sd	s0,8(sp)
 212:	0800                	addi	s0,sp,16
  for(; *s; s++)
 214:	00054783          	lbu	a5,0(a0)
 218:	cb99                	beqz	a5,22e <strchr+0x20>
    if(*s == c)
 21a:	00f58763          	beq	a1,a5,228 <strchr+0x1a>
  for(; *s; s++)
 21e:	0505                	addi	a0,a0,1
 220:	00054783          	lbu	a5,0(a0)
 224:	fbfd                	bnez	a5,21a <strchr+0xc>
      return (char*)s;
  return 0;
 226:	4501                	li	a0,0
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret
  return 0;
 22e:	4501                	li	a0,0
 230:	bfe5                	j	228 <strchr+0x1a>

0000000000000232 <gets>:

char*
gets(char *buf, int max)
{
 232:	711d                	addi	sp,sp,-96
 234:	ec86                	sd	ra,88(sp)
 236:	e8a2                	sd	s0,80(sp)
 238:	e4a6                	sd	s1,72(sp)
 23a:	e0ca                	sd	s2,64(sp)
 23c:	fc4e                	sd	s3,56(sp)
 23e:	f852                	sd	s4,48(sp)
 240:	f456                	sd	s5,40(sp)
 242:	f05a                	sd	s6,32(sp)
 244:	ec5e                	sd	s7,24(sp)
 246:	1080                	addi	s0,sp,96
 248:	8baa                	mv	s7,a0
 24a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 24c:	892a                	mv	s2,a0
 24e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 250:	4aa9                	li	s5,10
 252:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 254:	89a6                	mv	s3,s1
 256:	2485                	addiw	s1,s1,1
 258:	0344d863          	bge	s1,s4,288 <gets+0x56>
    cc = read(0, &c, 1);
 25c:	4605                	li	a2,1
 25e:	faf40593          	addi	a1,s0,-81
 262:	4501                	li	a0,0
 264:	00000097          	auipc	ra,0x0
 268:	19c080e7          	jalr	412(ra) # 400 <read>
    if(cc < 1)
 26c:	00a05e63          	blez	a0,288 <gets+0x56>
    buf[i++] = c;
 270:	faf44783          	lbu	a5,-81(s0)
 274:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 278:	01578763          	beq	a5,s5,286 <gets+0x54>
 27c:	0905                	addi	s2,s2,1
 27e:	fd679be3          	bne	a5,s6,254 <gets+0x22>
  for(i=0; i+1 < max; ){
 282:	89a6                	mv	s3,s1
 284:	a011                	j	288 <gets+0x56>
 286:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 288:	99de                	add	s3,s3,s7
 28a:	00098023          	sb	zero,0(s3)
  return buf;
}
 28e:	855e                	mv	a0,s7
 290:	60e6                	ld	ra,88(sp)
 292:	6446                	ld	s0,80(sp)
 294:	64a6                	ld	s1,72(sp)
 296:	6906                	ld	s2,64(sp)
 298:	79e2                	ld	s3,56(sp)
 29a:	7a42                	ld	s4,48(sp)
 29c:	7aa2                	ld	s5,40(sp)
 29e:	7b02                	ld	s6,32(sp)
 2a0:	6be2                	ld	s7,24(sp)
 2a2:	6125                	addi	sp,sp,96
 2a4:	8082                	ret

00000000000002a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2a6:	1101                	addi	sp,sp,-32
 2a8:	ec06                	sd	ra,24(sp)
 2aa:	e822                	sd	s0,16(sp)
 2ac:	e426                	sd	s1,8(sp)
 2ae:	e04a                	sd	s2,0(sp)
 2b0:	1000                	addi	s0,sp,32
 2b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b4:	4581                	li	a1,0
 2b6:	00000097          	auipc	ra,0x0
 2ba:	172080e7          	jalr	370(ra) # 428 <open>
  if(fd < 0)
 2be:	02054563          	bltz	a0,2e8 <stat+0x42>
 2c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c4:	85ca                	mv	a1,s2
 2c6:	00000097          	auipc	ra,0x0
 2ca:	17a080e7          	jalr	378(ra) # 440 <fstat>
 2ce:	892a                	mv	s2,a0
  close(fd);
 2d0:	8526                	mv	a0,s1
 2d2:	00000097          	auipc	ra,0x0
 2d6:	13e080e7          	jalr	318(ra) # 410 <close>
  return r;
}
 2da:	854a                	mv	a0,s2
 2dc:	60e2                	ld	ra,24(sp)
 2de:	6442                	ld	s0,16(sp)
 2e0:	64a2                	ld	s1,8(sp)
 2e2:	6902                	ld	s2,0(sp)
 2e4:	6105                	addi	sp,sp,32
 2e6:	8082                	ret
    return -1;
 2e8:	597d                	li	s2,-1
 2ea:	bfc5                	j	2da <stat+0x34>

00000000000002ec <atoi>:

int
atoi(const char *s)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f2:	00054603          	lbu	a2,0(a0)
 2f6:	fd06079b          	addiw	a5,a2,-48
 2fa:	0ff7f793          	andi	a5,a5,255
 2fe:	4725                	li	a4,9
 300:	02f76963          	bltu	a4,a5,332 <atoi+0x46>
 304:	86aa                	mv	a3,a0
  n = 0;
 306:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 308:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 30a:	0685                	addi	a3,a3,1
 30c:	0025179b          	slliw	a5,a0,0x2
 310:	9fa9                	addw	a5,a5,a0
 312:	0017979b          	slliw	a5,a5,0x1
 316:	9fb1                	addw	a5,a5,a2
 318:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 31c:	0006c603          	lbu	a2,0(a3)
 320:	fd06071b          	addiw	a4,a2,-48
 324:	0ff77713          	andi	a4,a4,255
 328:	fee5f1e3          	bgeu	a1,a4,30a <atoi+0x1e>
  return n;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret
  n = 0;
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <atoi+0x40>

0000000000000336 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 336:	1141                	addi	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 33c:	02b57463          	bgeu	a0,a1,364 <memmove+0x2e>
    while(n-- > 0)
 340:	00c05f63          	blez	a2,35e <memmove+0x28>
 344:	1602                	slli	a2,a2,0x20
 346:	9201                	srli	a2,a2,0x20
 348:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 34c:	872a                	mv	a4,a0
      *dst++ = *src++;
 34e:	0585                	addi	a1,a1,1
 350:	0705                	addi	a4,a4,1
 352:	fff5c683          	lbu	a3,-1(a1)
 356:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35a:	fee79ae3          	bne	a5,a4,34e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
    dst += n;
 364:	00c50733          	add	a4,a0,a2
    src += n;
 368:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36a:	fec05ae3          	blez	a2,35e <memmove+0x28>
 36e:	fff6079b          	addiw	a5,a2,-1
 372:	1782                	slli	a5,a5,0x20
 374:	9381                	srli	a5,a5,0x20
 376:	fff7c793          	not	a5,a5
 37a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 37c:	15fd                	addi	a1,a1,-1
 37e:	177d                	addi	a4,a4,-1
 380:	0005c683          	lbu	a3,0(a1)
 384:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 388:	fee79ae3          	bne	a5,a4,37c <memmove+0x46>
 38c:	bfc9                	j	35e <memmove+0x28>

000000000000038e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 38e:	1141                	addi	sp,sp,-16
 390:	e422                	sd	s0,8(sp)
 392:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 394:	ca05                	beqz	a2,3c4 <memcmp+0x36>
 396:	fff6069b          	addiw	a3,a2,-1
 39a:	1682                	slli	a3,a3,0x20
 39c:	9281                	srli	a3,a3,0x20
 39e:	0685                	addi	a3,a3,1
 3a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a2:	00054783          	lbu	a5,0(a0)
 3a6:	0005c703          	lbu	a4,0(a1)
 3aa:	00e79863          	bne	a5,a4,3ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ae:	0505                	addi	a0,a0,1
    p2++;
 3b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3b2:	fed518e3          	bne	a0,a3,3a2 <memcmp+0x14>
  }
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	a019                	j	3be <memcmp+0x30>
      return *p1 - *p2;
 3ba:	40e7853b          	subw	a0,a5,a4
}
 3be:	6422                	ld	s0,8(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret
  return 0;
 3c4:	4501                	li	a0,0
 3c6:	bfe5                	j	3be <memcmp+0x30>

00000000000003c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3c8:	1141                	addi	sp,sp,-16
 3ca:	e406                	sd	ra,8(sp)
 3cc:	e022                	sd	s0,0(sp)
 3ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3d0:	00000097          	auipc	ra,0x0
 3d4:	f66080e7          	jalr	-154(ra) # 336 <memmove>
}
 3d8:	60a2                	ld	ra,8(sp)
 3da:	6402                	ld	s0,0(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret

00000000000003e0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e0:	4885                	li	a7,1
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3e8:	4889                	li	a7,2
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f0:	488d                	li	a7,3
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3f8:	4891                	li	a7,4
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <read>:
.global read
read:
 li a7, SYS_read
 400:	4895                	li	a7,5
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <write>:
.global write
write:
 li a7, SYS_write
 408:	48c1                	li	a7,16
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <close>:
.global close
close:
 li a7, SYS_close
 410:	48d5                	li	a7,21
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <kill>:
.global kill
kill:
 li a7, SYS_kill
 418:	4899                	li	a7,6
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <exec>:
.global exec
exec:
 li a7, SYS_exec
 420:	489d                	li	a7,7
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <open>:
.global open
open:
 li a7, SYS_open
 428:	48bd                	li	a7,15
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 430:	48c5                	li	a7,17
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 438:	48c9                	li	a7,18
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 440:	48a1                	li	a7,8
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <link>:
.global link
link:
 li a7, SYS_link
 448:	48cd                	li	a7,19
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 450:	48d1                	li	a7,20
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 458:	48a5                	li	a7,9
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <dup>:
.global dup
dup:
 li a7, SYS_dup
 460:	48a9                	li	a7,10
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 468:	48ad                	li	a7,11
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 470:	48b1                	li	a7,12
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 478:	48b5                	li	a7,13
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 480:	48b9                	li	a7,14
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
 488:	48d9                	li	a7,22
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret
