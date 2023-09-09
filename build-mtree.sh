#! /bin/sh

. lib.sh

parse_args "$@"
if [ ${BUILD} = yes ]; then
    build_mtree mtree
fi
