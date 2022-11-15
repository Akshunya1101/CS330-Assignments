
user/_testpinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/procstat.h"
#include "user/user.h"

int
main(void)
{
   0:	7159                	addi	sp,sp,-112
   2:	f486                	sd	ra,104(sp)
   4:	f0a2                	sd	s0,96(sp)
   6:	eca6                	sd	s1,88(sp)
   8:	1880                	addi	s0,sp,112
  struct procstat pstat;

  int x = fork();
   a:	00000097          	auipc	ra,0x0
   e:	414080e7          	jalr	1044(ra) # 41e <fork>
  if (x < 0) {
  12:	0e054563          	bltz	a0,fc <main+0xfc>
  16:	84aa                	mv	s1,a0
     fprintf(2, "Error: cannot fork\nAborting...\n");
     exit(0);
  }
  else if (x > 0) {
  18:	12a05463          	blez	a0,140 <main+0x140>
     sleep(1);
  1c:	4505                	li	a0,1
  1e:	00000097          	auipc	ra,0x0
  22:	498080e7          	jalr	1176(ra) # 4b6 <sleep>
     fprintf(1, "%d: Parent.\n", getpid());
  26:	00000097          	auipc	ra,0x0
  2a:	480080e7          	jalr	1152(ra) # 4a6 <getpid>
  2e:	862a                	mv	a2,a0
  30:	00001597          	auipc	a1,0x1
  34:	9d058593          	addi	a1,a1,-1584 # a00 <malloc+0x108>
  38:	4505                	li	a0,1
  3a:	00000097          	auipc	ra,0x0
  3e:	7d8080e7          	jalr	2008(ra) # 812 <fprintf>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
  42:	fa840593          	addi	a1,s0,-88
  46:	557d                	li	a0,-1
  48:	00000097          	auipc	ra,0x0
  4c:	4ae080e7          	jalr	1198(ra) # 4f6 <pinfo>
  50:	0c054463          	bltz	a0,118 <main+0x118>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  54:	fd843783          	ld	a5,-40(s0)
  58:	e43e                	sd	a5,8(sp)
  5a:	fd042783          	lw	a5,-48(s0)
  5e:	e03e                	sd	a5,0(sp)
  60:	fcc42883          	lw	a7,-52(s0)
  64:	fc842803          	lw	a6,-56(s0)
  68:	fb840793          	addi	a5,s0,-72
  6c:	fb040713          	addi	a4,s0,-80
  70:	fac42683          	lw	a3,-84(s0)
  74:	fa842603          	lw	a2,-88(s0)
  78:	00001597          	auipc	a1,0x1
  7c:	9b058593          	addi	a1,a1,-1616 # a28 <malloc+0x130>
  80:	4505                	li	a0,1
  82:	00000097          	auipc	ra,0x0
  86:	790080e7          	jalr	1936(ra) # 812 <fprintf>
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
  8a:	fa840593          	addi	a1,s0,-88
  8e:	8526                	mv	a0,s1
  90:	00000097          	auipc	ra,0x0
  94:	466080e7          	jalr	1126(ra) # 4f6 <pinfo>
  98:	08054a63          	bltz	a0,12c <main+0x12c>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  9c:	fd843783          	ld	a5,-40(s0)
  a0:	e43e                	sd	a5,8(sp)
  a2:	fd042783          	lw	a5,-48(s0)
  a6:	e03e                	sd	a5,0(sp)
  a8:	fcc42883          	lw	a7,-52(s0)
  ac:	fc842803          	lw	a6,-56(s0)
  b0:	fb840793          	addi	a5,s0,-72
  b4:	fb040713          	addi	a4,s0,-80
  b8:	fac42683          	lw	a3,-84(s0)
  bc:	fa842603          	lw	a2,-88(s0)
  c0:	00001597          	auipc	a1,0x1
  c4:	9b858593          	addi	a1,a1,-1608 # a78 <malloc+0x180>
  c8:	4505                	li	a0,1
  ca:	00000097          	auipc	ra,0x0
  ce:	748080e7          	jalr	1864(ra) # 812 <fprintf>
     fprintf(1, "Return value of waitpid=%d\n", waitpid(x, 0));
  d2:	4581                	li	a1,0
  d4:	8526                	mv	a0,s1
  d6:	00000097          	auipc	ra,0x0
  da:	410080e7          	jalr	1040(ra) # 4e6 <waitpid>
  de:	862a                	mv	a2,a0
  e0:	00001597          	auipc	a1,0x1
  e4:	9e858593          	addi	a1,a1,-1560 # ac8 <malloc+0x1d0>
  e8:	4505                	li	a0,1
  ea:	00000097          	auipc	ra,0x0
  ee:	728080e7          	jalr	1832(ra) # 812 <fprintf>
     fprintf(1, "%d: Child.\n", getpid());
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
  }

  exit(0);
  f2:	4501                	li	a0,0
  f4:	00000097          	auipc	ra,0x0
  f8:	332080e7          	jalr	818(ra) # 426 <exit>
     fprintf(2, "Error: cannot fork\nAborting...\n");
  fc:	00001597          	auipc	a1,0x1
 100:	8e458593          	addi	a1,a1,-1820 # 9e0 <malloc+0xe8>
 104:	4509                	li	a0,2
 106:	00000097          	auipc	ra,0x0
 10a:	70c080e7          	jalr	1804(ra) # 812 <fprintf>
     exit(0);
 10e:	4501                	li	a0,0
 110:	00000097          	auipc	ra,0x0
 114:	316080e7          	jalr	790(ra) # 426 <exit>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 118:	00001597          	auipc	a1,0x1
 11c:	8f858593          	addi	a1,a1,-1800 # a10 <malloc+0x118>
 120:	4505                	li	a0,1
 122:	00000097          	auipc	ra,0x0
 126:	6f0080e7          	jalr	1776(ra) # 812 <fprintf>
 12a:	b785                	j	8a <main+0x8a>
     if (pinfo(x, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 12c:	00001597          	auipc	a1,0x1
 130:	8e458593          	addi	a1,a1,-1820 # a10 <malloc+0x118>
 134:	4505                	li	a0,1
 136:	00000097          	auipc	ra,0x0
 13a:	6dc080e7          	jalr	1756(ra) # 812 <fprintf>
 13e:	bf51                	j	d2 <main+0xd2>
     fprintf(1, "%d: Child.\n", getpid());
 140:	00000097          	auipc	ra,0x0
 144:	366080e7          	jalr	870(ra) # 4a6 <getpid>
 148:	862a                	mv	a2,a0
 14a:	00001597          	auipc	a1,0x1
 14e:	99e58593          	addi	a1,a1,-1634 # ae8 <malloc+0x1f0>
 152:	4505                	li	a0,1
 154:	00000097          	auipc	ra,0x0
 158:	6be080e7          	jalr	1726(ra) # 812 <fprintf>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 15c:	fa840593          	addi	a1,s0,-88
 160:	557d                	li	a0,-1
 162:	00000097          	auipc	ra,0x0
 166:	394080e7          	jalr	916(ra) # 4f6 <pinfo>
 16a:	02054e63          	bltz	a0,1a6 <main+0x1a6>
     else fprintf(1, "pid=%d, ppid=%d, state=%s, cmd=%s, ctime=%d, stime=%d, etime=%d, size=%p\n\n", pstat.pid, pstat.ppid, pstat.state, pstat.command, pstat.ctime, pstat.stime, pstat.etime, pstat.size);
 16e:	fd843783          	ld	a5,-40(s0)
 172:	e43e                	sd	a5,8(sp)
 174:	fd042783          	lw	a5,-48(s0)
 178:	e03e                	sd	a5,0(sp)
 17a:	fcc42883          	lw	a7,-52(s0)
 17e:	fc842803          	lw	a6,-56(s0)
 182:	fb840793          	addi	a5,s0,-72
 186:	fb040713          	addi	a4,s0,-80
 18a:	fac42683          	lw	a3,-84(s0)
 18e:	fa842603          	lw	a2,-88(s0)
 192:	00001597          	auipc	a1,0x1
 196:	8e658593          	addi	a1,a1,-1818 # a78 <malloc+0x180>
 19a:	4505                	li	a0,1
 19c:	00000097          	auipc	ra,0x0
 1a0:	676080e7          	jalr	1654(ra) # 812 <fprintf>
 1a4:	b7b9                	j	f2 <main+0xf2>
     if (pinfo(-1, &pstat) < 0) fprintf(1, "Cannot get pinfo\n");
 1a6:	00001597          	auipc	a1,0x1
 1aa:	86a58593          	addi	a1,a1,-1942 # a10 <malloc+0x118>
 1ae:	4505                	li	a0,1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	662080e7          	jalr	1634(ra) # 812 <fprintf>
 1b8:	bf2d                	j	f2 <main+0xf2>

00000000000001ba <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1ba:	1141                	addi	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1c0:	87aa                	mv	a5,a0
 1c2:	0585                	addi	a1,a1,1
 1c4:	0785                	addi	a5,a5,1
 1c6:	fff5c703          	lbu	a4,-1(a1)
 1ca:	fee78fa3          	sb	a4,-1(a5)
 1ce:	fb75                	bnez	a4,1c2 <strcpy+0x8>
    ;
  return os;
}
 1d0:	6422                	ld	s0,8(sp)
 1d2:	0141                	addi	sp,sp,16
 1d4:	8082                	ret

00000000000001d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1d6:	1141                	addi	sp,sp,-16
 1d8:	e422                	sd	s0,8(sp)
 1da:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	cb91                	beqz	a5,1f4 <strcmp+0x1e>
 1e2:	0005c703          	lbu	a4,0(a1)
 1e6:	00f71763          	bne	a4,a5,1f4 <strcmp+0x1e>
    p++, q++;
 1ea:	0505                	addi	a0,a0,1
 1ec:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ee:	00054783          	lbu	a5,0(a0)
 1f2:	fbe5                	bnez	a5,1e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1f4:	0005c503          	lbu	a0,0(a1)
}
 1f8:	40a7853b          	subw	a0,a5,a0
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strlen>:

uint
strlen(const char *s)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 208:	00054783          	lbu	a5,0(a0)
 20c:	cf91                	beqz	a5,228 <strlen+0x26>
 20e:	0505                	addi	a0,a0,1
 210:	87aa                	mv	a5,a0
 212:	4685                	li	a3,1
 214:	9e89                	subw	a3,a3,a0
 216:	00f6853b          	addw	a0,a3,a5
 21a:	0785                	addi	a5,a5,1
 21c:	fff7c703          	lbu	a4,-1(a5)
 220:	fb7d                	bnez	a4,216 <strlen+0x14>
    ;
  return n;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret
  for(n = 0; s[n]; n++)
 228:	4501                	li	a0,0
 22a:	bfe5                	j	222 <strlen+0x20>

000000000000022c <memset>:

void*
memset(void *dst, int c, uint n)
{
 22c:	1141                	addi	sp,sp,-16
 22e:	e422                	sd	s0,8(sp)
 230:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 232:	ca19                	beqz	a2,248 <memset+0x1c>
 234:	87aa                	mv	a5,a0
 236:	1602                	slli	a2,a2,0x20
 238:	9201                	srli	a2,a2,0x20
 23a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 23e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 242:	0785                	addi	a5,a5,1
 244:	fee79de3          	bne	a5,a4,23e <memset+0x12>
  }
  return dst;
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	addi	sp,sp,16
 24c:	8082                	ret

000000000000024e <strchr>:

char*
strchr(const char *s, char c)
{
 24e:	1141                	addi	sp,sp,-16
 250:	e422                	sd	s0,8(sp)
 252:	0800                	addi	s0,sp,16
  for(; *s; s++)
 254:	00054783          	lbu	a5,0(a0)
 258:	cb99                	beqz	a5,26e <strchr+0x20>
    if(*s == c)
 25a:	00f58763          	beq	a1,a5,268 <strchr+0x1a>
  for(; *s; s++)
 25e:	0505                	addi	a0,a0,1
 260:	00054783          	lbu	a5,0(a0)
 264:	fbfd                	bnez	a5,25a <strchr+0xc>
      return (char*)s;
  return 0;
 266:	4501                	li	a0,0
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
  return 0;
 26e:	4501                	li	a0,0
 270:	bfe5                	j	268 <strchr+0x1a>

0000000000000272 <gets>:

char*
gets(char *buf, int max)
{
 272:	711d                	addi	sp,sp,-96
 274:	ec86                	sd	ra,88(sp)
 276:	e8a2                	sd	s0,80(sp)
 278:	e4a6                	sd	s1,72(sp)
 27a:	e0ca                	sd	s2,64(sp)
 27c:	fc4e                	sd	s3,56(sp)
 27e:	f852                	sd	s4,48(sp)
 280:	f456                	sd	s5,40(sp)
 282:	f05a                	sd	s6,32(sp)
 284:	ec5e                	sd	s7,24(sp)
 286:	1080                	addi	s0,sp,96
 288:	8baa                	mv	s7,a0
 28a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 28c:	892a                	mv	s2,a0
 28e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 290:	4aa9                	li	s5,10
 292:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 294:	89a6                	mv	s3,s1
 296:	2485                	addiw	s1,s1,1
 298:	0344d863          	bge	s1,s4,2c8 <gets+0x56>
    cc = read(0, &c, 1);
 29c:	4605                	li	a2,1
 29e:	faf40593          	addi	a1,s0,-81
 2a2:	4501                	li	a0,0
 2a4:	00000097          	auipc	ra,0x0
 2a8:	19a080e7          	jalr	410(ra) # 43e <read>
    if(cc < 1)
 2ac:	00a05e63          	blez	a0,2c8 <gets+0x56>
    buf[i++] = c;
 2b0:	faf44783          	lbu	a5,-81(s0)
 2b4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2b8:	01578763          	beq	a5,s5,2c6 <gets+0x54>
 2bc:	0905                	addi	s2,s2,1
 2be:	fd679be3          	bne	a5,s6,294 <gets+0x22>
  for(i=0; i+1 < max; ){
 2c2:	89a6                	mv	s3,s1
 2c4:	a011                	j	2c8 <gets+0x56>
 2c6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2c8:	99de                	add	s3,s3,s7
 2ca:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ce:	855e                	mv	a0,s7
 2d0:	60e6                	ld	ra,88(sp)
 2d2:	6446                	ld	s0,80(sp)
 2d4:	64a6                	ld	s1,72(sp)
 2d6:	6906                	ld	s2,64(sp)
 2d8:	79e2                	ld	s3,56(sp)
 2da:	7a42                	ld	s4,48(sp)
 2dc:	7aa2                	ld	s5,40(sp)
 2de:	7b02                	ld	s6,32(sp)
 2e0:	6be2                	ld	s7,24(sp)
 2e2:	6125                	addi	sp,sp,96
 2e4:	8082                	ret

00000000000002e6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2e6:	1101                	addi	sp,sp,-32
 2e8:	ec06                	sd	ra,24(sp)
 2ea:	e822                	sd	s0,16(sp)
 2ec:	e426                	sd	s1,8(sp)
 2ee:	e04a                	sd	s2,0(sp)
 2f0:	1000                	addi	s0,sp,32
 2f2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2f4:	4581                	li	a1,0
 2f6:	00000097          	auipc	ra,0x0
 2fa:	170080e7          	jalr	368(ra) # 466 <open>
  if(fd < 0)
 2fe:	02054563          	bltz	a0,328 <stat+0x42>
 302:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 304:	85ca                	mv	a1,s2
 306:	00000097          	auipc	ra,0x0
 30a:	178080e7          	jalr	376(ra) # 47e <fstat>
 30e:	892a                	mv	s2,a0
  close(fd);
 310:	8526                	mv	a0,s1
 312:	00000097          	auipc	ra,0x0
 316:	13c080e7          	jalr	316(ra) # 44e <close>
  return r;
}
 31a:	854a                	mv	a0,s2
 31c:	60e2                	ld	ra,24(sp)
 31e:	6442                	ld	s0,16(sp)
 320:	64a2                	ld	s1,8(sp)
 322:	6902                	ld	s2,0(sp)
 324:	6105                	addi	sp,sp,32
 326:	8082                	ret
    return -1;
 328:	597d                	li	s2,-1
 32a:	bfc5                	j	31a <stat+0x34>

000000000000032c <atoi>:

int
atoi(const char *s)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e422                	sd	s0,8(sp)
 330:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 332:	00054683          	lbu	a3,0(a0)
 336:	fd06879b          	addiw	a5,a3,-48
 33a:	0ff7f793          	zext.b	a5,a5
 33e:	4625                	li	a2,9
 340:	02f66863          	bltu	a2,a5,370 <atoi+0x44>
 344:	872a                	mv	a4,a0
  n = 0;
 346:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 348:	0705                	addi	a4,a4,1
 34a:	0025179b          	slliw	a5,a0,0x2
 34e:	9fa9                	addw	a5,a5,a0
 350:	0017979b          	slliw	a5,a5,0x1
 354:	9fb5                	addw	a5,a5,a3
 356:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 35a:	00074683          	lbu	a3,0(a4)
 35e:	fd06879b          	addiw	a5,a3,-48
 362:	0ff7f793          	zext.b	a5,a5
 366:	fef671e3          	bgeu	a2,a5,348 <atoi+0x1c>
  return n;
}
 36a:	6422                	ld	s0,8(sp)
 36c:	0141                	addi	sp,sp,16
 36e:	8082                	ret
  n = 0;
 370:	4501                	li	a0,0
 372:	bfe5                	j	36a <atoi+0x3e>

0000000000000374 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 374:	1141                	addi	sp,sp,-16
 376:	e422                	sd	s0,8(sp)
 378:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 37a:	02b57463          	bgeu	a0,a1,3a2 <memmove+0x2e>
    while(n-- > 0)
 37e:	00c05f63          	blez	a2,39c <memmove+0x28>
 382:	1602                	slli	a2,a2,0x20
 384:	9201                	srli	a2,a2,0x20
 386:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 38a:	872a                	mv	a4,a0
      *dst++ = *src++;
 38c:	0585                	addi	a1,a1,1
 38e:	0705                	addi	a4,a4,1
 390:	fff5c683          	lbu	a3,-1(a1)
 394:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 398:	fee79ae3          	bne	a5,a4,38c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 39c:	6422                	ld	s0,8(sp)
 39e:	0141                	addi	sp,sp,16
 3a0:	8082                	ret
    dst += n;
 3a2:	00c50733          	add	a4,a0,a2
    src += n;
 3a6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3a8:	fec05ae3          	blez	a2,39c <memmove+0x28>
 3ac:	fff6079b          	addiw	a5,a2,-1
 3b0:	1782                	slli	a5,a5,0x20
 3b2:	9381                	srli	a5,a5,0x20
 3b4:	fff7c793          	not	a5,a5
 3b8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3ba:	15fd                	addi	a1,a1,-1
 3bc:	177d                	addi	a4,a4,-1
 3be:	0005c683          	lbu	a3,0(a1)
 3c2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3c6:	fee79ae3          	bne	a5,a4,3ba <memmove+0x46>
 3ca:	bfc9                	j	39c <memmove+0x28>

00000000000003cc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e422                	sd	s0,8(sp)
 3d0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3d2:	ca05                	beqz	a2,402 <memcmp+0x36>
 3d4:	fff6069b          	addiw	a3,a2,-1
 3d8:	1682                	slli	a3,a3,0x20
 3da:	9281                	srli	a3,a3,0x20
 3dc:	0685                	addi	a3,a3,1
 3de:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3e0:	00054783          	lbu	a5,0(a0)
 3e4:	0005c703          	lbu	a4,0(a1)
 3e8:	00e79863          	bne	a5,a4,3f8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3ec:	0505                	addi	a0,a0,1
    p2++;
 3ee:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3f0:	fed518e3          	bne	a0,a3,3e0 <memcmp+0x14>
  }
  return 0;
 3f4:	4501                	li	a0,0
 3f6:	a019                	j	3fc <memcmp+0x30>
      return *p1 - *p2;
 3f8:	40e7853b          	subw	a0,a5,a4
}
 3fc:	6422                	ld	s0,8(sp)
 3fe:	0141                	addi	sp,sp,16
 400:	8082                	ret
  return 0;
 402:	4501                	li	a0,0
 404:	bfe5                	j	3fc <memcmp+0x30>

0000000000000406 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 406:	1141                	addi	sp,sp,-16
 408:	e406                	sd	ra,8(sp)
 40a:	e022                	sd	s0,0(sp)
 40c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 40e:	00000097          	auipc	ra,0x0
 412:	f66080e7          	jalr	-154(ra) # 374 <memmove>
}
 416:	60a2                	ld	ra,8(sp)
 418:	6402                	ld	s0,0(sp)
 41a:	0141                	addi	sp,sp,16
 41c:	8082                	ret

000000000000041e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 41e:	4885                	li	a7,1
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <exit>:
.global exit
exit:
 li a7, SYS_exit
 426:	4889                	li	a7,2
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <wait>:
.global wait
wait:
 li a7, SYS_wait
 42e:	488d                	li	a7,3
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 436:	4891                	li	a7,4
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <read>:
.global read
read:
 li a7, SYS_read
 43e:	4895                	li	a7,5
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <write>:
.global write
write:
 li a7, SYS_write
 446:	48c1                	li	a7,16
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <close>:
.global close
close:
 li a7, SYS_close
 44e:	48d5                	li	a7,21
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <kill>:
.global kill
kill:
 li a7, SYS_kill
 456:	4899                	li	a7,6
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <exec>:
.global exec
exec:
 li a7, SYS_exec
 45e:	489d                	li	a7,7
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <open>:
.global open
open:
 li a7, SYS_open
 466:	48bd                	li	a7,15
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 46e:	48c5                	li	a7,17
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 476:	48c9                	li	a7,18
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 47e:	48a1                	li	a7,8
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <link>:
.global link
link:
 li a7, SYS_link
 486:	48cd                	li	a7,19
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 48e:	48d1                	li	a7,20
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 496:	48a5                	li	a7,9
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <dup>:
.global dup
dup:
 li a7, SYS_dup
 49e:	48a9                	li	a7,10
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4a6:	48ad                	li	a7,11
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ae:	48b1                	li	a7,12
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4b6:	48b5                	li	a7,13
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4be:	48b9                	li	a7,14
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4c6:	48d9                	li	a7,22
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <yield>:
.global yield
yield:
 li a7, SYS_yield
 4ce:	48dd                	li	a7,23
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 4d6:	48e1                	li	a7,24
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 4de:	48e5                	li	a7,25
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 4e6:	48e9                	li	a7,26
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <ps>:
.global ps
ps:
 li a7, SYS_ps
 4ee:	48ed                	li	a7,27
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 4f6:	48f1                	li	a7,28
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 4fe:	48f5                	li	a7,29
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 506:	48f9                	li	a7,30
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 50e:	02100893          	li	a7,33
 ecall
 512:	00000073          	ecall
 ret
 516:	8082                	ret

0000000000000518 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 518:	48fd                	li	a7,31
 ecall
 51a:	00000073          	ecall
 ret
 51e:	8082                	ret

0000000000000520 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 520:	02000893          	li	a7,32
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 52a:	02200893          	li	a7,34
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 534:	02300893          	li	a7,35
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 53e:	02400893          	li	a7,36
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 548:	02500893          	li	a7,37
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 552:	02700893          	li	a7,39
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 55c:	02600893          	li	a7,38
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 566:	1101                	addi	sp,sp,-32
 568:	ec06                	sd	ra,24(sp)
 56a:	e822                	sd	s0,16(sp)
 56c:	1000                	addi	s0,sp,32
 56e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 572:	4605                	li	a2,1
 574:	fef40593          	addi	a1,s0,-17
 578:	00000097          	auipc	ra,0x0
 57c:	ece080e7          	jalr	-306(ra) # 446 <write>
}
 580:	60e2                	ld	ra,24(sp)
 582:	6442                	ld	s0,16(sp)
 584:	6105                	addi	sp,sp,32
 586:	8082                	ret

0000000000000588 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 588:	7139                	addi	sp,sp,-64
 58a:	fc06                	sd	ra,56(sp)
 58c:	f822                	sd	s0,48(sp)
 58e:	f426                	sd	s1,40(sp)
 590:	f04a                	sd	s2,32(sp)
 592:	ec4e                	sd	s3,24(sp)
 594:	0080                	addi	s0,sp,64
 596:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 598:	c299                	beqz	a3,59e <printint+0x16>
 59a:	0805c963          	bltz	a1,62c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 59e:	2581                	sext.w	a1,a1
  neg = 0;
 5a0:	4881                	li	a7,0
 5a2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5a6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5a8:	2601                	sext.w	a2,a2
 5aa:	00000517          	auipc	a0,0x0
 5ae:	5ae50513          	addi	a0,a0,1454 # b58 <digits>
 5b2:	883a                	mv	a6,a4
 5b4:	2705                	addiw	a4,a4,1
 5b6:	02c5f7bb          	remuw	a5,a1,a2
 5ba:	1782                	slli	a5,a5,0x20
 5bc:	9381                	srli	a5,a5,0x20
 5be:	97aa                	add	a5,a5,a0
 5c0:	0007c783          	lbu	a5,0(a5)
 5c4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5c8:	0005879b          	sext.w	a5,a1
 5cc:	02c5d5bb          	divuw	a1,a1,a2
 5d0:	0685                	addi	a3,a3,1
 5d2:	fec7f0e3          	bgeu	a5,a2,5b2 <printint+0x2a>
  if(neg)
 5d6:	00088c63          	beqz	a7,5ee <printint+0x66>
    buf[i++] = '-';
 5da:	fd070793          	addi	a5,a4,-48
 5de:	00878733          	add	a4,a5,s0
 5e2:	02d00793          	li	a5,45
 5e6:	fef70823          	sb	a5,-16(a4)
 5ea:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ee:	02e05863          	blez	a4,61e <printint+0x96>
 5f2:	fc040793          	addi	a5,s0,-64
 5f6:	00e78933          	add	s2,a5,a4
 5fa:	fff78993          	addi	s3,a5,-1
 5fe:	99ba                	add	s3,s3,a4
 600:	377d                	addiw	a4,a4,-1
 602:	1702                	slli	a4,a4,0x20
 604:	9301                	srli	a4,a4,0x20
 606:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 60a:	fff94583          	lbu	a1,-1(s2)
 60e:	8526                	mv	a0,s1
 610:	00000097          	auipc	ra,0x0
 614:	f56080e7          	jalr	-170(ra) # 566 <putc>
  while(--i >= 0)
 618:	197d                	addi	s2,s2,-1
 61a:	ff3918e3          	bne	s2,s3,60a <printint+0x82>
}
 61e:	70e2                	ld	ra,56(sp)
 620:	7442                	ld	s0,48(sp)
 622:	74a2                	ld	s1,40(sp)
 624:	7902                	ld	s2,32(sp)
 626:	69e2                	ld	s3,24(sp)
 628:	6121                	addi	sp,sp,64
 62a:	8082                	ret
    x = -xx;
 62c:	40b005bb          	negw	a1,a1
    neg = 1;
 630:	4885                	li	a7,1
    x = -xx;
 632:	bf85                	j	5a2 <printint+0x1a>

0000000000000634 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 634:	7119                	addi	sp,sp,-128
 636:	fc86                	sd	ra,120(sp)
 638:	f8a2                	sd	s0,112(sp)
 63a:	f4a6                	sd	s1,104(sp)
 63c:	f0ca                	sd	s2,96(sp)
 63e:	ecce                	sd	s3,88(sp)
 640:	e8d2                	sd	s4,80(sp)
 642:	e4d6                	sd	s5,72(sp)
 644:	e0da                	sd	s6,64(sp)
 646:	fc5e                	sd	s7,56(sp)
 648:	f862                	sd	s8,48(sp)
 64a:	f466                	sd	s9,40(sp)
 64c:	f06a                	sd	s10,32(sp)
 64e:	ec6e                	sd	s11,24(sp)
 650:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 652:	0005c903          	lbu	s2,0(a1)
 656:	18090f63          	beqz	s2,7f4 <vprintf+0x1c0>
 65a:	8aaa                	mv	s5,a0
 65c:	8b32                	mv	s6,a2
 65e:	00158493          	addi	s1,a1,1
  state = 0;
 662:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 664:	02500a13          	li	s4,37
 668:	4c55                	li	s8,21
 66a:	00000c97          	auipc	s9,0x0
 66e:	496c8c93          	addi	s9,s9,1174 # b00 <malloc+0x208>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 672:	02800d93          	li	s11,40
  putc(fd, 'x');
 676:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 678:	00000b97          	auipc	s7,0x0
 67c:	4e0b8b93          	addi	s7,s7,1248 # b58 <digits>
 680:	a839                	j	69e <vprintf+0x6a>
        putc(fd, c);
 682:	85ca                	mv	a1,s2
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	ee0080e7          	jalr	-288(ra) # 566 <putc>
 68e:	a019                	j	694 <vprintf+0x60>
    } else if(state == '%'){
 690:	01498d63          	beq	s3,s4,6aa <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 694:	0485                	addi	s1,s1,1
 696:	fff4c903          	lbu	s2,-1(s1)
 69a:	14090d63          	beqz	s2,7f4 <vprintf+0x1c0>
    if(state == 0){
 69e:	fe0999e3          	bnez	s3,690 <vprintf+0x5c>
      if(c == '%'){
 6a2:	ff4910e3          	bne	s2,s4,682 <vprintf+0x4e>
        state = '%';
 6a6:	89d2                	mv	s3,s4
 6a8:	b7f5                	j	694 <vprintf+0x60>
      if(c == 'd'){
 6aa:	11490c63          	beq	s2,s4,7c2 <vprintf+0x18e>
 6ae:	f9d9079b          	addiw	a5,s2,-99
 6b2:	0ff7f793          	zext.b	a5,a5
 6b6:	10fc6e63          	bltu	s8,a5,7d2 <vprintf+0x19e>
 6ba:	f9d9079b          	addiw	a5,s2,-99
 6be:	0ff7f713          	zext.b	a4,a5
 6c2:	10ec6863          	bltu	s8,a4,7d2 <vprintf+0x19e>
 6c6:	00271793          	slli	a5,a4,0x2
 6ca:	97e6                	add	a5,a5,s9
 6cc:	439c                	lw	a5,0(a5)
 6ce:	97e6                	add	a5,a5,s9
 6d0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6d2:	008b0913          	addi	s2,s6,8
 6d6:	4685                	li	a3,1
 6d8:	4629                	li	a2,10
 6da:	000b2583          	lw	a1,0(s6)
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	ea8080e7          	jalr	-344(ra) # 588 <printint>
 6e8:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b765                	j	694 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ee:	008b0913          	addi	s2,s6,8
 6f2:	4681                	li	a3,0
 6f4:	4629                	li	a2,10
 6f6:	000b2583          	lw	a1,0(s6)
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	e8c080e7          	jalr	-372(ra) # 588 <printint>
 704:	8b4a                	mv	s6,s2
      state = 0;
 706:	4981                	li	s3,0
 708:	b771                	j	694 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 70a:	008b0913          	addi	s2,s6,8
 70e:	4681                	li	a3,0
 710:	866a                	mv	a2,s10
 712:	000b2583          	lw	a1,0(s6)
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	e70080e7          	jalr	-400(ra) # 588 <printint>
 720:	8b4a                	mv	s6,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	bf85                	j	694 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 726:	008b0793          	addi	a5,s6,8
 72a:	f8f43423          	sd	a5,-120(s0)
 72e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 732:	03000593          	li	a1,48
 736:	8556                	mv	a0,s5
 738:	00000097          	auipc	ra,0x0
 73c:	e2e080e7          	jalr	-466(ra) # 566 <putc>
  putc(fd, 'x');
 740:	07800593          	li	a1,120
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	e20080e7          	jalr	-480(ra) # 566 <putc>
 74e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 750:	03c9d793          	srli	a5,s3,0x3c
 754:	97de                	add	a5,a5,s7
 756:	0007c583          	lbu	a1,0(a5)
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	e0a080e7          	jalr	-502(ra) # 566 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 764:	0992                	slli	s3,s3,0x4
 766:	397d                	addiw	s2,s2,-1
 768:	fe0914e3          	bnez	s2,750 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 76c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 770:	4981                	li	s3,0
 772:	b70d                	j	694 <vprintf+0x60>
        s = va_arg(ap, char*);
 774:	008b0913          	addi	s2,s6,8
 778:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 77c:	02098163          	beqz	s3,79e <vprintf+0x16a>
        while(*s != 0){
 780:	0009c583          	lbu	a1,0(s3)
 784:	c5ad                	beqz	a1,7ee <vprintf+0x1ba>
          putc(fd, *s);
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	dde080e7          	jalr	-546(ra) # 566 <putc>
          s++;
 790:	0985                	addi	s3,s3,1
        while(*s != 0){
 792:	0009c583          	lbu	a1,0(s3)
 796:	f9e5                	bnez	a1,786 <vprintf+0x152>
        s = va_arg(ap, char*);
 798:	8b4a                	mv	s6,s2
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bde5                	j	694 <vprintf+0x60>
          s = "(null)";
 79e:	00000997          	auipc	s3,0x0
 7a2:	35a98993          	addi	s3,s3,858 # af8 <malloc+0x200>
        while(*s != 0){
 7a6:	85ee                	mv	a1,s11
 7a8:	bff9                	j	786 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7aa:	008b0913          	addi	s2,s6,8
 7ae:	000b4583          	lbu	a1,0(s6)
 7b2:	8556                	mv	a0,s5
 7b4:	00000097          	auipc	ra,0x0
 7b8:	db2080e7          	jalr	-590(ra) # 566 <putc>
 7bc:	8b4a                	mv	s6,s2
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	bdd1                	j	694 <vprintf+0x60>
        putc(fd, c);
 7c2:	85d2                	mv	a1,s4
 7c4:	8556                	mv	a0,s5
 7c6:	00000097          	auipc	ra,0x0
 7ca:	da0080e7          	jalr	-608(ra) # 566 <putc>
      state = 0;
 7ce:	4981                	li	s3,0
 7d0:	b5d1                	j	694 <vprintf+0x60>
        putc(fd, '%');
 7d2:	85d2                	mv	a1,s4
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	d90080e7          	jalr	-624(ra) # 566 <putc>
        putc(fd, c);
 7de:	85ca                	mv	a1,s2
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	d84080e7          	jalr	-636(ra) # 566 <putc>
      state = 0;
 7ea:	4981                	li	s3,0
 7ec:	b565                	j	694 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ee:	8b4a                	mv	s6,s2
      state = 0;
 7f0:	4981                	li	s3,0
 7f2:	b54d                	j	694 <vprintf+0x60>
    }
  }
}
 7f4:	70e6                	ld	ra,120(sp)
 7f6:	7446                	ld	s0,112(sp)
 7f8:	74a6                	ld	s1,104(sp)
 7fa:	7906                	ld	s2,96(sp)
 7fc:	69e6                	ld	s3,88(sp)
 7fe:	6a46                	ld	s4,80(sp)
 800:	6aa6                	ld	s5,72(sp)
 802:	6b06                	ld	s6,64(sp)
 804:	7be2                	ld	s7,56(sp)
 806:	7c42                	ld	s8,48(sp)
 808:	7ca2                	ld	s9,40(sp)
 80a:	7d02                	ld	s10,32(sp)
 80c:	6de2                	ld	s11,24(sp)
 80e:	6109                	addi	sp,sp,128
 810:	8082                	ret

0000000000000812 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 812:	715d                	addi	sp,sp,-80
 814:	ec06                	sd	ra,24(sp)
 816:	e822                	sd	s0,16(sp)
 818:	1000                	addi	s0,sp,32
 81a:	e010                	sd	a2,0(s0)
 81c:	e414                	sd	a3,8(s0)
 81e:	e818                	sd	a4,16(s0)
 820:	ec1c                	sd	a5,24(s0)
 822:	03043023          	sd	a6,32(s0)
 826:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 82a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82e:	8622                	mv	a2,s0
 830:	00000097          	auipc	ra,0x0
 834:	e04080e7          	jalr	-508(ra) # 634 <vprintf>
}
 838:	60e2                	ld	ra,24(sp)
 83a:	6442                	ld	s0,16(sp)
 83c:	6161                	addi	sp,sp,80
 83e:	8082                	ret

0000000000000840 <printf>:

void
printf(const char *fmt, ...)
{
 840:	711d                	addi	sp,sp,-96
 842:	ec06                	sd	ra,24(sp)
 844:	e822                	sd	s0,16(sp)
 846:	1000                	addi	s0,sp,32
 848:	e40c                	sd	a1,8(s0)
 84a:	e810                	sd	a2,16(s0)
 84c:	ec14                	sd	a3,24(s0)
 84e:	f018                	sd	a4,32(s0)
 850:	f41c                	sd	a5,40(s0)
 852:	03043823          	sd	a6,48(s0)
 856:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 85a:	00840613          	addi	a2,s0,8
 85e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 862:	85aa                	mv	a1,a0
 864:	4505                	li	a0,1
 866:	00000097          	auipc	ra,0x0
 86a:	dce080e7          	jalr	-562(ra) # 634 <vprintf>
}
 86e:	60e2                	ld	ra,24(sp)
 870:	6442                	ld	s0,16(sp)
 872:	6125                	addi	sp,sp,96
 874:	8082                	ret

0000000000000876 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 876:	1141                	addi	sp,sp,-16
 878:	e422                	sd	s0,8(sp)
 87a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	00000797          	auipc	a5,0x0
 884:	2f07b783          	ld	a5,752(a5) # b70 <freep>
 888:	a02d                	j	8b2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 88a:	4618                	lw	a4,8(a2)
 88c:	9f2d                	addw	a4,a4,a1
 88e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 892:	6398                	ld	a4,0(a5)
 894:	6310                	ld	a2,0(a4)
 896:	a83d                	j	8d4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 898:	ff852703          	lw	a4,-8(a0)
 89c:	9f31                	addw	a4,a4,a2
 89e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8a0:	ff053683          	ld	a3,-16(a0)
 8a4:	a091                	j	8e8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a6:	6398                	ld	a4,0(a5)
 8a8:	00e7e463          	bltu	a5,a4,8b0 <free+0x3a>
 8ac:	00e6ea63          	bltu	a3,a4,8c0 <free+0x4a>
{
 8b0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b2:	fed7fae3          	bgeu	a5,a3,8a6 <free+0x30>
 8b6:	6398                	ld	a4,0(a5)
 8b8:	00e6e463          	bltu	a3,a4,8c0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8bc:	fee7eae3          	bltu	a5,a4,8b0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8c0:	ff852583          	lw	a1,-8(a0)
 8c4:	6390                	ld	a2,0(a5)
 8c6:	02059813          	slli	a6,a1,0x20
 8ca:	01c85713          	srli	a4,a6,0x1c
 8ce:	9736                	add	a4,a4,a3
 8d0:	fae60de3          	beq	a2,a4,88a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8d4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8d8:	4790                	lw	a2,8(a5)
 8da:	02061593          	slli	a1,a2,0x20
 8de:	01c5d713          	srli	a4,a1,0x1c
 8e2:	973e                	add	a4,a4,a5
 8e4:	fae68ae3          	beq	a3,a4,898 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8e8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	28f73323          	sd	a5,646(a4) # b70 <freep>
}
 8f2:	6422                	ld	s0,8(sp)
 8f4:	0141                	addi	sp,sp,16
 8f6:	8082                	ret

00000000000008f8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f8:	7139                	addi	sp,sp,-64
 8fa:	fc06                	sd	ra,56(sp)
 8fc:	f822                	sd	s0,48(sp)
 8fe:	f426                	sd	s1,40(sp)
 900:	f04a                	sd	s2,32(sp)
 902:	ec4e                	sd	s3,24(sp)
 904:	e852                	sd	s4,16(sp)
 906:	e456                	sd	s5,8(sp)
 908:	e05a                	sd	s6,0(sp)
 90a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 90c:	02051493          	slli	s1,a0,0x20
 910:	9081                	srli	s1,s1,0x20
 912:	04bd                	addi	s1,s1,15
 914:	8091                	srli	s1,s1,0x4
 916:	0014899b          	addiw	s3,s1,1
 91a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 91c:	00000517          	auipc	a0,0x0
 920:	25453503          	ld	a0,596(a0) # b70 <freep>
 924:	c515                	beqz	a0,950 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 926:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 928:	4798                	lw	a4,8(a5)
 92a:	02977f63          	bgeu	a4,s1,968 <malloc+0x70>
 92e:	8a4e                	mv	s4,s3
 930:	0009871b          	sext.w	a4,s3
 934:	6685                	lui	a3,0x1
 936:	00d77363          	bgeu	a4,a3,93c <malloc+0x44>
 93a:	6a05                	lui	s4,0x1
 93c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 940:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 944:	00000917          	auipc	s2,0x0
 948:	22c90913          	addi	s2,s2,556 # b70 <freep>
  if(p == (char*)-1)
 94c:	5afd                	li	s5,-1
 94e:	a895                	j	9c2 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 950:	00000797          	auipc	a5,0x0
 954:	22878793          	addi	a5,a5,552 # b78 <base>
 958:	00000717          	auipc	a4,0x0
 95c:	20f73c23          	sd	a5,536(a4) # b70 <freep>
 960:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 962:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 966:	b7e1                	j	92e <malloc+0x36>
      if(p->s.size == nunits)
 968:	02e48c63          	beq	s1,a4,9a0 <malloc+0xa8>
        p->s.size -= nunits;
 96c:	4137073b          	subw	a4,a4,s3
 970:	c798                	sw	a4,8(a5)
        p += p->s.size;
 972:	02071693          	slli	a3,a4,0x20
 976:	01c6d713          	srli	a4,a3,0x1c
 97a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 97c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 980:	00000717          	auipc	a4,0x0
 984:	1ea73823          	sd	a0,496(a4) # b70 <freep>
      return (void*)(p + 1);
 988:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 98c:	70e2                	ld	ra,56(sp)
 98e:	7442                	ld	s0,48(sp)
 990:	74a2                	ld	s1,40(sp)
 992:	7902                	ld	s2,32(sp)
 994:	69e2                	ld	s3,24(sp)
 996:	6a42                	ld	s4,16(sp)
 998:	6aa2                	ld	s5,8(sp)
 99a:	6b02                	ld	s6,0(sp)
 99c:	6121                	addi	sp,sp,64
 99e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 9a0:	6398                	ld	a4,0(a5)
 9a2:	e118                	sd	a4,0(a0)
 9a4:	bff1                	j	980 <malloc+0x88>
  hp->s.size = nu;
 9a6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9aa:	0541                	addi	a0,a0,16
 9ac:	00000097          	auipc	ra,0x0
 9b0:	eca080e7          	jalr	-310(ra) # 876 <free>
  return freep;
 9b4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9b8:	d971                	beqz	a0,98c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9bc:	4798                	lw	a4,8(a5)
 9be:	fa9775e3          	bgeu	a4,s1,968 <malloc+0x70>
    if(p == freep)
 9c2:	00093703          	ld	a4,0(s2)
 9c6:	853e                	mv	a0,a5
 9c8:	fef719e3          	bne	a4,a5,9ba <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9cc:	8552                	mv	a0,s4
 9ce:	00000097          	auipc	ra,0x0
 9d2:	ae0080e7          	jalr	-1312(ra) # 4ae <sbrk>
  if(p == (char*)-1)
 9d6:	fd5518e3          	bne	a0,s5,9a6 <malloc+0xae>
        return 0;
 9da:	4501                	li	a0,0
 9dc:	bf45                	j	98c <malloc+0x94>
