#!/bin/sh

fileNames=()
for fileName in $@
do
    if [ -d "${fileName}" ];
    then
        fileNames[${#fileNames[@]}]="${fileName}"
    else
        echo "\033[33m警告: ${fileName} 无法找到该目录\033[0m"
    fi
done

if [ ${#fileNames[@]} -eq 0 ];
then
    echo "\033[31m错误: 请输入正确目录路径，多个以空格分开\033[0m"
    exit 0
fi

for fileName in "${fileNames[@]}"
do
    echo "信息: 转换目录 ${fileName} 中的ape文件"
    for FILE in ${fileName}/*.ape;
    do
        echo "==> 信息: 转换 ${FILE} 为 temp.wav"
        ffmpeg -loglevel quiet -i "$FILE" ${fileName}/temp.wav;
        echo "==> 信息: 转换 temp.wav 为 ${FILE%.*}.mp3"
        lame --quiet -b 320 ${fileName}/temp.wav "${FILE%.*}.mp3";
        rm ${fileName}/temp.wav
        if [ -f "${FILE%.*}.cue" ];
        then
            echo "==> 信息: 切割 ${FILE%.*}.mp3 为多个音频"
            mkdir ${fileName}/Track
            mp3splt -Q -c ${FILE%.*}.cue -o Track/@n.@t ${FILE%.*}.mp3
        fi
    done
done