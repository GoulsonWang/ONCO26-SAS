/* ============================================
   第一阶段：认识宏变量
   目标：用宏变量替代固定路径和文件名
   ============================================ */

/* ----- 1.1 定义宏变量（相当于给值起一个名字） ----- */
/* %符号是引用，let是赋值 */
%let mypath = /home/u64589246/ONCO26/;    /* 路径 */
%let dmfile = raw_dm.csv;                 /* 人口学文件名 */
%let survfile = raw_survival.csv;         /* 生存文件名 */

/* ----- 1.2 用宏变量替代硬编码路径 ----- */
/* 之前你写的是：
   proc import datafile="/home/u64589246/ONCO26/raw_dm.csv" ...;
   现在变成下面这样： */

proc import datafile="&mypath.&dmfile"		/*此处将两个变量链接*/
    out=raw_dm			/*将该数据集在SAS工作区的名称命名为raw_dm*/
    dbms=csv
    replace;			/*如果SAS工作区有重名的数据集，则进行覆盖*/
    guessingrows=1000;			/*查看前1000条数据来判断每个变量类型*/
run;

proc import datafile="&mypath.&survfile"
    out=raw_survival
    dbms=csv
    replace;
    guessingrows=1000;
run;

/* ----- 1.3 查看宏变量的值（在日志中显示） ----- */
%put 当前数据路径: &mypath;
%put 人口学文件: &dmfile;
%put 生存文件: &survfile;



/* ============================================
   第二阶段：封装重复的 PROC IMPORT
   目标：定义一个宏，以后一句话即可导入CSV
   ============================================ */

/* ----- 2.1 定义宏（封装模板） ----- */
%macro import_csv(file=, out=, guess=1000);			
/*macro是定义宏，类比于R中的function*/

    /* 【宏内部代码区】—— 这里写你想要重复执行的代码 */
    proc import datafile="&mypath.&file"
        out=&out
        dbms=csv
        replace;
        guessingrows=&guess;
    run;

%mend import_csv;		/*结束宏定义*/

/* ----- 2.2 现在调用宏（执行命令） ----- */

/* 调用方式1：导入人口学数据 */
%import_csv(file=&dmfile, out=raw_dm);

/* 调用方式2：导入生存数据 */
%import_csv(file=&survfile, out=raw_survival);

/* 调用方式3：如果我想修改猜测行数（比如只扫500行），可以这样覆盖默认值 */
%import_csv(file=&dmfile, out=raw_dm_test, guess=500);



/* ============================================
   第三阶段：构建 ADSL 的标准化宏
   目标：将变量名和标签变成参数，适应不同研究
   ============================================ */

%macro build_adsl(
    /* 必填参数 */
    indata=,          /* 输入的人口学数据集，如 raw_dm */
    
    /* 可选参数（带默认值，adsl的标准是全小写） */
    outdata=adsl,     /* 输出的数据集名称 */
    id=SUBJID,        /* 受试者ID变量 */
    age=AGE,          /* 年龄变量 */
    sex=SEX,          /* 性别变量 */
    race=RACE,        /* 种族变量 */
    bmi=BMI,          /* BMI变量 */
    arm=ARM,          /* 分组变量名 */
    arm_active=ARM A, /* 试验组取值 */
    arm_placebo=ARM B /* 对照组取值 */
);

    /* ----- 宏核心逻辑（开始构建数据）----- */
    data &outdata;		/*创建一个数据集*/
        set &indata;		/*读取indata数据集*/
        
        /* 1. 派生治疗分组（标准化命名 TRT） */
        length TRT $10;			
        /*length定义变量的存储属性，TRT为新变量名字，$表示字符型，10表示长度10*/
        if &arm = "&arm_active" then TRT = "Active";	
        /*标准化分组变量名arm为Active和Placebo*/
        else if &arm = "&arm_placebo" then TRT = "Placebo";
        else TRT = "Unknown";			/*质控保险丝，暴露脏数据*/
        
        /* 2. 添加变量标签（增强可读性） */
        label &id  = "Subject Identifier"		/*给变量加上人类可读的描述*/
              &age = "Age (years)"
              &sex = "Sex"
              &race = "Race"
              &bmi = "Body Mass Index (kg/m2)"
              &arm = "Treatment Arm (Raw)"
              TRT  = "Treatment Group (Derived)";		/*给新造的TRT变量添加标签*/
        
        /* 3. 保留核心变量（&id 和 &arm 会被替换成实际变量名） */
        keep &id &age &sex &race &bmi &arm TRT;			
        /*仅仅保留keep后面的这些变量，其余变量舍弃*/
    run;

%mend build_adsl;



/* ============================================
   第四阶段：构建 ADTTE 的标准化宏
   目标：将生存数据转换为 CDISC ADaM 标准
   ============================================ */

%macro build_adtte(
    /* ----- 必填参数 ----- */
    indata=,                /* 输入的生存数据集，如 raw_survival */
    
    /* ----- 可选参数（带默认值，适配本项目） ----- */
    outdata=adtte,          /* 输出的数据集名称 */
    id=SUBJID,              /* 受试者ID变量名 */
    time=OS_DAYS,           /* 生存时间变量（天） */
    event=EVENT_STATUS,     /* 事件状态变量（1=死亡，0=删失） */
    paramcd=OS,             /* 参数代码（如 OS, PFS, DFS） */
    param=Overall Survival, /* 参数全称 */
    arm=ARM                 /* 分组变量名（保留用于后续分析） */
);

    /* ----- 核心 DATA 步：标准化映射 ----- */
    data &outdata;
        set &indata;
        
        /* 1. 分析值（生存时间） */
        AVAL = &time;
        
        /* 2. 删失指示符（CDISC 标准：0=事件，1=删失） */
        /* 原始 event=1 表示死亡，所以用 1 减去原值完成反转 */
        CNSR = 1 - &event;
        
        /* 3. 参数标识（固定值） */
        PARAMCD = "&paramcd";
        PARAM = "&param";
        
        /* 4. 事件/删失描述（用于列表输出） */
        length EVNTDESC $20;
        if &event = 1 then EVNTDESC = "DEATH";
        else EVNTDESC = "CENSORED";
        
        /* 5. 添加变量标签（增强可读性） */
        label AVAL     = "Analysis Value (Survival Days)"
              CNSR     = "Censoring Indicator (0=Event, 1=Censored)"
              PARAMCD  = "Parameter Code"
              PARAM    = "Parameter Description"
              EVNTDESC = "Event/Censoring Description";
        
        /* 6. 保留核心变量（保留 arm 便于后续分层分析） */
        keep &id AVAL CNSR PARAMCD PARAM EVNTDESC &arm;
    run;

%mend build_adtte;