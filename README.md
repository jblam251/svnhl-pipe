# svnhl-pipe
A Parallelized Structural Variant Calling Pipeline for Canine Non-Hodgkin Lymphoma 

Structural variant calling with svnhl-pipe requires paired-end reads.  Input can either be the aligned reads, or the raw FASTQ files.  After pre-processing, the reads are piped into three separate but complementary structural variant callers: [DELLY](https://github.com/dellytools/delly), [Breakdancer](https://github.com/genome/breakdancer), and [CNVnator](https://github.com/abyzovlab/CNVnator).  Each caller processes the data in-parallel and produces two Variant Call Format (VCF) files: one for all variant calls, and one for only the somatic calls.  The  VCF files will then be merged, and high-confidence variants (those called by multiple tools) will be marked for further analysis. 

Variant calls will eventually be assembled and mapped back to the reference. See below for a schematic of the svnhl-pipe workflow.

![alt text](https://github.com/jblam251/svnhl-pipe/blob/master/pipe-08092019.png)



