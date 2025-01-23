#!/bin/bash

############################
#Config
raw_dir="/path/to/rawdata" #rawdataのあるディレクトリ
primer_1="AAGTCGGAGGCCAAGCGGTCTTAGGAAGACAA" #除去するアダプター配列情報 #1
primer_2="AAGTCGGATCGTAGCCATGTCGTTCTGTGAGCCAAGGAGTTG" #除去するアダプター配列情報 #2
ref="/path/to/genome.fna"      #リファレンスとなるゲノム配列のfastaファイル
gtf="/path/to/genomic.gtf"      #リファレンスとなるgtfファイル
output="/path/to/output_dir"   #アウトプットを出力するディレクトリ 

############################
#outputディレクトリに移動
cd $output

############################
#インプットデータの準備
#生データの統計情報を出力, manifestファイルを作成
seqfu stats $raw_dir/*gz --csv > rawdata_stat.csv
seqfu metadata --format manifest  $raw_dir/ > manifest.tsv


# 一行目を削除して一時ファイルに保存
tail -n +2 manifest.tsv > temp.tsv
# 各行を配列に読み込む
mapfile -t lines < temp.tsv

################################
#クオリティコントロール

#配列情報を含むファイルを作成
echo ">adapter1/1" >> adapters.fa
echo $primer_1 >> adapters.fa
echo ">adapter1/2" >> adapters.fa
echo $primer_2 >> adapters.fa

# Trimmomatic
for line in "${lines[@]}"; do
    IFS=$'\t' read -r ID raw1 raw2 <<< "$line"
  trimmomatic PE -threads 4 -phred33 -trimlog ${ID}_TrimLog.txt "${raw1}" "${raw2}" "${ID}_R1_trimmed.fastq.gz" "${ID}_R1_unpaired.fastq.gz" "${ID}_R2_trimmed.fastq.gz" "${ID}_R2_unpaired.fastq.gz" ILLUMINACLIP:adapters.fa:2:30:10 LEADING:20 TRAILING:20 SLIDINGWINDOW:4:15 MINLEN:36   
done

###############################
#クオリティチェック

# IDリストを作成
ID=() # Initialize an empty array
while IFS=$'\t' read -r col1 _; do # Read the first column of temp.tsv and store it in the array
    ID+=("$col1")
done < temp.tsv

# outputディレクトリを作成
mkdir -p fastqc

# fastqcの実行。ID変数を改行で区切られたリストとして扱う
for id in "${ID[@]}"; do
    fastqc -t 10 --nogroup -o fastqc -f fastq ${id}_R1_trimmed.fastq.gz ${id}_R2_trimmed.fastq.gz
done

##############################
#マッピング

#indexの作成
STAR --runMode genomeGenerate --genomeDir star_rsem --runThreadN 10 --sjdbOverhang 99 --genomeFastaFiles $ref --sjdbGTFfile $gtf --genomeSAindexNbases 13

#outputディレクトリを作成
mkdir ster_out

#sterによるマッピング
for id in "${ID[@]}"; do
STAR --genomeDir star_rsem --runThreadN 10 --outFileNamePrefix ster_out/${id}/ --quantMode TranscriptomeSAM --outSAMtype BAM SortedByCoordinate --readFilesIn ${id}_R1_trimmed.fastq.gz ${id}_R2_trimmed.fastq.gz --readFilesCommand gunzip -c
done 

##############################
#RSEMによるリードカウント

#インデックスの作成・リファレンスデータの生成
rsem-prepare-reference --gtf $gtf -p 10 $ref star_rsem/rsem_index

#rsemによるマッピング
for id in "${ID[@]}"; do
rsem-calculate-expression --alignments --paired-end -p 10 --strandedness reverse --append-names --estimate-rspd ster_out/${id}/Aligned.toTranscriptome.out.bam star_rsem/rsem_index ${id}
done

##############################
#リードカウントファイルを整理
mkdir rsem_result #カウントデータを格納するフォルダを作成

#ファイルの振り分けおよびリネーム
for id in "${ID[@]}"; do
mkdir ./rsem_result/${id}_exp_rsem 
cp ${id}.*.results ./rsem_result/${id}_exp_rsem
mv ./rsem_result/${id}_exp_rsem/${id}.genes.results ./rsem_result/${id}_exp_rsem/genes.results
mv ./rsem_result/${id}_exp_rsem/${id}.isoforms.results ./rsem_result/${id}_exp_rsem/isoforms.results
done

##############################
#中間ファイルを整理
mkdir tmp output logs trimmed trim_log

#不要なファイルを削除
rm *_unpaired.fastq.gz manifest.tsv temp.tsv *.genes.results *isoforms.results

#ファイルを移動
mv nohup.out rnamap.log #nohup 
mv *_TrimLog.txt trim_log
mv trim_log rnamap.log logs
mv rawdata_stat.csv fastqc rsem_result output
mv *gz trimmed
mv *.stat trimmed adapters.fa *.transcript.bam ster_out star_rsem tmp
