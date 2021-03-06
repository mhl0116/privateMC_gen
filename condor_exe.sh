PACKAGE=package.tar.gz
OUTPUTDIR=$1
OUTPUTFILENAME=$2
INPUTFILENAMES=$3
INDEX=$4
CMSSW_VER=$5

ARGS=$7

echo "[wrapper] OUTPUTDIR	= " ${OUTPUTDIR}
echo "[wrapper] OUTPUTFILENAME	= " ${OUTPUTFILENAME}
echo "[wrapper] INPUTFILENAMES	= " ${INPUTFILENAMES}
echo "[wrapper] INDEX		= " ${INDEX}

echo "[wrapper] printing env"
printenv
echo

echo "[wrapper] hostname  = " `hostname`
echo "[wrapper] date      = " `date`
echo "[wrapper] linux timestamp = " `date +%s`

######################
# Set up environment #
######################

export SCRAM_ARCH=slc6_amd64_gcc700
source /cvmfs/cms.cern.ch/cmsset_default.sh

# Untar
tar -xvf package.tar.gz

# Build
cd $CMSSW_VER/src
echo "[wrapper] in directory: " ${PWD}
echo "[wrapper] attempting to build"
eval `scramv1 runtime -sh`
scramv1 b ProjectRename
scram b -j3
eval `scramv1 runtime -sh`

cmssw_cfg="template.py"

if [[ $ARGS == *"2016MC"* ]]
then

    cmssw_cfg="NanoAODCFG_2016MC.py"

elif [[  $ARGS == *"2017MC"*  ]]
then 

    cmssw_cfg="NanoAODCFG_2017MC.py"

elif [[  $ARGS == *"2018MC"*  ]]
then 

    cmssw_cfg="NanoAODCFG_2018MC.py"

elif [[  $ARGS == *"2016Data"*  ]]
then 

    cmssw_cfg="NanoAODCFG_2016Data.py"
elif [[  $ARGS == *"2017Data"*  ]]
then 

    cmssw_cfg="NanoAODCFG_2017Data.py"
elif [[  $ARGS == *"2018Data"*  ]]
then 

    cmssw_cfg="NanoAODCFG_2018Data.py"
else
    echo "Don't know which cmssw cfg to use, check ARGS!!"
fi

# update input file
echo "process.source = cms.Source(\"PoolSource\",
fileNames=cms.untracked.vstring(\"${INPUTFILENAMES}\".replace('/hadoop', 'file:/hadoop').split(\",\"))
)

process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32( -1 ) )
" >> $cmssw_cfg 
#" >> HIG-RunIIAutumn18NanoAODv7-01134_1_cfg_template.py

# Create tag file
#echo "[wrapper `date +\"%Y%m%d %k:%M:%S\"`] running: cmsRun HIG-RunIIAutumn18NanoAODv7-01134_1_cfg_template.py"
#cmsRun HIG-RunIIAutumn18NanoAODv7-01134_1_cfg_template.py 
echo "[wrapper `date +\"%Y%m%d %k:%M:%S\"`] running: cmsRun "${cmssw_cfg}
cmsRun ${cmssw_cfg} 

if [ "$?" != "0" ]; then
    echo "Removing output file because cmsRun crashed with exit code $?"
    rm *.root
fi

echo "[wrapper] output root files are currently: "
ls -lh *.root

# Copy output
env -i X509_USER_PROXY=${X509_USER_PROXY} gfal-copy -p -f -t 4200 --verbose file://`pwd`/${OUTPUTFILENAME}.root gsiftp://gftp.t2.ucsd.edu/${OUTPUTDIR}/${OUTPUTFILENAME}_${INDEX}.root --checksum ADLER32
