
user/_barriergrouptest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	e45e                	sd	s7,8(sp)
  14:	e062                	sd	s8,0(sp)
  16:	0880                	addi	s0,sp,80
  int i, j, n, r, barrier_id1, barrier_id2;

  if (argc != 3) {
  18:	478d                	li	a5,3
  1a:	02f50063          	beq	a0,a5,3a <main+0x3a>
     fprintf(2, "syntax: barriergrouptest numprocs numrounds\nAborting...\n");
  1e:	00001597          	auipc	a1,0x1
  22:	95a58593          	addi	a1,a1,-1702 # 978 <malloc+0xea>
  26:	4509                	li	a0,2
  28:	00000097          	auipc	ra,0x0
  2c:	780080e7          	jalr	1920(ra) # 7a8 <fprintf>
     exit(0);
  30:	4501                	li	a0,0
  32:	00000097          	auipc	ra,0x0
  36:	38a080e7          	jalr	906(ra) # 3bc <exit>
  3a:	84ae                	mv	s1,a1
  }

  n = atoi(argv[1]);
  3c:	6588                	ld	a0,8(a1)
  3e:	00000097          	auipc	ra,0x0
  42:	284080e7          	jalr	644(ra) # 2c2 <atoi>
  46:	8c2a                	mv	s8,a0
  r = atoi(argv[2]);
  48:	6888                	ld	a0,16(s1)
  4a:	00000097          	auipc	ra,0x0
  4e:	278080e7          	jalr	632(ra) # 2c2 <atoi>
  52:	89aa                	mv	s3,a0
  barrier_id1 = barrier_alloc();
  54:	00000097          	auipc	ra,0x0
  58:	450080e7          	jalr	1104(ra) # 4a4 <barrier_alloc>
  5c:	8baa                	mv	s7,a0
  barrier_id2 = barrier_alloc();
  5e:	00000097          	auipc	ra,0x0
  62:	446080e7          	jalr	1094(ra) # 4a4 <barrier_alloc>
  66:	8a2a                	mv	s4,a0
  fprintf(1, "%d: got barrier array ids %d, %d\n\n", getpid(), barrier_id1, barrier_id2);
  68:	00000097          	auipc	ra,0x0
  6c:	3d4080e7          	jalr	980(ra) # 43c <getpid>
  70:	862a                	mv	a2,a0
  72:	8752                	mv	a4,s4
  74:	86de                	mv	a3,s7
  76:	00001597          	auipc	a1,0x1
  7a:	94258593          	addi	a1,a1,-1726 # 9b8 <malloc+0x12a>
  7e:	4505                	li	a0,1
  80:	00000097          	auipc	ra,0x0
  84:	728080e7          	jalr	1832(ra) # 7a8 <fprintf>

  for (i=0; i<n-1; i++) {
  88:	fffc0b1b          	addiw	s6,s8,-1
  8c:	0b605f63          	blez	s6,14a <main+0x14a>
  90:	8ada                	mv	s5,s6
  92:	4901                	li	s2,0
     if (fork() == 0) {
  94:	00000097          	auipc	ra,0x0
  98:	320080e7          	jalr	800(ra) # 3b4 <fork>
  9c:	84aa                	mv	s1,a0
  9e:	cd31                	beqz	a0,fa <main+0xfa>
  for (i=0; i<n-1; i++) {
  a0:	2905                	addiw	s2,s2,1
  a2:	ff5919e3          	bne	s2,s5,94 <main+0x94>
           }
        }
	exit(0);
     }
  }
  for (j=0; j<r; j++) {
  a6:	03305263          	blez	s3,ca <main+0xca>
     barrier(j, barrier_id2, n/2);
  aa:	4909                	li	s2,2
  ac:	032c493b          	divw	s2,s8,s2
  for (j=0; j<r; j++) {
  b0:	4481                	li	s1,0
     barrier(j, barrier_id2, n/2);
  b2:	864a                	mv	a2,s2
  b4:	85d2                	mv	a1,s4
  b6:	8526                	mv	a0,s1
  b8:	00000097          	auipc	ra,0x0
  bc:	3f6080e7          	jalr	1014(ra) # 4ae <barrier>
  for (j=0; j<r; j++) {
  c0:	2485                	addiw	s1,s1,1
  c2:	ff34c8e3          	blt	s1,s3,b2 <main+0xb2>
  }
  for (i=0; i<n-1; i++) wait(0);
  c6:	01605b63          	blez	s6,dc <main+0xdc>
  for (j=0; j<r; j++) {
  ca:	4481                	li	s1,0
  for (i=0; i<n-1; i++) wait(0);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	2f6080e7          	jalr	758(ra) # 3c4 <wait>
  d6:	2485                	addiw	s1,s1,1
  d8:	ff64cae3          	blt	s1,s6,cc <main+0xcc>
  barrier_free(barrier_id1);
  dc:	855e                	mv	a0,s7
  de:	00000097          	auipc	ra,0x0
  e2:	3d8080e7          	jalr	984(ra) # 4b6 <barrier_free>
  barrier_free(barrier_id2);
  e6:	8552                	mv	a0,s4
  e8:	00000097          	auipc	ra,0x0
  ec:	3ce080e7          	jalr	974(ra) # 4b6 <barrier_free>
  exit(0);
  f0:	4501                	li	a0,0
  f2:	00000097          	auipc	ra,0x0
  f6:	2ca080e7          	jalr	714(ra) # 3bc <exit>
	if ((i%2) == 0) {
  fa:	00197913          	andi	s2,s2,1
  fe:	02090263          	beqz	s2,122 <main+0x122>
	   for (j=0; j<r; j++) {
 102:	03305f63          	blez	s3,140 <main+0x140>
              barrier(j, barrier_id2, n/2);
 106:	4909                	li	s2,2
 108:	032c493b          	divw	s2,s8,s2
 10c:	864a                	mv	a2,s2
 10e:	85d2                	mv	a1,s4
 110:	8526                	mv	a0,s1
 112:	00000097          	auipc	ra,0x0
 116:	39c080e7          	jalr	924(ra) # 4ae <barrier>
	   for (j=0; j<r; j++) {
 11a:	2485                	addiw	s1,s1,1
 11c:	fe9998e3          	bne	s3,s1,10c <main+0x10c>
 120:	a005                	j	140 <main+0x140>
           for (j=0; j<r; j++) {
 122:	01305f63          	blez	s3,140 <main+0x140>
	      barrier(j, barrier_id1, n/2);
 126:	4909                	li	s2,2
 128:	032c493b          	divw	s2,s8,s2
 12c:	864a                	mv	a2,s2
 12e:	85de                	mv	a1,s7
 130:	8526                	mv	a0,s1
 132:	00000097          	auipc	ra,0x0
 136:	37c080e7          	jalr	892(ra) # 4ae <barrier>
           for (j=0; j<r; j++) {
 13a:	2485                	addiw	s1,s1,1
 13c:	fe9998e3          	bne	s3,s1,12c <main+0x12c>
	exit(0);
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	27a080e7          	jalr	634(ra) # 3bc <exit>
  for (j=0; j<r; j++) {
 14a:	f73040e3          	bgtz	s3,aa <main+0xaa>
 14e:	b779                	j	dc <main+0xdc>

0000000000000150 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 150:	1141                	addi	sp,sp,-16
 152:	e422                	sd	s0,8(sp)
 154:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 156:	87aa                	mv	a5,a0
 158:	0585                	addi	a1,a1,1
 15a:	0785                	addi	a5,a5,1
 15c:	fff5c703          	lbu	a4,-1(a1)
 160:	fee78fa3          	sb	a4,-1(a5)
 164:	fb75                	bnez	a4,158 <strcpy+0x8>
    ;
  return os;
}
 166:	6422                	ld	s0,8(sp)
 168:	0141                	addi	sp,sp,16
 16a:	8082                	ret

000000000000016c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16c:	1141                	addi	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 172:	00054783          	lbu	a5,0(a0)
 176:	cb91                	beqz	a5,18a <strcmp+0x1e>
 178:	0005c703          	lbu	a4,0(a1)
 17c:	00f71763          	bne	a4,a5,18a <strcmp+0x1e>
    p++, q++;
 180:	0505                	addi	a0,a0,1
 182:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 184:	00054783          	lbu	a5,0(a0)
 188:	fbe5                	bnez	a5,178 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 18a:	0005c503          	lbu	a0,0(a1)
}
 18e:	40a7853b          	subw	a0,a5,a0
 192:	6422                	ld	s0,8(sp)
 194:	0141                	addi	sp,sp,16
 196:	8082                	ret

0000000000000198 <strlen>:

uint
strlen(const char *s)
{
 198:	1141                	addi	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	cf91                	beqz	a5,1be <strlen+0x26>
 1a4:	0505                	addi	a0,a0,1
 1a6:	87aa                	mv	a5,a0
 1a8:	4685                	li	a3,1
 1aa:	9e89                	subw	a3,a3,a0
 1ac:	00f6853b          	addw	a0,a3,a5
 1b0:	0785                	addi	a5,a5,1
 1b2:	fff7c703          	lbu	a4,-1(a5)
 1b6:	fb7d                	bnez	a4,1ac <strlen+0x14>
    ;
  return n;
}
 1b8:	6422                	ld	s0,8(sp)
 1ba:	0141                	addi	sp,sp,16
 1bc:	8082                	ret
  for(n = 0; s[n]; n++)
 1be:	4501                	li	a0,0
 1c0:	bfe5                	j	1b8 <strlen+0x20>

00000000000001c2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1c8:	ca19                	beqz	a2,1de <memset+0x1c>
 1ca:	87aa                	mv	a5,a0
 1cc:	1602                	slli	a2,a2,0x20
 1ce:	9201                	srli	a2,a2,0x20
 1d0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1d4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1d8:	0785                	addi	a5,a5,1
 1da:	fee79de3          	bne	a5,a4,1d4 <memset+0x12>
  }
  return dst;
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	addi	sp,sp,16
 1e2:	8082                	ret

00000000000001e4 <strchr>:

char*
strchr(const char *s, char c)
{
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1ea:	00054783          	lbu	a5,0(a0)
 1ee:	cb99                	beqz	a5,204 <strchr+0x20>
    if(*s == c)
 1f0:	00f58763          	beq	a1,a5,1fe <strchr+0x1a>
  for(; *s; s++)
 1f4:	0505                	addi	a0,a0,1
 1f6:	00054783          	lbu	a5,0(a0)
 1fa:	fbfd                	bnez	a5,1f0 <strchr+0xc>
      return (char*)s;
  return 0;
 1fc:	4501                	li	a0,0
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  return 0;
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <strchr+0x1a>

0000000000000208 <gets>:

char*
gets(char *buf, int max)
{
 208:	711d                	addi	sp,sp,-96
 20a:	ec86                	sd	ra,88(sp)
 20c:	e8a2                	sd	s0,80(sp)
 20e:	e4a6                	sd	s1,72(sp)
 210:	e0ca                	sd	s2,64(sp)
 212:	fc4e                	sd	s3,56(sp)
 214:	f852                	sd	s4,48(sp)
 216:	f456                	sd	s5,40(sp)
 218:	f05a                	sd	s6,32(sp)
 21a:	ec5e                	sd	s7,24(sp)
 21c:	1080                	addi	s0,sp,96
 21e:	8baa                	mv	s7,a0
 220:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 222:	892a                	mv	s2,a0
 224:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 226:	4aa9                	li	s5,10
 228:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 22a:	89a6                	mv	s3,s1
 22c:	2485                	addiw	s1,s1,1
 22e:	0344d863          	bge	s1,s4,25e <gets+0x56>
    cc = read(0, &c, 1);
 232:	4605                	li	a2,1
 234:	faf40593          	addi	a1,s0,-81
 238:	4501                	li	a0,0
 23a:	00000097          	auipc	ra,0x0
 23e:	19a080e7          	jalr	410(ra) # 3d4 <read>
    if(cc < 1)
 242:	00a05e63          	blez	a0,25e <gets+0x56>
    buf[i++] = c;
 246:	faf44783          	lbu	a5,-81(s0)
 24a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 24e:	01578763          	beq	a5,s5,25c <gets+0x54>
 252:	0905                	addi	s2,s2,1
 254:	fd679be3          	bne	a5,s6,22a <gets+0x22>
  for(i=0; i+1 < max; ){
 258:	89a6                	mv	s3,s1
 25a:	a011                	j	25e <gets+0x56>
 25c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 25e:	99de                	add	s3,s3,s7
 260:	00098023          	sb	zero,0(s3)
  return buf;
}
 264:	855e                	mv	a0,s7
 266:	60e6                	ld	ra,88(sp)
 268:	6446                	ld	s0,80(sp)
 26a:	64a6                	ld	s1,72(sp)
 26c:	6906                	ld	s2,64(sp)
 26e:	79e2                	ld	s3,56(sp)
 270:	7a42                	ld	s4,48(sp)
 272:	7aa2                	ld	s5,40(sp)
 274:	7b02                	ld	s6,32(sp)
 276:	6be2                	ld	s7,24(sp)
 278:	6125                	addi	sp,sp,96
 27a:	8082                	ret

000000000000027c <stat>:

int
stat(const char *n, struct stat *st)
{
 27c:	1101                	addi	sp,sp,-32
 27e:	ec06                	sd	ra,24(sp)
 280:	e822                	sd	s0,16(sp)
 282:	e426                	sd	s1,8(sp)
 284:	e04a                	sd	s2,0(sp)
 286:	1000                	addi	s0,sp,32
 288:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28a:	4581                	li	a1,0
 28c:	00000097          	auipc	ra,0x0
 290:	170080e7          	jalr	368(ra) # 3fc <open>
  if(fd < 0)
 294:	02054563          	bltz	a0,2be <stat+0x42>
 298:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 29a:	85ca                	mv	a1,s2
 29c:	00000097          	auipc	ra,0x0
 2a0:	178080e7          	jalr	376(ra) # 414 <fstat>
 2a4:	892a                	mv	s2,a0
  close(fd);
 2a6:	8526                	mv	a0,s1
 2a8:	00000097          	auipc	ra,0x0
 2ac:	13c080e7          	jalr	316(ra) # 3e4 <close>
  return r;
}
 2b0:	854a                	mv	a0,s2
 2b2:	60e2                	ld	ra,24(sp)
 2b4:	6442                	ld	s0,16(sp)
 2b6:	64a2                	ld	s1,8(sp)
 2b8:	6902                	ld	s2,0(sp)
 2ba:	6105                	addi	sp,sp,32
 2bc:	8082                	ret
    return -1;
 2be:	597d                	li	s2,-1
 2c0:	bfc5                	j	2b0 <stat+0x34>

00000000000002c2 <atoi>:

int
atoi(const char *s)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2c8:	00054683          	lbu	a3,0(a0)
 2cc:	fd06879b          	addiw	a5,a3,-48
 2d0:	0ff7f793          	zext.b	a5,a5
 2d4:	4625                	li	a2,9
 2d6:	02f66863          	bltu	a2,a5,306 <atoi+0x44>
 2da:	872a                	mv	a4,a0
  n = 0;
 2dc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2de:	0705                	addi	a4,a4,1
 2e0:	0025179b          	slliw	a5,a0,0x2
 2e4:	9fa9                	addw	a5,a5,a0
 2e6:	0017979b          	slliw	a5,a5,0x1
 2ea:	9fb5                	addw	a5,a5,a3
 2ec:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f0:	00074683          	lbu	a3,0(a4)
 2f4:	fd06879b          	addiw	a5,a3,-48
 2f8:	0ff7f793          	zext.b	a5,a5
 2fc:	fef671e3          	bgeu	a2,a5,2de <atoi+0x1c>
  return n;
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret
  n = 0;
 306:	4501                	li	a0,0
 308:	bfe5                	j	300 <atoi+0x3e>

000000000000030a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 310:	02b57463          	bgeu	a0,a1,338 <memmove+0x2e>
    while(n-- > 0)
 314:	00c05f63          	blez	a2,332 <memmove+0x28>
 318:	1602                	slli	a2,a2,0x20
 31a:	9201                	srli	a2,a2,0x20
 31c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 320:	872a                	mv	a4,a0
      *dst++ = *src++;
 322:	0585                	addi	a1,a1,1
 324:	0705                	addi	a4,a4,1
 326:	fff5c683          	lbu	a3,-1(a1)
 32a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 32e:	fee79ae3          	bne	a5,a4,322 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 332:	6422                	ld	s0,8(sp)
 334:	0141                	addi	sp,sp,16
 336:	8082                	ret
    dst += n;
 338:	00c50733          	add	a4,a0,a2
    src += n;
 33c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 33e:	fec05ae3          	blez	a2,332 <memmove+0x28>
 342:	fff6079b          	addiw	a5,a2,-1
 346:	1782                	slli	a5,a5,0x20
 348:	9381                	srli	a5,a5,0x20
 34a:	fff7c793          	not	a5,a5
 34e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 350:	15fd                	addi	a1,a1,-1
 352:	177d                	addi	a4,a4,-1
 354:	0005c683          	lbu	a3,0(a1)
 358:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 35c:	fee79ae3          	bne	a5,a4,350 <memmove+0x46>
 360:	bfc9                	j	332 <memmove+0x28>

0000000000000362 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 362:	1141                	addi	sp,sp,-16
 364:	e422                	sd	s0,8(sp)
 366:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 368:	ca05                	beqz	a2,398 <memcmp+0x36>
 36a:	fff6069b          	addiw	a3,a2,-1
 36e:	1682                	slli	a3,a3,0x20
 370:	9281                	srli	a3,a3,0x20
 372:	0685                	addi	a3,a3,1
 374:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 376:	00054783          	lbu	a5,0(a0)
 37a:	0005c703          	lbu	a4,0(a1)
 37e:	00e79863          	bne	a5,a4,38e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 382:	0505                	addi	a0,a0,1
    p2++;
 384:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 386:	fed518e3          	bne	a0,a3,376 <memcmp+0x14>
  }
  return 0;
 38a:	4501                	li	a0,0
 38c:	a019                	j	392 <memcmp+0x30>
      return *p1 - *p2;
 38e:	40e7853b          	subw	a0,a5,a4
}
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
  return 0;
 398:	4501                	li	a0,0
 39a:	bfe5                	j	392 <memcmp+0x30>

000000000000039c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e406                	sd	ra,8(sp)
 3a0:	e022                	sd	s0,0(sp)
 3a2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3a4:	00000097          	auipc	ra,0x0
 3a8:	f66080e7          	jalr	-154(ra) # 30a <memmove>
}
 3ac:	60a2                	ld	ra,8(sp)
 3ae:	6402                	ld	s0,0(sp)
 3b0:	0141                	addi	sp,sp,16
 3b2:	8082                	ret

00000000000003b4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3b4:	4885                	li	a7,1
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3bc:	4889                	li	a7,2
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3c4:	488d                	li	a7,3
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3cc:	4891                	li	a7,4
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <read>:
.global read
read:
 li a7, SYS_read
 3d4:	4895                	li	a7,5
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <write>:
.global write
write:
 li a7, SYS_write
 3dc:	48c1                	li	a7,16
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <close>:
.global close
close:
 li a7, SYS_close
 3e4:	48d5                	li	a7,21
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ec:	4899                	li	a7,6
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3f4:	489d                	li	a7,7
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <open>:
.global open
open:
 li a7, SYS_open
 3fc:	48bd                	li	a7,15
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 404:	48c5                	li	a7,17
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 40c:	48c9                	li	a7,18
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 414:	48a1                	li	a7,8
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <link>:
.global link
link:
 li a7, SYS_link
 41c:	48cd                	li	a7,19
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 424:	48d1                	li	a7,20
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 42c:	48a5                	li	a7,9
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <dup>:
.global dup
dup:
 li a7, SYS_dup
 434:	48a9                	li	a7,10
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 43c:	48ad                	li	a7,11
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 444:	48b1                	li	a7,12
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 44c:	48b5                	li	a7,13
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 454:	48b9                	li	a7,14
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 45c:	48d9                	li	a7,22
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <yield>:
.global yield
yield:
 li a7, SYS_yield
 464:	48dd                	li	a7,23
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 46c:	48e1                	li	a7,24
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 474:	48e5                	li	a7,25
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 47c:	48e9                	li	a7,26
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <ps>:
.global ps
ps:
 li a7, SYS_ps
 484:	48ed                	li	a7,27
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 48c:	48f1                	li	a7,28
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 494:	48f5                	li	a7,29
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 49c:	48f9                	li	a7,30
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 4a4:	02100893          	li	a7,33
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 4ae:	48fd                	li	a7,31
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 4b6:	02000893          	li	a7,32
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 4c0:	02200893          	li	a7,34
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 4ca:	02300893          	li	a7,35
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 4d4:	02400893          	li	a7,36
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 4de:	02500893          	li	a7,37
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 4e8:	02700893          	li	a7,39
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 4f2:	02600893          	li	a7,38
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4fc:	1101                	addi	sp,sp,-32
 4fe:	ec06                	sd	ra,24(sp)
 500:	e822                	sd	s0,16(sp)
 502:	1000                	addi	s0,sp,32
 504:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 508:	4605                	li	a2,1
 50a:	fef40593          	addi	a1,s0,-17
 50e:	00000097          	auipc	ra,0x0
 512:	ece080e7          	jalr	-306(ra) # 3dc <write>
}
 516:	60e2                	ld	ra,24(sp)
 518:	6442                	ld	s0,16(sp)
 51a:	6105                	addi	sp,sp,32
 51c:	8082                	ret

000000000000051e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 51e:	7139                	addi	sp,sp,-64
 520:	fc06                	sd	ra,56(sp)
 522:	f822                	sd	s0,48(sp)
 524:	f426                	sd	s1,40(sp)
 526:	f04a                	sd	s2,32(sp)
 528:	ec4e                	sd	s3,24(sp)
 52a:	0080                	addi	s0,sp,64
 52c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 52e:	c299                	beqz	a3,534 <printint+0x16>
 530:	0805c963          	bltz	a1,5c2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 534:	2581                	sext.w	a1,a1
  neg = 0;
 536:	4881                	li	a7,0
 538:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 53c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 53e:	2601                	sext.w	a2,a2
 540:	00000517          	auipc	a0,0x0
 544:	50050513          	addi	a0,a0,1280 # a40 <digits>
 548:	883a                	mv	a6,a4
 54a:	2705                	addiw	a4,a4,1
 54c:	02c5f7bb          	remuw	a5,a1,a2
 550:	1782                	slli	a5,a5,0x20
 552:	9381                	srli	a5,a5,0x20
 554:	97aa                	add	a5,a5,a0
 556:	0007c783          	lbu	a5,0(a5)
 55a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 55e:	0005879b          	sext.w	a5,a1
 562:	02c5d5bb          	divuw	a1,a1,a2
 566:	0685                	addi	a3,a3,1
 568:	fec7f0e3          	bgeu	a5,a2,548 <printint+0x2a>
  if(neg)
 56c:	00088c63          	beqz	a7,584 <printint+0x66>
    buf[i++] = '-';
 570:	fd070793          	addi	a5,a4,-48
 574:	00878733          	add	a4,a5,s0
 578:	02d00793          	li	a5,45
 57c:	fef70823          	sb	a5,-16(a4)
 580:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 584:	02e05863          	blez	a4,5b4 <printint+0x96>
 588:	fc040793          	addi	a5,s0,-64
 58c:	00e78933          	add	s2,a5,a4
 590:	fff78993          	addi	s3,a5,-1
 594:	99ba                	add	s3,s3,a4
 596:	377d                	addiw	a4,a4,-1
 598:	1702                	slli	a4,a4,0x20
 59a:	9301                	srli	a4,a4,0x20
 59c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5a0:	fff94583          	lbu	a1,-1(s2)
 5a4:	8526                	mv	a0,s1
 5a6:	00000097          	auipc	ra,0x0
 5aa:	f56080e7          	jalr	-170(ra) # 4fc <putc>
  while(--i >= 0)
 5ae:	197d                	addi	s2,s2,-1
 5b0:	ff3918e3          	bne	s2,s3,5a0 <printint+0x82>
}
 5b4:	70e2                	ld	ra,56(sp)
 5b6:	7442                	ld	s0,48(sp)
 5b8:	74a2                	ld	s1,40(sp)
 5ba:	7902                	ld	s2,32(sp)
 5bc:	69e2                	ld	s3,24(sp)
 5be:	6121                	addi	sp,sp,64
 5c0:	8082                	ret
    x = -xx;
 5c2:	40b005bb          	negw	a1,a1
    neg = 1;
 5c6:	4885                	li	a7,1
    x = -xx;
 5c8:	bf85                	j	538 <printint+0x1a>

00000000000005ca <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ca:	7119                	addi	sp,sp,-128
 5cc:	fc86                	sd	ra,120(sp)
 5ce:	f8a2                	sd	s0,112(sp)
 5d0:	f4a6                	sd	s1,104(sp)
 5d2:	f0ca                	sd	s2,96(sp)
 5d4:	ecce                	sd	s3,88(sp)
 5d6:	e8d2                	sd	s4,80(sp)
 5d8:	e4d6                	sd	s5,72(sp)
 5da:	e0da                	sd	s6,64(sp)
 5dc:	fc5e                	sd	s7,56(sp)
 5de:	f862                	sd	s8,48(sp)
 5e0:	f466                	sd	s9,40(sp)
 5e2:	f06a                	sd	s10,32(sp)
 5e4:	ec6e                	sd	s11,24(sp)
 5e6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5e8:	0005c903          	lbu	s2,0(a1)
 5ec:	18090f63          	beqz	s2,78a <vprintf+0x1c0>
 5f0:	8aaa                	mv	s5,a0
 5f2:	8b32                	mv	s6,a2
 5f4:	00158493          	addi	s1,a1,1
  state = 0;
 5f8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5fa:	02500a13          	li	s4,37
 5fe:	4c55                	li	s8,21
 600:	00000c97          	auipc	s9,0x0
 604:	3e8c8c93          	addi	s9,s9,1000 # 9e8 <malloc+0x15a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 608:	02800d93          	li	s11,40
  putc(fd, 'x');
 60c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60e:	00000b97          	auipc	s7,0x0
 612:	432b8b93          	addi	s7,s7,1074 # a40 <digits>
 616:	a839                	j	634 <vprintf+0x6a>
        putc(fd, c);
 618:	85ca                	mv	a1,s2
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	ee0080e7          	jalr	-288(ra) # 4fc <putc>
 624:	a019                	j	62a <vprintf+0x60>
    } else if(state == '%'){
 626:	01498d63          	beq	s3,s4,640 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 62a:	0485                	addi	s1,s1,1
 62c:	fff4c903          	lbu	s2,-1(s1)
 630:	14090d63          	beqz	s2,78a <vprintf+0x1c0>
    if(state == 0){
 634:	fe0999e3          	bnez	s3,626 <vprintf+0x5c>
      if(c == '%'){
 638:	ff4910e3          	bne	s2,s4,618 <vprintf+0x4e>
        state = '%';
 63c:	89d2                	mv	s3,s4
 63e:	b7f5                	j	62a <vprintf+0x60>
      if(c == 'd'){
 640:	11490c63          	beq	s2,s4,758 <vprintf+0x18e>
 644:	f9d9079b          	addiw	a5,s2,-99
 648:	0ff7f793          	zext.b	a5,a5
 64c:	10fc6e63          	bltu	s8,a5,768 <vprintf+0x19e>
 650:	f9d9079b          	addiw	a5,s2,-99
 654:	0ff7f713          	zext.b	a4,a5
 658:	10ec6863          	bltu	s8,a4,768 <vprintf+0x19e>
 65c:	00271793          	slli	a5,a4,0x2
 660:	97e6                	add	a5,a5,s9
 662:	439c                	lw	a5,0(a5)
 664:	97e6                	add	a5,a5,s9
 666:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 668:	008b0913          	addi	s2,s6,8
 66c:	4685                	li	a3,1
 66e:	4629                	li	a2,10
 670:	000b2583          	lw	a1,0(s6)
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	ea8080e7          	jalr	-344(ra) # 51e <printint>
 67e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 680:	4981                	li	s3,0
 682:	b765                	j	62a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 684:	008b0913          	addi	s2,s6,8
 688:	4681                	li	a3,0
 68a:	4629                	li	a2,10
 68c:	000b2583          	lw	a1,0(s6)
 690:	8556                	mv	a0,s5
 692:	00000097          	auipc	ra,0x0
 696:	e8c080e7          	jalr	-372(ra) # 51e <printint>
 69a:	8b4a                	mv	s6,s2
      state = 0;
 69c:	4981                	li	s3,0
 69e:	b771                	j	62a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6a0:	008b0913          	addi	s2,s6,8
 6a4:	4681                	li	a3,0
 6a6:	866a                	mv	a2,s10
 6a8:	000b2583          	lw	a1,0(s6)
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	e70080e7          	jalr	-400(ra) # 51e <printint>
 6b6:	8b4a                	mv	s6,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bf85                	j	62a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6bc:	008b0793          	addi	a5,s6,8
 6c0:	f8f43423          	sd	a5,-120(s0)
 6c4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6c8:	03000593          	li	a1,48
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	e2e080e7          	jalr	-466(ra) # 4fc <putc>
  putc(fd, 'x');
 6d6:	07800593          	li	a1,120
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	e20080e7          	jalr	-480(ra) # 4fc <putc>
 6e4:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e6:	03c9d793          	srli	a5,s3,0x3c
 6ea:	97de                	add	a5,a5,s7
 6ec:	0007c583          	lbu	a1,0(a5)
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	e0a080e7          	jalr	-502(ra) # 4fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6fa:	0992                	slli	s3,s3,0x4
 6fc:	397d                	addiw	s2,s2,-1
 6fe:	fe0914e3          	bnez	s2,6e6 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 702:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 706:	4981                	li	s3,0
 708:	b70d                	j	62a <vprintf+0x60>
        s = va_arg(ap, char*);
 70a:	008b0913          	addi	s2,s6,8
 70e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 712:	02098163          	beqz	s3,734 <vprintf+0x16a>
        while(*s != 0){
 716:	0009c583          	lbu	a1,0(s3)
 71a:	c5ad                	beqz	a1,784 <vprintf+0x1ba>
          putc(fd, *s);
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	dde080e7          	jalr	-546(ra) # 4fc <putc>
          s++;
 726:	0985                	addi	s3,s3,1
        while(*s != 0){
 728:	0009c583          	lbu	a1,0(s3)
 72c:	f9e5                	bnez	a1,71c <vprintf+0x152>
        s = va_arg(ap, char*);
 72e:	8b4a                	mv	s6,s2
      state = 0;
 730:	4981                	li	s3,0
 732:	bde5                	j	62a <vprintf+0x60>
          s = "(null)";
 734:	00000997          	auipc	s3,0x0
 738:	2ac98993          	addi	s3,s3,684 # 9e0 <malloc+0x152>
        while(*s != 0){
 73c:	85ee                	mv	a1,s11
 73e:	bff9                	j	71c <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 740:	008b0913          	addi	s2,s6,8
 744:	000b4583          	lbu	a1,0(s6)
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	db2080e7          	jalr	-590(ra) # 4fc <putc>
 752:	8b4a                	mv	s6,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	bdd1                	j	62a <vprintf+0x60>
        putc(fd, c);
 758:	85d2                	mv	a1,s4
 75a:	8556                	mv	a0,s5
 75c:	00000097          	auipc	ra,0x0
 760:	da0080e7          	jalr	-608(ra) # 4fc <putc>
      state = 0;
 764:	4981                	li	s3,0
 766:	b5d1                	j	62a <vprintf+0x60>
        putc(fd, '%');
 768:	85d2                	mv	a1,s4
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	d90080e7          	jalr	-624(ra) # 4fc <putc>
        putc(fd, c);
 774:	85ca                	mv	a1,s2
 776:	8556                	mv	a0,s5
 778:	00000097          	auipc	ra,0x0
 77c:	d84080e7          	jalr	-636(ra) # 4fc <putc>
      state = 0;
 780:	4981                	li	s3,0
 782:	b565                	j	62a <vprintf+0x60>
        s = va_arg(ap, char*);
 784:	8b4a                	mv	s6,s2
      state = 0;
 786:	4981                	li	s3,0
 788:	b54d                	j	62a <vprintf+0x60>
    }
  }
}
 78a:	70e6                	ld	ra,120(sp)
 78c:	7446                	ld	s0,112(sp)
 78e:	74a6                	ld	s1,104(sp)
 790:	7906                	ld	s2,96(sp)
 792:	69e6                	ld	s3,88(sp)
 794:	6a46                	ld	s4,80(sp)
 796:	6aa6                	ld	s5,72(sp)
 798:	6b06                	ld	s6,64(sp)
 79a:	7be2                	ld	s7,56(sp)
 79c:	7c42                	ld	s8,48(sp)
 79e:	7ca2                	ld	s9,40(sp)
 7a0:	7d02                	ld	s10,32(sp)
 7a2:	6de2                	ld	s11,24(sp)
 7a4:	6109                	addi	sp,sp,128
 7a6:	8082                	ret

00000000000007a8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a8:	715d                	addi	sp,sp,-80
 7aa:	ec06                	sd	ra,24(sp)
 7ac:	e822                	sd	s0,16(sp)
 7ae:	1000                	addi	s0,sp,32
 7b0:	e010                	sd	a2,0(s0)
 7b2:	e414                	sd	a3,8(s0)
 7b4:	e818                	sd	a4,16(s0)
 7b6:	ec1c                	sd	a5,24(s0)
 7b8:	03043023          	sd	a6,32(s0)
 7bc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7c4:	8622                	mv	a2,s0
 7c6:	00000097          	auipc	ra,0x0
 7ca:	e04080e7          	jalr	-508(ra) # 5ca <vprintf>
}
 7ce:	60e2                	ld	ra,24(sp)
 7d0:	6442                	ld	s0,16(sp)
 7d2:	6161                	addi	sp,sp,80
 7d4:	8082                	ret

00000000000007d6 <printf>:

void
printf(const char *fmt, ...)
{
 7d6:	711d                	addi	sp,sp,-96
 7d8:	ec06                	sd	ra,24(sp)
 7da:	e822                	sd	s0,16(sp)
 7dc:	1000                	addi	s0,sp,32
 7de:	e40c                	sd	a1,8(s0)
 7e0:	e810                	sd	a2,16(s0)
 7e2:	ec14                	sd	a3,24(s0)
 7e4:	f018                	sd	a4,32(s0)
 7e6:	f41c                	sd	a5,40(s0)
 7e8:	03043823          	sd	a6,48(s0)
 7ec:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f0:	00840613          	addi	a2,s0,8
 7f4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7f8:	85aa                	mv	a1,a0
 7fa:	4505                	li	a0,1
 7fc:	00000097          	auipc	ra,0x0
 800:	dce080e7          	jalr	-562(ra) # 5ca <vprintf>
}
 804:	60e2                	ld	ra,24(sp)
 806:	6442                	ld	s0,16(sp)
 808:	6125                	addi	sp,sp,96
 80a:	8082                	ret

000000000000080c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 80c:	1141                	addi	sp,sp,-16
 80e:	e422                	sd	s0,8(sp)
 810:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 812:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 816:	00000797          	auipc	a5,0x0
 81a:	2427b783          	ld	a5,578(a5) # a58 <freep>
 81e:	a02d                	j	848 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 820:	4618                	lw	a4,8(a2)
 822:	9f2d                	addw	a4,a4,a1
 824:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 828:	6398                	ld	a4,0(a5)
 82a:	6310                	ld	a2,0(a4)
 82c:	a83d                	j	86a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 82e:	ff852703          	lw	a4,-8(a0)
 832:	9f31                	addw	a4,a4,a2
 834:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 836:	ff053683          	ld	a3,-16(a0)
 83a:	a091                	j	87e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 83c:	6398                	ld	a4,0(a5)
 83e:	00e7e463          	bltu	a5,a4,846 <free+0x3a>
 842:	00e6ea63          	bltu	a3,a4,856 <free+0x4a>
{
 846:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	fed7fae3          	bgeu	a5,a3,83c <free+0x30>
 84c:	6398                	ld	a4,0(a5)
 84e:	00e6e463          	bltu	a3,a4,856 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 852:	fee7eae3          	bltu	a5,a4,846 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 856:	ff852583          	lw	a1,-8(a0)
 85a:	6390                	ld	a2,0(a5)
 85c:	02059813          	slli	a6,a1,0x20
 860:	01c85713          	srli	a4,a6,0x1c
 864:	9736                	add	a4,a4,a3
 866:	fae60de3          	beq	a2,a4,820 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 86a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 86e:	4790                	lw	a2,8(a5)
 870:	02061593          	slli	a1,a2,0x20
 874:	01c5d713          	srli	a4,a1,0x1c
 878:	973e                	add	a4,a4,a5
 87a:	fae68ae3          	beq	a3,a4,82e <free+0x22>
    p->s.ptr = bp->s.ptr;
 87e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 880:	00000717          	auipc	a4,0x0
 884:	1cf73c23          	sd	a5,472(a4) # a58 <freep>
}
 888:	6422                	ld	s0,8(sp)
 88a:	0141                	addi	sp,sp,16
 88c:	8082                	ret

000000000000088e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 88e:	7139                	addi	sp,sp,-64
 890:	fc06                	sd	ra,56(sp)
 892:	f822                	sd	s0,48(sp)
 894:	f426                	sd	s1,40(sp)
 896:	f04a                	sd	s2,32(sp)
 898:	ec4e                	sd	s3,24(sp)
 89a:	e852                	sd	s4,16(sp)
 89c:	e456                	sd	s5,8(sp)
 89e:	e05a                	sd	s6,0(sp)
 8a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a2:	02051493          	slli	s1,a0,0x20
 8a6:	9081                	srli	s1,s1,0x20
 8a8:	04bd                	addi	s1,s1,15
 8aa:	8091                	srli	s1,s1,0x4
 8ac:	0014899b          	addiw	s3,s1,1
 8b0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b2:	00000517          	auipc	a0,0x0
 8b6:	1a653503          	ld	a0,422(a0) # a58 <freep>
 8ba:	c515                	beqz	a0,8e6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	02977f63          	bgeu	a4,s1,8fe <malloc+0x70>
 8c4:	8a4e                	mv	s4,s3
 8c6:	0009871b          	sext.w	a4,s3
 8ca:	6685                	lui	a3,0x1
 8cc:	00d77363          	bgeu	a4,a3,8d2 <malloc+0x44>
 8d0:	6a05                	lui	s4,0x1
 8d2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8d6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8da:	00000917          	auipc	s2,0x0
 8de:	17e90913          	addi	s2,s2,382 # a58 <freep>
  if(p == (char*)-1)
 8e2:	5afd                	li	s5,-1
 8e4:	a895                	j	958 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8e6:	00000797          	auipc	a5,0x0
 8ea:	17a78793          	addi	a5,a5,378 # a60 <base>
 8ee:	00000717          	auipc	a4,0x0
 8f2:	16f73523          	sd	a5,362(a4) # a58 <freep>
 8f6:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f8:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8fc:	b7e1                	j	8c4 <malloc+0x36>
      if(p->s.size == nunits)
 8fe:	02e48c63          	beq	s1,a4,936 <malloc+0xa8>
        p->s.size -= nunits;
 902:	4137073b          	subw	a4,a4,s3
 906:	c798                	sw	a4,8(a5)
        p += p->s.size;
 908:	02071693          	slli	a3,a4,0x20
 90c:	01c6d713          	srli	a4,a3,0x1c
 910:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 912:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 916:	00000717          	auipc	a4,0x0
 91a:	14a73123          	sd	a0,322(a4) # a58 <freep>
      return (void*)(p + 1);
 91e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 922:	70e2                	ld	ra,56(sp)
 924:	7442                	ld	s0,48(sp)
 926:	74a2                	ld	s1,40(sp)
 928:	7902                	ld	s2,32(sp)
 92a:	69e2                	ld	s3,24(sp)
 92c:	6a42                	ld	s4,16(sp)
 92e:	6aa2                	ld	s5,8(sp)
 930:	6b02                	ld	s6,0(sp)
 932:	6121                	addi	sp,sp,64
 934:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 936:	6398                	ld	a4,0(a5)
 938:	e118                	sd	a4,0(a0)
 93a:	bff1                	j	916 <malloc+0x88>
  hp->s.size = nu;
 93c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 940:	0541                	addi	a0,a0,16
 942:	00000097          	auipc	ra,0x0
 946:	eca080e7          	jalr	-310(ra) # 80c <free>
  return freep;
 94a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 94e:	d971                	beqz	a0,922 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 950:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 952:	4798                	lw	a4,8(a5)
 954:	fa9775e3          	bgeu	a4,s1,8fe <malloc+0x70>
    if(p == freep)
 958:	00093703          	ld	a4,0(s2)
 95c:	853e                	mv	a0,a5
 95e:	fef719e3          	bne	a4,a5,950 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 962:	8552                	mv	a0,s4
 964:	00000097          	auipc	ra,0x0
 968:	ae0080e7          	jalr	-1312(ra) # 444 <sbrk>
  if(p == (char*)-1)
 96c:	fd5518e3          	bne	a0,s5,93c <malloc+0xae>
        return 0;
 970:	4501                	li	a0,0
 972:	bf45                	j	922 <malloc+0x94>
