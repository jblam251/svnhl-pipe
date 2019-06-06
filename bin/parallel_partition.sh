module load gcc/5.4.0
module load cnvnator/0.3.3
module load root/6.14.04

for i in {1..3}
do
    srun -N1 -n1 -c1 --mem-per-cpu=1000 --time=00:30:00 cnvnator -root $1 -partition 50 -chrom chr$i &
done
wait


# -c = --cpus-per-task
# -n = --ntasks
# -N = --nodes
