export KALDI_ROOT=`pwd`/../../..
[ -f $KALDI_ROOT/tools/env.sh ] && . $KALDI_ROOT/tools/env.sh
export PATH="$PWD/utils/:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/build/src/featbin:$KALDI_ROOT/build/src/fstbin:$KALDI_ROOT/build/src/gmmbin:$KALDI_ROOT/build/src/bin:$PWD:$PATH"
export PATH="$KALDI_ROOT/build/src/lmbin:$PWD:$PATH"
[ ! -f $KALDI_ROOT/tools/config/common_path.sh ] && echo >&2 "The standard file $KALDI_ROOT/tools/config/common_path.sh is not present -> Exit!" && exit 1
. $KALDI_ROOT/tools/config/common_path.sh
export LC_ALL=C
