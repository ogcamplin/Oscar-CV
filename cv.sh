#!/bin/zsh

apply(){
  echo "Applying $1..."
  cd "terraform/$1" || return
  terraform init 
  terraform plan -out outfile
  terraform apply -auto-approve
}

destroy(){
  echo "Destroying $1..."
  cd "terraform/$1" || return
  terraform destroy -auto-approve
}

cmd=$1

base_dir=$(pwd)

if [ "$cmd" = "apply" ];
then
    apply "networking"
    cd $base_dir || return
    apply "instance"
  elif [ "$cmd" = "destroy" ] 
then
    destroy "instance"
    cd $base_dir || return
    destroy "networking"
else
    echo "Please provide arg (apply or destroy)"
fi