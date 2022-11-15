
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	34e080e7          	jalr	846(ra) # 35e <strlen>
  18:	02051793          	slli	a5,a0,0x20
  1c:	9381                	srli	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	addi	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	322080e7          	jalr	802(ra) # 35e <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	addi	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	300080e7          	jalr	768(ra) # 35e <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	c1298993          	addi	s3,s3,-1006 # c78 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	45a080e7          	jalr	1114(ra) # 4d0 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2de080e7          	jalr	734(ra) # 35e <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2d0080e7          	jalr	720(ra) # 35e <strlen>
  96:	1902                	slli	s2,s2,0x20
  98:	02095913          	srli	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2e0080e7          	jalr	736(ra) # 388 <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <find>:

void
find(char *path, char *fname)
{
  b4:	d8010113          	addi	sp,sp,-640
  b8:	26113c23          	sd	ra,632(sp)
  bc:	26813823          	sd	s0,624(sp)
  c0:	26913423          	sd	s1,616(sp)
  c4:	27213023          	sd	s2,608(sp)
  c8:	25313c23          	sd	s3,600(sp)
  cc:	25413823          	sd	s4,592(sp)
  d0:	25513423          	sd	s5,584(sp)
  d4:	25613023          	sd	s6,576(sp)
  d8:	23713c23          	sd	s7,568(sp)
  dc:	23813823          	sd	s8,560(sp)
  e0:	0500                	addi	s0,sp,640
  e2:	89aa                	mv	s3,a0
  e4:	892e                	mv	s2,a1
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  e6:	4581                	li	a1,0
  e8:	00000097          	auipc	ra,0x0
  ec:	4da080e7          	jalr	1242(ra) # 5c2 <open>
  f0:	04054563          	bltz	a0,13a <find+0x86>
  f4:	84aa                	mv	s1,a0
    fprintf(2, "find: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  f6:	d8840593          	addi	a1,s0,-632
  fa:	00000097          	auipc	ra,0x0
  fe:	4e0080e7          	jalr	1248(ra) # 5da <fstat>
 102:	04054763          	bltz	a0,150 <find+0x9c>
    fprintf(2, "find: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
 106:	d9041783          	lh	a5,-624(s0)
 10a:	0007869b          	sext.w	a3,a5
 10e:	4705                	li	a4,1
 110:	06e68063          	beq	a3,a4,170 <find+0xbc>
 114:	4709                	li	a4,2
 116:	06e69f63          	bne	a3,a4,194 <find+0xe0>
  case T_FILE:
    fprintf(2, "find: search path %s is not a directory\n", path);
 11a:	864e                	mv	a2,s3
 11c:	00001597          	auipc	a1,0x1
 120:	a5458593          	addi	a1,a1,-1452 # b70 <malloc+0x11c>
 124:	4509                	li	a0,2
 126:	00001097          	auipc	ra,0x1
 12a:	848080e7          	jalr	-1976(ra) # 96e <fprintf>
    close(fd);
 12e:	8526                	mv	a0,s1
 130:	00000097          	auipc	ra,0x0
 134:	47a080e7          	jalr	1146(ra) # 5aa <close>
    return;
 138:	a09d                	j	19e <find+0xea>
    fprintf(2, "find: cannot open %s\n", path);
 13a:	864e                	mv	a2,s3
 13c:	00001597          	auipc	a1,0x1
 140:	a0458593          	addi	a1,a1,-1532 # b40 <malloc+0xec>
 144:	4509                	li	a0,2
 146:	00001097          	auipc	ra,0x1
 14a:	828080e7          	jalr	-2008(ra) # 96e <fprintf>
    return;
 14e:	a881                	j	19e <find+0xea>
    fprintf(2, "find: cannot stat %s\n", path);
 150:	864e                	mv	a2,s3
 152:	00001597          	auipc	a1,0x1
 156:	a0658593          	addi	a1,a1,-1530 # b58 <malloc+0x104>
 15a:	4509                	li	a0,2
 15c:	00001097          	auipc	ra,0x1
 160:	812080e7          	jalr	-2030(ra) # 96e <fprintf>
    close(fd);
 164:	8526                	mv	a0,s1
 166:	00000097          	auipc	ra,0x0
 16a:	444080e7          	jalr	1092(ra) # 5aa <close>
    return;
 16e:	a805                	j	19e <find+0xea>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 170:	854e                	mv	a0,s3
 172:	00000097          	auipc	ra,0x0
 176:	1ec080e7          	jalr	492(ra) # 35e <strlen>
 17a:	2541                	addiw	a0,a0,16
 17c:	20000793          	li	a5,512
 180:	04a7f663          	bgeu	a5,a0,1cc <find+0x118>
      printf("find: path too long\n");
 184:	00001517          	auipc	a0,0x1
 188:	a1c50513          	addi	a0,a0,-1508 # ba0 <malloc+0x14c>
 18c:	00001097          	auipc	ra,0x1
 190:	810080e7          	jalr	-2032(ra) # 99c <printf>
         if (strcmp(".", de.name) && strcmp("..", de.name)) find(buf, fname);
      }
    }
    break;
  }
  close(fd);
 194:	8526                	mv	a0,s1
 196:	00000097          	auipc	ra,0x0
 19a:	414080e7          	jalr	1044(ra) # 5aa <close>
}
 19e:	27813083          	ld	ra,632(sp)
 1a2:	27013403          	ld	s0,624(sp)
 1a6:	26813483          	ld	s1,616(sp)
 1aa:	26013903          	ld	s2,608(sp)
 1ae:	25813983          	ld	s3,600(sp)
 1b2:	25013a03          	ld	s4,592(sp)
 1b6:	24813a83          	ld	s5,584(sp)
 1ba:	24013b03          	ld	s6,576(sp)
 1be:	23813b83          	ld	s7,568(sp)
 1c2:	23013c03          	ld	s8,560(sp)
 1c6:	28010113          	addi	sp,sp,640
 1ca:	8082                	ret
    strcpy(buf, path);
 1cc:	85ce                	mv	a1,s3
 1ce:	db040513          	addi	a0,s0,-592
 1d2:	00000097          	auipc	ra,0x0
 1d6:	144080e7          	jalr	324(ra) # 316 <strcpy>
    p = buf+strlen(buf);
 1da:	db040513          	addi	a0,s0,-592
 1de:	00000097          	auipc	ra,0x0
 1e2:	180080e7          	jalr	384(ra) # 35e <strlen>
 1e6:	1502                	slli	a0,a0,0x20
 1e8:	9101                	srli	a0,a0,0x20
 1ea:	db040793          	addi	a5,s0,-592
 1ee:	00a789b3          	add	s3,a5,a0
    *p++ = '/';
 1f2:	00198a13          	addi	s4,s3,1
 1f6:	02f00793          	li	a5,47
 1fa:	00f98023          	sb	a5,0(s3)
      if (st.type == T_FILE) {
 1fe:	4a89                	li	s5,2
      else if (st.type == T_DIR) {
 200:	4b05                	li	s6,1
         if (strcmp(".", de.name) && strcmp("..", de.name)) find(buf, fname);
 202:	00001b97          	auipc	s7,0x1
 206:	9beb8b93          	addi	s7,s7,-1602 # bc0 <malloc+0x16c>
 20a:	00001c17          	auipc	s8,0x1
 20e:	9bec0c13          	addi	s8,s8,-1602 # bc8 <malloc+0x174>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 212:	4641                	li	a2,16
 214:	da040593          	addi	a1,s0,-608
 218:	8526                	mv	a0,s1
 21a:	00000097          	auipc	ra,0x0
 21e:	380080e7          	jalr	896(ra) # 59a <read>
 222:	47c1                	li	a5,16
 224:	f6f518e3          	bne	a0,a5,194 <find+0xe0>
      if(de.inum == 0)
 228:	da045783          	lhu	a5,-608(s0)
 22c:	d3fd                	beqz	a5,212 <find+0x15e>
      memmove(p, de.name, DIRSIZ);
 22e:	4639                	li	a2,14
 230:	da240593          	addi	a1,s0,-606
 234:	8552                	mv	a0,s4
 236:	00000097          	auipc	ra,0x0
 23a:	29a080e7          	jalr	666(ra) # 4d0 <memmove>
      p[DIRSIZ] = 0;
 23e:	000987a3          	sb	zero,15(s3)
      if(stat(buf, &st) < 0){
 242:	d8840593          	addi	a1,s0,-632
 246:	db040513          	addi	a0,s0,-592
 24a:	00000097          	auipc	ra,0x0
 24e:	1f8080e7          	jalr	504(ra) # 442 <stat>
 252:	04054363          	bltz	a0,298 <find+0x1e4>
      if (st.type == T_FILE) {
 256:	d9041783          	lh	a5,-624(s0)
 25a:	0007871b          	sext.w	a4,a5
 25e:	05570863          	beq	a4,s5,2ae <find+0x1fa>
      else if (st.type == T_DIR) {
 262:	2781                	sext.w	a5,a5
 264:	fb6797e3          	bne	a5,s6,212 <find+0x15e>
         if (strcmp(".", de.name) && strcmp("..", de.name)) find(buf, fname);
 268:	da240593          	addi	a1,s0,-606
 26c:	855e                	mv	a0,s7
 26e:	00000097          	auipc	ra,0x0
 272:	0c4080e7          	jalr	196(ra) # 332 <strcmp>
 276:	dd51                	beqz	a0,212 <find+0x15e>
 278:	da240593          	addi	a1,s0,-606
 27c:	8562                	mv	a0,s8
 27e:	00000097          	auipc	ra,0x0
 282:	0b4080e7          	jalr	180(ra) # 332 <strcmp>
 286:	d551                	beqz	a0,212 <find+0x15e>
 288:	85ca                	mv	a1,s2
 28a:	db040513          	addi	a0,s0,-592
 28e:	00000097          	auipc	ra,0x0
 292:	e26080e7          	jalr	-474(ra) # b4 <find>
 296:	bfb5                	j	212 <find+0x15e>
        printf("find: cannot stat %s\n", buf);
 298:	db040593          	addi	a1,s0,-592
 29c:	00001517          	auipc	a0,0x1
 2a0:	8bc50513          	addi	a0,a0,-1860 # b58 <malloc+0x104>
 2a4:	00000097          	auipc	ra,0x0
 2a8:	6f8080e7          	jalr	1784(ra) # 99c <printf>
        continue;
 2ac:	b79d                	j	212 <find+0x15e>
         if (!strcmp(fname, de.name)) printf("%s\n", buf);
 2ae:	da240593          	addi	a1,s0,-606
 2b2:	854a                	mv	a0,s2
 2b4:	00000097          	auipc	ra,0x0
 2b8:	07e080e7          	jalr	126(ra) # 332 <strcmp>
 2bc:	f939                	bnez	a0,212 <find+0x15e>
 2be:	db040593          	addi	a1,s0,-592
 2c2:	00001517          	auipc	a0,0x1
 2c6:	8f650513          	addi	a0,a0,-1802 # bb8 <malloc+0x164>
 2ca:	00000097          	auipc	ra,0x0
 2ce:	6d2080e7          	jalr	1746(ra) # 99c <printf>
 2d2:	b781                	j	212 <find+0x15e>

00000000000002d4 <main>:

int
main(int argc, char *argv[])
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e406                	sd	ra,8(sp)
 2d8:	e022                	sd	s0,0(sp)
 2da:	0800                	addi	s0,sp,16
  if(argc != 3){
 2dc:	470d                	li	a4,3
 2de:	02e50063          	beq	a0,a4,2fe <main+0x2a>
    fprintf(2, "syntax: find path file\nAborting...\n");
 2e2:	00001597          	auipc	a1,0x1
 2e6:	8ee58593          	addi	a1,a1,-1810 # bd0 <malloc+0x17c>
 2ea:	4509                	li	a0,2
 2ec:	00000097          	auipc	ra,0x0
 2f0:	682080e7          	jalr	1666(ra) # 96e <fprintf>
    exit(0);
 2f4:	4501                	li	a0,0
 2f6:	00000097          	auipc	ra,0x0
 2fa:	28c080e7          	jalr	652(ra) # 582 <exit>
 2fe:	87ae                	mv	a5,a1
  }
  find (argv[1], argv[2]);
 300:	698c                	ld	a1,16(a1)
 302:	6788                	ld	a0,8(a5)
 304:	00000097          	auipc	ra,0x0
 308:	db0080e7          	jalr	-592(ra) # b4 <find>
  exit(0);
 30c:	4501                	li	a0,0
 30e:	00000097          	auipc	ra,0x0
 312:	274080e7          	jalr	628(ra) # 582 <exit>

0000000000000316 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 316:	1141                	addi	sp,sp,-16
 318:	e422                	sd	s0,8(sp)
 31a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 31c:	87aa                	mv	a5,a0
 31e:	0585                	addi	a1,a1,1
 320:	0785                	addi	a5,a5,1
 322:	fff5c703          	lbu	a4,-1(a1)
 326:	fee78fa3          	sb	a4,-1(a5)
 32a:	fb75                	bnez	a4,31e <strcpy+0x8>
    ;
  return os;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	addi	sp,sp,16
 330:	8082                	ret

0000000000000332 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 332:	1141                	addi	sp,sp,-16
 334:	e422                	sd	s0,8(sp)
 336:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 338:	00054783          	lbu	a5,0(a0)
 33c:	cb91                	beqz	a5,350 <strcmp+0x1e>
 33e:	0005c703          	lbu	a4,0(a1)
 342:	00f71763          	bne	a4,a5,350 <strcmp+0x1e>
    p++, q++;
 346:	0505                	addi	a0,a0,1
 348:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 34a:	00054783          	lbu	a5,0(a0)
 34e:	fbe5                	bnez	a5,33e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 350:	0005c503          	lbu	a0,0(a1)
}
 354:	40a7853b          	subw	a0,a5,a0
 358:	6422                	ld	s0,8(sp)
 35a:	0141                	addi	sp,sp,16
 35c:	8082                	ret

000000000000035e <strlen>:

uint
strlen(const char *s)
{
 35e:	1141                	addi	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 364:	00054783          	lbu	a5,0(a0)
 368:	cf91                	beqz	a5,384 <strlen+0x26>
 36a:	0505                	addi	a0,a0,1
 36c:	87aa                	mv	a5,a0
 36e:	4685                	li	a3,1
 370:	9e89                	subw	a3,a3,a0
 372:	00f6853b          	addw	a0,a3,a5
 376:	0785                	addi	a5,a5,1
 378:	fff7c703          	lbu	a4,-1(a5)
 37c:	fb7d                	bnez	a4,372 <strlen+0x14>
    ;
  return n;
}
 37e:	6422                	ld	s0,8(sp)
 380:	0141                	addi	sp,sp,16
 382:	8082                	ret
  for(n = 0; s[n]; n++)
 384:	4501                	li	a0,0
 386:	bfe5                	j	37e <strlen+0x20>

0000000000000388 <memset>:

void*
memset(void *dst, int c, uint n)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 38e:	ca19                	beqz	a2,3a4 <memset+0x1c>
 390:	87aa                	mv	a5,a0
 392:	1602                	slli	a2,a2,0x20
 394:	9201                	srli	a2,a2,0x20
 396:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 39a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 39e:	0785                	addi	a5,a5,1
 3a0:	fee79de3          	bne	a5,a4,39a <memset+0x12>
  }
  return dst;
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret

00000000000003aa <strchr>:

char*
strchr(const char *s, char c)
{
 3aa:	1141                	addi	sp,sp,-16
 3ac:	e422                	sd	s0,8(sp)
 3ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3b0:	00054783          	lbu	a5,0(a0)
 3b4:	cb99                	beqz	a5,3ca <strchr+0x20>
    if(*s == c)
 3b6:	00f58763          	beq	a1,a5,3c4 <strchr+0x1a>
  for(; *s; s++)
 3ba:	0505                	addi	a0,a0,1
 3bc:	00054783          	lbu	a5,0(a0)
 3c0:	fbfd                	bnez	a5,3b6 <strchr+0xc>
      return (char*)s;
  return 0;
 3c2:	4501                	li	a0,0
}
 3c4:	6422                	ld	s0,8(sp)
 3c6:	0141                	addi	sp,sp,16
 3c8:	8082                	ret
  return 0;
 3ca:	4501                	li	a0,0
 3cc:	bfe5                	j	3c4 <strchr+0x1a>

00000000000003ce <gets>:

char*
gets(char *buf, int max)
{
 3ce:	711d                	addi	sp,sp,-96
 3d0:	ec86                	sd	ra,88(sp)
 3d2:	e8a2                	sd	s0,80(sp)
 3d4:	e4a6                	sd	s1,72(sp)
 3d6:	e0ca                	sd	s2,64(sp)
 3d8:	fc4e                	sd	s3,56(sp)
 3da:	f852                	sd	s4,48(sp)
 3dc:	f456                	sd	s5,40(sp)
 3de:	f05a                	sd	s6,32(sp)
 3e0:	ec5e                	sd	s7,24(sp)
 3e2:	1080                	addi	s0,sp,96
 3e4:	8baa                	mv	s7,a0
 3e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3e8:	892a                	mv	s2,a0
 3ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ec:	4aa9                	li	s5,10
 3ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3f0:	89a6                	mv	s3,s1
 3f2:	2485                	addiw	s1,s1,1
 3f4:	0344d863          	bge	s1,s4,424 <gets+0x56>
    cc = read(0, &c, 1);
 3f8:	4605                	li	a2,1
 3fa:	faf40593          	addi	a1,s0,-81
 3fe:	4501                	li	a0,0
 400:	00000097          	auipc	ra,0x0
 404:	19a080e7          	jalr	410(ra) # 59a <read>
    if(cc < 1)
 408:	00a05e63          	blez	a0,424 <gets+0x56>
    buf[i++] = c;
 40c:	faf44783          	lbu	a5,-81(s0)
 410:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 414:	01578763          	beq	a5,s5,422 <gets+0x54>
 418:	0905                	addi	s2,s2,1
 41a:	fd679be3          	bne	a5,s6,3f0 <gets+0x22>
  for(i=0; i+1 < max; ){
 41e:	89a6                	mv	s3,s1
 420:	a011                	j	424 <gets+0x56>
 422:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 424:	99de                	add	s3,s3,s7
 426:	00098023          	sb	zero,0(s3)
  return buf;
}
 42a:	855e                	mv	a0,s7
 42c:	60e6                	ld	ra,88(sp)
 42e:	6446                	ld	s0,80(sp)
 430:	64a6                	ld	s1,72(sp)
 432:	6906                	ld	s2,64(sp)
 434:	79e2                	ld	s3,56(sp)
 436:	7a42                	ld	s4,48(sp)
 438:	7aa2                	ld	s5,40(sp)
 43a:	7b02                	ld	s6,32(sp)
 43c:	6be2                	ld	s7,24(sp)
 43e:	6125                	addi	sp,sp,96
 440:	8082                	ret

0000000000000442 <stat>:

int
stat(const char *n, struct stat *st)
{
 442:	1101                	addi	sp,sp,-32
 444:	ec06                	sd	ra,24(sp)
 446:	e822                	sd	s0,16(sp)
 448:	e426                	sd	s1,8(sp)
 44a:	e04a                	sd	s2,0(sp)
 44c:	1000                	addi	s0,sp,32
 44e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 450:	4581                	li	a1,0
 452:	00000097          	auipc	ra,0x0
 456:	170080e7          	jalr	368(ra) # 5c2 <open>
  if(fd < 0)
 45a:	02054563          	bltz	a0,484 <stat+0x42>
 45e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 460:	85ca                	mv	a1,s2
 462:	00000097          	auipc	ra,0x0
 466:	178080e7          	jalr	376(ra) # 5da <fstat>
 46a:	892a                	mv	s2,a0
  close(fd);
 46c:	8526                	mv	a0,s1
 46e:	00000097          	auipc	ra,0x0
 472:	13c080e7          	jalr	316(ra) # 5aa <close>
  return r;
}
 476:	854a                	mv	a0,s2
 478:	60e2                	ld	ra,24(sp)
 47a:	6442                	ld	s0,16(sp)
 47c:	64a2                	ld	s1,8(sp)
 47e:	6902                	ld	s2,0(sp)
 480:	6105                	addi	sp,sp,32
 482:	8082                	ret
    return -1;
 484:	597d                	li	s2,-1
 486:	bfc5                	j	476 <stat+0x34>

0000000000000488 <atoi>:

int
atoi(const char *s)
{
 488:	1141                	addi	sp,sp,-16
 48a:	e422                	sd	s0,8(sp)
 48c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 48e:	00054683          	lbu	a3,0(a0)
 492:	fd06879b          	addiw	a5,a3,-48
 496:	0ff7f793          	zext.b	a5,a5
 49a:	4625                	li	a2,9
 49c:	02f66863          	bltu	a2,a5,4cc <atoi+0x44>
 4a0:	872a                	mv	a4,a0
  n = 0;
 4a2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 4a4:	0705                	addi	a4,a4,1
 4a6:	0025179b          	slliw	a5,a0,0x2
 4aa:	9fa9                	addw	a5,a5,a0
 4ac:	0017979b          	slliw	a5,a5,0x1
 4b0:	9fb5                	addw	a5,a5,a3
 4b2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4b6:	00074683          	lbu	a3,0(a4)
 4ba:	fd06879b          	addiw	a5,a3,-48
 4be:	0ff7f793          	zext.b	a5,a5
 4c2:	fef671e3          	bgeu	a2,a5,4a4 <atoi+0x1c>
  return n;
}
 4c6:	6422                	ld	s0,8(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret
  n = 0;
 4cc:	4501                	li	a0,0
 4ce:	bfe5                	j	4c6 <atoi+0x3e>

00000000000004d0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4d0:	1141                	addi	sp,sp,-16
 4d2:	e422                	sd	s0,8(sp)
 4d4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4d6:	02b57463          	bgeu	a0,a1,4fe <memmove+0x2e>
    while(n-- > 0)
 4da:	00c05f63          	blez	a2,4f8 <memmove+0x28>
 4de:	1602                	slli	a2,a2,0x20
 4e0:	9201                	srli	a2,a2,0x20
 4e2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4e6:	872a                	mv	a4,a0
      *dst++ = *src++;
 4e8:	0585                	addi	a1,a1,1
 4ea:	0705                	addi	a4,a4,1
 4ec:	fff5c683          	lbu	a3,-1(a1)
 4f0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4f4:	fee79ae3          	bne	a5,a4,4e8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4f8:	6422                	ld	s0,8(sp)
 4fa:	0141                	addi	sp,sp,16
 4fc:	8082                	ret
    dst += n;
 4fe:	00c50733          	add	a4,a0,a2
    src += n;
 502:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 504:	fec05ae3          	blez	a2,4f8 <memmove+0x28>
 508:	fff6079b          	addiw	a5,a2,-1
 50c:	1782                	slli	a5,a5,0x20
 50e:	9381                	srli	a5,a5,0x20
 510:	fff7c793          	not	a5,a5
 514:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 516:	15fd                	addi	a1,a1,-1
 518:	177d                	addi	a4,a4,-1
 51a:	0005c683          	lbu	a3,0(a1)
 51e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 522:	fee79ae3          	bne	a5,a4,516 <memmove+0x46>
 526:	bfc9                	j	4f8 <memmove+0x28>

0000000000000528 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 528:	1141                	addi	sp,sp,-16
 52a:	e422                	sd	s0,8(sp)
 52c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 52e:	ca05                	beqz	a2,55e <memcmp+0x36>
 530:	fff6069b          	addiw	a3,a2,-1
 534:	1682                	slli	a3,a3,0x20
 536:	9281                	srli	a3,a3,0x20
 538:	0685                	addi	a3,a3,1
 53a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 53c:	00054783          	lbu	a5,0(a0)
 540:	0005c703          	lbu	a4,0(a1)
 544:	00e79863          	bne	a5,a4,554 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 548:	0505                	addi	a0,a0,1
    p2++;
 54a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 54c:	fed518e3          	bne	a0,a3,53c <memcmp+0x14>
  }
  return 0;
 550:	4501                	li	a0,0
 552:	a019                	j	558 <memcmp+0x30>
      return *p1 - *p2;
 554:	40e7853b          	subw	a0,a5,a4
}
 558:	6422                	ld	s0,8(sp)
 55a:	0141                	addi	sp,sp,16
 55c:	8082                	ret
  return 0;
 55e:	4501                	li	a0,0
 560:	bfe5                	j	558 <memcmp+0x30>

0000000000000562 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 562:	1141                	addi	sp,sp,-16
 564:	e406                	sd	ra,8(sp)
 566:	e022                	sd	s0,0(sp)
 568:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 56a:	00000097          	auipc	ra,0x0
 56e:	f66080e7          	jalr	-154(ra) # 4d0 <memmove>
}
 572:	60a2                	ld	ra,8(sp)
 574:	6402                	ld	s0,0(sp)
 576:	0141                	addi	sp,sp,16
 578:	8082                	ret

000000000000057a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 57a:	4885                	li	a7,1
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <exit>:
.global exit
exit:
 li a7, SYS_exit
 582:	4889                	li	a7,2
 ecall
 584:	00000073          	ecall
 ret
 588:	8082                	ret

000000000000058a <wait>:
.global wait
wait:
 li a7, SYS_wait
 58a:	488d                	li	a7,3
 ecall
 58c:	00000073          	ecall
 ret
 590:	8082                	ret

0000000000000592 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 592:	4891                	li	a7,4
 ecall
 594:	00000073          	ecall
 ret
 598:	8082                	ret

000000000000059a <read>:
.global read
read:
 li a7, SYS_read
 59a:	4895                	li	a7,5
 ecall
 59c:	00000073          	ecall
 ret
 5a0:	8082                	ret

00000000000005a2 <write>:
.global write
write:
 li a7, SYS_write
 5a2:	48c1                	li	a7,16
 ecall
 5a4:	00000073          	ecall
 ret
 5a8:	8082                	ret

00000000000005aa <close>:
.global close
close:
 li a7, SYS_close
 5aa:	48d5                	li	a7,21
 ecall
 5ac:	00000073          	ecall
 ret
 5b0:	8082                	ret

00000000000005b2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5b2:	4899                	li	a7,6
 ecall
 5b4:	00000073          	ecall
 ret
 5b8:	8082                	ret

00000000000005ba <exec>:
.global exec
exec:
 li a7, SYS_exec
 5ba:	489d                	li	a7,7
 ecall
 5bc:	00000073          	ecall
 ret
 5c0:	8082                	ret

00000000000005c2 <open>:
.global open
open:
 li a7, SYS_open
 5c2:	48bd                	li	a7,15
 ecall
 5c4:	00000073          	ecall
 ret
 5c8:	8082                	ret

00000000000005ca <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5ca:	48c5                	li	a7,17
 ecall
 5cc:	00000073          	ecall
 ret
 5d0:	8082                	ret

00000000000005d2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5d2:	48c9                	li	a7,18
 ecall
 5d4:	00000073          	ecall
 ret
 5d8:	8082                	ret

00000000000005da <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5da:	48a1                	li	a7,8
 ecall
 5dc:	00000073          	ecall
 ret
 5e0:	8082                	ret

00000000000005e2 <link>:
.global link
link:
 li a7, SYS_link
 5e2:	48cd                	li	a7,19
 ecall
 5e4:	00000073          	ecall
 ret
 5e8:	8082                	ret

00000000000005ea <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5ea:	48d1                	li	a7,20
 ecall
 5ec:	00000073          	ecall
 ret
 5f0:	8082                	ret

00000000000005f2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5f2:	48a5                	li	a7,9
 ecall
 5f4:	00000073          	ecall
 ret
 5f8:	8082                	ret

00000000000005fa <dup>:
.global dup
dup:
 li a7, SYS_dup
 5fa:	48a9                	li	a7,10
 ecall
 5fc:	00000073          	ecall
 ret
 600:	8082                	ret

0000000000000602 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 602:	48ad                	li	a7,11
 ecall
 604:	00000073          	ecall
 ret
 608:	8082                	ret

000000000000060a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 60a:	48b1                	li	a7,12
 ecall
 60c:	00000073          	ecall
 ret
 610:	8082                	ret

0000000000000612 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 612:	48b5                	li	a7,13
 ecall
 614:	00000073          	ecall
 ret
 618:	8082                	ret

000000000000061a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 61a:	48b9                	li	a7,14
 ecall
 61c:	00000073          	ecall
 ret
 620:	8082                	ret

0000000000000622 <getppid>:
.global getppid
getppid:
 li a7, SYS_getppid
 622:	48d9                	li	a7,22
 ecall
 624:	00000073          	ecall
 ret
 628:	8082                	ret

000000000000062a <yield>:
.global yield
yield:
 li a7, SYS_yield
 62a:	48dd                	li	a7,23
 ecall
 62c:	00000073          	ecall
 ret
 630:	8082                	ret

0000000000000632 <getpa>:
.global getpa
getpa:
 li a7, SYS_getpa
 632:	48e1                	li	a7,24
 ecall
 634:	00000073          	ecall
 ret
 638:	8082                	ret

000000000000063a <forkf>:
.global forkf
forkf:
 li a7, SYS_forkf
 63a:	48e5                	li	a7,25
 ecall
 63c:	00000073          	ecall
 ret
 640:	8082                	ret

0000000000000642 <waitpid>:
.global waitpid
waitpid:
 li a7, SYS_waitpid
 642:	48e9                	li	a7,26
 ecall
 644:	00000073          	ecall
 ret
 648:	8082                	ret

000000000000064a <ps>:
.global ps
ps:
 li a7, SYS_ps
 64a:	48ed                	li	a7,27
 ecall
 64c:	00000073          	ecall
 ret
 650:	8082                	ret

0000000000000652 <pinfo>:
.global pinfo
pinfo:
 li a7, SYS_pinfo
 652:	48f1                	li	a7,28
 ecall
 654:	00000073          	ecall
 ret
 658:	8082                	ret

000000000000065a <forkp>:
.global forkp
forkp:
 li a7, SYS_forkp
 65a:	48f5                	li	a7,29
 ecall
 65c:	00000073          	ecall
 ret
 660:	8082                	ret

0000000000000662 <schedpolicy>:
.global schedpolicy
schedpolicy:
 li a7, SYS_schedpolicy
 662:	48f9                	li	a7,30
 ecall
 664:	00000073          	ecall
 ret
 668:	8082                	ret

000000000000066a <barrier_alloc>:
.global barrier_alloc
barrier_alloc:
 li a7, SYS_barrier_alloc
 66a:	02100893          	li	a7,33
 ecall
 66e:	00000073          	ecall
 ret
 672:	8082                	ret

0000000000000674 <barrier>:
.global barrier
barrier:
 li a7, SYS_barrier
 674:	48fd                	li	a7,31
 ecall
 676:	00000073          	ecall
 ret
 67a:	8082                	ret

000000000000067c <barrier_free>:
.global barrier_free
barrier_free:
 li a7, SYS_barrier_free
 67c:	02000893          	li	a7,32
 ecall
 680:	00000073          	ecall
 ret
 684:	8082                	ret

0000000000000686 <buffer_cond_init>:
.global buffer_cond_init
buffer_cond_init:
 li a7, SYS_buffer_cond_init
 686:	02200893          	li	a7,34
 ecall
 68a:	00000073          	ecall
 ret
 68e:	8082                	ret

0000000000000690 <cond_produce>:
.global cond_produce
cond_produce:
 li a7, SYS_cond_produce
 690:	02300893          	li	a7,35
 ecall
 694:	00000073          	ecall
 ret
 698:	8082                	ret

000000000000069a <cond_consume>:
.global cond_consume
cond_consume:
 li a7, SYS_cond_consume
 69a:	02400893          	li	a7,36
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <buffer_sem_init>:
.global buffer_sem_init
buffer_sem_init:
 li a7, SYS_buffer_sem_init
 6a4:	02500893          	li	a7,37
 ecall
 6a8:	00000073          	ecall
 ret
 6ac:	8082                	ret

00000000000006ae <sem_produce>:
.global sem_produce
sem_produce:
 li a7, SYS_sem_produce
 6ae:	02700893          	li	a7,39
 ecall
 6b2:	00000073          	ecall
 ret
 6b6:	8082                	ret

00000000000006b8 <sem_consume>:
.global sem_consume
sem_consume:
 li a7, SYS_sem_consume
 6b8:	02600893          	li	a7,38
 ecall
 6bc:	00000073          	ecall
 ret
 6c0:	8082                	ret

00000000000006c2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 6c2:	1101                	addi	sp,sp,-32
 6c4:	ec06                	sd	ra,24(sp)
 6c6:	e822                	sd	s0,16(sp)
 6c8:	1000                	addi	s0,sp,32
 6ca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 6ce:	4605                	li	a2,1
 6d0:	fef40593          	addi	a1,s0,-17
 6d4:	00000097          	auipc	ra,0x0
 6d8:	ece080e7          	jalr	-306(ra) # 5a2 <write>
}
 6dc:	60e2                	ld	ra,24(sp)
 6de:	6442                	ld	s0,16(sp)
 6e0:	6105                	addi	sp,sp,32
 6e2:	8082                	ret

00000000000006e4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6e4:	7139                	addi	sp,sp,-64
 6e6:	fc06                	sd	ra,56(sp)
 6e8:	f822                	sd	s0,48(sp)
 6ea:	f426                	sd	s1,40(sp)
 6ec:	f04a                	sd	s2,32(sp)
 6ee:	ec4e                	sd	s3,24(sp)
 6f0:	0080                	addi	s0,sp,64
 6f2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6f4:	c299                	beqz	a3,6fa <printint+0x16>
 6f6:	0805c963          	bltz	a1,788 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6fa:	2581                	sext.w	a1,a1
  neg = 0;
 6fc:	4881                	li	a7,0
 6fe:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 702:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 704:	2601                	sext.w	a2,a2
 706:	00000517          	auipc	a0,0x0
 70a:	55250513          	addi	a0,a0,1362 # c58 <digits>
 70e:	883a                	mv	a6,a4
 710:	2705                	addiw	a4,a4,1
 712:	02c5f7bb          	remuw	a5,a1,a2
 716:	1782                	slli	a5,a5,0x20
 718:	9381                	srli	a5,a5,0x20
 71a:	97aa                	add	a5,a5,a0
 71c:	0007c783          	lbu	a5,0(a5)
 720:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 724:	0005879b          	sext.w	a5,a1
 728:	02c5d5bb          	divuw	a1,a1,a2
 72c:	0685                	addi	a3,a3,1
 72e:	fec7f0e3          	bgeu	a5,a2,70e <printint+0x2a>
  if(neg)
 732:	00088c63          	beqz	a7,74a <printint+0x66>
    buf[i++] = '-';
 736:	fd070793          	addi	a5,a4,-48
 73a:	00878733          	add	a4,a5,s0
 73e:	02d00793          	li	a5,45
 742:	fef70823          	sb	a5,-16(a4)
 746:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 74a:	02e05863          	blez	a4,77a <printint+0x96>
 74e:	fc040793          	addi	a5,s0,-64
 752:	00e78933          	add	s2,a5,a4
 756:	fff78993          	addi	s3,a5,-1
 75a:	99ba                	add	s3,s3,a4
 75c:	377d                	addiw	a4,a4,-1
 75e:	1702                	slli	a4,a4,0x20
 760:	9301                	srli	a4,a4,0x20
 762:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 766:	fff94583          	lbu	a1,-1(s2)
 76a:	8526                	mv	a0,s1
 76c:	00000097          	auipc	ra,0x0
 770:	f56080e7          	jalr	-170(ra) # 6c2 <putc>
  while(--i >= 0)
 774:	197d                	addi	s2,s2,-1
 776:	ff3918e3          	bne	s2,s3,766 <printint+0x82>
}
 77a:	70e2                	ld	ra,56(sp)
 77c:	7442                	ld	s0,48(sp)
 77e:	74a2                	ld	s1,40(sp)
 780:	7902                	ld	s2,32(sp)
 782:	69e2                	ld	s3,24(sp)
 784:	6121                	addi	sp,sp,64
 786:	8082                	ret
    x = -xx;
 788:	40b005bb          	negw	a1,a1
    neg = 1;
 78c:	4885                	li	a7,1
    x = -xx;
 78e:	bf85                	j	6fe <printint+0x1a>

0000000000000790 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 790:	7119                	addi	sp,sp,-128
 792:	fc86                	sd	ra,120(sp)
 794:	f8a2                	sd	s0,112(sp)
 796:	f4a6                	sd	s1,104(sp)
 798:	f0ca                	sd	s2,96(sp)
 79a:	ecce                	sd	s3,88(sp)
 79c:	e8d2                	sd	s4,80(sp)
 79e:	e4d6                	sd	s5,72(sp)
 7a0:	e0da                	sd	s6,64(sp)
 7a2:	fc5e                	sd	s7,56(sp)
 7a4:	f862                	sd	s8,48(sp)
 7a6:	f466                	sd	s9,40(sp)
 7a8:	f06a                	sd	s10,32(sp)
 7aa:	ec6e                	sd	s11,24(sp)
 7ac:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 7ae:	0005c903          	lbu	s2,0(a1)
 7b2:	18090f63          	beqz	s2,950 <vprintf+0x1c0>
 7b6:	8aaa                	mv	s5,a0
 7b8:	8b32                	mv	s6,a2
 7ba:	00158493          	addi	s1,a1,1
  state = 0;
 7be:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 7c0:	02500a13          	li	s4,37
 7c4:	4c55                	li	s8,21
 7c6:	00000c97          	auipc	s9,0x0
 7ca:	43ac8c93          	addi	s9,s9,1082 # c00 <malloc+0x1ac>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 7ce:	02800d93          	li	s11,40
  putc(fd, 'x');
 7d2:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d4:	00000b97          	auipc	s7,0x0
 7d8:	484b8b93          	addi	s7,s7,1156 # c58 <digits>
 7dc:	a839                	j	7fa <vprintf+0x6a>
        putc(fd, c);
 7de:	85ca                	mv	a1,s2
 7e0:	8556                	mv	a0,s5
 7e2:	00000097          	auipc	ra,0x0
 7e6:	ee0080e7          	jalr	-288(ra) # 6c2 <putc>
 7ea:	a019                	j	7f0 <vprintf+0x60>
    } else if(state == '%'){
 7ec:	01498d63          	beq	s3,s4,806 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 7f0:	0485                	addi	s1,s1,1
 7f2:	fff4c903          	lbu	s2,-1(s1)
 7f6:	14090d63          	beqz	s2,950 <vprintf+0x1c0>
    if(state == 0){
 7fa:	fe0999e3          	bnez	s3,7ec <vprintf+0x5c>
      if(c == '%'){
 7fe:	ff4910e3          	bne	s2,s4,7de <vprintf+0x4e>
        state = '%';
 802:	89d2                	mv	s3,s4
 804:	b7f5                	j	7f0 <vprintf+0x60>
      if(c == 'd'){
 806:	11490c63          	beq	s2,s4,91e <vprintf+0x18e>
 80a:	f9d9079b          	addiw	a5,s2,-99
 80e:	0ff7f793          	zext.b	a5,a5
 812:	10fc6e63          	bltu	s8,a5,92e <vprintf+0x19e>
 816:	f9d9079b          	addiw	a5,s2,-99
 81a:	0ff7f713          	zext.b	a4,a5
 81e:	10ec6863          	bltu	s8,a4,92e <vprintf+0x19e>
 822:	00271793          	slli	a5,a4,0x2
 826:	97e6                	add	a5,a5,s9
 828:	439c                	lw	a5,0(a5)
 82a:	97e6                	add	a5,a5,s9
 82c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 82e:	008b0913          	addi	s2,s6,8
 832:	4685                	li	a3,1
 834:	4629                	li	a2,10
 836:	000b2583          	lw	a1,0(s6)
 83a:	8556                	mv	a0,s5
 83c:	00000097          	auipc	ra,0x0
 840:	ea8080e7          	jalr	-344(ra) # 6e4 <printint>
 844:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 846:	4981                	li	s3,0
 848:	b765                	j	7f0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 84a:	008b0913          	addi	s2,s6,8
 84e:	4681                	li	a3,0
 850:	4629                	li	a2,10
 852:	000b2583          	lw	a1,0(s6)
 856:	8556                	mv	a0,s5
 858:	00000097          	auipc	ra,0x0
 85c:	e8c080e7          	jalr	-372(ra) # 6e4 <printint>
 860:	8b4a                	mv	s6,s2
      state = 0;
 862:	4981                	li	s3,0
 864:	b771                	j	7f0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 866:	008b0913          	addi	s2,s6,8
 86a:	4681                	li	a3,0
 86c:	866a                	mv	a2,s10
 86e:	000b2583          	lw	a1,0(s6)
 872:	8556                	mv	a0,s5
 874:	00000097          	auipc	ra,0x0
 878:	e70080e7          	jalr	-400(ra) # 6e4 <printint>
 87c:	8b4a                	mv	s6,s2
      state = 0;
 87e:	4981                	li	s3,0
 880:	bf85                	j	7f0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 882:	008b0793          	addi	a5,s6,8
 886:	f8f43423          	sd	a5,-120(s0)
 88a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 88e:	03000593          	li	a1,48
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	e2e080e7          	jalr	-466(ra) # 6c2 <putc>
  putc(fd, 'x');
 89c:	07800593          	li	a1,120
 8a0:	8556                	mv	a0,s5
 8a2:	00000097          	auipc	ra,0x0
 8a6:	e20080e7          	jalr	-480(ra) # 6c2 <putc>
 8aa:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8ac:	03c9d793          	srli	a5,s3,0x3c
 8b0:	97de                	add	a5,a5,s7
 8b2:	0007c583          	lbu	a1,0(a5)
 8b6:	8556                	mv	a0,s5
 8b8:	00000097          	auipc	ra,0x0
 8bc:	e0a080e7          	jalr	-502(ra) # 6c2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8c0:	0992                	slli	s3,s3,0x4
 8c2:	397d                	addiw	s2,s2,-1
 8c4:	fe0914e3          	bnez	s2,8ac <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 8c8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 8cc:	4981                	li	s3,0
 8ce:	b70d                	j	7f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 8d0:	008b0913          	addi	s2,s6,8
 8d4:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 8d8:	02098163          	beqz	s3,8fa <vprintf+0x16a>
        while(*s != 0){
 8dc:	0009c583          	lbu	a1,0(s3)
 8e0:	c5ad                	beqz	a1,94a <vprintf+0x1ba>
          putc(fd, *s);
 8e2:	8556                	mv	a0,s5
 8e4:	00000097          	auipc	ra,0x0
 8e8:	dde080e7          	jalr	-546(ra) # 6c2 <putc>
          s++;
 8ec:	0985                	addi	s3,s3,1
        while(*s != 0){
 8ee:	0009c583          	lbu	a1,0(s3)
 8f2:	f9e5                	bnez	a1,8e2 <vprintf+0x152>
        s = va_arg(ap, char*);
 8f4:	8b4a                	mv	s6,s2
      state = 0;
 8f6:	4981                	li	s3,0
 8f8:	bde5                	j	7f0 <vprintf+0x60>
          s = "(null)";
 8fa:	00000997          	auipc	s3,0x0
 8fe:	2fe98993          	addi	s3,s3,766 # bf8 <malloc+0x1a4>
        while(*s != 0){
 902:	85ee                	mv	a1,s11
 904:	bff9                	j	8e2 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 906:	008b0913          	addi	s2,s6,8
 90a:	000b4583          	lbu	a1,0(s6)
 90e:	8556                	mv	a0,s5
 910:	00000097          	auipc	ra,0x0
 914:	db2080e7          	jalr	-590(ra) # 6c2 <putc>
 918:	8b4a                	mv	s6,s2
      state = 0;
 91a:	4981                	li	s3,0
 91c:	bdd1                	j	7f0 <vprintf+0x60>
        putc(fd, c);
 91e:	85d2                	mv	a1,s4
 920:	8556                	mv	a0,s5
 922:	00000097          	auipc	ra,0x0
 926:	da0080e7          	jalr	-608(ra) # 6c2 <putc>
      state = 0;
 92a:	4981                	li	s3,0
 92c:	b5d1                	j	7f0 <vprintf+0x60>
        putc(fd, '%');
 92e:	85d2                	mv	a1,s4
 930:	8556                	mv	a0,s5
 932:	00000097          	auipc	ra,0x0
 936:	d90080e7          	jalr	-624(ra) # 6c2 <putc>
        putc(fd, c);
 93a:	85ca                	mv	a1,s2
 93c:	8556                	mv	a0,s5
 93e:	00000097          	auipc	ra,0x0
 942:	d84080e7          	jalr	-636(ra) # 6c2 <putc>
      state = 0;
 946:	4981                	li	s3,0
 948:	b565                	j	7f0 <vprintf+0x60>
        s = va_arg(ap, char*);
 94a:	8b4a                	mv	s6,s2
      state = 0;
 94c:	4981                	li	s3,0
 94e:	b54d                	j	7f0 <vprintf+0x60>
    }
  }
}
 950:	70e6                	ld	ra,120(sp)
 952:	7446                	ld	s0,112(sp)
 954:	74a6                	ld	s1,104(sp)
 956:	7906                	ld	s2,96(sp)
 958:	69e6                	ld	s3,88(sp)
 95a:	6a46                	ld	s4,80(sp)
 95c:	6aa6                	ld	s5,72(sp)
 95e:	6b06                	ld	s6,64(sp)
 960:	7be2                	ld	s7,56(sp)
 962:	7c42                	ld	s8,48(sp)
 964:	7ca2                	ld	s9,40(sp)
 966:	7d02                	ld	s10,32(sp)
 968:	6de2                	ld	s11,24(sp)
 96a:	6109                	addi	sp,sp,128
 96c:	8082                	ret

000000000000096e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 96e:	715d                	addi	sp,sp,-80
 970:	ec06                	sd	ra,24(sp)
 972:	e822                	sd	s0,16(sp)
 974:	1000                	addi	s0,sp,32
 976:	e010                	sd	a2,0(s0)
 978:	e414                	sd	a3,8(s0)
 97a:	e818                	sd	a4,16(s0)
 97c:	ec1c                	sd	a5,24(s0)
 97e:	03043023          	sd	a6,32(s0)
 982:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 986:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 98a:	8622                	mv	a2,s0
 98c:	00000097          	auipc	ra,0x0
 990:	e04080e7          	jalr	-508(ra) # 790 <vprintf>
}
 994:	60e2                	ld	ra,24(sp)
 996:	6442                	ld	s0,16(sp)
 998:	6161                	addi	sp,sp,80
 99a:	8082                	ret

000000000000099c <printf>:

void
printf(const char *fmt, ...)
{
 99c:	711d                	addi	sp,sp,-96
 99e:	ec06                	sd	ra,24(sp)
 9a0:	e822                	sd	s0,16(sp)
 9a2:	1000                	addi	s0,sp,32
 9a4:	e40c                	sd	a1,8(s0)
 9a6:	e810                	sd	a2,16(s0)
 9a8:	ec14                	sd	a3,24(s0)
 9aa:	f018                	sd	a4,32(s0)
 9ac:	f41c                	sd	a5,40(s0)
 9ae:	03043823          	sd	a6,48(s0)
 9b2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9b6:	00840613          	addi	a2,s0,8
 9ba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9be:	85aa                	mv	a1,a0
 9c0:	4505                	li	a0,1
 9c2:	00000097          	auipc	ra,0x0
 9c6:	dce080e7          	jalr	-562(ra) # 790 <vprintf>
}
 9ca:	60e2                	ld	ra,24(sp)
 9cc:	6442                	ld	s0,16(sp)
 9ce:	6125                	addi	sp,sp,96
 9d0:	8082                	ret

00000000000009d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9d2:	1141                	addi	sp,sp,-16
 9d4:	e422                	sd	s0,8(sp)
 9d6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9d8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9dc:	00000797          	auipc	a5,0x0
 9e0:	2947b783          	ld	a5,660(a5) # c70 <freep>
 9e4:	a02d                	j	a0e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9e6:	4618                	lw	a4,8(a2)
 9e8:	9f2d                	addw	a4,a4,a1
 9ea:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9ee:	6398                	ld	a4,0(a5)
 9f0:	6310                	ld	a2,0(a4)
 9f2:	a83d                	j	a30 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9f4:	ff852703          	lw	a4,-8(a0)
 9f8:	9f31                	addw	a4,a4,a2
 9fa:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9fc:	ff053683          	ld	a3,-16(a0)
 a00:	a091                	j	a44 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a02:	6398                	ld	a4,0(a5)
 a04:	00e7e463          	bltu	a5,a4,a0c <free+0x3a>
 a08:	00e6ea63          	bltu	a3,a4,a1c <free+0x4a>
{
 a0c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a0e:	fed7fae3          	bgeu	a5,a3,a02 <free+0x30>
 a12:	6398                	ld	a4,0(a5)
 a14:	00e6e463          	bltu	a3,a4,a1c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a18:	fee7eae3          	bltu	a5,a4,a0c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a1c:	ff852583          	lw	a1,-8(a0)
 a20:	6390                	ld	a2,0(a5)
 a22:	02059813          	slli	a6,a1,0x20
 a26:	01c85713          	srli	a4,a6,0x1c
 a2a:	9736                	add	a4,a4,a3
 a2c:	fae60de3          	beq	a2,a4,9e6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a30:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a34:	4790                	lw	a2,8(a5)
 a36:	02061593          	slli	a1,a2,0x20
 a3a:	01c5d713          	srli	a4,a1,0x1c
 a3e:	973e                	add	a4,a4,a5
 a40:	fae68ae3          	beq	a3,a4,9f4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a44:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a46:	00000717          	auipc	a4,0x0
 a4a:	22f73523          	sd	a5,554(a4) # c70 <freep>
}
 a4e:	6422                	ld	s0,8(sp)
 a50:	0141                	addi	sp,sp,16
 a52:	8082                	ret

0000000000000a54 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a54:	7139                	addi	sp,sp,-64
 a56:	fc06                	sd	ra,56(sp)
 a58:	f822                	sd	s0,48(sp)
 a5a:	f426                	sd	s1,40(sp)
 a5c:	f04a                	sd	s2,32(sp)
 a5e:	ec4e                	sd	s3,24(sp)
 a60:	e852                	sd	s4,16(sp)
 a62:	e456                	sd	s5,8(sp)
 a64:	e05a                	sd	s6,0(sp)
 a66:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a68:	02051493          	slli	s1,a0,0x20
 a6c:	9081                	srli	s1,s1,0x20
 a6e:	04bd                	addi	s1,s1,15
 a70:	8091                	srli	s1,s1,0x4
 a72:	0014899b          	addiw	s3,s1,1
 a76:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a78:	00000517          	auipc	a0,0x0
 a7c:	1f853503          	ld	a0,504(a0) # c70 <freep>
 a80:	c515                	beqz	a0,aac <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a82:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a84:	4798                	lw	a4,8(a5)
 a86:	02977f63          	bgeu	a4,s1,ac4 <malloc+0x70>
 a8a:	8a4e                	mv	s4,s3
 a8c:	0009871b          	sext.w	a4,s3
 a90:	6685                	lui	a3,0x1
 a92:	00d77363          	bgeu	a4,a3,a98 <malloc+0x44>
 a96:	6a05                	lui	s4,0x1
 a98:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a9c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 aa0:	00000917          	auipc	s2,0x0
 aa4:	1d090913          	addi	s2,s2,464 # c70 <freep>
  if(p == (char*)-1)
 aa8:	5afd                	li	s5,-1
 aaa:	a895                	j	b1e <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 aac:	00000797          	auipc	a5,0x0
 ab0:	1dc78793          	addi	a5,a5,476 # c88 <base>
 ab4:	00000717          	auipc	a4,0x0
 ab8:	1af73e23          	sd	a5,444(a4) # c70 <freep>
 abc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 abe:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ac2:	b7e1                	j	a8a <malloc+0x36>
      if(p->s.size == nunits)
 ac4:	02e48c63          	beq	s1,a4,afc <malloc+0xa8>
        p->s.size -= nunits;
 ac8:	4137073b          	subw	a4,a4,s3
 acc:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ace:	02071693          	slli	a3,a4,0x20
 ad2:	01c6d713          	srli	a4,a3,0x1c
 ad6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ad8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 adc:	00000717          	auipc	a4,0x0
 ae0:	18a73a23          	sd	a0,404(a4) # c70 <freep>
      return (void*)(p + 1);
 ae4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ae8:	70e2                	ld	ra,56(sp)
 aea:	7442                	ld	s0,48(sp)
 aec:	74a2                	ld	s1,40(sp)
 aee:	7902                	ld	s2,32(sp)
 af0:	69e2                	ld	s3,24(sp)
 af2:	6a42                	ld	s4,16(sp)
 af4:	6aa2                	ld	s5,8(sp)
 af6:	6b02                	ld	s6,0(sp)
 af8:	6121                	addi	sp,sp,64
 afa:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 afc:	6398                	ld	a4,0(a5)
 afe:	e118                	sd	a4,0(a0)
 b00:	bff1                	j	adc <malloc+0x88>
  hp->s.size = nu;
 b02:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b06:	0541                	addi	a0,a0,16
 b08:	00000097          	auipc	ra,0x0
 b0c:	eca080e7          	jalr	-310(ra) # 9d2 <free>
  return freep;
 b10:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b14:	d971                	beqz	a0,ae8 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b16:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b18:	4798                	lw	a4,8(a5)
 b1a:	fa9775e3          	bgeu	a4,s1,ac4 <malloc+0x70>
    if(p == freep)
 b1e:	00093703          	ld	a4,0(s2)
 b22:	853e                	mv	a0,a5
 b24:	fef719e3          	bne	a4,a5,b16 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 b28:	8552                	mv	a0,s4
 b2a:	00000097          	auipc	ra,0x0
 b2e:	ae0080e7          	jalr	-1312(ra) # 60a <sbrk>
  if(p == (char*)-1)
 b32:	fd5518e3          	bne	a0,s5,b02 <malloc+0xae>
        return 0;
 b36:	4501                	li	a0,0
 b38:	bf45                	j	ae8 <malloc+0x94>
