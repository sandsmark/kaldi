#!/usr/bin/env bash

# Copyright 2009-2012  Microsoft Corporation  Johns Hopkins University (Author: Daniel Povey)
# Copyright 2013-2014  Mirsk Digital Aps (Author: Andreas Kirkedal)
# Copyright 2016 KTH Royal Institute of Technology (Author: Emelie Kullmann)
# Apache 2.0.

set -e

dir=`pwd`/data/local/data
lmdir=`pwd`/data/local/transcript_lm
traindir=`pwd`/data/local/trainsrc
testdir=`pwd`/data/local/testsrc
rm -r $lmdir $traindir $testdir $devdir
mkdir -p $dir $lmdir $traindir $testdir $devdir
local=`pwd`/local
utils=`pwd`/utils

echo "$dir"

. ./path.sh

sph2pipe=$(which sph2pipe) || sph2pipe=$KALDI_ROOT/tools/sph2pipe_v2.5/sph2pipe
if [ ! -x $sph2pipe ]; then
   echo "Could not find (or execute) the sph2pipe program at $sph2pipe . Did you run 'make' in the tools directory?";
   exit 1;
fi

echo "Downloading, unpacking and processing corpus to $dir/corpus_processed. This will take a while."

rm -f "$lmdir/lmsents" "$dir/traintxtfiles" "$dir/trainsndfiles" "$lmdir/transcripts.uniq" "$lmdir/lmsents.norm"

for PACKAGE in 0463-{1,2,3,4} 0464-testing; do
    EXTRACT_DIR="$dir/download/$PACKAGE"
    if [ ! "$(ls -A "$EXTRACT_DIR")" ]; then

        if [ ! -d "$EXTRACT_DIR" ]; then
            mkdir -p "$dir/download/$PACKAGE"
        fi

        FILENAME="no.16khz.$PACKAGE.tar.gz"
        if [ ! -f "$dir/download/"$FILENAME ]; then
            ( echo wget --tries 100 "https://www.nb.no/sbfil/talegjenkjenning/16kHz/$FILENAME" --directory-prefix=$dir/download )
        fi

        if [ "$(command -v pigz)" -a "$(command -v pv)" ]; then
            pv "$dir/download/$FILENAME" | pigz -dc - | tar xf - -C "$EXTRACT_DIR"
        else
            tar -xzf $dir/download/"$FILENAME" -C "$EXTRACT_DIR"
        fi
    fi

    PROCESSED_DIR="$dir/corpus_processed/training/$PACKAGE"
    echo "Checking testing"
    if [[ $PACKAGE == *"testing"* ]]; then
        PROCESSED_DIR="$dir/corpus_processed/testing/$PACKAGE"
    fi
    echo "Processing $PACKAGE to $PROCESSED_DIR"
    echo "Checking exists"
    if [ ! -d "$PROCESSED_DIR" ]; then
        echo "Running python"
        mkdir -p "$PROCESSED_DIR"
        python "$local/sprak2kaldi.py" "$EXTRACT_DIR" "$PROCESSED_DIR"
    fi
    echo "CReating data"

    # Creating testing and training data
    if [[ $PACKAGE == *"testing"* ]]; then
        echo "============= testing dir ============="
        cat "$PROCESSED_DIR/txtlist" >> "$dir/testtxtfiles"
        cat "$PROCESSED_DIR/sndlist" >> "$dir/testsndfiles"
    else
        cat "$PROCESSED_DIR/txtlist" | while read l; do cat $l; done >> "$lmdir/lmsents"
        cat "$PROCESSED_DIR/txtlist" >> "$dir/traintxtfiles"
        cat "$PROCESSED_DIR/sndlist" >> "$dir/trainsndfiles"
    fi
done

echo "Corpus files downloaded."

echo "done"

echo "Converting downloaded files to a format consumable by Kaldi scripts."

python "$local/normalize_transcript.py" "$lmdir/lmsents" "$lmdir/lmsents.norm"
sort -u "$lmdir/lmsents.norm" > "$lmdir/transcripts.uniq"

# Write wav.scp, utt2spk and text.unnormalised for train, test and dev sets with
# Use sph2pipe because the wav files are actually sph files
echo "Creating wav.scp, utt2spk and text.unnormalised for train" 
python3 "$local/data_prep.py" "$dir/traintxtfiles" "$traindir" "$dir/trainsndfiles" "$sph2pipe"
echo "Creating wav.scp, utt2spk and text.unnormalised for test" 
python3 "$local/data_prep.py" "$dir/testtxtfiles" "$testdir" "$dir/testsndfiles" "$sph2pipe"

# Create the main data sets
echo "Creating main data set for test"
"$local/create_datasets.sh" "$testdir" data/test 
echo "Creating main data set for train"
"$local/create_datasets.sh" "$traindir" data/train 


echo "Data preparation succeeded"
