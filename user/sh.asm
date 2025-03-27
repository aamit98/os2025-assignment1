
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0,"");
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	35e58593          	addi	a1,a1,862 # 1370 <malloc+0xe8>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	e4e080e7          	jalr	-434(ra) # e6a <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	c24080e7          	jalr	-988(ra) # c4e <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	c5e080e7          	jalr	-930(ra) # c94 <gets>
  if(buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
  exit(0,"");
}

void
panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	31858593          	addi	a1,a1,792 # 1378 <malloc+0xf0>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	132080e7          	jalr	306(ra) # 119c <fprintf>
  exit(1,"");
      72:	00001597          	auipc	a1,0x1
      76:	30e58593          	addi	a1,a1,782 # 1380 <malloc+0xf8>
      7a:	4505                	li	a0,1
      7c:	00001097          	auipc	ra,0x1
      80:	dce080e7          	jalr	-562(ra) # e4a <exit>

0000000000000084 <fork1>:
}

int
fork1(void)
{
      84:	1141                	addi	sp,sp,-16
      86:	e406                	sd	ra,8(sp)
      88:	e022                	sd	s0,0(sp)
      8a:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      8c:	00001097          	auipc	ra,0x1
      90:	db6080e7          	jalr	-586(ra) # e42 <fork>
  if(pid == -1)
      94:	57fd                	li	a5,-1
      96:	00f50663          	beq	a0,a5,a2 <fork1+0x1e>
    panic("fork");
  return pid;
}
      9a:	60a2                	ld	ra,8(sp)
      9c:	6402                	ld	s0,0(sp)
      9e:	0141                	addi	sp,sp,16
      a0:	8082                	ret
    panic("fork");
      a2:	00001517          	auipc	a0,0x1
      a6:	2e650513          	addi	a0,a0,742 # 1388 <malloc+0x100>
      aa:	00000097          	auipc	ra,0x0
      ae:	fac080e7          	jalr	-84(ra) # 56 <panic>

00000000000000b2 <runcmd>:
{
      b2:	7179                	addi	sp,sp,-48
      b4:	f406                	sd	ra,40(sp)
      b6:	f022                	sd	s0,32(sp)
      b8:	ec26                	sd	s1,24(sp)
      ba:	1800                	addi	s0,sp,48
  if(cmd == 0)
      bc:	c10d                	beqz	a0,de <runcmd+0x2c>
      be:	84aa                	mv	s1,a0
  switch(cmd->type){
      c0:	4118                	lw	a4,0(a0)
      c2:	4795                	li	a5,5
      c4:	02e7e663          	bltu	a5,a4,f0 <runcmd+0x3e>
      c8:	00056783          	lwu	a5,0(a0)
      cc:	078a                	slli	a5,a5,0x2
      ce:	00001717          	auipc	a4,0x1
      d2:	3b670713          	addi	a4,a4,950 # 1484 <malloc+0x1fc>
      d6:	97ba                	add	a5,a5,a4
      d8:	439c                	lw	a5,0(a5)
      da:	97ba                	add	a5,a5,a4
      dc:	8782                	jr	a5
    exit(1,"");
      de:	00001597          	auipc	a1,0x1
      e2:	2a258593          	addi	a1,a1,674 # 1380 <malloc+0xf8>
      e6:	4505                	li	a0,1
      e8:	00001097          	auipc	ra,0x1
      ec:	d62080e7          	jalr	-670(ra) # e4a <exit>
    panic("runcmd");
      f0:	00001517          	auipc	a0,0x1
      f4:	2a050513          	addi	a0,a0,672 # 1390 <malloc+0x108>
      f8:	00000097          	auipc	ra,0x0
      fc:	f5e080e7          	jalr	-162(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
     100:	6508                	ld	a0,8(a0)
     102:	c915                	beqz	a0,136 <runcmd+0x84>
    exec(ecmd->argv[0], ecmd->argv);
     104:	00848593          	addi	a1,s1,8
     108:	00001097          	auipc	ra,0x1
     10c:	d7a080e7          	jalr	-646(ra) # e82 <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     110:	6490                	ld	a2,8(s1)
     112:	00001597          	auipc	a1,0x1
     116:	28658593          	addi	a1,a1,646 # 1398 <malloc+0x110>
     11a:	4509                	li	a0,2
     11c:	00001097          	auipc	ra,0x1
     120:	080080e7          	jalr	128(ra) # 119c <fprintf>
  exit(0,"");
     124:	00001597          	auipc	a1,0x1
     128:	25c58593          	addi	a1,a1,604 # 1380 <malloc+0xf8>
     12c:	4501                	li	a0,0
     12e:	00001097          	auipc	ra,0x1
     132:	d1c080e7          	jalr	-740(ra) # e4a <exit>
      exit(1,"");
     136:	00001597          	auipc	a1,0x1
     13a:	24a58593          	addi	a1,a1,586 # 1380 <malloc+0xf8>
     13e:	4505                	li	a0,1
     140:	00001097          	auipc	ra,0x1
     144:	d0a080e7          	jalr	-758(ra) # e4a <exit>
    close(rcmd->fd);
     148:	5148                	lw	a0,36(a0)
     14a:	00001097          	auipc	ra,0x1
     14e:	d28080e7          	jalr	-728(ra) # e72 <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     152:	508c                	lw	a1,32(s1)
     154:	6888                	ld	a0,16(s1)
     156:	00001097          	auipc	ra,0x1
     15a:	d34080e7          	jalr	-716(ra) # e8a <open>
     15e:	00054763          	bltz	a0,16c <runcmd+0xba>
    runcmd(rcmd->cmd);
     162:	6488                	ld	a0,8(s1)
     164:	00000097          	auipc	ra,0x0
     168:	f4e080e7          	jalr	-178(ra) # b2 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     16c:	6890                	ld	a2,16(s1)
     16e:	00001597          	auipc	a1,0x1
     172:	23a58593          	addi	a1,a1,570 # 13a8 <malloc+0x120>
     176:	4509                	li	a0,2
     178:	00001097          	auipc	ra,0x1
     17c:	024080e7          	jalr	36(ra) # 119c <fprintf>
      exit(1,"");
     180:	00001597          	auipc	a1,0x1
     184:	20058593          	addi	a1,a1,512 # 1380 <malloc+0xf8>
     188:	4505                	li	a0,1
     18a:	00001097          	auipc	ra,0x1
     18e:	cc0080e7          	jalr	-832(ra) # e4a <exit>
    if(fork1() == 0)
     192:	00000097          	auipc	ra,0x0
     196:	ef2080e7          	jalr	-270(ra) # 84 <fork1>
     19a:	e511                	bnez	a0,1a6 <runcmd+0xf4>
      runcmd(lcmd->left);
     19c:	6488                	ld	a0,8(s1)
     19e:	00000097          	auipc	ra,0x0
     1a2:	f14080e7          	jalr	-236(ra) # b2 <runcmd>
    wait(0,"");
     1a6:	00001597          	auipc	a1,0x1
     1aa:	1da58593          	addi	a1,a1,474 # 1380 <malloc+0xf8>
     1ae:	4501                	li	a0,0
     1b0:	00001097          	auipc	ra,0x1
     1b4:	ca2080e7          	jalr	-862(ra) # e52 <wait>
    runcmd(lcmd->right);
     1b8:	6888                	ld	a0,16(s1)
     1ba:	00000097          	auipc	ra,0x0
     1be:	ef8080e7          	jalr	-264(ra) # b2 <runcmd>
    if(pipe(p) < 0)
     1c2:	fd840513          	addi	a0,s0,-40
     1c6:	00001097          	auipc	ra,0x1
     1ca:	c94080e7          	jalr	-876(ra) # e5a <pipe>
     1ce:	04054363          	bltz	a0,214 <runcmd+0x162>
    if(fork1() == 0){
     1d2:	00000097          	auipc	ra,0x0
     1d6:	eb2080e7          	jalr	-334(ra) # 84 <fork1>
     1da:	e529                	bnez	a0,224 <runcmd+0x172>
      close(1);
     1dc:	4505                	li	a0,1
     1de:	00001097          	auipc	ra,0x1
     1e2:	c94080e7          	jalr	-876(ra) # e72 <close>
      dup(p[1]);
     1e6:	fdc42503          	lw	a0,-36(s0)
     1ea:	00001097          	auipc	ra,0x1
     1ee:	cd8080e7          	jalr	-808(ra) # ec2 <dup>
      close(p[0]);
     1f2:	fd842503          	lw	a0,-40(s0)
     1f6:	00001097          	auipc	ra,0x1
     1fa:	c7c080e7          	jalr	-900(ra) # e72 <close>
      close(p[1]);
     1fe:	fdc42503          	lw	a0,-36(s0)
     202:	00001097          	auipc	ra,0x1
     206:	c70080e7          	jalr	-912(ra) # e72 <close>
      runcmd(pcmd->left);
     20a:	6488                	ld	a0,8(s1)
     20c:	00000097          	auipc	ra,0x0
     210:	ea6080e7          	jalr	-346(ra) # b2 <runcmd>
      panic("pipe");
     214:	00001517          	auipc	a0,0x1
     218:	1a450513          	addi	a0,a0,420 # 13b8 <malloc+0x130>
     21c:	00000097          	auipc	ra,0x0
     220:	e3a080e7          	jalr	-454(ra) # 56 <panic>
    if(fork1() == 0){
     224:	00000097          	auipc	ra,0x0
     228:	e60080e7          	jalr	-416(ra) # 84 <fork1>
     22c:	ed05                	bnez	a0,264 <runcmd+0x1b2>
      close(0);
     22e:	00001097          	auipc	ra,0x1
     232:	c44080e7          	jalr	-956(ra) # e72 <close>
      dup(p[0]);
     236:	fd842503          	lw	a0,-40(s0)
     23a:	00001097          	auipc	ra,0x1
     23e:	c88080e7          	jalr	-888(ra) # ec2 <dup>
      close(p[0]);
     242:	fd842503          	lw	a0,-40(s0)
     246:	00001097          	auipc	ra,0x1
     24a:	c2c080e7          	jalr	-980(ra) # e72 <close>
      close(p[1]);
     24e:	fdc42503          	lw	a0,-36(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c20080e7          	jalr	-992(ra) # e72 <close>
      runcmd(pcmd->right);
     25a:	6888                	ld	a0,16(s1)
     25c:	00000097          	auipc	ra,0x0
     260:	e56080e7          	jalr	-426(ra) # b2 <runcmd>
    close(p[0]);
     264:	fd842503          	lw	a0,-40(s0)
     268:	00001097          	auipc	ra,0x1
     26c:	c0a080e7          	jalr	-1014(ra) # e72 <close>
    close(p[1]);
     270:	fdc42503          	lw	a0,-36(s0)
     274:	00001097          	auipc	ra,0x1
     278:	bfe080e7          	jalr	-1026(ra) # e72 <close>
    wait(0,"");
     27c:	00001597          	auipc	a1,0x1
     280:	10458593          	addi	a1,a1,260 # 1380 <malloc+0xf8>
     284:	4501                	li	a0,0
     286:	00001097          	auipc	ra,0x1
     28a:	bcc080e7          	jalr	-1076(ra) # e52 <wait>
    wait(0,"");
     28e:	00001597          	auipc	a1,0x1
     292:	0f258593          	addi	a1,a1,242 # 1380 <malloc+0xf8>
     296:	4501                	li	a0,0
     298:	00001097          	auipc	ra,0x1
     29c:	bba080e7          	jalr	-1094(ra) # e52 <wait>
    break;
     2a0:	b551                	j	124 <runcmd+0x72>
    if(fork1() == 0)
     2a2:	00000097          	auipc	ra,0x0
     2a6:	de2080e7          	jalr	-542(ra) # 84 <fork1>
     2aa:	e6051de3          	bnez	a0,124 <runcmd+0x72>
      runcmd(bcmd->cmd);
     2ae:	6488                	ld	a0,8(s1)
     2b0:	00000097          	auipc	ra,0x0
     2b4:	e02080e7          	jalr	-510(ra) # b2 <runcmd>

00000000000002b8 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     2b8:	1101                	addi	sp,sp,-32
     2ba:	ec06                	sd	ra,24(sp)
     2bc:	e822                	sd	s0,16(sp)
     2be:	e426                	sd	s1,8(sp)
     2c0:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2c2:	0a800513          	li	a0,168
     2c6:	00001097          	auipc	ra,0x1
     2ca:	fc2080e7          	jalr	-62(ra) # 1288 <malloc>
     2ce:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2d0:	0a800613          	li	a2,168
     2d4:	4581                	li	a1,0
     2d6:	00001097          	auipc	ra,0x1
     2da:	978080e7          	jalr	-1672(ra) # c4e <memset>
  cmd->type = EXEC;
     2de:	4785                	li	a5,1
     2e0:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2e2:	8526                	mv	a0,s1
     2e4:	60e2                	ld	ra,24(sp)
     2e6:	6442                	ld	s0,16(sp)
     2e8:	64a2                	ld	s1,8(sp)
     2ea:	6105                	addi	sp,sp,32
     2ec:	8082                	ret

00000000000002ee <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2ee:	7139                	addi	sp,sp,-64
     2f0:	fc06                	sd	ra,56(sp)
     2f2:	f822                	sd	s0,48(sp)
     2f4:	f426                	sd	s1,40(sp)
     2f6:	f04a                	sd	s2,32(sp)
     2f8:	ec4e                	sd	s3,24(sp)
     2fa:	e852                	sd	s4,16(sp)
     2fc:	e456                	sd	s5,8(sp)
     2fe:	e05a                	sd	s6,0(sp)
     300:	0080                	addi	s0,sp,64
     302:	8b2a                	mv	s6,a0
     304:	8aae                	mv	s5,a1
     306:	8a32                	mv	s4,a2
     308:	89b6                	mv	s3,a3
     30a:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     30c:	02800513          	li	a0,40
     310:	00001097          	auipc	ra,0x1
     314:	f78080e7          	jalr	-136(ra) # 1288 <malloc>
     318:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     31a:	02800613          	li	a2,40
     31e:	4581                	li	a1,0
     320:	00001097          	auipc	ra,0x1
     324:	92e080e7          	jalr	-1746(ra) # c4e <memset>
  cmd->type = REDIR;
     328:	4789                	li	a5,2
     32a:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     32c:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     330:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     334:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     338:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     33c:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     340:	8526                	mv	a0,s1
     342:	70e2                	ld	ra,56(sp)
     344:	7442                	ld	s0,48(sp)
     346:	74a2                	ld	s1,40(sp)
     348:	7902                	ld	s2,32(sp)
     34a:	69e2                	ld	s3,24(sp)
     34c:	6a42                	ld	s4,16(sp)
     34e:	6aa2                	ld	s5,8(sp)
     350:	6b02                	ld	s6,0(sp)
     352:	6121                	addi	sp,sp,64
     354:	8082                	ret

0000000000000356 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     356:	7179                	addi	sp,sp,-48
     358:	f406                	sd	ra,40(sp)
     35a:	f022                	sd	s0,32(sp)
     35c:	ec26                	sd	s1,24(sp)
     35e:	e84a                	sd	s2,16(sp)
     360:	e44e                	sd	s3,8(sp)
     362:	1800                	addi	s0,sp,48
     364:	89aa                	mv	s3,a0
     366:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     368:	4561                	li	a0,24
     36a:	00001097          	auipc	ra,0x1
     36e:	f1e080e7          	jalr	-226(ra) # 1288 <malloc>
     372:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     374:	4661                	li	a2,24
     376:	4581                	li	a1,0
     378:	00001097          	auipc	ra,0x1
     37c:	8d6080e7          	jalr	-1834(ra) # c4e <memset>
  cmd->type = PIPE;
     380:	478d                	li	a5,3
     382:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     384:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     388:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     38c:	8526                	mv	a0,s1
     38e:	70a2                	ld	ra,40(sp)
     390:	7402                	ld	s0,32(sp)
     392:	64e2                	ld	s1,24(sp)
     394:	6942                	ld	s2,16(sp)
     396:	69a2                	ld	s3,8(sp)
     398:	6145                	addi	sp,sp,48
     39a:	8082                	ret

000000000000039c <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     39c:	7179                	addi	sp,sp,-48
     39e:	f406                	sd	ra,40(sp)
     3a0:	f022                	sd	s0,32(sp)
     3a2:	ec26                	sd	s1,24(sp)
     3a4:	e84a                	sd	s2,16(sp)
     3a6:	e44e                	sd	s3,8(sp)
     3a8:	1800                	addi	s0,sp,48
     3aa:	89aa                	mv	s3,a0
     3ac:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3ae:	4561                	li	a0,24
     3b0:	00001097          	auipc	ra,0x1
     3b4:	ed8080e7          	jalr	-296(ra) # 1288 <malloc>
     3b8:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3ba:	4661                	li	a2,24
     3bc:	4581                	li	a1,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	890080e7          	jalr	-1904(ra) # c4e <memset>
  cmd->type = LIST;
     3c6:	4791                	li	a5,4
     3c8:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     3ca:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     3ce:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     3d2:	8526                	mv	a0,s1
     3d4:	70a2                	ld	ra,40(sp)
     3d6:	7402                	ld	s0,32(sp)
     3d8:	64e2                	ld	s1,24(sp)
     3da:	6942                	ld	s2,16(sp)
     3dc:	69a2                	ld	s3,8(sp)
     3de:	6145                	addi	sp,sp,48
     3e0:	8082                	ret

00000000000003e2 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3e2:	1101                	addi	sp,sp,-32
     3e4:	ec06                	sd	ra,24(sp)
     3e6:	e822                	sd	s0,16(sp)
     3e8:	e426                	sd	s1,8(sp)
     3ea:	e04a                	sd	s2,0(sp)
     3ec:	1000                	addi	s0,sp,32
     3ee:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3f0:	4541                	li	a0,16
     3f2:	00001097          	auipc	ra,0x1
     3f6:	e96080e7          	jalr	-362(ra) # 1288 <malloc>
     3fa:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3fc:	4641                	li	a2,16
     3fe:	4581                	li	a1,0
     400:	00001097          	auipc	ra,0x1
     404:	84e080e7          	jalr	-1970(ra) # c4e <memset>
  cmd->type = BACK;
     408:	4795                	li	a5,5
     40a:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     40c:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     410:	8526                	mv	a0,s1
     412:	60e2                	ld	ra,24(sp)
     414:	6442                	ld	s0,16(sp)
     416:	64a2                	ld	s1,8(sp)
     418:	6902                	ld	s2,0(sp)
     41a:	6105                	addi	sp,sp,32
     41c:	8082                	ret

000000000000041e <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     41e:	7139                	addi	sp,sp,-64
     420:	fc06                	sd	ra,56(sp)
     422:	f822                	sd	s0,48(sp)
     424:	f426                	sd	s1,40(sp)
     426:	f04a                	sd	s2,32(sp)
     428:	ec4e                	sd	s3,24(sp)
     42a:	e852                	sd	s4,16(sp)
     42c:	e456                	sd	s5,8(sp)
     42e:	e05a                	sd	s6,0(sp)
     430:	0080                	addi	s0,sp,64
     432:	8a2a                	mv	s4,a0
     434:	892e                	mv	s2,a1
     436:	8ab2                	mv	s5,a2
     438:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     43a:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     43c:	00002997          	auipc	s3,0x2
     440:	bcc98993          	addi	s3,s3,-1076 # 2008 <whitespace>
     444:	00b4fd63          	bgeu	s1,a1,45e <gettoken+0x40>
     448:	0004c583          	lbu	a1,0(s1)
     44c:	854e                	mv	a0,s3
     44e:	00001097          	auipc	ra,0x1
     452:	822080e7          	jalr	-2014(ra) # c70 <strchr>
     456:	c501                	beqz	a0,45e <gettoken+0x40>
    s++;
     458:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     45a:	fe9917e3          	bne	s2,s1,448 <gettoken+0x2a>
  if(q)
     45e:	000a8463          	beqz	s5,466 <gettoken+0x48>
    *q = s;
     462:	009ab023          	sd	s1,0(s5)
  ret = *s;
     466:	0004c783          	lbu	a5,0(s1)
     46a:	00078a9b          	sext.w	s5,a5
  switch(*s){
     46e:	03c00713          	li	a4,60
     472:	06f76563          	bltu	a4,a5,4dc <gettoken+0xbe>
     476:	03a00713          	li	a4,58
     47a:	00f76e63          	bltu	a4,a5,496 <gettoken+0x78>
     47e:	cf89                	beqz	a5,498 <gettoken+0x7a>
     480:	02600713          	li	a4,38
     484:	00e78963          	beq	a5,a4,496 <gettoken+0x78>
     488:	fd87879b          	addiw	a5,a5,-40
     48c:	0ff7f793          	andi	a5,a5,255
     490:	4705                	li	a4,1
     492:	06f76c63          	bltu	a4,a5,50a <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     496:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     498:	000b0463          	beqz	s6,4a0 <gettoken+0x82>
    *eq = s;
     49c:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     4a0:	00002997          	auipc	s3,0x2
     4a4:	b6898993          	addi	s3,s3,-1176 # 2008 <whitespace>
     4a8:	0124fd63          	bgeu	s1,s2,4c2 <gettoken+0xa4>
     4ac:	0004c583          	lbu	a1,0(s1)
     4b0:	854e                	mv	a0,s3
     4b2:	00000097          	auipc	ra,0x0
     4b6:	7be080e7          	jalr	1982(ra) # c70 <strchr>
     4ba:	c501                	beqz	a0,4c2 <gettoken+0xa4>
    s++;
     4bc:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     4be:	fe9917e3          	bne	s2,s1,4ac <gettoken+0x8e>
  *ps = s;
     4c2:	009a3023          	sd	s1,0(s4)
  return ret;
}
     4c6:	8556                	mv	a0,s5
     4c8:	70e2                	ld	ra,56(sp)
     4ca:	7442                	ld	s0,48(sp)
     4cc:	74a2                	ld	s1,40(sp)
     4ce:	7902                	ld	s2,32(sp)
     4d0:	69e2                	ld	s3,24(sp)
     4d2:	6a42                	ld	s4,16(sp)
     4d4:	6aa2                	ld	s5,8(sp)
     4d6:	6b02                	ld	s6,0(sp)
     4d8:	6121                	addi	sp,sp,64
     4da:	8082                	ret
  switch(*s){
     4dc:	03e00713          	li	a4,62
     4e0:	02e79163          	bne	a5,a4,502 <gettoken+0xe4>
    s++;
     4e4:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     4e8:	0014c703          	lbu	a4,1(s1)
     4ec:	03e00793          	li	a5,62
      s++;
     4f0:	0489                	addi	s1,s1,2
      ret = '+';
     4f2:	02b00a93          	li	s5,43
    if(*s == '>'){
     4f6:	faf701e3          	beq	a4,a5,498 <gettoken+0x7a>
    s++;
     4fa:	84b6                	mv	s1,a3
  ret = *s;
     4fc:	03e00a93          	li	s5,62
     500:	bf61                	j	498 <gettoken+0x7a>
  switch(*s){
     502:	07c00713          	li	a4,124
     506:	f8e788e3          	beq	a5,a4,496 <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     50a:	00002997          	auipc	s3,0x2
     50e:	afe98993          	addi	s3,s3,-1282 # 2008 <whitespace>
     512:	00002a97          	auipc	s5,0x2
     516:	aeea8a93          	addi	s5,s5,-1298 # 2000 <symbols>
     51a:	0324f563          	bgeu	s1,s2,544 <gettoken+0x126>
     51e:	0004c583          	lbu	a1,0(s1)
     522:	854e                	mv	a0,s3
     524:	00000097          	auipc	ra,0x0
     528:	74c080e7          	jalr	1868(ra) # c70 <strchr>
     52c:	e505                	bnez	a0,554 <gettoken+0x136>
     52e:	0004c583          	lbu	a1,0(s1)
     532:	8556                	mv	a0,s5
     534:	00000097          	auipc	ra,0x0
     538:	73c080e7          	jalr	1852(ra) # c70 <strchr>
     53c:	e909                	bnez	a0,54e <gettoken+0x130>
      s++;
     53e:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     540:	fc991fe3          	bne	s2,s1,51e <gettoken+0x100>
  if(eq)
     544:	06100a93          	li	s5,97
     548:	f40b1ae3          	bnez	s6,49c <gettoken+0x7e>
     54c:	bf9d                	j	4c2 <gettoken+0xa4>
    ret = 'a';
     54e:	06100a93          	li	s5,97
     552:	b799                	j	498 <gettoken+0x7a>
     554:	06100a93          	li	s5,97
     558:	b781                	j	498 <gettoken+0x7a>

000000000000055a <peek>:

int
peek(char **ps, char *es, char *toks)
{
     55a:	7139                	addi	sp,sp,-64
     55c:	fc06                	sd	ra,56(sp)
     55e:	f822                	sd	s0,48(sp)
     560:	f426                	sd	s1,40(sp)
     562:	f04a                	sd	s2,32(sp)
     564:	ec4e                	sd	s3,24(sp)
     566:	e852                	sd	s4,16(sp)
     568:	e456                	sd	s5,8(sp)
     56a:	0080                	addi	s0,sp,64
     56c:	8a2a                	mv	s4,a0
     56e:	892e                	mv	s2,a1
     570:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     572:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     574:	00002997          	auipc	s3,0x2
     578:	a9498993          	addi	s3,s3,-1388 # 2008 <whitespace>
     57c:	00b4fd63          	bgeu	s1,a1,596 <peek+0x3c>
     580:	0004c583          	lbu	a1,0(s1)
     584:	854e                	mv	a0,s3
     586:	00000097          	auipc	ra,0x0
     58a:	6ea080e7          	jalr	1770(ra) # c70 <strchr>
     58e:	c501                	beqz	a0,596 <peek+0x3c>
    s++;
     590:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     592:	fe9917e3          	bne	s2,s1,580 <peek+0x26>
  *ps = s;
     596:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     59a:	0004c583          	lbu	a1,0(s1)
     59e:	4501                	li	a0,0
     5a0:	e991                	bnez	a1,5b4 <peek+0x5a>
}
     5a2:	70e2                	ld	ra,56(sp)
     5a4:	7442                	ld	s0,48(sp)
     5a6:	74a2                	ld	s1,40(sp)
     5a8:	7902                	ld	s2,32(sp)
     5aa:	69e2                	ld	s3,24(sp)
     5ac:	6a42                	ld	s4,16(sp)
     5ae:	6aa2                	ld	s5,8(sp)
     5b0:	6121                	addi	sp,sp,64
     5b2:	8082                	ret
  return *s && strchr(toks, *s);
     5b4:	8556                	mv	a0,s5
     5b6:	00000097          	auipc	ra,0x0
     5ba:	6ba080e7          	jalr	1722(ra) # c70 <strchr>
     5be:	00a03533          	snez	a0,a0
     5c2:	b7c5                	j	5a2 <peek+0x48>

00000000000005c4 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     5c4:	7159                	addi	sp,sp,-112
     5c6:	f486                	sd	ra,104(sp)
     5c8:	f0a2                	sd	s0,96(sp)
     5ca:	eca6                	sd	s1,88(sp)
     5cc:	e8ca                	sd	s2,80(sp)
     5ce:	e4ce                	sd	s3,72(sp)
     5d0:	e0d2                	sd	s4,64(sp)
     5d2:	fc56                	sd	s5,56(sp)
     5d4:	f85a                	sd	s6,48(sp)
     5d6:	f45e                	sd	s7,40(sp)
     5d8:	f062                	sd	s8,32(sp)
     5da:	ec66                	sd	s9,24(sp)
     5dc:	1880                	addi	s0,sp,112
     5de:	8a2a                	mv	s4,a0
     5e0:	89ae                	mv	s3,a1
     5e2:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5e4:	00001b97          	auipc	s7,0x1
     5e8:	dfcb8b93          	addi	s7,s7,-516 # 13e0 <malloc+0x158>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5ec:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     5f0:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     5f4:	a02d                	j	61e <parseredirs+0x5a>
      panic("missing file for redirection");
     5f6:	00001517          	auipc	a0,0x1
     5fa:	dca50513          	addi	a0,a0,-566 # 13c0 <malloc+0x138>
     5fe:	00000097          	auipc	ra,0x0
     602:	a58080e7          	jalr	-1448(ra) # 56 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     606:	4701                	li	a4,0
     608:	4681                	li	a3,0
     60a:	f9043603          	ld	a2,-112(s0)
     60e:	f9843583          	ld	a1,-104(s0)
     612:	8552                	mv	a0,s4
     614:	00000097          	auipc	ra,0x0
     618:	cda080e7          	jalr	-806(ra) # 2ee <redircmd>
     61c:	8a2a                	mv	s4,a0
    switch(tok){
     61e:	03e00b13          	li	s6,62
     622:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     626:	865e                	mv	a2,s7
     628:	85ca                	mv	a1,s2
     62a:	854e                	mv	a0,s3
     62c:	00000097          	auipc	ra,0x0
     630:	f2e080e7          	jalr	-210(ra) # 55a <peek>
     634:	c925                	beqz	a0,6a4 <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     636:	4681                	li	a3,0
     638:	4601                	li	a2,0
     63a:	85ca                	mv	a1,s2
     63c:	854e                	mv	a0,s3
     63e:	00000097          	auipc	ra,0x0
     642:	de0080e7          	jalr	-544(ra) # 41e <gettoken>
     646:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     648:	f9040693          	addi	a3,s0,-112
     64c:	f9840613          	addi	a2,s0,-104
     650:	85ca                	mv	a1,s2
     652:	854e                	mv	a0,s3
     654:	00000097          	auipc	ra,0x0
     658:	dca080e7          	jalr	-566(ra) # 41e <gettoken>
     65c:	f9851de3          	bne	a0,s8,5f6 <parseredirs+0x32>
    switch(tok){
     660:	fb9483e3          	beq	s1,s9,606 <parseredirs+0x42>
     664:	03648263          	beq	s1,s6,688 <parseredirs+0xc4>
     668:	fb549fe3          	bne	s1,s5,626 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     66c:	4705                	li	a4,1
     66e:	20100693          	li	a3,513
     672:	f9043603          	ld	a2,-112(s0)
     676:	f9843583          	ld	a1,-104(s0)
     67a:	8552                	mv	a0,s4
     67c:	00000097          	auipc	ra,0x0
     680:	c72080e7          	jalr	-910(ra) # 2ee <redircmd>
     684:	8a2a                	mv	s4,a0
      break;
     686:	bf61                	j	61e <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     688:	4705                	li	a4,1
     68a:	60100693          	li	a3,1537
     68e:	f9043603          	ld	a2,-112(s0)
     692:	f9843583          	ld	a1,-104(s0)
     696:	8552                	mv	a0,s4
     698:	00000097          	auipc	ra,0x0
     69c:	c56080e7          	jalr	-938(ra) # 2ee <redircmd>
     6a0:	8a2a                	mv	s4,a0
      break;
     6a2:	bfb5                	j	61e <parseredirs+0x5a>
    }
  }
  return cmd;
}
     6a4:	8552                	mv	a0,s4
     6a6:	70a6                	ld	ra,104(sp)
     6a8:	7406                	ld	s0,96(sp)
     6aa:	64e6                	ld	s1,88(sp)
     6ac:	6946                	ld	s2,80(sp)
     6ae:	69a6                	ld	s3,72(sp)
     6b0:	6a06                	ld	s4,64(sp)
     6b2:	7ae2                	ld	s5,56(sp)
     6b4:	7b42                	ld	s6,48(sp)
     6b6:	7ba2                	ld	s7,40(sp)
     6b8:	7c02                	ld	s8,32(sp)
     6ba:	6ce2                	ld	s9,24(sp)
     6bc:	6165                	addi	sp,sp,112
     6be:	8082                	ret

00000000000006c0 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     6c0:	7159                	addi	sp,sp,-112
     6c2:	f486                	sd	ra,104(sp)
     6c4:	f0a2                	sd	s0,96(sp)
     6c6:	eca6                	sd	s1,88(sp)
     6c8:	e8ca                	sd	s2,80(sp)
     6ca:	e4ce                	sd	s3,72(sp)
     6cc:	e0d2                	sd	s4,64(sp)
     6ce:	fc56                	sd	s5,56(sp)
     6d0:	f85a                	sd	s6,48(sp)
     6d2:	f45e                	sd	s7,40(sp)
     6d4:	f062                	sd	s8,32(sp)
     6d6:	ec66                	sd	s9,24(sp)
     6d8:	1880                	addi	s0,sp,112
     6da:	8a2a                	mv	s4,a0
     6dc:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6de:	00001617          	auipc	a2,0x1
     6e2:	d0a60613          	addi	a2,a2,-758 # 13e8 <malloc+0x160>
     6e6:	00000097          	auipc	ra,0x0
     6ea:	e74080e7          	jalr	-396(ra) # 55a <peek>
     6ee:	e905                	bnez	a0,71e <parseexec+0x5e>
     6f0:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     6f2:	00000097          	auipc	ra,0x0
     6f6:	bc6080e7          	jalr	-1082(ra) # 2b8 <execcmd>
     6fa:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6fc:	8656                	mv	a2,s5
     6fe:	85d2                	mv	a1,s4
     700:	00000097          	auipc	ra,0x0
     704:	ec4080e7          	jalr	-316(ra) # 5c4 <parseredirs>
     708:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     70a:	008c0913          	addi	s2,s8,8
     70e:	00001b17          	auipc	s6,0x1
     712:	cfab0b13          	addi	s6,s6,-774 # 1408 <malloc+0x180>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     716:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     71a:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     71c:	a0b1                	j	768 <parseexec+0xa8>
    return parseblock(ps, es);
     71e:	85d6                	mv	a1,s5
     720:	8552                	mv	a0,s4
     722:	00000097          	auipc	ra,0x0
     726:	1bc080e7          	jalr	444(ra) # 8de <parseblock>
     72a:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     72c:	8526                	mv	a0,s1
     72e:	70a6                	ld	ra,104(sp)
     730:	7406                	ld	s0,96(sp)
     732:	64e6                	ld	s1,88(sp)
     734:	6946                	ld	s2,80(sp)
     736:	69a6                	ld	s3,72(sp)
     738:	6a06                	ld	s4,64(sp)
     73a:	7ae2                	ld	s5,56(sp)
     73c:	7b42                	ld	s6,48(sp)
     73e:	7ba2                	ld	s7,40(sp)
     740:	7c02                	ld	s8,32(sp)
     742:	6ce2                	ld	s9,24(sp)
     744:	6165                	addi	sp,sp,112
     746:	8082                	ret
      panic("syntax");
     748:	00001517          	auipc	a0,0x1
     74c:	ca850513          	addi	a0,a0,-856 # 13f0 <malloc+0x168>
     750:	00000097          	auipc	ra,0x0
     754:	906080e7          	jalr	-1786(ra) # 56 <panic>
    ret = parseredirs(ret, ps, es);
     758:	8656                	mv	a2,s5
     75a:	85d2                	mv	a1,s4
     75c:	8526                	mv	a0,s1
     75e:	00000097          	auipc	ra,0x0
     762:	e66080e7          	jalr	-410(ra) # 5c4 <parseredirs>
     766:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     768:	865a                	mv	a2,s6
     76a:	85d6                	mv	a1,s5
     76c:	8552                	mv	a0,s4
     76e:	00000097          	auipc	ra,0x0
     772:	dec080e7          	jalr	-532(ra) # 55a <peek>
     776:	e131                	bnez	a0,7ba <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     778:	f9040693          	addi	a3,s0,-112
     77c:	f9840613          	addi	a2,s0,-104
     780:	85d6                	mv	a1,s5
     782:	8552                	mv	a0,s4
     784:	00000097          	auipc	ra,0x0
     788:	c9a080e7          	jalr	-870(ra) # 41e <gettoken>
     78c:	c51d                	beqz	a0,7ba <parseexec+0xfa>
    if(tok != 'a')
     78e:	fb951de3          	bne	a0,s9,748 <parseexec+0x88>
    cmd->argv[argc] = q;
     792:	f9843783          	ld	a5,-104(s0)
     796:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     79a:	f9043783          	ld	a5,-112(s0)
     79e:	04f93823          	sd	a5,80(s2)
    argc++;
     7a2:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     7a4:	0921                	addi	s2,s2,8
     7a6:	fb7999e3          	bne	s3,s7,758 <parseexec+0x98>
      panic("too many args");
     7aa:	00001517          	auipc	a0,0x1
     7ae:	c4e50513          	addi	a0,a0,-946 # 13f8 <malloc+0x170>
     7b2:	00000097          	auipc	ra,0x0
     7b6:	8a4080e7          	jalr	-1884(ra) # 56 <panic>
  cmd->argv[argc] = 0;
     7ba:	098e                	slli	s3,s3,0x3
     7bc:	99e2                	add	s3,s3,s8
     7be:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     7c2:	0409bc23          	sd	zero,88(s3)
  return ret;
     7c6:	b79d                	j	72c <parseexec+0x6c>

00000000000007c8 <parsepipe>:
{
     7c8:	7179                	addi	sp,sp,-48
     7ca:	f406                	sd	ra,40(sp)
     7cc:	f022                	sd	s0,32(sp)
     7ce:	ec26                	sd	s1,24(sp)
     7d0:	e84a                	sd	s2,16(sp)
     7d2:	e44e                	sd	s3,8(sp)
     7d4:	1800                	addi	s0,sp,48
     7d6:	892a                	mv	s2,a0
     7d8:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7da:	00000097          	auipc	ra,0x0
     7de:	ee6080e7          	jalr	-282(ra) # 6c0 <parseexec>
     7e2:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7e4:	00001617          	auipc	a2,0x1
     7e8:	c2c60613          	addi	a2,a2,-980 # 1410 <malloc+0x188>
     7ec:	85ce                	mv	a1,s3
     7ee:	854a                	mv	a0,s2
     7f0:	00000097          	auipc	ra,0x0
     7f4:	d6a080e7          	jalr	-662(ra) # 55a <peek>
     7f8:	e909                	bnez	a0,80a <parsepipe+0x42>
}
     7fa:	8526                	mv	a0,s1
     7fc:	70a2                	ld	ra,40(sp)
     7fe:	7402                	ld	s0,32(sp)
     800:	64e2                	ld	s1,24(sp)
     802:	6942                	ld	s2,16(sp)
     804:	69a2                	ld	s3,8(sp)
     806:	6145                	addi	sp,sp,48
     808:	8082                	ret
    gettoken(ps, es, 0, 0);
     80a:	4681                	li	a3,0
     80c:	4601                	li	a2,0
     80e:	85ce                	mv	a1,s3
     810:	854a                	mv	a0,s2
     812:	00000097          	auipc	ra,0x0
     816:	c0c080e7          	jalr	-1012(ra) # 41e <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     81a:	85ce                	mv	a1,s3
     81c:	854a                	mv	a0,s2
     81e:	00000097          	auipc	ra,0x0
     822:	faa080e7          	jalr	-86(ra) # 7c8 <parsepipe>
     826:	85aa                	mv	a1,a0
     828:	8526                	mv	a0,s1
     82a:	00000097          	auipc	ra,0x0
     82e:	b2c080e7          	jalr	-1236(ra) # 356 <pipecmd>
     832:	84aa                	mv	s1,a0
  return cmd;
     834:	b7d9                	j	7fa <parsepipe+0x32>

0000000000000836 <parseline>:
{
     836:	7179                	addi	sp,sp,-48
     838:	f406                	sd	ra,40(sp)
     83a:	f022                	sd	s0,32(sp)
     83c:	ec26                	sd	s1,24(sp)
     83e:	e84a                	sd	s2,16(sp)
     840:	e44e                	sd	s3,8(sp)
     842:	e052                	sd	s4,0(sp)
     844:	1800                	addi	s0,sp,48
     846:	892a                	mv	s2,a0
     848:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     84a:	00000097          	auipc	ra,0x0
     84e:	f7e080e7          	jalr	-130(ra) # 7c8 <parsepipe>
     852:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     854:	00001a17          	auipc	s4,0x1
     858:	bc4a0a13          	addi	s4,s4,-1084 # 1418 <malloc+0x190>
     85c:	a839                	j	87a <parseline+0x44>
    gettoken(ps, es, 0, 0);
     85e:	4681                	li	a3,0
     860:	4601                	li	a2,0
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00000097          	auipc	ra,0x0
     86a:	bb8080e7          	jalr	-1096(ra) # 41e <gettoken>
    cmd = backcmd(cmd);
     86e:	8526                	mv	a0,s1
     870:	00000097          	auipc	ra,0x0
     874:	b72080e7          	jalr	-1166(ra) # 3e2 <backcmd>
     878:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     87a:	8652                	mv	a2,s4
     87c:	85ce                	mv	a1,s3
     87e:	854a                	mv	a0,s2
     880:	00000097          	auipc	ra,0x0
     884:	cda080e7          	jalr	-806(ra) # 55a <peek>
     888:	f979                	bnez	a0,85e <parseline+0x28>
  if(peek(ps, es, ";")){
     88a:	00001617          	auipc	a2,0x1
     88e:	b9660613          	addi	a2,a2,-1130 # 1420 <malloc+0x198>
     892:	85ce                	mv	a1,s3
     894:	854a                	mv	a0,s2
     896:	00000097          	auipc	ra,0x0
     89a:	cc4080e7          	jalr	-828(ra) # 55a <peek>
     89e:	e911                	bnez	a0,8b2 <parseline+0x7c>
}
     8a0:	8526                	mv	a0,s1
     8a2:	70a2                	ld	ra,40(sp)
     8a4:	7402                	ld	s0,32(sp)
     8a6:	64e2                	ld	s1,24(sp)
     8a8:	6942                	ld	s2,16(sp)
     8aa:	69a2                	ld	s3,8(sp)
     8ac:	6a02                	ld	s4,0(sp)
     8ae:	6145                	addi	sp,sp,48
     8b0:	8082                	ret
    gettoken(ps, es, 0, 0);
     8b2:	4681                	li	a3,0
     8b4:	4601                	li	a2,0
     8b6:	85ce                	mv	a1,s3
     8b8:	854a                	mv	a0,s2
     8ba:	00000097          	auipc	ra,0x0
     8be:	b64080e7          	jalr	-1180(ra) # 41e <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     8c2:	85ce                	mv	a1,s3
     8c4:	854a                	mv	a0,s2
     8c6:	00000097          	auipc	ra,0x0
     8ca:	f70080e7          	jalr	-144(ra) # 836 <parseline>
     8ce:	85aa                	mv	a1,a0
     8d0:	8526                	mv	a0,s1
     8d2:	00000097          	auipc	ra,0x0
     8d6:	aca080e7          	jalr	-1334(ra) # 39c <listcmd>
     8da:	84aa                	mv	s1,a0
  return cmd;
     8dc:	b7d1                	j	8a0 <parseline+0x6a>

00000000000008de <parseblock>:
{
     8de:	7179                	addi	sp,sp,-48
     8e0:	f406                	sd	ra,40(sp)
     8e2:	f022                	sd	s0,32(sp)
     8e4:	ec26                	sd	s1,24(sp)
     8e6:	e84a                	sd	s2,16(sp)
     8e8:	e44e                	sd	s3,8(sp)
     8ea:	1800                	addi	s0,sp,48
     8ec:	84aa                	mv	s1,a0
     8ee:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8f0:	00001617          	auipc	a2,0x1
     8f4:	af860613          	addi	a2,a2,-1288 # 13e8 <malloc+0x160>
     8f8:	00000097          	auipc	ra,0x0
     8fc:	c62080e7          	jalr	-926(ra) # 55a <peek>
     900:	c12d                	beqz	a0,962 <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     902:	4681                	li	a3,0
     904:	4601                	li	a2,0
     906:	85ca                	mv	a1,s2
     908:	8526                	mv	a0,s1
     90a:	00000097          	auipc	ra,0x0
     90e:	b14080e7          	jalr	-1260(ra) # 41e <gettoken>
  cmd = parseline(ps, es);
     912:	85ca                	mv	a1,s2
     914:	8526                	mv	a0,s1
     916:	00000097          	auipc	ra,0x0
     91a:	f20080e7          	jalr	-224(ra) # 836 <parseline>
     91e:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     920:	00001617          	auipc	a2,0x1
     924:	b1860613          	addi	a2,a2,-1256 # 1438 <malloc+0x1b0>
     928:	85ca                	mv	a1,s2
     92a:	8526                	mv	a0,s1
     92c:	00000097          	auipc	ra,0x0
     930:	c2e080e7          	jalr	-978(ra) # 55a <peek>
     934:	cd1d                	beqz	a0,972 <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     936:	4681                	li	a3,0
     938:	4601                	li	a2,0
     93a:	85ca                	mv	a1,s2
     93c:	8526                	mv	a0,s1
     93e:	00000097          	auipc	ra,0x0
     942:	ae0080e7          	jalr	-1312(ra) # 41e <gettoken>
  cmd = parseredirs(cmd, ps, es);
     946:	864a                	mv	a2,s2
     948:	85a6                	mv	a1,s1
     94a:	854e                	mv	a0,s3
     94c:	00000097          	auipc	ra,0x0
     950:	c78080e7          	jalr	-904(ra) # 5c4 <parseredirs>
}
     954:	70a2                	ld	ra,40(sp)
     956:	7402                	ld	s0,32(sp)
     958:	64e2                	ld	s1,24(sp)
     95a:	6942                	ld	s2,16(sp)
     95c:	69a2                	ld	s3,8(sp)
     95e:	6145                	addi	sp,sp,48
     960:	8082                	ret
    panic("parseblock");
     962:	00001517          	auipc	a0,0x1
     966:	ac650513          	addi	a0,a0,-1338 # 1428 <malloc+0x1a0>
     96a:	fffff097          	auipc	ra,0xfffff
     96e:	6ec080e7          	jalr	1772(ra) # 56 <panic>
    panic("syntax - missing )");
     972:	00001517          	auipc	a0,0x1
     976:	ace50513          	addi	a0,a0,-1330 # 1440 <malloc+0x1b8>
     97a:	fffff097          	auipc	ra,0xfffff
     97e:	6dc080e7          	jalr	1756(ra) # 56 <panic>

0000000000000982 <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     982:	1101                	addi	sp,sp,-32
     984:	ec06                	sd	ra,24(sp)
     986:	e822                	sd	s0,16(sp)
     988:	e426                	sd	s1,8(sp)
     98a:	1000                	addi	s0,sp,32
     98c:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     98e:	c521                	beqz	a0,9d6 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     990:	4118                	lw	a4,0(a0)
     992:	4795                	li	a5,5
     994:	04e7e163          	bltu	a5,a4,9d6 <nulterminate+0x54>
     998:	00056783          	lwu	a5,0(a0)
     99c:	078a                	slli	a5,a5,0x2
     99e:	00001717          	auipc	a4,0x1
     9a2:	afe70713          	addi	a4,a4,-1282 # 149c <malloc+0x214>
     9a6:	97ba                	add	a5,a5,a4
     9a8:	439c                	lw	a5,0(a5)
     9aa:	97ba                	add	a5,a5,a4
     9ac:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     9ae:	651c                	ld	a5,8(a0)
     9b0:	c39d                	beqz	a5,9d6 <nulterminate+0x54>
     9b2:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     9b6:	67b8                	ld	a4,72(a5)
     9b8:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     9bc:	07a1                	addi	a5,a5,8
     9be:	ff87b703          	ld	a4,-8(a5)
     9c2:	fb75                	bnez	a4,9b6 <nulterminate+0x34>
     9c4:	a809                	j	9d6 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     9c6:	6508                	ld	a0,8(a0)
     9c8:	00000097          	auipc	ra,0x0
     9cc:	fba080e7          	jalr	-70(ra) # 982 <nulterminate>
    *rcmd->efile = 0;
     9d0:	6c9c                	ld	a5,24(s1)
     9d2:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     9d6:	8526                	mv	a0,s1
     9d8:	60e2                	ld	ra,24(sp)
     9da:	6442                	ld	s0,16(sp)
     9dc:	64a2                	ld	s1,8(sp)
     9de:	6105                	addi	sp,sp,32
     9e0:	8082                	ret
    nulterminate(pcmd->left);
     9e2:	6508                	ld	a0,8(a0)
     9e4:	00000097          	auipc	ra,0x0
     9e8:	f9e080e7          	jalr	-98(ra) # 982 <nulterminate>
    nulterminate(pcmd->right);
     9ec:	6888                	ld	a0,16(s1)
     9ee:	00000097          	auipc	ra,0x0
     9f2:	f94080e7          	jalr	-108(ra) # 982 <nulterminate>
    break;
     9f6:	b7c5                	j	9d6 <nulterminate+0x54>
    nulterminate(lcmd->left);
     9f8:	6508                	ld	a0,8(a0)
     9fa:	00000097          	auipc	ra,0x0
     9fe:	f88080e7          	jalr	-120(ra) # 982 <nulterminate>
    nulterminate(lcmd->right);
     a02:	6888                	ld	a0,16(s1)
     a04:	00000097          	auipc	ra,0x0
     a08:	f7e080e7          	jalr	-130(ra) # 982 <nulterminate>
    break;
     a0c:	b7e9                	j	9d6 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     a0e:	6508                	ld	a0,8(a0)
     a10:	00000097          	auipc	ra,0x0
     a14:	f72080e7          	jalr	-142(ra) # 982 <nulterminate>
    break;
     a18:	bf7d                	j	9d6 <nulterminate+0x54>

0000000000000a1a <parsecmd>:
{
     a1a:	7179                	addi	sp,sp,-48
     a1c:	f406                	sd	ra,40(sp)
     a1e:	f022                	sd	s0,32(sp)
     a20:	ec26                	sd	s1,24(sp)
     a22:	e84a                	sd	s2,16(sp)
     a24:	1800                	addi	s0,sp,48
     a26:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     a2a:	84aa                	mv	s1,a0
     a2c:	00000097          	auipc	ra,0x0
     a30:	1f8080e7          	jalr	504(ra) # c24 <strlen>
     a34:	1502                	slli	a0,a0,0x20
     a36:	9101                	srli	a0,a0,0x20
     a38:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a3a:	85a6                	mv	a1,s1
     a3c:	fd840513          	addi	a0,s0,-40
     a40:	00000097          	auipc	ra,0x0
     a44:	df6080e7          	jalr	-522(ra) # 836 <parseline>
     a48:	892a                	mv	s2,a0
  peek(&s, es, "");
     a4a:	00001617          	auipc	a2,0x1
     a4e:	93660613          	addi	a2,a2,-1738 # 1380 <malloc+0xf8>
     a52:	85a6                	mv	a1,s1
     a54:	fd840513          	addi	a0,s0,-40
     a58:	00000097          	auipc	ra,0x0
     a5c:	b02080e7          	jalr	-1278(ra) # 55a <peek>
  if(s != es){
     a60:	fd843603          	ld	a2,-40(s0)
     a64:	00961e63          	bne	a2,s1,a80 <parsecmd+0x66>
  nulterminate(cmd);
     a68:	854a                	mv	a0,s2
     a6a:	00000097          	auipc	ra,0x0
     a6e:	f18080e7          	jalr	-232(ra) # 982 <nulterminate>
}
     a72:	854a                	mv	a0,s2
     a74:	70a2                	ld	ra,40(sp)
     a76:	7402                	ld	s0,32(sp)
     a78:	64e2                	ld	s1,24(sp)
     a7a:	6942                	ld	s2,16(sp)
     a7c:	6145                	addi	sp,sp,48
     a7e:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a80:	00001597          	auipc	a1,0x1
     a84:	9d858593          	addi	a1,a1,-1576 # 1458 <malloc+0x1d0>
     a88:	4509                	li	a0,2
     a8a:	00000097          	auipc	ra,0x0
     a8e:	712080e7          	jalr	1810(ra) # 119c <fprintf>
    panic("syntax");
     a92:	00001517          	auipc	a0,0x1
     a96:	95e50513          	addi	a0,a0,-1698 # 13f0 <malloc+0x168>
     a9a:	fffff097          	auipc	ra,0xfffff
     a9e:	5bc080e7          	jalr	1468(ra) # 56 <panic>

0000000000000aa2 <main>:
{
     aa2:	711d                	addi	sp,sp,-96
     aa4:	ec86                	sd	ra,88(sp)
     aa6:	e8a2                	sd	s0,80(sp)
     aa8:	e4a6                	sd	s1,72(sp)
     aaa:	e0ca                	sd	s2,64(sp)
     aac:	fc4e                	sd	s3,56(sp)
     aae:	f852                	sd	s4,48(sp)
     ab0:	f456                	sd	s5,40(sp)
     ab2:	f05a                	sd	s6,32(sp)
     ab4:	1080                	addi	s0,sp,96
  while((fd = open("console", O_RDWR)) >= 0){
     ab6:	00001497          	auipc	s1,0x1
     aba:	9b248493          	addi	s1,s1,-1614 # 1468 <malloc+0x1e0>
     abe:	4589                	li	a1,2
     ac0:	8526                	mv	a0,s1
     ac2:	00000097          	auipc	ra,0x0
     ac6:	3c8080e7          	jalr	968(ra) # e8a <open>
     aca:	00054963          	bltz	a0,adc <main+0x3a>
    if(fd >= 3){
     ace:	4789                	li	a5,2
     ad0:	fea7d7e3          	bge	a5,a0,abe <main+0x1c>
      close(fd);
     ad4:	00000097          	auipc	ra,0x0
     ad8:	39e080e7          	jalr	926(ra) # e72 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     adc:	00001497          	auipc	s1,0x1
     ae0:	54448493          	addi	s1,s1,1348 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ae4:	06300913          	li	s2,99
    printf("%s",msg);
     ae8:	00001997          	auipc	s3,0x1
     aec:	99898993          	addi	s3,s3,-1640 # 1480 <malloc+0x1f8>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     af0:	02000a13          	li	s4,32
      if(chdir(buf+3) < 0)
     af4:	00001a97          	auipc	s5,0x1
     af8:	52fa8a93          	addi	s5,s5,1327 # 2023 <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     afc:	00001b17          	auipc	s6,0x1
     b00:	974b0b13          	addi	s6,s6,-1676 # 1470 <malloc+0x1e8>
     b04:	a025                	j	b2c <main+0x8a>
    if(fork1() == 0)
     b06:	fffff097          	auipc	ra,0xfffff
     b0a:	57e080e7          	jalr	1406(ra) # 84 <fork1>
     b0e:	c149                	beqz	a0,b90 <main+0xee>
    wait(0,msg);
     b10:	fa040593          	addi	a1,s0,-96
     b14:	4501                	li	a0,0
     b16:	00000097          	auipc	ra,0x0
     b1a:	33c080e7          	jalr	828(ra) # e52 <wait>
    printf("%s",msg);
     b1e:	fa040593          	addi	a1,s0,-96
     b22:	854e                	mv	a0,s3
     b24:	00000097          	auipc	ra,0x0
     b28:	6a6080e7          	jalr	1702(ra) # 11ca <printf>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b2c:	06400593          	li	a1,100
     b30:	8526                	mv	a0,s1
     b32:	fffff097          	auipc	ra,0xfffff
     b36:	4ce080e7          	jalr	1230(ra) # 0 <getcmd>
     b3a:	06054763          	bltz	a0,ba8 <main+0x106>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b3e:	0004c783          	lbu	a5,0(s1)
     b42:	fd2792e3          	bne	a5,s2,b06 <main+0x64>
     b46:	0014c703          	lbu	a4,1(s1)
     b4a:	06400793          	li	a5,100
     b4e:	faf71ce3          	bne	a4,a5,b06 <main+0x64>
     b52:	0024c783          	lbu	a5,2(s1)
     b56:	fb4798e3          	bne	a5,s4,b06 <main+0x64>
      buf[strlen(buf)-1] = 0;  // chop \n
     b5a:	8526                	mv	a0,s1
     b5c:	00000097          	auipc	ra,0x0
     b60:	0c8080e7          	jalr	200(ra) # c24 <strlen>
     b64:	fff5079b          	addiw	a5,a0,-1
     b68:	1782                	slli	a5,a5,0x20
     b6a:	9381                	srli	a5,a5,0x20
     b6c:	97a6                	add	a5,a5,s1
     b6e:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     b72:	8556                	mv	a0,s5
     b74:	00000097          	auipc	ra,0x0
     b78:	346080e7          	jalr	838(ra) # eba <chdir>
     b7c:	fa0558e3          	bgez	a0,b2c <main+0x8a>
        fprintf(2, "cannot cd %s\n", buf+3);
     b80:	8656                	mv	a2,s5
     b82:	85da                	mv	a1,s6
     b84:	4509                	li	a0,2
     b86:	00000097          	auipc	ra,0x0
     b8a:	616080e7          	jalr	1558(ra) # 119c <fprintf>
      continue;
     b8e:	bf79                	j	b2c <main+0x8a>
      runcmd(parsecmd(buf));
     b90:	00001517          	auipc	a0,0x1
     b94:	49050513          	addi	a0,a0,1168 # 2020 <buf.0>
     b98:	00000097          	auipc	ra,0x0
     b9c:	e82080e7          	jalr	-382(ra) # a1a <parsecmd>
     ba0:	fffff097          	auipc	ra,0xfffff
     ba4:	512080e7          	jalr	1298(ra) # b2 <runcmd>
  exit(0,"");
     ba8:	00000597          	auipc	a1,0x0
     bac:	7d858593          	addi	a1,a1,2008 # 1380 <malloc+0xf8>
     bb0:	4501                	li	a0,0
     bb2:	00000097          	auipc	ra,0x0
     bb6:	298080e7          	jalr	664(ra) # e4a <exit>

0000000000000bba <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     bba:	1141                	addi	sp,sp,-16
     bbc:	e406                	sd	ra,8(sp)
     bbe:	e022                	sd	s0,0(sp)
     bc0:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bc2:	00000097          	auipc	ra,0x0
     bc6:	ee0080e7          	jalr	-288(ra) # aa2 <main>
  exit(0,"");
     bca:	00000597          	auipc	a1,0x0
     bce:	7b658593          	addi	a1,a1,1974 # 1380 <malloc+0xf8>
     bd2:	4501                	li	a0,0
     bd4:	00000097          	auipc	ra,0x0
     bd8:	276080e7          	jalr	630(ra) # e4a <exit>

0000000000000bdc <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     bdc:	1141                	addi	sp,sp,-16
     bde:	e422                	sd	s0,8(sp)
     be0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     be2:	87aa                	mv	a5,a0
     be4:	0585                	addi	a1,a1,1
     be6:	0785                	addi	a5,a5,1
     be8:	fff5c703          	lbu	a4,-1(a1)
     bec:	fee78fa3          	sb	a4,-1(a5)
     bf0:	fb75                	bnez	a4,be4 <strcpy+0x8>
    ;
  return os;
}
     bf2:	6422                	ld	s0,8(sp)
     bf4:	0141                	addi	sp,sp,16
     bf6:	8082                	ret

0000000000000bf8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bf8:	1141                	addi	sp,sp,-16
     bfa:	e422                	sd	s0,8(sp)
     bfc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     bfe:	00054783          	lbu	a5,0(a0)
     c02:	cb91                	beqz	a5,c16 <strcmp+0x1e>
     c04:	0005c703          	lbu	a4,0(a1)
     c08:	00f71763          	bne	a4,a5,c16 <strcmp+0x1e>
    p++, q++;
     c0c:	0505                	addi	a0,a0,1
     c0e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c10:	00054783          	lbu	a5,0(a0)
     c14:	fbe5                	bnez	a5,c04 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c16:	0005c503          	lbu	a0,0(a1)
}
     c1a:	40a7853b          	subw	a0,a5,a0
     c1e:	6422                	ld	s0,8(sp)
     c20:	0141                	addi	sp,sp,16
     c22:	8082                	ret

0000000000000c24 <strlen>:

uint
strlen(const char *s)
{
     c24:	1141                	addi	sp,sp,-16
     c26:	e422                	sd	s0,8(sp)
     c28:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c2a:	00054783          	lbu	a5,0(a0)
     c2e:	cf91                	beqz	a5,c4a <strlen+0x26>
     c30:	0505                	addi	a0,a0,1
     c32:	87aa                	mv	a5,a0
     c34:	4685                	li	a3,1
     c36:	9e89                	subw	a3,a3,a0
     c38:	00f6853b          	addw	a0,a3,a5
     c3c:	0785                	addi	a5,a5,1
     c3e:	fff7c703          	lbu	a4,-1(a5)
     c42:	fb7d                	bnez	a4,c38 <strlen+0x14>
    ;
  return n;
}
     c44:	6422                	ld	s0,8(sp)
     c46:	0141                	addi	sp,sp,16
     c48:	8082                	ret
  for(n = 0; s[n]; n++)
     c4a:	4501                	li	a0,0
     c4c:	bfe5                	j	c44 <strlen+0x20>

0000000000000c4e <memset>:

void*
memset(void *dst, int c, uint n)
{
     c4e:	1141                	addi	sp,sp,-16
     c50:	e422                	sd	s0,8(sp)
     c52:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c54:	ca19                	beqz	a2,c6a <memset+0x1c>
     c56:	87aa                	mv	a5,a0
     c58:	1602                	slli	a2,a2,0x20
     c5a:	9201                	srli	a2,a2,0x20
     c5c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c60:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c64:	0785                	addi	a5,a5,1
     c66:	fee79de3          	bne	a5,a4,c60 <memset+0x12>
  }
  return dst;
}
     c6a:	6422                	ld	s0,8(sp)
     c6c:	0141                	addi	sp,sp,16
     c6e:	8082                	ret

0000000000000c70 <strchr>:

char*
strchr(const char *s, char c)
{
     c70:	1141                	addi	sp,sp,-16
     c72:	e422                	sd	s0,8(sp)
     c74:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c76:	00054783          	lbu	a5,0(a0)
     c7a:	cb99                	beqz	a5,c90 <strchr+0x20>
    if(*s == c)
     c7c:	00f58763          	beq	a1,a5,c8a <strchr+0x1a>
  for(; *s; s++)
     c80:	0505                	addi	a0,a0,1
     c82:	00054783          	lbu	a5,0(a0)
     c86:	fbfd                	bnez	a5,c7c <strchr+0xc>
      return (char*)s;
  return 0;
     c88:	4501                	li	a0,0
}
     c8a:	6422                	ld	s0,8(sp)
     c8c:	0141                	addi	sp,sp,16
     c8e:	8082                	ret
  return 0;
     c90:	4501                	li	a0,0
     c92:	bfe5                	j	c8a <strchr+0x1a>

0000000000000c94 <gets>:

char*
gets(char *buf, int max)
{
     c94:	711d                	addi	sp,sp,-96
     c96:	ec86                	sd	ra,88(sp)
     c98:	e8a2                	sd	s0,80(sp)
     c9a:	e4a6                	sd	s1,72(sp)
     c9c:	e0ca                	sd	s2,64(sp)
     c9e:	fc4e                	sd	s3,56(sp)
     ca0:	f852                	sd	s4,48(sp)
     ca2:	f456                	sd	s5,40(sp)
     ca4:	f05a                	sd	s6,32(sp)
     ca6:	ec5e                	sd	s7,24(sp)
     ca8:	1080                	addi	s0,sp,96
     caa:	8baa                	mv	s7,a0
     cac:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cae:	892a                	mv	s2,a0
     cb0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cb2:	4aa9                	li	s5,10
     cb4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cb6:	89a6                	mv	s3,s1
     cb8:	2485                	addiw	s1,s1,1
     cba:	0344d863          	bge	s1,s4,cea <gets+0x56>
    cc = read(0, &c, 1);
     cbe:	4605                	li	a2,1
     cc0:	faf40593          	addi	a1,s0,-81
     cc4:	4501                	li	a0,0
     cc6:	00000097          	auipc	ra,0x0
     cca:	19c080e7          	jalr	412(ra) # e62 <read>
    if(cc < 1)
     cce:	00a05e63          	blez	a0,cea <gets+0x56>
    buf[i++] = c;
     cd2:	faf44783          	lbu	a5,-81(s0)
     cd6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     cda:	01578763          	beq	a5,s5,ce8 <gets+0x54>
     cde:	0905                	addi	s2,s2,1
     ce0:	fd679be3          	bne	a5,s6,cb6 <gets+0x22>
  for(i=0; i+1 < max; ){
     ce4:	89a6                	mv	s3,s1
     ce6:	a011                	j	cea <gets+0x56>
     ce8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cea:	99de                	add	s3,s3,s7
     cec:	00098023          	sb	zero,0(s3)
  return buf;
}
     cf0:	855e                	mv	a0,s7
     cf2:	60e6                	ld	ra,88(sp)
     cf4:	6446                	ld	s0,80(sp)
     cf6:	64a6                	ld	s1,72(sp)
     cf8:	6906                	ld	s2,64(sp)
     cfa:	79e2                	ld	s3,56(sp)
     cfc:	7a42                	ld	s4,48(sp)
     cfe:	7aa2                	ld	s5,40(sp)
     d00:	7b02                	ld	s6,32(sp)
     d02:	6be2                	ld	s7,24(sp)
     d04:	6125                	addi	sp,sp,96
     d06:	8082                	ret

0000000000000d08 <stat>:

int
stat(const char *n, struct stat *st)
{
     d08:	1101                	addi	sp,sp,-32
     d0a:	ec06                	sd	ra,24(sp)
     d0c:	e822                	sd	s0,16(sp)
     d0e:	e426                	sd	s1,8(sp)
     d10:	e04a                	sd	s2,0(sp)
     d12:	1000                	addi	s0,sp,32
     d14:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d16:	4581                	li	a1,0
     d18:	00000097          	auipc	ra,0x0
     d1c:	172080e7          	jalr	370(ra) # e8a <open>
  if(fd < 0)
     d20:	02054563          	bltz	a0,d4a <stat+0x42>
     d24:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d26:	85ca                	mv	a1,s2
     d28:	00000097          	auipc	ra,0x0
     d2c:	17a080e7          	jalr	378(ra) # ea2 <fstat>
     d30:	892a                	mv	s2,a0
  close(fd);
     d32:	8526                	mv	a0,s1
     d34:	00000097          	auipc	ra,0x0
     d38:	13e080e7          	jalr	318(ra) # e72 <close>
  return r;
}
     d3c:	854a                	mv	a0,s2
     d3e:	60e2                	ld	ra,24(sp)
     d40:	6442                	ld	s0,16(sp)
     d42:	64a2                	ld	s1,8(sp)
     d44:	6902                	ld	s2,0(sp)
     d46:	6105                	addi	sp,sp,32
     d48:	8082                	ret
    return -1;
     d4a:	597d                	li	s2,-1
     d4c:	bfc5                	j	d3c <stat+0x34>

0000000000000d4e <atoi>:

int
atoi(const char *s)
{
     d4e:	1141                	addi	sp,sp,-16
     d50:	e422                	sd	s0,8(sp)
     d52:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d54:	00054603          	lbu	a2,0(a0)
     d58:	fd06079b          	addiw	a5,a2,-48
     d5c:	0ff7f793          	andi	a5,a5,255
     d60:	4725                	li	a4,9
     d62:	02f76963          	bltu	a4,a5,d94 <atoi+0x46>
     d66:	86aa                	mv	a3,a0
  n = 0;
     d68:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d6a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d6c:	0685                	addi	a3,a3,1
     d6e:	0025179b          	slliw	a5,a0,0x2
     d72:	9fa9                	addw	a5,a5,a0
     d74:	0017979b          	slliw	a5,a5,0x1
     d78:	9fb1                	addw	a5,a5,a2
     d7a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d7e:	0006c603          	lbu	a2,0(a3)
     d82:	fd06071b          	addiw	a4,a2,-48
     d86:	0ff77713          	andi	a4,a4,255
     d8a:	fee5f1e3          	bgeu	a1,a4,d6c <atoi+0x1e>
  return n;
}
     d8e:	6422                	ld	s0,8(sp)
     d90:	0141                	addi	sp,sp,16
     d92:	8082                	ret
  n = 0;
     d94:	4501                	li	a0,0
     d96:	bfe5                	j	d8e <atoi+0x40>

0000000000000d98 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d98:	1141                	addi	sp,sp,-16
     d9a:	e422                	sd	s0,8(sp)
     d9c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d9e:	02b57463          	bgeu	a0,a1,dc6 <memmove+0x2e>
    while(n-- > 0)
     da2:	00c05f63          	blez	a2,dc0 <memmove+0x28>
     da6:	1602                	slli	a2,a2,0x20
     da8:	9201                	srli	a2,a2,0x20
     daa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     dae:	872a                	mv	a4,a0
      *dst++ = *src++;
     db0:	0585                	addi	a1,a1,1
     db2:	0705                	addi	a4,a4,1
     db4:	fff5c683          	lbu	a3,-1(a1)
     db8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dbc:	fee79ae3          	bne	a5,a4,db0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     dc0:	6422                	ld	s0,8(sp)
     dc2:	0141                	addi	sp,sp,16
     dc4:	8082                	ret
    dst += n;
     dc6:	00c50733          	add	a4,a0,a2
    src += n;
     dca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dcc:	fec05ae3          	blez	a2,dc0 <memmove+0x28>
     dd0:	fff6079b          	addiw	a5,a2,-1
     dd4:	1782                	slli	a5,a5,0x20
     dd6:	9381                	srli	a5,a5,0x20
     dd8:	fff7c793          	not	a5,a5
     ddc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     dde:	15fd                	addi	a1,a1,-1
     de0:	177d                	addi	a4,a4,-1
     de2:	0005c683          	lbu	a3,0(a1)
     de6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     dea:	fee79ae3          	bne	a5,a4,dde <memmove+0x46>
     dee:	bfc9                	j	dc0 <memmove+0x28>

0000000000000df0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     df0:	1141                	addi	sp,sp,-16
     df2:	e422                	sd	s0,8(sp)
     df4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     df6:	ca05                	beqz	a2,e26 <memcmp+0x36>
     df8:	fff6069b          	addiw	a3,a2,-1
     dfc:	1682                	slli	a3,a3,0x20
     dfe:	9281                	srli	a3,a3,0x20
     e00:	0685                	addi	a3,a3,1
     e02:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e04:	00054783          	lbu	a5,0(a0)
     e08:	0005c703          	lbu	a4,0(a1)
     e0c:	00e79863          	bne	a5,a4,e1c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e10:	0505                	addi	a0,a0,1
    p2++;
     e12:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e14:	fed518e3          	bne	a0,a3,e04 <memcmp+0x14>
  }
  return 0;
     e18:	4501                	li	a0,0
     e1a:	a019                	j	e20 <memcmp+0x30>
      return *p1 - *p2;
     e1c:	40e7853b          	subw	a0,a5,a4
}
     e20:	6422                	ld	s0,8(sp)
     e22:	0141                	addi	sp,sp,16
     e24:	8082                	ret
  return 0;
     e26:	4501                	li	a0,0
     e28:	bfe5                	j	e20 <memcmp+0x30>

0000000000000e2a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e2a:	1141                	addi	sp,sp,-16
     e2c:	e406                	sd	ra,8(sp)
     e2e:	e022                	sd	s0,0(sp)
     e30:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e32:	00000097          	auipc	ra,0x0
     e36:	f66080e7          	jalr	-154(ra) # d98 <memmove>
}
     e3a:	60a2                	ld	ra,8(sp)
     e3c:	6402                	ld	s0,0(sp)
     e3e:	0141                	addi	sp,sp,16
     e40:	8082                	ret

0000000000000e42 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e42:	4885                	li	a7,1
 ecall
     e44:	00000073          	ecall
 ret
     e48:	8082                	ret

0000000000000e4a <exit>:
.global exit
exit:
 li a7, SYS_exit
     e4a:	4889                	li	a7,2
 ecall
     e4c:	00000073          	ecall
 ret
     e50:	8082                	ret

0000000000000e52 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e52:	488d                	li	a7,3
 ecall
     e54:	00000073          	ecall
 ret
     e58:	8082                	ret

0000000000000e5a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e5a:	4891                	li	a7,4
 ecall
     e5c:	00000073          	ecall
 ret
     e60:	8082                	ret

0000000000000e62 <read>:
.global read
read:
 li a7, SYS_read
     e62:	4895                	li	a7,5
 ecall
     e64:	00000073          	ecall
 ret
     e68:	8082                	ret

0000000000000e6a <write>:
.global write
write:
 li a7, SYS_write
     e6a:	48c1                	li	a7,16
 ecall
     e6c:	00000073          	ecall
 ret
     e70:	8082                	ret

0000000000000e72 <close>:
.global close
close:
 li a7, SYS_close
     e72:	48d5                	li	a7,21
 ecall
     e74:	00000073          	ecall
 ret
     e78:	8082                	ret

0000000000000e7a <kill>:
.global kill
kill:
 li a7, SYS_kill
     e7a:	4899                	li	a7,6
 ecall
     e7c:	00000073          	ecall
 ret
     e80:	8082                	ret

0000000000000e82 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e82:	489d                	li	a7,7
 ecall
     e84:	00000073          	ecall
 ret
     e88:	8082                	ret

0000000000000e8a <open>:
.global open
open:
 li a7, SYS_open
     e8a:	48bd                	li	a7,15
 ecall
     e8c:	00000073          	ecall
 ret
     e90:	8082                	ret

0000000000000e92 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e92:	48c5                	li	a7,17
 ecall
     e94:	00000073          	ecall
 ret
     e98:	8082                	ret

0000000000000e9a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e9a:	48c9                	li	a7,18
 ecall
     e9c:	00000073          	ecall
 ret
     ea0:	8082                	ret

0000000000000ea2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ea2:	48a1                	li	a7,8
 ecall
     ea4:	00000073          	ecall
 ret
     ea8:	8082                	ret

0000000000000eaa <link>:
.global link
link:
 li a7, SYS_link
     eaa:	48cd                	li	a7,19
 ecall
     eac:	00000073          	ecall
 ret
     eb0:	8082                	ret

0000000000000eb2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     eb2:	48d1                	li	a7,20
 ecall
     eb4:	00000073          	ecall
 ret
     eb8:	8082                	ret

0000000000000eba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     eba:	48a5                	li	a7,9
 ecall
     ebc:	00000073          	ecall
 ret
     ec0:	8082                	ret

0000000000000ec2 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ec2:	48a9                	li	a7,10
 ecall
     ec4:	00000073          	ecall
 ret
     ec8:	8082                	ret

0000000000000eca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     eca:	48ad                	li	a7,11
 ecall
     ecc:	00000073          	ecall
 ret
     ed0:	8082                	ret

0000000000000ed2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     ed2:	48b1                	li	a7,12
 ecall
     ed4:	00000073          	ecall
 ret
     ed8:	8082                	ret

0000000000000eda <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     eda:	48b5                	li	a7,13
 ecall
     edc:	00000073          	ecall
 ret
     ee0:	8082                	ret

0000000000000ee2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ee2:	48b9                	li	a7,14
 ecall
     ee4:	00000073          	ecall
 ret
     ee8:	8082                	ret

0000000000000eea <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
     eea:	48d9                	li	a7,22
 ecall
     eec:	00000073          	ecall
 ret
     ef0:	8082                	ret

0000000000000ef2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     ef2:	1101                	addi	sp,sp,-32
     ef4:	ec06                	sd	ra,24(sp)
     ef6:	e822                	sd	s0,16(sp)
     ef8:	1000                	addi	s0,sp,32
     efa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     efe:	4605                	li	a2,1
     f00:	fef40593          	addi	a1,s0,-17
     f04:	00000097          	auipc	ra,0x0
     f08:	f66080e7          	jalr	-154(ra) # e6a <write>
}
     f0c:	60e2                	ld	ra,24(sp)
     f0e:	6442                	ld	s0,16(sp)
     f10:	6105                	addi	sp,sp,32
     f12:	8082                	ret

0000000000000f14 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f14:	7139                	addi	sp,sp,-64
     f16:	fc06                	sd	ra,56(sp)
     f18:	f822                	sd	s0,48(sp)
     f1a:	f426                	sd	s1,40(sp)
     f1c:	f04a                	sd	s2,32(sp)
     f1e:	ec4e                	sd	s3,24(sp)
     f20:	0080                	addi	s0,sp,64
     f22:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f24:	c299                	beqz	a3,f2a <printint+0x16>
     f26:	0805c863          	bltz	a1,fb6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f2a:	2581                	sext.w	a1,a1
  neg = 0;
     f2c:	4881                	li	a7,0
     f2e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f32:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f34:	2601                	sext.w	a2,a2
     f36:	00000517          	auipc	a0,0x0
     f3a:	58a50513          	addi	a0,a0,1418 # 14c0 <digits>
     f3e:	883a                	mv	a6,a4
     f40:	2705                	addiw	a4,a4,1
     f42:	02c5f7bb          	remuw	a5,a1,a2
     f46:	1782                	slli	a5,a5,0x20
     f48:	9381                	srli	a5,a5,0x20
     f4a:	97aa                	add	a5,a5,a0
     f4c:	0007c783          	lbu	a5,0(a5)
     f50:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f54:	0005879b          	sext.w	a5,a1
     f58:	02c5d5bb          	divuw	a1,a1,a2
     f5c:	0685                	addi	a3,a3,1
     f5e:	fec7f0e3          	bgeu	a5,a2,f3e <printint+0x2a>
  if(neg)
     f62:	00088b63          	beqz	a7,f78 <printint+0x64>
    buf[i++] = '-';
     f66:	fd040793          	addi	a5,s0,-48
     f6a:	973e                	add	a4,a4,a5
     f6c:	02d00793          	li	a5,45
     f70:	fef70823          	sb	a5,-16(a4)
     f74:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f78:	02e05863          	blez	a4,fa8 <printint+0x94>
     f7c:	fc040793          	addi	a5,s0,-64
     f80:	00e78933          	add	s2,a5,a4
     f84:	fff78993          	addi	s3,a5,-1
     f88:	99ba                	add	s3,s3,a4
     f8a:	377d                	addiw	a4,a4,-1
     f8c:	1702                	slli	a4,a4,0x20
     f8e:	9301                	srli	a4,a4,0x20
     f90:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f94:	fff94583          	lbu	a1,-1(s2)
     f98:	8526                	mv	a0,s1
     f9a:	00000097          	auipc	ra,0x0
     f9e:	f58080e7          	jalr	-168(ra) # ef2 <putc>
  while(--i >= 0)
     fa2:	197d                	addi	s2,s2,-1
     fa4:	ff3918e3          	bne	s2,s3,f94 <printint+0x80>
}
     fa8:	70e2                	ld	ra,56(sp)
     faa:	7442                	ld	s0,48(sp)
     fac:	74a2                	ld	s1,40(sp)
     fae:	7902                	ld	s2,32(sp)
     fb0:	69e2                	ld	s3,24(sp)
     fb2:	6121                	addi	sp,sp,64
     fb4:	8082                	ret
    x = -xx;
     fb6:	40b005bb          	negw	a1,a1
    neg = 1;
     fba:	4885                	li	a7,1
    x = -xx;
     fbc:	bf8d                	j	f2e <printint+0x1a>

0000000000000fbe <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fbe:	7119                	addi	sp,sp,-128
     fc0:	fc86                	sd	ra,120(sp)
     fc2:	f8a2                	sd	s0,112(sp)
     fc4:	f4a6                	sd	s1,104(sp)
     fc6:	f0ca                	sd	s2,96(sp)
     fc8:	ecce                	sd	s3,88(sp)
     fca:	e8d2                	sd	s4,80(sp)
     fcc:	e4d6                	sd	s5,72(sp)
     fce:	e0da                	sd	s6,64(sp)
     fd0:	fc5e                	sd	s7,56(sp)
     fd2:	f862                	sd	s8,48(sp)
     fd4:	f466                	sd	s9,40(sp)
     fd6:	f06a                	sd	s10,32(sp)
     fd8:	ec6e                	sd	s11,24(sp)
     fda:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     fdc:	0005c903          	lbu	s2,0(a1)
     fe0:	18090f63          	beqz	s2,117e <vprintf+0x1c0>
     fe4:	8aaa                	mv	s5,a0
     fe6:	8b32                	mv	s6,a2
     fe8:	00158493          	addi	s1,a1,1
  state = 0;
     fec:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     fee:	02500a13          	li	s4,37
      if(c == 'd'){
     ff2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     ff6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     ffa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     ffe:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1002:	00000b97          	auipc	s7,0x0
    1006:	4beb8b93          	addi	s7,s7,1214 # 14c0 <digits>
    100a:	a839                	j	1028 <vprintf+0x6a>
        putc(fd, c);
    100c:	85ca                	mv	a1,s2
    100e:	8556                	mv	a0,s5
    1010:	00000097          	auipc	ra,0x0
    1014:	ee2080e7          	jalr	-286(ra) # ef2 <putc>
    1018:	a019                	j	101e <vprintf+0x60>
    } else if(state == '%'){
    101a:	01498f63          	beq	s3,s4,1038 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    101e:	0485                	addi	s1,s1,1
    1020:	fff4c903          	lbu	s2,-1(s1)
    1024:	14090d63          	beqz	s2,117e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1028:	0009079b          	sext.w	a5,s2
    if(state == 0){
    102c:	fe0997e3          	bnez	s3,101a <vprintf+0x5c>
      if(c == '%'){
    1030:	fd479ee3          	bne	a5,s4,100c <vprintf+0x4e>
        state = '%';
    1034:	89be                	mv	s3,a5
    1036:	b7e5                	j	101e <vprintf+0x60>
      if(c == 'd'){
    1038:	05878063          	beq	a5,s8,1078 <vprintf+0xba>
      } else if(c == 'l') {
    103c:	05978c63          	beq	a5,s9,1094 <vprintf+0xd6>
      } else if(c == 'x') {
    1040:	07a78863          	beq	a5,s10,10b0 <vprintf+0xf2>
      } else if(c == 'p') {
    1044:	09b78463          	beq	a5,s11,10cc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1048:	07300713          	li	a4,115
    104c:	0ce78663          	beq	a5,a4,1118 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    1050:	06300713          	li	a4,99
    1054:	0ee78e63          	beq	a5,a4,1150 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1058:	11478863          	beq	a5,s4,1168 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    105c:	85d2                	mv	a1,s4
    105e:	8556                	mv	a0,s5
    1060:	00000097          	auipc	ra,0x0
    1064:	e92080e7          	jalr	-366(ra) # ef2 <putc>
        putc(fd, c);
    1068:	85ca                	mv	a1,s2
    106a:	8556                	mv	a0,s5
    106c:	00000097          	auipc	ra,0x0
    1070:	e86080e7          	jalr	-378(ra) # ef2 <putc>
      }
      state = 0;
    1074:	4981                	li	s3,0
    1076:	b765                	j	101e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1078:	008b0913          	addi	s2,s6,8
    107c:	4685                	li	a3,1
    107e:	4629                	li	a2,10
    1080:	000b2583          	lw	a1,0(s6)
    1084:	8556                	mv	a0,s5
    1086:	00000097          	auipc	ra,0x0
    108a:	e8e080e7          	jalr	-370(ra) # f14 <printint>
    108e:	8b4a                	mv	s6,s2
      state = 0;
    1090:	4981                	li	s3,0
    1092:	b771                	j	101e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1094:	008b0913          	addi	s2,s6,8
    1098:	4681                	li	a3,0
    109a:	4629                	li	a2,10
    109c:	000b2583          	lw	a1,0(s6)
    10a0:	8556                	mv	a0,s5
    10a2:	00000097          	auipc	ra,0x0
    10a6:	e72080e7          	jalr	-398(ra) # f14 <printint>
    10aa:	8b4a                	mv	s6,s2
      state = 0;
    10ac:	4981                	li	s3,0
    10ae:	bf85                	j	101e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10b0:	008b0913          	addi	s2,s6,8
    10b4:	4681                	li	a3,0
    10b6:	4641                	li	a2,16
    10b8:	000b2583          	lw	a1,0(s6)
    10bc:	8556                	mv	a0,s5
    10be:	00000097          	auipc	ra,0x0
    10c2:	e56080e7          	jalr	-426(ra) # f14 <printint>
    10c6:	8b4a                	mv	s6,s2
      state = 0;
    10c8:	4981                	li	s3,0
    10ca:	bf91                	j	101e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    10cc:	008b0793          	addi	a5,s6,8
    10d0:	f8f43423          	sd	a5,-120(s0)
    10d4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    10d8:	03000593          	li	a1,48
    10dc:	8556                	mv	a0,s5
    10de:	00000097          	auipc	ra,0x0
    10e2:	e14080e7          	jalr	-492(ra) # ef2 <putc>
  putc(fd, 'x');
    10e6:	85ea                	mv	a1,s10
    10e8:	8556                	mv	a0,s5
    10ea:	00000097          	auipc	ra,0x0
    10ee:	e08080e7          	jalr	-504(ra) # ef2 <putc>
    10f2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    10f4:	03c9d793          	srli	a5,s3,0x3c
    10f8:	97de                	add	a5,a5,s7
    10fa:	0007c583          	lbu	a1,0(a5)
    10fe:	8556                	mv	a0,s5
    1100:	00000097          	auipc	ra,0x0
    1104:	df2080e7          	jalr	-526(ra) # ef2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1108:	0992                	slli	s3,s3,0x4
    110a:	397d                	addiw	s2,s2,-1
    110c:	fe0914e3          	bnez	s2,10f4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1110:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1114:	4981                	li	s3,0
    1116:	b721                	j	101e <vprintf+0x60>
        s = va_arg(ap, char*);
    1118:	008b0993          	addi	s3,s6,8
    111c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1120:	02090163          	beqz	s2,1142 <vprintf+0x184>
        while(*s != 0){
    1124:	00094583          	lbu	a1,0(s2)
    1128:	c9a1                	beqz	a1,1178 <vprintf+0x1ba>
          putc(fd, *s);
    112a:	8556                	mv	a0,s5
    112c:	00000097          	auipc	ra,0x0
    1130:	dc6080e7          	jalr	-570(ra) # ef2 <putc>
          s++;
    1134:	0905                	addi	s2,s2,1
        while(*s != 0){
    1136:	00094583          	lbu	a1,0(s2)
    113a:	f9e5                	bnez	a1,112a <vprintf+0x16c>
        s = va_arg(ap, char*);
    113c:	8b4e                	mv	s6,s3
      state = 0;
    113e:	4981                	li	s3,0
    1140:	bdf9                	j	101e <vprintf+0x60>
          s = "(null)";
    1142:	00000917          	auipc	s2,0x0
    1146:	37690913          	addi	s2,s2,886 # 14b8 <malloc+0x230>
        while(*s != 0){
    114a:	02800593          	li	a1,40
    114e:	bff1                	j	112a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1150:	008b0913          	addi	s2,s6,8
    1154:	000b4583          	lbu	a1,0(s6)
    1158:	8556                	mv	a0,s5
    115a:	00000097          	auipc	ra,0x0
    115e:	d98080e7          	jalr	-616(ra) # ef2 <putc>
    1162:	8b4a                	mv	s6,s2
      state = 0;
    1164:	4981                	li	s3,0
    1166:	bd65                	j	101e <vprintf+0x60>
        putc(fd, c);
    1168:	85d2                	mv	a1,s4
    116a:	8556                	mv	a0,s5
    116c:	00000097          	auipc	ra,0x0
    1170:	d86080e7          	jalr	-634(ra) # ef2 <putc>
      state = 0;
    1174:	4981                	li	s3,0
    1176:	b565                	j	101e <vprintf+0x60>
        s = va_arg(ap, char*);
    1178:	8b4e                	mv	s6,s3
      state = 0;
    117a:	4981                	li	s3,0
    117c:	b54d                	j	101e <vprintf+0x60>
    }
  }
}
    117e:	70e6                	ld	ra,120(sp)
    1180:	7446                	ld	s0,112(sp)
    1182:	74a6                	ld	s1,104(sp)
    1184:	7906                	ld	s2,96(sp)
    1186:	69e6                	ld	s3,88(sp)
    1188:	6a46                	ld	s4,80(sp)
    118a:	6aa6                	ld	s5,72(sp)
    118c:	6b06                	ld	s6,64(sp)
    118e:	7be2                	ld	s7,56(sp)
    1190:	7c42                	ld	s8,48(sp)
    1192:	7ca2                	ld	s9,40(sp)
    1194:	7d02                	ld	s10,32(sp)
    1196:	6de2                	ld	s11,24(sp)
    1198:	6109                	addi	sp,sp,128
    119a:	8082                	ret

000000000000119c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    119c:	715d                	addi	sp,sp,-80
    119e:	ec06                	sd	ra,24(sp)
    11a0:	e822                	sd	s0,16(sp)
    11a2:	1000                	addi	s0,sp,32
    11a4:	e010                	sd	a2,0(s0)
    11a6:	e414                	sd	a3,8(s0)
    11a8:	e818                	sd	a4,16(s0)
    11aa:	ec1c                	sd	a5,24(s0)
    11ac:	03043023          	sd	a6,32(s0)
    11b0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11b4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11b8:	8622                	mv	a2,s0
    11ba:	00000097          	auipc	ra,0x0
    11be:	e04080e7          	jalr	-508(ra) # fbe <vprintf>
}
    11c2:	60e2                	ld	ra,24(sp)
    11c4:	6442                	ld	s0,16(sp)
    11c6:	6161                	addi	sp,sp,80
    11c8:	8082                	ret

00000000000011ca <printf>:

void
printf(const char *fmt, ...)
{
    11ca:	711d                	addi	sp,sp,-96
    11cc:	ec06                	sd	ra,24(sp)
    11ce:	e822                	sd	s0,16(sp)
    11d0:	1000                	addi	s0,sp,32
    11d2:	e40c                	sd	a1,8(s0)
    11d4:	e810                	sd	a2,16(s0)
    11d6:	ec14                	sd	a3,24(s0)
    11d8:	f018                	sd	a4,32(s0)
    11da:	f41c                	sd	a5,40(s0)
    11dc:	03043823          	sd	a6,48(s0)
    11e0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11e4:	00840613          	addi	a2,s0,8
    11e8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11ec:	85aa                	mv	a1,a0
    11ee:	4505                	li	a0,1
    11f0:	00000097          	auipc	ra,0x0
    11f4:	dce080e7          	jalr	-562(ra) # fbe <vprintf>
}
    11f8:	60e2                	ld	ra,24(sp)
    11fa:	6442                	ld	s0,16(sp)
    11fc:	6125                	addi	sp,sp,96
    11fe:	8082                	ret

0000000000001200 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1200:	1141                	addi	sp,sp,-16
    1202:	e422                	sd	s0,8(sp)
    1204:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1206:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    120a:	00001797          	auipc	a5,0x1
    120e:	e067b783          	ld	a5,-506(a5) # 2010 <freep>
    1212:	a805                	j	1242 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1214:	4618                	lw	a4,8(a2)
    1216:	9db9                	addw	a1,a1,a4
    1218:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    121c:	6398                	ld	a4,0(a5)
    121e:	6318                	ld	a4,0(a4)
    1220:	fee53823          	sd	a4,-16(a0)
    1224:	a091                	j	1268 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1226:	ff852703          	lw	a4,-8(a0)
    122a:	9e39                	addw	a2,a2,a4
    122c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    122e:	ff053703          	ld	a4,-16(a0)
    1232:	e398                	sd	a4,0(a5)
    1234:	a099                	j	127a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1236:	6398                	ld	a4,0(a5)
    1238:	00e7e463          	bltu	a5,a4,1240 <free+0x40>
    123c:	00e6ea63          	bltu	a3,a4,1250 <free+0x50>
{
    1240:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1242:	fed7fae3          	bgeu	a5,a3,1236 <free+0x36>
    1246:	6398                	ld	a4,0(a5)
    1248:	00e6e463          	bltu	a3,a4,1250 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    124c:	fee7eae3          	bltu	a5,a4,1240 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1250:	ff852583          	lw	a1,-8(a0)
    1254:	6390                	ld	a2,0(a5)
    1256:	02059713          	slli	a4,a1,0x20
    125a:	9301                	srli	a4,a4,0x20
    125c:	0712                	slli	a4,a4,0x4
    125e:	9736                	add	a4,a4,a3
    1260:	fae60ae3          	beq	a2,a4,1214 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1264:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1268:	4790                	lw	a2,8(a5)
    126a:	02061713          	slli	a4,a2,0x20
    126e:	9301                	srli	a4,a4,0x20
    1270:	0712                	slli	a4,a4,0x4
    1272:	973e                	add	a4,a4,a5
    1274:	fae689e3          	beq	a3,a4,1226 <free+0x26>
  } else
    p->s.ptr = bp;
    1278:	e394                	sd	a3,0(a5)
  freep = p;
    127a:	00001717          	auipc	a4,0x1
    127e:	d8f73b23          	sd	a5,-618(a4) # 2010 <freep>
}
    1282:	6422                	ld	s0,8(sp)
    1284:	0141                	addi	sp,sp,16
    1286:	8082                	ret

0000000000001288 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1288:	7139                	addi	sp,sp,-64
    128a:	fc06                	sd	ra,56(sp)
    128c:	f822                	sd	s0,48(sp)
    128e:	f426                	sd	s1,40(sp)
    1290:	f04a                	sd	s2,32(sp)
    1292:	ec4e                	sd	s3,24(sp)
    1294:	e852                	sd	s4,16(sp)
    1296:	e456                	sd	s5,8(sp)
    1298:	e05a                	sd	s6,0(sp)
    129a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    129c:	02051493          	slli	s1,a0,0x20
    12a0:	9081                	srli	s1,s1,0x20
    12a2:	04bd                	addi	s1,s1,15
    12a4:	8091                	srli	s1,s1,0x4
    12a6:	0014899b          	addiw	s3,s1,1
    12aa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12ac:	00001517          	auipc	a0,0x1
    12b0:	d6453503          	ld	a0,-668(a0) # 2010 <freep>
    12b4:	c515                	beqz	a0,12e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12b6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12b8:	4798                	lw	a4,8(a5)
    12ba:	02977f63          	bgeu	a4,s1,12f8 <malloc+0x70>
    12be:	8a4e                	mv	s4,s3
    12c0:	0009871b          	sext.w	a4,s3
    12c4:	6685                	lui	a3,0x1
    12c6:	00d77363          	bgeu	a4,a3,12cc <malloc+0x44>
    12ca:	6a05                	lui	s4,0x1
    12cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12d0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12d4:	00001917          	auipc	s2,0x1
    12d8:	d3c90913          	addi	s2,s2,-708 # 2010 <freep>
  if(p == (char*)-1)
    12dc:	5afd                	li	s5,-1
    12de:	a88d                	j	1350 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    12e0:	00001797          	auipc	a5,0x1
    12e4:	da878793          	addi	a5,a5,-600 # 2088 <base>
    12e8:	00001717          	auipc	a4,0x1
    12ec:	d2f73423          	sd	a5,-728(a4) # 2010 <freep>
    12f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12f6:	b7e1                	j	12be <malloc+0x36>
      if(p->s.size == nunits)
    12f8:	02e48b63          	beq	s1,a4,132e <malloc+0xa6>
        p->s.size -= nunits;
    12fc:	4137073b          	subw	a4,a4,s3
    1300:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1302:	1702                	slli	a4,a4,0x20
    1304:	9301                	srli	a4,a4,0x20
    1306:	0712                	slli	a4,a4,0x4
    1308:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    130a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    130e:	00001717          	auipc	a4,0x1
    1312:	d0a73123          	sd	a0,-766(a4) # 2010 <freep>
      return (void*)(p + 1);
    1316:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    131a:	70e2                	ld	ra,56(sp)
    131c:	7442                	ld	s0,48(sp)
    131e:	74a2                	ld	s1,40(sp)
    1320:	7902                	ld	s2,32(sp)
    1322:	69e2                	ld	s3,24(sp)
    1324:	6a42                	ld	s4,16(sp)
    1326:	6aa2                	ld	s5,8(sp)
    1328:	6b02                	ld	s6,0(sp)
    132a:	6121                	addi	sp,sp,64
    132c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    132e:	6398                	ld	a4,0(a5)
    1330:	e118                	sd	a4,0(a0)
    1332:	bff1                	j	130e <malloc+0x86>
  hp->s.size = nu;
    1334:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1338:	0541                	addi	a0,a0,16
    133a:	00000097          	auipc	ra,0x0
    133e:	ec6080e7          	jalr	-314(ra) # 1200 <free>
  return freep;
    1342:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1346:	d971                	beqz	a0,131a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1348:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    134a:	4798                	lw	a4,8(a5)
    134c:	fa9776e3          	bgeu	a4,s1,12f8 <malloc+0x70>
    if(p == freep)
    1350:	00093703          	ld	a4,0(s2)
    1354:	853e                	mv	a0,a5
    1356:	fef719e3          	bne	a4,a5,1348 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    135a:	8552                	mv	a0,s4
    135c:	00000097          	auipc	ra,0x0
    1360:	b76080e7          	jalr	-1162(ra) # ed2 <sbrk>
  if(p == (char*)-1)
    1364:	fd5518e3          	bne	a0,s5,1334 <malloc+0xac>
        return 0;
    1368:	4501                	li	a0,0
    136a:	bf45                	j	131a <malloc+0x92>
