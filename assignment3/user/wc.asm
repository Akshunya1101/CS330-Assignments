
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	addi	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	addi	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4981                	li	s3,0
  l = w = c = 0;
  28:	4c81                	li	s9,0
  2a:	4c01                	li	s8,0
  2c:	4b81                	li	s7,0
  2e:	00001d97          	auipc	s11,0x1
  32:	a5bd8d93          	addi	s11,s11,-1445 # a89 <buf+0x1>
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	988a0a13          	addi	s4,s4,-1656 # 9c0 <malloc+0xec>
        inword = 0;
  40:	4b01                	li	s6,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1e4080e7          	jalr	484(ra) # 22a <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	89da                	mv	s3,s6
    for(i=0; i<n; i++){
  52:	0485                	addi	s1,s1,1
  54:	01248d63          	beq	s1,s2,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2b85                	addiw	s7,s7,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0997e3          	bnez	s3,52 <wc+0x52>
        w++;
  68:	2c05                	addiw	s8,s8,1
        inword = 1;
  6a:	4985                	li	s3,1
  6c:	b7dd                	j	52 <wc+0x52>
      c++;
  6e:	01ac8cbb          	addw	s9,s9,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	00001597          	auipc	a1,0x1
  7a:	a1258593          	addi	a1,a1,-1518 # a88 <buf>
  7e:	f8843503          	ld	a0,-120(s0)
  82:	00000097          	auipc	ra,0x0
  86:	398080e7          	jalr	920(ra) # 41a <read>
  8a:	00a05f63          	blez	a0,a8 <wc+0xa8>
    for(i=0; i<n; i++){
  8e:	00001497          	auipc	s1,0x1
  92:	9fa48493          	addi	s1,s1,-1542 # a88 <buf>
  96:	00050d1b          	sext.w	s10,a0
  9a:	fff5091b          	addiw	s2,a0,-1
  9e:	1902                	slli	s2,s2,0x20
  a0:	02095913          	srli	s2,s2,0x20
  a4:	996e                	add	s2,s2,s11
  a6:	bf4d                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  a8:	02054e63          	bltz	a0,e4 <wc+0xe4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  ac:	f8043703          	ld	a4,-128(s0)
  b0:	86e6                	mv	a3,s9
  b2:	8662                	mv	a2,s8
  b4:	85de                	mv	a1,s7
  b6:	00001517          	auipc	a0,0x1
  ba:	92250513          	addi	a0,a0,-1758 # 9d8 <malloc+0x104>
  be:	00000097          	auipc	ra,0x0
  c2:	75e080e7          	jalr	1886(ra) # 81c <printf>
}
  c6:	70e6                	ld	ra,120(sp)
  c8:	7446                	ld	s0,112(sp)
  ca:	74a6                	ld	s1,104(sp)
  cc:	7906                	ld	s2,96(sp)
  ce:	69e6                	ld	s3,88(sp)
  d0:	6a46                	ld	s4,80(sp)
  d2:	6aa6                	ld	s5,72(sp)
  d4:	6b06                	ld	s6,64(sp)
  d6:	7be2                	ld	s7,56(sp)
  d8:	7c42                	ld	s8,48(sp)
  da:	7ca2                	ld	s9,40(sp)
  dc:	7d02                	ld	s10,32(sp)
  de:	6de2                	ld	s11,24(sp)
  e0:	6109                	addi	sp,sp,128
  e2:	8082                	ret
    printf("wc: read error\n");
  e4:	00001517          	auipc	a0,0x1
  e8:	8e450513          	addi	a0,a0,-1820 # 9c8 <malloc+0xf4>
  ec:	00000097          	auipc	ra,0x0
  f0:	730080e7          	jalr	1840(ra) # 81c <printf>
    exit(1);
  f4:	4505                	li	a0,1
  f6:	00000097          	auipc	ra,0x0
  fa:	30c080e7          	jalr	780(ra) # 402 <exit>

00000000000000fe <main>:

int
main(int argc, char *argv[])
{
  fe:	7179                	addi	sp,sp,-48
 100:	f406                	sd	ra,40(sp)
 102:	f022                	sd	s0,32(sp)
 104:	ec26                	sd	s1,24(sp)
 106:	e84a                	sd	s2,16(sp)
 108:	e44e                	sd	s3,8(sp)
 10a:	e052                	sd	s4,0(sp)
 10c:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
 10e:	4785                	li	a5,1
 110:	04a7d763          	bge	a5,a0,15e <main+0x60>
 114:	00858493          	addi	s1,a1,8
 118:	ffe5099b          	addiw	s3,a0,-2
 11c:	02099793          	slli	a5,s3,0x20
 120:	01d7d993          	srli	s3,a5,0x1d
 124:	05c1                	addi	a1,a1,16
 126:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 128:	4581                	li	a1,0
 12a:	6088                	ld	a0,0(s1)
 12c:	00000097          	auipc	ra,0x0
 130:	316080e7          	jalr	790(ra) # 442 <open>
 134:	892a                	mv	s2,a0
 136:	04054263          	bltz	a0,17a <main+0x7c>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 13a:	608c                	ld	a1,0(s1)
 13c:	00000097          	auipc	ra,0x0
 140:	ec4080e7          	jalr	-316(ra) # 0 <wc>
    close(fd);
 144:	854a                	mv	a0,s2
 146:	00000097          	auipc	ra,0x0
 14a:	2e4080e7          	jalr	740(ra) # 42a <close>
  for(i = 1; i < argc; i++){
 14e:	04a1                	addi	s1,s1,8
 150:	fd349ce3          	bne	s1,s3,128 <main+0x2a>
  }
  exit(0);
 154:	4501                	li	a0,0
 156:	00000097          	auipc	ra,0x0
 15a:	2ac080e7          	jalr	684(ra) # 402 <exit>
    wc(0, "");
 15e:	00001597          	auipc	a1,0x1
 162:	88a58593          	addi	a1,a1,-1910 # 9e8 <malloc+0x114>
 166:	4501                	li	a0,0
 168:	00000097          	auipc	ra,0x0
 16c:	e98080e7          	jalr	-360(ra) # 0 <wc>
    exit(0);
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	290080e7          	jalr	656(ra) # 402 <exit>
      printf("wc: cannot open %s\n", argv[i]);
 17a:	608c                	ld	a1,0(s1)
 17c:	00001517          	auipc	a0,0x1
 180:	87450513          	addi	a0,a0,-1932 # 9f0 <malloc+0x11c>
 184:	00000097          	auipc	ra,0x0
 188:	698080e7          	jalr	1688(ra) # 81c <printf>
      exit(1);
 18c:	4505                	li	a0,1
 18e:	00000097          	auipc	ra,0x0
 192:	274080e7          	jalr	628(ra) # 402 <exit>

0000000000000196 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19c:	87aa                	mv	a5,a0
 19e:	0585                	addi	a1,a1,1
 1a0:	0785                	addi	a5,a5,1
 1a2:	fff5c703          	lbu	a4,-1(a1)
 1a6:	fee78fa3          	sb	a4,-1(a5)
 1aa:	fb75                	bnez	a4,19e <strcpy+0x8>
    ;
  return os;
}
 1ac:	6422                	ld	s0,8(sp)
 1ae:	0141                	addi	sp,sp,16
 1b0:	8082                	ret

00000000000001b2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b2:	1141                	addi	sp,sp,-16
 1b4:	e422                	sd	s0,8(sp)
 1b6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b8:	00054783          	lbu	a5,0(a0)
 1bc:	cb91                	beqz	a5,1d0 <strcmp+0x1e>
 1be:	0005c703          	lbu	a4,0(a1)
 1c2:	00f71763          	bne	a4,a5,1d0 <strcmp+0x1e>
    p++, q++;
 1c6:	0505                	addi	a0,a0,1
 1c8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbe5                	bnez	a5,1be <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d0:	0005c503          	lbu	a0,0(a1)
}
 1d4:	40a7853b          	subw	a0,a5,a0
 1d8:	6422                	ld	s0,8(sp)
 1da:	0141                	addi	sp,sp,16
 1dc:	8082                	ret

00000000000001de <strlen>:

uint
strlen(const char *s)
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e4:	00054783          	lbu	a5,0(a0)
 1e8:	cf91                	beqz	a5,204 <strlen+0x26>
 1ea:	0505                	addi	a0,a0,1
 1ec:	87aa                	mv	a5,a0
 1ee:	4685                	li	a3,1
 1f0:	9e89                	subw	a3,a3,a0
 1f2:	00f6853b          	addw	a0,a3,a5
 1f6:	0785                	addi	a5,a5,1
 1f8:	fff7c703          	lbu	a4,-1(a5)
 1fc:	fb7d                	bnez	a4,1f2 <strlen+0x14>
    ;
  return n;
}
 1fe:	6422                	ld	s0,8(sp)
 200:	0141                	addi	sp,sp,16
 202:	8082                	ret
  for(n = 0; s[n]; n++)
 204:	4501                	li	a0,0
 206:	bfe5                	j	1fe <strlen+0x20>

0000000000000208 <memset>:

void*
memset(void *dst, int c, uint n)
{
 208:	1141                	addi	sp,sp,-16
 20a:	e422                	sd	s0,8(sp)
 20c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 20e:	ca19                	beqz	a2,224 <memset+0x1c>
 210:	87aa                	mv	a5,a0
 212:	1602                	slli	a2,a2,0x20
 214:	9201                	srli	a2,a2,0x20
 216:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21e:	0785                	addi	a5,a5,1
 220:	fee79de3          	bne	a5,a4,21a <memset+0x12>
  }
  return dst;
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret

000000000000022a <strchr>:

char*
strchr(const char *s, char c)
{
 22a:	1141                	addi	sp,sp,-16
 22c:	e422                	sd	s0,8(sp)
 22e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 230:	00054783          	lbu	a5,0(a0)
 234:	cb99                	beqz	a5,24a <strchr+0x20>
    if(*s == c)
 236:	00f58763          	beq	a1,a5,244 <strchr+0x1a>
  for(; *s; s++)
 23a:	0505                	addi	a0,a0,1
 23c:	00054783          	lbu	a5,0(a0)
 240:	fbfd                	bnez	a5,236 <strchr+0xc>
      return (char*)s;
  return 0;
 242:	4501                	li	a0,0
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret
  return 0;
 24a:	4501                	li	a0,0
 24c:	bfe5                	j	244 <strchr+0x1a>

000000000000024e <gets>:

char*
gets(char *buf, int max)
{
 24e:	711d                	addi	sp,sp,-96
 250:	ec86                	sd	ra,88(sp)
 252:	e8a2                	sd	s0,80(sp)
 254:	e4a6                	sd	s1,72(sp)
 256:	e0ca                	sd	s2,64(sp)
 258:	fc4e                	sd	s3,56(sp)
 25a:	f852                	sd	s4,48(sp)
 25c:	f456                	sd	s5,40(sp)
 25e:	f05a                	sd	s6,32(sp)
 260:	ec5e                	sd	s7,24(sp)
 262:	1080                	addi	s0,sp,96
 264:	8baa                	mv	s7,a0
 266:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 268:	892a                	mv	s2,a0
 26a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26c:	4aa9                	li	s5,10
 26e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 270:	89a6                	mv	s3,s1
 272:	2485                	addiw	s1,s1,1
 274:	0344d863          	bge	s1,s4,2a4 <gets+0x56>
    cc = read(0, &c, 1);
 278:	4605                	li	a2,1
 27a:	faf40593          	addi	a1,s0,-81
 27e:	4501                	li	a0,0
 280:	00000097          	auipc	ra,0x0
 284:	19a080e7          	jalr	410(ra) # 41a <read>
    if(cc < 1)
 288:	00a05e63          	blez	a0,2a4 <gets+0x56>
    buf[i++] = c;
 28c:	faf44783          	lbu	a5,-81(s0)
 290:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 294:	01578763          	beq	a5,s5,2a2 <gets+0x54>
 298:	0905                	addi	s2,s2,1
 29a:	fd679be3          	bne	a5,s6,270 <gets+0x22>
  for(i=0; i+1 < max; ){
 29e:	89a6                	mv	s3,s1
 2a0:	a011                	j	2a4 <gets+0x56>
 2a2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a4:	99de                	add	s3,s3,s7
 2a6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2aa:	855e                	mv	a0,s7
 2ac:	60e6                	ld	ra,88(sp)
 2ae:	6446                	ld	s0,80(sp)
 2b0:	64a6                	ld	s1,72(sp)
 2b2:	6906                	ld	s2,64(sp)
 2b4:	79e2                	ld	s3,56(sp)
 2b6:	7a42                	ld	s4,48(sp)
 2b8:	7aa2                	ld	s5,40(sp)
 2ba:	7b02                	ld	s6,32(sp)
 2bc:	6be2                	ld	s7,24(sp)
 2be:	6125                	addi	sp,sp,96
 2c0:	8082                	ret

00000000000002c2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c2:	1101                	addi	sp,sp,-32
 2c4:	ec06                	sd	ra,24(sp)
 2c6:	e822                	sd	s0,16(sp)
 2c8:	e426                	sd	s1,8(sp)
 2ca:	e04a                	sd	s2,0(sp)
 2cc:	1000                	addi	s0,sp,32
 2ce:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d0:	4581                	li	a1,0
 2d2:	00000097          	auipc	ra,0x0
 2d6:	170080e7          	jalr	368(ra) # 442 <open>
  if(fd < 0)
 2da:	02054563          	bltz	a0,304 <stat+0x42>
 2de:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2e0:	85ca                	mv	a1,s2
 2e2:	00000097          	auipc	ra,0x0
 2e6:	178080e7          	jalr	376(ra) # 45a <fstat>
 2ea:	892a                	mv	s2,a0
  close(fd);
 2ec:	8526                	mv	a0,s1
 2ee:	00000097          	auipc	ra,0x0
 2f2:	13c080e7          	jalr	316(ra) # 42a <close>
  return r;
}
 2f6:	854a                	mv	a0,s2
 2f8:	60e2                	ld	ra,24(sp)
 2fa:	6442                	ld	s0,16(sp)
 2fc:	64a2                	ld	s1,8(sp)
 2fe:	6902                	ld	s2,0(sp)
 300:	6105                	addi	sp,sp,32
 302:	8082                	ret
    return -1;
 304:	597d                	li	s2,-1
 306:	bfc5                	j	2f6 <stat+0x34>

0000000000000308 <atoi>:

int
atoi(const char *s)
{
 308:	1141                	addi	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30e:	00054683          	lbu	a3,0(a0)
 312:	fd06879b          	addiw	a5,a3,-48
 316:	0ff7f793          	zext.b	a5,a5
 31a:	4625                	li	a2,9
 31c:	02f66863          	bltu	a2,a5,34c <atoi+0x44>
 320:	872a                	mv	a4,a0
  n = 0;
 322:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 324:	0705                	addi	a4,a4,1
 326:	0025179b          	slliw	a5,a0,0x2
 32a:	9fa9                	addw	a5,a5,a0
 32c:	0017979b          	slliw	a5,a5,0x1
 330:	9fb5                	addw	a5,a5,a3
 332:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 336:	00074683          	lbu	a3,0(a4)
 33a:	fd06879b          	addiw	a5,a3,-48
 33e:	0ff7f793          	zext.b	a5,a5
 342:	fef671e3          	bgeu	a2,a5,324 <atoi+0x1c>
  return n;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  n = 0;
 34c:	4501                	li	a0,0
 34e:	bfe5                	j	346 <atoi+0x3e>

0000000000000350 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e422                	sd	s0,8(sp)
 354:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 356:	02b57463          	bgeu	a0,a1,37e <memmove+0x2e>
    while(n-- > 0)
 35a:	00c05f63          	blez	a2,378 <memmove+0x28>
 35e:	1602                	slli	a2,a2,0x20
 360:	9201                	srli	a2,a2,0x20
 362:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 366:	872a                	mv	a4,a0
      *dst++ = *src++;
 368:	0585                	addi	a1,a1,1
 36a:	0705                	addi	a4,a4,1
 36c:	fff5c683          	lbu	a3,-1(a1)
 370:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 374:	fee79ae3          	bne	a5,a4,368 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 378:	6422                	ld	s0,8(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret
    dst += n;
 37e:	00c50733          	add	a4,a0,a2
    src += n;
 382:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 384:	fec05ae3          	blez	a2,378 <memmove+0x28>
 388:	fff6079b          	addiw	a5,a2,-1
 38c:	1782                	slli	a5,a5,0x20
 38e:	9381                	srli	a5,a5,0x20
 390:	fff7c793          	not	a5,a5
 394:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 396:	15fd                	addi	a1,a1,-1
 398:	177d                	addi	a4,a4,-1
 39a:	0005c683          	lbu	a3,0(a1)
 39e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a2:	fee79ae3          	bne	a5,a4,396 <memmove+0x46>
 3a6:	bfc9                	j	378 <memmove+0x28>

00000000000003a8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e422                	sd	s0,8(sp)
 3ac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ae:	ca05                	beqz	a2,3de <memcmp+0x36>
 3b0:	fff6069b          	addiw	a3,a2,-1
 3b4:	1682                	slli	a3,a3,0x20
 3b6:	9281                	srli	a3,a3,0x20
 3b8:	0685                	addi	a3,a3,1
 3ba:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3bc:	00054783          	lbu	a5,0(a0)
 3c0:	0005c703          	lbu	a4,0(a1)
 3c4:	00e79863          	bne	a5,a4,3d4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3c8:	0505                	addi	a0,a0,1
    p2++;
 3ca:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3cc:	fed518e3          	bne	a0,a3,3bc <memcmp+0x14>
  }
  return 0;
 3d0:	4501                	li	a0,0
 3d2:	a019                	j	3d8 <memcmp+0x30>
      return *p1 - *p2;
 3d4:	40e7853b          	subw	a0,a5,a4
}
 3d8:	6422                	ld	s0,8(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret
  return 0;
 3de:	4501                	li	a0,0
 3e0:	bfe5                	j	3d8 <memcmp+0x30>

00000000000003e2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e2:	1141                	addi	sp,sp,-16
 3e4:	e406                	sd	ra,8(sp)
 3e6:	e022                	sd	s0,0(sp)
 3e8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ea:	00000097          	auipc	ra,0x0
 3ee:	f66080e7          	jalr	-154(ra) # 350 <memmove>
}
 3f2:	60a2                	ld	ra,8(sp)
 3f4:	6402                	ld	s0,0(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret

00000000000003fa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fa:	4885                	li	a7,1
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <exit>:
.global exit
exit:
 li a7, SYS_exit
 402:	4889                	li	a7,2
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <wait>:
.global wait
wait:
 li a7, SYS_wait
 40a:	488d                	li	a7,3
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 412:	4891                	li	a7,4
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <read>:
.global read
read:
 li a7, SYS_read
 41a:	4895                	li	a7,5
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <write>:
.global write
write:
 li a7, SYS_write
 422:	48c1                	li	a7,16
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <close>:
.global close
close:
 li a7, SYS_close
 42a:	48d5                	li	a7,21
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <kill>:
.global kill
kill:
 li a7, SYS_kill
 432:	4899                	li	a7,6
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <exec>:
.global exec
exec:
 li a7, SYS_exec
 43a:	489d                	li	a7,7
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <open>:
.global open
open:
 li a7, SYS_open
 442:	48bd                	li	a7,15
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44a:	48c5                	li	a7,17
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 452:	48c9                	li	a7,18
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45a:	48a1                	li	a7,8
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <link>:
.global link
link:
 li a7, SYS_link
 462:	48cd                	li	a7,19
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46a:	48d1                	li	a7,20
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 472:	48a5                	li	a7,9
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <dup>:
.global dup
dup:
 li a7, SYS_dup
 47a:	48a9                	li	a7,10
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 482:	48ad                	li	a7,11
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 48a:	48b1                	li	a7,12
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 492:	48b5                	li	a7,13
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49a:	48b9                	li	a7,14
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 4a2:	48d9                	li	a7,22
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <yield>:
.global yield
yield:
 li a7, SYS_yield
 4aa:	48dd                	li	a7,23
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 4b2:	48e1                	li	a7,24
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 4ba:	48e5                	li	a7,25
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 4c2:	48e9                	li	a7,26
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <ps>:
.global ps
ps:
 li a7, SYS_ps
 4ca:	48ed                	li	a7,27
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 4d2:	48f1                	li	a7,28
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 4da:	48f5                	li	a7,29
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 4e2:	48f9                	li	a7,30
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 4ea:	02100893          	li	a7,33
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 4f4:	48fd                	li	a7,31
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 4fc:	02000893          	li	a7,32
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 506:	02200893          	li	a7,34
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 510:	02300893          	li	a7,35
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 51a:	02400893          	li	a7,36
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 524:	02500893          	li	a7,37
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 52e:	02700893          	li	a7,39
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 538:	02600893          	li	a7,38
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 542:	1101                	addi	sp,sp,-32
 544:	ec06                	sd	ra,24(sp)
 546:	e822                	sd	s0,16(sp)
 548:	1000                	addi	s0,sp,32
 54a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 54e:	4605                	li	a2,1
 550:	fef40593          	addi	a1,s0,-17
 554:	00000097          	auipc	ra,0x0
 558:	ece080e7          	jalr	-306(ra) # 422 <write>
}
 55c:	60e2                	ld	ra,24(sp)
 55e:	6442                	ld	s0,16(sp)
 560:	6105                	addi	sp,sp,32
 562:	8082                	ret

0000000000000564 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 564:	7139                	addi	sp,sp,-64
 566:	fc06                	sd	ra,56(sp)
 568:	f822                	sd	s0,48(sp)
 56a:	f426                	sd	s1,40(sp)
 56c:	f04a                	sd	s2,32(sp)
 56e:	ec4e                	sd	s3,24(sp)
 570:	0080                	addi	s0,sp,64
 572:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 574:	c299                	beqz	a3,57a <printint+0x16>
 576:	0805c963          	bltz	a1,608 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 57a:	2581                	sext.w	a1,a1
  neg = 0;
 57c:	4881                	li	a7,0
 57e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 582:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 584:	2601                	sext.w	a2,a2
 586:	00000517          	auipc	a0,0x0
 58a:	4e250513          	addi	a0,a0,1250 # a68 <digits>
 58e:	883a                	mv	a6,a4
 590:	2705                	addiw	a4,a4,1
 592:	02c5f7bb          	remuw	a5,a1,a2
 596:	1782                	slli	a5,a5,0x20
 598:	9381                	srli	a5,a5,0x20
 59a:	97aa                	add	a5,a5,a0
 59c:	0007c783          	lbu	a5,0(a5)
 5a0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5a4:	0005879b          	sext.w	a5,a1
 5a8:	02c5d5bb          	divuw	a1,a1,a2
 5ac:	0685                	addi	a3,a3,1
 5ae:	fec7f0e3          	bgeu	a5,a2,58e <printint+0x2a>
  if(neg)
 5b2:	00088c63          	beqz	a7,5ca <printint+0x66>
    buf[i++] = '-';
 5b6:	fd070793          	addi	a5,a4,-48
 5ba:	00878733          	add	a4,a5,s0
 5be:	02d00793          	li	a5,45
 5c2:	fef70823          	sb	a5,-16(a4)
 5c6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ca:	02e05863          	blez	a4,5fa <printint+0x96>
 5ce:	fc040793          	addi	a5,s0,-64
 5d2:	00e78933          	add	s2,a5,a4
 5d6:	fff78993          	addi	s3,a5,-1
 5da:	99ba                	add	s3,s3,a4
 5dc:	377d                	addiw	a4,a4,-1
 5de:	1702                	slli	a4,a4,0x20
 5e0:	9301                	srli	a4,a4,0x20
 5e2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5e6:	fff94583          	lbu	a1,-1(s2)
 5ea:	8526                	mv	a0,s1
 5ec:	00000097          	auipc	ra,0x0
 5f0:	f56080e7          	jalr	-170(ra) # 542 <putc>
  while(--i >= 0)
 5f4:	197d                	addi	s2,s2,-1
 5f6:	ff3918e3          	bne	s2,s3,5e6 <printint+0x82>
}
 5fa:	70e2                	ld	ra,56(sp)
 5fc:	7442                	ld	s0,48(sp)
 5fe:	74a2                	ld	s1,40(sp)
 600:	7902                	ld	s2,32(sp)
 602:	69e2                	ld	s3,24(sp)
 604:	6121                	addi	sp,sp,64
 606:	8082                	ret
    x = -xx;
 608:	40b005bb          	negw	a1,a1
    neg = 1;
 60c:	4885                	li	a7,1
    x = -xx;
 60e:	bf85                	j	57e <printint+0x1a>

0000000000000610 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 610:	7119                	addi	sp,sp,-128
 612:	fc86                	sd	ra,120(sp)
 614:	f8a2                	sd	s0,112(sp)
 616:	f4a6                	sd	s1,104(sp)
 618:	f0ca                	sd	s2,96(sp)
 61a:	ecce                	sd	s3,88(sp)
 61c:	e8d2                	sd	s4,80(sp)
 61e:	e4d6                	sd	s5,72(sp)
 620:	e0da                	sd	s6,64(sp)
 622:	fc5e                	sd	s7,56(sp)
 624:	f862                	sd	s8,48(sp)
 626:	f466                	sd	s9,40(sp)
 628:	f06a                	sd	s10,32(sp)
 62a:	ec6e                	sd	s11,24(sp)
 62c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 62e:	0005c903          	lbu	s2,0(a1)
 632:	18090f63          	beqz	s2,7d0 <vprintf+0x1c0>
 636:	8aaa                	mv	s5,a0
 638:	8b32                	mv	s6,a2
 63a:	00158493          	addi	s1,a1,1
  state = 0;
 63e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 640:	02500a13          	li	s4,37
 644:	4c55                	li	s8,21
 646:	00000c97          	auipc	s9,0x0
 64a:	3cac8c93          	addi	s9,s9,970 # a10 <malloc+0x13c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 64e:	02800d93          	li	s11,40
  putc(fd, 'x');
 652:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 654:	00000b97          	auipc	s7,0x0
 658:	414b8b93          	addi	s7,s7,1044 # a68 <digits>
 65c:	a839                	j	67a <vprintf+0x6a>
        putc(fd, c);
 65e:	85ca                	mv	a1,s2
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	ee0080e7          	jalr	-288(ra) # 542 <putc>
 66a:	a019                	j	670 <vprintf+0x60>
    } else if(state == '%'){
 66c:	01498d63          	beq	s3,s4,686 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 670:	0485                	addi	s1,s1,1
 672:	fff4c903          	lbu	s2,-1(s1)
 676:	14090d63          	beqz	s2,7d0 <vprintf+0x1c0>
    if(state == 0){
 67a:	fe0999e3          	bnez	s3,66c <vprintf+0x5c>
      if(c == '%'){
 67e:	ff4910e3          	bne	s2,s4,65e <vprintf+0x4e>
        state = '%';
 682:	89d2                	mv	s3,s4
 684:	b7f5                	j	670 <vprintf+0x60>
      if(c == 'd'){
 686:	11490c63          	beq	s2,s4,79e <vprintf+0x18e>
 68a:	f9d9079b          	addiw	a5,s2,-99
 68e:	0ff7f793          	zext.b	a5,a5
 692:	10fc6e63          	bltu	s8,a5,7ae <vprintf+0x19e>
 696:	f9d9079b          	addiw	a5,s2,-99
 69a:	0ff7f713          	zext.b	a4,a5
 69e:	10ec6863          	bltu	s8,a4,7ae <vprintf+0x19e>
 6a2:	00271793          	slli	a5,a4,0x2
 6a6:	97e6                	add	a5,a5,s9
 6a8:	439c                	lw	a5,0(a5)
 6aa:	97e6                	add	a5,a5,s9
 6ac:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6ae:	008b0913          	addi	s2,s6,8
 6b2:	4685                	li	a3,1
 6b4:	4629                	li	a2,10
 6b6:	000b2583          	lw	a1,0(s6)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	ea8080e7          	jalr	-344(ra) # 564 <printint>
 6c4:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b765                	j	670 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	008b0913          	addi	s2,s6,8
 6ce:	4681                	li	a3,0
 6d0:	4629                	li	a2,10
 6d2:	000b2583          	lw	a1,0(s6)
 6d6:	8556                	mv	a0,s5
 6d8:	00000097          	auipc	ra,0x0
 6dc:	e8c080e7          	jalr	-372(ra) # 564 <printint>
 6e0:	8b4a                	mv	s6,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	b771                	j	670 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6e6:	008b0913          	addi	s2,s6,8
 6ea:	4681                	li	a3,0
 6ec:	866a                	mv	a2,s10
 6ee:	000b2583          	lw	a1,0(s6)
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	e70080e7          	jalr	-400(ra) # 564 <printint>
 6fc:	8b4a                	mv	s6,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bf85                	j	670 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 702:	008b0793          	addi	a5,s6,8
 706:	f8f43423          	sd	a5,-120(s0)
 70a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 70e:	03000593          	li	a1,48
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e2e080e7          	jalr	-466(ra) # 542 <putc>
  putc(fd, 'x');
 71c:	07800593          	li	a1,120
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	e20080e7          	jalr	-480(ra) # 542 <putc>
 72a:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72c:	03c9d793          	srli	a5,s3,0x3c
 730:	97de                	add	a5,a5,s7
 732:	0007c583          	lbu	a1,0(a5)
 736:	8556                	mv	a0,s5
 738:	00000097          	auipc	ra,0x0
 73c:	e0a080e7          	jalr	-502(ra) # 542 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 740:	0992                	slli	s3,s3,0x4
 742:	397d                	addiw	s2,s2,-1
 744:	fe0914e3          	bnez	s2,72c <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 748:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b70d                	j	670 <vprintf+0x60>
        s = va_arg(ap, char*);
 750:	008b0913          	addi	s2,s6,8
 754:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 758:	02098163          	beqz	s3,77a <vprintf+0x16a>
        while(*s != 0){
 75c:	0009c583          	lbu	a1,0(s3)
 760:	c5ad                	beqz	a1,7ca <vprintf+0x1ba>
          putc(fd, *s);
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	dde080e7          	jalr	-546(ra) # 542 <putc>
          s++;
 76c:	0985                	addi	s3,s3,1
        while(*s != 0){
 76e:	0009c583          	lbu	a1,0(s3)
 772:	f9e5                	bnez	a1,762 <vprintf+0x152>
        s = va_arg(ap, char*);
 774:	8b4a                	mv	s6,s2
      state = 0;
 776:	4981                	li	s3,0
 778:	bde5                	j	670 <vprintf+0x60>
          s = "(null)";
 77a:	00000997          	auipc	s3,0x0
 77e:	28e98993          	addi	s3,s3,654 # a08 <malloc+0x134>
        while(*s != 0){
 782:	85ee                	mv	a1,s11
 784:	bff9                	j	762 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 786:	008b0913          	addi	s2,s6,8
 78a:	000b4583          	lbu	a1,0(s6)
 78e:	8556                	mv	a0,s5
 790:	00000097          	auipc	ra,0x0
 794:	db2080e7          	jalr	-590(ra) # 542 <putc>
 798:	8b4a                	mv	s6,s2
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bdd1                	j	670 <vprintf+0x60>
        putc(fd, c);
 79e:	85d2                	mv	a1,s4
 7a0:	8556                	mv	a0,s5
 7a2:	00000097          	auipc	ra,0x0
 7a6:	da0080e7          	jalr	-608(ra) # 542 <putc>
      state = 0;
 7aa:	4981                	li	s3,0
 7ac:	b5d1                	j	670 <vprintf+0x60>
        putc(fd, '%');
 7ae:	85d2                	mv	a1,s4
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	d90080e7          	jalr	-624(ra) # 542 <putc>
        putc(fd, c);
 7ba:	85ca                	mv	a1,s2
 7bc:	8556                	mv	a0,s5
 7be:	00000097          	auipc	ra,0x0
 7c2:	d84080e7          	jalr	-636(ra) # 542 <putc>
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	b565                	j	670 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ca:	8b4a                	mv	s6,s2
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b54d                	j	670 <vprintf+0x60>
    }
  }
}
 7d0:	70e6                	ld	ra,120(sp)
 7d2:	7446                	ld	s0,112(sp)
 7d4:	74a6                	ld	s1,104(sp)
 7d6:	7906                	ld	s2,96(sp)
 7d8:	69e6                	ld	s3,88(sp)
 7da:	6a46                	ld	s4,80(sp)
 7dc:	6aa6                	ld	s5,72(sp)
 7de:	6b06                	ld	s6,64(sp)
 7e0:	7be2                	ld	s7,56(sp)
 7e2:	7c42                	ld	s8,48(sp)
 7e4:	7ca2                	ld	s9,40(sp)
 7e6:	7d02                	ld	s10,32(sp)
 7e8:	6de2                	ld	s11,24(sp)
 7ea:	6109                	addi	sp,sp,128
 7ec:	8082                	ret

00000000000007ee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ee:	715d                	addi	sp,sp,-80
 7f0:	ec06                	sd	ra,24(sp)
 7f2:	e822                	sd	s0,16(sp)
 7f4:	1000                	addi	s0,sp,32
 7f6:	e010                	sd	a2,0(s0)
 7f8:	e414                	sd	a3,8(s0)
 7fa:	e818                	sd	a4,16(s0)
 7fc:	ec1c                	sd	a5,24(s0)
 7fe:	03043023          	sd	a6,32(s0)
 802:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 806:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 80a:	8622                	mv	a2,s0
 80c:	00000097          	auipc	ra,0x0
 810:	e04080e7          	jalr	-508(ra) # 610 <vprintf>
}
 814:	60e2                	ld	ra,24(sp)
 816:	6442                	ld	s0,16(sp)
 818:	6161                	addi	sp,sp,80
 81a:	8082                	ret

000000000000081c <printf>:

void
printf(const char *fmt, ...)
{
 81c:	711d                	addi	sp,sp,-96
 81e:	ec06                	sd	ra,24(sp)
 820:	e822                	sd	s0,16(sp)
 822:	1000                	addi	s0,sp,32
 824:	e40c                	sd	a1,8(s0)
 826:	e810                	sd	a2,16(s0)
 828:	ec14                	sd	a3,24(s0)
 82a:	f018                	sd	a4,32(s0)
 82c:	f41c                	sd	a5,40(s0)
 82e:	03043823          	sd	a6,48(s0)
 832:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 836:	00840613          	addi	a2,s0,8
 83a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 83e:	85aa                	mv	a1,a0
 840:	4505                	li	a0,1
 842:	00000097          	auipc	ra,0x0
 846:	dce080e7          	jalr	-562(ra) # 610 <vprintf>
}
 84a:	60e2                	ld	ra,24(sp)
 84c:	6442                	ld	s0,16(sp)
 84e:	6125                	addi	sp,sp,96
 850:	8082                	ret

0000000000000852 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 852:	1141                	addi	sp,sp,-16
 854:	e422                	sd	s0,8(sp)
 856:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 858:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85c:	00000797          	auipc	a5,0x0
 860:	2247b783          	ld	a5,548(a5) # a80 <freep>
 864:	a02d                	j	88e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 866:	4618                	lw	a4,8(a2)
 868:	9f2d                	addw	a4,a4,a1
 86a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 86e:	6398                	ld	a4,0(a5)
 870:	6310                	ld	a2,0(a4)
 872:	a83d                	j	8b0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 874:	ff852703          	lw	a4,-8(a0)
 878:	9f31                	addw	a4,a4,a2
 87a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 87c:	ff053683          	ld	a3,-16(a0)
 880:	a091                	j	8c4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 882:	6398                	ld	a4,0(a5)
 884:	00e7e463          	bltu	a5,a4,88c <free+0x3a>
 888:	00e6ea63          	bltu	a3,a4,89c <free+0x4a>
{
 88c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88e:	fed7fae3          	bgeu	a5,a3,882 <free+0x30>
 892:	6398                	ld	a4,0(a5)
 894:	00e6e463          	bltu	a3,a4,89c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 898:	fee7eae3          	bltu	a5,a4,88c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 89c:	ff852583          	lw	a1,-8(a0)
 8a0:	6390                	ld	a2,0(a5)
 8a2:	02059813          	slli	a6,a1,0x20
 8a6:	01c85713          	srli	a4,a6,0x1c
 8aa:	9736                	add	a4,a4,a3
 8ac:	fae60de3          	beq	a2,a4,866 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8b0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8b4:	4790                	lw	a2,8(a5)
 8b6:	02061593          	slli	a1,a2,0x20
 8ba:	01c5d713          	srli	a4,a1,0x1c
 8be:	973e                	add	a4,a4,a5
 8c0:	fae68ae3          	beq	a3,a4,874 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8c4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8c6:	00000717          	auipc	a4,0x0
 8ca:	1af73d23          	sd	a5,442(a4) # a80 <freep>
}
 8ce:	6422                	ld	s0,8(sp)
 8d0:	0141                	addi	sp,sp,16
 8d2:	8082                	ret

00000000000008d4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d4:	7139                	addi	sp,sp,-64
 8d6:	fc06                	sd	ra,56(sp)
 8d8:	f822                	sd	s0,48(sp)
 8da:	f426                	sd	s1,40(sp)
 8dc:	f04a                	sd	s2,32(sp)
 8de:	ec4e                	sd	s3,24(sp)
 8e0:	e852                	sd	s4,16(sp)
 8e2:	e456                	sd	s5,8(sp)
 8e4:	e05a                	sd	s6,0(sp)
 8e6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e8:	02051493          	slli	s1,a0,0x20
 8ec:	9081                	srli	s1,s1,0x20
 8ee:	04bd                	addi	s1,s1,15
 8f0:	8091                	srli	s1,s1,0x4
 8f2:	0014899b          	addiw	s3,s1,1
 8f6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8f8:	00000517          	auipc	a0,0x0
 8fc:	18853503          	ld	a0,392(a0) # a80 <freep>
 900:	c515                	beqz	a0,92c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 902:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 904:	4798                	lw	a4,8(a5)
 906:	02977f63          	bgeu	a4,s1,944 <malloc+0x70>
 90a:	8a4e                	mv	s4,s3
 90c:	0009871b          	sext.w	a4,s3
 910:	6685                	lui	a3,0x1
 912:	00d77363          	bgeu	a4,a3,918 <malloc+0x44>
 916:	6a05                	lui	s4,0x1
 918:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 91c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 920:	00000917          	auipc	s2,0x0
 924:	16090913          	addi	s2,s2,352 # a80 <freep>
  if(p == (char*)-1)
 928:	5afd                	li	s5,-1
 92a:	a895                	j	99e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 92c:	00000797          	auipc	a5,0x0
 930:	35c78793          	addi	a5,a5,860 # c88 <base>
 934:	00000717          	auipc	a4,0x0
 938:	14f73623          	sd	a5,332(a4) # a80 <freep>
 93c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 93e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 942:	b7e1                	j	90a <malloc+0x36>
      if(p->s.size == nunits)
 944:	02e48c63          	beq	s1,a4,97c <malloc+0xa8>
        p->s.size -= nunits;
 948:	4137073b          	subw	a4,a4,s3
 94c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 94e:	02071693          	slli	a3,a4,0x20
 952:	01c6d713          	srli	a4,a3,0x1c
 956:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 958:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 95c:	00000717          	auipc	a4,0x0
 960:	12a73223          	sd	a0,292(a4) # a80 <freep>
      return (void*)(p + 1);
 964:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 968:	70e2                	ld	ra,56(sp)
 96a:	7442                	ld	s0,48(sp)
 96c:	74a2                	ld	s1,40(sp)
 96e:	7902                	ld	s2,32(sp)
 970:	69e2                	ld	s3,24(sp)
 972:	6a42                	ld	s4,16(sp)
 974:	6aa2                	ld	s5,8(sp)
 976:	6b02                	ld	s6,0(sp)
 978:	6121                	addi	sp,sp,64
 97a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 97c:	6398                	ld	a4,0(a5)
 97e:	e118                	sd	a4,0(a0)
 980:	bff1                	j	95c <malloc+0x88>
  hp->s.size = nu;
 982:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 986:	0541                	addi	a0,a0,16
 988:	00000097          	auipc	ra,0x0
 98c:	eca080e7          	jalr	-310(ra) # 852 <free>
  return freep;
 990:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 994:	d971                	beqz	a0,968 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 996:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 998:	4798                	lw	a4,8(a5)
 99a:	fa9775e3          	bgeu	a4,s1,944 <malloc+0x70>
    if(p == freep)
 99e:	00093703          	ld	a4,0(s2)
 9a2:	853e                	mv	a0,a5
 9a4:	fef719e3          	bne	a4,a5,996 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9a8:	8552                	mv	a0,s4
 9aa:	00000097          	auipc	ra,0x0
 9ae:	ae0080e7          	jalr	-1312(ra) # 48a <sbrk>
  if(p == (char*)-1)
 9b2:	fd5518e3          	bne	a0,s5,982 <malloc+0xae>
        return 0;
 9b6:	4501                	li	a0,0
 9b8:	bf45                	j	968 <malloc+0x94>
