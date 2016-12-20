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
    accountid=$(aws configure get default.s3n.bucket_prefix)
    if [ -z "$accountid" ]; then
      accountid=$(aws sts get-caller-identity --query Account --output text)
      aws configure set default.s3n.bucket_prefix "$accountid"
    fi
    i=$(aws configure get default.s3n.bucket_prefix)
    echo "s3n-${accountid:0:6}-${1}"
}

s3n-cp() {
    [[ "$@" =~ (.*)s3n://([^ /]*)([^ ]*) ]] && \
      localpath="${BASH_REMATCH[1]}" && \
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
    if [ -x md5 ]; then s=$(echo -n "${1}" | md5sum); fi
    echo "${s:0:6}-${1}";
}
