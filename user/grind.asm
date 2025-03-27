
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	addi	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	addi	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	e8ca                	sd	s2,80(sp)
      82:	e4ce                	sd	s3,72(sp)
      84:	e0d2                	sd	s4,64(sp)
      86:	fc56                	sd	s5,56(sp)
      88:	f85a                	sd	s6,48(sp)
      8a:	1880                	addi	s0,sp,112
      8c:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8e:	4501                	li	a0,0
      90:	00001097          	auipc	ra,0x1
      94:	000080e7          	jalr	ra # 1090 <sbrk>
      98:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      9a:	00001517          	auipc	a0,0x1
      9e:	49650513          	addi	a0,a0,1174 # 1530 <malloc+0xea>
      a2:	00001097          	auipc	ra,0x1
      a6:	fce080e7          	jalr	-50(ra) # 1070 <mkdir>
  if(chdir("grindir") != 0){
      aa:	00001517          	auipc	a0,0x1
      ae:	48650513          	addi	a0,a0,1158 # 1530 <malloc+0xea>
      b2:	00001097          	auipc	ra,0x1
      b6:	fc6080e7          	jalr	-58(ra) # 1078 <chdir>
      ba:	c115                	beqz	a0,de <go+0x66>
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	47c50513          	addi	a0,a0,1148 # 1538 <malloc+0xf2>
      c4:	00001097          	auipc	ra,0x1
      c8:	2c4080e7          	jalr	708(ra) # 1388 <printf>
    exit(1,"");
      cc:	00001597          	auipc	a1,0x1
      d0:	5fc58593          	addi	a1,a1,1532 # 16c8 <malloc+0x282>
      d4:	4505                	li	a0,1
      d6:	00001097          	auipc	ra,0x1
      da:	f32080e7          	jalr	-206(ra) # 1008 <exit>
  }
  chdir("/");
      de:	00001517          	auipc	a0,0x1
      e2:	47a50513          	addi	a0,a0,1146 # 1558 <malloc+0x112>
      e6:	00001097          	auipc	ra,0x1
      ea:	f92080e7          	jalr	-110(ra) # 1078 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      ee:	00001997          	auipc	s3,0x1
      f2:	47a98993          	addi	s3,s3,1146 # 1568 <malloc+0x122>
      f6:	c489                	beqz	s1,100 <go+0x88>
      f8:	00001997          	auipc	s3,0x1
      fc:	46898993          	addi	s3,s3,1128 # 1560 <malloc+0x11a>
    iters++;
     100:	4485                	li	s1,1
  int fd = -1;
     102:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     104:	00002a17          	auipc	s4,0x2
     108:	f1ca0a13          	addi	s4,s4,-228 # 2020 <buf.0>
     10c:	a825                	j	144 <go+0xcc>
      close(open("grindir/../a", O_CREATE|O_RDWR));
     10e:	20200593          	li	a1,514
     112:	00001517          	auipc	a0,0x1
     116:	45e50513          	addi	a0,a0,1118 # 1570 <malloc+0x12a>
     11a:	00001097          	auipc	ra,0x1
     11e:	f2e080e7          	jalr	-210(ra) # 1048 <open>
     122:	00001097          	auipc	ra,0x1
     126:	f0e080e7          	jalr	-242(ra) # 1030 <close>
    iters++;
     12a:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     12c:	1f400793          	li	a5,500
     130:	02f4f7b3          	remu	a5,s1,a5
     134:	eb81                	bnez	a5,144 <go+0xcc>
      write(1, which_child?"B":"A", 1);
     136:	4605                	li	a2,1
     138:	85ce                	mv	a1,s3
     13a:	4505                	li	a0,1
     13c:	00001097          	auipc	ra,0x1
     140:	eec080e7          	jalr	-276(ra) # 1028 <write>
    int what = rand() % 23;
     144:	00000097          	auipc	ra,0x0
     148:	f14080e7          	jalr	-236(ra) # 58 <rand>
     14c:	47dd                	li	a5,23
     14e:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     152:	4785                	li	a5,1
     154:	faf50de3          	beq	a0,a5,10e <go+0x96>
    } else if(what == 2){
     158:	4789                	li	a5,2
     15a:	1af50163          	beq	a0,a5,2fc <go+0x284>
    } else if(what == 3){
     15e:	478d                	li	a5,3
     160:	1af50d63          	beq	a0,a5,31a <go+0x2a2>
    } else if(what == 4){
     164:	4791                	li	a5,4
     166:	1cf50363          	beq	a0,a5,32c <go+0x2b4>
    } else if(what == 5){
     16a:	4795                	li	a5,5
     16c:	20f50b63          	beq	a0,a5,382 <go+0x30a>
    } else if(what == 6){
     170:	4799                	li	a5,6
     172:	22f50963          	beq	a0,a5,3a4 <go+0x32c>
    } else if(what == 7){
     176:	479d                	li	a5,7
     178:	24f50763          	beq	a0,a5,3c6 <go+0x34e>
    } else if(what == 8){
     17c:	47a1                	li	a5,8
     17e:	24f50d63          	beq	a0,a5,3d8 <go+0x360>
    } else if(what == 9){
     182:	47a5                	li	a5,9
     184:	26f50363          	beq	a0,a5,3ea <go+0x372>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     188:	47a9                	li	a5,10
     18a:	28f50f63          	beq	a0,a5,428 <go+0x3b0>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     18e:	47ad                	li	a5,11
     190:	2cf50b63          	beq	a0,a5,466 <go+0x3ee>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     194:	47b1                	li	a5,12
     196:	2ef50d63          	beq	a0,a5,490 <go+0x418>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     19a:	47b5                	li	a5,13
     19c:	30f50f63          	beq	a0,a5,4ba <go+0x442>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1,"");
      }
      wait(0,"");
    } else if(what == 14){
     1a0:	47b9                	li	a5,14
     1a2:	36f50663          	beq	a0,a5,50e <go+0x496>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1,"");
      }
      wait(0,"");
    } else if(what == 15){
     1a6:	47bd                	li	a5,15
     1a8:	3cf50663          	beq	a0,a5,574 <go+0x4fc>
      sbrk(6011);
    } else if(what == 16){
     1ac:	47c1                	li	a5,16
     1ae:	3cf50b63          	beq	a0,a5,584 <go+0x50c>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     1b2:	47c5                	li	a5,17
     1b4:	3ef50b63          	beq	a0,a5,5aa <go+0x532>
        printf("grind: chdir failed\n");
        exit(1,"");
      }
      kill(pid);
      wait(0,"");
    } else if(what == 18){
     1b8:	47c9                	li	a5,18
     1ba:	4af50163          	beq	a0,a5,65c <go+0x5e4>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1,"");
      }
      wait(0,"");
    } else if(what == 19){
     1be:	47cd                	li	a5,19
     1c0:	50f50163          	beq	a0,a5,6c2 <go+0x64a>
        exit(1,"");
      }
      close(fds[0]);
      close(fds[1]);
      wait(0,"");
    } else if(what == 20){
     1c4:	47d1                	li	a5,20
     1c6:	60f50263          	beq	a0,a5,7ca <go+0x752>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1,"");
      }
      wait(0,"");
    } else if(what == 21){
     1ca:	47d5                	li	a5,21
     1cc:	6af50c63          	beq	a0,a5,884 <go+0x80c>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1,"");
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     1d0:	47d9                	li	a5,22
     1d2:	f4f51ce3          	bne	a0,a5,12a <go+0xb2>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1d6:	f9840513          	addi	a0,s0,-104
     1da:	00001097          	auipc	ra,0x1
     1de:	e3e080e7          	jalr	-450(ra) # 1018 <pipe>
     1e2:	7c054963          	bltz	a0,9b4 <go+0x93c>
        fprintf(2, "grind: pipe failed\n");
        exit(1,"");
      }
      if(pipe(bb) < 0){
     1e6:	fa040513          	addi	a0,s0,-96
     1ea:	00001097          	auipc	ra,0x1
     1ee:	e2e080e7          	jalr	-466(ra) # 1018 <pipe>
     1f2:	7e054363          	bltz	a0,9d8 <go+0x960>
        fprintf(2, "grind: pipe failed\n");
        exit(1,"");
      }
      int pid1 = fork();
     1f6:	00001097          	auipc	ra,0x1
     1fa:	e0a080e7          	jalr	-502(ra) # 1000 <fork>
      if(pid1 == 0){
     1fe:	7e050f63          	beqz	a0,9fc <go+0x984>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2,"");
      } else if(pid1 < 0){
     202:	0a054fe3          	bltz	a0,ac0 <go+0xa48>
        fprintf(2, "grind: fork failed\n");
        exit(3,"");
      }
      int pid2 = fork();
     206:	00001097          	auipc	ra,0x1
     20a:	dfa080e7          	jalr	-518(ra) # 1000 <fork>
      if(pid2 == 0){
     20e:	0c050be3          	beqz	a0,ae4 <go+0xa6c>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6,"");
      } else if(pid2 < 0){
     212:	1c0543e3          	bltz	a0,bd8 <go+0xb60>
        fprintf(2, "grind: fork failed\n");
        exit(7,"");
      }
      close(aa[0]);
     216:	f9842503          	lw	a0,-104(s0)
     21a:	00001097          	auipc	ra,0x1
     21e:	e16080e7          	jalr	-490(ra) # 1030 <close>
      close(aa[1]);
     222:	f9c42503          	lw	a0,-100(s0)
     226:	00001097          	auipc	ra,0x1
     22a:	e0a080e7          	jalr	-502(ra) # 1030 <close>
      close(bb[1]);
     22e:	fa442503          	lw	a0,-92(s0)
     232:	00001097          	auipc	ra,0x1
     236:	dfe080e7          	jalr	-514(ra) # 1030 <close>
      char buf[4] = { 0, 0, 0, 0 };
     23a:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     23e:	4605                	li	a2,1
     240:	f9040593          	addi	a1,s0,-112
     244:	fa042503          	lw	a0,-96(s0)
     248:	00001097          	auipc	ra,0x1
     24c:	dd8080e7          	jalr	-552(ra) # 1020 <read>
      read(bb[0], buf+1, 1);
     250:	4605                	li	a2,1
     252:	f9140593          	addi	a1,s0,-111
     256:	fa042503          	lw	a0,-96(s0)
     25a:	00001097          	auipc	ra,0x1
     25e:	dc6080e7          	jalr	-570(ra) # 1020 <read>
      read(bb[0], buf+2, 1);
     262:	4605                	li	a2,1
     264:	f9240593          	addi	a1,s0,-110
     268:	fa042503          	lw	a0,-96(s0)
     26c:	00001097          	auipc	ra,0x1
     270:	db4080e7          	jalr	-588(ra) # 1020 <read>
      close(bb[0]);
     274:	fa042503          	lw	a0,-96(s0)
     278:	00001097          	auipc	ra,0x1
     27c:	db8080e7          	jalr	-584(ra) # 1030 <close>
      int st1, st2;
      wait(&st1,"");
     280:	00001597          	auipc	a1,0x1
     284:	44858593          	addi	a1,a1,1096 # 16c8 <malloc+0x282>
     288:	f9440513          	addi	a0,s0,-108
     28c:	00001097          	auipc	ra,0x1
     290:	d84080e7          	jalr	-636(ra) # 1010 <wait>
      wait(&st2,"");
     294:	00001597          	auipc	a1,0x1
     298:	43458593          	addi	a1,a1,1076 # 16c8 <malloc+0x282>
     29c:	fa840513          	addi	a0,s0,-88
     2a0:	00001097          	auipc	ra,0x1
     2a4:	d70080e7          	jalr	-656(ra) # 1010 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     2a8:	f9442783          	lw	a5,-108(s0)
     2ac:	fa842703          	lw	a4,-88(s0)
     2b0:	8fd9                	or	a5,a5,a4
     2b2:	2781                	sext.w	a5,a5
     2b4:	ef89                	bnez	a5,2ce <go+0x256>
     2b6:	00001597          	auipc	a1,0x1
     2ba:	53258593          	addi	a1,a1,1330 # 17e8 <malloc+0x3a2>
     2be:	f9040513          	addi	a0,s0,-112
     2c2:	00001097          	auipc	ra,0x1
     2c6:	af4080e7          	jalr	-1292(ra) # db6 <strcmp>
     2ca:	e60500e3          	beqz	a0,12a <go+0xb2>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     2ce:	f9040693          	addi	a3,s0,-112
     2d2:	fa842603          	lw	a2,-88(s0)
     2d6:	f9442583          	lw	a1,-108(s0)
     2da:	00001517          	auipc	a0,0x1
     2de:	51650513          	addi	a0,a0,1302 # 17f0 <malloc+0x3aa>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	0a6080e7          	jalr	166(ra) # 1388 <printf>
        exit(1,"");
     2ea:	00001597          	auipc	a1,0x1
     2ee:	3de58593          	addi	a1,a1,990 # 16c8 <malloc+0x282>
     2f2:	4505                	li	a0,1
     2f4:	00001097          	auipc	ra,0x1
     2f8:	d14080e7          	jalr	-748(ra) # 1008 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     2fc:	20200593          	li	a1,514
     300:	00001517          	auipc	a0,0x1
     304:	28050513          	addi	a0,a0,640 # 1580 <malloc+0x13a>
     308:	00001097          	auipc	ra,0x1
     30c:	d40080e7          	jalr	-704(ra) # 1048 <open>
     310:	00001097          	auipc	ra,0x1
     314:	d20080e7          	jalr	-736(ra) # 1030 <close>
     318:	bd09                	j	12a <go+0xb2>
      unlink("grindir/../a");
     31a:	00001517          	auipc	a0,0x1
     31e:	25650513          	addi	a0,a0,598 # 1570 <malloc+0x12a>
     322:	00001097          	auipc	ra,0x1
     326:	d36080e7          	jalr	-714(ra) # 1058 <unlink>
     32a:	b501                	j	12a <go+0xb2>
      if(chdir("grindir") != 0){
     32c:	00001517          	auipc	a0,0x1
     330:	20450513          	addi	a0,a0,516 # 1530 <malloc+0xea>
     334:	00001097          	auipc	ra,0x1
     338:	d44080e7          	jalr	-700(ra) # 1078 <chdir>
     33c:	e115                	bnez	a0,360 <go+0x2e8>
      unlink("../b");
     33e:	00001517          	auipc	a0,0x1
     342:	25a50513          	addi	a0,a0,602 # 1598 <malloc+0x152>
     346:	00001097          	auipc	ra,0x1
     34a:	d12080e7          	jalr	-750(ra) # 1058 <unlink>
      chdir("/");
     34e:	00001517          	auipc	a0,0x1
     352:	20a50513          	addi	a0,a0,522 # 1558 <malloc+0x112>
     356:	00001097          	auipc	ra,0x1
     35a:	d22080e7          	jalr	-734(ra) # 1078 <chdir>
     35e:	b3f1                	j	12a <go+0xb2>
        printf("grind: chdir grindir failed\n");
     360:	00001517          	auipc	a0,0x1
     364:	1d850513          	addi	a0,a0,472 # 1538 <malloc+0xf2>
     368:	00001097          	auipc	ra,0x1
     36c:	020080e7          	jalr	32(ra) # 1388 <printf>
        exit(1,"");
     370:	00001597          	auipc	a1,0x1
     374:	35858593          	addi	a1,a1,856 # 16c8 <malloc+0x282>
     378:	4505                	li	a0,1
     37a:	00001097          	auipc	ra,0x1
     37e:	c8e080e7          	jalr	-882(ra) # 1008 <exit>
      close(fd);
     382:	854a                	mv	a0,s2
     384:	00001097          	auipc	ra,0x1
     388:	cac080e7          	jalr	-852(ra) # 1030 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     38c:	20200593          	li	a1,514
     390:	00001517          	auipc	a0,0x1
     394:	21050513          	addi	a0,a0,528 # 15a0 <malloc+0x15a>
     398:	00001097          	auipc	ra,0x1
     39c:	cb0080e7          	jalr	-848(ra) # 1048 <open>
     3a0:	892a                	mv	s2,a0
     3a2:	b361                	j	12a <go+0xb2>
      close(fd);
     3a4:	854a                	mv	a0,s2
     3a6:	00001097          	auipc	ra,0x1
     3aa:	c8a080e7          	jalr	-886(ra) # 1030 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     3ae:	20200593          	li	a1,514
     3b2:	00001517          	auipc	a0,0x1
     3b6:	1fe50513          	addi	a0,a0,510 # 15b0 <malloc+0x16a>
     3ba:	00001097          	auipc	ra,0x1
     3be:	c8e080e7          	jalr	-882(ra) # 1048 <open>
     3c2:	892a                	mv	s2,a0
     3c4:	b39d                	j	12a <go+0xb2>
      write(fd, buf, sizeof(buf));
     3c6:	3e700613          	li	a2,999
     3ca:	85d2                	mv	a1,s4
     3cc:	854a                	mv	a0,s2
     3ce:	00001097          	auipc	ra,0x1
     3d2:	c5a080e7          	jalr	-934(ra) # 1028 <write>
     3d6:	bb91                	j	12a <go+0xb2>
      read(fd, buf, sizeof(buf));
     3d8:	3e700613          	li	a2,999
     3dc:	85d2                	mv	a1,s4
     3de:	854a                	mv	a0,s2
     3e0:	00001097          	auipc	ra,0x1
     3e4:	c40080e7          	jalr	-960(ra) # 1020 <read>
     3e8:	b389                	j	12a <go+0xb2>
      mkdir("grindir/../a");
     3ea:	00001517          	auipc	a0,0x1
     3ee:	18650513          	addi	a0,a0,390 # 1570 <malloc+0x12a>
     3f2:	00001097          	auipc	ra,0x1
     3f6:	c7e080e7          	jalr	-898(ra) # 1070 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     3fa:	20200593          	li	a1,514
     3fe:	00001517          	auipc	a0,0x1
     402:	1ca50513          	addi	a0,a0,458 # 15c8 <malloc+0x182>
     406:	00001097          	auipc	ra,0x1
     40a:	c42080e7          	jalr	-958(ra) # 1048 <open>
     40e:	00001097          	auipc	ra,0x1
     412:	c22080e7          	jalr	-990(ra) # 1030 <close>
      unlink("a/a");
     416:	00001517          	auipc	a0,0x1
     41a:	1c250513          	addi	a0,a0,450 # 15d8 <malloc+0x192>
     41e:	00001097          	auipc	ra,0x1
     422:	c3a080e7          	jalr	-966(ra) # 1058 <unlink>
     426:	b311                	j	12a <go+0xb2>
      mkdir("/../b");
     428:	00001517          	auipc	a0,0x1
     42c:	1b850513          	addi	a0,a0,440 # 15e0 <malloc+0x19a>
     430:	00001097          	auipc	ra,0x1
     434:	c40080e7          	jalr	-960(ra) # 1070 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     438:	20200593          	li	a1,514
     43c:	00001517          	auipc	a0,0x1
     440:	1ac50513          	addi	a0,a0,428 # 15e8 <malloc+0x1a2>
     444:	00001097          	auipc	ra,0x1
     448:	c04080e7          	jalr	-1020(ra) # 1048 <open>
     44c:	00001097          	auipc	ra,0x1
     450:	be4080e7          	jalr	-1052(ra) # 1030 <close>
      unlink("b/b");
     454:	00001517          	auipc	a0,0x1
     458:	1a450513          	addi	a0,a0,420 # 15f8 <malloc+0x1b2>
     45c:	00001097          	auipc	ra,0x1
     460:	bfc080e7          	jalr	-1028(ra) # 1058 <unlink>
     464:	b1d9                	j	12a <go+0xb2>
      unlink("b");
     466:	00001517          	auipc	a0,0x1
     46a:	15a50513          	addi	a0,a0,346 # 15c0 <malloc+0x17a>
     46e:	00001097          	auipc	ra,0x1
     472:	bea080e7          	jalr	-1046(ra) # 1058 <unlink>
      link("../grindir/./../a", "../b");
     476:	00001597          	auipc	a1,0x1
     47a:	12258593          	addi	a1,a1,290 # 1598 <malloc+0x152>
     47e:	00001517          	auipc	a0,0x1
     482:	18250513          	addi	a0,a0,386 # 1600 <malloc+0x1ba>
     486:	00001097          	auipc	ra,0x1
     48a:	be2080e7          	jalr	-1054(ra) # 1068 <link>
     48e:	b971                	j	12a <go+0xb2>
      unlink("../grindir/../a");
     490:	00001517          	auipc	a0,0x1
     494:	18850513          	addi	a0,a0,392 # 1618 <malloc+0x1d2>
     498:	00001097          	auipc	ra,0x1
     49c:	bc0080e7          	jalr	-1088(ra) # 1058 <unlink>
      link(".././b", "/grindir/../a");
     4a0:	00001597          	auipc	a1,0x1
     4a4:	10058593          	addi	a1,a1,256 # 15a0 <malloc+0x15a>
     4a8:	00001517          	auipc	a0,0x1
     4ac:	18050513          	addi	a0,a0,384 # 1628 <malloc+0x1e2>
     4b0:	00001097          	auipc	ra,0x1
     4b4:	bb8080e7          	jalr	-1096(ra) # 1068 <link>
     4b8:	b98d                	j	12a <go+0xb2>
      int pid = fork();
     4ba:	00001097          	auipc	ra,0x1
     4be:	b46080e7          	jalr	-1210(ra) # 1000 <fork>
      if(pid == 0){
     4c2:	cd09                	beqz	a0,4dc <go+0x464>
      } else if(pid < 0){
     4c4:	02054463          	bltz	a0,4ec <go+0x474>
      wait(0,"");
     4c8:	00001597          	auipc	a1,0x1
     4cc:	20058593          	addi	a1,a1,512 # 16c8 <malloc+0x282>
     4d0:	4501                	li	a0,0
     4d2:	00001097          	auipc	ra,0x1
     4d6:	b3e080e7          	jalr	-1218(ra) # 1010 <wait>
     4da:	b981                	j	12a <go+0xb2>
        exit(0,"");
     4dc:	00001597          	auipc	a1,0x1
     4e0:	1ec58593          	addi	a1,a1,492 # 16c8 <malloc+0x282>
     4e4:	00001097          	auipc	ra,0x1
     4e8:	b24080e7          	jalr	-1244(ra) # 1008 <exit>
        printf("grind: fork failed\n");
     4ec:	00001517          	auipc	a0,0x1
     4f0:	14450513          	addi	a0,a0,324 # 1630 <malloc+0x1ea>
     4f4:	00001097          	auipc	ra,0x1
     4f8:	e94080e7          	jalr	-364(ra) # 1388 <printf>
        exit(1,"");
     4fc:	00001597          	auipc	a1,0x1
     500:	1cc58593          	addi	a1,a1,460 # 16c8 <malloc+0x282>
     504:	4505                	li	a0,1
     506:	00001097          	auipc	ra,0x1
     50a:	b02080e7          	jalr	-1278(ra) # 1008 <exit>
      int pid = fork();
     50e:	00001097          	auipc	ra,0x1
     512:	af2080e7          	jalr	-1294(ra) # 1000 <fork>
      if(pid == 0){
     516:	cd09                	beqz	a0,530 <go+0x4b8>
      } else if(pid < 0){
     518:	02054d63          	bltz	a0,552 <go+0x4da>
      wait(0,"");
     51c:	00001597          	auipc	a1,0x1
     520:	1ac58593          	addi	a1,a1,428 # 16c8 <malloc+0x282>
     524:	4501                	li	a0,0
     526:	00001097          	auipc	ra,0x1
     52a:	aea080e7          	jalr	-1302(ra) # 1010 <wait>
     52e:	bef5                	j	12a <go+0xb2>
        fork();
     530:	00001097          	auipc	ra,0x1
     534:	ad0080e7          	jalr	-1328(ra) # 1000 <fork>
        fork();
     538:	00001097          	auipc	ra,0x1
     53c:	ac8080e7          	jalr	-1336(ra) # 1000 <fork>
        exit(0,"");
     540:	00001597          	auipc	a1,0x1
     544:	18858593          	addi	a1,a1,392 # 16c8 <malloc+0x282>
     548:	4501                	li	a0,0
     54a:	00001097          	auipc	ra,0x1
     54e:	abe080e7          	jalr	-1346(ra) # 1008 <exit>
        printf("grind: fork failed\n");
     552:	00001517          	auipc	a0,0x1
     556:	0de50513          	addi	a0,a0,222 # 1630 <malloc+0x1ea>
     55a:	00001097          	auipc	ra,0x1
     55e:	e2e080e7          	jalr	-466(ra) # 1388 <printf>
        exit(1,"");
     562:	00001597          	auipc	a1,0x1
     566:	16658593          	addi	a1,a1,358 # 16c8 <malloc+0x282>
     56a:	4505                	li	a0,1
     56c:	00001097          	auipc	ra,0x1
     570:	a9c080e7          	jalr	-1380(ra) # 1008 <exit>
      sbrk(6011);
     574:	6505                	lui	a0,0x1
     576:	77b50513          	addi	a0,a0,1915 # 177b <malloc+0x335>
     57a:	00001097          	auipc	ra,0x1
     57e:	b16080e7          	jalr	-1258(ra) # 1090 <sbrk>
     582:	b665                	j	12a <go+0xb2>
      if(sbrk(0) > break0)
     584:	4501                	li	a0,0
     586:	00001097          	auipc	ra,0x1
     58a:	b0a080e7          	jalr	-1270(ra) # 1090 <sbrk>
     58e:	b8aafee3          	bgeu	s5,a0,12a <go+0xb2>
        sbrk(-(sbrk(0) - break0));
     592:	4501                	li	a0,0
     594:	00001097          	auipc	ra,0x1
     598:	afc080e7          	jalr	-1284(ra) # 1090 <sbrk>
     59c:	40aa853b          	subw	a0,s5,a0
     5a0:	00001097          	auipc	ra,0x1
     5a4:	af0080e7          	jalr	-1296(ra) # 1090 <sbrk>
     5a8:	b649                	j	12a <go+0xb2>
      int pid = fork();
     5aa:	00001097          	auipc	ra,0x1
     5ae:	a56080e7          	jalr	-1450(ra) # 1000 <fork>
     5b2:	8b2a                	mv	s6,a0
      if(pid == 0){
     5b4:	c91d                	beqz	a0,5ea <go+0x572>
      } else if(pid < 0){
     5b6:	06054163          	bltz	a0,618 <go+0x5a0>
      if(chdir("../grindir/..") != 0){
     5ba:	00001517          	auipc	a0,0x1
     5be:	08e50513          	addi	a0,a0,142 # 1648 <malloc+0x202>
     5c2:	00001097          	auipc	ra,0x1
     5c6:	ab6080e7          	jalr	-1354(ra) # 1078 <chdir>
     5ca:	e925                	bnez	a0,63a <go+0x5c2>
      kill(pid);
     5cc:	855a                	mv	a0,s6
     5ce:	00001097          	auipc	ra,0x1
     5d2:	a6a080e7          	jalr	-1430(ra) # 1038 <kill>
      wait(0,"");
     5d6:	00001597          	auipc	a1,0x1
     5da:	0f258593          	addi	a1,a1,242 # 16c8 <malloc+0x282>
     5de:	4501                	li	a0,0
     5e0:	00001097          	auipc	ra,0x1
     5e4:	a30080e7          	jalr	-1488(ra) # 1010 <wait>
     5e8:	b689                	j	12a <go+0xb2>
        close(open("a", O_CREATE|O_RDWR));
     5ea:	20200593          	li	a1,514
     5ee:	00001517          	auipc	a0,0x1
     5f2:	02250513          	addi	a0,a0,34 # 1610 <malloc+0x1ca>
     5f6:	00001097          	auipc	ra,0x1
     5fa:	a52080e7          	jalr	-1454(ra) # 1048 <open>
     5fe:	00001097          	auipc	ra,0x1
     602:	a32080e7          	jalr	-1486(ra) # 1030 <close>
        exit(0,"");
     606:	00001597          	auipc	a1,0x1
     60a:	0c258593          	addi	a1,a1,194 # 16c8 <malloc+0x282>
     60e:	4501                	li	a0,0
     610:	00001097          	auipc	ra,0x1
     614:	9f8080e7          	jalr	-1544(ra) # 1008 <exit>
        printf("grind: fork failed\n");
     618:	00001517          	auipc	a0,0x1
     61c:	01850513          	addi	a0,a0,24 # 1630 <malloc+0x1ea>
     620:	00001097          	auipc	ra,0x1
     624:	d68080e7          	jalr	-664(ra) # 1388 <printf>
        exit(1,"");
     628:	00001597          	auipc	a1,0x1
     62c:	0a058593          	addi	a1,a1,160 # 16c8 <malloc+0x282>
     630:	4505                	li	a0,1
     632:	00001097          	auipc	ra,0x1
     636:	9d6080e7          	jalr	-1578(ra) # 1008 <exit>
        printf("grind: chdir failed\n");
     63a:	00001517          	auipc	a0,0x1
     63e:	01e50513          	addi	a0,a0,30 # 1658 <malloc+0x212>
     642:	00001097          	auipc	ra,0x1
     646:	d46080e7          	jalr	-698(ra) # 1388 <printf>
        exit(1,"");
     64a:	00001597          	auipc	a1,0x1
     64e:	07e58593          	addi	a1,a1,126 # 16c8 <malloc+0x282>
     652:	4505                	li	a0,1
     654:	00001097          	auipc	ra,0x1
     658:	9b4080e7          	jalr	-1612(ra) # 1008 <exit>
      int pid = fork();
     65c:	00001097          	auipc	ra,0x1
     660:	9a4080e7          	jalr	-1628(ra) # 1000 <fork>
      if(pid == 0){
     664:	cd09                	beqz	a0,67e <go+0x606>
      } else if(pid < 0){
     666:	02054d63          	bltz	a0,6a0 <go+0x628>
      wait(0,"");
     66a:	00001597          	auipc	a1,0x1
     66e:	05e58593          	addi	a1,a1,94 # 16c8 <malloc+0x282>
     672:	4501                	li	a0,0
     674:	00001097          	auipc	ra,0x1
     678:	99c080e7          	jalr	-1636(ra) # 1010 <wait>
     67c:	b47d                	j	12a <go+0xb2>
        kill(getpid());
     67e:	00001097          	auipc	ra,0x1
     682:	a0a080e7          	jalr	-1526(ra) # 1088 <getpid>
     686:	00001097          	auipc	ra,0x1
     68a:	9b2080e7          	jalr	-1614(ra) # 1038 <kill>
        exit(0,"");
     68e:	00001597          	auipc	a1,0x1
     692:	03a58593          	addi	a1,a1,58 # 16c8 <malloc+0x282>
     696:	4501                	li	a0,0
     698:	00001097          	auipc	ra,0x1
     69c:	970080e7          	jalr	-1680(ra) # 1008 <exit>
        printf("grind: fork failed\n");
     6a0:	00001517          	auipc	a0,0x1
     6a4:	f9050513          	addi	a0,a0,-112 # 1630 <malloc+0x1ea>
     6a8:	00001097          	auipc	ra,0x1
     6ac:	ce0080e7          	jalr	-800(ra) # 1388 <printf>
        exit(1,"");
     6b0:	00001597          	auipc	a1,0x1
     6b4:	01858593          	addi	a1,a1,24 # 16c8 <malloc+0x282>
     6b8:	4505                	li	a0,1
     6ba:	00001097          	auipc	ra,0x1
     6be:	94e080e7          	jalr	-1714(ra) # 1008 <exit>
      if(pipe(fds) < 0){
     6c2:	fa840513          	addi	a0,s0,-88
     6c6:	00001097          	auipc	ra,0x1
     6ca:	952080e7          	jalr	-1710(ra) # 1018 <pipe>
     6ce:	02054f63          	bltz	a0,70c <go+0x694>
      int pid = fork();
     6d2:	00001097          	auipc	ra,0x1
     6d6:	92e080e7          	jalr	-1746(ra) # 1000 <fork>
      if(pid == 0){
     6da:	c931                	beqz	a0,72e <go+0x6b6>
      } else if(pid < 0){
     6dc:	0c054663          	bltz	a0,7a8 <go+0x730>
      close(fds[0]);
     6e0:	fa842503          	lw	a0,-88(s0)
     6e4:	00001097          	auipc	ra,0x1
     6e8:	94c080e7          	jalr	-1716(ra) # 1030 <close>
      close(fds[1]);
     6ec:	fac42503          	lw	a0,-84(s0)
     6f0:	00001097          	auipc	ra,0x1
     6f4:	940080e7          	jalr	-1728(ra) # 1030 <close>
      wait(0,"");
     6f8:	00001597          	auipc	a1,0x1
     6fc:	fd058593          	addi	a1,a1,-48 # 16c8 <malloc+0x282>
     700:	4501                	li	a0,0
     702:	00001097          	auipc	ra,0x1
     706:	90e080e7          	jalr	-1778(ra) # 1010 <wait>
     70a:	b405                	j	12a <go+0xb2>
        printf("grind: pipe failed\n");
     70c:	00001517          	auipc	a0,0x1
     710:	f6450513          	addi	a0,a0,-156 # 1670 <malloc+0x22a>
     714:	00001097          	auipc	ra,0x1
     718:	c74080e7          	jalr	-908(ra) # 1388 <printf>
        exit(1,"");
     71c:	00001597          	auipc	a1,0x1
     720:	fac58593          	addi	a1,a1,-84 # 16c8 <malloc+0x282>
     724:	4505                	li	a0,1
     726:	00001097          	auipc	ra,0x1
     72a:	8e2080e7          	jalr	-1822(ra) # 1008 <exit>
        fork();
     72e:	00001097          	auipc	ra,0x1
     732:	8d2080e7          	jalr	-1838(ra) # 1000 <fork>
        fork();
     736:	00001097          	auipc	ra,0x1
     73a:	8ca080e7          	jalr	-1846(ra) # 1000 <fork>
        if(write(fds[1], "x", 1) != 1)
     73e:	4605                	li	a2,1
     740:	00001597          	auipc	a1,0x1
     744:	f4858593          	addi	a1,a1,-184 # 1688 <malloc+0x242>
     748:	fac42503          	lw	a0,-84(s0)
     74c:	00001097          	auipc	ra,0x1
     750:	8dc080e7          	jalr	-1828(ra) # 1028 <write>
     754:	4785                	li	a5,1
     756:	02f51763          	bne	a0,a5,784 <go+0x70c>
        if(read(fds[0], &c, 1) != 1)
     75a:	4605                	li	a2,1
     75c:	fa040593          	addi	a1,s0,-96
     760:	fa842503          	lw	a0,-88(s0)
     764:	00001097          	auipc	ra,0x1
     768:	8bc080e7          	jalr	-1860(ra) # 1020 <read>
     76c:	4785                	li	a5,1
     76e:	02f51463          	bne	a0,a5,796 <go+0x71e>
        exit(0,"");
     772:	00001597          	auipc	a1,0x1
     776:	f5658593          	addi	a1,a1,-170 # 16c8 <malloc+0x282>
     77a:	4501                	li	a0,0
     77c:	00001097          	auipc	ra,0x1
     780:	88c080e7          	jalr	-1908(ra) # 1008 <exit>
          printf("grind: pipe write failed\n");
     784:	00001517          	auipc	a0,0x1
     788:	f0c50513          	addi	a0,a0,-244 # 1690 <malloc+0x24a>
     78c:	00001097          	auipc	ra,0x1
     790:	bfc080e7          	jalr	-1028(ra) # 1388 <printf>
     794:	b7d9                	j	75a <go+0x6e2>
          printf("grind: pipe read failed\n");
     796:	00001517          	auipc	a0,0x1
     79a:	f1a50513          	addi	a0,a0,-230 # 16b0 <malloc+0x26a>
     79e:	00001097          	auipc	ra,0x1
     7a2:	bea080e7          	jalr	-1046(ra) # 1388 <printf>
     7a6:	b7f1                	j	772 <go+0x6fa>
        printf("grind: fork failed\n");
     7a8:	00001517          	auipc	a0,0x1
     7ac:	e8850513          	addi	a0,a0,-376 # 1630 <malloc+0x1ea>
     7b0:	00001097          	auipc	ra,0x1
     7b4:	bd8080e7          	jalr	-1064(ra) # 1388 <printf>
        exit(1,"");
     7b8:	00001597          	auipc	a1,0x1
     7bc:	f1058593          	addi	a1,a1,-240 # 16c8 <malloc+0x282>
     7c0:	4505                	li	a0,1
     7c2:	00001097          	auipc	ra,0x1
     7c6:	846080e7          	jalr	-1978(ra) # 1008 <exit>
      int pid = fork();
     7ca:	00001097          	auipc	ra,0x1
     7ce:	836080e7          	jalr	-1994(ra) # 1000 <fork>
      if(pid == 0){
     7d2:	cd09                	beqz	a0,7ec <go+0x774>
      } else if(pid < 0){
     7d4:	08054763          	bltz	a0,862 <go+0x7ea>
      wait(0,"");
     7d8:	00001597          	auipc	a1,0x1
     7dc:	ef058593          	addi	a1,a1,-272 # 16c8 <malloc+0x282>
     7e0:	4501                	li	a0,0
     7e2:	00001097          	auipc	ra,0x1
     7e6:	82e080e7          	jalr	-2002(ra) # 1010 <wait>
     7ea:	b281                	j	12a <go+0xb2>
        unlink("a");
     7ec:	00001517          	auipc	a0,0x1
     7f0:	e2450513          	addi	a0,a0,-476 # 1610 <malloc+0x1ca>
     7f4:	00001097          	auipc	ra,0x1
     7f8:	864080e7          	jalr	-1948(ra) # 1058 <unlink>
        mkdir("a");
     7fc:	00001517          	auipc	a0,0x1
     800:	e1450513          	addi	a0,a0,-492 # 1610 <malloc+0x1ca>
     804:	00001097          	auipc	ra,0x1
     808:	86c080e7          	jalr	-1940(ra) # 1070 <mkdir>
        chdir("a");
     80c:	00001517          	auipc	a0,0x1
     810:	e0450513          	addi	a0,a0,-508 # 1610 <malloc+0x1ca>
     814:	00001097          	auipc	ra,0x1
     818:	864080e7          	jalr	-1948(ra) # 1078 <chdir>
        unlink("../a");
     81c:	00001517          	auipc	a0,0x1
     820:	d5c50513          	addi	a0,a0,-676 # 1578 <malloc+0x132>
     824:	00001097          	auipc	ra,0x1
     828:	834080e7          	jalr	-1996(ra) # 1058 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     82c:	20200593          	li	a1,514
     830:	00001517          	auipc	a0,0x1
     834:	e5850513          	addi	a0,a0,-424 # 1688 <malloc+0x242>
     838:	00001097          	auipc	ra,0x1
     83c:	810080e7          	jalr	-2032(ra) # 1048 <open>
        unlink("x");
     840:	00001517          	auipc	a0,0x1
     844:	e4850513          	addi	a0,a0,-440 # 1688 <malloc+0x242>
     848:	00001097          	auipc	ra,0x1
     84c:	810080e7          	jalr	-2032(ra) # 1058 <unlink>
        exit(0,"");
     850:	00001597          	auipc	a1,0x1
     854:	e7858593          	addi	a1,a1,-392 # 16c8 <malloc+0x282>
     858:	4501                	li	a0,0
     85a:	00000097          	auipc	ra,0x0
     85e:	7ae080e7          	jalr	1966(ra) # 1008 <exit>
        printf("grind: fork failed\n");
     862:	00001517          	auipc	a0,0x1
     866:	dce50513          	addi	a0,a0,-562 # 1630 <malloc+0x1ea>
     86a:	00001097          	auipc	ra,0x1
     86e:	b1e080e7          	jalr	-1250(ra) # 1388 <printf>
        exit(1,"");
     872:	00001597          	auipc	a1,0x1
     876:	e5658593          	addi	a1,a1,-426 # 16c8 <malloc+0x282>
     87a:	4505                	li	a0,1
     87c:	00000097          	auipc	ra,0x0
     880:	78c080e7          	jalr	1932(ra) # 1008 <exit>
      unlink("c");
     884:	00001517          	auipc	a0,0x1
     888:	e4c50513          	addi	a0,a0,-436 # 16d0 <malloc+0x28a>
     88c:	00000097          	auipc	ra,0x0
     890:	7cc080e7          	jalr	1996(ra) # 1058 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     894:	20200593          	li	a1,514
     898:	00001517          	auipc	a0,0x1
     89c:	e3850513          	addi	a0,a0,-456 # 16d0 <malloc+0x28a>
     8a0:	00000097          	auipc	ra,0x0
     8a4:	7a8080e7          	jalr	1960(ra) # 1048 <open>
     8a8:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     8aa:	04054f63          	bltz	a0,908 <go+0x890>
      if(write(fd1, "x", 1) != 1){
     8ae:	4605                	li	a2,1
     8b0:	00001597          	auipc	a1,0x1
     8b4:	dd858593          	addi	a1,a1,-552 # 1688 <malloc+0x242>
     8b8:	00000097          	auipc	ra,0x0
     8bc:	770080e7          	jalr	1904(ra) # 1028 <write>
     8c0:	4785                	li	a5,1
     8c2:	06f51463          	bne	a0,a5,92a <go+0x8b2>
      if(fstat(fd1, &st) != 0){
     8c6:	fa840593          	addi	a1,s0,-88
     8ca:	855a                	mv	a0,s6
     8cc:	00000097          	auipc	ra,0x0
     8d0:	794080e7          	jalr	1940(ra) # 1060 <fstat>
     8d4:	ed25                	bnez	a0,94c <go+0x8d4>
      if(st.size != 1){
     8d6:	fb843583          	ld	a1,-72(s0)
     8da:	4785                	li	a5,1
     8dc:	08f59963          	bne	a1,a5,96e <go+0x8f6>
      if(st.ino > 200){
     8e0:	fac42583          	lw	a1,-84(s0)
     8e4:	0c800793          	li	a5,200
     8e8:	0ab7e563          	bltu	a5,a1,992 <go+0x91a>
      close(fd1);
     8ec:	855a                	mv	a0,s6
     8ee:	00000097          	auipc	ra,0x0
     8f2:	742080e7          	jalr	1858(ra) # 1030 <close>
      unlink("c");
     8f6:	00001517          	auipc	a0,0x1
     8fa:	dda50513          	addi	a0,a0,-550 # 16d0 <malloc+0x28a>
     8fe:	00000097          	auipc	ra,0x0
     902:	75a080e7          	jalr	1882(ra) # 1058 <unlink>
     906:	b015                	j	12a <go+0xb2>
        printf("grind: create c failed\n");
     908:	00001517          	auipc	a0,0x1
     90c:	dd050513          	addi	a0,a0,-560 # 16d8 <malloc+0x292>
     910:	00001097          	auipc	ra,0x1
     914:	a78080e7          	jalr	-1416(ra) # 1388 <printf>
        exit(1,"");
     918:	00001597          	auipc	a1,0x1
     91c:	db058593          	addi	a1,a1,-592 # 16c8 <malloc+0x282>
     920:	4505                	li	a0,1
     922:	00000097          	auipc	ra,0x0
     926:	6e6080e7          	jalr	1766(ra) # 1008 <exit>
        printf("grind: write c failed\n");
     92a:	00001517          	auipc	a0,0x1
     92e:	dc650513          	addi	a0,a0,-570 # 16f0 <malloc+0x2aa>
     932:	00001097          	auipc	ra,0x1
     936:	a56080e7          	jalr	-1450(ra) # 1388 <printf>
        exit(1,"");
     93a:	00001597          	auipc	a1,0x1
     93e:	d8e58593          	addi	a1,a1,-626 # 16c8 <malloc+0x282>
     942:	4505                	li	a0,1
     944:	00000097          	auipc	ra,0x0
     948:	6c4080e7          	jalr	1732(ra) # 1008 <exit>
        printf("grind: fstat failed\n");
     94c:	00001517          	auipc	a0,0x1
     950:	dbc50513          	addi	a0,a0,-580 # 1708 <malloc+0x2c2>
     954:	00001097          	auipc	ra,0x1
     958:	a34080e7          	jalr	-1484(ra) # 1388 <printf>
        exit(1,"");
     95c:	00001597          	auipc	a1,0x1
     960:	d6c58593          	addi	a1,a1,-660 # 16c8 <malloc+0x282>
     964:	4505                	li	a0,1
     966:	00000097          	auipc	ra,0x0
     96a:	6a2080e7          	jalr	1698(ra) # 1008 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     96e:	2581                	sext.w	a1,a1
     970:	00001517          	auipc	a0,0x1
     974:	db050513          	addi	a0,a0,-592 # 1720 <malloc+0x2da>
     978:	00001097          	auipc	ra,0x1
     97c:	a10080e7          	jalr	-1520(ra) # 1388 <printf>
        exit(1,"");
     980:	00001597          	auipc	a1,0x1
     984:	d4858593          	addi	a1,a1,-696 # 16c8 <malloc+0x282>
     988:	4505                	li	a0,1
     98a:	00000097          	auipc	ra,0x0
     98e:	67e080e7          	jalr	1662(ra) # 1008 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     992:	00001517          	auipc	a0,0x1
     996:	db650513          	addi	a0,a0,-586 # 1748 <malloc+0x302>
     99a:	00001097          	auipc	ra,0x1
     99e:	9ee080e7          	jalr	-1554(ra) # 1388 <printf>
        exit(1,"");
     9a2:	00001597          	auipc	a1,0x1
     9a6:	d2658593          	addi	a1,a1,-730 # 16c8 <malloc+0x282>
     9aa:	4505                	li	a0,1
     9ac:	00000097          	auipc	ra,0x0
     9b0:	65c080e7          	jalr	1628(ra) # 1008 <exit>
        fprintf(2, "grind: pipe failed\n");
     9b4:	00001597          	auipc	a1,0x1
     9b8:	cbc58593          	addi	a1,a1,-836 # 1670 <malloc+0x22a>
     9bc:	4509                	li	a0,2
     9be:	00001097          	auipc	ra,0x1
     9c2:	99c080e7          	jalr	-1636(ra) # 135a <fprintf>
        exit(1,"");
     9c6:	00001597          	auipc	a1,0x1
     9ca:	d0258593          	addi	a1,a1,-766 # 16c8 <malloc+0x282>
     9ce:	4505                	li	a0,1
     9d0:	00000097          	auipc	ra,0x0
     9d4:	638080e7          	jalr	1592(ra) # 1008 <exit>
        fprintf(2, "grind: pipe failed\n");
     9d8:	00001597          	auipc	a1,0x1
     9dc:	c9858593          	addi	a1,a1,-872 # 1670 <malloc+0x22a>
     9e0:	4509                	li	a0,2
     9e2:	00001097          	auipc	ra,0x1
     9e6:	978080e7          	jalr	-1672(ra) # 135a <fprintf>
        exit(1,"");
     9ea:	00001597          	auipc	a1,0x1
     9ee:	cde58593          	addi	a1,a1,-802 # 16c8 <malloc+0x282>
     9f2:	4505                	li	a0,1
     9f4:	00000097          	auipc	ra,0x0
     9f8:	614080e7          	jalr	1556(ra) # 1008 <exit>
        close(bb[0]);
     9fc:	fa042503          	lw	a0,-96(s0)
     a00:	00000097          	auipc	ra,0x0
     a04:	630080e7          	jalr	1584(ra) # 1030 <close>
        close(bb[1]);
     a08:	fa442503          	lw	a0,-92(s0)
     a0c:	00000097          	auipc	ra,0x0
     a10:	624080e7          	jalr	1572(ra) # 1030 <close>
        close(aa[0]);
     a14:	f9842503          	lw	a0,-104(s0)
     a18:	00000097          	auipc	ra,0x0
     a1c:	618080e7          	jalr	1560(ra) # 1030 <close>
        close(1);
     a20:	4505                	li	a0,1
     a22:	00000097          	auipc	ra,0x0
     a26:	60e080e7          	jalr	1550(ra) # 1030 <close>
        if(dup(aa[1]) != 1){
     a2a:	f9c42503          	lw	a0,-100(s0)
     a2e:	00000097          	auipc	ra,0x0
     a32:	652080e7          	jalr	1618(ra) # 1080 <dup>
     a36:	4785                	li	a5,1
     a38:	02f50463          	beq	a0,a5,a60 <go+0x9e8>
          fprintf(2, "grind: dup failed\n");
     a3c:	00001597          	auipc	a1,0x1
     a40:	d3458593          	addi	a1,a1,-716 # 1770 <malloc+0x32a>
     a44:	4509                	li	a0,2
     a46:	00001097          	auipc	ra,0x1
     a4a:	914080e7          	jalr	-1772(ra) # 135a <fprintf>
          exit(1,"");
     a4e:	00001597          	auipc	a1,0x1
     a52:	c7a58593          	addi	a1,a1,-902 # 16c8 <malloc+0x282>
     a56:	4505                	li	a0,1
     a58:	00000097          	auipc	ra,0x0
     a5c:	5b0080e7          	jalr	1456(ra) # 1008 <exit>
        close(aa[1]);
     a60:	f9c42503          	lw	a0,-100(s0)
     a64:	00000097          	auipc	ra,0x0
     a68:	5cc080e7          	jalr	1484(ra) # 1030 <close>
        char *args[3] = { "echo", "hi", 0 };
     a6c:	00001797          	auipc	a5,0x1
     a70:	d1c78793          	addi	a5,a5,-740 # 1788 <malloc+0x342>
     a74:	faf43423          	sd	a5,-88(s0)
     a78:	00001797          	auipc	a5,0x1
     a7c:	d1878793          	addi	a5,a5,-744 # 1790 <malloc+0x34a>
     a80:	faf43823          	sd	a5,-80(s0)
     a84:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     a88:	fa840593          	addi	a1,s0,-88
     a8c:	00001517          	auipc	a0,0x1
     a90:	d0c50513          	addi	a0,a0,-756 # 1798 <malloc+0x352>
     a94:	00000097          	auipc	ra,0x0
     a98:	5ac080e7          	jalr	1452(ra) # 1040 <exec>
        fprintf(2, "grind: echo: not found\n");
     a9c:	00001597          	auipc	a1,0x1
     aa0:	d0c58593          	addi	a1,a1,-756 # 17a8 <malloc+0x362>
     aa4:	4509                	li	a0,2
     aa6:	00001097          	auipc	ra,0x1
     aaa:	8b4080e7          	jalr	-1868(ra) # 135a <fprintf>
        exit(2,"");
     aae:	00001597          	auipc	a1,0x1
     ab2:	c1a58593          	addi	a1,a1,-998 # 16c8 <malloc+0x282>
     ab6:	4509                	li	a0,2
     ab8:	00000097          	auipc	ra,0x0
     abc:	550080e7          	jalr	1360(ra) # 1008 <exit>
        fprintf(2, "grind: fork failed\n");
     ac0:	00001597          	auipc	a1,0x1
     ac4:	b7058593          	addi	a1,a1,-1168 # 1630 <malloc+0x1ea>
     ac8:	4509                	li	a0,2
     aca:	00001097          	auipc	ra,0x1
     ace:	890080e7          	jalr	-1904(ra) # 135a <fprintf>
        exit(3,"");
     ad2:	00001597          	auipc	a1,0x1
     ad6:	bf658593          	addi	a1,a1,-1034 # 16c8 <malloc+0x282>
     ada:	450d                	li	a0,3
     adc:	00000097          	auipc	ra,0x0
     ae0:	52c080e7          	jalr	1324(ra) # 1008 <exit>
        close(aa[1]);
     ae4:	f9c42503          	lw	a0,-100(s0)
     ae8:	00000097          	auipc	ra,0x0
     aec:	548080e7          	jalr	1352(ra) # 1030 <close>
        close(bb[0]);
     af0:	fa042503          	lw	a0,-96(s0)
     af4:	00000097          	auipc	ra,0x0
     af8:	53c080e7          	jalr	1340(ra) # 1030 <close>
        close(0);
     afc:	4501                	li	a0,0
     afe:	00000097          	auipc	ra,0x0
     b02:	532080e7          	jalr	1330(ra) # 1030 <close>
        if(dup(aa[0]) != 0){
     b06:	f9842503          	lw	a0,-104(s0)
     b0a:	00000097          	auipc	ra,0x0
     b0e:	576080e7          	jalr	1398(ra) # 1080 <dup>
     b12:	c11d                	beqz	a0,b38 <go+0xac0>
          fprintf(2, "grind: dup failed\n");
     b14:	00001597          	auipc	a1,0x1
     b18:	c5c58593          	addi	a1,a1,-932 # 1770 <malloc+0x32a>
     b1c:	4509                	li	a0,2
     b1e:	00001097          	auipc	ra,0x1
     b22:	83c080e7          	jalr	-1988(ra) # 135a <fprintf>
          exit(4,"");
     b26:	00001597          	auipc	a1,0x1
     b2a:	ba258593          	addi	a1,a1,-1118 # 16c8 <malloc+0x282>
     b2e:	4511                	li	a0,4
     b30:	00000097          	auipc	ra,0x0
     b34:	4d8080e7          	jalr	1240(ra) # 1008 <exit>
        close(aa[0]);
     b38:	f9842503          	lw	a0,-104(s0)
     b3c:	00000097          	auipc	ra,0x0
     b40:	4f4080e7          	jalr	1268(ra) # 1030 <close>
        close(1);
     b44:	4505                	li	a0,1
     b46:	00000097          	auipc	ra,0x0
     b4a:	4ea080e7          	jalr	1258(ra) # 1030 <close>
        if(dup(bb[1]) != 1){
     b4e:	fa442503          	lw	a0,-92(s0)
     b52:	00000097          	auipc	ra,0x0
     b56:	52e080e7          	jalr	1326(ra) # 1080 <dup>
     b5a:	4785                	li	a5,1
     b5c:	02f50463          	beq	a0,a5,b84 <go+0xb0c>
          fprintf(2, "grind: dup failed\n");
     b60:	00001597          	auipc	a1,0x1
     b64:	c1058593          	addi	a1,a1,-1008 # 1770 <malloc+0x32a>
     b68:	4509                	li	a0,2
     b6a:	00000097          	auipc	ra,0x0
     b6e:	7f0080e7          	jalr	2032(ra) # 135a <fprintf>
          exit(5,"");
     b72:	00001597          	auipc	a1,0x1
     b76:	b5658593          	addi	a1,a1,-1194 # 16c8 <malloc+0x282>
     b7a:	4515                	li	a0,5
     b7c:	00000097          	auipc	ra,0x0
     b80:	48c080e7          	jalr	1164(ra) # 1008 <exit>
        close(bb[1]);
     b84:	fa442503          	lw	a0,-92(s0)
     b88:	00000097          	auipc	ra,0x0
     b8c:	4a8080e7          	jalr	1192(ra) # 1030 <close>
        char *args[2] = { "cat", 0 };
     b90:	00001797          	auipc	a5,0x1
     b94:	c3078793          	addi	a5,a5,-976 # 17c0 <malloc+0x37a>
     b98:	faf43423          	sd	a5,-88(s0)
     b9c:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     ba0:	fa840593          	addi	a1,s0,-88
     ba4:	00001517          	auipc	a0,0x1
     ba8:	c2450513          	addi	a0,a0,-988 # 17c8 <malloc+0x382>
     bac:	00000097          	auipc	ra,0x0
     bb0:	494080e7          	jalr	1172(ra) # 1040 <exec>
        fprintf(2, "grind: cat: not found\n");
     bb4:	00001597          	auipc	a1,0x1
     bb8:	c1c58593          	addi	a1,a1,-996 # 17d0 <malloc+0x38a>
     bbc:	4509                	li	a0,2
     bbe:	00000097          	auipc	ra,0x0
     bc2:	79c080e7          	jalr	1948(ra) # 135a <fprintf>
        exit(6,"");
     bc6:	00001597          	auipc	a1,0x1
     bca:	b0258593          	addi	a1,a1,-1278 # 16c8 <malloc+0x282>
     bce:	4519                	li	a0,6
     bd0:	00000097          	auipc	ra,0x0
     bd4:	438080e7          	jalr	1080(ra) # 1008 <exit>
        fprintf(2, "grind: fork failed\n");
     bd8:	00001597          	auipc	a1,0x1
     bdc:	a5858593          	addi	a1,a1,-1448 # 1630 <malloc+0x1ea>
     be0:	4509                	li	a0,2
     be2:	00000097          	auipc	ra,0x0
     be6:	778080e7          	jalr	1912(ra) # 135a <fprintf>
        exit(7,"");
     bea:	00001597          	auipc	a1,0x1
     bee:	ade58593          	addi	a1,a1,-1314 # 16c8 <malloc+0x282>
     bf2:	451d                	li	a0,7
     bf4:	00000097          	auipc	ra,0x0
     bf8:	414080e7          	jalr	1044(ra) # 1008 <exit>

0000000000000bfc <iter>:
  }
}

void
iter()
{
     bfc:	7179                	addi	sp,sp,-48
     bfe:	f406                	sd	ra,40(sp)
     c00:	f022                	sd	s0,32(sp)
     c02:	ec26                	sd	s1,24(sp)
     c04:	e84a                	sd	s2,16(sp)
     c06:	1800                	addi	s0,sp,48
  unlink("a");
     c08:	00001517          	auipc	a0,0x1
     c0c:	a0850513          	addi	a0,a0,-1528 # 1610 <malloc+0x1ca>
     c10:	00000097          	auipc	ra,0x0
     c14:	448080e7          	jalr	1096(ra) # 1058 <unlink>
  unlink("b");
     c18:	00001517          	auipc	a0,0x1
     c1c:	9a850513          	addi	a0,a0,-1624 # 15c0 <malloc+0x17a>
     c20:	00000097          	auipc	ra,0x0
     c24:	438080e7          	jalr	1080(ra) # 1058 <unlink>
  
  int pid1 = fork();
     c28:	00000097          	auipc	ra,0x0
     c2c:	3d8080e7          	jalr	984(ra) # 1000 <fork>
  if(pid1 < 0){
     c30:	02054163          	bltz	a0,c52 <iter+0x56>
     c34:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1,"");
  }
  if(pid1 == 0){
     c36:	ed1d                	bnez	a0,c74 <iter+0x78>
    rand_next ^= 31;
     c38:	00001717          	auipc	a4,0x1
     c3c:	3c870713          	addi	a4,a4,968 # 2000 <rand_next>
     c40:	631c                	ld	a5,0(a4)
     c42:	01f7c793          	xori	a5,a5,31
     c46:	e31c                	sd	a5,0(a4)
    go(0);
     c48:	4501                	li	a0,0
     c4a:	fffff097          	auipc	ra,0xfffff
     c4e:	42e080e7          	jalr	1070(ra) # 78 <go>
    printf("grind: fork failed\n");
     c52:	00001517          	auipc	a0,0x1
     c56:	9de50513          	addi	a0,a0,-1570 # 1630 <malloc+0x1ea>
     c5a:	00000097          	auipc	ra,0x0
     c5e:	72e080e7          	jalr	1838(ra) # 1388 <printf>
    exit(1,"");
     c62:	00001597          	auipc	a1,0x1
     c66:	a6658593          	addi	a1,a1,-1434 # 16c8 <malloc+0x282>
     c6a:	4505                	li	a0,1
     c6c:	00000097          	auipc	ra,0x0
     c70:	39c080e7          	jalr	924(ra) # 1008 <exit>
    exit(0,"");
  }

  int pid2 = fork();
     c74:	00000097          	auipc	ra,0x0
     c78:	38c080e7          	jalr	908(ra) # 1000 <fork>
     c7c:	892a                	mv	s2,a0
  if(pid2 < 0){
     c7e:	02054263          	bltz	a0,ca2 <iter+0xa6>
    printf("grind: fork failed\n");
    exit(1,"");
  }
  if(pid2 == 0){
     c82:	e129                	bnez	a0,cc4 <iter+0xc8>
    rand_next ^= 7177;
     c84:	00001697          	auipc	a3,0x1
     c88:	37c68693          	addi	a3,a3,892 # 2000 <rand_next>
     c8c:	629c                	ld	a5,0(a3)
     c8e:	6709                	lui	a4,0x2
     c90:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x3e9>
     c94:	8fb9                	xor	a5,a5,a4
     c96:	e29c                	sd	a5,0(a3)
    go(1);
     c98:	4505                	li	a0,1
     c9a:	fffff097          	auipc	ra,0xfffff
     c9e:	3de080e7          	jalr	990(ra) # 78 <go>
    printf("grind: fork failed\n");
     ca2:	00001517          	auipc	a0,0x1
     ca6:	98e50513          	addi	a0,a0,-1650 # 1630 <malloc+0x1ea>
     caa:	00000097          	auipc	ra,0x0
     cae:	6de080e7          	jalr	1758(ra) # 1388 <printf>
    exit(1,"");
     cb2:	00001597          	auipc	a1,0x1
     cb6:	a1658593          	addi	a1,a1,-1514 # 16c8 <malloc+0x282>
     cba:	4505                	li	a0,1
     cbc:	00000097          	auipc	ra,0x0
     cc0:	34c080e7          	jalr	844(ra) # 1008 <exit>
    exit(0,"");
  }

  int st1 = -1;
     cc4:	57fd                	li	a5,-1
     cc6:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1,"");
     cca:	00001597          	auipc	a1,0x1
     cce:	9fe58593          	addi	a1,a1,-1538 # 16c8 <malloc+0x282>
     cd2:	fdc40513          	addi	a0,s0,-36
     cd6:	00000097          	auipc	ra,0x0
     cda:	33a080e7          	jalr	826(ra) # 1010 <wait>
  if(st1 != 0){
     cde:	fdc42783          	lw	a5,-36(s0)
     ce2:	e79d                	bnez	a5,d10 <iter+0x114>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     ce4:	57fd                	li	a5,-1
     ce6:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2,"");
     cea:	00001597          	auipc	a1,0x1
     cee:	9de58593          	addi	a1,a1,-1570 # 16c8 <malloc+0x282>
     cf2:	fd840513          	addi	a0,s0,-40
     cf6:	00000097          	auipc	ra,0x0
     cfa:	31a080e7          	jalr	794(ra) # 1010 <wait>

  exit(0,"");
     cfe:	00001597          	auipc	a1,0x1
     d02:	9ca58593          	addi	a1,a1,-1590 # 16c8 <malloc+0x282>
     d06:	4501                	li	a0,0
     d08:	00000097          	auipc	ra,0x0
     d0c:	300080e7          	jalr	768(ra) # 1008 <exit>
    kill(pid1);
     d10:	8526                	mv	a0,s1
     d12:	00000097          	auipc	ra,0x0
     d16:	326080e7          	jalr	806(ra) # 1038 <kill>
    kill(pid2);
     d1a:	854a                	mv	a0,s2
     d1c:	00000097          	auipc	ra,0x0
     d20:	31c080e7          	jalr	796(ra) # 1038 <kill>
     d24:	b7c1                	j	ce4 <iter+0xe8>

0000000000000d26 <main>:
}

int
main()
{
     d26:	1101                	addi	sp,sp,-32
     d28:	ec06                	sd	ra,24(sp)
     d2a:	e822                	sd	s0,16(sp)
     d2c:	e426                	sd	s1,8(sp)
     d2e:	e04a                	sd	s2,0(sp)
     d30:	1000                	addi	s0,sp,32
    if(pid == 0){
      iter();
      exit(0,"");
    }
    if(pid > 0){
      wait(0,"");
     d32:	00001917          	auipc	s2,0x1
     d36:	99690913          	addi	s2,s2,-1642 # 16c8 <malloc+0x282>
    }
    sleep(20);
    rand_next += 1;
     d3a:	00001497          	auipc	s1,0x1
     d3e:	2c648493          	addi	s1,s1,710 # 2000 <rand_next>
     d42:	a829                	j	d5c <main+0x36>
      iter();
     d44:	00000097          	auipc	ra,0x0
     d48:	eb8080e7          	jalr	-328(ra) # bfc <iter>
    sleep(20);
     d4c:	4551                	li	a0,20
     d4e:	00000097          	auipc	ra,0x0
     d52:	34a080e7          	jalr	842(ra) # 1098 <sleep>
    rand_next += 1;
     d56:	609c                	ld	a5,0(s1)
     d58:	0785                	addi	a5,a5,1
     d5a:	e09c                	sd	a5,0(s1)
    int pid = fork();
     d5c:	00000097          	auipc	ra,0x0
     d60:	2a4080e7          	jalr	676(ra) # 1000 <fork>
    if(pid == 0){
     d64:	d165                	beqz	a0,d44 <main+0x1e>
    if(pid > 0){
     d66:	fea053e3          	blez	a0,d4c <main+0x26>
      wait(0,"");
     d6a:	85ca                	mv	a1,s2
     d6c:	4501                	li	a0,0
     d6e:	00000097          	auipc	ra,0x0
     d72:	2a2080e7          	jalr	674(ra) # 1010 <wait>
     d76:	bfd9                	j	d4c <main+0x26>

0000000000000d78 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     d78:	1141                	addi	sp,sp,-16
     d7a:	e406                	sd	ra,8(sp)
     d7c:	e022                	sd	s0,0(sp)
     d7e:	0800                	addi	s0,sp,16
  extern int main();
  main();
     d80:	00000097          	auipc	ra,0x0
     d84:	fa6080e7          	jalr	-90(ra) # d26 <main>
  exit(0,"");
     d88:	00001597          	auipc	a1,0x1
     d8c:	94058593          	addi	a1,a1,-1728 # 16c8 <malloc+0x282>
     d90:	4501                	li	a0,0
     d92:	00000097          	auipc	ra,0x0
     d96:	276080e7          	jalr	630(ra) # 1008 <exit>

0000000000000d9a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     d9a:	1141                	addi	sp,sp,-16
     d9c:	e422                	sd	s0,8(sp)
     d9e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     da0:	87aa                	mv	a5,a0
     da2:	0585                	addi	a1,a1,1
     da4:	0785                	addi	a5,a5,1
     da6:	fff5c703          	lbu	a4,-1(a1)
     daa:	fee78fa3          	sb	a4,-1(a5)
     dae:	fb75                	bnez	a4,da2 <strcpy+0x8>
    ;
  return os;
}
     db0:	6422                	ld	s0,8(sp)
     db2:	0141                	addi	sp,sp,16
     db4:	8082                	ret

0000000000000db6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     db6:	1141                	addi	sp,sp,-16
     db8:	e422                	sd	s0,8(sp)
     dba:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     dbc:	00054783          	lbu	a5,0(a0)
     dc0:	cb91                	beqz	a5,dd4 <strcmp+0x1e>
     dc2:	0005c703          	lbu	a4,0(a1)
     dc6:	00f71763          	bne	a4,a5,dd4 <strcmp+0x1e>
    p++, q++;
     dca:	0505                	addi	a0,a0,1
     dcc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     dce:	00054783          	lbu	a5,0(a0)
     dd2:	fbe5                	bnez	a5,dc2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     dd4:	0005c503          	lbu	a0,0(a1)
}
     dd8:	40a7853b          	subw	a0,a5,a0
     ddc:	6422                	ld	s0,8(sp)
     dde:	0141                	addi	sp,sp,16
     de0:	8082                	ret

0000000000000de2 <strlen>:

uint
strlen(const char *s)
{
     de2:	1141                	addi	sp,sp,-16
     de4:	e422                	sd	s0,8(sp)
     de6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     de8:	00054783          	lbu	a5,0(a0)
     dec:	cf91                	beqz	a5,e08 <strlen+0x26>
     dee:	0505                	addi	a0,a0,1
     df0:	87aa                	mv	a5,a0
     df2:	4685                	li	a3,1
     df4:	9e89                	subw	a3,a3,a0
     df6:	00f6853b          	addw	a0,a3,a5
     dfa:	0785                	addi	a5,a5,1
     dfc:	fff7c703          	lbu	a4,-1(a5)
     e00:	fb7d                	bnez	a4,df6 <strlen+0x14>
    ;
  return n;
}
     e02:	6422                	ld	s0,8(sp)
     e04:	0141                	addi	sp,sp,16
     e06:	8082                	ret
  for(n = 0; s[n]; n++)
     e08:	4501                	li	a0,0
     e0a:	bfe5                	j	e02 <strlen+0x20>

0000000000000e0c <memset>:

void*
memset(void *dst, int c, uint n)
{
     e0c:	1141                	addi	sp,sp,-16
     e0e:	e422                	sd	s0,8(sp)
     e10:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     e12:	ca19                	beqz	a2,e28 <memset+0x1c>
     e14:	87aa                	mv	a5,a0
     e16:	1602                	slli	a2,a2,0x20
     e18:	9201                	srli	a2,a2,0x20
     e1a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     e1e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     e22:	0785                	addi	a5,a5,1
     e24:	fee79de3          	bne	a5,a4,e1e <memset+0x12>
  }
  return dst;
}
     e28:	6422                	ld	s0,8(sp)
     e2a:	0141                	addi	sp,sp,16
     e2c:	8082                	ret

0000000000000e2e <strchr>:

char*
strchr(const char *s, char c)
{
     e2e:	1141                	addi	sp,sp,-16
     e30:	e422                	sd	s0,8(sp)
     e32:	0800                	addi	s0,sp,16
  for(; *s; s++)
     e34:	00054783          	lbu	a5,0(a0)
     e38:	cb99                	beqz	a5,e4e <strchr+0x20>
    if(*s == c)
     e3a:	00f58763          	beq	a1,a5,e48 <strchr+0x1a>
  for(; *s; s++)
     e3e:	0505                	addi	a0,a0,1
     e40:	00054783          	lbu	a5,0(a0)
     e44:	fbfd                	bnez	a5,e3a <strchr+0xc>
      return (char*)s;
  return 0;
     e46:	4501                	li	a0,0
}
     e48:	6422                	ld	s0,8(sp)
     e4a:	0141                	addi	sp,sp,16
     e4c:	8082                	ret
  return 0;
     e4e:	4501                	li	a0,0
     e50:	bfe5                	j	e48 <strchr+0x1a>

0000000000000e52 <gets>:

char*
gets(char *buf, int max)
{
     e52:	711d                	addi	sp,sp,-96
     e54:	ec86                	sd	ra,88(sp)
     e56:	e8a2                	sd	s0,80(sp)
     e58:	e4a6                	sd	s1,72(sp)
     e5a:	e0ca                	sd	s2,64(sp)
     e5c:	fc4e                	sd	s3,56(sp)
     e5e:	f852                	sd	s4,48(sp)
     e60:	f456                	sd	s5,40(sp)
     e62:	f05a                	sd	s6,32(sp)
     e64:	ec5e                	sd	s7,24(sp)
     e66:	1080                	addi	s0,sp,96
     e68:	8baa                	mv	s7,a0
     e6a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     e6c:	892a                	mv	s2,a0
     e6e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     e70:	4aa9                	li	s5,10
     e72:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     e74:	89a6                	mv	s3,s1
     e76:	2485                	addiw	s1,s1,1
     e78:	0344d863          	bge	s1,s4,ea8 <gets+0x56>
    cc = read(0, &c, 1);
     e7c:	4605                	li	a2,1
     e7e:	faf40593          	addi	a1,s0,-81
     e82:	4501                	li	a0,0
     e84:	00000097          	auipc	ra,0x0
     e88:	19c080e7          	jalr	412(ra) # 1020 <read>
    if(cc < 1)
     e8c:	00a05e63          	blez	a0,ea8 <gets+0x56>
    buf[i++] = c;
     e90:	faf44783          	lbu	a5,-81(s0)
     e94:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     e98:	01578763          	beq	a5,s5,ea6 <gets+0x54>
     e9c:	0905                	addi	s2,s2,1
     e9e:	fd679be3          	bne	a5,s6,e74 <gets+0x22>
  for(i=0; i+1 < max; ){
     ea2:	89a6                	mv	s3,s1
     ea4:	a011                	j	ea8 <gets+0x56>
     ea6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ea8:	99de                	add	s3,s3,s7
     eaa:	00098023          	sb	zero,0(s3)
  return buf;
}
     eae:	855e                	mv	a0,s7
     eb0:	60e6                	ld	ra,88(sp)
     eb2:	6446                	ld	s0,80(sp)
     eb4:	64a6                	ld	s1,72(sp)
     eb6:	6906                	ld	s2,64(sp)
     eb8:	79e2                	ld	s3,56(sp)
     eba:	7a42                	ld	s4,48(sp)
     ebc:	7aa2                	ld	s5,40(sp)
     ebe:	7b02                	ld	s6,32(sp)
     ec0:	6be2                	ld	s7,24(sp)
     ec2:	6125                	addi	sp,sp,96
     ec4:	8082                	ret

0000000000000ec6 <stat>:

int
stat(const char *n, struct stat *st)
{
     ec6:	1101                	addi	sp,sp,-32
     ec8:	ec06                	sd	ra,24(sp)
     eca:	e822                	sd	s0,16(sp)
     ecc:	e426                	sd	s1,8(sp)
     ece:	e04a                	sd	s2,0(sp)
     ed0:	1000                	addi	s0,sp,32
     ed2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     ed4:	4581                	li	a1,0
     ed6:	00000097          	auipc	ra,0x0
     eda:	172080e7          	jalr	370(ra) # 1048 <open>
  if(fd < 0)
     ede:	02054563          	bltz	a0,f08 <stat+0x42>
     ee2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     ee4:	85ca                	mv	a1,s2
     ee6:	00000097          	auipc	ra,0x0
     eea:	17a080e7          	jalr	378(ra) # 1060 <fstat>
     eee:	892a                	mv	s2,a0
  close(fd);
     ef0:	8526                	mv	a0,s1
     ef2:	00000097          	auipc	ra,0x0
     ef6:	13e080e7          	jalr	318(ra) # 1030 <close>
  return r;
}
     efa:	854a                	mv	a0,s2
     efc:	60e2                	ld	ra,24(sp)
     efe:	6442                	ld	s0,16(sp)
     f00:	64a2                	ld	s1,8(sp)
     f02:	6902                	ld	s2,0(sp)
     f04:	6105                	addi	sp,sp,32
     f06:	8082                	ret
    return -1;
     f08:	597d                	li	s2,-1
     f0a:	bfc5                	j	efa <stat+0x34>

0000000000000f0c <atoi>:

int
atoi(const char *s)
{
     f0c:	1141                	addi	sp,sp,-16
     f0e:	e422                	sd	s0,8(sp)
     f10:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     f12:	00054603          	lbu	a2,0(a0)
     f16:	fd06079b          	addiw	a5,a2,-48
     f1a:	0ff7f793          	andi	a5,a5,255
     f1e:	4725                	li	a4,9
     f20:	02f76963          	bltu	a4,a5,f52 <atoi+0x46>
     f24:	86aa                	mv	a3,a0
  n = 0;
     f26:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     f28:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     f2a:	0685                	addi	a3,a3,1
     f2c:	0025179b          	slliw	a5,a0,0x2
     f30:	9fa9                	addw	a5,a5,a0
     f32:	0017979b          	slliw	a5,a5,0x1
     f36:	9fb1                	addw	a5,a5,a2
     f38:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     f3c:	0006c603          	lbu	a2,0(a3)
     f40:	fd06071b          	addiw	a4,a2,-48
     f44:	0ff77713          	andi	a4,a4,255
     f48:	fee5f1e3          	bgeu	a1,a4,f2a <atoi+0x1e>
  return n;
}
     f4c:	6422                	ld	s0,8(sp)
     f4e:	0141                	addi	sp,sp,16
     f50:	8082                	ret
  n = 0;
     f52:	4501                	li	a0,0
     f54:	bfe5                	j	f4c <atoi+0x40>

0000000000000f56 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     f56:	1141                	addi	sp,sp,-16
     f58:	e422                	sd	s0,8(sp)
     f5a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     f5c:	02b57463          	bgeu	a0,a1,f84 <memmove+0x2e>
    while(n-- > 0)
     f60:	00c05f63          	blez	a2,f7e <memmove+0x28>
     f64:	1602                	slli	a2,a2,0x20
     f66:	9201                	srli	a2,a2,0x20
     f68:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     f6c:	872a                	mv	a4,a0
      *dst++ = *src++;
     f6e:	0585                	addi	a1,a1,1
     f70:	0705                	addi	a4,a4,1
     f72:	fff5c683          	lbu	a3,-1(a1)
     f76:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     f7a:	fee79ae3          	bne	a5,a4,f6e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     f7e:	6422                	ld	s0,8(sp)
     f80:	0141                	addi	sp,sp,16
     f82:	8082                	ret
    dst += n;
     f84:	00c50733          	add	a4,a0,a2
    src += n;
     f88:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     f8a:	fec05ae3          	blez	a2,f7e <memmove+0x28>
     f8e:	fff6079b          	addiw	a5,a2,-1
     f92:	1782                	slli	a5,a5,0x20
     f94:	9381                	srli	a5,a5,0x20
     f96:	fff7c793          	not	a5,a5
     f9a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     f9c:	15fd                	addi	a1,a1,-1
     f9e:	177d                	addi	a4,a4,-1
     fa0:	0005c683          	lbu	a3,0(a1)
     fa4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     fa8:	fee79ae3          	bne	a5,a4,f9c <memmove+0x46>
     fac:	bfc9                	j	f7e <memmove+0x28>

0000000000000fae <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     fae:	1141                	addi	sp,sp,-16
     fb0:	e422                	sd	s0,8(sp)
     fb2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     fb4:	ca05                	beqz	a2,fe4 <memcmp+0x36>
     fb6:	fff6069b          	addiw	a3,a2,-1
     fba:	1682                	slli	a3,a3,0x20
     fbc:	9281                	srli	a3,a3,0x20
     fbe:	0685                	addi	a3,a3,1
     fc0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     fc2:	00054783          	lbu	a5,0(a0)
     fc6:	0005c703          	lbu	a4,0(a1)
     fca:	00e79863          	bne	a5,a4,fda <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     fce:	0505                	addi	a0,a0,1
    p2++;
     fd0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     fd2:	fed518e3          	bne	a0,a3,fc2 <memcmp+0x14>
  }
  return 0;
     fd6:	4501                	li	a0,0
     fd8:	a019                	j	fde <memcmp+0x30>
      return *p1 - *p2;
     fda:	40e7853b          	subw	a0,a5,a4
}
     fde:	6422                	ld	s0,8(sp)
     fe0:	0141                	addi	sp,sp,16
     fe2:	8082                	ret
  return 0;
     fe4:	4501                	li	a0,0
     fe6:	bfe5                	j	fde <memcmp+0x30>

0000000000000fe8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     fe8:	1141                	addi	sp,sp,-16
     fea:	e406                	sd	ra,8(sp)
     fec:	e022                	sd	s0,0(sp)
     fee:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     ff0:	00000097          	auipc	ra,0x0
     ff4:	f66080e7          	jalr	-154(ra) # f56 <memmove>
}
     ff8:	60a2                	ld	ra,8(sp)
     ffa:	6402                	ld	s0,0(sp)
     ffc:	0141                	addi	sp,sp,16
     ffe:	8082                	ret

0000000000001000 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    1000:	4885                	li	a7,1
 ecall
    1002:	00000073          	ecall
 ret
    1006:	8082                	ret

0000000000001008 <exit>:
.global exit
exit:
 li a7, SYS_exit
    1008:	4889                	li	a7,2
 ecall
    100a:	00000073          	ecall
 ret
    100e:	8082                	ret

0000000000001010 <wait>:
.global wait
wait:
 li a7, SYS_wait
    1010:	488d                	li	a7,3
 ecall
    1012:	00000073          	ecall
 ret
    1016:	8082                	ret

0000000000001018 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    1018:	4891                	li	a7,4
 ecall
    101a:	00000073          	ecall
 ret
    101e:	8082                	ret

0000000000001020 <read>:
.global read
read:
 li a7, SYS_read
    1020:	4895                	li	a7,5
 ecall
    1022:	00000073          	ecall
 ret
    1026:	8082                	ret

0000000000001028 <write>:
.global write
write:
 li a7, SYS_write
    1028:	48c1                	li	a7,16
 ecall
    102a:	00000073          	ecall
 ret
    102e:	8082                	ret

0000000000001030 <close>:
.global close
close:
 li a7, SYS_close
    1030:	48d5                	li	a7,21
 ecall
    1032:	00000073          	ecall
 ret
    1036:	8082                	ret

0000000000001038 <kill>:
.global kill
kill:
 li a7, SYS_kill
    1038:	4899                	li	a7,6
 ecall
    103a:	00000073          	ecall
 ret
    103e:	8082                	ret

0000000000001040 <exec>:
.global exec
exec:
 li a7, SYS_exec
    1040:	489d                	li	a7,7
 ecall
    1042:	00000073          	ecall
 ret
    1046:	8082                	ret

0000000000001048 <open>:
.global open
open:
 li a7, SYS_open
    1048:	48bd                	li	a7,15
 ecall
    104a:	00000073          	ecall
 ret
    104e:	8082                	ret

0000000000001050 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    1050:	48c5                	li	a7,17
 ecall
    1052:	00000073          	ecall
 ret
    1056:	8082                	ret

0000000000001058 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    1058:	48c9                	li	a7,18
 ecall
    105a:	00000073          	ecall
 ret
    105e:	8082                	ret

0000000000001060 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    1060:	48a1                	li	a7,8
 ecall
    1062:	00000073          	ecall
 ret
    1066:	8082                	ret

0000000000001068 <link>:
.global link
link:
 li a7, SYS_link
    1068:	48cd                	li	a7,19
 ecall
    106a:	00000073          	ecall
 ret
    106e:	8082                	ret

0000000000001070 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    1070:	48d1                	li	a7,20
 ecall
    1072:	00000073          	ecall
 ret
    1076:	8082                	ret

0000000000001078 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    1078:	48a5                	li	a7,9
 ecall
    107a:	00000073          	ecall
 ret
    107e:	8082                	ret

0000000000001080 <dup>:
.global dup
dup:
 li a7, SYS_dup
    1080:	48a9                	li	a7,10
 ecall
    1082:	00000073          	ecall
 ret
    1086:	8082                	ret

0000000000001088 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    1088:	48ad                	li	a7,11
 ecall
    108a:	00000073          	ecall
 ret
    108e:	8082                	ret

0000000000001090 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    1090:	48b1                	li	a7,12
 ecall
    1092:	00000073          	ecall
 ret
    1096:	8082                	ret

0000000000001098 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    1098:	48b5                	li	a7,13
 ecall
    109a:	00000073          	ecall
 ret
    109e:	8082                	ret

00000000000010a0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    10a0:	48b9                	li	a7,14
 ecall
    10a2:	00000073          	ecall
 ret
    10a6:	8082                	ret

00000000000010a8 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
    10a8:	48d9                	li	a7,22
 ecall
    10aa:	00000073          	ecall
 ret
    10ae:	8082                	ret

00000000000010b0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    10b0:	1101                	addi	sp,sp,-32
    10b2:	ec06                	sd	ra,24(sp)
    10b4:	e822                	sd	s0,16(sp)
    10b6:	1000                	addi	s0,sp,32
    10b8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    10bc:	4605                	li	a2,1
    10be:	fef40593          	addi	a1,s0,-17
    10c2:	00000097          	auipc	ra,0x0
    10c6:	f66080e7          	jalr	-154(ra) # 1028 <write>
}
    10ca:	60e2                	ld	ra,24(sp)
    10cc:	6442                	ld	s0,16(sp)
    10ce:	6105                	addi	sp,sp,32
    10d0:	8082                	ret

00000000000010d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    10d2:	7139                	addi	sp,sp,-64
    10d4:	fc06                	sd	ra,56(sp)
    10d6:	f822                	sd	s0,48(sp)
    10d8:	f426                	sd	s1,40(sp)
    10da:	f04a                	sd	s2,32(sp)
    10dc:	ec4e                	sd	s3,24(sp)
    10de:	0080                	addi	s0,sp,64
    10e0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    10e2:	c299                	beqz	a3,10e8 <printint+0x16>
    10e4:	0805c863          	bltz	a1,1174 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    10e8:	2581                	sext.w	a1,a1
  neg = 0;
    10ea:	4881                	li	a7,0
    10ec:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    10f0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    10f2:	2601                	sext.w	a2,a2
    10f4:	00000517          	auipc	a0,0x0
    10f8:	72c50513          	addi	a0,a0,1836 # 1820 <digits>
    10fc:	883a                	mv	a6,a4
    10fe:	2705                	addiw	a4,a4,1
    1100:	02c5f7bb          	remuw	a5,a1,a2
    1104:	1782                	slli	a5,a5,0x20
    1106:	9381                	srli	a5,a5,0x20
    1108:	97aa                	add	a5,a5,a0
    110a:	0007c783          	lbu	a5,0(a5)
    110e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1112:	0005879b          	sext.w	a5,a1
    1116:	02c5d5bb          	divuw	a1,a1,a2
    111a:	0685                	addi	a3,a3,1
    111c:	fec7f0e3          	bgeu	a5,a2,10fc <printint+0x2a>
  if(neg)
    1120:	00088b63          	beqz	a7,1136 <printint+0x64>
    buf[i++] = '-';
    1124:	fd040793          	addi	a5,s0,-48
    1128:	973e                	add	a4,a4,a5
    112a:	02d00793          	li	a5,45
    112e:	fef70823          	sb	a5,-16(a4)
    1132:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    1136:	02e05863          	blez	a4,1166 <printint+0x94>
    113a:	fc040793          	addi	a5,s0,-64
    113e:	00e78933          	add	s2,a5,a4
    1142:	fff78993          	addi	s3,a5,-1
    1146:	99ba                	add	s3,s3,a4
    1148:	377d                	addiw	a4,a4,-1
    114a:	1702                	slli	a4,a4,0x20
    114c:	9301                	srli	a4,a4,0x20
    114e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1152:	fff94583          	lbu	a1,-1(s2)
    1156:	8526                	mv	a0,s1
    1158:	00000097          	auipc	ra,0x0
    115c:	f58080e7          	jalr	-168(ra) # 10b0 <putc>
  while(--i >= 0)
    1160:	197d                	addi	s2,s2,-1
    1162:	ff3918e3          	bne	s2,s3,1152 <printint+0x80>
}
    1166:	70e2                	ld	ra,56(sp)
    1168:	7442                	ld	s0,48(sp)
    116a:	74a2                	ld	s1,40(sp)
    116c:	7902                	ld	s2,32(sp)
    116e:	69e2                	ld	s3,24(sp)
    1170:	6121                	addi	sp,sp,64
    1172:	8082                	ret
    x = -xx;
    1174:	40b005bb          	negw	a1,a1
    neg = 1;
    1178:	4885                	li	a7,1
    x = -xx;
    117a:	bf8d                	j	10ec <printint+0x1a>

000000000000117c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    117c:	7119                	addi	sp,sp,-128
    117e:	fc86                	sd	ra,120(sp)
    1180:	f8a2                	sd	s0,112(sp)
    1182:	f4a6                	sd	s1,104(sp)
    1184:	f0ca                	sd	s2,96(sp)
    1186:	ecce                	sd	s3,88(sp)
    1188:	e8d2                	sd	s4,80(sp)
    118a:	e4d6                	sd	s5,72(sp)
    118c:	e0da                	sd	s6,64(sp)
    118e:	fc5e                	sd	s7,56(sp)
    1190:	f862                	sd	s8,48(sp)
    1192:	f466                	sd	s9,40(sp)
    1194:	f06a                	sd	s10,32(sp)
    1196:	ec6e                	sd	s11,24(sp)
    1198:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    119a:	0005c903          	lbu	s2,0(a1)
    119e:	18090f63          	beqz	s2,133c <vprintf+0x1c0>
    11a2:	8aaa                	mv	s5,a0
    11a4:	8b32                	mv	s6,a2
    11a6:	00158493          	addi	s1,a1,1
  state = 0;
    11aa:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    11ac:	02500a13          	li	s4,37
      if(c == 'd'){
    11b0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    11b4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    11b8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    11bc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    11c0:	00000b97          	auipc	s7,0x0
    11c4:	660b8b93          	addi	s7,s7,1632 # 1820 <digits>
    11c8:	a839                	j	11e6 <vprintf+0x6a>
        putc(fd, c);
    11ca:	85ca                	mv	a1,s2
    11cc:	8556                	mv	a0,s5
    11ce:	00000097          	auipc	ra,0x0
    11d2:	ee2080e7          	jalr	-286(ra) # 10b0 <putc>
    11d6:	a019                	j	11dc <vprintf+0x60>
    } else if(state == '%'){
    11d8:	01498f63          	beq	s3,s4,11f6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    11dc:	0485                	addi	s1,s1,1
    11de:	fff4c903          	lbu	s2,-1(s1)
    11e2:	14090d63          	beqz	s2,133c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    11e6:	0009079b          	sext.w	a5,s2
    if(state == 0){
    11ea:	fe0997e3          	bnez	s3,11d8 <vprintf+0x5c>
      if(c == '%'){
    11ee:	fd479ee3          	bne	a5,s4,11ca <vprintf+0x4e>
        state = '%';
    11f2:	89be                	mv	s3,a5
    11f4:	b7e5                	j	11dc <vprintf+0x60>
      if(c == 'd'){
    11f6:	05878063          	beq	a5,s8,1236 <vprintf+0xba>
      } else if(c == 'l') {
    11fa:	05978c63          	beq	a5,s9,1252 <vprintf+0xd6>
      } else if(c == 'x') {
    11fe:	07a78863          	beq	a5,s10,126e <vprintf+0xf2>
      } else if(c == 'p') {
    1202:	09b78463          	beq	a5,s11,128a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1206:	07300713          	li	a4,115
    120a:	0ce78663          	beq	a5,a4,12d6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    120e:	06300713          	li	a4,99
    1212:	0ee78e63          	beq	a5,a4,130e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1216:	11478863          	beq	a5,s4,1326 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    121a:	85d2                	mv	a1,s4
    121c:	8556                	mv	a0,s5
    121e:	00000097          	auipc	ra,0x0
    1222:	e92080e7          	jalr	-366(ra) # 10b0 <putc>
        putc(fd, c);
    1226:	85ca                	mv	a1,s2
    1228:	8556                	mv	a0,s5
    122a:	00000097          	auipc	ra,0x0
    122e:	e86080e7          	jalr	-378(ra) # 10b0 <putc>
      }
      state = 0;
    1232:	4981                	li	s3,0
    1234:	b765                	j	11dc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1236:	008b0913          	addi	s2,s6,8
    123a:	4685                	li	a3,1
    123c:	4629                	li	a2,10
    123e:	000b2583          	lw	a1,0(s6)
    1242:	8556                	mv	a0,s5
    1244:	00000097          	auipc	ra,0x0
    1248:	e8e080e7          	jalr	-370(ra) # 10d2 <printint>
    124c:	8b4a                	mv	s6,s2
      state = 0;
    124e:	4981                	li	s3,0
    1250:	b771                	j	11dc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1252:	008b0913          	addi	s2,s6,8
    1256:	4681                	li	a3,0
    1258:	4629                	li	a2,10
    125a:	000b2583          	lw	a1,0(s6)
    125e:	8556                	mv	a0,s5
    1260:	00000097          	auipc	ra,0x0
    1264:	e72080e7          	jalr	-398(ra) # 10d2 <printint>
    1268:	8b4a                	mv	s6,s2
      state = 0;
    126a:	4981                	li	s3,0
    126c:	bf85                	j	11dc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    126e:	008b0913          	addi	s2,s6,8
    1272:	4681                	li	a3,0
    1274:	4641                	li	a2,16
    1276:	000b2583          	lw	a1,0(s6)
    127a:	8556                	mv	a0,s5
    127c:	00000097          	auipc	ra,0x0
    1280:	e56080e7          	jalr	-426(ra) # 10d2 <printint>
    1284:	8b4a                	mv	s6,s2
      state = 0;
    1286:	4981                	li	s3,0
    1288:	bf91                	j	11dc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    128a:	008b0793          	addi	a5,s6,8
    128e:	f8f43423          	sd	a5,-120(s0)
    1292:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1296:	03000593          	li	a1,48
    129a:	8556                	mv	a0,s5
    129c:	00000097          	auipc	ra,0x0
    12a0:	e14080e7          	jalr	-492(ra) # 10b0 <putc>
  putc(fd, 'x');
    12a4:	85ea                	mv	a1,s10
    12a6:	8556                	mv	a0,s5
    12a8:	00000097          	auipc	ra,0x0
    12ac:	e08080e7          	jalr	-504(ra) # 10b0 <putc>
    12b0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    12b2:	03c9d793          	srli	a5,s3,0x3c
    12b6:	97de                	add	a5,a5,s7
    12b8:	0007c583          	lbu	a1,0(a5)
    12bc:	8556                	mv	a0,s5
    12be:	00000097          	auipc	ra,0x0
    12c2:	df2080e7          	jalr	-526(ra) # 10b0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    12c6:	0992                	slli	s3,s3,0x4
    12c8:	397d                	addiw	s2,s2,-1
    12ca:	fe0914e3          	bnez	s2,12b2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    12ce:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    12d2:	4981                	li	s3,0
    12d4:	b721                	j	11dc <vprintf+0x60>
        s = va_arg(ap, char*);
    12d6:	008b0993          	addi	s3,s6,8
    12da:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    12de:	02090163          	beqz	s2,1300 <vprintf+0x184>
        while(*s != 0){
    12e2:	00094583          	lbu	a1,0(s2)
    12e6:	c9a1                	beqz	a1,1336 <vprintf+0x1ba>
          putc(fd, *s);
    12e8:	8556                	mv	a0,s5
    12ea:	00000097          	auipc	ra,0x0
    12ee:	dc6080e7          	jalr	-570(ra) # 10b0 <putc>
          s++;
    12f2:	0905                	addi	s2,s2,1
        while(*s != 0){
    12f4:	00094583          	lbu	a1,0(s2)
    12f8:	f9e5                	bnez	a1,12e8 <vprintf+0x16c>
        s = va_arg(ap, char*);
    12fa:	8b4e                	mv	s6,s3
      state = 0;
    12fc:	4981                	li	s3,0
    12fe:	bdf9                	j	11dc <vprintf+0x60>
          s = "(null)";
    1300:	00000917          	auipc	s2,0x0
    1304:	51890913          	addi	s2,s2,1304 # 1818 <malloc+0x3d2>
        while(*s != 0){
    1308:	02800593          	li	a1,40
    130c:	bff1                	j	12e8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    130e:	008b0913          	addi	s2,s6,8
    1312:	000b4583          	lbu	a1,0(s6)
    1316:	8556                	mv	a0,s5
    1318:	00000097          	auipc	ra,0x0
    131c:	d98080e7          	jalr	-616(ra) # 10b0 <putc>
    1320:	8b4a                	mv	s6,s2
      state = 0;
    1322:	4981                	li	s3,0
    1324:	bd65                	j	11dc <vprintf+0x60>
        putc(fd, c);
    1326:	85d2                	mv	a1,s4
    1328:	8556                	mv	a0,s5
    132a:	00000097          	auipc	ra,0x0
    132e:	d86080e7          	jalr	-634(ra) # 10b0 <putc>
      state = 0;
    1332:	4981                	li	s3,0
    1334:	b565                	j	11dc <vprintf+0x60>
        s = va_arg(ap, char*);
    1336:	8b4e                	mv	s6,s3
      state = 0;
    1338:	4981                	li	s3,0
    133a:	b54d                	j	11dc <vprintf+0x60>
    }
  }
}
    133c:	70e6                	ld	ra,120(sp)
    133e:	7446                	ld	s0,112(sp)
    1340:	74a6                	ld	s1,104(sp)
    1342:	7906                	ld	s2,96(sp)
    1344:	69e6                	ld	s3,88(sp)
    1346:	6a46                	ld	s4,80(sp)
    1348:	6aa6                	ld	s5,72(sp)
    134a:	6b06                	ld	s6,64(sp)
    134c:	7be2                	ld	s7,56(sp)
    134e:	7c42                	ld	s8,48(sp)
    1350:	7ca2                	ld	s9,40(sp)
    1352:	7d02                	ld	s10,32(sp)
    1354:	6de2                	ld	s11,24(sp)
    1356:	6109                	addi	sp,sp,128
    1358:	8082                	ret

000000000000135a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    135a:	715d                	addi	sp,sp,-80
    135c:	ec06                	sd	ra,24(sp)
    135e:	e822                	sd	s0,16(sp)
    1360:	1000                	addi	s0,sp,32
    1362:	e010                	sd	a2,0(s0)
    1364:	e414                	sd	a3,8(s0)
    1366:	e818                	sd	a4,16(s0)
    1368:	ec1c                	sd	a5,24(s0)
    136a:	03043023          	sd	a6,32(s0)
    136e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1372:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1376:	8622                	mv	a2,s0
    1378:	00000097          	auipc	ra,0x0
    137c:	e04080e7          	jalr	-508(ra) # 117c <vprintf>
}
    1380:	60e2                	ld	ra,24(sp)
    1382:	6442                	ld	s0,16(sp)
    1384:	6161                	addi	sp,sp,80
    1386:	8082                	ret

0000000000001388 <printf>:

void
printf(const char *fmt, ...)
{
    1388:	711d                	addi	sp,sp,-96
    138a:	ec06                	sd	ra,24(sp)
    138c:	e822                	sd	s0,16(sp)
    138e:	1000                	addi	s0,sp,32
    1390:	e40c                	sd	a1,8(s0)
    1392:	e810                	sd	a2,16(s0)
    1394:	ec14                	sd	a3,24(s0)
    1396:	f018                	sd	a4,32(s0)
    1398:	f41c                	sd	a5,40(s0)
    139a:	03043823          	sd	a6,48(s0)
    139e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    13a2:	00840613          	addi	a2,s0,8
    13a6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    13aa:	85aa                	mv	a1,a0
    13ac:	4505                	li	a0,1
    13ae:	00000097          	auipc	ra,0x0
    13b2:	dce080e7          	jalr	-562(ra) # 117c <vprintf>
}
    13b6:	60e2                	ld	ra,24(sp)
    13b8:	6442                	ld	s0,16(sp)
    13ba:	6125                	addi	sp,sp,96
    13bc:	8082                	ret

00000000000013be <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    13be:	1141                	addi	sp,sp,-16
    13c0:	e422                	sd	s0,8(sp)
    13c2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    13c4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    13c8:	00001797          	auipc	a5,0x1
    13cc:	c487b783          	ld	a5,-952(a5) # 2010 <freep>
    13d0:	a805                	j	1400 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    13d2:	4618                	lw	a4,8(a2)
    13d4:	9db9                	addw	a1,a1,a4
    13d6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    13da:	6398                	ld	a4,0(a5)
    13dc:	6318                	ld	a4,0(a4)
    13de:	fee53823          	sd	a4,-16(a0)
    13e2:	a091                	j	1426 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    13e4:	ff852703          	lw	a4,-8(a0)
    13e8:	9e39                	addw	a2,a2,a4
    13ea:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    13ec:	ff053703          	ld	a4,-16(a0)
    13f0:	e398                	sd	a4,0(a5)
    13f2:	a099                	j	1438 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    13f4:	6398                	ld	a4,0(a5)
    13f6:	00e7e463          	bltu	a5,a4,13fe <free+0x40>
    13fa:	00e6ea63          	bltu	a3,a4,140e <free+0x50>
{
    13fe:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1400:	fed7fae3          	bgeu	a5,a3,13f4 <free+0x36>
    1404:	6398                	ld	a4,0(a5)
    1406:	00e6e463          	bltu	a3,a4,140e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    140a:	fee7eae3          	bltu	a5,a4,13fe <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    140e:	ff852583          	lw	a1,-8(a0)
    1412:	6390                	ld	a2,0(a5)
    1414:	02059713          	slli	a4,a1,0x20
    1418:	9301                	srli	a4,a4,0x20
    141a:	0712                	slli	a4,a4,0x4
    141c:	9736                	add	a4,a4,a3
    141e:	fae60ae3          	beq	a2,a4,13d2 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1422:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1426:	4790                	lw	a2,8(a5)
    1428:	02061713          	slli	a4,a2,0x20
    142c:	9301                	srli	a4,a4,0x20
    142e:	0712                	slli	a4,a4,0x4
    1430:	973e                	add	a4,a4,a5
    1432:	fae689e3          	beq	a3,a4,13e4 <free+0x26>
  } else
    p->s.ptr = bp;
    1436:	e394                	sd	a3,0(a5)
  freep = p;
    1438:	00001717          	auipc	a4,0x1
    143c:	bcf73c23          	sd	a5,-1064(a4) # 2010 <freep>
}
    1440:	6422                	ld	s0,8(sp)
    1442:	0141                	addi	sp,sp,16
    1444:	8082                	ret

0000000000001446 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1446:	7139                	addi	sp,sp,-64
    1448:	fc06                	sd	ra,56(sp)
    144a:	f822                	sd	s0,48(sp)
    144c:	f426                	sd	s1,40(sp)
    144e:	f04a                	sd	s2,32(sp)
    1450:	ec4e                	sd	s3,24(sp)
    1452:	e852                	sd	s4,16(sp)
    1454:	e456                	sd	s5,8(sp)
    1456:	e05a                	sd	s6,0(sp)
    1458:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    145a:	02051493          	slli	s1,a0,0x20
    145e:	9081                	srli	s1,s1,0x20
    1460:	04bd                	addi	s1,s1,15
    1462:	8091                	srli	s1,s1,0x4
    1464:	0014899b          	addiw	s3,s1,1
    1468:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    146a:	00001517          	auipc	a0,0x1
    146e:	ba653503          	ld	a0,-1114(a0) # 2010 <freep>
    1472:	c515                	beqz	a0,149e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1474:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1476:	4798                	lw	a4,8(a5)
    1478:	02977f63          	bgeu	a4,s1,14b6 <malloc+0x70>
    147c:	8a4e                	mv	s4,s3
    147e:	0009871b          	sext.w	a4,s3
    1482:	6685                	lui	a3,0x1
    1484:	00d77363          	bgeu	a4,a3,148a <malloc+0x44>
    1488:	6a05                	lui	s4,0x1
    148a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    148e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1492:	00001917          	auipc	s2,0x1
    1496:	b7e90913          	addi	s2,s2,-1154 # 2010 <freep>
  if(p == (char*)-1)
    149a:	5afd                	li	s5,-1
    149c:	a88d                	j	150e <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    149e:	00001797          	auipc	a5,0x1
    14a2:	f6a78793          	addi	a5,a5,-150 # 2408 <base>
    14a6:	00001717          	auipc	a4,0x1
    14aa:	b6f73523          	sd	a5,-1174(a4) # 2010 <freep>
    14ae:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    14b0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    14b4:	b7e1                	j	147c <malloc+0x36>
      if(p->s.size == nunits)
    14b6:	02e48b63          	beq	s1,a4,14ec <malloc+0xa6>
        p->s.size -= nunits;
    14ba:	4137073b          	subw	a4,a4,s3
    14be:	c798                	sw	a4,8(a5)
        p += p->s.size;
    14c0:	1702                	slli	a4,a4,0x20
    14c2:	9301                	srli	a4,a4,0x20
    14c4:	0712                	slli	a4,a4,0x4
    14c6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    14c8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    14cc:	00001717          	auipc	a4,0x1
    14d0:	b4a73223          	sd	a0,-1212(a4) # 2010 <freep>
      return (void*)(p + 1);
    14d4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    14d8:	70e2                	ld	ra,56(sp)
    14da:	7442                	ld	s0,48(sp)
    14dc:	74a2                	ld	s1,40(sp)
    14de:	7902                	ld	s2,32(sp)
    14e0:	69e2                	ld	s3,24(sp)
    14e2:	6a42                	ld	s4,16(sp)
    14e4:	6aa2                	ld	s5,8(sp)
    14e6:	6b02                	ld	s6,0(sp)
    14e8:	6121                	addi	sp,sp,64
    14ea:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    14ec:	6398                	ld	a4,0(a5)
    14ee:	e118                	sd	a4,0(a0)
    14f0:	bff1                	j	14cc <malloc+0x86>
  hp->s.size = nu;
    14f2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    14f6:	0541                	addi	a0,a0,16
    14f8:	00000097          	auipc	ra,0x0
    14fc:	ec6080e7          	jalr	-314(ra) # 13be <free>
  return freep;
    1500:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1504:	d971                	beqz	a0,14d8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1506:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1508:	4798                	lw	a4,8(a5)
    150a:	fa9776e3          	bgeu	a4,s1,14b6 <malloc+0x70>
    if(p == freep)
    150e:	00093703          	ld	a4,0(s2)
    1512:	853e                	mv	a0,a5
    1514:	fef719e3          	bne	a4,a5,1506 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    1518:	8552                	mv	a0,s4
    151a:	00000097          	auipc	ra,0x0
    151e:	b76080e7          	jalr	-1162(ra) # 1090 <sbrk>
  if(p == (char*)-1)
    1522:	fd5518e3          	bne	a0,s5,14f2 <malloc+0xac>
        return 0;
    1526:	4501                	li	a0,0
    1528:	bf45                	j	14d8 <malloc+0x92>
