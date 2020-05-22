#!/bin/bash
export SCRAM_ARCH=slc6_amd64_gcc630
source /cvmfs/cms.cern.ch/cmsset_default.sh
if [ -r CMSSW_9_4_6_patch1/src ] ; then 
 echo release CMSSW_9_4_6_patch1 already exists
else
scram p CMSSW CMSSW_9_4_6_patch1
fi
cd CMSSW_9_4_6_patch1/src
eval `scram runtime -sh`


scram b
cd ../../
cmsDriver.py step1 --filein "dbs:/TTHH_TuneCP5_13TeV-madgraph-pythia8/RunIIFall17DRPremix-PU2017_94X_mc2017_realistic_v11-v1/AODSIM" --fileout file:TOP-RunIIFall17MiniAODv2-00217.root --mc --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions 94X_mc2017_realistic_v14 --step PAT --nThreads 4 --scenario pp --era Run2_2017,run2_miniAOD_94XFall17 --python_filename TOP-RunIIFall17MiniAODv2-00217_1_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 4800 || exit $? ; 
