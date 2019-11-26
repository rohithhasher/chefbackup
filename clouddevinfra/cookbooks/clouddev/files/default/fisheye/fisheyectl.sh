#!/bin/sh



case "`uname`" in
  Darwin*) if [ -z "$JAVA_HOME" ] ; then
             JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
           fi
           ;;
esac

PRG="$0"
FISHEYE_HOME=`dirname "$PRG"`/..
# make it fully qualified
FISHEYE_HOME=`cd "$FISHEYE_HOME" && pwd`

if [ ! -f "$FISHEYE_HOME/fisheyeboot.jar" ] ; then
  echo "Error: Could not find $FISHEYE_HOME/fisheyeboot.jar"  
  exit 1
fi



if [ -z "$JAVACMD" ] ; then
  if [ -n "$JAVA_HOME"  ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
      # IBM's JDK on AIX uses strange locations for the executables
      JAVACMD="$JAVA_HOME/jre/sh/java"
    else
      JAVACMD="$JAVA_HOME/bin/java"
    fi
  else
    JAVACMD=`which java 2> /dev/null `
    if [ -z "$JAVACMD" ] ; then
        JAVACMD=java
    fi
  fi
fi

if [ ! -x "$JAVACMD" ] ; then
  echo "Error: JAVA_HOME is not defined correctly."
  echo "  We cannot execute $JAVACMD"
  exit 1
fi

if [ -z "$FISHEYE_INST" ] ; then
  FISHEYE_INST=$FISHEYE_HOME
fi

FISHEYE_OPTS=`$JAVACMD -cp $FISHEYE_HOME/fisheyeboot.jar com.cenqua.fisheye.boot.OptsSetter`

FISHEYE_CMD="$JAVACMD $FISHEYE_OPTS  -Dfisheye.library.path=$FISHEYE_LIBRARY_PATH -Dfisheye.inst=$FISHEYE_INST -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Djava.endorsed.dirs=$FISHEYE_HOME/lib/endorsed -jar $FISHEYE_HOME/fisheyeboot.jar"
if [ "$1" = "start" ] ; then
  cd $FISHEYE_INST
  mkdir -p $FISHEYE_INST/var/log
  nohup sh -c "exec $FISHEYE_CMD $@ $FISHEYE_ARGS >> $FISHEYE_INST/var/log/fisheye.out 2>&1" &
else
  exec $FISHEYE_CMD $@ $FISHEYE_ARGS
fi
