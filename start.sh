mkdir -p outputs

# set initial variables
export PREFIX=$USER
export SUFFIX=$RANDOM
export RG=$PREFIX-container-app-demo-$SUFFIX
export LOCATION='canadacentral'
export LOGFILE_NAME="./outputs/${RG_NAME}.log"

./walk-the-dog.sh $RG_NAME $LOCATION $SUFFIX 2>&1 | tee -a $LOGFILE_NAME