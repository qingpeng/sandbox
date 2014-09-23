
Note: at the moment, the khmer script ``normalize-by-median.py`` needs
to be updated from the master branch of `khmer
<https://github.com/ged-lab/khmer>`__ to run this code properly.  Once
we've cut a new release, we'll remove this note and simply specify the
khmer release required.

.. shell start

.. ::

   . ~/dev/ipy7/bin/activate
   set -e
   
# make a 500 bp repeat
   python ~/dev/nullgraph/make-random-genome.py -l 500 -s 10 > repeat.fa
   
   # create a genome with 5kb unique sequence interspersed with 5x 500 bp
   # repeats.
   echo '>genome' > genome.fa
   cat repeat.fa | grep -v ^'>' >> genome.fa
   python ~/dev/nullgraph/make-random-genome.py -l 1000 -s 1 | grep -v ^'>' >> genome.fa
   cat repeat.fa | grep -v ^'>' >> genome.fa
   python ~/dev/nullgraph/make-random-genome.py -l 1000 -s 2 | grep -v ^'>' >> genome.fa
   cat repeat.fa | grep -v ^'>' >> genome.fa
   python ~/dev/nullgraph/make-random-genome.py -l 1000 -s 3 | grep -v ^'>' >> genome.fa
   cat repeat.fa | grep -v ^'>' >> genome.fa
   python ~/dev/nullgraph/make-random-genome.py -l 1000 -s 4 | grep -v ^'>' >> genome.fa
   cat repeat.fa | grep -v ^'>' >> genome.fa
   python ~/dev/nullgraph/make-random-genome.py -l 1000 -s 5 | grep -v ^'>' >> genome.fa
   
   # build a read set
   python ~/dev/nullgraph/make-reads.py -C 150 genome.fa > reads.fa

Let's assume you have a simple genome with some 5x repeats, and you've
done some shotgun sequencing to a coverage of 150 or higher.  If your reads are
in ``reads.fa``, you can get an estimate of the single-copy genome size
(here known to be 5500 bp) by running ``normalize-by-median.py``
