#!/bin/bash
#变量池
    #用于返回查询身份证号的信息是否存在
    SEARCHFLAG1=;
    #用于返回查询身份证号的信息所在行
    SEARCHINFO1=;
    #试管编号
    TUBEID=0;
    #试管是否封装
    TUBEFLAG=0;
    #试管编号是否存在
    TUBESEARCHFLAG=0;
    #试管是否被检测
    TUBECHECK=0;
    #按照yyyy-mm-dd MM:SS获取当前时间
    nowtime=0;
#获取当前时间
function getNowTime(){
    nowtime=$(date --date='0 days ago' "+%Y-%m-%d %H:%M:%S");
}
#市民身份登录
#查询person.txt中的信息
function searchPerson(){
    SEARCHFLAG1=$(sed -n "/$1/=" person.txt);
    SEARCHINFO1=$(sed -n "/$1/p" person.txt);
}
#查询sample.txt中的信息
function searchSample(){
    TUBESEARCHFLAG=$(sed -n "/$1/p" sample.txt);
}
#个人信息登记
function addPersonalInfo(){
    local ID_Num;
    local name;
    local Address;
    local phoneNumber;
    while [[ 1 ]]
    do
            read -p "请输入您的身份证号：" ID_Num;
            searchPerson $ID_Num;
            if [ "${#ID_Num}" -ne 18 ];then
                echo "输入正确的身份证号！"
            elif [ -n "$SEARCHFLAG1" ];then
                 echo "该身份证号已存在！"
            else break
            fi
    done
    read -p "请输入您的姓名：" name;
    read -p "请输入您的家庭住址：" Address;
    while [[ 1 ]]
    do
        read -p "请输入您的手机号码：" phoneNumber;
        if [ "${#phoneNumber}" -ne 11 ];then
             echo "请输入11位手机号码！"
        else break
        fi
    done
    echo "$ID_Num $name $Address $phoneNumber" >> /home/zzy/桌面/NAT/person.txt;
    echo "信息已经录入!";
    echo "系统将自动返回……";sleep 1.5s;clear;
}
#个人信息修改
function updatePersonInfo () {
    local ID;
    local name;
    local address;
    local phoneNumber;
    read -p "请输入已登记的身份证号：" ID;
    searchPerson ${ID};
    if [ -z "$SEARCHFLAG1" ];then
        echo "输入的身份证号未登记，请先登记。";
    else
        echo "根据身份证号:$ID查询到的信息有：";
        SEARCHINFO1=${SEARCHINFO1#* };
        name=${SEARCHINFO1%% *};
        SEARCHINFO1=${SEARCHINFO1#* };
        echo "姓名:$name"
        address=${SEARCHINFO1%% *};
        echo "家庭住址:$address";
        phoneNumber=${SEARCHINFO1#* };
        echo "联系电话:$phoneNumber";
        echo "======================================"
		echo "=      请输入要修改的值的序号        ="
		echo "======================================"
		echo "=0.退出修改 1.姓名 2.家庭住址 3.电话 ="
		echo "======================================"
        local key=-1;
        while [ $key -ne 0 ]
        do
            read -p "input operation char:" key;
            case "${key}" in
            0)
                break;
            ;;
            1)
                read -p "输入新的姓名：" name;
            ;;
             2)
                read -p "输入新的家庭住址：" address;
            ;;
            3)
            while [[ 1 ]]
                     do
                          read -p "请输入您的手机号码：" phoneNumber;
                         if [ "${#phoneNumber}" -ne 11 ];then
                          echo "请输入11位手机号码！"
                          else break
                          fi
                    done
            ;;
            *)
                 echo "无效操作符，请重新输入！";sleep 0.5s;
            ;;
            esac
        done
    sed -i "${SEARCHFLAG1}c ${ID} ${name} ${address} ${phoneNumber}" person.txt
    echo "修改成功,等待系统刷新";sleep 1.5s;clear;
    fi
}
#核酸结果查询
function searchNAResult(){
    local ID_Num;
    local name;
     while [[ 1 ]]
    do
            read -p "请输入您的身份证号：" ID_Num;
            searchPerson $ID_Num;
            if [ "${#ID_Num}" -ne 18 ];then
                echo "输入正确的身份证号！"
            elif [ -z "$SEARCHFLAG1" ];then
                 echo "该身份证号不存在！"
            else break
            fi
    done
    echo "查询到以下信息：";
    #这个查询语句比较复杂
    #首先将身份证号为$ID_NUM的信息筛选出来
    #然后判断这些信息里有没有核酸结果还没出的
    #若核酸结果已出，打印相应列
    #将这些信息倒序即按照时间先后顺序输出
    sed -n "/$ID_Num/p" sample.txt|awk -F ' ' '{if($8=="阴性"||$7=="阳性") print $2,$3,$4,$8,$9,$10}'|tac;
    sleep 5s;clear;
}
#市民主菜单
function citizensMenu () {
    local key=0;
    while [ $key -ne 4 ]
        do
           echo "============================================"
	       echo "=            欢迎来到核酸检测系统          ="
	       echo "=           当前登录的身份是：市民         ="
           echo "============================================"
	       echo "=              1.个人信息登记              ="
           echo "=              2.修改个人信息              ="
	       echo "=              3.核酸结果查询              ="
	       echo "=              4.注销当前登录              ="
	       echo "============================================"
           read -p "input operation char:" key;
        case "${key}" in
        1)
            clear;addPersonalInfo;
        ;;
        2)
            clear;updatePersonInfo;
        ;;
        3)
            searchNAResult;
        ;;
        4)echo "正在注销当前用户登录……";sleep 1.5s;clear;
        ;;
        *)
            echo "无效操作符，请重新输入！";sleep 0.5s;clear;
        ;;
      esac
    done
}
#核酸采样人员登录
#添加试管信息
function addTubeInfo(){
    if [ "$TUBEFLAG" -eq 0 ]&&[ "$TUBEID" -eq 0 ];then
        while [[ 1 ]]
        do 
            read -p "输入试管编号：" TUBEID;
            searchSample ${TUBEID};
            if [ "${#TUBEID}" -ne 6 ];then
                echo "请输入正确的试管编号";
            elif [ -n "$TUBESEARCHFLAG" ];then
                echo "该试管已被录入，请检查试管编号是否输入正确！";
            else
                TUBEFLAG=0;
                getNowTime;
                echo "$TUBEID $TUBECHECK $nowtime <--" >> sample.txt;
                echo "试管号$TUBEID信息已经添加成功!";sleep 1.5s;clear;
                break
            fi
        done
    else
        echo "当前还存在为试管编号$TUBEID未封管，请先封管";
    fi
}
#添加样本信息
function addSampleInfo(){
    if [ "$TUBEID" -eq 0 ];then
        echo "当前没有试管被启用，请添加试管。";sleep 1.5s;clear;
    else
        clear;
        local samplingname;
        local takenAddress;
        read -p "请输入采样员姓名：" samplingname;
        echo "请选择采集地址:";
        select takenAddress in 瑶海区采集点 包和区采集点
        do
            break
        done
        echo "您选择的是$takenAddress";
        #判断是否封管
        local quitflag=0;
        local takenid;
        local takenname;
        local num=0;
        echo "采样员:$samplingname";
        echo "======================================"
		echo "=       欢迎来到核酸采样系统         ="
		echo "=      当前试管编号为：$TUBEID       ="
		echo "======================================"
		echo "=           输入"!q"封管             ="
		echo "======================================"
        for((num=1;num<=10;num++)); do
            while [[ 1 ]]
            do
                read -p "请输入被采人身份证号：" takenid;
                if [ "$takenid" == "!q" ];then
                    let "quitflag=1";break
                fi
                searchPerson $takenid;
                if [ "${#takenid}" -ne 18 ];then
                    echo "输入正确的身份证号！"
                elif [ -z "$SEARCHFLAG1" ];then
                    echo "该身份证号还未登记，请先登记！";
                else break
                fi
            done
            if [ "$quitflag" -eq 1 ];then
                break
            fi
            getNowTime;
            SEARCHINFO1=${SEARCHINFO1#* };
            takenname=${SEARCHINFO1%% *};
            echo "当前添加被采人员为${takenname}-->添加成功！";
            echo "$TUBEID $takenid $takenname $takenAddress $nowtime $samplingname result testtime tester">>sample.txt;
            echo "当前试管已有${num}个样本"
        done
        let "TUBEID=0";
        let "TUBEFLAG=1";
        if [ "$num" -eq 11 ];then
            echo "当前试管已满（已自动封管），请添加新的试管信息";sleep 1.5s; 
        else
            echo "封管成功";sleep 1.5s;
        fi
        echo "-->">>sample.txt;
        clear;
    fi
}
#核酸采样人员主菜单
function samplingPersonnelMenu(){
        local key=0;
    while [ $key -ne 3 ]
        do
           echo "============================================"
	       echo "=            欢迎来到核酸检测系统          ="
	       echo "=       当前登录的身份是：核酸采样人员     ="
           echo "============================================"
	       echo "=              1.添加试管信息              ="
	       echo "=              2.添加采样信息              ="
	       echo "=              3.注销当前登录              ="
	       echo "============================================"
           read -p "input operation char:" key;
           case "${key}" in
           1)
                 addTubeInfo;
            ;;
            2)
                addSampleInfo;
            ;;
            3)echo "正在注销当前用户登录……";sleep 1.5s;clear;
            ;;
            *)
                echo "无效操作符，请重新输入！";sleep 0.5s;clear;
            ;;
            esac
        done
}
#核酸检测人员登录
#添加核酸结果
function addNAResult(){
    local tube_id;
    local tester;
    read -p "请输入检测员姓名:" tester;
    while [[ 1 ]]
    do
        read -p "请输入试管编号（0：exit）：" tube_id;
        if [ "$tube_id" -eq 0 ];then
            clear;break
        fi
        searchSample ${tube_id};
        TUBECHECK=$(sed -n "/$tube_id .* <--/p" sample.txt | awk -F' ' '{print $2}');
        if [ "${#tube_id}" -ne 6 ];then
            echo "请输入正确的试管编号！";
        elif [ -z "$TUBEFLAG" ];then
            echo "输入的试管编号不存在，请检查后输入！";
         elif [ "$TUBECHECK" -eq 1 ];then
             echo "该试管已提交过检测结果！";
        else
            curline=$(sed -n "/$tube_id .* <--/=" sample.txt);
           sed -i "$curline s/ 0 / 1 /" sample.txt;
            echo "请选择核酸检测结果";
            select result in 阴性 阳性
            do
                case $result in
                阴性)
                    tmp=$(sed -n "$curline p" sample.txt);
                    while [ "$tmp" != "-->" ]
                    do
                        let "curline++";
                        tmp=$(sed -n "$curline p" sample.txt);
                        getNowTime;
                        sed -i -e "$curline s/result/$result/" -e "$curline s/testtime/$nowtime/" -e "$curline s/tester/$tester/" sample.txt;
                    done
                    echo "正在提交核酸检测结果……";sleep 1.5s;
                    echo "核酸结果已提交！";sleep 1s;break
                ;;
                阳性)
                    tmp=$(sed -n "$curline p" sample.txt);
                    while [ "$tmp" != "-->" ]
                    do
                        let "curline++";
                        tmp=$(sed -n "$curline p" sample.txt);
                        getNowTime;
                        sed -i -e "$curline s/result/$result/" -e "$curline s/testtime/$nowtime/" -e "$curline s/tester/$tester/" sample.txt;
                    done
                    echo "正在提交核酸检测结果……"sleep 1.5s;
                    echo "核酸结果已提交！";sleep 1s;break
                ;;
                *) echo "请重新输入正确的标识符！";
                ;;
                esac
            done
        fi
        done
}
#核酸检测人员主菜单
function inspectPersonnelMenu(){
    local key=0;
    while [ $key -ne 2 ]
        do
           echo "============================================"
	       echo "=            欢迎来到核酸检测系统          ="
	       echo "=       当前登录的身份是：核酸检测人员     ="
           echo "============================================"
	       echo "=              1.录入检测结果              ="
	       echo "=              2.注销当前登录              ="
	       echo "============================================"
           read -p "input operation char:" key;
           case "${key}" in
           1)
                addNAResult;
            ;;
            2)echo "正在注销当前用户登录……";sleep 1.5s;clear;
            ;;
            *)
                echo "无效操作符，请重新输入！";sleep 0.5s;clear;
            ;;
            esac
        done
}
#主菜单
function mainMenu () {
local key=0;
while [ $key -ne 4 ];
    do 
       echo "============================================"
	   echo "=            欢迎来到核酸检测系统          ="
       echo "=               请选择您的身份             ="
       echo "============================================"
       echo "=               1.我是普通市民             ="
       echo "=               2.我是核酸采样人员         ="
       echo "=               3.我是核酸检测人员         ="
       echo "=               4.退出系统                 ="
       echo "============================================"
       read -p "input operation char:" key;
      case "${key}" in
        1)
            clear;citizensMenu;
        ;;
        2)
            clear;samplingPersonnelMenu
        ;;
        3)
            clear;inspectPersonnelMenu
        ;;
        4)echo "已退出系统……"
        ;;
        *)
            echo "无效操作符，请重新输入！";sleep 0.5s;clear;
        ;;
      esac
   done
}
mainMenu;