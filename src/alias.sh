#!/usr/bin/env bash

# porcelain
s3n() {
    operation="${1}"; shift
    case "${operation}" in
      cp) aws s3n-cp "$@" ;;
      create-bucket) aws s3n-create-bucket "$@" ;;
      *)  aws s3n-help ;;
    esac
}

# plumbing
s3n-bucket-name() {
    prefix=$(aws configure get default.s3n.bucket_prefix)
    if [ -z "$prefix" ]; then
      accountid=$(aws sts get-caller-identity --query Account --output text)
      prefix="s3n-${accountid}"
      aws configure set default.s3n.bucket_prefix $prefix
    fi
    if [[ -z "$1" ]]; then echo -n "ERROR"; else echo -n "${prefix}-${1}"; fi
}

s3n-cp() {
    [[ "$@" =~ (.*)s3n:\/\/([^ /]*)([^ ]*) ]] && \
      localpath="$(echo ${BASH_REMATCH[1]} | tr -d '[:space:]')" && \
      filename="${localpath/*\//}" && \
      bucket="${BASH_REMATCH[2]}"
    key=$(aws s3n-key-name "${filename/*\//}")
    aws s3 cp $localpath s3://$(aws s3n-bucket-name "${bucket}")/"${key}"
}

# TODO: Figure out how to set --region
s3n-create-bucket() {
    [[ "$@" =~ (.*)?--bucket[[:space:]]*([^ ]*)[[:space:]]*(.*)? ]] && \
      pre="${BASH_REMATCH[1]}" && \
      bucket="${BASH_REMATCH[2]}" && \
      post="${BASH_REMATCH[3]}"
      aws s3api create-bucket $pre --bucket $(aws s3n-bucket-name $bucket) $post --region us-east-2 --create-bucket-configuration LocationConstraint=us-east-2
}

s3n-help() {
    echo "help"
}

s3n-key-name() {
    hash md5    2>/dev/null && s=$(md5 -qs "$1" )
    hash md5sum 2>/dev/null && s=$(echo -n "$1" | md5sum)
    out="${s:0:6}-${1}"
    if [[ -z "$s" ]] || [[ "$out" = "d41d8c-" ]]; then echo -n "ERROR"; else echo -n "$out"; fi
}
