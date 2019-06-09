
all_output_folder="/net/shendure/vol1/home/cao1025/Projects/nobackup/181022_time_test/output_STAR_para_1/"
control_cell="/net/shendure/vol1/home/cao1025/Projects/processed_data/181023_scitime_test/data/RData/control_cell_id.csv"
gtf_file="/net/shendure/vol1/home/cao1025/reference/gtf_reference/hg19_mm10/rmchr.gencode.v19.chr_patch_hapl_scaff.annotation.gencode.vM12.chr_patch_hapl_scaff.annotation.gtf.gz"
core=10
script_folder="/net/shendure/vol1/home/cao1025/analysis_script/scRNA_seq_pipe"
reference_fa="/net/shendure/vol1/home/cao1025/reference/fasta/hs37d5_mm10.fa"
varscan="/net/shendure/vol1/home/cao1025/Download/VarScan.v2.3.9.jar"

script_folder="/net/shendure/vol1/home/cao1025/analysis_script/scitimelapse/"
R_script="/net/shendure/vol1/home/cao1025/analysis_script/sci3/sci3_bash_input_ID_output_core.R"
Rscript="/net/shendure/vol1/home/cao1025/bin/Rscript.3.5"
gene_count_script="/net/shendure/vol1/home/cao1025/analysis_script/scRNA_seq_pipe/sciRNAseq_count.py"

#define the bin of python
python_path="/net/shendure/vol1/home/cao1025/anaconda2/bin/"

# in this script, I will generate a file and count T -> C mutation in each single cell sam file
input_folder=$all_output_folder/mutation_count/
sample_ID=$all_output_folder/barcode_samples.txt
output_folder=$all_output_folder/new_synthesised_reads/
SNP_VCF=$all_output_folder/combind_control_bam/SNP.vcf
# filter the newly synthesised reads for each reads
$Rscript $script_folder/select_newly_synthesised_read.R $input_folder $sample_ID $output_folder $core $SNP_VCF

# in this script, I will generate a file and identify T -> C mutation in each single cell sam file
input_folder=$all_output_folder
sample_list=$all_output_folder/new_synthesised_reads/sample_id.txt
output_folder=$all_output_folder/new_reads_sam/

mkdir $output_folder
# generate al alignment files for the output
bash_script=$script_folder/extract_new_reads.sh
$Rscript $R_script $bash_script $input_folder $sample_list $output_folder $core
echo analysis done.

# Generate gene count matrix for all files
input_folder=$all_output_folder/new_reads_sam/
sample_ID=$all_output_folder/new_synthesised_reads/sample_id.txt
output_folder=$all_output_folder/report/newly_syn_human_mouse_gene_count/

script=$gene_count_script
echo "Start the gene count...."
$python_path/python $script $gtf_file $input_folder $sample_ID $core

echo "Make the output folder and transfer the files..."
mkdir -p $output_folder
cat $input_folder/*.count > $output_folder/count.MM
rm $input_folder/*.count
cat $input_folder/*.report > $output_folder/report.MM
rm $input_folder/*.report
mv $input_folder/*_annotate.txt $output_folder/
echo "All output files are transferred~"