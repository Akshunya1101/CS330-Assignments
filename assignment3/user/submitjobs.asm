
user/_submitjobs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7151                	addi	sp,sp,-240
   2:	f586                	sd	ra,232(sp)
   4:	f1a2                	sd	s0,224(sp)
   6:	eda6                	sd	s1,216(sp)
   8:	e9ca                	sd	s2,208(sp)
   a:	e5ce                	sd	s3,200(sp)
   c:	e1d2                	sd	s4,192(sp)
   e:	fd56                	sd	s5,184(sp)
  10:	f95a                	sd	s6,176(sp)
  12:	f55e                	sd	s7,168(sp)
  14:	f162                	sd	s8,160(sp)
  16:	ed66                	sd	s9,152(sp)
  18:	e96a                	sd	s10,144(sp)
  1a:	1980                	addi	s0,sp,240
  char buf[128], prio[4], policy[2];
  char **args;
  int i, j, k;

  args = (char**)malloc(sizeof(char*)*16);
  1c:	08000513          	li	a0,128
  20:	00001097          	auipc	ra,0x1
  24:	88c080e7          	jalr	-1908(ra) # 8ac <malloc>
  28:	8caa                	mv	s9,a0
  for (i=0; i<16; i++) args[i] = 0;
  2a:	08050713          	addi	a4,a0,128
  args = (char**)malloc(sizeof(char*)*16);
  2e:	87aa                	mv	a5,a0
  for (i=0; i<16; i++) args[i] = 0;
  30:	0007b023          	sd	zero,0(a5)
  34:	07a1                	addi	a5,a5,8
  36:	fee79de3          	bne	a5,a4,30 <main+0x30>

  gets(buf, sizeof(buf));
  3a:	08000593          	li	a1,128
  3e:	f2040513          	addi	a0,s0,-224
  42:	00000097          	auipc	ra,0x0
  46:	1e4080e7          	jalr	484(ra) # 226 <gets>
  policy[0] = buf[0];
  4a:	f2044783          	lbu	a5,-224(s0)
  4e:	f0f40823          	sb	a5,-240(s0)
  policy[1] = '\0';
  52:	f00408a3          	sb	zero,-239(s0)
  schedpolicy(atoi((const char*)policy));
  56:	f1040513          	addi	a0,s0,-240
  5a:	00000097          	auipc	ra,0x0
  5e:	286080e7          	jalr	646(ra) # 2e0 <atoi>
  62:	00000097          	auipc	ra,0x0
  66:	458080e7          	jalr	1112(ra) # 4ba <schedpolicy>
  while (1) {
     gets(buf, sizeof(buf));
  6a:	f2040b13          	addi	s6,s0,-224
     if(buf[0] == 0) break;
     i=0;
     while (buf[i] != ' ') {
  6e:	02000a13          	li	s4,32
  72:	4c05                	li	s8,1
  74:	416c0c3b          	subw	s8,s8,s6
     k=0;
     while (1) {
	i++;
        j=0;
	if (!args[k]) args[k] = (char*)malloc(sizeof(char)*32);
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  78:	4aa9                	li	s5,10
  7a:	a861                	j	112 <main+0x112>
     i=0;
  7c:	4901                	li	s2,0
  7e:	a0d9                	j	144 <main+0x144>
	if (!args[k]) args[k] = (char*)malloc(sizeof(char)*32);
  80:	8552                	mv	a0,s4
  82:	00001097          	auipc	ra,0x1
  86:	82a080e7          	jalr	-2006(ra) # 8ac <malloc>
  8a:	00abb023          	sd	a0,0(s7)
  8e:	a805                	j	be <main+0xbe>
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  90:	8926                	mv	s2,s1
  92:	86ea                	mv	a3,s10
  94:	a011                	j	98 <main+0x98>
  96:	8926                	mv	s2,s1
           args[k][j] = buf[i];
           i++;
	   j++;
        }
        args[k][j] = '\0';
  98:	0009b783          	ld	a5,0(s3)
  9c:	97b6                	add	a5,a5,a3
  9e:	00078023          	sb	zero,0(a5)
	if (buf[i] == '\n') {
  a2:	0ba1                	addi	s7,s7,8
  a4:	fa090793          	addi	a5,s2,-96
  a8:	97a2                	add	a5,a5,s0
  aa:	f807c783          	lbu	a5,-128(a5)
  ae:	05578763          	beq	a5,s5,fc <main+0xfc>
	i++;
  b2:	0019049b          	addiw	s1,s2,1
	if (!args[k]) args[k] = (char*)malloc(sizeof(char)*32);
  b6:	89de                	mv	s3,s7
  b8:	000bb783          	ld	a5,0(s7)
  bc:	d3f1                	beqz	a5,80 <main+0x80>
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  be:	fa048793          	addi	a5,s1,-96
  c2:	97a2                	add	a5,a5,s0
  c4:	f807c703          	lbu	a4,-128(a5)
  c8:	4781                	li	a5,0
  ca:	fd4703e3          	beq	a4,s4,90 <main+0x90>
  ce:	0007861b          	sext.w	a2,a5
  d2:	86b2                	mv	a3,a2
  d4:	fd5701e3          	beq	a4,s5,96 <main+0x96>
           args[k][j] = buf[i];
  d8:	0009b683          	ld	a3,0(s3)
  dc:	96be                	add	a3,a3,a5
  de:	00e68023          	sb	a4,0(a3)
           i++;
  e2:	2485                	addiw	s1,s1,1
	   j++;
  e4:	0016069b          	addiw	a3,a2,1
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
  e8:	0785                	addi	a5,a5,1
  ea:	00f90733          	add	a4,s2,a5
  ee:	975a                	add	a4,a4,s6
  f0:	00174703          	lbu	a4,1(a4)
  f4:	fd471de3          	bne	a4,s4,ce <main+0xce>
           i++;
  f8:	8926                	mv	s2,s1
  fa:	bf79                	j	98 <main+0x98>
	   break;
	}
	k++;
     }
     if (forkp(atoi((const char*)prio)) == 0) exec(args[0], args);
  fc:	f1840513          	addi	a0,s0,-232
 100:	00000097          	auipc	ra,0x0
 104:	1e0080e7          	jalr	480(ra) # 2e0 <atoi>
 108:	00000097          	auipc	ra,0x0
 10c:	3aa080e7          	jalr	938(ra) # 4b2 <forkp>
 110:	c131                	beqz	a0,154 <main+0x154>
     gets(buf, sizeof(buf));
 112:	08000593          	li	a1,128
 116:	855a                	mv	a0,s6
 118:	00000097          	auipc	ra,0x0
 11c:	10e080e7          	jalr	270(ra) # 226 <gets>
     if(buf[0] == 0) break;
 120:	f2044703          	lbu	a4,-224(s0)
 124:	c321                	beqz	a4,164 <main+0x164>
     while (buf[i] != ' ') {
 126:	f5470be3          	beq	a4,s4,7c <main+0x7c>
 12a:	f1840693          	addi	a3,s0,-232
 12e:	87da                	mv	a5,s6
        prio[i] = buf[i];
 130:	00e68023          	sb	a4,0(a3)
	i++;
 134:	00fc093b          	addw	s2,s8,a5
     while (buf[i] != ' ') {
 138:	0017c703          	lbu	a4,1(a5)
 13c:	0685                	addi	a3,a3,1
 13e:	0785                	addi	a5,a5,1
 140:	ff4718e3          	bne	a4,s4,130 <main+0x130>
     prio[i] = '\0';
 144:	fa090793          	addi	a5,s2,-96
 148:	97a2                	add	a5,a5,s0
 14a:	f6078c23          	sb	zero,-136(a5)
 14e:	8be6                	mv	s7,s9
        while ((buf[i] != ' ') && (buf[i] != '\n')) {
 150:	4d01                	li	s10,0
 152:	b785                	j	b2 <main+0xb2>
     if (forkp(atoi((const char*)prio)) == 0) exec(args[0], args);
 154:	85e6                	mv	a1,s9
 156:	000cb503          	ld	a0,0(s9)
 15a:	00000097          	auipc	ra,0x0
 15e:	2b8080e7          	jalr	696(ra) # 412 <exec>
 162:	bf19                	j	78 <main+0x78>
  }

  exit(0);
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	274080e7          	jalr	628(ra) # 3da <exit>

000000000000016e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 174:	87aa                	mv	a5,a0
 176:	0585                	addi	a1,a1,1
 178:	0785                	addi	a5,a5,1
 17a:	fff5c703          	lbu	a4,-1(a1)
 17e:	fee78fa3          	sb	a4,-1(a5)
 182:	fb75                	bnez	a4,176 <strcpy+0x8>
    ;
  return os;
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret

000000000000018a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 190:	00054783          	lbu	a5,0(a0)
 194:	cb91                	beqz	a5,1a8 <strcmp+0x1e>
 196:	0005c703          	lbu	a4,0(a1)
 19a:	00f71763          	bne	a4,a5,1a8 <strcmp+0x1e>
    p++, q++;
 19e:	0505                	addi	a0,a0,1
 1a0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbe5                	bnez	a5,196 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a8:	0005c503          	lbu	a0,0(a1)
}
 1ac:	40a7853b          	subw	a0,a5,a0
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	addi	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strlen>:

uint
strlen(const char *s)
{
 1b6:	1141                	addi	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cf91                	beqz	a5,1dc <strlen+0x26>
 1c2:	0505                	addi	a0,a0,1
 1c4:	87aa                	mv	a5,a0
 1c6:	4685                	li	a3,1
 1c8:	9e89                	subw	a3,a3,a0
 1ca:	00f6853b          	addw	a0,a3,a5
 1ce:	0785                	addi	a5,a5,1
 1d0:	fff7c703          	lbu	a4,-1(a5)
 1d4:	fb7d                	bnez	a4,1ca <strlen+0x14>
    ;
  return n;
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret
  for(n = 0; s[n]; n++)
 1dc:	4501                	li	a0,0
 1de:	bfe5                	j	1d6 <strlen+0x20>

00000000000001e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e6:	ca19                	beqz	a2,1fc <memset+0x1c>
 1e8:	87aa                	mv	a5,a0
 1ea:	1602                	slli	a2,a2,0x20
 1ec:	9201                	srli	a2,a2,0x20
 1ee:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f6:	0785                	addi	a5,a5,1
 1f8:	fee79de3          	bne	a5,a4,1f2 <memset+0x12>
  }
  return dst;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret

0000000000000202 <strchr>:

char*
strchr(const char *s, char c)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  for(; *s; s++)
 208:	00054783          	lbu	a5,0(a0)
 20c:	cb99                	beqz	a5,222 <strchr+0x20>
    if(*s == c)
 20e:	00f58763          	beq	a1,a5,21c <strchr+0x1a>
  for(; *s; s++)
 212:	0505                	addi	a0,a0,1
 214:	00054783          	lbu	a5,0(a0)
 218:	fbfd                	bnez	a5,20e <strchr+0xc>
      return (char*)s;
  return 0;
 21a:	4501                	li	a0,0
}
 21c:	6422                	ld	s0,8(sp)
 21e:	0141                	addi	sp,sp,16
 220:	8082                	ret
  return 0;
 222:	4501                	li	a0,0
 224:	bfe5                	j	21c <strchr+0x1a>

0000000000000226 <gets>:

char*
gets(char *buf, int max)
{
 226:	711d                	addi	sp,sp,-96
 228:	ec86                	sd	ra,88(sp)
 22a:	e8a2                	sd	s0,80(sp)
 22c:	e4a6                	sd	s1,72(sp)
 22e:	e0ca                	sd	s2,64(sp)
 230:	fc4e                	sd	s3,56(sp)
 232:	f852                	sd	s4,48(sp)
 234:	f456                	sd	s5,40(sp)
 236:	f05a                	sd	s6,32(sp)
 238:	ec5e                	sd	s7,24(sp)
 23a:	1080                	addi	s0,sp,96
 23c:	8baa                	mv	s7,a0
 23e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 240:	892a                	mv	s2,a0
 242:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 244:	4aa9                	li	s5,10
 246:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 248:	89a6                	mv	s3,s1
 24a:	2485                	addiw	s1,s1,1
 24c:	0344d863          	bge	s1,s4,27c <gets+0x56>
    cc = read(0, &c, 1);
 250:	4605                	li	a2,1
 252:	faf40593          	addi	a1,s0,-81
 256:	4501                	li	a0,0
 258:	00000097          	auipc	ra,0x0
 25c:	19a080e7          	jalr	410(ra) # 3f2 <read>
    if(cc < 1)
 260:	00a05e63          	blez	a0,27c <gets+0x56>
    buf[i++] = c;
 264:	faf44783          	lbu	a5,-81(s0)
 268:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 26c:	01578763          	beq	a5,s5,27a <gets+0x54>
 270:	0905                	addi	s2,s2,1
 272:	fd679be3          	bne	a5,s6,248 <gets+0x22>
  for(i=0; i+1 < max; ){
 276:	89a6                	mv	s3,s1
 278:	a011                	j	27c <gets+0x56>
 27a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27c:	99de                	add	s3,s3,s7
 27e:	00098023          	sb	zero,0(s3)
  return buf;
}
 282:	855e                	mv	a0,s7
 284:	60e6                	ld	ra,88(sp)
 286:	6446                	ld	s0,80(sp)
 288:	64a6                	ld	s1,72(sp)
 28a:	6906                	ld	s2,64(sp)
 28c:	79e2                	ld	s3,56(sp)
 28e:	7a42                	ld	s4,48(sp)
 290:	7aa2                	ld	s5,40(sp)
 292:	7b02                	ld	s6,32(sp)
 294:	6be2                	ld	s7,24(sp)
 296:	6125                	addi	sp,sp,96
 298:	8082                	ret

000000000000029a <stat>:

int
stat(const char *n, struct stat *st)
{
 29a:	1101                	addi	sp,sp,-32
 29c:	ec06                	sd	ra,24(sp)
 29e:	e822                	sd	s0,16(sp)
 2a0:	e426                	sd	s1,8(sp)
 2a2:	e04a                	sd	s2,0(sp)
 2a4:	1000                	addi	s0,sp,32
 2a6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a8:	4581                	li	a1,0
 2aa:	00000097          	auipc	ra,0x0
 2ae:	170080e7          	jalr	368(ra) # 41a <open>
  if(fd < 0)
 2b2:	02054563          	bltz	a0,2dc <stat+0x42>
 2b6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b8:	85ca                	mv	a1,s2
 2ba:	00000097          	auipc	ra,0x0
 2be:	178080e7          	jalr	376(ra) # 432 <fstat>
 2c2:	892a                	mv	s2,a0
  close(fd);
 2c4:	8526                	mv	a0,s1
 2c6:	00000097          	auipc	ra,0x0
 2ca:	13c080e7          	jalr	316(ra) # 402 <close>
  return r;
}
 2ce:	854a                	mv	a0,s2
 2d0:	60e2                	ld	ra,24(sp)
 2d2:	6442                	ld	s0,16(sp)
 2d4:	64a2                	ld	s1,8(sp)
 2d6:	6902                	ld	s2,0(sp)
 2d8:	6105                	addi	sp,sp,32
 2da:	8082                	ret
    return -1;
 2dc:	597d                	li	s2,-1
 2de:	bfc5                	j	2ce <stat+0x34>

00000000000002e0 <atoi>:

int
atoi(const char *s)
{
 2e0:	1141                	addi	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e6:	00054683          	lbu	a3,0(a0)
 2ea:	fd06879b          	addiw	a5,a3,-48
 2ee:	0ff7f793          	zext.b	a5,a5
 2f2:	4625                	li	a2,9
 2f4:	02f66863          	bltu	a2,a5,324 <atoi+0x44>
 2f8:	872a                	mv	a4,a0
  n = 0;
 2fa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2fc:	0705                	addi	a4,a4,1
 2fe:	0025179b          	slliw	a5,a0,0x2
 302:	9fa9                	addw	a5,a5,a0
 304:	0017979b          	slliw	a5,a5,0x1
 308:	9fb5                	addw	a5,a5,a3
 30a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30e:	00074683          	lbu	a3,0(a4)
 312:	fd06879b          	addiw	a5,a3,-48
 316:	0ff7f793          	zext.b	a5,a5
 31a:	fef671e3          	bgeu	a2,a5,2fc <atoi+0x1c>
  return n;
}
 31e:	6422                	ld	s0,8(sp)
 320:	0141                	addi	sp,sp,16
 322:	8082                	ret
  n = 0;
 324:	4501                	li	a0,0
 326:	bfe5                	j	31e <atoi+0x3e>

0000000000000328 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 32e:	02b57463          	bgeu	a0,a1,356 <memmove+0x2e>
    while(n-- > 0)
 332:	00c05f63          	blez	a2,350 <memmove+0x28>
 336:	1602                	slli	a2,a2,0x20
 338:	9201                	srli	a2,a2,0x20
 33a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 33e:	872a                	mv	a4,a0
      *dst++ = *src++;
 340:	0585                	addi	a1,a1,1
 342:	0705                	addi	a4,a4,1
 344:	fff5c683          	lbu	a3,-1(a1)
 348:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34c:	fee79ae3          	bne	a5,a4,340 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 350:	6422                	ld	s0,8(sp)
 352:	0141                	addi	sp,sp,16
 354:	8082                	ret
    dst += n;
 356:	00c50733          	add	a4,a0,a2
    src += n;
 35a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35c:	fec05ae3          	blez	a2,350 <memmove+0x28>
 360:	fff6079b          	addiw	a5,a2,-1
 364:	1782                	slli	a5,a5,0x20
 366:	9381                	srli	a5,a5,0x20
 368:	fff7c793          	not	a5,a5
 36c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36e:	15fd                	addi	a1,a1,-1
 370:	177d                	addi	a4,a4,-1
 372:	0005c683          	lbu	a3,0(a1)
 376:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37a:	fee79ae3          	bne	a5,a4,36e <memmove+0x46>
 37e:	bfc9                	j	350 <memmove+0x28>

0000000000000380 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 380:	1141                	addi	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 386:	ca05                	beqz	a2,3b6 <memcmp+0x36>
 388:	fff6069b          	addiw	a3,a2,-1
 38c:	1682                	slli	a3,a3,0x20
 38e:	9281                	srli	a3,a3,0x20
 390:	0685                	addi	a3,a3,1
 392:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 394:	00054783          	lbu	a5,0(a0)
 398:	0005c703          	lbu	a4,0(a1)
 39c:	00e79863          	bne	a5,a4,3ac <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a0:	0505                	addi	a0,a0,1
    p2++;
 3a2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a4:	fed518e3          	bne	a0,a3,394 <memcmp+0x14>
  }
  return 0;
 3a8:	4501                	li	a0,0
 3aa:	a019                	j	3b0 <memcmp+0x30>
      return *p1 - *p2;
 3ac:	40e7853b          	subw	a0,a5,a4
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
  return 0;
 3b6:	4501                	li	a0,0
 3b8:	bfe5                	j	3b0 <memcmp+0x30>

00000000000003ba <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e406                	sd	ra,8(sp)
 3be:	e022                	sd	s0,0(sp)
 3c0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c2:	00000097          	auipc	ra,0x0
 3c6:	f66080e7          	jalr	-154(ra) # 328 <memmove>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d2:	4885                	li	a7,1
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <exit>:
.global exit
exit:
 li a7, SYS_exit
 3da:	4889                	li	a7,2
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e2:	488d                	li	a7,3
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ea:	4891                	li	a7,4
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <read>:
.global read
read:
 li a7, SYS_read
 3f2:	4895                	li	a7,5
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <write>:
.global write
write:
 li a7, SYS_write
 3fa:	48c1                	li	a7,16
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <close>:
.global close
close:
 li a7, SYS_close
 402:	48d5                	li	a7,21
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <kill>:
.global kill
kill:
 li a7, SYS_kill
 40a:	4899                	li	a7,6
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exec>:
.global exec
exec:
 li a7, SYS_exec
 412:	489d                	li	a7,7
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <open>:
.global open
open:
 li a7, SYS_open
 41a:	48bd                	li	a7,15
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 422:	48c5                	li	a7,17
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42a:	48c9                	li	a7,18
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 432:	48a1                	li	a7,8
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <link>:
.global link
link:
 li a7, SYS_link
 43a:	48cd                	li	a7,19
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 442:	48d1                	li	a7,20
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44a:	48a5                	li	a7,9
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <dup>:
.global dup
dup:
 li a7, SYS_dup
 452:	48a9                	li	a7,10
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45a:	48ad                	li	a7,11
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 462:	48b1                	li	a7,12
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46a:	48b5                	li	a7,13
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 472:	48b9                	li	a7,14
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 47a:	48d9                	li	a7,22
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <yield>:
.global yield
yield:
 li a7, SYS_yield
 482:	48dd                	li	a7,23
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 48a:	48e1                	li	a7,24
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 492:	48e5                	li	a7,25
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 49a:	48e9                	li	a7,26
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <ps>:
.global ps
ps:
 li a7, SYS_ps
 4a2:	48ed                	li	a7,27
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 4aa:	48f1                	li	a7,28
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 4b2:	48f5                	li	a7,29
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 4ba:	48f9                	li	a7,30
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 4c2:	02100893          	li	a7,33
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 4cc:	48fd                	li	a7,31
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 4d4:	02000893          	li	a7,32
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 4de:	02200893          	li	a7,34
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 4e8:	02300893          	li	a7,35
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 4f2:	02400893          	li	a7,36
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 4fc:	02500893          	li	a7,37
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 506:	02700893          	li	a7,39
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 510:	02600893          	li	a7,38
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 51a:	1101                	addi	sp,sp,-32
 51c:	ec06                	sd	ra,24(sp)
 51e:	e822                	sd	s0,16(sp)
 520:	1000                	addi	s0,sp,32
 522:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 526:	4605                	li	a2,1
 528:	fef40593          	addi	a1,s0,-17
 52c:	00000097          	auipc	ra,0x0
 530:	ece080e7          	jalr	-306(ra) # 3fa <write>
}
 534:	60e2                	ld	ra,24(sp)
 536:	6442                	ld	s0,16(sp)
 538:	6105                	addi	sp,sp,32
 53a:	8082                	ret

000000000000053c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 53c:	7139                	addi	sp,sp,-64
 53e:	fc06                	sd	ra,56(sp)
 540:	f822                	sd	s0,48(sp)
 542:	f426                	sd	s1,40(sp)
 544:	f04a                	sd	s2,32(sp)
 546:	ec4e                	sd	s3,24(sp)
 548:	0080                	addi	s0,sp,64
 54a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 54c:	c299                	beqz	a3,552 <printint+0x16>
 54e:	0805c963          	bltz	a1,5e0 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 552:	2581                	sext.w	a1,a1
  neg = 0;
 554:	4881                	li	a7,0
 556:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 55a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 55c:	2601                	sext.w	a2,a2
 55e:	00000517          	auipc	a0,0x0
 562:	49a50513          	addi	a0,a0,1178 # 9f8 <digits>
 566:	883a                	mv	a6,a4
 568:	2705                	addiw	a4,a4,1
 56a:	02c5f7bb          	remuw	a5,a1,a2
 56e:	1782                	slli	a5,a5,0x20
 570:	9381                	srli	a5,a5,0x20
 572:	97aa                	add	a5,a5,a0
 574:	0007c783          	lbu	a5,0(a5)
 578:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 57c:	0005879b          	sext.w	a5,a1
 580:	02c5d5bb          	divuw	a1,a1,a2
 584:	0685                	addi	a3,a3,1
 586:	fec7f0e3          	bgeu	a5,a2,566 <printint+0x2a>
  if(neg)
 58a:	00088c63          	beqz	a7,5a2 <printint+0x66>
    buf[i++] = '-';
 58e:	fd070793          	addi	a5,a4,-48
 592:	00878733          	add	a4,a5,s0
 596:	02d00793          	li	a5,45
 59a:	fef70823          	sb	a5,-16(a4)
 59e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5a2:	02e05863          	blez	a4,5d2 <printint+0x96>
 5a6:	fc040793          	addi	a5,s0,-64
 5aa:	00e78933          	add	s2,a5,a4
 5ae:	fff78993          	addi	s3,a5,-1
 5b2:	99ba                	add	s3,s3,a4
 5b4:	377d                	addiw	a4,a4,-1
 5b6:	1702                	slli	a4,a4,0x20
 5b8:	9301                	srli	a4,a4,0x20
 5ba:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5be:	fff94583          	lbu	a1,-1(s2)
 5c2:	8526                	mv	a0,s1
 5c4:	00000097          	auipc	ra,0x0
 5c8:	f56080e7          	jalr	-170(ra) # 51a <putc>
  while(--i >= 0)
 5cc:	197d                	addi	s2,s2,-1
 5ce:	ff3918e3          	bne	s2,s3,5be <printint+0x82>
}
 5d2:	70e2                	ld	ra,56(sp)
 5d4:	7442                	ld	s0,48(sp)
 5d6:	74a2                	ld	s1,40(sp)
 5d8:	7902                	ld	s2,32(sp)
 5da:	69e2                	ld	s3,24(sp)
 5dc:	6121                	addi	sp,sp,64
 5de:	8082                	ret
    x = -xx;
 5e0:	40b005bb          	negw	a1,a1
    neg = 1;
 5e4:	4885                	li	a7,1
    x = -xx;
 5e6:	bf85                	j	556 <printint+0x1a>

00000000000005e8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5e8:	7119                	addi	sp,sp,-128
 5ea:	fc86                	sd	ra,120(sp)
 5ec:	f8a2                	sd	s0,112(sp)
 5ee:	f4a6                	sd	s1,104(sp)
 5f0:	f0ca                	sd	s2,96(sp)
 5f2:	ecce                	sd	s3,88(sp)
 5f4:	e8d2                	sd	s4,80(sp)
 5f6:	e4d6                	sd	s5,72(sp)
 5f8:	e0da                	sd	s6,64(sp)
 5fa:	fc5e                	sd	s7,56(sp)
 5fc:	f862                	sd	s8,48(sp)
 5fe:	f466                	sd	s9,40(sp)
 600:	f06a                	sd	s10,32(sp)
 602:	ec6e                	sd	s11,24(sp)
 604:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 606:	0005c903          	lbu	s2,0(a1)
 60a:	18090f63          	beqz	s2,7a8 <vprintf+0x1c0>
 60e:	8aaa                	mv	s5,a0
 610:	8b32                	mv	s6,a2
 612:	00158493          	addi	s1,a1,1
  state = 0;
 616:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 618:	02500a13          	li	s4,37
 61c:	4c55                	li	s8,21
 61e:	00000c97          	auipc	s9,0x0
 622:	382c8c93          	addi	s9,s9,898 # 9a0 <malloc+0xf4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 626:	02800d93          	li	s11,40
  putc(fd, 'x');
 62a:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 62c:	00000b97          	auipc	s7,0x0
 630:	3ccb8b93          	addi	s7,s7,972 # 9f8 <digits>
 634:	a839                	j	652 <vprintf+0x6a>
        putc(fd, c);
 636:	85ca                	mv	a1,s2
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	ee0080e7          	jalr	-288(ra) # 51a <putc>
 642:	a019                	j	648 <vprintf+0x60>
    } else if(state == '%'){
 644:	01498d63          	beq	s3,s4,65e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 648:	0485                	addi	s1,s1,1
 64a:	fff4c903          	lbu	s2,-1(s1)
 64e:	14090d63          	beqz	s2,7a8 <vprintf+0x1c0>
    if(state == 0){
 652:	fe0999e3          	bnez	s3,644 <vprintf+0x5c>
      if(c == '%'){
 656:	ff4910e3          	bne	s2,s4,636 <vprintf+0x4e>
        state = '%';
 65a:	89d2                	mv	s3,s4
 65c:	b7f5                	j	648 <vprintf+0x60>
      if(c == 'd'){
 65e:	11490c63          	beq	s2,s4,776 <vprintf+0x18e>
 662:	f9d9079b          	addiw	a5,s2,-99
 666:	0ff7f793          	zext.b	a5,a5
 66a:	10fc6e63          	bltu	s8,a5,786 <vprintf+0x19e>
 66e:	f9d9079b          	addiw	a5,s2,-99
 672:	0ff7f713          	zext.b	a4,a5
 676:	10ec6863          	bltu	s8,a4,786 <vprintf+0x19e>
 67a:	00271793          	slli	a5,a4,0x2
 67e:	97e6                	add	a5,a5,s9
 680:	439c                	lw	a5,0(a5)
 682:	97e6                	add	a5,a5,s9
 684:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 686:	008b0913          	addi	s2,s6,8
 68a:	4685                	li	a3,1
 68c:	4629                	li	a2,10
 68e:	000b2583          	lw	a1,0(s6)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	ea8080e7          	jalr	-344(ra) # 53c <printint>
 69c:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	b765                	j	648 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a2:	008b0913          	addi	s2,s6,8
 6a6:	4681                	li	a3,0
 6a8:	4629                	li	a2,10
 6aa:	000b2583          	lw	a1,0(s6)
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e8c080e7          	jalr	-372(ra) # 53c <printint>
 6b8:	8b4a                	mv	s6,s2
      state = 0;
 6ba:	4981                	li	s3,0
 6bc:	b771                	j	648 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6be:	008b0913          	addi	s2,s6,8
 6c2:	4681                	li	a3,0
 6c4:	866a                	mv	a2,s10
 6c6:	000b2583          	lw	a1,0(s6)
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	e70080e7          	jalr	-400(ra) # 53c <printint>
 6d4:	8b4a                	mv	s6,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bf85                	j	648 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6da:	008b0793          	addi	a5,s6,8
 6de:	f8f43423          	sd	a5,-120(s0)
 6e2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6e6:	03000593          	li	a1,48
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	e2e080e7          	jalr	-466(ra) # 51a <putc>
  putc(fd, 'x');
 6f4:	07800593          	li	a1,120
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e20080e7          	jalr	-480(ra) # 51a <putc>
 702:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 704:	03c9d793          	srli	a5,s3,0x3c
 708:	97de                	add	a5,a5,s7
 70a:	0007c583          	lbu	a1,0(a5)
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	e0a080e7          	jalr	-502(ra) # 51a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 718:	0992                	slli	s3,s3,0x4
 71a:	397d                	addiw	s2,s2,-1
 71c:	fe0914e3          	bnez	s2,704 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 720:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 724:	4981                	li	s3,0
 726:	b70d                	j	648 <vprintf+0x60>
        s = va_arg(ap, char*);
 728:	008b0913          	addi	s2,s6,8
 72c:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 730:	02098163          	beqz	s3,752 <vprintf+0x16a>
        while(*s != 0){
 734:	0009c583          	lbu	a1,0(s3)
 738:	c5ad                	beqz	a1,7a2 <vprintf+0x1ba>
          putc(fd, *s);
 73a:	8556                	mv	a0,s5
 73c:	00000097          	auipc	ra,0x0
 740:	dde080e7          	jalr	-546(ra) # 51a <putc>
          s++;
 744:	0985                	addi	s3,s3,1
        while(*s != 0){
 746:	0009c583          	lbu	a1,0(s3)
 74a:	f9e5                	bnez	a1,73a <vprintf+0x152>
        s = va_arg(ap, char*);
 74c:	8b4a                	mv	s6,s2
      state = 0;
 74e:	4981                	li	s3,0
 750:	bde5                	j	648 <vprintf+0x60>
          s = "(null)";
 752:	00000997          	auipc	s3,0x0
 756:	24698993          	addi	s3,s3,582 # 998 <malloc+0xec>
        while(*s != 0){
 75a:	85ee                	mv	a1,s11
 75c:	bff9                	j	73a <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 75e:	008b0913          	addi	s2,s6,8
 762:	000b4583          	lbu	a1,0(s6)
 766:	8556                	mv	a0,s5
 768:	00000097          	auipc	ra,0x0
 76c:	db2080e7          	jalr	-590(ra) # 51a <putc>
 770:	8b4a                	mv	s6,s2
      state = 0;
 772:	4981                	li	s3,0
 774:	bdd1                	j	648 <vprintf+0x60>
        putc(fd, c);
 776:	85d2                	mv	a1,s4
 778:	8556                	mv	a0,s5
 77a:	00000097          	auipc	ra,0x0
 77e:	da0080e7          	jalr	-608(ra) # 51a <putc>
      state = 0;
 782:	4981                	li	s3,0
 784:	b5d1                	j	648 <vprintf+0x60>
        putc(fd, '%');
 786:	85d2                	mv	a1,s4
 788:	8556                	mv	a0,s5
 78a:	00000097          	auipc	ra,0x0
 78e:	d90080e7          	jalr	-624(ra) # 51a <putc>
        putc(fd, c);
 792:	85ca                	mv	a1,s2
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	d84080e7          	jalr	-636(ra) # 51a <putc>
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	b565                	j	648 <vprintf+0x60>
        s = va_arg(ap, char*);
 7a2:	8b4a                	mv	s6,s2
      state = 0;
 7a4:	4981                	li	s3,0
 7a6:	b54d                	j	648 <vprintf+0x60>
    }
  }
}
 7a8:	70e6                	ld	ra,120(sp)
 7aa:	7446                	ld	s0,112(sp)
 7ac:	74a6                	ld	s1,104(sp)
 7ae:	7906                	ld	s2,96(sp)
 7b0:	69e6                	ld	s3,88(sp)
 7b2:	6a46                	ld	s4,80(sp)
 7b4:	6aa6                	ld	s5,72(sp)
 7b6:	6b06                	ld	s6,64(sp)
 7b8:	7be2                	ld	s7,56(sp)
 7ba:	7c42                	ld	s8,48(sp)
 7bc:	7ca2                	ld	s9,40(sp)
 7be:	7d02                	ld	s10,32(sp)
 7c0:	6de2                	ld	s11,24(sp)
 7c2:	6109                	addi	sp,sp,128
 7c4:	8082                	ret

00000000000007c6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7c6:	715d                	addi	sp,sp,-80
 7c8:	ec06                	sd	ra,24(sp)
 7ca:	e822                	sd	s0,16(sp)
 7cc:	1000                	addi	s0,sp,32
 7ce:	e010                	sd	a2,0(s0)
 7d0:	e414                	sd	a3,8(s0)
 7d2:	e818                	sd	a4,16(s0)
 7d4:	ec1c                	sd	a5,24(s0)
 7d6:	03043023          	sd	a6,32(s0)
 7da:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7de:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e2:	8622                	mv	a2,s0
 7e4:	00000097          	auipc	ra,0x0
 7e8:	e04080e7          	jalr	-508(ra) # 5e8 <vprintf>
}
 7ec:	60e2                	ld	ra,24(sp)
 7ee:	6442                	ld	s0,16(sp)
 7f0:	6161                	addi	sp,sp,80
 7f2:	8082                	ret

00000000000007f4 <printf>:

void
printf(const char *fmt, ...)
{
 7f4:	711d                	addi	sp,sp,-96
 7f6:	ec06                	sd	ra,24(sp)
 7f8:	e822                	sd	s0,16(sp)
 7fa:	1000                	addi	s0,sp,32
 7fc:	e40c                	sd	a1,8(s0)
 7fe:	e810                	sd	a2,16(s0)
 800:	ec14                	sd	a3,24(s0)
 802:	f018                	sd	a4,32(s0)
 804:	f41c                	sd	a5,40(s0)
 806:	03043823          	sd	a6,48(s0)
 80a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 80e:	00840613          	addi	a2,s0,8
 812:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 816:	85aa                	mv	a1,a0
 818:	4505                	li	a0,1
 81a:	00000097          	auipc	ra,0x0
 81e:	dce080e7          	jalr	-562(ra) # 5e8 <vprintf>
}
 822:	60e2                	ld	ra,24(sp)
 824:	6442                	ld	s0,16(sp)
 826:	6125                	addi	sp,sp,96
 828:	8082                	ret

000000000000082a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82a:	1141                	addi	sp,sp,-16
 82c:	e422                	sd	s0,8(sp)
 82e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 830:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 834:	00000797          	auipc	a5,0x0
 838:	1dc7b783          	ld	a5,476(a5) # a10 <freep>
 83c:	a02d                	j	866 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 83e:	4618                	lw	a4,8(a2)
 840:	9f2d                	addw	a4,a4,a1
 842:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 846:	6398                	ld	a4,0(a5)
 848:	6310                	ld	a2,0(a4)
 84a:	a83d                	j	888 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84c:	ff852703          	lw	a4,-8(a0)
 850:	9f31                	addw	a4,a4,a2
 852:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 854:	ff053683          	ld	a3,-16(a0)
 858:	a091                	j	89c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85a:	6398                	ld	a4,0(a5)
 85c:	00e7e463          	bltu	a5,a4,864 <free+0x3a>
 860:	00e6ea63          	bltu	a3,a4,874 <free+0x4a>
{
 864:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 866:	fed7fae3          	bgeu	a5,a3,85a <free+0x30>
 86a:	6398                	ld	a4,0(a5)
 86c:	00e6e463          	bltu	a3,a4,874 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 870:	fee7eae3          	bltu	a5,a4,864 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 874:	ff852583          	lw	a1,-8(a0)
 878:	6390                	ld	a2,0(a5)
 87a:	02059813          	slli	a6,a1,0x20
 87e:	01c85713          	srli	a4,a6,0x1c
 882:	9736                	add	a4,a4,a3
 884:	fae60de3          	beq	a2,a4,83e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 888:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 88c:	4790                	lw	a2,8(a5)
 88e:	02061593          	slli	a1,a2,0x20
 892:	01c5d713          	srli	a4,a1,0x1c
 896:	973e                	add	a4,a4,a5
 898:	fae68ae3          	beq	a3,a4,84c <free+0x22>
    p->s.ptr = bp->s.ptr;
 89c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 89e:	00000717          	auipc	a4,0x0
 8a2:	16f73923          	sd	a5,370(a4) # a10 <freep>
}
 8a6:	6422                	ld	s0,8(sp)
 8a8:	0141                	addi	sp,sp,16
 8aa:	8082                	ret

00000000000008ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8ac:	7139                	addi	sp,sp,-64
 8ae:	fc06                	sd	ra,56(sp)
 8b0:	f822                	sd	s0,48(sp)
 8b2:	f426                	sd	s1,40(sp)
 8b4:	f04a                	sd	s2,32(sp)
 8b6:	ec4e                	sd	s3,24(sp)
 8b8:	e852                	sd	s4,16(sp)
 8ba:	e456                	sd	s5,8(sp)
 8bc:	e05a                	sd	s6,0(sp)
 8be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c0:	02051493          	slli	s1,a0,0x20
 8c4:	9081                	srli	s1,s1,0x20
 8c6:	04bd                	addi	s1,s1,15
 8c8:	8091                	srli	s1,s1,0x4
 8ca:	0014899b          	addiw	s3,s1,1
 8ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d0:	00000517          	auipc	a0,0x0
 8d4:	14053503          	ld	a0,320(a0) # a10 <freep>
 8d8:	c515                	beqz	a0,904 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8dc:	4798                	lw	a4,8(a5)
 8de:	02977f63          	bgeu	a4,s1,91c <malloc+0x70>
 8e2:	8a4e                	mv	s4,s3
 8e4:	0009871b          	sext.w	a4,s3
 8e8:	6685                	lui	a3,0x1
 8ea:	00d77363          	bgeu	a4,a3,8f0 <malloc+0x44>
 8ee:	6a05                	lui	s4,0x1
 8f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f8:	00000917          	auipc	s2,0x0
 8fc:	11890913          	addi	s2,s2,280 # a10 <freep>
  if(p == (char*)-1)
 900:	5afd                	li	s5,-1
 902:	a895                	j	976 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 904:	00000797          	auipc	a5,0x0
 908:	11478793          	addi	a5,a5,276 # a18 <base>
 90c:	00000717          	auipc	a4,0x0
 910:	10f73223          	sd	a5,260(a4) # a10 <freep>
 914:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 916:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 91a:	b7e1                	j	8e2 <malloc+0x36>
      if(p->s.size == nunits)
 91c:	02e48c63          	beq	s1,a4,954 <malloc+0xa8>
        p->s.size -= nunits;
 920:	4137073b          	subw	a4,a4,s3
 924:	c798                	sw	a4,8(a5)
        p += p->s.size;
 926:	02071693          	slli	a3,a4,0x20
 92a:	01c6d713          	srli	a4,a3,0x1c
 92e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 930:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 934:	00000717          	auipc	a4,0x0
 938:	0ca73e23          	sd	a0,220(a4) # a10 <freep>
      return (void*)(p + 1);
 93c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 940:	70e2                	ld	ra,56(sp)
 942:	7442                	ld	s0,48(sp)
 944:	74a2                	ld	s1,40(sp)
 946:	7902                	ld	s2,32(sp)
 948:	69e2                	ld	s3,24(sp)
 94a:	6a42                	ld	s4,16(sp)
 94c:	6aa2                	ld	s5,8(sp)
 94e:	6b02                	ld	s6,0(sp)
 950:	6121                	addi	sp,sp,64
 952:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 954:	6398                	ld	a4,0(a5)
 956:	e118                	sd	a4,0(a0)
 958:	bff1                	j	934 <malloc+0x88>
  hp->s.size = nu;
 95a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 95e:	0541                	addi	a0,a0,16
 960:	00000097          	auipc	ra,0x0
 964:	eca080e7          	jalr	-310(ra) # 82a <free>
  return freep;
 968:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 96c:	d971                	beqz	a0,940 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 970:	4798                	lw	a4,8(a5)
 972:	fa9775e3          	bgeu	a4,s1,91c <malloc+0x70>
    if(p == freep)
 976:	00093703          	ld	a4,0(s2)
 97a:	853e                	mv	a0,a5
 97c:	fef719e3          	bne	a4,a5,96e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 980:	8552                	mv	a0,s4
 982:	00000097          	auipc	ra,0x0
 986:	ae0080e7          	jalr	-1312(ra) # 462 <sbrk>
  if(p == (char*)-1)
 98a:	fd5518e3          	bne	a0,s5,95a <malloc+0xae>
        return 0;
 98e:	4501                	li	a0,0
 990:	bf45                	j	940 <malloc+0x94>
