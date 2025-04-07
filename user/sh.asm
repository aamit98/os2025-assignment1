
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
      16:	37e58593          	addi	a1,a1,894 # 1390 <malloc+0xee>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	e58080e7          	jalr	-424(ra) # e74 <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	c2e080e7          	jalr	-978(ra) # c58 <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	c68080e7          	jalr	-920(ra) # c9e <gets>
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
      64:	33858593          	addi	a1,a1,824 # 1398 <malloc+0xf6>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	14c080e7          	jalr	332(ra) # 11b6 <fprintf>
  exit(1,"");
      72:	00001597          	auipc	a1,0x1
      76:	32e58593          	addi	a1,a1,814 # 13a0 <malloc+0xfe>
      7a:	4505                	li	a0,1
      7c:	00001097          	auipc	ra,0x1
      80:	dd8080e7          	jalr	-552(ra) # e54 <exit>

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
      90:	dc0080e7          	jalr	-576(ra) # e4c <fork>
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
      a6:	30650513          	addi	a0,a0,774 # 13a8 <malloc+0x106>
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
      d2:	3d270713          	addi	a4,a4,978 # 14a0 <malloc+0x1fe>
      d6:	97ba                	add	a5,a5,a4
      d8:	439c                	lw	a5,0(a5)
      da:	97ba                	add	a5,a5,a4
      dc:	8782                	jr	a5
    exit(1,"");
      de:	00001597          	auipc	a1,0x1
      e2:	2c258593          	addi	a1,a1,706 # 13a0 <malloc+0xfe>
      e6:	4505                	li	a0,1
      e8:	00001097          	auipc	ra,0x1
      ec:	d6c080e7          	jalr	-660(ra) # e54 <exit>
    panic("runcmd");
      f0:	00001517          	auipc	a0,0x1
      f4:	2c050513          	addi	a0,a0,704 # 13b0 <malloc+0x10e>
      f8:	00000097          	auipc	ra,0x0
      fc:	f5e080e7          	jalr	-162(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
     100:	6508                	ld	a0,8(a0)
     102:	c915                	beqz	a0,136 <runcmd+0x84>
    exec(ecmd->argv[0], ecmd->argv);
     104:	00848593          	addi	a1,s1,8
     108:	00001097          	auipc	ra,0x1
     10c:	d84080e7          	jalr	-636(ra) # e8c <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     110:	6490                	ld	a2,8(s1)
     112:	00001597          	auipc	a1,0x1
     116:	2a658593          	addi	a1,a1,678 # 13b8 <malloc+0x116>
     11a:	4509                	li	a0,2
     11c:	00001097          	auipc	ra,0x1
     120:	09a080e7          	jalr	154(ra) # 11b6 <fprintf>
  exit(0,"");
     124:	00001597          	auipc	a1,0x1
     128:	27c58593          	addi	a1,a1,636 # 13a0 <malloc+0xfe>
     12c:	4501                	li	a0,0
     12e:	00001097          	auipc	ra,0x1
     132:	d26080e7          	jalr	-730(ra) # e54 <exit>
      exit(1,"");
     136:	00001597          	auipc	a1,0x1
     13a:	26a58593          	addi	a1,a1,618 # 13a0 <malloc+0xfe>
     13e:	4505                	li	a0,1
     140:	00001097          	auipc	ra,0x1
     144:	d14080e7          	jalr	-748(ra) # e54 <exit>
    close(rcmd->fd);
     148:	5148                	lw	a0,36(a0)
     14a:	00001097          	auipc	ra,0x1
     14e:	d32080e7          	jalr	-718(ra) # e7c <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     152:	508c                	lw	a1,32(s1)
     154:	6888                	ld	a0,16(s1)
     156:	00001097          	auipc	ra,0x1
     15a:	d3e080e7          	jalr	-706(ra) # e94 <open>
     15e:	00054763          	bltz	a0,16c <runcmd+0xba>
    runcmd(rcmd->cmd);
     162:	6488                	ld	a0,8(s1)
     164:	00000097          	auipc	ra,0x0
     168:	f4e080e7          	jalr	-178(ra) # b2 <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     16c:	6890                	ld	a2,16(s1)
     16e:	00001597          	auipc	a1,0x1
     172:	25a58593          	addi	a1,a1,602 # 13c8 <malloc+0x126>
     176:	4509                	li	a0,2
     178:	00001097          	auipc	ra,0x1
     17c:	03e080e7          	jalr	62(ra) # 11b6 <fprintf>
      exit(1,"");
     180:	00001597          	auipc	a1,0x1
     184:	22058593          	addi	a1,a1,544 # 13a0 <malloc+0xfe>
     188:	4505                	li	a0,1
     18a:	00001097          	auipc	ra,0x1
     18e:	cca080e7          	jalr	-822(ra) # e54 <exit>
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
     1aa:	1fa58593          	addi	a1,a1,506 # 13a0 <malloc+0xfe>
     1ae:	4501                	li	a0,0
     1b0:	00001097          	auipc	ra,0x1
     1b4:	cac080e7          	jalr	-852(ra) # e5c <wait>
    runcmd(lcmd->right);
     1b8:	6888                	ld	a0,16(s1)
     1ba:	00000097          	auipc	ra,0x0
     1be:	ef8080e7          	jalr	-264(ra) # b2 <runcmd>
    if(pipe(p) < 0)
     1c2:	fd840513          	addi	a0,s0,-40
     1c6:	00001097          	auipc	ra,0x1
     1ca:	c9e080e7          	jalr	-866(ra) # e64 <pipe>
     1ce:	04054363          	bltz	a0,214 <runcmd+0x162>
    if(fork1() == 0){
     1d2:	00000097          	auipc	ra,0x0
     1d6:	eb2080e7          	jalr	-334(ra) # 84 <fork1>
     1da:	e529                	bnez	a0,224 <runcmd+0x172>
      close(1);
     1dc:	4505                	li	a0,1
     1de:	00001097          	auipc	ra,0x1
     1e2:	c9e080e7          	jalr	-866(ra) # e7c <close>
      dup(p[1]);
     1e6:	fdc42503          	lw	a0,-36(s0)
     1ea:	00001097          	auipc	ra,0x1
     1ee:	ce2080e7          	jalr	-798(ra) # ecc <dup>
      close(p[0]);
     1f2:	fd842503          	lw	a0,-40(s0)
     1f6:	00001097          	auipc	ra,0x1
     1fa:	c86080e7          	jalr	-890(ra) # e7c <close>
      close(p[1]);
     1fe:	fdc42503          	lw	a0,-36(s0)
     202:	00001097          	auipc	ra,0x1
     206:	c7a080e7          	jalr	-902(ra) # e7c <close>
      runcmd(pcmd->left);
     20a:	6488                	ld	a0,8(s1)
     20c:	00000097          	auipc	ra,0x0
     210:	ea6080e7          	jalr	-346(ra) # b2 <runcmd>
      panic("pipe");
     214:	00001517          	auipc	a0,0x1
     218:	1c450513          	addi	a0,a0,452 # 13d8 <malloc+0x136>
     21c:	00000097          	auipc	ra,0x0
     220:	e3a080e7          	jalr	-454(ra) # 56 <panic>
    if(fork1() == 0){
     224:	00000097          	auipc	ra,0x0
     228:	e60080e7          	jalr	-416(ra) # 84 <fork1>
     22c:	ed05                	bnez	a0,264 <runcmd+0x1b2>
      close(0);
     22e:	00001097          	auipc	ra,0x1
     232:	c4e080e7          	jalr	-946(ra) # e7c <close>
      dup(p[0]);
     236:	fd842503          	lw	a0,-40(s0)
     23a:	00001097          	auipc	ra,0x1
     23e:	c92080e7          	jalr	-878(ra) # ecc <dup>
      close(p[0]);
     242:	fd842503          	lw	a0,-40(s0)
     246:	00001097          	auipc	ra,0x1
     24a:	c36080e7          	jalr	-970(ra) # e7c <close>
      close(p[1]);
     24e:	fdc42503          	lw	a0,-36(s0)
     252:	00001097          	auipc	ra,0x1
     256:	c2a080e7          	jalr	-982(ra) # e7c <close>
      runcmd(pcmd->right);
     25a:	6888                	ld	a0,16(s1)
     25c:	00000097          	auipc	ra,0x0
     260:	e56080e7          	jalr	-426(ra) # b2 <runcmd>
    close(p[0]);
     264:	fd842503          	lw	a0,-40(s0)
     268:	00001097          	auipc	ra,0x1
     26c:	c14080e7          	jalr	-1004(ra) # e7c <close>
    close(p[1]);
     270:	fdc42503          	lw	a0,-36(s0)
     274:	00001097          	auipc	ra,0x1
     278:	c08080e7          	jalr	-1016(ra) # e7c <close>
    wait(0,"");
     27c:	00001597          	auipc	a1,0x1
     280:	12458593          	addi	a1,a1,292 # 13a0 <malloc+0xfe>
     284:	4501                	li	a0,0
     286:	00001097          	auipc	ra,0x1
     28a:	bd6080e7          	jalr	-1066(ra) # e5c <wait>
    wait(0,"");
     28e:	00001597          	auipc	a1,0x1
     292:	11258593          	addi	a1,a1,274 # 13a0 <malloc+0xfe>
     296:	4501                	li	a0,0
     298:	00001097          	auipc	ra,0x1
     29c:	bc4080e7          	jalr	-1084(ra) # e5c <wait>
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
     2ca:	fdc080e7          	jalr	-36(ra) # 12a2 <malloc>
     2ce:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2d0:	0a800613          	li	a2,168
     2d4:	4581                	li	a1,0
     2d6:	00001097          	auipc	ra,0x1
     2da:	982080e7          	jalr	-1662(ra) # c58 <memset>
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
     314:	f92080e7          	jalr	-110(ra) # 12a2 <malloc>
     318:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     31a:	02800613          	li	a2,40
     31e:	4581                	li	a1,0
     320:	00001097          	auipc	ra,0x1
     324:	938080e7          	jalr	-1736(ra) # c58 <memset>
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
     36e:	f38080e7          	jalr	-200(ra) # 12a2 <malloc>
     372:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     374:	4661                	li	a2,24
     376:	4581                	li	a1,0
     378:	00001097          	auipc	ra,0x1
     37c:	8e0080e7          	jalr	-1824(ra) # c58 <memset>
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
     3b4:	ef2080e7          	jalr	-270(ra) # 12a2 <malloc>
     3b8:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3ba:	4661                	li	a2,24
     3bc:	4581                	li	a1,0
     3be:	00001097          	auipc	ra,0x1
     3c2:	89a080e7          	jalr	-1894(ra) # c58 <memset>
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
     3f6:	eb0080e7          	jalr	-336(ra) # 12a2 <malloc>
     3fa:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3fc:	4641                	li	a2,16
     3fe:	4581                	li	a1,0
     400:	00001097          	auipc	ra,0x1
     404:	858080e7          	jalr	-1960(ra) # c58 <memset>
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
     452:	82c080e7          	jalr	-2004(ra) # c7a <strchr>
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
     4b6:	7c8080e7          	jalr	1992(ra) # c7a <strchr>
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
     528:	756080e7          	jalr	1878(ra) # c7a <strchr>
     52c:	e505                	bnez	a0,554 <gettoken+0x136>
     52e:	0004c583          	lbu	a1,0(s1)
     532:	8556                	mv	a0,s5
     534:	00000097          	auipc	ra,0x0
     538:	746080e7          	jalr	1862(ra) # c7a <strchr>
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
     58a:	6f4080e7          	jalr	1780(ra) # c7a <strchr>
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
     5ba:	6c4080e7          	jalr	1732(ra) # c7a <strchr>
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
     5e8:	e1cb8b93          	addi	s7,s7,-484 # 1400 <malloc+0x15e>
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
     5fa:	dea50513          	addi	a0,a0,-534 # 13e0 <malloc+0x13e>
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
     6e2:	d2a60613          	addi	a2,a2,-726 # 1408 <malloc+0x166>
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
     712:	d1ab0b13          	addi	s6,s6,-742 # 1428 <malloc+0x186>
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
     74c:	cc850513          	addi	a0,a0,-824 # 1410 <malloc+0x16e>
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
     7ae:	c6e50513          	addi	a0,a0,-914 # 1418 <malloc+0x176>
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
     7e8:	c4c60613          	addi	a2,a2,-948 # 1430 <malloc+0x18e>
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
     858:	be4a0a13          	addi	s4,s4,-1052 # 1438 <malloc+0x196>
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
     88e:	bb660613          	addi	a2,a2,-1098 # 1440 <malloc+0x19e>
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
     8f4:	b1860613          	addi	a2,a2,-1256 # 1408 <malloc+0x166>
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
     924:	b3860613          	addi	a2,a2,-1224 # 1458 <malloc+0x1b6>
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
     966:	ae650513          	addi	a0,a0,-1306 # 1448 <malloc+0x1a6>
     96a:	fffff097          	auipc	ra,0xfffff
     96e:	6ec080e7          	jalr	1772(ra) # 56 <panic>
    panic("syntax - missing )");
     972:	00001517          	auipc	a0,0x1
     976:	aee50513          	addi	a0,a0,-1298 # 1460 <malloc+0x1be>
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
     9a2:	b1a70713          	addi	a4,a4,-1254 # 14b8 <malloc+0x216>
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
     a30:	202080e7          	jalr	514(ra) # c2e <strlen>
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
     a4e:	95660613          	addi	a2,a2,-1706 # 13a0 <malloc+0xfe>
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
     a84:	9f858593          	addi	a1,a1,-1544 # 1478 <malloc+0x1d6>
     a88:	4509                	li	a0,2
     a8a:	00000097          	auipc	ra,0x0
     a8e:	72c080e7          	jalr	1836(ra) # 11b6 <fprintf>
    panic("syntax");
     a92:	00001517          	auipc	a0,0x1
     a96:	97e50513          	addi	a0,a0,-1666 # 1410 <malloc+0x16e>
     a9a:	fffff097          	auipc	ra,0xfffff
     a9e:	5bc080e7          	jalr	1468(ra) # 56 <panic>

0000000000000aa2 <main>:
{
     aa2:	7159                	addi	sp,sp,-112
     aa4:	f486                	sd	ra,104(sp)
     aa6:	f0a2                	sd	s0,96(sp)
     aa8:	eca6                	sd	s1,88(sp)
     aaa:	e8ca                	sd	s2,80(sp)
     aac:	e4ce                	sd	s3,72(sp)
     aae:	e0d2                	sd	s4,64(sp)
     ab0:	fc56                	sd	s5,56(sp)
     ab2:	f85a                	sd	s6,48(sp)
     ab4:	1880                	addi	s0,sp,112
  while((fd = open("console", O_RDWR)) >= 0){
     ab6:	00001497          	auipc	s1,0x1
     aba:	9d248493          	addi	s1,s1,-1582 # 1488 <malloc+0x1e6>
     abe:	4589                	li	a1,2
     ac0:	8526                	mv	a0,s1
     ac2:	00000097          	auipc	ra,0x0
     ac6:	3d2080e7          	jalr	978(ra) # e94 <open>
     aca:	00054963          	bltz	a0,adc <main+0x3a>
    if(fd >= 3){
     ace:	4789                	li	a5,2
     ad0:	fea7d7e3          	bge	a5,a0,abe <main+0x1c>
      close(fd);
     ad4:	00000097          	auipc	ra,0x0
     ad8:	3a8080e7          	jalr	936(ra) # e7c <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     adc:	00001497          	auipc	s1,0x1
     ae0:	54448493          	addi	s1,s1,1348 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     ae4:	06300913          	li	s2,99
        printf("%s\n", msg);
     ae8:	00001997          	auipc	s3,0x1
     aec:	8b098993          	addi	s3,s3,-1872 # 1398 <malloc+0xf6>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     af0:	02000a13          	li	s4,32
      if(chdir(buf+3) < 0)
     af4:	00001a97          	auipc	s5,0x1
     af8:	52fa8a93          	addi	s5,s5,1327 # 2023 <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     afc:	00001b17          	auipc	s6,0x1
     b00:	994b0b13          	addi	s6,s6,-1644 # 1490 <malloc+0x1ee>
     b04:	a00d                	j	b26 <main+0x84>
    if(fork1() == 0){
     b06:	fffff097          	auipc	ra,0xfffff
     b0a:	57e080e7          	jalr	1406(ra) # 84 <fork1>
     b0e:	cd35                	beqz	a0,b8a <main+0xe8>
      wait(&child_status, msg);
     b10:	fa040593          	addi	a1,s0,-96
     b14:	f9c40513          	addi	a0,s0,-100
     b18:	00000097          	auipc	ra,0x0
     b1c:	344080e7          	jalr	836(ra) # e5c <wait>
      if(msg[0] != '\0'){
     b20:	fa044783          	lbu	a5,-96(s0)
     b24:	efbd                	bnez	a5,ba2 <main+0x100>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b26:	06400593          	li	a1,100
     b2a:	8526                	mv	a0,s1
     b2c:	fffff097          	auipc	ra,0xfffff
     b30:	4d4080e7          	jalr	1236(ra) # 0 <getcmd>
     b34:	06054f63          	bltz	a0,bb2 <main+0x110>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b38:	0004c783          	lbu	a5,0(s1)
     b3c:	fd2795e3          	bne	a5,s2,b06 <main+0x64>
     b40:	0014c703          	lbu	a4,1(s1)
     b44:	06400793          	li	a5,100
     b48:	faf71fe3          	bne	a4,a5,b06 <main+0x64>
     b4c:	0024c783          	lbu	a5,2(s1)
     b50:	fb479be3          	bne	a5,s4,b06 <main+0x64>
      buf[strlen(buf)-1] = 0;  // chop \n
     b54:	8526                	mv	a0,s1
     b56:	00000097          	auipc	ra,0x0
     b5a:	0d8080e7          	jalr	216(ra) # c2e <strlen>
     b5e:	fff5079b          	addiw	a5,a0,-1
     b62:	1782                	slli	a5,a5,0x20
     b64:	9381                	srli	a5,a5,0x20
     b66:	97a6                	add	a5,a5,s1
     b68:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     b6c:	8556                	mv	a0,s5
     b6e:	00000097          	auipc	ra,0x0
     b72:	356080e7          	jalr	854(ra) # ec4 <chdir>
     b76:	fa0558e3          	bgez	a0,b26 <main+0x84>
        fprintf(2, "cannot cd %s\n", buf+3);
     b7a:	8656                	mv	a2,s5
     b7c:	85da                	mv	a1,s6
     b7e:	4509                	li	a0,2
     b80:	00000097          	auipc	ra,0x0
     b84:	636080e7          	jalr	1590(ra) # 11b6 <fprintf>
      continue;
     b88:	bf79                	j	b26 <main+0x84>
      runcmd(parsecmd(buf));
     b8a:	00001517          	auipc	a0,0x1
     b8e:	49650513          	addi	a0,a0,1174 # 2020 <buf.0>
     b92:	00000097          	auipc	ra,0x0
     b96:	e88080e7          	jalr	-376(ra) # a1a <parsecmd>
     b9a:	fffff097          	auipc	ra,0xfffff
     b9e:	518080e7          	jalr	1304(ra) # b2 <runcmd>
        printf("%s\n", msg);
     ba2:	fa040593          	addi	a1,s0,-96
     ba6:	854e                	mv	a0,s3
     ba8:	00000097          	auipc	ra,0x0
     bac:	63c080e7          	jalr	1596(ra) # 11e4 <printf>
     bb0:	bf9d                	j	b26 <main+0x84>
  exit(0,"");
     bb2:	00000597          	auipc	a1,0x0
     bb6:	7ee58593          	addi	a1,a1,2030 # 13a0 <malloc+0xfe>
     bba:	4501                	li	a0,0
     bbc:	00000097          	auipc	ra,0x0
     bc0:	298080e7          	jalr	664(ra) # e54 <exit>

0000000000000bc4 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     bc4:	1141                	addi	sp,sp,-16
     bc6:	e406                	sd	ra,8(sp)
     bc8:	e022                	sd	s0,0(sp)
     bca:	0800                	addi	s0,sp,16
  extern int main();
  main();
     bcc:	00000097          	auipc	ra,0x0
     bd0:	ed6080e7          	jalr	-298(ra) # aa2 <main>
  exit(0,"");
     bd4:	00000597          	auipc	a1,0x0
     bd8:	7cc58593          	addi	a1,a1,1996 # 13a0 <malloc+0xfe>
     bdc:	4501                	li	a0,0
     bde:	00000097          	auipc	ra,0x0
     be2:	276080e7          	jalr	630(ra) # e54 <exit>

0000000000000be6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     be6:	1141                	addi	sp,sp,-16
     be8:	e422                	sd	s0,8(sp)
     bea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     bec:	87aa                	mv	a5,a0
     bee:	0585                	addi	a1,a1,1
     bf0:	0785                	addi	a5,a5,1
     bf2:	fff5c703          	lbu	a4,-1(a1)
     bf6:	fee78fa3          	sb	a4,-1(a5)
     bfa:	fb75                	bnez	a4,bee <strcpy+0x8>
    ;
  return os;
}
     bfc:	6422                	ld	s0,8(sp)
     bfe:	0141                	addi	sp,sp,16
     c00:	8082                	ret

0000000000000c02 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c02:	1141                	addi	sp,sp,-16
     c04:	e422                	sd	s0,8(sp)
     c06:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c08:	00054783          	lbu	a5,0(a0)
     c0c:	cb91                	beqz	a5,c20 <strcmp+0x1e>
     c0e:	0005c703          	lbu	a4,0(a1)
     c12:	00f71763          	bne	a4,a5,c20 <strcmp+0x1e>
    p++, q++;
     c16:	0505                	addi	a0,a0,1
     c18:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c1a:	00054783          	lbu	a5,0(a0)
     c1e:	fbe5                	bnez	a5,c0e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c20:	0005c503          	lbu	a0,0(a1)
}
     c24:	40a7853b          	subw	a0,a5,a0
     c28:	6422                	ld	s0,8(sp)
     c2a:	0141                	addi	sp,sp,16
     c2c:	8082                	ret

0000000000000c2e <strlen>:

uint
strlen(const char *s)
{
     c2e:	1141                	addi	sp,sp,-16
     c30:	e422                	sd	s0,8(sp)
     c32:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c34:	00054783          	lbu	a5,0(a0)
     c38:	cf91                	beqz	a5,c54 <strlen+0x26>
     c3a:	0505                	addi	a0,a0,1
     c3c:	87aa                	mv	a5,a0
     c3e:	4685                	li	a3,1
     c40:	9e89                	subw	a3,a3,a0
     c42:	00f6853b          	addw	a0,a3,a5
     c46:	0785                	addi	a5,a5,1
     c48:	fff7c703          	lbu	a4,-1(a5)
     c4c:	fb7d                	bnez	a4,c42 <strlen+0x14>
    ;
  return n;
}
     c4e:	6422                	ld	s0,8(sp)
     c50:	0141                	addi	sp,sp,16
     c52:	8082                	ret
  for(n = 0; s[n]; n++)
     c54:	4501                	li	a0,0
     c56:	bfe5                	j	c4e <strlen+0x20>

0000000000000c58 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c58:	1141                	addi	sp,sp,-16
     c5a:	e422                	sd	s0,8(sp)
     c5c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c5e:	ca19                	beqz	a2,c74 <memset+0x1c>
     c60:	87aa                	mv	a5,a0
     c62:	1602                	slli	a2,a2,0x20
     c64:	9201                	srli	a2,a2,0x20
     c66:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c6a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c6e:	0785                	addi	a5,a5,1
     c70:	fee79de3          	bne	a5,a4,c6a <memset+0x12>
  }
  return dst;
}
     c74:	6422                	ld	s0,8(sp)
     c76:	0141                	addi	sp,sp,16
     c78:	8082                	ret

0000000000000c7a <strchr>:

char*
strchr(const char *s, char c)
{
     c7a:	1141                	addi	sp,sp,-16
     c7c:	e422                	sd	s0,8(sp)
     c7e:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c80:	00054783          	lbu	a5,0(a0)
     c84:	cb99                	beqz	a5,c9a <strchr+0x20>
    if(*s == c)
     c86:	00f58763          	beq	a1,a5,c94 <strchr+0x1a>
  for(; *s; s++)
     c8a:	0505                	addi	a0,a0,1
     c8c:	00054783          	lbu	a5,0(a0)
     c90:	fbfd                	bnez	a5,c86 <strchr+0xc>
      return (char*)s;
  return 0;
     c92:	4501                	li	a0,0
}
     c94:	6422                	ld	s0,8(sp)
     c96:	0141                	addi	sp,sp,16
     c98:	8082                	ret
  return 0;
     c9a:	4501                	li	a0,0
     c9c:	bfe5                	j	c94 <strchr+0x1a>

0000000000000c9e <gets>:

char*
gets(char *buf, int max)
{
     c9e:	711d                	addi	sp,sp,-96
     ca0:	ec86                	sd	ra,88(sp)
     ca2:	e8a2                	sd	s0,80(sp)
     ca4:	e4a6                	sd	s1,72(sp)
     ca6:	e0ca                	sd	s2,64(sp)
     ca8:	fc4e                	sd	s3,56(sp)
     caa:	f852                	sd	s4,48(sp)
     cac:	f456                	sd	s5,40(sp)
     cae:	f05a                	sd	s6,32(sp)
     cb0:	ec5e                	sd	s7,24(sp)
     cb2:	1080                	addi	s0,sp,96
     cb4:	8baa                	mv	s7,a0
     cb6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cb8:	892a                	mv	s2,a0
     cba:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     cbc:	4aa9                	li	s5,10
     cbe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     cc0:	89a6                	mv	s3,s1
     cc2:	2485                	addiw	s1,s1,1
     cc4:	0344d863          	bge	s1,s4,cf4 <gets+0x56>
    cc = read(0, &c, 1);
     cc8:	4605                	li	a2,1
     cca:	faf40593          	addi	a1,s0,-81
     cce:	4501                	li	a0,0
     cd0:	00000097          	auipc	ra,0x0
     cd4:	19c080e7          	jalr	412(ra) # e6c <read>
    if(cc < 1)
     cd8:	00a05e63          	blez	a0,cf4 <gets+0x56>
    buf[i++] = c;
     cdc:	faf44783          	lbu	a5,-81(s0)
     ce0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     ce4:	01578763          	beq	a5,s5,cf2 <gets+0x54>
     ce8:	0905                	addi	s2,s2,1
     cea:	fd679be3          	bne	a5,s6,cc0 <gets+0x22>
  for(i=0; i+1 < max; ){
     cee:	89a6                	mv	s3,s1
     cf0:	a011                	j	cf4 <gets+0x56>
     cf2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cf4:	99de                	add	s3,s3,s7
     cf6:	00098023          	sb	zero,0(s3)
  return buf;
}
     cfa:	855e                	mv	a0,s7
     cfc:	60e6                	ld	ra,88(sp)
     cfe:	6446                	ld	s0,80(sp)
     d00:	64a6                	ld	s1,72(sp)
     d02:	6906                	ld	s2,64(sp)
     d04:	79e2                	ld	s3,56(sp)
     d06:	7a42                	ld	s4,48(sp)
     d08:	7aa2                	ld	s5,40(sp)
     d0a:	7b02                	ld	s6,32(sp)
     d0c:	6be2                	ld	s7,24(sp)
     d0e:	6125                	addi	sp,sp,96
     d10:	8082                	ret

0000000000000d12 <stat>:

int
stat(const char *n, struct stat *st)
{
     d12:	1101                	addi	sp,sp,-32
     d14:	ec06                	sd	ra,24(sp)
     d16:	e822                	sd	s0,16(sp)
     d18:	e426                	sd	s1,8(sp)
     d1a:	e04a                	sd	s2,0(sp)
     d1c:	1000                	addi	s0,sp,32
     d1e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d20:	4581                	li	a1,0
     d22:	00000097          	auipc	ra,0x0
     d26:	172080e7          	jalr	370(ra) # e94 <open>
  if(fd < 0)
     d2a:	02054563          	bltz	a0,d54 <stat+0x42>
     d2e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d30:	85ca                	mv	a1,s2
     d32:	00000097          	auipc	ra,0x0
     d36:	17a080e7          	jalr	378(ra) # eac <fstat>
     d3a:	892a                	mv	s2,a0
  close(fd);
     d3c:	8526                	mv	a0,s1
     d3e:	00000097          	auipc	ra,0x0
     d42:	13e080e7          	jalr	318(ra) # e7c <close>
  return r;
}
     d46:	854a                	mv	a0,s2
     d48:	60e2                	ld	ra,24(sp)
     d4a:	6442                	ld	s0,16(sp)
     d4c:	64a2                	ld	s1,8(sp)
     d4e:	6902                	ld	s2,0(sp)
     d50:	6105                	addi	sp,sp,32
     d52:	8082                	ret
    return -1;
     d54:	597d                	li	s2,-1
     d56:	bfc5                	j	d46 <stat+0x34>

0000000000000d58 <atoi>:

int
atoi(const char *s)
{
     d58:	1141                	addi	sp,sp,-16
     d5a:	e422                	sd	s0,8(sp)
     d5c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d5e:	00054603          	lbu	a2,0(a0)
     d62:	fd06079b          	addiw	a5,a2,-48
     d66:	0ff7f793          	andi	a5,a5,255
     d6a:	4725                	li	a4,9
     d6c:	02f76963          	bltu	a4,a5,d9e <atoi+0x46>
     d70:	86aa                	mv	a3,a0
  n = 0;
     d72:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     d74:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     d76:	0685                	addi	a3,a3,1
     d78:	0025179b          	slliw	a5,a0,0x2
     d7c:	9fa9                	addw	a5,a5,a0
     d7e:	0017979b          	slliw	a5,a5,0x1
     d82:	9fb1                	addw	a5,a5,a2
     d84:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d88:	0006c603          	lbu	a2,0(a3)
     d8c:	fd06071b          	addiw	a4,a2,-48
     d90:	0ff77713          	andi	a4,a4,255
     d94:	fee5f1e3          	bgeu	a1,a4,d76 <atoi+0x1e>
  return n;
}
     d98:	6422                	ld	s0,8(sp)
     d9a:	0141                	addi	sp,sp,16
     d9c:	8082                	ret
  n = 0;
     d9e:	4501                	li	a0,0
     da0:	bfe5                	j	d98 <atoi+0x40>

0000000000000da2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     da2:	1141                	addi	sp,sp,-16
     da4:	e422                	sd	s0,8(sp)
     da6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     da8:	02b57463          	bgeu	a0,a1,dd0 <memmove+0x2e>
    while(n-- > 0)
     dac:	00c05f63          	blez	a2,dca <memmove+0x28>
     db0:	1602                	slli	a2,a2,0x20
     db2:	9201                	srli	a2,a2,0x20
     db4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     db8:	872a                	mv	a4,a0
      *dst++ = *src++;
     dba:	0585                	addi	a1,a1,1
     dbc:	0705                	addi	a4,a4,1
     dbe:	fff5c683          	lbu	a3,-1(a1)
     dc2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     dc6:	fee79ae3          	bne	a5,a4,dba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     dca:	6422                	ld	s0,8(sp)
     dcc:	0141                	addi	sp,sp,16
     dce:	8082                	ret
    dst += n;
     dd0:	00c50733          	add	a4,a0,a2
    src += n;
     dd4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     dd6:	fec05ae3          	blez	a2,dca <memmove+0x28>
     dda:	fff6079b          	addiw	a5,a2,-1
     dde:	1782                	slli	a5,a5,0x20
     de0:	9381                	srli	a5,a5,0x20
     de2:	fff7c793          	not	a5,a5
     de6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     de8:	15fd                	addi	a1,a1,-1
     dea:	177d                	addi	a4,a4,-1
     dec:	0005c683          	lbu	a3,0(a1)
     df0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     df4:	fee79ae3          	bne	a5,a4,de8 <memmove+0x46>
     df8:	bfc9                	j	dca <memmove+0x28>

0000000000000dfa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     dfa:	1141                	addi	sp,sp,-16
     dfc:	e422                	sd	s0,8(sp)
     dfe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e00:	ca05                	beqz	a2,e30 <memcmp+0x36>
     e02:	fff6069b          	addiw	a3,a2,-1
     e06:	1682                	slli	a3,a3,0x20
     e08:	9281                	srli	a3,a3,0x20
     e0a:	0685                	addi	a3,a3,1
     e0c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e0e:	00054783          	lbu	a5,0(a0)
     e12:	0005c703          	lbu	a4,0(a1)
     e16:	00e79863          	bne	a5,a4,e26 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e1a:	0505                	addi	a0,a0,1
    p2++;
     e1c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e1e:	fed518e3          	bne	a0,a3,e0e <memcmp+0x14>
  }
  return 0;
     e22:	4501                	li	a0,0
     e24:	a019                	j	e2a <memcmp+0x30>
      return *p1 - *p2;
     e26:	40e7853b          	subw	a0,a5,a4
}
     e2a:	6422                	ld	s0,8(sp)
     e2c:	0141                	addi	sp,sp,16
     e2e:	8082                	ret
  return 0;
     e30:	4501                	li	a0,0
     e32:	bfe5                	j	e2a <memcmp+0x30>

0000000000000e34 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e34:	1141                	addi	sp,sp,-16
     e36:	e406                	sd	ra,8(sp)
     e38:	e022                	sd	s0,0(sp)
     e3a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e3c:	00000097          	auipc	ra,0x0
     e40:	f66080e7          	jalr	-154(ra) # da2 <memmove>
}
     e44:	60a2                	ld	ra,8(sp)
     e46:	6402                	ld	s0,0(sp)
     e48:	0141                	addi	sp,sp,16
     e4a:	8082                	ret

0000000000000e4c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e4c:	4885                	li	a7,1
 ecall
     e4e:	00000073          	ecall
 ret
     e52:	8082                	ret

0000000000000e54 <exit>:
.global exit
exit:
 li a7, SYS_exit
     e54:	4889                	li	a7,2
 ecall
     e56:	00000073          	ecall
 ret
     e5a:	8082                	ret

0000000000000e5c <wait>:
.global wait
wait:
 li a7, SYS_wait
     e5c:	488d                	li	a7,3
 ecall
     e5e:	00000073          	ecall
 ret
     e62:	8082                	ret

0000000000000e64 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e64:	4891                	li	a7,4
 ecall
     e66:	00000073          	ecall
 ret
     e6a:	8082                	ret

0000000000000e6c <read>:
.global read
read:
 li a7, SYS_read
     e6c:	4895                	li	a7,5
 ecall
     e6e:	00000073          	ecall
 ret
     e72:	8082                	ret

0000000000000e74 <write>:
.global write
write:
 li a7, SYS_write
     e74:	48c1                	li	a7,16
 ecall
     e76:	00000073          	ecall
 ret
     e7a:	8082                	ret

0000000000000e7c <close>:
.global close
close:
 li a7, SYS_close
     e7c:	48d5                	li	a7,21
 ecall
     e7e:	00000073          	ecall
 ret
     e82:	8082                	ret

0000000000000e84 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e84:	4899                	li	a7,6
 ecall
     e86:	00000073          	ecall
 ret
     e8a:	8082                	ret

0000000000000e8c <exec>:
.global exec
exec:
 li a7, SYS_exec
     e8c:	489d                	li	a7,7
 ecall
     e8e:	00000073          	ecall
 ret
     e92:	8082                	ret

0000000000000e94 <open>:
.global open
open:
 li a7, SYS_open
     e94:	48bd                	li	a7,15
 ecall
     e96:	00000073          	ecall
 ret
     e9a:	8082                	ret

0000000000000e9c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e9c:	48c5                	li	a7,17
 ecall
     e9e:	00000073          	ecall
 ret
     ea2:	8082                	ret

0000000000000ea4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     ea4:	48c9                	li	a7,18
 ecall
     ea6:	00000073          	ecall
 ret
     eaa:	8082                	ret

0000000000000eac <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     eac:	48a1                	li	a7,8
 ecall
     eae:	00000073          	ecall
 ret
     eb2:	8082                	ret

0000000000000eb4 <link>:
.global link
link:
 li a7, SYS_link
     eb4:	48cd                	li	a7,19
 ecall
     eb6:	00000073          	ecall
 ret
     eba:	8082                	ret

0000000000000ebc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     ebc:	48d1                	li	a7,20
 ecall
     ebe:	00000073          	ecall
 ret
     ec2:	8082                	ret

0000000000000ec4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ec4:	48a5                	li	a7,9
 ecall
     ec6:	00000073          	ecall
 ret
     eca:	8082                	ret

0000000000000ecc <dup>:
.global dup
dup:
 li a7, SYS_dup
     ecc:	48a9                	li	a7,10
 ecall
     ece:	00000073          	ecall
 ret
     ed2:	8082                	ret

0000000000000ed4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     ed4:	48ad                	li	a7,11
 ecall
     ed6:	00000073          	ecall
 ret
     eda:	8082                	ret

0000000000000edc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     edc:	48b1                	li	a7,12
 ecall
     ede:	00000073          	ecall
 ret
     ee2:	8082                	ret

0000000000000ee4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     ee4:	48b5                	li	a7,13
 ecall
     ee6:	00000073          	ecall
 ret
     eea:	8082                	ret

0000000000000eec <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     eec:	48b9                	li	a7,14
 ecall
     eee:	00000073          	ecall
 ret
     ef2:	8082                	ret

0000000000000ef4 <memsize>:
.global memsize
memsize:
 li a7, SYS_memsize
     ef4:	48d9                	li	a7,22
 ecall
     ef6:	00000073          	ecall
 ret
     efa:	8082                	ret

0000000000000efc <forkn>:
.global forkn
forkn:
 li a7, SYS_forkn
     efc:	48dd                	li	a7,23
 ecall
     efe:	00000073          	ecall
 ret
     f02:	8082                	ret

0000000000000f04 <waitall>:
.global waitall
waitall:
 li a7, SYS_waitall
     f04:	48e1                	li	a7,24
 ecall
     f06:	00000073          	ecall
 ret
     f0a:	8082                	ret

0000000000000f0c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f0c:	1101                	addi	sp,sp,-32
     f0e:	ec06                	sd	ra,24(sp)
     f10:	e822                	sd	s0,16(sp)
     f12:	1000                	addi	s0,sp,32
     f14:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f18:	4605                	li	a2,1
     f1a:	fef40593          	addi	a1,s0,-17
     f1e:	00000097          	auipc	ra,0x0
     f22:	f56080e7          	jalr	-170(ra) # e74 <write>
}
     f26:	60e2                	ld	ra,24(sp)
     f28:	6442                	ld	s0,16(sp)
     f2a:	6105                	addi	sp,sp,32
     f2c:	8082                	ret

0000000000000f2e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f2e:	7139                	addi	sp,sp,-64
     f30:	fc06                	sd	ra,56(sp)
     f32:	f822                	sd	s0,48(sp)
     f34:	f426                	sd	s1,40(sp)
     f36:	f04a                	sd	s2,32(sp)
     f38:	ec4e                	sd	s3,24(sp)
     f3a:	0080                	addi	s0,sp,64
     f3c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f3e:	c299                	beqz	a3,f44 <printint+0x16>
     f40:	0805c863          	bltz	a1,fd0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f44:	2581                	sext.w	a1,a1
  neg = 0;
     f46:	4881                	li	a7,0
     f48:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f4c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f4e:	2601                	sext.w	a2,a2
     f50:	00000517          	auipc	a0,0x0
     f54:	58850513          	addi	a0,a0,1416 # 14d8 <digits>
     f58:	883a                	mv	a6,a4
     f5a:	2705                	addiw	a4,a4,1
     f5c:	02c5f7bb          	remuw	a5,a1,a2
     f60:	1782                	slli	a5,a5,0x20
     f62:	9381                	srli	a5,a5,0x20
     f64:	97aa                	add	a5,a5,a0
     f66:	0007c783          	lbu	a5,0(a5)
     f6a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f6e:	0005879b          	sext.w	a5,a1
     f72:	02c5d5bb          	divuw	a1,a1,a2
     f76:	0685                	addi	a3,a3,1
     f78:	fec7f0e3          	bgeu	a5,a2,f58 <printint+0x2a>
  if(neg)
     f7c:	00088b63          	beqz	a7,f92 <printint+0x64>
    buf[i++] = '-';
     f80:	fd040793          	addi	a5,s0,-48
     f84:	973e                	add	a4,a4,a5
     f86:	02d00793          	li	a5,45
     f8a:	fef70823          	sb	a5,-16(a4)
     f8e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f92:	02e05863          	blez	a4,fc2 <printint+0x94>
     f96:	fc040793          	addi	a5,s0,-64
     f9a:	00e78933          	add	s2,a5,a4
     f9e:	fff78993          	addi	s3,a5,-1
     fa2:	99ba                	add	s3,s3,a4
     fa4:	377d                	addiw	a4,a4,-1
     fa6:	1702                	slli	a4,a4,0x20
     fa8:	9301                	srli	a4,a4,0x20
     faa:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     fae:	fff94583          	lbu	a1,-1(s2)
     fb2:	8526                	mv	a0,s1
     fb4:	00000097          	auipc	ra,0x0
     fb8:	f58080e7          	jalr	-168(ra) # f0c <putc>
  while(--i >= 0)
     fbc:	197d                	addi	s2,s2,-1
     fbe:	ff3918e3          	bne	s2,s3,fae <printint+0x80>
}
     fc2:	70e2                	ld	ra,56(sp)
     fc4:	7442                	ld	s0,48(sp)
     fc6:	74a2                	ld	s1,40(sp)
     fc8:	7902                	ld	s2,32(sp)
     fca:	69e2                	ld	s3,24(sp)
     fcc:	6121                	addi	sp,sp,64
     fce:	8082                	ret
    x = -xx;
     fd0:	40b005bb          	negw	a1,a1
    neg = 1;
     fd4:	4885                	li	a7,1
    x = -xx;
     fd6:	bf8d                	j	f48 <printint+0x1a>

0000000000000fd8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     fd8:	7119                	addi	sp,sp,-128
     fda:	fc86                	sd	ra,120(sp)
     fdc:	f8a2                	sd	s0,112(sp)
     fde:	f4a6                	sd	s1,104(sp)
     fe0:	f0ca                	sd	s2,96(sp)
     fe2:	ecce                	sd	s3,88(sp)
     fe4:	e8d2                	sd	s4,80(sp)
     fe6:	e4d6                	sd	s5,72(sp)
     fe8:	e0da                	sd	s6,64(sp)
     fea:	fc5e                	sd	s7,56(sp)
     fec:	f862                	sd	s8,48(sp)
     fee:	f466                	sd	s9,40(sp)
     ff0:	f06a                	sd	s10,32(sp)
     ff2:	ec6e                	sd	s11,24(sp)
     ff4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     ff6:	0005c903          	lbu	s2,0(a1)
     ffa:	18090f63          	beqz	s2,1198 <vprintf+0x1c0>
     ffe:	8aaa                	mv	s5,a0
    1000:	8b32                	mv	s6,a2
    1002:	00158493          	addi	s1,a1,1
  state = 0;
    1006:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    1008:	02500a13          	li	s4,37
      if(c == 'd'){
    100c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1010:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    1014:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    1018:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    101c:	00000b97          	auipc	s7,0x0
    1020:	4bcb8b93          	addi	s7,s7,1212 # 14d8 <digits>
    1024:	a839                	j	1042 <vprintf+0x6a>
        putc(fd, c);
    1026:	85ca                	mv	a1,s2
    1028:	8556                	mv	a0,s5
    102a:	00000097          	auipc	ra,0x0
    102e:	ee2080e7          	jalr	-286(ra) # f0c <putc>
    1032:	a019                	j	1038 <vprintf+0x60>
    } else if(state == '%'){
    1034:	01498f63          	beq	s3,s4,1052 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    1038:	0485                	addi	s1,s1,1
    103a:	fff4c903          	lbu	s2,-1(s1)
    103e:	14090d63          	beqz	s2,1198 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1042:	0009079b          	sext.w	a5,s2
    if(state == 0){
    1046:	fe0997e3          	bnez	s3,1034 <vprintf+0x5c>
      if(c == '%'){
    104a:	fd479ee3          	bne	a5,s4,1026 <vprintf+0x4e>
        state = '%';
    104e:	89be                	mv	s3,a5
    1050:	b7e5                	j	1038 <vprintf+0x60>
      if(c == 'd'){
    1052:	05878063          	beq	a5,s8,1092 <vprintf+0xba>
      } else if(c == 'l') {
    1056:	05978c63          	beq	a5,s9,10ae <vprintf+0xd6>
      } else if(c == 'x') {
    105a:	07a78863          	beq	a5,s10,10ca <vprintf+0xf2>
      } else if(c == 'p') {
    105e:	09b78463          	beq	a5,s11,10e6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1062:	07300713          	li	a4,115
    1066:	0ce78663          	beq	a5,a4,1132 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    106a:	06300713          	li	a4,99
    106e:	0ee78e63          	beq	a5,a4,116a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1072:	11478863          	beq	a5,s4,1182 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    1076:	85d2                	mv	a1,s4
    1078:	8556                	mv	a0,s5
    107a:	00000097          	auipc	ra,0x0
    107e:	e92080e7          	jalr	-366(ra) # f0c <putc>
        putc(fd, c);
    1082:	85ca                	mv	a1,s2
    1084:	8556                	mv	a0,s5
    1086:	00000097          	auipc	ra,0x0
    108a:	e86080e7          	jalr	-378(ra) # f0c <putc>
      }
      state = 0;
    108e:	4981                	li	s3,0
    1090:	b765                	j	1038 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1092:	008b0913          	addi	s2,s6,8
    1096:	4685                	li	a3,1
    1098:	4629                	li	a2,10
    109a:	000b2583          	lw	a1,0(s6)
    109e:	8556                	mv	a0,s5
    10a0:	00000097          	auipc	ra,0x0
    10a4:	e8e080e7          	jalr	-370(ra) # f2e <printint>
    10a8:	8b4a                	mv	s6,s2
      state = 0;
    10aa:	4981                	li	s3,0
    10ac:	b771                	j	1038 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10ae:	008b0913          	addi	s2,s6,8
    10b2:	4681                	li	a3,0
    10b4:	4629                	li	a2,10
    10b6:	000b2583          	lw	a1,0(s6)
    10ba:	8556                	mv	a0,s5
    10bc:	00000097          	auipc	ra,0x0
    10c0:	e72080e7          	jalr	-398(ra) # f2e <printint>
    10c4:	8b4a                	mv	s6,s2
      state = 0;
    10c6:	4981                	li	s3,0
    10c8:	bf85                	j	1038 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    10ca:	008b0913          	addi	s2,s6,8
    10ce:	4681                	li	a3,0
    10d0:	4641                	li	a2,16
    10d2:	000b2583          	lw	a1,0(s6)
    10d6:	8556                	mv	a0,s5
    10d8:	00000097          	auipc	ra,0x0
    10dc:	e56080e7          	jalr	-426(ra) # f2e <printint>
    10e0:	8b4a                	mv	s6,s2
      state = 0;
    10e2:	4981                	li	s3,0
    10e4:	bf91                	j	1038 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    10e6:	008b0793          	addi	a5,s6,8
    10ea:	f8f43423          	sd	a5,-120(s0)
    10ee:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    10f2:	03000593          	li	a1,48
    10f6:	8556                	mv	a0,s5
    10f8:	00000097          	auipc	ra,0x0
    10fc:	e14080e7          	jalr	-492(ra) # f0c <putc>
  putc(fd, 'x');
    1100:	85ea                	mv	a1,s10
    1102:	8556                	mv	a0,s5
    1104:	00000097          	auipc	ra,0x0
    1108:	e08080e7          	jalr	-504(ra) # f0c <putc>
    110c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    110e:	03c9d793          	srli	a5,s3,0x3c
    1112:	97de                	add	a5,a5,s7
    1114:	0007c583          	lbu	a1,0(a5)
    1118:	8556                	mv	a0,s5
    111a:	00000097          	auipc	ra,0x0
    111e:	df2080e7          	jalr	-526(ra) # f0c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1122:	0992                	slli	s3,s3,0x4
    1124:	397d                	addiw	s2,s2,-1
    1126:	fe0914e3          	bnez	s2,110e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    112a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    112e:	4981                	li	s3,0
    1130:	b721                	j	1038 <vprintf+0x60>
        s = va_arg(ap, char*);
    1132:	008b0993          	addi	s3,s6,8
    1136:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    113a:	02090163          	beqz	s2,115c <vprintf+0x184>
        while(*s != 0){
    113e:	00094583          	lbu	a1,0(s2)
    1142:	c9a1                	beqz	a1,1192 <vprintf+0x1ba>
          putc(fd, *s);
    1144:	8556                	mv	a0,s5
    1146:	00000097          	auipc	ra,0x0
    114a:	dc6080e7          	jalr	-570(ra) # f0c <putc>
          s++;
    114e:	0905                	addi	s2,s2,1
        while(*s != 0){
    1150:	00094583          	lbu	a1,0(s2)
    1154:	f9e5                	bnez	a1,1144 <vprintf+0x16c>
        s = va_arg(ap, char*);
    1156:	8b4e                	mv	s6,s3
      state = 0;
    1158:	4981                	li	s3,0
    115a:	bdf9                	j	1038 <vprintf+0x60>
          s = "(null)";
    115c:	00000917          	auipc	s2,0x0
    1160:	37490913          	addi	s2,s2,884 # 14d0 <malloc+0x22e>
        while(*s != 0){
    1164:	02800593          	li	a1,40
    1168:	bff1                	j	1144 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    116a:	008b0913          	addi	s2,s6,8
    116e:	000b4583          	lbu	a1,0(s6)
    1172:	8556                	mv	a0,s5
    1174:	00000097          	auipc	ra,0x0
    1178:	d98080e7          	jalr	-616(ra) # f0c <putc>
    117c:	8b4a                	mv	s6,s2
      state = 0;
    117e:	4981                	li	s3,0
    1180:	bd65                	j	1038 <vprintf+0x60>
        putc(fd, c);
    1182:	85d2                	mv	a1,s4
    1184:	8556                	mv	a0,s5
    1186:	00000097          	auipc	ra,0x0
    118a:	d86080e7          	jalr	-634(ra) # f0c <putc>
      state = 0;
    118e:	4981                	li	s3,0
    1190:	b565                	j	1038 <vprintf+0x60>
        s = va_arg(ap, char*);
    1192:	8b4e                	mv	s6,s3
      state = 0;
    1194:	4981                	li	s3,0
    1196:	b54d                	j	1038 <vprintf+0x60>
    }
  }
}
    1198:	70e6                	ld	ra,120(sp)
    119a:	7446                	ld	s0,112(sp)
    119c:	74a6                	ld	s1,104(sp)
    119e:	7906                	ld	s2,96(sp)
    11a0:	69e6                	ld	s3,88(sp)
    11a2:	6a46                	ld	s4,80(sp)
    11a4:	6aa6                	ld	s5,72(sp)
    11a6:	6b06                	ld	s6,64(sp)
    11a8:	7be2                	ld	s7,56(sp)
    11aa:	7c42                	ld	s8,48(sp)
    11ac:	7ca2                	ld	s9,40(sp)
    11ae:	7d02                	ld	s10,32(sp)
    11b0:	6de2                	ld	s11,24(sp)
    11b2:	6109                	addi	sp,sp,128
    11b4:	8082                	ret

00000000000011b6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11b6:	715d                	addi	sp,sp,-80
    11b8:	ec06                	sd	ra,24(sp)
    11ba:	e822                	sd	s0,16(sp)
    11bc:	1000                	addi	s0,sp,32
    11be:	e010                	sd	a2,0(s0)
    11c0:	e414                	sd	a3,8(s0)
    11c2:	e818                	sd	a4,16(s0)
    11c4:	ec1c                	sd	a5,24(s0)
    11c6:	03043023          	sd	a6,32(s0)
    11ca:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    11ce:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    11d2:	8622                	mv	a2,s0
    11d4:	00000097          	auipc	ra,0x0
    11d8:	e04080e7          	jalr	-508(ra) # fd8 <vprintf>
}
    11dc:	60e2                	ld	ra,24(sp)
    11de:	6442                	ld	s0,16(sp)
    11e0:	6161                	addi	sp,sp,80
    11e2:	8082                	ret

00000000000011e4 <printf>:

void
printf(const char *fmt, ...)
{
    11e4:	711d                	addi	sp,sp,-96
    11e6:	ec06                	sd	ra,24(sp)
    11e8:	e822                	sd	s0,16(sp)
    11ea:	1000                	addi	s0,sp,32
    11ec:	e40c                	sd	a1,8(s0)
    11ee:	e810                	sd	a2,16(s0)
    11f0:	ec14                	sd	a3,24(s0)
    11f2:	f018                	sd	a4,32(s0)
    11f4:	f41c                	sd	a5,40(s0)
    11f6:	03043823          	sd	a6,48(s0)
    11fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11fe:	00840613          	addi	a2,s0,8
    1202:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1206:	85aa                	mv	a1,a0
    1208:	4505                	li	a0,1
    120a:	00000097          	auipc	ra,0x0
    120e:	dce080e7          	jalr	-562(ra) # fd8 <vprintf>
}
    1212:	60e2                	ld	ra,24(sp)
    1214:	6442                	ld	s0,16(sp)
    1216:	6125                	addi	sp,sp,96
    1218:	8082                	ret

000000000000121a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    121a:	1141                	addi	sp,sp,-16
    121c:	e422                	sd	s0,8(sp)
    121e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1220:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1224:	00001797          	auipc	a5,0x1
    1228:	dec7b783          	ld	a5,-532(a5) # 2010 <freep>
    122c:	a805                	j	125c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    122e:	4618                	lw	a4,8(a2)
    1230:	9db9                	addw	a1,a1,a4
    1232:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1236:	6398                	ld	a4,0(a5)
    1238:	6318                	ld	a4,0(a4)
    123a:	fee53823          	sd	a4,-16(a0)
    123e:	a091                	j	1282 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1240:	ff852703          	lw	a4,-8(a0)
    1244:	9e39                	addw	a2,a2,a4
    1246:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1248:	ff053703          	ld	a4,-16(a0)
    124c:	e398                	sd	a4,0(a5)
    124e:	a099                	j	1294 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1250:	6398                	ld	a4,0(a5)
    1252:	00e7e463          	bltu	a5,a4,125a <free+0x40>
    1256:	00e6ea63          	bltu	a3,a4,126a <free+0x50>
{
    125a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    125c:	fed7fae3          	bgeu	a5,a3,1250 <free+0x36>
    1260:	6398                	ld	a4,0(a5)
    1262:	00e6e463          	bltu	a3,a4,126a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1266:	fee7eae3          	bltu	a5,a4,125a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    126a:	ff852583          	lw	a1,-8(a0)
    126e:	6390                	ld	a2,0(a5)
    1270:	02059713          	slli	a4,a1,0x20
    1274:	9301                	srli	a4,a4,0x20
    1276:	0712                	slli	a4,a4,0x4
    1278:	9736                	add	a4,a4,a3
    127a:	fae60ae3          	beq	a2,a4,122e <free+0x14>
    bp->s.ptr = p->s.ptr;
    127e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1282:	4790                	lw	a2,8(a5)
    1284:	02061713          	slli	a4,a2,0x20
    1288:	9301                	srli	a4,a4,0x20
    128a:	0712                	slli	a4,a4,0x4
    128c:	973e                	add	a4,a4,a5
    128e:	fae689e3          	beq	a3,a4,1240 <free+0x26>
  } else
    p->s.ptr = bp;
    1292:	e394                	sd	a3,0(a5)
  freep = p;
    1294:	00001717          	auipc	a4,0x1
    1298:	d6f73e23          	sd	a5,-644(a4) # 2010 <freep>
}
    129c:	6422                	ld	s0,8(sp)
    129e:	0141                	addi	sp,sp,16
    12a0:	8082                	ret

00000000000012a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12a2:	7139                	addi	sp,sp,-64
    12a4:	fc06                	sd	ra,56(sp)
    12a6:	f822                	sd	s0,48(sp)
    12a8:	f426                	sd	s1,40(sp)
    12aa:	f04a                	sd	s2,32(sp)
    12ac:	ec4e                	sd	s3,24(sp)
    12ae:	e852                	sd	s4,16(sp)
    12b0:	e456                	sd	s5,8(sp)
    12b2:	e05a                	sd	s6,0(sp)
    12b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12b6:	02051493          	slli	s1,a0,0x20
    12ba:	9081                	srli	s1,s1,0x20
    12bc:	04bd                	addi	s1,s1,15
    12be:	8091                	srli	s1,s1,0x4
    12c0:	0014899b          	addiw	s3,s1,1
    12c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    12c6:	00001517          	auipc	a0,0x1
    12ca:	d4a53503          	ld	a0,-694(a0) # 2010 <freep>
    12ce:	c515                	beqz	a0,12fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12d2:	4798                	lw	a4,8(a5)
    12d4:	02977f63          	bgeu	a4,s1,1312 <malloc+0x70>
    12d8:	8a4e                	mv	s4,s3
    12da:	0009871b          	sext.w	a4,s3
    12de:	6685                	lui	a3,0x1
    12e0:	00d77363          	bgeu	a4,a3,12e6 <malloc+0x44>
    12e4:	6a05                	lui	s4,0x1
    12e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    12ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    12ee:	00001917          	auipc	s2,0x1
    12f2:	d2290913          	addi	s2,s2,-734 # 2010 <freep>
  if(p == (char*)-1)
    12f6:	5afd                	li	s5,-1
    12f8:	a88d                	j	136a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
    12fa:	00001797          	auipc	a5,0x1
    12fe:	d8e78793          	addi	a5,a5,-626 # 2088 <base>
    1302:	00001717          	auipc	a4,0x1
    1306:	d0f73723          	sd	a5,-754(a4) # 2010 <freep>
    130a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    130c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1310:	b7e1                	j	12d8 <malloc+0x36>
      if(p->s.size == nunits)
    1312:	02e48b63          	beq	s1,a4,1348 <malloc+0xa6>
        p->s.size -= nunits;
    1316:	4137073b          	subw	a4,a4,s3
    131a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    131c:	1702                	slli	a4,a4,0x20
    131e:	9301                	srli	a4,a4,0x20
    1320:	0712                	slli	a4,a4,0x4
    1322:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1324:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1328:	00001717          	auipc	a4,0x1
    132c:	cea73423          	sd	a0,-792(a4) # 2010 <freep>
      return (void*)(p + 1);
    1330:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1334:	70e2                	ld	ra,56(sp)
    1336:	7442                	ld	s0,48(sp)
    1338:	74a2                	ld	s1,40(sp)
    133a:	7902                	ld	s2,32(sp)
    133c:	69e2                	ld	s3,24(sp)
    133e:	6a42                	ld	s4,16(sp)
    1340:	6aa2                	ld	s5,8(sp)
    1342:	6b02                	ld	s6,0(sp)
    1344:	6121                	addi	sp,sp,64
    1346:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1348:	6398                	ld	a4,0(a5)
    134a:	e118                	sd	a4,0(a0)
    134c:	bff1                	j	1328 <malloc+0x86>
  hp->s.size = nu;
    134e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1352:	0541                	addi	a0,a0,16
    1354:	00000097          	auipc	ra,0x0
    1358:	ec6080e7          	jalr	-314(ra) # 121a <free>
  return freep;
    135c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1360:	d971                	beqz	a0,1334 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1362:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1364:	4798                	lw	a4,8(a5)
    1366:	fa9776e3          	bgeu	a4,s1,1312 <malloc+0x70>
    if(p == freep)
    136a:	00093703          	ld	a4,0(s2)
    136e:	853e                	mv	a0,a5
    1370:	fef719e3          	bne	a4,a5,1362 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
    1374:	8552                	mv	a0,s4
    1376:	00000097          	auipc	ra,0x0
    137a:	b66080e7          	jalr	-1178(ra) # edc <sbrk>
  if(p == (char*)-1)
    137e:	fd5518e3          	bne	a0,s5,134e <malloc+0xac>
        return 0;
    1382:	4501                	li	a0,0
    1384:	bf45                	j	1334 <malloc+0x92>
