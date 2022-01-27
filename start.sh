mkdir -p outputs

# set initial variables
#export PREFIX=$USER
export PREFIX='briar'
export SUFFIX=$RANDOM
export RG=$PREFIX-container-app-demo-$SUFFIX
#export LOCATION='canadacentral'
export LOCATION='eastus'
export LOGFILE_NAME="./outputs/${RG}.log"

./walk-the-dog.sh $RG $LOCATION $SUFFIX 2>&1 | tee -a $LOGFILE_NAME