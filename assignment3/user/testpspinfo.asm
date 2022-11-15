
user/_testpspinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/procstat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	0100                	addi	s0,sp,128
  int m, n, x;
  struct procstat pstat;

  if (argc != 3) {
   e:	478d                	li	a5,3
  10:	02f50063          	beq	a0,a5,30 <main+0x30>
     fprintf(2, "syntax: testpspinfo m n\nAborting...\n");
  14:	00001597          	auipc	a1,0x1
  18:	a8c58593          	addi	a1,a1,-1396 # aa0 <malloc+0xea>
  1c:	4509                	li	a0,2
  1e:	00001097          	auipc	ra,0x1
  22:	8b2080e7          	jalr	-1870(ra) # 8d0 <fprintf>
     exit(0);
  26:	4501                	li	a0,0
  28:	00000097          	auipc	ra,0x0
  2c:	4bc080e7          	jalr	1212(ra) # 4e4 <exit>
  30:	84ae                	mv	s1,a1
  }

  m = atoi(argv[1]);
  32:	6588                	ld	a0,8(a1)
  34:	00000097          	auipc	ra,0x0
  38:	3b6080e7          	jalr	950(ra) # 3ea <atoi>
  3c:	892a                	mv	s2,a0
  if (m <= 0) {
  3e:	02a05b63          	blez	a0,74 <main+0x74>
     fprintf(2, "Invalid input\nAborting...\n");
     exit(0);
  }
  n = atoi(argv[2]);
  42:	6888                	ld	a0,16(s1)
  44:	00000097          	auipc	ra,0x0
  48:	3a6080e7          	jalr	934(ra) # 3ea <atoi>
  4c:	84aa                	mv	s1,a0
  if ((n != 0) && (n != 1)) {
  4e:	0005071b          	sext.w	a4,a0
  52:	4785                	li	a5,1
  54:	02e7fe63          	bgeu	a5,a4,90 <main+0x90>
     fprintf(2, "Invalid input\nAborting...\n");
  58:	00001597          	auipc	a1,0x1
  5c:	a7058593          	addi	a1,a1,-1424 # ac8 <malloc+0x112>
  60:	4509                	li	a0,2
  62:	00001097          	auipc	ra,0x1
  66:	86e080e7          	jalr	-1938(ra) # 8d0 <fprintf>
     exit(0);
  6a:	4501                	li	a0,0
  6c:	00000097          	auipc	ra,0x0
  70:	478080e7          	jalr	1144(ra) # 4e4 <exit>
     fprintf(2, "Invalid input\nAborting...\n");
  74:	00001597          	auipc	a1,0x1
  78:	a5458593          	addi	a1,a1,-1452 # ac8 <malloc+0x112>
  7c:	4509                	li	a0,2
  7e:	00001097          	auipc	ra,0x1
  82:	852080e7          	jalr	-1966(ra) # 8d0 <fprintf>
     exit(0);
  86:	4501                	li	a0,0
  88:	00000097          	auipc	ra,0x0
  8c:	45c080e7          	jalr	1116(ra) # 4e4 <exit>
  }

  x = fork();
  90:	00000097          	auipc	ra,0x0
  94:	44c080e7          	jalr	1100(ra) # 4dc <fork>
  98:	89aa                	mv	s3,a0
  if (x < 0) {
  9a:	0e054e63          	bltz	a0,196 <main+0x196>
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  9e:	14a05463          	blez	a0,1e6 <main+0x1e6>
     if (n) sleep(m);
  a2:	10049863          	bnez	s1,1b2 <main+0x1b2>
     fprintf(1, "%d: Parent.\n", getpid());
  a6:	00000097          	auipc	ra,0x0
  aa:	4be080e7          	jalr	1214(ra) # 564 <getpid>
  ae:	862a                	mv	a2,a0
  b0:	00001597          	auipc	a1,0x1
  b4:	a5858593          	addi	a1,a1,-1448 # b08 <malloc+0x152>
  b8:	4505                	li	a0,1
  ba:	00001097          	auipc	ra,0x1
  be:	816080e7          	jalr	-2026(ra) # 8d0 <fprintf>
     ps();
  c2:	00000097          	auipc	ra,0x0
  c6:	4ea080e7          	jalr	1258(ra) # 5ac <ps>
     fprintf(1, "\n");
  ca:	00001597          	auipc	a1,0x1
  ce:	a5e58593          	addi	a1,a1,-1442 # b28 <malloc+0x172>
  d2:	4505                	li	a0,1
  d4:	00000097          	auipc	ra,0x0
  d8:	7fc080e7          	jalr	2044(ra) # 8d0 <fprintf>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
  dc:	f9840593          	addi	a1,s0,-104
  e0:	557d                	li	a0,-1
  e2:	00000097          	auipc	ra,0x0
  e6:	4d2080e7          	jalr	1234(ra) # 5b4 <pinfo>
  ea:	0c054a63          	bltz	a0,1be <main+0x1be>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  ee:	fc843783          	ld	a5,-56(s0)
  f2:	e43e                	sd	a5,8(sp)
  f4:	fc042783          	lw	a5,-64(s0)
  f8:	e03e                	sd	a5,0(sp)
  fa:	fbc42883          	lw	a7,-68(s0)
  fe:	fb842803          	lw	a6,-72(s0)
 102:	fa840793          	addi	a5,s0,-88
 106:	fa040713          	addi	a4,s0,-96
 10a:	f9c42683          	lw	a3,-100(s0)
 10e:	f9842603          	lw	a2,-104(s0)
 112:	00001597          	auipc	a1,0x1
 116:	a1e58593          	addi	a1,a1,-1506 # b30 <malloc+0x17a>
 11a:	4505                	li	a0,1
 11c:	00000097          	auipc	ra,0x0
 120:	7b4080e7          	jalr	1972(ra) # 8d0 <fprintf>
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 124:	f9840593          	addi	a1,s0,-104
 128:	854e                	mv	a0,s3
 12a:	00000097          	auipc	ra,0x0
 12e:	48a080e7          	jalr	1162(ra) # 5b4 <pinfo>
 132:	0a054063          	bltz	a0,1d2 <main+0x1d2>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
 136:	fc843783          	ld	a5,-56(s0)
 13a:	e43e                	sd	a5,8(sp)
 13c:	fc042783          	lw	a5,-64(s0)
 140:	e03e                	sd	a5,0(sp)
 142:	fbc42883          	lw	a7,-68(s0)
 146:	fb842803          	lw	a6,-72(s0)
 14a:	fa840793          	addi	a5,s0,-88
 14e:	fa040713          	addi	a4,s0,-96
 152:	f9c42683          	lw	a3,-100(s0)
 156:	f9842603          	lw	a2,-104(s0)
 15a:	00001597          	auipc	a1,0x1
 15e:	a2658593          	addi	a1,a1,-1498 # b80 <malloc+0x1ca>
 162:	4505                	li	a0,1
 164:	00000097          	auipc	ra,0x0
 168:	76c080e7          	jalr	1900(ra) # 8d0 <fprintf>
     fprintf(1, "Return value of waitpid=%d\n", waitpid(x, 0));
 16c:	4581                	li	a1,0
 16e:	854e                	mv	a0,s3
 170:	00000097          	auipc	ra,0x0
 174:	434080e7          	jalr	1076(ra) # 5a4 <waitpid>
 178:	862a                	mv	a2,a0
 17a:	00001597          	auipc	a1,0x1
 17e:	a5658593          	addi	a1,a1,-1450 # bd0 <malloc+0x21a>
 182:	4505                	li	a0,1
 184:	00000097          	auipc	ra,0x0
 188:	74c080e7          	jalr	1868(ra) # 8d0 <fprintf>
     sleep(1);
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  }

  exit(0);
 18c:	4501                	li	a0,0
 18e:	00000097          	auipc	ra,0x0
 192:	356080e7          	jalr	854(ra) # 4e4 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
 196:	00001597          	auipc	a1,0x1
 19a:	95258593          	addi	a1,a1,-1710 # ae8 <malloc+0x132>
 19e:	4509                	li	a0,2
 1a0:	00000097          	auipc	ra,0x0
 1a4:	730080e7          	jalr	1840(ra) # 8d0 <fprintf>
     exit(0);
 1a8:	4501                	li	a0,0
 1aa:	00000097          	auipc	ra,0x0
 1ae:	33a080e7          	jalr	826(ra) # 4e4 <exit>
     if (n) sleep(m);
 1b2:	854a                	mv	a0,s2
 1b4:	00000097          	auipc	ra,0x0
 1b8:	3c0080e7          	jalr	960(ra) # 574 <sleep>
 1bc:	b5ed                	j	a6 <main+0xa6>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 1be:	00001597          	auipc	a1,0x1
 1c2:	95a58593          	addi	a1,a1,-1702 # b18 <malloc+0x162>
 1c6:	4505                	li	a0,1
 1c8:	00000097          	auipc	ra,0x0
 1cc:	708080e7          	jalr	1800(ra) # 8d0 <fprintf>
 1d0:	bf91                	j	124 <main+0x124>
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 1d2:	00001597          	auipc	a1,0x1
 1d6:	94658593          	addi	a1,a1,-1722 # b18 <malloc+0x162>
 1da:	4505                	li	a0,1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	6f4080e7          	jalr	1780(ra) # 8d0 <fprintf>
 1e4:	b761                	j	16c <main+0x16c>
     if (!n) sleep(m);
 1e6:	c8ad                	beqz	s1,258 <main+0x258>
     fprintf(1, "%d: Child.\n", getpid());
 1e8:	00000097          	auipc	ra,0x0
 1ec:	37c080e7          	jalr	892(ra) # 564 <getpid>
 1f0:	862a                	mv	a2,a0
 1f2:	00001597          	auipc	a1,0x1
 1f6:	9fe58593          	addi	a1,a1,-1538 # bf0 <malloc+0x23a>
 1fa:	4505                	li	a0,1
 1fc:	00000097          	auipc	ra,0x0
 200:	6d4080e7          	jalr	1748(ra) # 8d0 <fprintf>
     sleep(1);
 204:	4505                	li	a0,1
 206:	00000097          	auipc	ra,0x0
 20a:	36e080e7          	jalr	878(ra) # 574 <sleep>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 20e:	f9840593          	addi	a1,s0,-104
 212:	557d                	li	a0,-1
 214:	00000097          	auipc	ra,0x0
 218:	3a0080e7          	jalr	928(ra) # 5b4 <pinfo>
 21c:	04054463          	bltz	a0,264 <main+0x264>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
 220:	fc843783          	ld	a5,-56(s0)
 224:	e43e                	sd	a5,8(sp)
 226:	fc042783          	lw	a5,-64(s0)
 22a:	e03e                	sd	a5,0(sp)
 22c:	fbc42883          	lw	a7,-68(s0)
 230:	fb842803          	lw	a6,-72(s0)
 234:	fa840793          	addi	a5,s0,-88
 238:	fa040713          	addi	a4,s0,-96
 23c:	f9c42683          	lw	a3,-100(s0)
 240:	f9842603          	lw	a2,-104(s0)
 244:	00001597          	auipc	a1,0x1
 248:	93c58593          	addi	a1,a1,-1732 # b80 <malloc+0x1ca>
 24c:	4505                	li	a0,1
 24e:	00000097          	auipc	ra,0x0
 252:	682080e7          	jalr	1666(ra) # 8d0 <fprintf>
 256:	bf1d                	j	18c <main+0x18c>
     if (!n) sleep(m);
 258:	854a                	mv	a0,s2
 25a:	00000097          	auipc	ra,0x0
 25e:	31a080e7          	jalr	794(ra) # 574 <sleep>
 262:	b759                	j	1e8 <main+0x1e8>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 264:	00001597          	auipc	a1,0x1
 268:	8b458593          	addi	a1,a1,-1868 # b18 <malloc+0x162>
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	662080e7          	jalr	1634(ra) # 8d0 <fprintf>
 276:	bf19                	j	18c <main+0x18c>

0000000000000278 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e422                	sd	s0,8(sp)
 27c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 27e:	87aa                	mv	a5,a0
 280:	0585                	addi	a1,a1,1
 282:	0785                	addi	a5,a5,1
 284:	fff5c703          	lbu	a4,-1(a1)
 288:	fee78fa3          	sb	a4,-1(a5)
 28c:	fb75                	bnez	a4,280 <strcpy+0x8>
    ;
  return os;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cb91                	beqz	a5,2b2 <strcmp+0x1e>
 2a0:	0005c703          	lbu	a4,0(a1)
 2a4:	00f71763          	bne	a4,a5,2b2 <strcmp+0x1e>
    p++, q++;
 2a8:	0505                	addi	a0,a0,1
 2aa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	fbe5                	bnez	a5,2a0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b2:	0005c503          	lbu	a0,0(a1)
}
 2b6:	40a7853b          	subw	a0,a5,a0
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret

00000000000002c0 <strlen>:

uint
strlen(const char *s)
{
 2c0:	1141                	addi	sp,sp,-16
 2c2:	e422                	sd	s0,8(sp)
 2c4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c6:	00054783          	lbu	a5,0(a0)
 2ca:	cf91                	beqz	a5,2e6 <strlen+0x26>
 2cc:	0505                	addi	a0,a0,1
 2ce:	87aa                	mv	a5,a0
 2d0:	4685                	li	a3,1
 2d2:	9e89                	subw	a3,a3,a0
 2d4:	00f6853b          	addw	a0,a3,a5
 2d8:	0785                	addi	a5,a5,1
 2da:	fff7c703          	lbu	a4,-1(a5)
 2de:	fb7d                	bnez	a4,2d4 <strlen+0x14>
    ;
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	addi	sp,sp,16
 2e4:	8082                	ret
  for(n = 0; s[n]; n++)
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <strlen+0x20>

00000000000002ea <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ea:	1141                	addi	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f0:	ca19                	beqz	a2,306 <memset+0x1c>
 2f2:	87aa                	mv	a5,a0
 2f4:	1602                	slli	a2,a2,0x20
 2f6:	9201                	srli	a2,a2,0x20
 2f8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 300:	0785                	addi	a5,a5,1
 302:	fee79de3          	bne	a5,a4,2fc <memset+0x12>
  }
  return dst;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret

000000000000030c <strchr>:

char*
strchr(const char *s, char c)
{
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
  for(; *s; s++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cb99                	beqz	a5,32c <strchr+0x20>
    if(*s == c)
 318:	00f58763          	beq	a1,a5,326 <strchr+0x1a>
  for(; *s; s++)
 31c:	0505                	addi	a0,a0,1
 31e:	00054783          	lbu	a5,0(a0)
 322:	fbfd                	bnez	a5,318 <strchr+0xc>
      return (char*)s;
  return 0;
 324:	4501                	li	a0,0
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret
  return 0;
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <strchr+0x1a>

0000000000000330 <gets>:

char*
gets(char *buf, int max)
{
 330:	711d                	addi	sp,sp,-96
 332:	ec86                	sd	ra,88(sp)
 334:	e8a2                	sd	s0,80(sp)
 336:	e4a6                	sd	s1,72(sp)
 338:	e0ca                	sd	s2,64(sp)
 33a:	fc4e                	sd	s3,56(sp)
 33c:	f852                	sd	s4,48(sp)
 33e:	f456                	sd	s5,40(sp)
 340:	f05a                	sd	s6,32(sp)
 342:	ec5e                	sd	s7,24(sp)
 344:	1080                	addi	s0,sp,96
 346:	8baa                	mv	s7,a0
 348:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34a:	892a                	mv	s2,a0
 34c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 34e:	4aa9                	li	s5,10
 350:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 352:	89a6                	mv	s3,s1
 354:	2485                	addiw	s1,s1,1
 356:	0344d863          	bge	s1,s4,386 <gets+0x56>
    cc = read(0, &c, 1);
 35a:	4605                	li	a2,1
 35c:	faf40593          	addi	a1,s0,-81
 360:	4501                	li	a0,0
 362:	00000097          	auipc	ra,0x0
 366:	19a080e7          	jalr	410(ra) # 4fc <read>
    if(cc < 1)
 36a:	00a05e63          	blez	a0,386 <gets+0x56>
    buf[i++] = c;
 36e:	faf44783          	lbu	a5,-81(s0)
 372:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 376:	01578763          	beq	a5,s5,384 <gets+0x54>
 37a:	0905                	addi	s2,s2,1
 37c:	fd679be3          	bne	a5,s6,352 <gets+0x22>
  for(i=0; i+1 < max; ){
 380:	89a6                	mv	s3,s1
 382:	a011                	j	386 <gets+0x56>
 384:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 386:	99de                	add	s3,s3,s7
 388:	00098023          	sb	zero,0(s3)
  return buf;
}
 38c:	855e                	mv	a0,s7
 38e:	60e6                	ld	ra,88(sp)
 390:	6446                	ld	s0,80(sp)
 392:	64a6                	ld	s1,72(sp)
 394:	6906                	ld	s2,64(sp)
 396:	79e2                	ld	s3,56(sp)
 398:	7a42                	ld	s4,48(sp)
 39a:	7aa2                	ld	s5,40(sp)
 39c:	7b02                	ld	s6,32(sp)
 39e:	6be2                	ld	s7,24(sp)
 3a0:	6125                	addi	sp,sp,96
 3a2:	8082                	ret

00000000000003a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	e426                	sd	s1,8(sp)
 3ac:	e04a                	sd	s2,0(sp)
 3ae:	1000                	addi	s0,sp,32
 3b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b2:	4581                	li	a1,0
 3b4:	00000097          	auipc	ra,0x0
 3b8:	170080e7          	jalr	368(ra) # 524 <open>
  if(fd < 0)
 3bc:	02054563          	bltz	a0,3e6 <stat+0x42>
 3c0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c2:	85ca                	mv	a1,s2
 3c4:	00000097          	auipc	ra,0x0
 3c8:	178080e7          	jalr	376(ra) # 53c <fstat>
 3cc:	892a                	mv	s2,a0
  close(fd);
 3ce:	8526                	mv	a0,s1
 3d0:	00000097          	auipc	ra,0x0
 3d4:	13c080e7          	jalr	316(ra) # 50c <close>
  return r;
}
 3d8:	854a                	mv	a0,s2
 3da:	60e2                	ld	ra,24(sp)
 3dc:	6442                	ld	s0,16(sp)
 3de:	64a2                	ld	s1,8(sp)
 3e0:	6902                	ld	s2,0(sp)
 3e2:	6105                	addi	sp,sp,32
 3e4:	8082                	ret
    return -1;
 3e6:	597d                	li	s2,-1
 3e8:	bfc5                	j	3d8 <stat+0x34>

00000000000003ea <atoi>:

int
atoi(const char *s)
{
 3ea:	1141                	addi	sp,sp,-16
 3ec:	e422                	sd	s0,8(sp)
 3ee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f0:	00054683          	lbu	a3,0(a0)
 3f4:	fd06879b          	addiw	a5,a3,-48
 3f8:	0ff7f793          	zext.b	a5,a5
 3fc:	4625                	li	a2,9
 3fe:	02f66863          	bltu	a2,a5,42e <atoi+0x44>
 402:	872a                	mv	a4,a0
  n = 0;
 404:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 406:	0705                	addi	a4,a4,1
 408:	0025179b          	slliw	a5,a0,0x2
 40c:	9fa9                	addw	a5,a5,a0
 40e:	0017979b          	slliw	a5,a5,0x1
 412:	9fb5                	addw	a5,a5,a3
 414:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 418:	00074683          	lbu	a3,0(a4)
 41c:	fd06879b          	addiw	a5,a3,-48
 420:	0ff7f793          	zext.b	a5,a5
 424:	fef671e3          	bgeu	a2,a5,406 <atoi+0x1c>
  return n;
}
 428:	6422                	ld	s0,8(sp)
 42a:	0141                	addi	sp,sp,16
 42c:	8082                	ret
  n = 0;
 42e:	4501                	li	a0,0
 430:	bfe5                	j	428 <atoi+0x3e>

0000000000000432 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 432:	1141                	addi	sp,sp,-16
 434:	e422                	sd	s0,8(sp)
 436:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 438:	02b57463          	bgeu	a0,a1,460 <memmove+0x2e>
    while(n-- > 0)
 43c:	00c05f63          	blez	a2,45a <memmove+0x28>
 440:	1602                	slli	a2,a2,0x20
 442:	9201                	srli	a2,a2,0x20
 444:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 448:	872a                	mv	a4,a0
      *dst++ = *src++;
 44a:	0585                	addi	a1,a1,1
 44c:	0705                	addi	a4,a4,1
 44e:	fff5c683          	lbu	a3,-1(a1)
 452:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 456:	fee79ae3          	bne	a5,a4,44a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 45a:	6422                	ld	s0,8(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret
    dst += n;
 460:	00c50733          	add	a4,a0,a2
    src += n;
 464:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 466:	fec05ae3          	blez	a2,45a <memmove+0x28>
 46a:	fff6079b          	addiw	a5,a2,-1
 46e:	1782                	slli	a5,a5,0x20
 470:	9381                	srli	a5,a5,0x20
 472:	fff7c793          	not	a5,a5
 476:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 478:	15fd                	addi	a1,a1,-1
 47a:	177d                	addi	a4,a4,-1
 47c:	0005c683          	lbu	a3,0(a1)
 480:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 484:	fee79ae3          	bne	a5,a4,478 <memmove+0x46>
 488:	bfc9                	j	45a <memmove+0x28>

000000000000048a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 48a:	1141                	addi	sp,sp,-16
 48c:	e422                	sd	s0,8(sp)
 48e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 490:	ca05                	beqz	a2,4c0 <memcmp+0x36>
 492:	fff6069b          	addiw	a3,a2,-1
 496:	1682                	slli	a3,a3,0x20
 498:	9281                	srli	a3,a3,0x20
 49a:	0685                	addi	a3,a3,1
 49c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 49e:	00054783          	lbu	a5,0(a0)
 4a2:	0005c703          	lbu	a4,0(a1)
 4a6:	00e79863          	bne	a5,a4,4b6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4aa:	0505                	addi	a0,a0,1
    p2++;
 4ac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4ae:	fed518e3          	bne	a0,a3,49e <memcmp+0x14>
  }
  return 0;
 4b2:	4501                	li	a0,0
 4b4:	a019                	j	4ba <memcmp+0x30>
      return *p1 - *p2;
 4b6:	40e7853b          	subw	a0,a5,a4
}
 4ba:	6422                	ld	s0,8(sp)
 4bc:	0141                	addi	sp,sp,16
 4be:	8082                	ret
  return 0;
 4c0:	4501                	li	a0,0
 4c2:	bfe5                	j	4ba <memcmp+0x30>

00000000000004c4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4c4:	1141                	addi	sp,sp,-16
 4c6:	e406                	sd	ra,8(sp)
 4c8:	e022                	sd	s0,0(sp)
 4ca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4cc:	00000097          	auipc	ra,0x0
 4d0:	f66080e7          	jalr	-154(ra) # 432 <memmove>
}
 4d4:	60a2                	ld	ra,8(sp)
 4d6:	6402                	ld	s0,0(sp)
 4d8:	0141                	addi	sp,sp,16
 4da:	8082                	ret

00000000000004dc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4dc:	4885                	li	a7,1
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4e4:	4889                	li	a7,2
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ec:	488d                	li	a7,3
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4f4:	4891                	li	a7,4
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <read>:
.global read
read:
 li a7, SYS_read
 4fc:	4895                	li	a7,5
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <write>:
.global write
write:
 li a7, SYS_write
 504:	48c1                	li	a7,16
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <close>:
.global close
close:
 li a7, SYS_close
 50c:	48d5                	li	a7,21
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <kill>:
.global kill
kill:
 li a7, SYS_kill
 514:	4899                	li	a7,6
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <exec>:
.global exec
exec:
 li a7, SYS_exec
 51c:	489d                	li	a7,7
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <open>:
.global open
open:
 li a7, SYS_open
 524:	48bd                	li	a7,15
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 52c:	48c5                	li	a7,17
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 534:	48c9                	li	a7,18
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 53c:	48a1                	li	a7,8
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <link>:
.global link
link:
 li a7, SYS_link
 544:	48cd                	li	a7,19
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 54c:	48d1                	li	a7,20
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 554:	48a5                	li	a7,9
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <dup>:
.global dup
dup:
 li a7, SYS_dup
 55c:	48a9                	li	a7,10
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 564:	48ad                	li	a7,11
 ecall
 566:	00000073          	ecall
 ret
 56a:	8082                	ret

000000000000056c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 56c:	48b1                	li	a7,12
 ecall
 56e:	00000073          	ecall
 ret
 572:	8082                	ret

0000000000000574 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 574:	48b5                	li	a7,13
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 57c:	48b9                	li	a7,14
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 584:	48d9                	li	a7,22
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <yield>:
.global yield
yield:
 li a7, SYS_yield
 58c:	48dd                	li	a7,23
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 594:	48e1                	li	a7,24
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 59c:	48e5                	li	a7,25
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 5a4:	48e9                	li	a7,26
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <ps>:
.global ps
ps:
 li a7, SYS_ps
 5ac:	48ed                	li	a7,27
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 5b4:	48f1                	li	a7,28
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 5bc:	48f5                	li	a7,29
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 5c4:	48f9                	li	a7,30
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 5cc:	02100893          	li	a7,33
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 5d6:	48fd                	li	a7,31
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 5de:	02000893          	li	a7,32
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 5e8:	02200893          	li	a7,34
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 5f2:	02300893          	li	a7,35
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 5fc:	02400893          	li	a7,36
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 606:	02500893          	li	a7,37
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 610:	02700893          	li	a7,39
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 61a:	02600893          	li	a7,38
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 624:	1101                	addi	sp,sp,-32
 626:	ec06                	sd	ra,24(sp)
 628:	e822                	sd	s0,16(sp)
 62a:	1000                	addi	s0,sp,32
 62c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 630:	4605                	li	a2,1
 632:	fef40593          	addi	a1,s0,-17
 636:	00000097          	auipc	ra,0x0
 63a:	ece080e7          	jalr	-306(ra) # 504 <write>
}
 63e:	60e2                	ld	ra,24(sp)
 640:	6442                	ld	s0,16(sp)
 642:	6105                	addi	sp,sp,32
 644:	8082                	ret

0000000000000646 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 646:	7139                	addi	sp,sp,-64
 648:	fc06                	sd	ra,56(sp)
 64a:	f822                	sd	s0,48(sp)
 64c:	f426                	sd	s1,40(sp)
 64e:	f04a                	sd	s2,32(sp)
 650:	ec4e                	sd	s3,24(sp)
 652:	0080                	addi	s0,sp,64
 654:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 656:	c299                	beqz	a3,65c <printint+0x16>
 658:	0805c963          	bltz	a1,6ea <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 65c:	2581                	sext.w	a1,a1
  neg = 0;
 65e:	4881                	li	a7,0
 660:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 664:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 666:	2601                	sext.w	a2,a2
 668:	00000517          	auipc	a0,0x0
 66c:	5f850513          	addi	a0,a0,1528 # c60 <digits>
 670:	883a                	mv	a6,a4
 672:	2705                	addiw	a4,a4,1
 674:	02c5f7bb          	remuw	a5,a1,a2
 678:	1782                	slli	a5,a5,0x20
 67a:	9381                	srli	a5,a5,0x20
 67c:	97aa                	add	a5,a5,a0
 67e:	0007c783          	lbu	a5,0(a5)
 682:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 686:	0005879b          	sext.w	a5,a1
 68a:	02c5d5bb          	divuw	a1,a1,a2
 68e:	0685                	addi	a3,a3,1
 690:	fec7f0e3          	bgeu	a5,a2,670 <printint+0x2a>
  if(neg)
 694:	00088c63          	beqz	a7,6ac <printint+0x66>
    buf[i++] = '-';
 698:	fd070793          	addi	a5,a4,-48
 69c:	00878733          	add	a4,a5,s0
 6a0:	02d00793          	li	a5,45
 6a4:	fef70823          	sb	a5,-16(a4)
 6a8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6ac:	02e05863          	blez	a4,6dc <printint+0x96>
 6b0:	fc040793          	addi	a5,s0,-64
 6b4:	00e78933          	add	s2,a5,a4
 6b8:	fff78993          	addi	s3,a5,-1
 6bc:	99ba                	add	s3,s3,a4
 6be:	377d                	addiw	a4,a4,-1
 6c0:	1702                	slli	a4,a4,0x20
 6c2:	9301                	srli	a4,a4,0x20
 6c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6c8:	fff94583          	lbu	a1,-1(s2)
 6cc:	8526                	mv	a0,s1
 6ce:	00000097          	auipc	ra,0x0
 6d2:	f56080e7          	jalr	-170(ra) # 624 <putc>
  while(--i >= 0)
 6d6:	197d                	addi	s2,s2,-1
 6d8:	ff3918e3          	bne	s2,s3,6c8 <printint+0x82>
}
 6dc:	70e2                	ld	ra,56(sp)
 6de:	7442                	ld	s0,48(sp)
 6e0:	74a2                	ld	s1,40(sp)
 6e2:	7902                	ld	s2,32(sp)
 6e4:	69e2                	ld	s3,24(sp)
 6e6:	6121                	addi	sp,sp,64
 6e8:	8082                	ret
    x = -xx;
 6ea:	40b005bb          	negw	a1,a1
    neg = 1;
 6ee:	4885                	li	a7,1
    x = -xx;
 6f0:	bf85                	j	660 <printint+0x1a>

00000000000006f2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6f2:	7119                	addi	sp,sp,-128
 6f4:	fc86                	sd	ra,120(sp)
 6f6:	f8a2                	sd	s0,112(sp)
 6f8:	f4a6                	sd	s1,104(sp)
 6fa:	f0ca                	sd	s2,96(sp)
 6fc:	ecce                	sd	s3,88(sp)
 6fe:	e8d2                	sd	s4,80(sp)
 700:	e4d6                	sd	s5,72(sp)
 702:	e0da                	sd	s6,64(sp)
 704:	fc5e                	sd	s7,56(sp)
 706:	f862                	sd	s8,48(sp)
 708:	f466                	sd	s9,40(sp)
 70a:	f06a                	sd	s10,32(sp)
 70c:	ec6e                	sd	s11,24(sp)
 70e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 710:	0005c903          	lbu	s2,0(a1)
 714:	18090f63          	beqz	s2,8b2 <vprintf+0x1c0>
 718:	8aaa                	mv	s5,a0
 71a:	8b32                	mv	s6,a2
 71c:	00158493          	addi	s1,a1,1
  state = 0;
 720:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 722:	02500a13          	li	s4,37
 726:	4c55                	li	s8,21
 728:	00000c97          	auipc	s9,0x0
 72c:	4e0c8c93          	addi	s9,s9,1248 # c08 <malloc+0x252>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 730:	02800d93          	li	s11,40
  putc(fd, 'x');
 734:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 736:	00000b97          	auipc	s7,0x0
 73a:	52ab8b93          	addi	s7,s7,1322 # c60 <digits>
 73e:	a839                	j	75c <vprintf+0x6a>
        putc(fd, c);
 740:	85ca                	mv	a1,s2
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	ee0080e7          	jalr	-288(ra) # 624 <putc>
 74c:	a019                	j	752 <vprintf+0x60>
    } else if(state == '%'){
 74e:	01498d63          	beq	s3,s4,768 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 752:	0485                	addi	s1,s1,1
 754:	fff4c903          	lbu	s2,-1(s1)
 758:	14090d63          	beqz	s2,8b2 <vprintf+0x1c0>
    if(state == 0){
 75c:	fe0999e3          	bnez	s3,74e <vprintf+0x5c>
      if(c == '%'){
 760:	ff4910e3          	bne	s2,s4,740 <vprintf+0x4e>
        state = '%';
 764:	89d2                	mv	s3,s4
 766:	b7f5                	j	752 <vprintf+0x60>
      if(c == 'd'){
 768:	11490c63          	beq	s2,s4,880 <vprintf+0x18e>
 76c:	f9d9079b          	addiw	a5,s2,-99
 770:	0ff7f793          	zext.b	a5,a5
 774:	10fc6e63          	bltu	s8,a5,890 <vprintf+0x19e>
 778:	f9d9079b          	addiw	a5,s2,-99
 77c:	0ff7f713          	zext.b	a4,a5
 780:	10ec6863          	bltu	s8,a4,890 <vprintf+0x19e>
 784:	00271793          	slli	a5,a4,0x2
 788:	97e6                	add	a5,a5,s9
 78a:	439c                	lw	a5,0(a5)
 78c:	97e6                	add	a5,a5,s9
 78e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 790:	008b0913          	addi	s2,s6,8
 794:	4685                	li	a3,1
 796:	4629                	li	a2,10
 798:	000b2583          	lw	a1,0(s6)
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	ea8080e7          	jalr	-344(ra) # 646 <printint>
 7a6:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b765                	j	752 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ac:	008b0913          	addi	s2,s6,8
 7b0:	4681                	li	a3,0
 7b2:	4629                	li	a2,10
 7b4:	000b2583          	lw	a1,0(s6)
 7b8:	8556                	mv	a0,s5
 7ba:	00000097          	auipc	ra,0x0
 7be:	e8c080e7          	jalr	-372(ra) # 646 <printint>
 7c2:	8b4a                	mv	s6,s2
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	b771                	j	752 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 7c8:	008b0913          	addi	s2,s6,8
 7cc:	4681                	li	a3,0
 7ce:	866a                	mv	a2,s10
 7d0:	000b2583          	lw	a1,0(s6)
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	e70080e7          	jalr	-400(ra) # 646 <printint>
 7de:	8b4a                	mv	s6,s2
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	bf85                	j	752 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 7e4:	008b0793          	addi	a5,s6,8
 7e8:	f8f43423          	sd	a5,-120(s0)
 7ec:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 7f0:	03000593          	li	a1,48
 7f4:	8556                	mv	a0,s5
 7f6:	00000097          	auipc	ra,0x0
 7fa:	e2e080e7          	jalr	-466(ra) # 624 <putc>
  putc(fd, 'x');
 7fe:	07800593          	li	a1,120
 802:	8556                	mv	a0,s5
 804:	00000097          	auipc	ra,0x0
 808:	e20080e7          	jalr	-480(ra) # 624 <putc>
 80c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 80e:	03c9d793          	srli	a5,s3,0x3c
 812:	97de                	add	a5,a5,s7
 814:	0007c583          	lbu	a1,0(a5)
 818:	8556                	mv	a0,s5
 81a:	00000097          	auipc	ra,0x0
 81e:	e0a080e7          	jalr	-502(ra) # 624 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 822:	0992                	slli	s3,s3,0x4
 824:	397d                	addiw	s2,s2,-1
 826:	fe0914e3          	bnez	s2,80e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 82a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 82e:	4981                	li	s3,0
 830:	b70d                	j	752 <vprintf+0x60>
        s = va_arg(ap, char*);
 832:	008b0913          	addi	s2,s6,8
 836:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 83a:	02098163          	beqz	s3,85c <vprintf+0x16a>
        while(*s != 0){
 83e:	0009c583          	lbu	a1,0(s3)
 842:	c5ad                	beqz	a1,8ac <vprintf+0x1ba>
          putc(fd, *s);
 844:	8556                	mv	a0,s5
 846:	00000097          	auipc	ra,0x0
 84a:	dde080e7          	jalr	-546(ra) # 624 <putc>
          s++;
 84e:	0985                	addi	s3,s3,1
        while(*s != 0){
 850:	0009c583          	lbu	a1,0(s3)
 854:	f9e5                	bnez	a1,844 <vprintf+0x152>
        s = va_arg(ap, char*);
 856:	8b4a                	mv	s6,s2
      state = 0;
 858:	4981                	li	s3,0
 85a:	bde5                	j	752 <vprintf+0x60>
          s = "(null)";
 85c:	00000997          	auipc	s3,0x0
 860:	3a498993          	addi	s3,s3,932 # c00 <malloc+0x24a>
        while(*s != 0){
 864:	85ee                	mv	a1,s11
 866:	bff9                	j	844 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 868:	008b0913          	addi	s2,s6,8
 86c:	000b4583          	lbu	a1,0(s6)
 870:	8556                	mv	a0,s5
 872:	00000097          	auipc	ra,0x0
 876:	db2080e7          	jalr	-590(ra) # 624 <putc>
 87a:	8b4a                	mv	s6,s2
      state = 0;
 87c:	4981                	li	s3,0
 87e:	bdd1                	j	752 <vprintf+0x60>
        putc(fd, c);
 880:	85d2                	mv	a1,s4
 882:	8556                	mv	a0,s5
 884:	00000097          	auipc	ra,0x0
 888:	da0080e7          	jalr	-608(ra) # 624 <putc>
      state = 0;
 88c:	4981                	li	s3,0
 88e:	b5d1                	j	752 <vprintf+0x60>
        putc(fd, '%');
 890:	85d2                	mv	a1,s4
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	d90080e7          	jalr	-624(ra) # 624 <putc>
        putc(fd, c);
 89c:	85ca                	mv	a1,s2
 89e:	8556                	mv	a0,s5
 8a0:	00000097          	auipc	ra,0x0
 8a4:	d84080e7          	jalr	-636(ra) # 624 <putc>
      state = 0;
 8a8:	4981                	li	s3,0
 8aa:	b565                	j	752 <vprintf+0x60>
        s = va_arg(ap, char*);
 8ac:	8b4a                	mv	s6,s2
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	b54d                	j	752 <vprintf+0x60>
    }
  }
}
 8b2:	70e6                	ld	ra,120(sp)
 8b4:	7446                	ld	s0,112(sp)
 8b6:	74a6                	ld	s1,104(sp)
 8b8:	7906                	ld	s2,96(sp)
 8ba:	69e6                	ld	s3,88(sp)
 8bc:	6a46                	ld	s4,80(sp)
 8be:	6aa6                	ld	s5,72(sp)
 8c0:	6b06                	ld	s6,64(sp)
 8c2:	7be2                	ld	s7,56(sp)
 8c4:	7c42                	ld	s8,48(sp)
 8c6:	7ca2                	ld	s9,40(sp)
 8c8:	7d02                	ld	s10,32(sp)
 8ca:	6de2                	ld	s11,24(sp)
 8cc:	6109                	addi	sp,sp,128
 8ce:	8082                	ret

00000000000008d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8d0:	715d                	addi	sp,sp,-80
 8d2:	ec06                	sd	ra,24(sp)
 8d4:	e822                	sd	s0,16(sp)
 8d6:	1000                	addi	s0,sp,32
 8d8:	e010                	sd	a2,0(s0)
 8da:	e414                	sd	a3,8(s0)
 8dc:	e818                	sd	a4,16(s0)
 8de:	ec1c                	sd	a5,24(s0)
 8e0:	03043023          	sd	a6,32(s0)
 8e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8ec:	8622                	mv	a2,s0
 8ee:	00000097          	auipc	ra,0x0
 8f2:	e04080e7          	jalr	-508(ra) # 6f2 <vprintf>
}
 8f6:	60e2                	ld	ra,24(sp)
 8f8:	6442                	ld	s0,16(sp)
 8fa:	6161                	addi	sp,sp,80
 8fc:	8082                	ret

00000000000008fe <printf>:

void
printf(const char *fmt, ...)
{
 8fe:	711d                	addi	sp,sp,-96
 900:	ec06                	sd	ra,24(sp)
 902:	e822                	sd	s0,16(sp)
 904:	1000                	addi	s0,sp,32
 906:	e40c                	sd	a1,8(s0)
 908:	e810                	sd	a2,16(s0)
 90a:	ec14                	sd	a3,24(s0)
 90c:	f018                	sd	a4,32(s0)
 90e:	f41c                	sd	a5,40(s0)
 910:	03043823          	sd	a6,48(s0)
 914:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 918:	00840613          	addi	a2,s0,8
 91c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 920:	85aa                	mv	a1,a0
 922:	4505                	li	a0,1
 924:	00000097          	auipc	ra,0x0
 928:	dce080e7          	jalr	-562(ra) # 6f2 <vprintf>
}
 92c:	60e2                	ld	ra,24(sp)
 92e:	6442                	ld	s0,16(sp)
 930:	6125                	addi	sp,sp,96
 932:	8082                	ret

0000000000000934 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 934:	1141                	addi	sp,sp,-16
 936:	e422                	sd	s0,8(sp)
 938:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 93a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93e:	00000797          	auipc	a5,0x0
 942:	33a7b783          	ld	a5,826(a5) # c78 <freep>
 946:	a02d                	j	970 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 948:	4618                	lw	a4,8(a2)
 94a:	9f2d                	addw	a4,a4,a1
 94c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 950:	6398                	ld	a4,0(a5)
 952:	6310                	ld	a2,0(a4)
 954:	a83d                	j	992 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 956:	ff852703          	lw	a4,-8(a0)
 95a:	9f31                	addw	a4,a4,a2
 95c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 95e:	ff053683          	ld	a3,-16(a0)
 962:	a091                	j	9a6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 964:	6398                	ld	a4,0(a5)
 966:	00e7e463          	bltu	a5,a4,96e <free+0x3a>
 96a:	00e6ea63          	bltu	a3,a4,97e <free+0x4a>
{
 96e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 970:	fed7fae3          	bgeu	a5,a3,964 <free+0x30>
 974:	6398                	ld	a4,0(a5)
 976:	00e6e463          	bltu	a3,a4,97e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 97a:	fee7eae3          	bltu	a5,a4,96e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 97e:	ff852583          	lw	a1,-8(a0)
 982:	6390                	ld	a2,0(a5)
 984:	02059813          	slli	a6,a1,0x20
 988:	01c85713          	srli	a4,a6,0x1c
 98c:	9736                	add	a4,a4,a3
 98e:	fae60de3          	beq	a2,a4,948 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 992:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 996:	4790                	lw	a2,8(a5)
 998:	02061593          	slli	a1,a2,0x20
 99c:	01c5d713          	srli	a4,a1,0x1c
 9a0:	973e                	add	a4,a4,a5
 9a2:	fae68ae3          	beq	a3,a4,956 <free+0x22>
    p->s.ptr = bp->s.ptr;
 9a6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9a8:	00000717          	auipc	a4,0x0
 9ac:	2cf73823          	sd	a5,720(a4) # c78 <freep>
}
 9b0:	6422                	ld	s0,8(sp)
 9b2:	0141                	addi	sp,sp,16
 9b4:	8082                	ret

00000000000009b6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9b6:	7139                	addi	sp,sp,-64
 9b8:	fc06                	sd	ra,56(sp)
 9ba:	f822                	sd	s0,48(sp)
 9bc:	f426                	sd	s1,40(sp)
 9be:	f04a                	sd	s2,32(sp)
 9c0:	ec4e                	sd	s3,24(sp)
 9c2:	e852                	sd	s4,16(sp)
 9c4:	e456                	sd	s5,8(sp)
 9c6:	e05a                	sd	s6,0(sp)
 9c8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ca:	02051493          	slli	s1,a0,0x20
 9ce:	9081                	srli	s1,s1,0x20
 9d0:	04bd                	addi	s1,s1,15
 9d2:	8091                	srli	s1,s1,0x4
 9d4:	0014899b          	addiw	s3,s1,1
 9d8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9da:	00000517          	auipc	a0,0x0
 9de:	29e53503          	ld	a0,670(a0) # c78 <freep>
 9e2:	c515                	beqz	a0,a0e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e6:	4798                	lw	a4,8(a5)
 9e8:	02977f63          	bgeu	a4,s1,a26 <malloc+0x70>
 9ec:	8a4e                	mv	s4,s3
 9ee:	0009871b          	sext.w	a4,s3
 9f2:	6685                	lui	a3,0x1
 9f4:	00d77363          	bgeu	a4,a3,9fa <malloc+0x44>
 9f8:	6a05                	lui	s4,0x1
 9fa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9fe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a02:	00000917          	auipc	s2,0x0
 a06:	27690913          	addi	s2,s2,630 # c78 <freep>
  if(p == (char*)-1)
 a0a:	5afd                	li	s5,-1
 a0c:	a895                	j	a80 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a0e:	00000797          	auipc	a5,0x0
 a12:	27278793          	addi	a5,a5,626 # c80 <base>
 a16:	00000717          	auipc	a4,0x0
 a1a:	26f73123          	sd	a5,610(a4) # c78 <freep>
 a1e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a20:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a24:	b7e1                	j	9ec <malloc+0x36>
      if(p->s.size == nunits)
 a26:	02e48c63          	beq	s1,a4,a5e <malloc+0xa8>
        p->s.size -= nunits;
 a2a:	4137073b          	subw	a4,a4,s3
 a2e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a30:	02071693          	slli	a3,a4,0x20
 a34:	01c6d713          	srli	a4,a3,0x1c
 a38:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a3a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a3e:	00000717          	auipc	a4,0x0
 a42:	22a73d23          	sd	a0,570(a4) # c78 <freep>
      return (void*)(p + 1);
 a46:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a4a:	70e2                	ld	ra,56(sp)
 a4c:	7442                	ld	s0,48(sp)
 a4e:	74a2                	ld	s1,40(sp)
 a50:	7902                	ld	s2,32(sp)
 a52:	69e2                	ld	s3,24(sp)
 a54:	6a42                	ld	s4,16(sp)
 a56:	6aa2                	ld	s5,8(sp)
 a58:	6b02                	ld	s6,0(sp)
 a5a:	6121                	addi	sp,sp,64
 a5c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a5e:	6398                	ld	a4,0(a5)
 a60:	e118                	sd	a4,0(a0)
 a62:	bff1                	j	a3e <malloc+0x88>
  hp->s.size = nu;
 a64:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a68:	0541                	addi	a0,a0,16
 a6a:	00000097          	auipc	ra,0x0
 a6e:	eca080e7          	jalr	-310(ra) # 934 <free>
  return freep;
 a72:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a76:	d971                	beqz	a0,a4a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a78:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a7a:	4798                	lw	a4,8(a5)
 a7c:	fa9775e3          	bgeu	a4,s1,a26 <malloc+0x70>
    if(p == freep)
 a80:	00093703          	ld	a4,0(s2)
 a84:	853e                	mv	a0,a5
 a86:	fef719e3          	bne	a4,a5,a78 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a8a:	8552                	mv	a0,s4
 a8c:	00000097          	auipc	ra,0x0
 a90:	ae0080e7          	jalr	-1312(ra) # 56c <sbrk>
  if(p == (char*)-1)
 a94:	fd5518e3          	bne	a0,s5,a64 <malloc+0xae>
        return 0;
 a98:	4501                	li	a0,0
 a9a:	bf45                	j	a4a <malloc+0x94>
