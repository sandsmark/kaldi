#!/usr/bin/env bash

# Copyright 2020 Martin Sandsmark <martin.sandsmark@kde.org>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# THIS CODE IS PROVIDED *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
# WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR PURPOSE,
# MERCHANTABLITY OR NON-INFRINGEMENT.
# See the Apache 2 License for the specific language governing permissions and
# limitations under the License.

KALDI_ROOT=$(pwd)/../../..

exproot=$(pwd)
dir=data/local/dict
mkdir -p $dir
rm -f "$dir/lexicon.txt"

# Copy pre-made phone table and questions file
cp local/dictsrc/nonsilence_phones.txt $dir/nonsilence_phones.txt
cp local/dictsrc/extra_questions.txt $dir/extra_questions.txt
cp local/dictsrc/silence_phones.txt $dir/silence_phones.txt
cp local/dictsrc/optional_silence.txt $dir/optional_silence.txt

if [ ! -f "data/local/data/download/20191016_nlb_trans.tar.gz" ]; then
    wget https://www.nb.no/sbfil/leksikalske_databaser/20191016_nlb_trans.tar.gz --directory-prefix=data/local/data/download
fi
mkdir -p data/local/data/dict
tar -xzf data/local/data/download/20191016_nlb_trans.tar.gz -C data/local/data/dict
cat data/local/data/dict/20191016_nlb_trans/*.lex | cut -f-2 | iconv -f WINDOWS-1252 -t UTF-8 >> "$dir"/lexicon.txt

# Some words are missing in the official database, so here are some
# generated with espeak, plus SIL and UNK.
cat local/dictsrc/lexicon-missing.txt >> "$dir"/lexicon.txt



echo "Dictionary preparation succeeded"

