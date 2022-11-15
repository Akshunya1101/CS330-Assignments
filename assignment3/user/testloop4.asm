
user/_testloop4:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#define INNER_BOUND 10000000
#define SIZE 100

int
main(int argc, char *argv[])
{
   0:	7105                	addi	sp,sp,-480
   2:	ef86                	sd	ra,472(sp)
   4:	eba2                	sd	s0,464(sp)
   6:	e7a6                	sd	s1,456(sp)
   8:	e3ca                	sd	s2,448(sp)
   a:	ff4e                	sd	s3,440(sp)
   c:	fb52                	sd	s4,432(sp)
   e:	f756                	sd	s5,424(sp)
  10:	f35a                	sd	s6,416(sp)
  12:	ef5e                	sd	s7,408(sp)
  14:	1380                	addi	s0,sp,480
    int array[SIZE], i, j, k, sum=0, pid=getpid();
  16:	00000097          	auipc	ra,0x0
  1a:	382080e7          	jalr	898(ra) # 398 <getpid>
  1e:	8baa                	mv	s7,a0
    unsigned start_time, end_time;

    start_time = uptime();
  20:	00000097          	auipc	ra,0x0
  24:	390080e7          	jalr	912(ra) # 3b0 <uptime>
  28:	0005099b          	sext.w	s3,a0
  2c:	4a15                	li	s4,5
    int array[SIZE], i, j, k, sum=0, pid=getpid();
  2e:	4481                	li	s1,0
{
  30:	009897b7          	lui	a5,0x989
  34:	68078b13          	addi	s6,a5,1664 # 989680 <__global_pointer$+0x9884f7>
  38:	fb040913          	addi	s2,s0,-80
    for (k=0; k<OUTER_BOUND; k++) {
       for (j=0; j<INNER_BOUND; j++) for (i=0; i<SIZE; i++) sum += array[i];
       fprintf(1, "%d", pid);
  3c:	00001a97          	auipc	s5,0x1
  40:	894a8a93          	addi	s5,s5,-1900 # 8d0 <malloc+0xe6>
{
  44:	86da                	mv	a3,s6
       for (j=0; j<INNER_BOUND; j++) for (i=0; i<SIZE; i++) sum += array[i];
  46:	e2040793          	addi	a5,s0,-480
  4a:	4398                	lw	a4,0(a5)
  4c:	9cb9                	addw	s1,s1,a4
  4e:	0791                	addi	a5,a5,4
  50:	ff279de3          	bne	a5,s2,4a <main+0x4a>
  54:	36fd                	addiw	a3,a3,-1
  56:	fae5                	bnez	a3,46 <main+0x46>
       fprintf(1, "%d", pid);
  58:	865e                	mv	a2,s7
  5a:	85d6                	mv	a1,s5
  5c:	4505                	li	a0,1
  5e:	00000097          	auipc	ra,0x0
  62:	6a6080e7          	jalr	1702(ra) # 704 <fprintf>
    for (k=0; k<OUTER_BOUND; k++) {
  66:	3a7d                	addiw	s4,s4,-1
  68:	fc0a1ee3          	bnez	s4,44 <main+0x44>
    }
    end_time = uptime();
  6c:	00000097          	auipc	ra,0x0
  70:	344080e7          	jalr	836(ra) # 3b0 <uptime>
  74:	0005091b          	sext.w	s2,a0
    printf("\nTotal sum: %d\n", sum);
  78:	85a6                	mv	a1,s1
  7a:	00001517          	auipc	a0,0x1
  7e:	85e50513          	addi	a0,a0,-1954 # 8d8 <malloc+0xee>
  82:	00000097          	auipc	ra,0x0
  86:	6b0080e7          	jalr	1712(ra) # 732 <printf>
    printf("Start time: %d, End time: %d, Total time: %d\n", start_time, end_time, end_time-start_time);
  8a:	413906bb          	subw	a3,s2,s3
  8e:	864a                	mv	a2,s2
  90:	85ce                	mv	a1,s3
  92:	00001517          	auipc	a0,0x1
  96:	85650513          	addi	a0,a0,-1962 # 8e8 <malloc+0xfe>
  9a:	00000097          	auipc	ra,0x0
  9e:	698080e7          	jalr	1688(ra) # 732 <printf>
    exit(0);
  a2:	4501                	li	a0,0
  a4:	00000097          	auipc	ra,0x0
  a8:	274080e7          	jalr	628(ra) # 318 <exit>

00000000000000ac <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  ac:	1141                	addi	sp,sp,-16
  ae:	e422                	sd	s0,8(sp)
  b0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  b2:	87aa                	mv	a5,a0
  b4:	0585                	addi	a1,a1,1
  b6:	0785                	addi	a5,a5,1
  b8:	fff5c703          	lbu	a4,-1(a1)
  bc:	fee78fa3          	sb	a4,-1(a5)
  c0:	fb75                	bnez	a4,b4 <strcpy+0x8>
    ;
  return os;
}
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret

00000000000000c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	cb91                	beqz	a5,e6 <strcmp+0x1e>
  d4:	0005c703          	lbu	a4,0(a1)
  d8:	00f71763          	bne	a4,a5,e6 <strcmp+0x1e>
    p++, q++;
  dc:	0505                	addi	a0,a0,1
  de:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	fbe5                	bnez	a5,d4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e6:	0005c503          	lbu	a0,0(a1)
}
  ea:	40a7853b          	subw	a0,a5,a0
  ee:	6422                	ld	s0,8(sp)
  f0:	0141                	addi	sp,sp,16
  f2:	8082                	ret

00000000000000f4 <strlen>:

uint
strlen(const char *s)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  fa:	00054783          	lbu	a5,0(a0)
  fe:	cf91                	beqz	a5,11a <strlen+0x26>
 100:	0505                	addi	a0,a0,1
 102:	87aa                	mv	a5,a0
 104:	4685                	li	a3,1
 106:	9e89                	subw	a3,a3,a0
 108:	00f6853b          	addw	a0,a3,a5
 10c:	0785                	addi	a5,a5,1
 10e:	fff7c703          	lbu	a4,-1(a5)
 112:	fb7d                	bnez	a4,108 <strlen+0x14>
    ;
  return n;
}
 114:	6422                	ld	s0,8(sp)
 116:	0141                	addi	sp,sp,16
 118:	8082                	ret
  for(n = 0; s[n]; n++)
 11a:	4501                	li	a0,0
 11c:	bfe5                	j	114 <strlen+0x20>

000000000000011e <memset>:

void*
memset(void *dst, int c, uint n)
{
 11e:	1141                	addi	sp,sp,-16
 120:	e422                	sd	s0,8(sp)
 122:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 124:	ca19                	beqz	a2,13a <memset+0x1c>
 126:	87aa                	mv	a5,a0
 128:	1602                	slli	a2,a2,0x20
 12a:	9201                	srli	a2,a2,0x20
 12c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 130:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 134:	0785                	addi	a5,a5,1
 136:	fee79de3          	bne	a5,a4,130 <memset+0x12>
  }
  return dst;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strchr>:

char*
strchr(const char *s, char c)
{
 140:	1141                	addi	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	addi	s0,sp,16
  for(; *s; s++)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cb99                	beqz	a5,160 <strchr+0x20>
    if(*s == c)
 14c:	00f58763          	beq	a1,a5,15a <strchr+0x1a>
  for(; *s; s++)
 150:	0505                	addi	a0,a0,1
 152:	00054783          	lbu	a5,0(a0)
 156:	fbfd                	bnez	a5,14c <strchr+0xc>
      return (char*)s;
  return 0;
 158:	4501                	li	a0,0
}
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret
  return 0;
 160:	4501                	li	a0,0
 162:	bfe5                	j	15a <strchr+0x1a>

0000000000000164 <gets>:

char*
gets(char *buf, int max)
{
 164:	711d                	addi	sp,sp,-96
 166:	ec86                	sd	ra,88(sp)
 168:	e8a2                	sd	s0,80(sp)
 16a:	e4a6                	sd	s1,72(sp)
 16c:	e0ca                	sd	s2,64(sp)
 16e:	fc4e                	sd	s3,56(sp)
 170:	f852                	sd	s4,48(sp)
 172:	f456                	sd	s5,40(sp)
 174:	f05a                	sd	s6,32(sp)
 176:	ec5e                	sd	s7,24(sp)
 178:	1080                	addi	s0,sp,96
 17a:	8baa                	mv	s7,a0
 17c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17e:	892a                	mv	s2,a0
 180:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 182:	4aa9                	li	s5,10
 184:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 186:	89a6                	mv	s3,s1
 188:	2485                	addiw	s1,s1,1
 18a:	0344d863          	bge	s1,s4,1ba <gets+0x56>
    cc = read(0, &c, 1);
 18e:	4605                	li	a2,1
 190:	faf40593          	addi	a1,s0,-81
 194:	4501                	li	a0,0
 196:	00000097          	auipc	ra,0x0
 19a:	19a080e7          	jalr	410(ra) # 330 <read>
    if(cc < 1)
 19e:	00a05e63          	blez	a0,1ba <gets+0x56>
    buf[i++] = c;
 1a2:	faf44783          	lbu	a5,-81(s0)
 1a6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1aa:	01578763          	beq	a5,s5,1b8 <gets+0x54>
 1ae:	0905                	addi	s2,s2,1
 1b0:	fd679be3          	bne	a5,s6,186 <gets+0x22>
  for(i=0; i+1 < max; ){
 1b4:	89a6                	mv	s3,s1
 1b6:	a011                	j	1ba <gets+0x56>
 1b8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ba:	99de                	add	s3,s3,s7
 1bc:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c0:	855e                	mv	a0,s7
 1c2:	60e6                	ld	ra,88(sp)
 1c4:	6446                	ld	s0,80(sp)
 1c6:	64a6                	ld	s1,72(sp)
 1c8:	6906                	ld	s2,64(sp)
 1ca:	79e2                	ld	s3,56(sp)
 1cc:	7a42                	ld	s4,48(sp)
 1ce:	7aa2                	ld	s5,40(sp)
 1d0:	7b02                	ld	s6,32(sp)
 1d2:	6be2                	ld	s7,24(sp)
 1d4:	6125                	addi	sp,sp,96
 1d6:	8082                	ret

00000000000001d8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d8:	1101                	addi	sp,sp,-32
 1da:	ec06                	sd	ra,24(sp)
 1dc:	e822                	sd	s0,16(sp)
 1de:	e426                	sd	s1,8(sp)
 1e0:	e04a                	sd	s2,0(sp)
 1e2:	1000                	addi	s0,sp,32
 1e4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e6:	4581                	li	a1,0
 1e8:	00000097          	auipc	ra,0x0
 1ec:	170080e7          	jalr	368(ra) # 358 <open>
  if(fd < 0)
 1f0:	02054563          	bltz	a0,21a <stat+0x42>
 1f4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f6:	85ca                	mv	a1,s2
 1f8:	00000097          	auipc	ra,0x0
 1fc:	178080e7          	jalr	376(ra) # 370 <fstat>
 200:	892a                	mv	s2,a0
  close(fd);
 202:	8526                	mv	a0,s1
 204:	00000097          	auipc	ra,0x0
 208:	13c080e7          	jalr	316(ra) # 340 <close>
  return r;
}
 20c:	854a                	mv	a0,s2
 20e:	60e2                	ld	ra,24(sp)
 210:	6442                	ld	s0,16(sp)
 212:	64a2                	ld	s1,8(sp)
 214:	6902                	ld	s2,0(sp)
 216:	6105                	addi	sp,sp,32
 218:	8082                	ret
    return -1;
 21a:	597d                	li	s2,-1
 21c:	bfc5                	j	20c <stat+0x34>

000000000000021e <atoi>:

int
atoi(const char *s)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e422                	sd	s0,8(sp)
 222:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 224:	00054683          	lbu	a3,0(a0)
 228:	fd06879b          	addiw	a5,a3,-48
 22c:	0ff7f793          	zext.b	a5,a5
 230:	4625                	li	a2,9
 232:	02f66863          	bltu	a2,a5,262 <atoi+0x44>
 236:	872a                	mv	a4,a0
  n = 0;
 238:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 23a:	0705                	addi	a4,a4,1
 23c:	0025179b          	slliw	a5,a0,0x2
 240:	9fa9                	addw	a5,a5,a0
 242:	0017979b          	slliw	a5,a5,0x1
 246:	9fb5                	addw	a5,a5,a3
 248:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 24c:	00074683          	lbu	a3,0(a4)
 250:	fd06879b          	addiw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	fef671e3          	bgeu	a2,a5,23a <atoi+0x1c>
  return n;
}
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
  n = 0;
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <atoi+0x3e>

0000000000000266 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 266:	1141                	addi	sp,sp,-16
 268:	e422                	sd	s0,8(sp)
 26a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26c:	02b57463          	bgeu	a0,a1,294 <memmove+0x2e>
    while(n-- > 0)
 270:	00c05f63          	blez	a2,28e <memmove+0x28>
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27c:	872a                	mv	a4,a0
      *dst++ = *src++;
 27e:	0585                	addi	a1,a1,1
 280:	0705                	addi	a4,a4,1
 282:	fff5c683          	lbu	a3,-1(a1)
 286:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 28a:	fee79ae3          	bne	a5,a4,27e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret
    dst += n;
 294:	00c50733          	add	a4,a0,a2
    src += n;
 298:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 29a:	fec05ae3          	blez	a2,28e <memmove+0x28>
 29e:	fff6079b          	addiw	a5,a2,-1
 2a2:	1782                	slli	a5,a5,0x20
 2a4:	9381                	srli	a5,a5,0x20
 2a6:	fff7c793          	not	a5,a5
 2aa:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2ac:	15fd                	addi	a1,a1,-1
 2ae:	177d                	addi	a4,a4,-1
 2b0:	0005c683          	lbu	a3,0(a1)
 2b4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b8:	fee79ae3          	bne	a5,a4,2ac <memmove+0x46>
 2bc:	bfc9                	j	28e <memmove+0x28>

00000000000002be <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2be:	1141                	addi	sp,sp,-16
 2c0:	e422                	sd	s0,8(sp)
 2c2:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c4:	ca05                	beqz	a2,2f4 <memcmp+0x36>
 2c6:	fff6069b          	addiw	a3,a2,-1
 2ca:	1682                	slli	a3,a3,0x20
 2cc:	9281                	srli	a3,a3,0x20
 2ce:	0685                	addi	a3,a3,1
 2d0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d2:	00054783          	lbu	a5,0(a0)
 2d6:	0005c703          	lbu	a4,0(a1)
 2da:	00e79863          	bne	a5,a4,2ea <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2de:	0505                	addi	a0,a0,1
    p2++;
 2e0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e2:	fed518e3          	bne	a0,a3,2d2 <memcmp+0x14>
  }
  return 0;
 2e6:	4501                	li	a0,0
 2e8:	a019                	j	2ee <memcmp+0x30>
      return *p1 - *p2;
 2ea:	40e7853b          	subw	a0,a5,a4
}
 2ee:	6422                	ld	s0,8(sp)
 2f0:	0141                	addi	sp,sp,16
 2f2:	8082                	ret
  return 0;
 2f4:	4501                	li	a0,0
 2f6:	bfe5                	j	2ee <memcmp+0x30>

00000000000002f8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e406                	sd	ra,8(sp)
 2fc:	e022                	sd	s0,0(sp)
 2fe:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 300:	00000097          	auipc	ra,0x0
 304:	f66080e7          	jalr	-154(ra) # 266 <memmove>
}
 308:	60a2                	ld	ra,8(sp)
 30a:	6402                	ld	s0,0(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 310:	4885                	li	a7,1
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <exit>:
.global exit
exit:
 li a7, SYS_exit
 318:	4889                	li	a7,2
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <wait>:
.global wait
wait:
 li a7, SYS_wait
 320:	488d                	li	a7,3
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 328:	4891                	li	a7,4
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <read>:
.global read
read:
 li a7, SYS_read
 330:	4895                	li	a7,5
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <write>:
.global write
write:
 li a7, SYS_write
 338:	48c1                	li	a7,16
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <close>:
.global close
close:
 li a7, SYS_close
 340:	48d5                	li	a7,21
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <kill>:
.global kill
kill:
 li a7, SYS_kill
 348:	4899                	li	a7,6
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <exec>:
.global exec
exec:
 li a7, SYS_exec
 350:	489d                	li	a7,7
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <open>:
.global open
open:
 li a7, SYS_open
 358:	48bd                	li	a7,15
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 360:	48c5                	li	a7,17
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 368:	48c9                	li	a7,18
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 370:	48a1                	li	a7,8
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <link>:
.global link
link:
 li a7, SYS_link
 378:	48cd                	li	a7,19
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 380:	48d1                	li	a7,20
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 388:	48a5                	li	a7,9
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <dup>:
.global dup
dup:
 li a7, SYS_dup
 390:	48a9                	li	a7,10
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 398:	48ad                	li	a7,11
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a0:	48b1                	li	a7,12
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a8:	48b5                	li	a7,13
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b0:	48b9                	li	a7,14
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 3b8:	48d9                	li	a7,22
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <yield>:
.global yield
yield:
 li a7, SYS_yield
 3c0:	48dd                	li	a7,23
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 3c8:	48e1                	li	a7,24
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 3d0:	48e5                	li	a7,25
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 3d8:	48e9                	li	a7,26
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3e0:	48ed                	li	a7,27
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 3e8:	48f1                	li	a7,28
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 3f0:	48f5                	li	a7,29
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 3f8:	48f9                	li	a7,30
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 400:	02100893          	li	a7,33
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 40a:	48fd                	li	a7,31
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 412:	02000893          	li	a7,32
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 41c:	02200893          	li	a7,34
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 426:	02300893          	li	a7,35
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 430:	02400893          	li	a7,36
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 43a:	02500893          	li	a7,37
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 444:	02700893          	li	a7,39
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 44e:	02600893          	li	a7,38
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 458:	1101                	addi	sp,sp,-32
 45a:	ec06                	sd	ra,24(sp)
 45c:	e822                	sd	s0,16(sp)
 45e:	1000                	addi	s0,sp,32
 460:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 464:	4605                	li	a2,1
 466:	fef40593          	addi	a1,s0,-17
 46a:	00000097          	auipc	ra,0x0
 46e:	ece080e7          	jalr	-306(ra) # 338 <write>
}
 472:	60e2                	ld	ra,24(sp)
 474:	6442                	ld	s0,16(sp)
 476:	6105                	addi	sp,sp,32
 478:	8082                	ret

000000000000047a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47a:	7139                	addi	sp,sp,-64
 47c:	fc06                	sd	ra,56(sp)
 47e:	f822                	sd	s0,48(sp)
 480:	f426                	sd	s1,40(sp)
 482:	f04a                	sd	s2,32(sp)
 484:	ec4e                	sd	s3,24(sp)
 486:	0080                	addi	s0,sp,64
 488:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 48a:	c299                	beqz	a3,490 <printint+0x16>
 48c:	0805c963          	bltz	a1,51e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 490:	2581                	sext.w	a1,a1
  neg = 0;
 492:	4881                	li	a7,0
 494:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 498:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 49a:	2601                	sext.w	a2,a2
 49c:	00000517          	auipc	a0,0x0
 4a0:	4dc50513          	addi	a0,a0,1244 # 978 <digits>
 4a4:	883a                	mv	a6,a4
 4a6:	2705                	addiw	a4,a4,1
 4a8:	02c5f7bb          	remuw	a5,a1,a2
 4ac:	1782                	slli	a5,a5,0x20
 4ae:	9381                	srli	a5,a5,0x20
 4b0:	97aa                	add	a5,a5,a0
 4b2:	0007c783          	lbu	a5,0(a5)
 4b6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ba:	0005879b          	sext.w	a5,a1
 4be:	02c5d5bb          	divuw	a1,a1,a2
 4c2:	0685                	addi	a3,a3,1
 4c4:	fec7f0e3          	bgeu	a5,a2,4a4 <printint+0x2a>
  if(neg)
 4c8:	00088c63          	beqz	a7,4e0 <printint+0x66>
    buf[i++] = '-';
 4cc:	fd070793          	addi	a5,a4,-48
 4d0:	00878733          	add	a4,a5,s0
 4d4:	02d00793          	li	a5,45
 4d8:	fef70823          	sb	a5,-16(a4)
 4dc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4e0:	02e05863          	blez	a4,510 <printint+0x96>
 4e4:	fc040793          	addi	a5,s0,-64
 4e8:	00e78933          	add	s2,a5,a4
 4ec:	fff78993          	addi	s3,a5,-1
 4f0:	99ba                	add	s3,s3,a4
 4f2:	377d                	addiw	a4,a4,-1
 4f4:	1702                	slli	a4,a4,0x20
 4f6:	9301                	srli	a4,a4,0x20
 4f8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4fc:	fff94583          	lbu	a1,-1(s2)
 500:	8526                	mv	a0,s1
 502:	00000097          	auipc	ra,0x0
 506:	f56080e7          	jalr	-170(ra) # 458 <putc>
  while(--i >= 0)
 50a:	197d                	addi	s2,s2,-1
 50c:	ff3918e3          	bne	s2,s3,4fc <printint+0x82>
}
 510:	70e2                	ld	ra,56(sp)
 512:	7442                	ld	s0,48(sp)
 514:	74a2                	ld	s1,40(sp)
 516:	7902                	ld	s2,32(sp)
 518:	69e2                	ld	s3,24(sp)
 51a:	6121                	addi	sp,sp,64
 51c:	8082                	ret
    x = -xx;
 51e:	40b005bb          	negw	a1,a1
    neg = 1;
 522:	4885                	li	a7,1
    x = -xx;
 524:	bf85                	j	494 <printint+0x1a>

0000000000000526 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 526:	7119                	addi	sp,sp,-128
 528:	fc86                	sd	ra,120(sp)
 52a:	f8a2                	sd	s0,112(sp)
 52c:	f4a6                	sd	s1,104(sp)
 52e:	f0ca                	sd	s2,96(sp)
 530:	ecce                	sd	s3,88(sp)
 532:	e8d2                	sd	s4,80(sp)
 534:	e4d6                	sd	s5,72(sp)
 536:	e0da                	sd	s6,64(sp)
 538:	fc5e                	sd	s7,56(sp)
 53a:	f862                	sd	s8,48(sp)
 53c:	f466                	sd	s9,40(sp)
 53e:	f06a                	sd	s10,32(sp)
 540:	ec6e                	sd	s11,24(sp)
 542:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 544:	0005c903          	lbu	s2,0(a1)
 548:	18090f63          	beqz	s2,6e6 <vprintf+0x1c0>
 54c:	8aaa                	mv	s5,a0
 54e:	8b32                	mv	s6,a2
 550:	00158493          	addi	s1,a1,1
  state = 0;
 554:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 556:	02500a13          	li	s4,37
 55a:	4c55                	li	s8,21
 55c:	00000c97          	auipc	s9,0x0
 560:	3c4c8c93          	addi	s9,s9,964 # 920 <malloc+0x136>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 564:	02800d93          	li	s11,40
  putc(fd, 'x');
 568:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56a:	00000b97          	auipc	s7,0x0
 56e:	40eb8b93          	addi	s7,s7,1038 # 978 <digits>
 572:	a839                	j	590 <vprintf+0x6a>
        putc(fd, c);
 574:	85ca                	mv	a1,s2
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	ee0080e7          	jalr	-288(ra) # 458 <putc>
 580:	a019                	j	586 <vprintf+0x60>
    } else if(state == '%'){
 582:	01498d63          	beq	s3,s4,59c <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 586:	0485                	addi	s1,s1,1
 588:	fff4c903          	lbu	s2,-1(s1)
 58c:	14090d63          	beqz	s2,6e6 <vprintf+0x1c0>
    if(state == 0){
 590:	fe0999e3          	bnez	s3,582 <vprintf+0x5c>
      if(c == '%'){
 594:	ff4910e3          	bne	s2,s4,574 <vprintf+0x4e>
        state = '%';
 598:	89d2                	mv	s3,s4
 59a:	b7f5                	j	586 <vprintf+0x60>
      if(c == 'd'){
 59c:	11490c63          	beq	s2,s4,6b4 <vprintf+0x18e>
 5a0:	f9d9079b          	addiw	a5,s2,-99
 5a4:	0ff7f793          	zext.b	a5,a5
 5a8:	10fc6e63          	bltu	s8,a5,6c4 <vprintf+0x19e>
 5ac:	f9d9079b          	addiw	a5,s2,-99
 5b0:	0ff7f713          	zext.b	a4,a5
 5b4:	10ec6863          	bltu	s8,a4,6c4 <vprintf+0x19e>
 5b8:	00271793          	slli	a5,a4,0x2
 5bc:	97e6                	add	a5,a5,s9
 5be:	439c                	lw	a5,0(a5)
 5c0:	97e6                	add	a5,a5,s9
 5c2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5c4:	008b0913          	addi	s2,s6,8
 5c8:	4685                	li	a3,1
 5ca:	4629                	li	a2,10
 5cc:	000b2583          	lw	a1,0(s6)
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	ea8080e7          	jalr	-344(ra) # 47a <printint>
 5da:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b765                	j	586 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5e0:	008b0913          	addi	s2,s6,8
 5e4:	4681                	li	a3,0
 5e6:	4629                	li	a2,10
 5e8:	000b2583          	lw	a1,0(s6)
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e8c080e7          	jalr	-372(ra) # 47a <printint>
 5f6:	8b4a                	mv	s6,s2
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b771                	j	586 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5fc:	008b0913          	addi	s2,s6,8
 600:	4681                	li	a3,0
 602:	866a                	mv	a2,s10
 604:	000b2583          	lw	a1,0(s6)
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	e70080e7          	jalr	-400(ra) # 47a <printint>
 612:	8b4a                	mv	s6,s2
      state = 0;
 614:	4981                	li	s3,0
 616:	bf85                	j	586 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 618:	008b0793          	addi	a5,s6,8
 61c:	f8f43423          	sd	a5,-120(s0)
 620:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 624:	03000593          	li	a1,48
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e2e080e7          	jalr	-466(ra) # 458 <putc>
  putc(fd, 'x');
 632:	07800593          	li	a1,120
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e20080e7          	jalr	-480(ra) # 458 <putc>
 640:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 642:	03c9d793          	srli	a5,s3,0x3c
 646:	97de                	add	a5,a5,s7
 648:	0007c583          	lbu	a1,0(a5)
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	e0a080e7          	jalr	-502(ra) # 458 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 656:	0992                	slli	s3,s3,0x4
 658:	397d                	addiw	s2,s2,-1
 65a:	fe0914e3          	bnez	s2,642 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 65e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 662:	4981                	li	s3,0
 664:	b70d                	j	586 <vprintf+0x60>
        s = va_arg(ap, char*);
 666:	008b0913          	addi	s2,s6,8
 66a:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 66e:	02098163          	beqz	s3,690 <vprintf+0x16a>
        while(*s != 0){
 672:	0009c583          	lbu	a1,0(s3)
 676:	c5ad                	beqz	a1,6e0 <vprintf+0x1ba>
          putc(fd, *s);
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	dde080e7          	jalr	-546(ra) # 458 <putc>
          s++;
 682:	0985                	addi	s3,s3,1
        while(*s != 0){
 684:	0009c583          	lbu	a1,0(s3)
 688:	f9e5                	bnez	a1,678 <vprintf+0x152>
        s = va_arg(ap, char*);
 68a:	8b4a                	mv	s6,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bde5                	j	586 <vprintf+0x60>
          s = "(null)";
 690:	00000997          	auipc	s3,0x0
 694:	28898993          	addi	s3,s3,648 # 918 <malloc+0x12e>
        while(*s != 0){
 698:	85ee                	mv	a1,s11
 69a:	bff9                	j	678 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 69c:	008b0913          	addi	s2,s6,8
 6a0:	000b4583          	lbu	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	db2080e7          	jalr	-590(ra) # 458 <putc>
 6ae:	8b4a                	mv	s6,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bdd1                	j	586 <vprintf+0x60>
        putc(fd, c);
 6b4:	85d2                	mv	a1,s4
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	da0080e7          	jalr	-608(ra) # 458 <putc>
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b5d1                	j	586 <vprintf+0x60>
        putc(fd, '%');
 6c4:	85d2                	mv	a1,s4
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	d90080e7          	jalr	-624(ra) # 458 <putc>
        putc(fd, c);
 6d0:	85ca                	mv	a1,s2
 6d2:	8556                	mv	a0,s5
 6d4:	00000097          	auipc	ra,0x0
 6d8:	d84080e7          	jalr	-636(ra) # 458 <putc>
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b565                	j	586 <vprintf+0x60>
        s = va_arg(ap, char*);
 6e0:	8b4a                	mv	s6,s2
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	b54d                	j	586 <vprintf+0x60>
    }
  }
}
 6e6:	70e6                	ld	ra,120(sp)
 6e8:	7446                	ld	s0,112(sp)
 6ea:	74a6                	ld	s1,104(sp)
 6ec:	7906                	ld	s2,96(sp)
 6ee:	69e6                	ld	s3,88(sp)
 6f0:	6a46                	ld	s4,80(sp)
 6f2:	6aa6                	ld	s5,72(sp)
 6f4:	6b06                	ld	s6,64(sp)
 6f6:	7be2                	ld	s7,56(sp)
 6f8:	7c42                	ld	s8,48(sp)
 6fa:	7ca2                	ld	s9,40(sp)
 6fc:	7d02                	ld	s10,32(sp)
 6fe:	6de2                	ld	s11,24(sp)
 700:	6109                	addi	sp,sp,128
 702:	8082                	ret

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 720:	8622                	mv	a2,s0
 722:	00000097          	auipc	ra,0x0
 726:	e04080e7          	jalr	-508(ra) # 526 <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6161                	addi	sp,sp,80
 730:	8082                	ret

0000000000000732 <printf>:

void
printf(const char *fmt, ...)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec06                	sd	ra,24(sp)
 736:	e822                	sd	s0,16(sp)
 738:	1000                	addi	s0,sp,32
 73a:	e40c                	sd	a1,8(s0)
 73c:	e810                	sd	a2,16(s0)
 73e:	ec14                	sd	a3,24(s0)
 740:	f018                	sd	a4,32(s0)
 742:	f41c                	sd	a5,40(s0)
 744:	03043823          	sd	a6,48(s0)
 748:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	00840613          	addi	a2,s0,8
 750:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 754:	85aa                	mv	a1,a0
 756:	4505                	li	a0,1
 758:	00000097          	auipc	ra,0x0
 75c:	dce080e7          	jalr	-562(ra) # 526 <vprintf>
}
 760:	60e2                	ld	ra,24(sp)
 762:	6442                	ld	s0,16(sp)
 764:	6125                	addi	sp,sp,96
 766:	8082                	ret

0000000000000768 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 768:	1141                	addi	sp,sp,-16
 76a:	e422                	sd	s0,8(sp)
 76c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 772:	00000797          	auipc	a5,0x0
 776:	21e7b783          	ld	a5,542(a5) # 990 <freep>
 77a:	a02d                	j	7a4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 77c:	4618                	lw	a4,8(a2)
 77e:	9f2d                	addw	a4,a4,a1
 780:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 784:	6398                	ld	a4,0(a5)
 786:	6310                	ld	a2,0(a4)
 788:	a83d                	j	7c6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 78a:	ff852703          	lw	a4,-8(a0)
 78e:	9f31                	addw	a4,a4,a2
 790:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 792:	ff053683          	ld	a3,-16(a0)
 796:	a091                	j	7da <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 798:	6398                	ld	a4,0(a5)
 79a:	00e7e463          	bltu	a5,a4,7a2 <free+0x3a>
 79e:	00e6ea63          	bltu	a3,a4,7b2 <free+0x4a>
{
 7a2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a4:	fed7fae3          	bgeu	a5,a3,798 <free+0x30>
 7a8:	6398                	ld	a4,0(a5)
 7aa:	00e6e463          	bltu	a3,a4,7b2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	fee7eae3          	bltu	a5,a4,7a2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7b2:	ff852583          	lw	a1,-8(a0)
 7b6:	6390                	ld	a2,0(a5)
 7b8:	02059813          	slli	a6,a1,0x20
 7bc:	01c85713          	srli	a4,a6,0x1c
 7c0:	9736                	add	a4,a4,a3
 7c2:	fae60de3          	beq	a2,a4,77c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7c6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ca:	4790                	lw	a2,8(a5)
 7cc:	02061593          	slli	a1,a2,0x20
 7d0:	01c5d713          	srli	a4,a1,0x1c
 7d4:	973e                	add	a4,a4,a5
 7d6:	fae68ae3          	beq	a3,a4,78a <free+0x22>
    p->s.ptr = bp->s.ptr;
 7da:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7dc:	00000717          	auipc	a4,0x0
 7e0:	1af73a23          	sd	a5,436(a4) # 990 <freep>
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret

00000000000007ea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ea:	7139                	addi	sp,sp,-64
 7ec:	fc06                	sd	ra,56(sp)
 7ee:	f822                	sd	s0,48(sp)
 7f0:	f426                	sd	s1,40(sp)
 7f2:	f04a                	sd	s2,32(sp)
 7f4:	ec4e                	sd	s3,24(sp)
 7f6:	e852                	sd	s4,16(sp)
 7f8:	e456                	sd	s5,8(sp)
 7fa:	e05a                	sd	s6,0(sp)
 7fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fe:	02051493          	slli	s1,a0,0x20
 802:	9081                	srli	s1,s1,0x20
 804:	04bd                	addi	s1,s1,15
 806:	8091                	srli	s1,s1,0x4
 808:	0014899b          	addiw	s3,s1,1
 80c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 80e:	00000517          	auipc	a0,0x0
 812:	18253503          	ld	a0,386(a0) # 990 <freep>
 816:	c515                	beqz	a0,842 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81a:	4798                	lw	a4,8(a5)
 81c:	02977f63          	bgeu	a4,s1,85a <malloc+0x70>
 820:	8a4e                	mv	s4,s3
 822:	0009871b          	sext.w	a4,s3
 826:	6685                	lui	a3,0x1
 828:	00d77363          	bgeu	a4,a3,82e <malloc+0x44>
 82c:	6a05                	lui	s4,0x1
 82e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 832:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 836:	00000917          	auipc	s2,0x0
 83a:	15a90913          	addi	s2,s2,346 # 990 <freep>
  if(p == (char*)-1)
 83e:	5afd                	li	s5,-1
 840:	a895                	j	8b4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 842:	00000797          	auipc	a5,0x0
 846:	15678793          	addi	a5,a5,342 # 998 <base>
 84a:	00000717          	auipc	a4,0x0
 84e:	14f73323          	sd	a5,326(a4) # 990 <freep>
 852:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 854:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 858:	b7e1                	j	820 <malloc+0x36>
      if(p->s.size == nunits)
 85a:	02e48c63          	beq	s1,a4,892 <malloc+0xa8>
        p->s.size -= nunits;
 85e:	4137073b          	subw	a4,a4,s3
 862:	c798                	sw	a4,8(a5)
        p += p->s.size;
 864:	02071693          	slli	a3,a4,0x20
 868:	01c6d713          	srli	a4,a3,0x1c
 86c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 86e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 872:	00000717          	auipc	a4,0x0
 876:	10a73f23          	sd	a0,286(a4) # 990 <freep>
      return (void*)(p + 1);
 87a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 87e:	70e2                	ld	ra,56(sp)
 880:	7442                	ld	s0,48(sp)
 882:	74a2                	ld	s1,40(sp)
 884:	7902                	ld	s2,32(sp)
 886:	69e2                	ld	s3,24(sp)
 888:	6a42                	ld	s4,16(sp)
 88a:	6aa2                	ld	s5,8(sp)
 88c:	6b02                	ld	s6,0(sp)
 88e:	6121                	addi	sp,sp,64
 890:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 892:	6398                	ld	a4,0(a5)
 894:	e118                	sd	a4,0(a0)
 896:	bff1                	j	872 <malloc+0x88>
  hp->s.size = nu;
 898:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 89c:	0541                	addi	a0,a0,16
 89e:	00000097          	auipc	ra,0x0
 8a2:	eca080e7          	jalr	-310(ra) # 768 <free>
  return freep;
 8a6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8aa:	d971                	beqz	a0,87e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ae:	4798                	lw	a4,8(a5)
 8b0:	fa9775e3          	bgeu	a4,s1,85a <malloc+0x70>
    if(p == freep)
 8b4:	00093703          	ld	a4,0(s2)
 8b8:	853e                	mv	a0,a5
 8ba:	fef719e3          	bne	a4,a5,8ac <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8be:	8552                	mv	a0,s4
 8c0:	00000097          	auipc	ra,0x0
 8c4:	ae0080e7          	jalr	-1312(ra) # 3a0 <sbrk>
  if(p == (char*)-1)
 8c8:	fd5518e3          	bne	a0,s5,898 <malloc+0xae>
        return 0;
 8cc:	4501                	li	a0,0
 8ce:	bf45                	j	87e <malloc+0x94>
