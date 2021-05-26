############################### 打tag ################################
inputpodtag=''
if [ -n "$1" ]
then
inputpodtag="$1"
else
    echo -n "请输入你要打的tag:"
    # 使用 while 循环隐式地从标准输入每次读取一个字符，且反斜杠不做转义字符处理
    # 然后将读取的字符赋值给变量 char
    while IFS= read -r -s -n1 char
    do
        # 如果读入的字符为空，则退出 while 循环
        if [ -z $char ]
        then
            echo
            break
        fi
        # 如果输入的是退格或删除键，则移除一个字符
        if [[ $char == $'\x08' || $char == $'\x7f' ]]
        then
            [[ -n $inputpodtag ]] && inputpodtag=${inputpodtag:0:${#inputpodtag}-1}
            printf '\b \b'
        else
            inputpodtag+=$char
            printf $char
        fi
    done
fi

echo "inputpodtag is: $inputpodtag"

git tag ${inputpodtag}
git push origin --tags

################################ 获取podspec文件名称 ################################



packageDIR=`pwd`
podName=${packageDIR##*/}

cur_dir=$(cd "$(dirname "$0")"; pwd)
for file in `ls $cur_dir`
do
cd $cur_dir
if [[ $file == *.podspec ]]; then
podName=${file%.podspec}
podName=${podName%.json}
echo $podName
if [ -f "${podName}.podspec" ];then
podspecFile="${podName}.podspec"
fi

if [ -f "${podName}.podspec.json" ];then
podspecFile="${podName}.podspec.json"
fi
echo "podName ----->"${podName}
echo 'COMMIT-podspec-FILE'
sourceRepo='http://code.soulapp-inc.cn/front/CocoapodsPrivateRepo.git'
sourceRepoName='CocoapodsPrivateRepo'
version=`git describe --abbrev=0 --tags 2>/dev/null`

echo $version
cd ..
specsDir=`pwd`/${sourceRepoName}/
echo "specsdir ---->"$specsDir
if [ -d $specsDir ];
then
cd $specsDir
git pull
else
git clone $sourceRepo
cd $specsDir
fi
echo 'FILE-PATH:'
echo ${specsDir}${podName}/${version}
echo $packageDIR/${podspecFile}
mkdir -p  ${specsDir}${podName}/${version}
echo ${specsDir}${podName}/${version}/${podspecFile}
cp $packageDIR/${podspecFile} ${specsDir}${podName}/${version}
echo '文件copy'
destSource='"'${version}'"'
sed -i ''  's/= smart_version/= '${destSource}'/g' ${specsDir}${podName}/${version}/${podspecFile}
echo '替换版本号'

nowDIR=`pwd`
echo 'nowDIR->' ${nowDIR}

git status
git add .
git commit -m "[Add] ${podName} (${version})"
git push

cd ..
rm -rf $sourceRepoName

fi
done

